"""
End-to-end automation that walks through the core consumer purchase journey:

1. Register consumer, merchant, and admin users (via auth-service)
2. Merchant registers a business, admin approves it
3. Merchant creates + publishes a voucher
4. Consumer purchases the voucher (order + payment)
5. Wallet service issues the voucher and consumer can see it
6. Merchant redeems the voucher

This test intentionally calls each microservice directly (bypassing APISIX) so
failures point to the specific service. Lightweight DB helpers are used to set
up shared fixtures (activating users, ensuring voucher categories) because
there are no public APIs for those operations yet.
"""

from __future__ import annotations

import os
import random
import string
import time
import uuid
from dataclasses import dataclass
from decimal import Decimal
from typing import Any, Dict, List, Optional

import psycopg
import pytest
import requests
from tenacity import retry, stop_after_attempt, wait_fixed


# Base URLs (override via env vars if services are hosted elsewhere)
AUTH_BASE = os.getenv("AUTH_BASE_URL", "http://localhost:8081")
MERCHANT_BASE = os.getenv("MERCHANT_BASE_URL", "http://localhost:8088")
VOUCHER_BASE = os.getenv("VOUCHER_BASE_URL", "http://localhost:8083")
ORDER_BASE = os.getenv("ORDER_BASE_URL", "http://localhost:8084")
WALLET_BASE = os.getenv("WALLET_BASE_URL", "http://localhost:8086")
REDEMPTION_BASE = os.getenv("REDEMPTION_BASE_URL", "http://localhost:8087")

# Database connectivity (matches docker-compose + scripts)
DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "dbname": os.getenv("POSTGRES_DB", "kado24_db"),
    "user": os.getenv("POSTGRES_USER", "kado24_user"),
    "password": os.getenv("POSTGRES_PASSWORD", "kado24_pass"),
}


@dataclass
class RegisteredUser:
    id: int
    token: str
    phone: str
    role: str


class DbHelper:
    def __init__(self) -> None:
        self.conn = psycopg.connect(**DB_CONFIG)
        self.conn.autocommit = True
        self.multi_schema = self._detect_multi_schema()

    def close(self) -> None:
        self.conn.close()

    def _detect_multi_schema(self) -> bool:
        with self.conn.cursor() as cur:
            cur.execute(
                "SELECT 1 FROM information_schema.schemata WHERE schema_name=%s",
                ("auth_schema",),
            )
            return cur.fetchone() is not None

    def table(self, logical: str) -> str:
        if self.multi_schema:
            mapping = {
                "users": "auth_schema.users",
                "voucher_categories": "shared_schema.voucher_categories",
            }
        else:
            mapping = {
                "users": "users",
                "voucher_categories": "voucher_categories",
            }
        return mapping[logical]

    def activate_user(self, user_id: int) -> None:
        table = self.table("users")
        with self.conn.cursor() as cur:
            cur.execute(
                f"""
                UPDATE {table}
                   SET status = 'ACTIVE',
                       phone_verified = TRUE,
                       email_verified = TRUE
                 WHERE id = %s
                """,
                (user_id,),
            )

    def ensure_category(self, name: str) -> int:
        table = self.table("voucher_categories")
        if self.multi_schema:
            sql = (
                f"""
                INSERT INTO {table} (name, display_name, icon, color, sort_order, is_active)
                VALUES (%s, %s, %s, %s, %s, TRUE)
                ON CONFLICT (name) DO UPDATE
                    SET display_name = EXCLUDED.display_name
                RETURNING id
                """
            )
            values = (name, f"{name} Display", "🎯", "#5A67D8", 99)
        else:
            sql = (
                f"""
                INSERT INTO {table} (name, slug, description, display_order, icon_url)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (slug) DO UPDATE
                    SET description = EXCLUDED.description
                RETURNING id
                """
            )
            slug = name.lower().replace(" ", "-")
            values = (name, slug, "Automation category", 99, "🎯")

        with self.conn.cursor() as cur:
            cur.execute(sql, values)
            cat_id = cur.fetchone()[0]
        return cat_id


def random_phone() -> str:
    digits = random.randint(100_00000, 999_99999)  # 8 digits
    return f"+855{digits}"


def random_email(prefix: str) -> str:
    suffix = uuid.uuid4().hex[:6]
    return f"{prefix}-{suffix}@test.kado24.local"


def random_business_name() -> str:
    suffix = "".join(random.choices(string.ascii_uppercase, k=4))
    return f"Automation Merchant {suffix}"


def parse_response(resp: requests.Response) -> Dict[str, Any]:
    resp.raise_for_status()
    payload = resp.json()
    assert payload.get("success"), f"API failure: {payload}"
    return payload


def post_json(base: str, path: str, token: Optional[str] = None, json: Any = None) -> Dict[str, Any]:
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    resp = requests.post(f"{base}{path}", json=json, headers=headers, timeout=30)
    return parse_response(resp)


def get_json(base: str, path: str, token: Optional[str] = None, params: Any = None) -> Dict[str, Any]:
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    resp = requests.get(f"{base}{path}", params=params, headers=headers, timeout=30)
    return parse_response(resp)


def register_user(role: str) -> RegisteredUser:
    payload = {
        "fullName": f"Automation {role.title()}",
        "phoneNumber": random_phone(),
        "email": random_email(role.lower()),
        "password": "TestPass1",
        "role": role,
    }
    data = post_json(AUTH_BASE, "/api/v1/auth/register", json=payload)["data"]
    return RegisteredUser(
        id=int(data["user"]["id"]),
        token=data["accessToken"],
        phone=payload["phoneNumber"],
        role=role,
    )


def register_merchant_profile(token: str) -> Dict[str, Any]:
    payload = {
        "businessName": random_business_name(),
        "businessType": "Restaurant",
        "businessLicense": f"LIC-{uuid.uuid4().hex[:6]}",
        "taxId": f"TAX-{uuid.uuid4().hex[:6]}",
        "phoneNumber": random_phone(),
        "email": random_email("merchant"),
        "description": "Automated test merchant",
        "addressLine1": "123 Main St",
        "city": "Phnom Penh",
        "province": "Phnom Penh",
        "bankName": "ABA Bank",
        "bankAccountNumber": str(random.randint(10_00000000, 99_99999999)),
        "bankAccountName": "Automation QA",
    }
    return post_json(
        MERCHANT_BASE, "/api/v1/merchants/register", token=token, json=payload
    )["data"]


def approve_merchant(admin_token: str, merchant_id: int) -> Dict[str, Any]:
    return post_json(
        MERCHANT_BASE, f"/api/v1/merchants/{merchant_id}/approve", token=admin_token
    )["data"]


def create_voucher(token: str, category_id: int) -> Dict[str, Any]:
    payload = {
        "categoryId": category_id,
        "title": f"Automation Voucher {uuid.uuid4().hex[:4]}",
        "description": "Automated voucher for testing",
        "termsAndConditions": "Use once",
        "denominations": [25.00],
        "discountPercentage": 0,
        "stockQuantity": 10,
        "unlimitedStock": False,
        "usageInstructions": "Show QR code",
    }
    return post_json(VOUCHER_BASE, "/api/v1/vouchers", token=token, json=payload)["data"]


def publish_voucher(token: str, voucher_id: int) -> Dict[str, Any]:
    return post_json(
        VOUCHER_BASE, f"/api/v1/vouchers/{voucher_id}/publish", token=token
    )["data"]


def create_order(token: str, voucher_id: int, denomination: Decimal) -> Dict[str, Any]:
    payload = {
        "voucherId": voucher_id,
        "denomination": float(denomination),
        "quantity": 1,
        "customerNotes": "Automation order",
    }
    return post_json(ORDER_BASE, "/api/v1/orders", token=token, json=payload)["data"]


def pay_order(token: str, order: Dict[str, Any]) -> Dict[str, Any]:
    payload = {
        "orderId": order["id"],
        "paymentMethod": "ABA_PAY",
        "amount": float(order["totalAmount"]),
    }
    return post_json(ORDER_BASE, "/api/v1/payments", token=token, json=payload)["data"]


def list_wallet_entries(token: str) -> List[Dict[str, Any]]:
    page = get_json(WALLET_BASE, "/api/v1/wallet", token=token)["data"]
    if isinstance(page, dict) and "content" in page:
        return page["content"]
    raise AssertionError(f"Unexpected wallet payload: {page}")


@retry(stop=stop_after_attempt(10), wait=wait_fixed(1))
def wait_for_wallet_entry(token: str, voucher_id: int) -> Dict[str, Any]:
    entries = list_wallet_entries(token)
    for entry in entries:
        if entry.get("voucherId") == voucher_id:
            return entry
    raise AssertionError("Wallet entry not yet available")


def redeem_voucher(token: str, voucher_code: str, amount: Decimal) -> Dict[str, Any]:
    payload = {
        "voucherCode": voucher_code,
        "amount": float(amount),
        "location": "Automation Branch",
    }
    return post_json(
        REDEMPTION_BASE, "/api/v1/redemptions/redeem", token=token, json=payload
    )["data"]


@pytest.mark.fullflow
def test_consumer_purchase_and_redemption_flow():
    db = DbHelper()
    try:
        consumer = register_user("CONSUMER")
        merchant_user = register_user("MERCHANT")
        admin_user = register_user("ADMIN")

        # Activate accounts so subsequent logins/actions succeed
        for user in (consumer, merchant_user, admin_user):
            db.activate_user(user.id)

        merchant_profile = register_merchant_profile(merchant_user.token)
        approved_merchant = approve_merchant(admin_user.token, merchant_profile["id"])
        assert approved_merchant["verificationStatus"] == "APPROVED"

        category_id = db.ensure_category("Automation Category")
        voucher = create_voucher(merchant_user.token, category_id)
        published = publish_voucher(merchant_user.token, voucher["id"])
        assert published["status"] == "ACTIVE"

        denom = Decimal(str(voucher["denominations"][0]))
        order = create_order(consumer.token, voucher["id"], denom)
        payment = pay_order(consumer.token, order)
        assert payment["status"] == "COMPLETED"

        wallet_entry = wait_for_wallet_entry(consumer.token, voucher["id"])
        assert wallet_entry["status"] == "ACTIVE"

        redemption = redeem_voucher(
            merchant_user.token,
            wallet_entry["voucherCode"],
            Decimal(str(wallet_entry["denomination"])),
        )
        assert redemption["status"] in {"COMPLETED", "CONFIRMED", "PENDING"}
    finally:
        db.close()

