import uuid
import random

import requests

BASE_AUTH = "http://localhost:8081"
BASE_WALLET = "http://localhost:8086"


def register_consumer():
    payload = {
        "fullName": f"Automation QA {uuid.uuid4().hex[:4]}",
        "phoneNumber": "+8551" + str(random.randint(10_000_000, 99_999_999)),
        "email": f"qa-{uuid.uuid4().hex[:6]}@autotest.local",
        "password": "StrongP@ss123",
        "role": "CONSUMER",
    }
    response = requests.post(f"{BASE_AUTH}/api/v1/auth/register", json=payload, timeout=10)
    print("register", response.status_code, response.text[:120])
    response.raise_for_status()
    return response.json()["data"]


def fetch_wallet(token: str):
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_WALLET}/api/v1/wallet", headers=headers, timeout=10)
    print("wallet", response.status_code, response.text[:160])
    response.raise_for_status()


if __name__ == "__main__":
    consumer = register_consumer()
    fetch_wallet(consumer["accessToken"])







