# Kado24 Cambodia - Business Flow Diagram Test Scenarios

**Version:** 1.0  
**Date:** November 16, 2025  
**Source:** `prompt/kado24_business_flow_diagrams.html`  
**Purpose:** Comprehensive test scenarios derived from business flow diagrams covering all visual workflows

---

## Table of Contents

1. [High-Level System Overview Tests](#1-high-level-system-overview-tests)
2. [Complete Business Flow Cycle Tests](#2-complete-business-flow-cycle-tests)
3. [Consumer Purchase Flow Tests](#3-consumer-purchase-flow-tests)
4. [Money Flow & Revenue Split Tests](#4-money-flow--revenue-split-tests)
5. [Voucher Redemption Flow Tests](#5-voucher-redemption-flow-tests)
6. [Admin Platform Management Flow Tests](#6-admin-platform-management-flow-tests)
7. [Data & Information Flow Tests](#7-data--information-flow-tests)

---

## 1. High-Level System Overview Tests

### 1.1 Three-Sided Marketplace Integration

| ID | Test Case | Description | Priority |
|---|---|---|---|
| **BF-OV-01** | Consumer can browse and buy vouchers | Verify consumer app can access marketplace and purchase vouchers | P0 |
| **BF-OV-02** | Merchant can create vouchers and accept redemptions | Verify merchant app can create vouchers and process redemptions | P0 |
| **BF-OV-03** | Platform processes payments with 8% commission | Verify platform correctly calculates and retains 8% commission | P0 |
| **BF-OV-04** | Admin can approve merchants and monitor transactions | Verify admin portal can manage merchants and view transactions | P0 |
| **BF-OV-05** | All three actors can interact simultaneously | Load test with concurrent consumer purchases, merchant operations, and admin actions | P1 |

---

## 2. Complete Business Flow Cycle Tests

### 2.1 End-to-End Business Flow

**Flow:** Merchant Setup → Consumer Purchase → Payment Split → Redemption → Payout

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-CYCLE-01** | Complete business cycle happy path | 1. Merchant registers and gets approved<br>2. Merchant creates and publishes voucher<br>3. Consumer browses, selects, and purchases voucher<br>4. Payment processed (8% platform, 92% merchant)<br>5. Consumer redeems voucher at merchant<br>6. Weekly payout to merchant | All steps complete successfully<br>Money flows correctly<br>Voucher status transitions correctly | P0 |
| **BF-CYCLE-02** | Business cycle with multiple consumers | Same as BF-CYCLE-01 but with 10 consumers purchasing same voucher | All purchases succeed<br>Stock decreases correctly<br>All redemptions work | P0 |
| **BF-CYCLE-03** | Business cycle with multiple merchants | 5 merchants create vouchers, 20 consumers purchase from different merchants | All transactions process correctly<br>Revenue split accurate per merchant | P1 |
| **BF-CYCLE-04** | Business cycle with payment failure | Steps 1-3 succeed, payment fails at step 4 | Order remains pending<br>No voucher issued<br>Consumer can retry payment | P0 |
| **BF-CYCLE-05** | Business cycle with redemption failure | Steps 1-4 succeed, redemption fails at step 5 | Voucher remains active<br>Consumer can retry redemption<br>Merchant can see failed attempt | P1 |

### 2.2 Merchant Setup Phase

| ID | Test Case | Description | Priority |
|---|---|---|---|
| **BF-MERCHANT-01** | Merchant registration flow | Register → Submit documents → Wait for approval | P0 |
| **BF-MERCHANT-02** | Admin approval within 24-48 hours | Admin reviews and approves within SLA | P0 |
| **BF-MERCHANT-03** | Merchant creates first voucher after approval | Verify merchant can create voucher immediately after approval | P0 |
| **BF-MERCHANT-04** | Merchant creates multiple vouchers | Create 5 different vouchers with different denominations | P1 |

---

## 3. Consumer Purchase Flow Tests

### 3.1 Consumer Actions Flow

**Flow:** Browse Vouchers → Select Voucher → Choose Amount → Complete Payment

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-PURCHASE-01** | Browse vouchers with search and filter | 1. Open consumer app<br>2. Browse available vouchers<br>3. Apply filters (category, price, location)<br>4. Search by merchant name | Vouchers displayed correctly<br>Filters work<br>Search returns relevant results | P0 |
| **BF-PURCHASE-02** | Select voucher and view details | 1. Click on a voucher<br>2. View full details (description, terms, merchant info)<br>3. Check available denominations | All details displayed correctly<br>Denominations shown accurately | P0 |
| **BF-PURCHASE-03** | Choose voucher amount | 1. Select voucher<br>2. Choose denomination ($5, $10, $25)<br>3. Verify price calculation | Correct amount selected<br>Total price calculated correctly | P0 |
| **BF-PURCHASE-04** | Complete payment with ABA Pay | 1. Select payment method: ABA Pay<br>2. Enter payment details<br>3. Confirm payment | Payment processed successfully<br>Order status: COMPLETED | P0 |
| **BF-PURCHASE-05** | Complete payment with Wing Money | Same as BF-PURCHASE-04 but with Wing Money | Payment processed successfully | P1 |
| **BF-PURCHASE-06** | Complete payment with Pi Pay | Same as BF-PURCHASE-04 but with Pi Pay | Payment processed successfully | P1 |
| **BF-PURCHASE-07** | Payment with insufficient funds | Attempt payment with insufficient balance | Payment rejected<br>Clear error message<br>Order remains PENDING | P0 |
| **BF-PURCHASE-08** | Payment timeout handling | Payment gateway timeout | Order status: CANCELLED<br>No funds deducted<br>Consumer can retry | P0 |

### 3.2 Platform Processing Flow

**Flow:** Verify Payment → Generate Voucher → Send Confirmation

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-PROCESS-01** | Payment gateway callback verification | 1. Payment gateway sends callback<br>2. Platform verifies signature<br>3. Platform validates payment amount | Payment verified successfully<br>Order updated to COMPLETED | P0 |
| **BF-PROCESS-02** | Voucher generation after payment | 1. Payment verified<br>2. System generates unique voucher code<br>3. QR code generated<br>4. Voucher added to consumer wallet | Voucher code unique<br>QR code valid<br>Wallet entry created | P0 |
| **BF-PROCESS-03** | Confirmation notifications sent | 1. Payment completed<br>2. System sends email confirmation<br>3. System sends push notification<br>4. System sends SMS (if enabled) | All notifications delivered<br>Consumer receives confirmation | P0 |
| **BF-PROCESS-04** | Invalid payment callback rejected | Payment gateway sends invalid signature | Payment rejected<br>Order remains PENDING<br>Security alert logged | P0 |
| **BF-PROCESS-05** | Duplicate payment callback handling | Payment gateway sends duplicate callback | Payment processed once<br>Idempotency maintained | P0 |

### 3.3 Voucher Activation

| ID | Test Case | Description | Priority |
|---|---|---|---|
| **BF-ACTIVATE-01** | Voucher appears in consumer wallet | After payment, voucher immediately available in wallet | P0 |
| **BF-ACTIVATE-02** | Voucher status is ACTIVE | New voucher has status ACTIVE | P0 |
| **BF-ACTIVATE-03** | Voucher can be viewed with QR code | Consumer can open voucher and see QR code | P0 |
| **BF-ACTIVATE-04** | Voucher has correct validity dates | Voucher valid_from and valid_until set correctly | P0 |

---

## 4. Money Flow & Revenue Split Tests

### 4.1 Payment Flow

**Flow:** Customer Pays $100 → Payment Gateway (Gateway Fee ~2%) → Platform Split (8% commission, 92% merchant)

| ID | Test Case | Scenario | Expected Result | Priority |
|---|---|---|---|---|
| **BF-MONEY-01** | $100 voucher purchase money flow | Customer pays $100<br>Gateway fee: ~$2<br>Platform: $8 (8%)<br>Merchant: $92 (92%) | All amounts calculated correctly<br>Ledger entries accurate | P0 |
| **BF-MONEY-02** | Multiple denomination money flow | Purchase $5, $10, $25 vouchers | Each split correctly<br>Platform: 8% each<br>Merchant: 92% each | P0 |
| **BF-MONEY-03** | Gateway fee calculation | Verify gateway fee deducted before split | Platform commission on net amount<br>Merchant receives correct amount | P0 |
| **BF-MONEY-04** | Revenue split accuracy | 100 transactions of $25 each | Platform: $200 (8% of $2500)<br>Merchant: $2300 (92% of $2500)<br>Total: $2500 | P0 |
| **BF-MONEY-05** | Rounding error handling | Purchase $1 voucher (edge case) | Platform: $0.08 (rounded correctly)<br>Merchant: $0.92 (rounded correctly)<br>Total: $1.00 | P1 |
| **BF-MONEY-06** | High-value voucher split | Purchase $1000 voucher | Platform: $80<br>Merchant: $920<br>Split accurate | P1 |
| **BF-MONEY-07** | Gateway fee exceeds threshold alert | Gateway fee > 3% | Alert sent to admin<br>Transaction logged for review | P1 |
| **BF-MONEY-08** | Negative balance prevention | Attempt refund > original amount | Refund rejected<br>Error message shown | P0 |

### 4.2 Weekly Payout Flow

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-PAYOUT-01** | Weekly payout calculation | Every Friday, calculate merchant earnings | All eligible merchants included<br>Amounts accurate | P0 |
| **BF-PAYOUT-02** | Single merchant payout | Merchant with $920 earnings | Bank transfer: $920<br>Email confirmation sent | P0 |
| **BF-PAYOUT-03** | Batch payout for 100 merchants | Weekly payout for 100 merchants | All transfers processed<br>All confirmations sent | P1 |
| **BF-PAYOUT-04** | Bank transfer failure handling | Bank rejects transfer | Retry scheduled<br>Merchant notified<br>Admin alerted | P0 |
| **BF-PAYOUT-05** | Suspended merchant excluded | Merchant suspended before payout | Excluded from payout<br>Held for review | P0 |
| **BF-PAYOUT-06** | Bank holiday payout adjustment | Payout scheduled on bank holiday | Payout delayed to next business day<br>Merchants notified | P1 |

---

## 5. Voucher Redemption Flow Tests

### 5.1 Consumer Side Redemption

**Flow:** Open Wallet → Show QR Code → Confirm Redemption

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-REDEEM-01** | Consumer opens wallet | 1. Open consumer app<br>2. Navigate to wallet<br>3. View available vouchers | All active vouchers displayed<br>Vouchers sorted correctly | P0 |
| **BF-REDEEM-02** | Consumer selects voucher to use | 1. Tap on voucher<br>2. View voucher details<br>3. Confirm merchant match | Voucher details shown<br>Merchant name displayed | P0 |
| **BF-REDEEM-03** | Consumer shows QR code | 1. Tap "Show QR Code"<br>2. QR code displayed on screen | QR code visible and scannable<br>Voucher code shown | P0 |
| **BF-REDEEM-04** | Consumer confirms redemption | 1. After merchant scans<br>2. Confirm amount and merchant<br>3. Tap "Confirm" | Redemption processed<br>Voucher marked as USED | P0 |
| **BF-REDEEM-05** | Consumer receives confirmation | After redemption | Digital receipt received<br>Voucher status updated in wallet | P0 |

### 5.2 Merchant Side Redemption

**Flow:** Open QR Scanner → Scan Customer QR → System Validates → Transaction Recorded

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-MERCH-REDEEM-01** | Merchant opens QR scanner | 1. Open merchant app<br>2. Navigate to scanner<br>3. Scanner ready | Scanner interface displayed<br>Camera activated | P0 |
| **BF-MERCH-REDEEM-02** | Merchant scans customer QR | 1. Point camera at QR code<br>2. QR code detected<br>3. Voucher details displayed | QR code scanned successfully<br>Voucher info shown | P0 |
| **BF-MERCH-REDEEM-03** | System validates voucher | System checks:<br>- Voucher exists<br>- Not used<br>- Not expired<br>- Correct merchant | All validations pass<br>Redemption allowed | P0 |
| **BF-MERCH-REDEEM-04** | Transaction recorded | After validation | Transaction logged<br>Added to weekly payout<br>Merchant sees confirmation | P0 |
| **BF-MERCH-REDEEM-05** | Validation fails - voucher used | Scan already-used voucher | Error: "Voucher already redeemed"<br>Redemption blocked | P0 |
| **BF-MERCH-REDEEM-06** | Validation fails - expired voucher | Scan expired voucher | Error: "Voucher expired"<br>Redemption blocked | P0 |
| **BF-MERCH-REDEEM-07** | Validation fails - wrong merchant | Scan voucher for different merchant | Error: "Voucher not valid for this merchant"<br>Redemption blocked | P0 |
| **BF-MERCH-REDEEM-08** | Partial redemption | Redeem $10 from $25 voucher | Remaining balance: $15<br>New QR code generated<br>Voucher still ACTIVE | P1 |

### 5.3 Real-Time Sync

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-SYNC-01** | Consumer device sync after redemption | Consumer app syncs after redemption | Voucher marked "Used"<br>Digital receipt appears | P0 |
| **BF-SYNC-02** | Merchant device sync after redemption | Merchant app syncs after redemption | Transaction logged<br>Revenue tracking updated | P0 |
| **BF-SYNC-03** | Platform sync after redemption | Platform updates records | Commission recorded<br>Payout queue updated | P0 |
| **BF-SYNC-04** | Offline redemption sync | Redeem while offline, sync when online | Redemption synced successfully<br>No data loss | P1 |

---

## 6. Admin Platform Management Flow Tests

### 6.1 Merchant Lifecycle Management

**Flow:** Merchant Applies → Admin Reviews (24-48 hours) → Approved

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-ADMIN-01** | Admin reviews merchant application | 1. Admin opens pending applications<br>2. Reviews documents<br>3. Checks business license<br>4. Verifies bank details | All information displayed<br>Documents viewable | P0 |
| **BF-ADMIN-02** | Admin approves merchant | 1. Review complete<br>2. Click "Approve"<br>3. Confirm approval | Merchant status: APPROVED<br>Merchant notified<br>Account activated | P0 |
| **BF-ADMIN-03** | Admin rejects merchant | 1. Review complete<br>2. Click "Reject"<br>3. Enter rejection reason<br>4. Confirm | Merchant status: REJECTED<br>Rejection email sent<br>Merchant can reapply | P0 |
| **BF-ADMIN-04** | Admin reviews within SLA | Application reviewed within 24-48 hours | SLA marked as "Met"<br>No escalation | P1 |
| **BF-ADMIN-05** | Admin reviews after SLA | Application reviewed after 48 hours | SLA marked as "Missed"<br>Escalation logged | P1 |
| **BF-ADMIN-06** | Bulk merchant approval | Approve 10 merchants at once | All approved successfully<br>All notifications sent | P1 |

### 6.2 Transaction Monitoring

**Flow:** Real-Time Dashboard → Fraud Detection → Investigate

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-MONITOR-01** | Real-time transaction dashboard | Admin views live transactions | All transactions displayed<br>Filters work<br>Real-time updates | P0 |
| **BF-MONITOR-02** | Fraud detection alerts | System detects suspicious pattern | Alert sent to admin<br>Transaction flagged<br>Details logged | P0 |
| **BF-MONITOR-03** | Admin investigates flagged transaction | Admin reviews flagged transaction | Transaction details shown<br>Can approve or reject<br>Can suspend merchant | P0 |
| **BF-MONITOR-04** | Transaction filtering and search | Filter by merchant, date, amount | Filters work correctly<br>Search returns results | P1 |
| **BF-MONITOR-05** | Export transaction report | Export transactions to CSV/Excel | Report generated correctly<br>All data included | P1 |

### 6.3 Financial Operations

**Flow:** Weekly Payout Prep → Review & Approve → Bank Transfer

| ID | Test Case | Steps | Expected Result | Priority |
|---|---|---|---|---|
| **BF-FIN-01** | Weekly payout preparation | Every Friday, system calculates payouts | All eligible merchants included<br>Amounts calculated correctly | P0 |
| **BF-FIN-02** | Admin reviews payout batch | 1. Admin opens payout batch<br>2. Reviews amounts<br>3. Checks merchant status | All payouts displayed<br>Amounts verified | P0 |
| **BF-FIN-03** | Admin approves payout | 1. Review complete<br>2. Click "Approve"<br>3. Confirm | Payout batch approved<br>Bank transfers initiated | P0 |
| **BF-FIN-04** | Bank transfer execution | Approved payouts sent to bank | All transfers processed<br>Confirmations received | P0 |
| **BF-FIN-05** | Failed transfer handling | Bank rejects a transfer | Transfer retried<br>Merchant notified<br>Admin alerted | P0 |
| **BF-FIN-06** | Financial report generation | Generate monthly financial report | Report includes:<br>- Total revenue<br>- Platform commission<br>- Merchant payouts<br>- Gateway fees | P1 |

---

## 7. Data & Information Flow Tests

### 7.1 Mobile App to Backend Communication

**Flow:** Mobile Apps → REST API → Backend API → Database

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-DATA-01** | Consumer app API communication | Consumer app calls backend APIs | All API calls succeed<br>Data synced correctly | P0 |
| **BF-DATA-02** | Merchant app API communication | Merchant app calls backend APIs | All API calls succeed<br>Data synced correctly | P0 |
| **BF-DATA-03** | API authentication | Apps authenticate with backend | JWT tokens valid<br>Requests authorized | P0 |
| **BF-DATA-04** | API rate limiting | Exceed rate limit | 429 status returned<br>Rate limit headers present | P1 |
| **BF-DATA-05** | Offline mode sync | App works offline, syncs when online | Data queued offline<br>Synced when online<br>No data loss | P1 |

### 7.2 External Service Integration

| ID | Test Case | Service | Expected Result | Priority |
|---|---|---|---|---|
| **BF-EXT-01** | Payment gateway integration | ABA/Wing/Pi Pay | Payments processed correctly<br>Callbacks received | P0 |
| **BF-EXT-02** | Email service integration | SendGrid | Emails delivered<br>Bounce handling works | P0 |
| **BF-EXT-03** | SMS gateway integration | Local provider | SMS delivered<br>Delivery status tracked | P1 |
| **BF-EXT-04** | Push notification service | Firebase FCM | Push notifications delivered<br>Device tokens valid | P0 |
| **BF-EXT-05** | External service timeout | Any external service | Timeout handled gracefully<br>Retry scheduled | P1 |
| **BF-EXT-06** | External service failure | Any external service | Fallback mechanism works<br>Error logged<br>Admin notified | P1 |

### 7.3 Database Operations

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-DB-01** | Database write consistency | Write operations to database | All writes succeed<br>Data persisted correctly | P0 |
| **BF-DB-02** | Database read consistency | Read operations from database | Data retrieved correctly<br>No stale data | P0 |
| **BF-DB-03** | Database transaction integrity | Multi-step operations | All or nothing<br>Rollback on failure | P0 |
| **BF-DB-04** | Database connection pool | High concurrent load | Connections managed efficiently<br>No pool exhaustion | P1 |
| **BF-DB-05** | Database replication sync | Read from replica | Data consistent with primary | P1 |

### 7.4 Admin Web Portal

| ID | Test Case | Description | Expected Result | Priority |
|---|---|---|---|---|
| **BF-ADMIN-PORTAL-01** | Admin portal access | Admin logs into web portal | Dashboard loads<br>All features accessible | P0 |
| **BF-ADMIN-PORTAL-02** | Real-time dashboard updates | Dashboard shows live data | Data updates in real-time<br>No page refresh needed | P1 |
| **BF-ADMIN-PORTAL-03** | Admin portal authentication | Admin login/logout | Secure authentication<br>Session management works | P0 |
| **BF-ADMIN-PORTAL-04** | Admin portal authorization | Non-admin tries to access | Access denied<br>403 error | P0 |

---

## Test Execution Priority

### P0 (Critical - Must Pass)
- All end-to-end business cycle tests
- All payment processing tests
- All redemption validation tests
- All money flow calculations
- All admin approval flows

### P1 (High Priority)
- Multiple concurrent user scenarios
- Edge cases and error handling
- Performance and load tests
- External service integration tests

### P2 (Medium Priority)
- Advanced filtering and search
- Report generation
- Bulk operations
- Offline mode scenarios

---

## Test Data Requirements

### Test Merchants
- At least 5 approved merchants
- Merchants with different business types
- Merchants with different bank accounts

### Test Consumers
- At least 20 test consumer accounts
- Consumers with different payment methods
- Consumers with different voucher purchase histories

### Test Vouchers
- Vouchers with different denominations ($5, $10, $25, $50, $100)
- Vouchers with different categories
- Vouchers with different expiry dates
- Vouchers with different stock quantities

### Test Payments
- Successful payments (all payment methods)
- Failed payments (insufficient funds, timeout)
- Payment callbacks (valid and invalid)

---

## Automation Recommendations

### High Automation Priority
- **BF-CYCLE-01**: Complete business cycle (E2E)
- **BF-PURCHASE-01 to BF-PURCHASE-08**: Consumer purchase flows
- **BF-MONEY-01 to BF-MONEY-06**: Money flow calculations
- **BF-REDEEM-01 to BF-REDEEM-08**: Redemption flows
- **BF-ADMIN-01 to BF-ADMIN-03**: Admin approval flows

### Medium Automation Priority
- **BF-PROCESS-01 to BF-PROCESS-05**: Platform processing
- **BF-PAYOUT-01 to BF-PAYOUT-06**: Payout operations
- **BF-MONITOR-01 to BF-MONITOR-05**: Transaction monitoring

### Manual/Exploratory Testing
- **BF-ADMIN-PORTAL-02**: Real-time dashboard UX
- **BF-DATA-05**: Offline mode user experience
- **BF-SYNC-04**: Offline redemption user flow

---

## Success Criteria

### Functional
- ✅ All P0 test cases pass
- ✅ All critical business flows work end-to-end
- ✅ Money calculations are accurate (within $0.01 tolerance)
- ✅ All validations work correctly

### Performance
- ✅ Purchase flow completes in < 5 seconds
- ✅ Redemption flow completes in < 3 seconds
- ✅ Dashboard loads in < 2 seconds
- ✅ System handles 1000 concurrent users

### Reliability
- ✅ Payment processing success rate > 99.9%
- ✅ Redemption processing success rate > 99.9%
- ✅ No data loss in any flow
- ✅ All transactions are auditable

---

**Document Control**  
Author: QA Engineering  
Reviewers: QA Lead, Product Manager, Tech Lead  
Next Review: Monthly  
Changelog: v1.0 – Initial test scenarios from business flow diagrams



