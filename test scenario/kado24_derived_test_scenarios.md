# Kado24 Cambodia – Automation-Oriented Test Scenarios

**Version:** 1.0  
**Date:** November 15, 2025  
**Source:** `test scenario/kado24_test_scenarios.md` (v1.0)  
**Purpose:** Provide a clean, automation-ready catalogue of the test scenarios described in the source document, including priority, suggested execution type, and notes for data or tooling.

---

## 1. Scope & Method
- Consolidates the nine process areas defined in the source test-scenarios document.
- Adds meta-data columns (`Priority`, `Execution`, `Automation Notes`) to help QA plan manual vs. automated coverage.
- Scenarios inherit IDs from the source document; new IDs follow the pattern `<Section>-A##` for automation-oriented references.
- Execution types: `Manual`, `Automated`, `Hybrid` (manual setup + automated validation).
- Priorities use the P0–P3 scale defined in the source document; defaults applied where not explicitly stated.

---

## 2. Scenario Inventory Summary

| Section | Total Scenarios | Automation Candidates | Notes |
|---|---|---|---|
| Merchant Onboarding & Registration | 11 | 7 | API/UI coverage for forms, approvals, SLAs. |
| Voucher Creation Process | 12 | 9 | Strong candidates for UI + API regression suites. |
| Consumer Purchase Flow | 13 | 10 | Mix of payment gateway mocks and mobile UI flows. |
| Money Flow & Revenue Split | 9 | 7 | Service-level validations; needs ledger fixtures. |
| Voucher Redemption Flow | 12 | 8 | Requires wallet + merchant app coordination. |
| Admin Platform Management | 12 | 8 | Web-admin UI + role-based access checks. |
| Financial Operations – Weekly Payouts | 12 | 9 | Batch jobs + banking integration mocks. |
| Data & Integration Flow | 12 | 10 | Contract tests, load, and resilience scenarios. |
| Cross-Process Integration Tests | 9 | 7 | Full-stack E2E journeys and chaos tests. |

---

## 3. Detailed Scenarios

### 3.1 Merchant Onboarding & Registration

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| MR-P01 | MO-A01 | Successful merchant registration with valid data | P0 | Hybrid | Automate API validation + UI smoke with faker docs. |
| MR-P02 | MO-A02 | Admin approves merchant application | P0 | Automated | Use admin API to approve and verify status/email events via mocks. |
| MR-P03 | MO-A03 | Merchant completes profile setup | P1 | Automated | Selenium/Appium wizard flow; assert bank info persisted. |
| MR-N01 | MO-N01 | Registration with duplicate email | P0 | Automated | Negative API test asserting 409 + localized error. |
| MR-N02 | MO-N02 | Invalid business license format | P1 | Automated | Form validation rules; data-driven license inputs. |
| MR-N03 | MO-N03 | Admin rejects merchant application | P1 | Manual | Requires reasoning on rejection reasons + email content. |
| MR-N04 | MO-N04 | Incomplete document upload | P0 | Automated | File upload component test with missing mandatory docs. |
| MR-E01 | MO-E01 | Application timeout during document upload | P2 | Manual | Needs network throttling lab setup; monitor retry logic. |
| MR-E02 | MO-E02 | Duplicate application submission | P1 | Automated | Idempotency check via repeated POST requests. |
| MR-E03 | MO-E03 | Admin review exactly at 48-hour SLA | P2 | Manual | Time-travel in test env; verify SLA status metrics. |
| MR-E04 | MO-E04 | Unicode characters in business name | P1 | Automated | UTF-8 test data; verify DB + UI rendering. |

### 3.2 Voucher Creation Process

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| VC-P01 | VC-A01 | Create standard voucher with fixed amounts | P0 | Automated | API + UI flow; assert QR generation + marketplace listing. |
| VC-P02 | VC-A02 | Voucher with custom terms and restrictions | P1 | Automated | Validate custom T&C propagation to consumer UI. |
| VC-P03 | VC-A03 | Upload high-quality voucher image | P2 | Manual | Visual QA + responsive previews. |
| VC-N01 | VC-N01 | Invalid denomination ($0) | P0 | Automated | Form validation; ensure server rejects payload. |
| VC-N02 | VC-N02 | Prohibited image content | P1 | Manual | Requires human-in-loop moderation or ML stub. |
| VC-N03 | VC-N03 | Expiry date in the past | P0 | Automated | Date-picker guard + backend validation. |
| VC-N04 | VC-N04 | Exceed voucher quantity limit | P1 | Automated | Boundary test for 10k cap; verify warning copy. |
| VC-E01 | VC-E01 | Create voucher at midnight (timezone) | P2 | Manual | Needs time-freeze; verify ICT handling. |
| VC-E02 | VC-E02 | Identical vouchers across merchants | P3 | Manual | Business acceptance check; ensure listing differentiation. |
| VC-E03 | VC-E03 | Voucher expires in cart | P1 | Automated | Simulate expiry then checkout; ensure cart validation. |
| VC-E04 | VC-E04 | Bulk upload 100 vouchers via CSV | P1 | Hybrid | CLI/CSV automation + manual review of error report. |

### 3.3 Consumer Purchase Flow

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| CP-P01 | CP-A01 | Purchase with ABA Pay | P0 | Automated | Mock ABA gateway, assert wallet + notifications. |
| CP-P02 | CP-A02 | Purchase with Wing Money | P1 | Automated | Parameterized payment provider tests. |
| CP-P03 | CP-A03 | Purchase with Pi Pay | P1 | Automated | Validate alternate gateway flows in same suite. |
| CP-P04 | CP-A04 | Multiple vouchers in one transaction | P0 | Automated | Ensure atomic cart operations + per-voucher QR. |
| CP-P05 | CP-A05 | Gift voucher to another user | P1 | Hybrid | Automated API for transfer + manual email rendering check. |
| CP-P06 | CP-A06 | Gifted voucher redemption end-to-end | P0 | Hybrid | Automate purchase → gift transfer → redemption → payout ledger; quick UI glance optional. |
| CP-N01 | CP-N01 | Payment failure – insufficient funds | P0 | Automated | Gateway mock returning 402; assert order failed state. |
| CP-N02 | CP-N02 | Payment timeout | P0 | Automated | Simulate delayed callback; ensure order cancelled + funds safe. |
| CP-N03 | CP-N03 | Double-spend attempt | P0 | Automated | Idempotency key stress test (rapid POST). |
| CP-N04 | CP-N04 | Purchase expired voucher | P1 | Automated | Inventory validation before checkout. |
| CP-N05 | CP-N05 | Invalid payment callback | P1 | Automated | Signature validation test with malformed payload. |
| CP-E01 | CP-E01 | Network interruption during payment | P1 | Manual | Mobile network throttle; observe retry + status sync. |
| CP-E02 | CP-E02 | Purchase at maximum platform limit | P2 | Automated | Bulk add 50 vouchers; check limit + notifications. |
| CP-E03 | CP-E03 | Concurrent purchase of last voucher | P0 | Automated | Race-condition test using parallel threads. |
| CP-E04 | CP-E04 | Payment in different currency | P2 | Hybrid | FX conversion assertions + manual receipt review. |

### 3.4 Money Flow & Revenue Split

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| MF-P01 | MF-A01 | Standard $100 revenue split | P0 | Automated | Service-level test verifying ledger entries (2%+8%). |
| MF-P02 | MF-A02 | Aggregate multiple transactions | P1 | Automated | Batch calculation test; compare to expected totals. |
| MF-P03 | MF-A03 | Mixed denomination commission | P1 | Automated | Data-driven amounts; assert percentage accuracy. |
| MF-N01 | MF-N01 | Gateway fee exceeds range | P0 | Automated | Alert triggers when fee > threshold. |
| MF-N02 | MF-N02 | Rounding error accumulation | P1 | Automated | Massive micro-transaction simulation; ensure ≤$0.01 delta. |
| MF-N03 | MF-N03 | Negative balance scenario | P0 | Automated | Refund validation preventing > original amount. |
| MF-E01 | MF-E01 | $0.01 voucher split | P2 | Manual | Verify rounding rules + ledger adjustments. |
| MF-E02 | MF-E02 | High-value $10k voucher | P1 | Hybrid | Automated calc + manual fraud/hold verification. |
| MF-E03 | MF-E03 | Partial refund scenario | P1 | Automated | Adjust commission + ledger entries after partial refund. |

### 3.5 Voucher Redemption Flow

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| VR-P01 | VR-A01 | QR code redemption | P0 | Automated | API contract between wallet + merchant scanner. |
| VR-P02 | VR-A02 | PIN-based redemption | P1 | Automated | PIN verification endpoint; manual backup for UX. |
| VR-P03 | VR-A03 | Partial redemption | P1 | Automated | Balance tracking + regenerated QR. |
| VR-P04 | VR-A04 | Multi-location redemption | P2 | Manual | GPS/location validation per branch. |
| VR-N01 | VR-N01 | Redeem already used voucher | P0 | Automated | Ensure status check blocks reuse; audit log. |
| VR-N02 | VR-N02 | Redeem expired voucher | P0 | Automated | Expiry validation with localized messaging. |
| VR-N03 | VR-N03 | Wrong merchant scanning | P0 | Automated | Merchant binding enforcement + fraud alert. |
| VR-N04 | VR-N04 | Offline redemption with stale data | P1 | Manual | Offline mode scenario; sync once online. |
| VR-E01 | VR-E01 | Simultaneous redemption attempt | P0 | Automated | Concurrency lock test. |
| VR-E02 | VR-E02 | Redemption during maintenance | P2 | Manual | Maintenance flag, queueing behavior. |
| VR-E03 | VR-E03 | Damaged QR code | P2 | Manual | Manual PIN fallback + support workflow. |
| VR-E04 | VR-E04 | Timezone confusion on expiry | P2 | Automated | Validate ICT timezone messaging and grace period. |

### 3.6 Admin Platform Management

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| AM-P01 | AM-A01 | Review pending merchant application | P0 | Automated | Admin UI regression; verify document checklist. |
| AM-P02 | AM-A02 | Suspend merchant | P0 | Automated | API toggle + ensure voucher creation blocked. |
| AM-P03 | AM-A03 | Reactivate merchant | P1 | Automated | Verify state transitions + notifications. |
| AM-P04 | AM-A04 | Real-time transaction dashboard | P1 | Manual | Visual validation of live metrics. |
| AM-P05 | AM-A05 | Detect fraudulent pattern | P0 | Manual | Requires investigative workflow; automated alert unit tests. |
| AM-P06 | AM-A06 | Generate financial report | P1 | Automated | Report export validation comparing totals. |
| AM-N01 | AM-N01 | Approve without documents | P0 | Automated | UI/API guard rails; expect validation errors. |
| AM-N02 | AM-N02 | Access denied for non-admin | P0 | Automated | RBAC tests; expect 403. |
| AM-N03 | AM-N03 | Concurrent admin actions | P1 | Automated | Optimistic locking test via parallel approvals. |
| AM-E01 | AM-E01 | Review at 48-hour deadline | P2 | Manual | SLA countdown UI + alerting. |
| AM-E02 | AM-E02 | Bulk approval of 100 merchants | P1 | Hybrid | Batch process automation + email queue verification. |
| AM-E03 | AM-E03 | Admin session timeout | P2 | Manual | Session persistence + drafts autosave. |

### 3.7 Financial Operations – Weekly Payouts

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| FO-P01 | FO-A01 | Standard weekly payout calculation | P0 | Automated | Batch job verification + report diffing. |
| FO-P02 | FO-A02 | Single merchant payout | P1 | Automated | Validate 92% payout and email confirmation. |
| FO-P03 | FO-A03 | Batch payout for 100 merchants | P1 | Hybrid | Automated file generation + manual bank portal upload. |
| FO-P04 | FO-A04 | Payout with bank account validation | P1 | Automated | Test $0.01 micro-deposit workflow. |
| FO-N01 | FO-N01 | Bank transfer failure | P0 | Automated | Simulate bank rejection; ensure alerts + retries. |
| FO-N02 | FO-N02 | Insufficient platform balance | P0 | Automated | Guard rails preventing payout run; alert. |
| FO-N03 | FO-N03 | Merchant suspended before payout | P1 | Automated | Exclude suspended merchants + flag for review. |
| FO-N04 | FO-N04 | Payout amount mismatch | P0 | Automated | Reconciliation script comparing expected vs actual. |
| FO-E01 | FO-E01 | Payout on bank holiday | P1 | Automated | Calendar-aware scheduling tests. |
| FO-E02 | FO-E02 | Zero earnings merchant | P2 | Automated | Ensure $0 payouts skipped quietly. |
| FO-E03 | FO-E03 | Micro-payout below threshold | P2 | Automated | Verify rollover accumulation. |
| FO-E04 | FO-E04 | Refund after payout calculation | P1 | Automated | Adjustment applied next cycle with audit trail. |

### 3.8 Data & Integration Flow

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| DI-P01 | DI-A01 | Consumer app sync after offline mode | P1 | Automated | Mobile integration test with offline cache fixtures. |
| DI-P02 | DI-A02 | Payment gateway callback | P0 | Automated | Contract test validating signature + event publication. |
| DI-P03 | DI-A03 | Real-time notification delivery | P1 | Automated | Event-driven test verifying push/SMS/email via mocks. |
| DI-P04 | DI-A04 | Database replication sync | P1 | Automated | Write-read consistency check between primary & replica. |
| DI-N01 | DI-N01 | API rate limit exceeded | P1 | Automated | Load test hitting throttle; verify 429 + headers. |
| DI-N02 | DI-N02 | Invalid webhook signature | P0 | Automated | Security regression suite. |
| DI-N03 | DI-N03 | DB connection pool exhausted | P1 | Hybrid | Load harness + service telemetry validation. |
| DI-N04 | DI-N04 | External service timeout | P1 | Automated | Inject latency; expect pending status + retry scheduling. |
| DI-E01 | DI-E01 | Kafka partition rebalancing | P2 | Automated | Consumer group integration test with rebalance simulation. |
| DI-E02 | DI-E02 | Redis cache invalidation | P2 | Automated | Cache miss fallback tests. |
| DI-E03 | DI-E03 | CDN cache serving stale images | P3 | Manual | Validate purge workflow + TTL behavior. |
| DI-E04 | DI-E04 | Cross-region API latency | P2 | Hybrid | Synthetic monitoring + compression verification. |

### 3.9 Cross-Process Integration Tests

| Source ID | Derived ID | Scenario | Priority | Execution | Automation Notes |
|---|---|---|---|---|---|
| E2E-01 | E2E-A01 | Complete consumer journey | P0 | Hybrid | Automated mobile/UI flow with manual UX validation. |
| E2E-02 | E2E-A02 | Complete merchant journey | P0 | Hybrid | Multi-role script spanning onboarding → payout. |
| E2E-03 | E2E-A03 | Gift voucher journey | P1 | Hybrid | Combine purchase, transfer, redemption flows. |
| FR-01 | E2E-F01 | Payment success, notification failure | P0 | Automated | Chaos experiment disabling email service. |
| FR-02 | E2E-F02 | DB failure during redemption | P0 | Automated | Fault injection to DB; ensure no voucher marked used. |
| FR-03 | E2E-F03 | Kafka broker down during purchase | P1 | Automated | Delay/stop Kafka to test buffering + replay. |
| PERF-01 | PERF-A01 | Black Friday purchase load | P0 | Automated | k6/JMeter script for 10k concurrent purchases. |
| PERF-02 | PERF-A02 | Mass redemption event | P1 | Automated | Simulate 5k redemptions/hour; watch latency/locks. |
| PERF-03 | PERF-A03 | Admin dashboard load | P2 | Automated | 50 concurrent admin sessions; watch DB utilization. |

---

## 4. Next Steps
- Prioritize automation of all `P0` scenarios before release.
- Align QA tooling (Selenium/Appium, Postman/Newman, k6) per execution notes.
- Link each derived ID to actual test cases in the test-management system (e.g., Jira XRay/TestRail).
- Schedule periodic reviews to keep this mapping in sync with product changes (monthly per document control policy).

---

**Document Control**  
Author: QA Engineering  
Reviewers: QA Lead, Automation Lead, Product Manager  
Next Review: Monthly  
Changelog: v1.0 – Initial automation-oriented mapping.







