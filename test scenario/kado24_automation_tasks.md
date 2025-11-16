# Kado24 Automation Tasks Plan

**Version:** 0.1  
**Date:** November 15, 2025  
**Source:** `kado24_derived_test_scenarios.md`  
**Purpose:** Translate high-priority scenarios into concrete automation tasks with ownership, tooling, and deliverables.

---

## 1. Guiding Principles
- Prioritize `P0` scenarios; treat `P1` with high urgency once critical paths are automated.
- Leverage existing tooling: Postman/Newman for API, Selenium/Appium for UI, k6 for load, and chaos scripts for failure tests.
- Keep tasks small (<3 days each) to allow incremental delivery.
- Tag every automated case with the derived scenario ID (e.g., `MO-A01`) inside the test repository.

---

## 2. Task Backlog

### 2.1 Merchant Onboarding (`MO-*`)
1. **MO-A01 Registration Happy Path**
   - *Owner:* QA Automation  
   - *Tooling:* Selenium + REST-assured  
   - *Deliverable:* UI script covering registration + API assertion for status `Pending`.  
   - *Dependencies:* Fake document generator service.
2. **MO-A02 Admin Approval Flow**
   - Automate admin API approval including verification of notification event (mocked email).
3. **MO-N01 Duplicate Email Validation**
   - Data-driven API suite verifying 409 response and localized error messages.
4. **MO-N04 Missing Documents**
   - UI upload negative test ensuring inline validation and disabled submit button.
5. **MO-E02 Duplicate Submission Idempotency**
   - Parallel POST requests using JMeter/REST-assured to confirm single record creation.

### 2.2 Voucher Creation (`VC-*`)
1. **VC-A01 Standard Voucher Creation**
   - *Owner:* QA Automation  
   - *Tooling:* Selenium + API hooks  
   - *Deliverable:* Script verifying voucher listing + QR generation event.
2. **VC-N01 Invalid Denomination**
   - Extend API validation suite to cover amount boundary checks.
3. **VC-N03 Past Expiry Date Guard**
   - UI test focused on date picker constraints + backend validation response.
4. **VC-E03 Cart Expiry Validation**
   - Simulate voucher expiry via API, then attempt checkout in UI; assert error message.
5. **VC-E04 CSV Bulk Upload**
   - CLI harness to upload sample CSV, parse error report, and compare expected failures.

### 2.3 Consumer Purchase Flow (`CP-*`)
1. **CP-A01 ABA Pay Happy Path**
   - *Owner:* Mobile QA Automation  
   - *Tooling:* Appium + mocked ABA gateway  
   - *Deliverable:* End-to-end purchase verifying wallet entry + notifications queue.
2. **CP-N02 Payment Timeout Handling**
   - Inject delay in mock gateway; ensure order cancels and funds remain untouched.
3. **CP-N03 Double-Spend Idempotency**
   - Multi-threaded request test verifying single successful transaction.
4. **CP-E03 Last Voucher Race Condition**
   - Use parallel test harness to simulate two purchases for final inventory unit.
5. **CP-E04 Multi-Currency Payment**
   - Validate FX conversion logic and persisted USD amount via API assertions.

### 2.4 Money Flow & Revenue Split (`MF-*`)
1. **MF-A01 Standard Split Ledger Test**
   - *Tooling:* Postman test suite with database verification script.
2. **MF-N01 Gateway Fee Alert**
   - Simulate overcharged fee and assert alert payload in notification topic.
3. **MF-N02 Rounding Error Suite**
   - Batch script generating 1k micro transactions; compare totals to expected tolerance.
4. **MF-E03 Partial Refund Adjustments**
   - Validate ledger entries and commission recalculations after partial refund API call.

### 2.5 Voucher Redemption (`VR-*`)
1. **VR-A01 QR Redemption Flow**
   - Integrate wallet + merchant API tests; assert status transition to `Used`.
2. **VR-A03 Partial Redemption**
   - Verify remaining balance and regenerated QR code asset.
3. **VR-N01 Reuse Prevention**
   - Negative test ensuring reused QR returns specific error and logs attempt.
4. **VR-E01 Simultaneous Redemption Lock**
   - Parallel redemption attempts to verify locking and audit entries.

### 2.6 Admin Platform (`AM-*`)
1. **AM-A02 Suspend Merchant**
   - Automate admin UI toggle + API verification that creation endpoints return 403.
2. **AM-N02 Non-Admin Access Denial**
   - RBAC automated tests covering multiple roles.
3. **AM-N03 Concurrent Admin Actions**
   - Parallel approval attempts to ensure second action receives “Already processed.”

### 2.7 Financial Operations (`FO-*`)
1. **FO-A01 Weekly Batch Calculation**
   - *Tooling:* Jenkins job + Postman collection running against staging data snapshot.
2. **FO-N01 Bank Transfer Failure Handling**
   - Mock bank API rejects transfer; ensure system retries and flags payout.
3. **FO-E01 Bank Holiday Schedule**
   - Automated calendar-aware test verifying payout date adjustment logic.

### 2.8 Data & Integration (`DI-*`)
1. **DI-A02 Payment Webhook Contract**
   - Pact tests validating signature, schema, and downstream events.
2. **DI-N01 API Rate Limiting**
   - k6 script hitting 1000 requests/min; assert 429 + headers.
3. **DI-N04 External Service Timeout**
   - Chaos script delaying gateway response; ensure system marks `Pending`.

### 2.9 Cross-Process & Performance (`E2E-*/PERF-*)`
1. **E2E-A01 Consumer Journey Smoke**
   - Hybrid pipeline: Appium UI + backend verification for each milestone.
2. **E2E-F02 DB Failure During Redemption**
   - Chaos experiment toggling DB connectivity mid-request; confirm safe failure.
3. **PERF-A01 Black Friday Load**
   - k6 scenario reaching 10k concurrent purchases; capture latency metrics to Grafana.

---

## 3. Execution Roadmap
1. **Sprint 1 (Weeks 1–2)**
   - Complete `P0` tasks from Merchant Onboarding, Voucher Creation, and Consumer Purchase (top three sections).
   - Establish shared fixtures (merchant/user creation APIs, payment mocks).
2. **Sprint 2 (Weeks 3–4)**
   - Automate core Money Flow, Redemption, and Admin scenarios.
   - Integrate ledger verification scripts into nightly regression.
3. **Sprint 3 (Weeks 5–6)**
   - Cover Financial Ops, Data & Integration, and initial E2E journeys.
   - Stand up chaos + load test harnesses; baseline metrics.
4. **Continuous**
   - Add remaining P1 scenarios.
   - Hook automation suites into CI pipeline (PR checks + nightly runs).

---

## 4. Dependencies & Tooling Checklist
- Mock services: payment gateways, email/SMS providers, banking API.
- Test data seeding scripts for merchants, vouchers, consumers.
- CI integration (GitHub Actions or Jenkins) with environment selectors.
- Reporting: integrate with TestRail/XRay via derived scenario IDs.

---

## 5. Open Questions
1. Ownership split between web QA vs. mobile QA for hybrid flows?  
2. Availability of sandbox credentials for Wing and Pi Pay mocks?  
3. Preferred chaos tooling (Gremlin vs. custom scripts)?  
4. SLA for updating documentation after each automated case lands?

Please provide clarifications before Sprint 1 starts to avoid blockers.










