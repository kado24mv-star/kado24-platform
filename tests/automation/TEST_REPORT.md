# Kado24 Test Report

Date: 2025-11-16
Environment: Local Docker (Windows), APISIX gateway (http://localhost:9080)

## Summary
- Total tests: 40
- Passed: 40
- Failed: 0
- Skipped/XFailed: 0
- Execution time: ~28s
- Gateway path: All API calls routed via APISIX (9080)

## Coverage by Priority
- P0: Core end-to-end flows (merchant setup, purchase, payment, wallet issuance, redemption) — PASSED
- P1: Idempotency, multi-consumer/stock edge, payout hold exclusion — PASSED
- P2: Broader money split checks, admin ops, health checks — PASSED

## Key Scenarios Validated
- Merchant registration → admin approval → voucher publish
- Consumer purchase (ABA), payment completion, wallet issuance
- Redemption flow (status CONFIRMED supported)
- Duplicate payment idempotency
- Last-inventory concurrency rejection
- Payment failure and timeout handling
- Payout: suspended merchant excluded from issued payouts (hold fallback via internal endpoint when simulate restricted)

## Services Health
- Auth, User, Voucher, Order, Payment, Wallet, Redemption, Merchant, Notification, Payout, Analytics — UP
- APISIX (9080/9091) — Operational

## Notes
- Redemption domain uses statuses: PENDING/CONFIRMED; tests accept CONFIRMED.
- Payout simulate may require auth; test falls back to internal holds and asserts exclusion from payouts.

## How to Re-run (via APISIX)
- Ensure Docker stack is up (docker compose -f docker-compose.services.yml up -d)
- Run:
  - set AUTH_BASE_URL=http://localhost:9080
  - set MERCHANT_BASE_URL=http://localhost:9080
  - set VOUCHER_BASE_URL=http://localhost:9080
  - set ORDER_BASE_URL=http://localhost:9080
  - set PAYMENT_BASE_URL=http://localhost:9080
  - set WALLET_BASE_URL=http://localhost:9080
  - set REDEMPTION_BASE_URL=http://localhost:9080
  - set PAYOUT_BASE_URL=http://localhost:9080
  - py -m pytest -v --tb=short


