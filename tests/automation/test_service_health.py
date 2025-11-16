"""
Smoke tests that validate critical platform services are reachable and healthy.

These tests exercise the health endpoints exposed by APISIX and each Spring Boot
microservice, ensuring the dockerized stack (connected to the host Postgres)
is ready for higher-level business flow automation.
"""

from __future__ import annotations

import os
from typing import Dict, Iterable, Optional, Tuple

import pytest
import requests
from tenacity import retry, stop_after_attempt, wait_fixed


def _build_service_matrix() -> Iterable[Tuple[str, str, Optional[Dict[str, str]]]]:
    gateway_admin_url = os.getenv(
        "APISIX_ADMIN_URL", "http://localhost:9091/apisix/admin/routes"
    )
    gateway_admin_key = os.getenv(
        "APISIX_ADMIN_KEY", "edd1c9f034335f136f87ad84b625c8f1"
    )

    # Base list derived from docker-compose.services.yml exposed ports
    services = [
        (
            "gateway-admin",
            gateway_admin_url,
            {"X-API-KEY": gateway_admin_key},
        ),
        ("auth-service", "http://localhost:8081/actuator/health", None),
        ("user-service", "http://localhost:8082/actuator/health", None),
        ("voucher-service", "http://localhost:8083/actuator/health", None),
        ("order-service", "http://localhost:8084/actuator/health", None),
        ("payment-service", "http://localhost:8085/actuator/health", None),
        ("wallet-service", "http://localhost:8086/actuator/health", None),
        ("redemption-service", "http://localhost:8087/actuator/health", None),
        ("merchant-service", "http://localhost:8088/actuator/health", None),
        ("admin-portal-backend", "http://localhost:8089/actuator/health", None),
        ("notification-service", "http://localhost:8091/actuator/health", None),
        ("payout-service", "http://localhost:8092/actuator/health", None),
        ("analytics-service", "http://localhost:8093/actuator/health", None),
    ]

    return services


@retry(stop=stop_after_attempt(5), wait=wait_fixed(5))
def _get_with_retry(url: str, headers: Optional[Dict[str, str]]) -> requests.Response:
    resp = requests.get(url, timeout=10, headers=headers)
    resp.raise_for_status()
    return resp


def _assert_health_payload(response: requests.Response) -> None:
    try:
        payload = response.json()
    except ValueError:
        body = response.text.strip().lower()
        assert "ok" in body or "up" in body, f"Unexpected body: {response.text}"
        return

    status = payload.get("status")
    if status is None:
        # Some endpoints (e.g., APISIX admin listing) just need to be reachable.
        return

    assert str(status).upper() == "UP", f"Health status not UP: {payload}"


@pytest.mark.parametrize(
    "service_name,url,headers",
    _build_service_matrix(),
)
def test_service_health(
    service_name: str, url: str, headers: Optional[Dict[str, str]]
) -> None:
    """
    Each service should respond with HTTP 200 and report an UP status.
    """
    response = _get_with_retry(url, headers)
    _assert_health_payload(response)

