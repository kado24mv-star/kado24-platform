# Kado24 Business Flow Test Plan
**Version:** 0.1  
**Date:** November 15, 2025  
**Sources:** `prompt/kado24_business_flow_diagrams.html`, `prompt/kado24_wireframes.html`  
**Purpose:** Define how each business process and associated UI flow will be validated (manual + automated) before deriving detailed scenarios and scripts.

---

## 1. Objectives
- Validate every end-to-end business flow depicted in the diagrams (consumer, merchant, admin, finance, support).
- Ensure each screen in the wireframes has functional, UX, and data integrity coverage.
- Prioritize automation coverage for repetitive, high-risk or cross-channel flows while retaining targeted manual exploration.

---

## 2. Scope & Coverage Matrix

| Business Process | Description (from diagrams) | Channels | Coverage Focus | Automation Type |
|---|---|---|---|---|
| Merchant Onboarding & Lifecycle | Merchant applies → Admin approves → Merchant operates → Suspension/reactivation | Merchant app, Admin web | Document upload validity, SLA timers, approval routing, status transitions | API + Web UI (Playwright/Selenium) |
| Voucher Creation & Publishing | Merchant creates vouchers with pricing, terms, media assets | Merchant app | Form validations, media processing, preview accuracy, publish workflow | API + Web UI |
| Consumer Discovery & Purchase | Browse → search/filter → detail view → payment → wallet entry | Consumer app | Catalog accuracy, personalization, purchase rules, multi-payment integration | Mobile UI (Appium) + API (REST Assured) |
| Gift & Wallet Management | Gift sending/receiving, wallet status tabs, QR availability | Consumer app | Ownership transfer, notifications, wallet state transitions | API + Mobile UI |
| Redemption (Dual QR) | Show QR vs scan merchant QR + offline fallback | Consumer + Merchant apps | Token validation, conflict resolution, offline sync | API + Mobile UI |
| Money Flow & Payouts | Payment split 8%/92%, weekly payouts, bank validations | Backend services + Admin web | Ledger accuracy, payout batching, failure handling | API + Batch verification scripts |
| Support & Disputes | Help center, live chat, ticketing, dispute workflow | Consumer app, Admin web | SLA tracking, notifications, status transitions, attachments | API + Web UI |
| Fraud & Monitoring | Real-time dashboards, alerts, investigation actions | Admin web, analytics svc | Alert thresholds, case workflow, remediation actions | API + Web UI |
| Data & Integrations | Payment callbacks, notifications (SMS/email/push), Kafka, Redis, offline sync | Backend services | Contract compliance, retry policies, cache invalidation | Contract tests + component tests |

**Out of scope (this cycle):** Localization translation accuracy, third-party payment certification, penetration testing (handled separately).

---

## 3. Test Approach
1. **Requirement to Test Traceability**
   - Tag each test case with `FLOW-ID` (diagram) and `SCREEN-ID` (wireframe section).
   - Maintain trace matrix in `test scenario/kado24_derived_test_scenarios.md`.

2. **Automation Pyramid Alignment**
   - Unit/service tests remain in repos (minimum 80% coverage baseline).
   - API regression packs executed via CI on every merge.
   - UI smoke suites (Consumer Flutter web build, Merchant Flutter, Admin Angular) nightly + pre-release.

3. **Data Strategy**
   - Seed baseline merchants/consumers via SQL scripts (`scripts/init-database*.sql`).
   - Create synthetic payment and redemption events through mock-payment-service & Kafka fixtures.
   - Mask PII snapshots before copying to lower environments.

4. **Environments**
   - **DEV:** docker-compose stack against host PostgreSQL; used for rapid API/UI automation debugging.
   - **QA/STAGING:** mirrors production scale (Kafka, Redis, APISIX); source of truth for release sign-off.
   - **PERF:** scaled services + synthetic load via k6/JMeter for PERF-01/02/03 (see scenarios doc).

5. **Entry / Exit Criteria**
   - **Entry:** Requirements baselined, environments healthy, seed data loaded, blocking defects from previous cycle resolved.
   - **Exit:** All P0/P1 scenarios pass, automation suite green twice consecutively, no open Sev1/Sev2 defects, business sign-off on dashboards/payout reports.

---

## 4. Test Deliverables
- Updated traceability matrix.
- Automation suite results (API, UI, performance).
- Defect reports & RCA logs for any SLA breaches (merchant approval, payout processing).
- Evidence bundles (screenshots, HAR files, database diffs) stored with test runs.

---

## 5. Roles & Responsibilities

| Role | Responsibilities |
|---|---|
| QA Lead | Owns plan execution, prioritization, exit criteria. |
| Automation Engineer | Builds/maintains API & UI suites, integrates with CI, ensures data-driven tests. |
| Manual QA | Executes exploratory/sanity passes on new wireframe screens, validates UX. |
| Dev Representatives | Provide fixtures, debug environment issues, own unit/contract coverage. |
| Product Ops | Validates financial/payout data, reviews support/fraud workflows. |

---

## 6. Tooling & Frameworks
- **API:** REST Assured + TestNG (Java stack alignment).
- **Mobile UI:** Appium + Flutter driver for consumer/merchant apps (web builds for CI).
- **Web UI:** Playwright for Admin portal.
- **Contract:** Pact for payment callbacks + Kafka schema registry checks.
- **Load:** k6 for purchase/redemption spikes; JMeter for payout batch performance.
- **Reporting:** Allure reports + Grafana dashboards for long-running suites.

---

## 7. Risk & Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Native PostgreSQL dependency on host | Automation blocked if host DB down | Health checks before suites, fallback to containerized Postgres profile. |
| Payment gateway sandbox instability | Flaky purchase tests | Use mock-payment-service for majority tests; limit live gateway calls to daily sanity. |
| APISIX route misconfiguration | Gateway routing failures | Pre-test script re-applies `gateway/apisix/setup-routes.sh` and validates route health. |
| Kafka / Redis state pollution | Non-deterministic results | Reset topics/flush Redis between suites using helper scripts. |

---

## 8. Schedule & Milestones

| Phase | Timeline | Deliverable |
|---|---|---|
| Test Plan Approval | Day 0 | Sign-off on this document. |
| Automation Prep | Day 1-2 | Data seeding scripts, environment validation. |
| Core Flow Automation | Day 3-6 | Consumer purchase, redemption, merchant onboarding suites. |
| Admin/Fraud/Finance Suites | Day 7-9 | Admin portal UI + payout validations. |
| Performance & Failover | Day 10-11 | Load + chaos scenarios. |
| Regression & Exit | Day 12 | Full suite run, metrics report, go/no-go. |

---

## 9. Traceability Kickoff
- Assign `FLOW IDs` per section of the business flow diagrams (e.g., `FLOW-1` Merchant Setup, `FLOW-2` Consumer Purchase, etc.).
- Map each wireframe subsection (Consumer, Merchant, Admin) to `SCREEN IDs`.
- Update `test scenario/kado24_derived_test_scenarios.md` with these identifiers before scripting automation.

---

## 10. Approval
- **QA Lead:** _Pending_
- **Product Owner:** _Pending_
- **Engineering Manager:** _Pending_

Once this plan is approved, proceed to detail automation scenarios per process (next deliverable).

---







