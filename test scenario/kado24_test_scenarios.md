# Kado24 Cambodia - Complete Test Scenarios
**Version:** 1.0  
**Date:** November 15, 2025  
**Purpose:** Comprehensive test scenarios for all business processes

---

## Table of Contents
1. [Merchant Onboarding & Registration](#1-merchant-onboarding--registration)
2. [Voucher Creation Process](#2-voucher-creation-process)
3. [Consumer Purchase Flow](#3-consumer-purchase-flow)
4. [Money Flow & Revenue Split](#4-money-flow--revenue-split)
5. [Voucher Redemption Flow](#5-voucher-redemption-flow)
6. [Admin Platform Management](#6-admin-platform-management)
7. [Financial Operations - Weekly Payouts](#7-financial-operations---weekly-payouts)
8. [Data & Integration Flow](#8-data--integration-flow)
9. [Cross-Process Integration Tests](#9-cross-process-integration-tests)

---

## 1. Merchant Onboarding & Registration

### Process Overview
Merchant registers → Admin reviews (24-48 hours) → Approval → Account activated

### 1.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| MR-P01 | Successful merchant registration with all valid data | - Merchant has valid business license<br>- Email is unique | 1. Navigate to merchant registration<br>2. Fill all required fields<br>3. Upload business documents<br>4. Submit application | - Registration successful<br>- Status: "Pending Approval"<br>- Confirmation email sent<br>- Admin receives notification |
| MR-P02 | Admin approves merchant application | - Merchant application in "Pending" status<br>- Admin logged in | 1. Admin opens pending applications<br>2. Reviews merchant documents<br>3. Clicks "Approve" | - Merchant status: "Approved"<br>- Merchant receives approval email<br>- Merchant can log in<br>- Can create vouchers |
| MR-P03 | Merchant completes profile setup | - Merchant approved<br>- First login | 1. Log in to merchant app<br>2. Complete profile wizard<br>3. Add bank account details<br>4. Set business hours | - Profile 100% complete<br>- Dashboard accessible<br>- Can create first voucher |

### 1.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| MR-N01 | Registration with duplicate email | - Email already exists in system | 1. Attempt registration with existing email | - Error: "Email already registered"<br>- Registration blocked |
| MR-N02 | Registration with invalid business license | - Business license number is invalid format | 1. Submit registration with invalid license format | - Validation error shown<br>- Cannot proceed |
| MR-N03 | Admin rejects merchant application | - Merchant application pending<br>- Documents are incomplete | 1. Admin reviews application<br>2. Clicks "Reject" with reason | - Status: "Rejected"<br>- Merchant receives rejection email with reason<br>- Can reapply with corrections |
| MR-N04 | Incomplete document upload | - Required documents missing | 1. Try to submit without all documents | - Validation error<br>- Lists missing documents<br>- Submit button disabled |

### 1.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| MR-E01 | Application timeout during document upload | Large file upload takes >30 mins | - Upload continues in background<br>- Session preserved<br>- Progress indicator shown |
| MR-E02 | Duplicate application submission | Merchant clicks submit multiple times | - Only one application created<br>- Duplicate prevention mechanism |
| MR-E03 | Admin review exactly at 48-hour SLA | Application reviewed at 47:59:59 | - SLA marked as "Met"<br>- No escalation triggered |
| MR-E04 | Unicode/Special characters in business name | Business name contains ភាសាខ្មែរ (Khmer) | - Properly stored and displayed<br>- No encoding issues |

---

## 2. Voucher Creation Process

### Process Overview
Approved merchant → Create voucher → Set terms → Platform review (if needed) → Published

### 2.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| VC-P01 | Create standard voucher with fixed amounts | - Merchant approved and logged in | 1. Navigate to "Create Voucher"<br>2. Enter voucher details<br>3. Set denominations: $5, $10, $25<br>4. Upload voucher image<br>5. Set expiry (90 days)<br>6. Publish | - Voucher created<br>- Status: "Active"<br>- Visible in marketplace<br>- QR codes generated |
| VC-P02 | Create voucher with custom terms | - Merchant logged in | 1. Create voucher<br>2. Add custom T&C<br>3. Set usage restrictions (1 per customer)<br>4. Set maximum quantity (1000) | - Voucher published with restrictions<br>- Terms visible to consumers |
| VC-P03 | Upload high-quality voucher image | - Image is 1920x1080, <5MB, JPG | 1. Select image<br>2. Upload<br>3. Crop/adjust | - Image uploaded successfully<br>- Optimized for mobile display<br>- Thumbnails generated |

### 2.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| VC-N01 | Create voucher with invalid denomination | - Trying to create $0 voucher | 1. Set amount to $0<br>2. Try to save | - Validation error: "Amount must be > $0"<br>- Cannot save |
| VC-N02 | Upload prohibited image content | - Image contains prohibited content | 1. Upload inappropriate image | - Content filter blocks upload<br>- Admin notified for review |
| VC-N03 | Set expiry date in the past | - Selected date is yesterday | 1. Set expiry to past date<br>2. Try to save | - Error: "Expiry must be future date"<br>- Date picker restricts past dates |
| VC-N04 | Exceed voucher quantity limit | - Platform limit: 10,000 per voucher | 1. Set quantity to 15,000<br>2. Save | - Warning shown<br>- Capped at platform limit |

### 2.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| VC-E01 | Create voucher at exactly midnight | Created at 00:00:00 | - Proper timezone handling<br>- Cambodian timezone applied |
| VC-E02 | Multiple merchants create identical vouchers | Same product, price, terms | - Both allowed<br>- Differentiated by merchant branding |
| VC-E03 | Voucher expires while in shopping cart | Consumer adds voucher, waits, then purchases | - Cart validation before payment<br>- Error if expired<br>- Prompt to remove |
| VC-E04 | Bulk upload 100 vouchers simultaneously | CSV import feature | - Batch processing<br>- Progress tracking<br>- Error report for failed items |

---

## 3. Consumer Purchase Flow

### Process Overview
Browse → Select → Choose amount → Payment → Voucher generated → Confirmation sent

### 3.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| CP-P01 | Successful voucher purchase with ABA Pay | - Consumer logged in<br>- Valid ABA account | 1. Browse vouchers<br>2. Select $25 voucher<br>3. Proceed to checkout<br>4. Select ABA Pay<br>5. Complete payment | - Payment processed<br>- Voucher in wallet<br>- QR code generated<br>- Email + SMS + Push sent |
| CP-P02 | Purchase with Wing Money | - Wing account with sufficient balance | 1. Select voucher<br>2. Choose Wing payment<br>3. Authorize payment | - Payment successful<br>- Voucher active immediately<br>- Transaction recorded |
| CP-P03 | Purchase with Pi Pay | - Pi Pay linked account | 1. Add to cart<br>2. Select Pi Pay<br>3. Confirm payment | - Payment processed<br>- Instant delivery<br>- Digital receipt |
| CP-P04 | Purchase multiple vouchers in one transaction | - Consumer wants 3 different vouchers | 1. Add voucher A ($10)<br>2. Add voucher B ($25)<br>3. Add voucher C ($15)<br>4. Checkout<br>5. Pay total $50 | - All 3 vouchers in wallet<br>- Single payment transaction<br>- Individual QR codes for each |
| CP-P05 | Gift voucher to another user | - Recipient email provided | 1. Select voucher<br>2. Choose "Gift to friend"<br>3. Enter recipient email<br>4. Complete payment | - Purchaser charged<br>- Recipient receives voucher<br>- Gift message included |

### 3.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| CP-N01 | Payment failure - insufficient funds | - Account balance < voucher amount | 1. Attempt purchase<br>2. Payment gateway rejects | - Error: "Insufficient funds"<br>- Order status: "Failed"<br>- No voucher generated<br>- User prompted to retry |
| CP-N02 | Payment timeout | - Payment takes >5 minutes | 1. Initiate payment<br>2. Don't complete within timeout | - Order cancelled<br>- Funds not captured<br>- Notification sent |
| CP-N03 | Double-spend attempt | - User clicks "Pay" multiple times | 1. Click pay button rapidly 5 times | - Only one payment processed<br>- Idempotency key prevents duplicates<br>- Other requests ignored |
| CP-N04 | Purchase expired voucher | - Voucher expired 1 hour ago | 1. Try to purchase expired voucher | - Error: "Voucher no longer available"<br>- Removed from cart |
| CP-N05 | Invalid payment callback | - Payment gateway sends malformed callback | 1. Payment made<br>2. Callback fails validation | - Payment logged as "Pending"<br>- Manual reconciliation triggered<br>- Admin alert sent |

### 3.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| CP-E01 | Network interruption during payment | WiFi disconnects mid-transaction | - Transaction status checked via polling<br>- Retry mechanism<br>- Eventually consistent state |
| CP-E02 | Purchase at maximum platform limit | Buying 50 vouchers (platform daily limit) | - All processed<br>- Rate limit notification<br>- Next day counter resets |
| CP-E03 | Concurrent purchase of last voucher | 2 users buy last available voucher simultaneously | - First commit wins<br>- Second gets "Sold out" error<br>- Inventory lock mechanism |
| CP-E04 | Payment in different currency | User pays in USD, THB, or EUR | - Currency conversion applied<br>- Exchange rate shown<br>- Final amount in USD stored |

---

## 4. Money Flow & Revenue Split

### Process Overview
Customer pays $100 → Gateway fee (~2%) → Platform 8% commission → Merchant 92%

### 4.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| MF-P01 | Standard revenue split calculation - $100 voucher | - $100 voucher purchased | 1. Customer pays $100<br>2. Payment gateway processes | - Gateway fee: $2<br>- Platform commission: $8<br>- Merchant earnings: $92<br>- All recorded in ledger |
| MF-P02 | Multiple transactions aggregation | - 10 vouchers sold at $25 each | 1. Process 10 sales<br>2. Calculate totals | - Total GMV: $250<br>- Platform revenue: $20 (8%)<br>- Merchant total: $230 (92%) |
| MF-P03 | Commission calculation with different amounts | - Vouchers: $5, $10, $25, $50, $100 | 1. Sell one of each<br>2. Calculate commission | - $5 → $0.40 platform, $4.60 merchant<br>- $10 → $0.80 platform, $9.20 merchant<br>- $25 → $2.00 platform, $23.00 merchant<br>- Accurate percentage maintained |

### 4.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| MF-N01 | Gateway fee exceeds expected range | - Gateway charges 5% instead of 2% | 1. Payment processed<br>2. Fee recorded | - Alert triggered<br>- Financial team notified<br>- Transaction flagged for review |
| MF-N02 | Rounding error accumulation | - 1000 micro-transactions with decimals | 1. Process many small amounts<br>2. Calculate totals | - Rounding differences ≤ $0.01<br>- Audit log reconciliation<br>- Discrepancy < 0.001% |
| MF-N03 | Negative balance scenario | - Refund > original payment | 1. Issue refund larger than purchase | - Validation prevents negative<br>- Maximum refund = original amount |

### 4.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| MF-E01 | Split calculation for $0.01 voucher | Minimum possible amount | - Platform: $0.00 (rounded)<br>- Merchant: $0.01<br>- Platform absorbs rounding loss |
| MF-E02 | High-value voucher ($10,000) | Enterprise gift card | - Platform: $800<br>- Merchant: $9,200<br>- Additional fraud review<br>- Hold period: 48 hours |
| MF-E03 | Partial refund scenario | Customer returns $50 of $100 voucher | - Refund: $50<br>- Platform refunds: $4<br>- Merchant refunds: $46<br>- Commission adjusted |

---

## 5. Voucher Redemption Flow

### Process Overview
Consumer opens wallet → Show QR → Merchant scans → Validation → Redemption confirmed

### 5.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| VR-P01 | Standard QR code redemption | - Valid unused voucher<br>- Correct merchant scanning | 1. Consumer opens voucher in wallet<br>2. Show QR code<br>3. Merchant scans QR<br>4. Both confirm | - Voucher marked "Used"<br>- Real-time sync both apps<br>- Transaction logged<br>- Added to merchant payout queue |
| VR-P02 | PIN-based redemption (no scanner) | - Voucher has 6-digit PIN<br>- Merchant has no scanner | 1. Consumer provides PIN<br>2. Merchant enters PIN manually<br>3. System validates | - Voucher redeemed successfully<br>- Same workflow as QR |
| VR-P03 | Partial redemption | - $100 voucher, purchase is $75 | 1. Scan voucher<br>2. Select "Partial" option<br>3. Enter $75<br>4. Confirm | - $75 redeemed<br>- $25 balance remains<br>- New QR for remaining amount |
| VR-P04 | Redemption at merchant with multiple locations | - Merchant has 5 branches<br>- Voucher valid at all | 1. Consumer visits branch #3<br>2. Redeem voucher | - Validates branch is owned by merchant<br>- Redeemed successfully<br>- Location tracked |

### 5.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| VR-N01 | Attempt to use already redeemed voucher | - Voucher status: "Used" | 1. Consumer tries to show same QR<br>2. Merchant scans | - Error: "Voucher already used"<br>- Shows redemption date/time<br>- Prevents fraud |
| VR-N02 | Expired voucher redemption attempt | - Voucher expired yesterday | 1. Attempt to scan expired voucher | - Error: "Voucher expired"<br>- Shows expiry date<br>- Blocks redemption |
| VR-N03 | Wrong merchant scanning | - Voucher for Restaurant A<br>- Scanned by Restaurant B | 1. Wrong merchant scans QR | - Error: "Invalid voucher for this merchant"<br>- Fraud alert logged |
| VR-N04 | Offline redemption with outdated data | - Merchant app offline<br>- Voucher was used 1 hour ago | 1. Merchant app in offline mode<br>2. Scans used voucher | - Offline validation fails<br>- Requires online connection<br>- Warning shown |

### 5.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| VR-E01 | Simultaneous redemption attempt | Consumer and merchant scan at exact same second | - First transaction locks voucher<br>- Second attempt blocked<br>- Race condition handled |
| VR-E02 | Redemption during system maintenance | Scheduled downtime window | - Grace period notification<br>- Queue redemption for processing<br>- Complete when system online |
| VR-E03 | QR code damaged/unreadable | Physical print is partially destroyed | - Manual PIN entry fallback<br>- Customer service verification<br>- Admin override option |
| VR-E04 | Timezone confusion on expiry | Voucher expires at midnight in different timezone | - System uses Cambodian time (ICT)<br>- Clear timezone displayed<br>- Grace period: 24 hours |

---

## 6. Admin Platform Management

### Process Overview
Admin monitors transactions → Reviews merchants → Handles disputes → Manages platform

### 6.1 Positive Test Scenarios - Merchant Lifecycle

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| AM-P01 | Review pending merchant application | - New merchant application received | 1. Admin logs in<br>2. Opens pending applications<br>3. Reviews documents<br>4. Verifies business license<br>5. Approves | - Merchant approved<br>- Email sent<br>- Merchant can access dashboard |
| AM-P02 | Suspend merchant for policy violation | - Merchant violated terms<br>- Multiple complaints | 1. Admin reviews violations<br>2. Clicks "Suspend account"<br>3. Provides reason | - Merchant suspended<br>- Cannot create new vouchers<br>- Existing vouchers still redeemable<br>- Notification sent |
| AM-P03 | Reactivate suspended merchant | - Previously suspended<br>- Issue resolved | 1. Review case<br>2. Click "Reactivate"<br>3. Add notes | - Merchant reactivated<br>- Full access restored<br>- Notification sent |

### 6.2 Positive Test Scenarios - Transaction Monitoring

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| AM-P04 | View real-time transaction dashboard | - Active transactions occurring | 1. Open dashboard<br>2. View metrics | - Live transaction count<br>- GMV updates real-time<br>- Charts refresh automatically |
| AM-P05 | Detect fraudulent pattern | - Suspicious activity detected<br>- Multiple high-value purchases from same IP | 1. System flags transaction<br>2. Admin reviews<br>3. Investigates | - Alert shown<br>- Transaction details visible<br>- Can freeze account if needed |
| AM-P06 | Generate financial report | - Month-end reporting period | 1. Select date range<br>2. Choose report type<br>3. Generate | - Excel/PDF report generated<br>- Revenue breakdown<br>- Merchant payouts<br>- Platform commission |

### 6.3 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| AM-N01 | Approve merchant without required documents | - Documents incomplete | 1. Try to approve<br>2. Click approve button | - Validation error<br>- Cannot proceed<br>- Lists missing items |
| AM-N02 | Access denied for non-admin user | - Regular user account | 1. Try to access admin portal | - 403 Forbidden error<br>- Redirected to login<br>- Access logged |
| AM-N03 | Concurrent admin actions on same merchant | - Two admins reviewing same application | 1. Admin A approves<br>2. Admin B tries to approve | - Second action blocked<br>- "Already processed" message<br>- Optimistic locking |

### 6.4 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| AM-E01 | Review application at exactly 48-hour deadline | SLA about to breach | - Countdown timer shown<br>- Priority flag<br>- Alert if not completed |
| AM-E02 | Bulk approval of 100 merchants | Mass onboarding event | - Batch processing<br>- Progress indicator<br>- Email queue management |
| AM-E03 | Admin session timeout during approval | Working on review for 2 hours | - Draft saved<br>- Session extended warning<br>- Auto-save notes |

---

## 7. Financial Operations - Weekly Payouts

### Process Overview
Every Friday → Calculate merchant earnings → Review & approve → Bank transfer

### 7.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| FO-P01 | Standard weekly payout calculation | - Week ended, transactions completed<br>- Friday arrived | 1. System calculates weekly earnings<br>2. Generates payout report<br>3. Admin reviews<br>4. Approves batch | - All merchants' earnings calculated<br>- 92% of voucher values<br>- Report generated |
| FO-P02 | Process payout for single merchant | - Merchant A sold $10,000 worth of vouchers | 1. Calculate payout: $10,000 × 92% = $9,200<br>2. Initiate bank transfer<br>3. Confirm transfer | - $9,200 transferred<br>- Status: "Paid"<br>- Email confirmation to merchant |
| FO-P03 | Batch payout for 100 merchants | - 100 active merchants with earnings | 1. Generate batch file<br>2. Upload to banking system<br>3. Process transfers | - All transfers initiated<br>- Batch processing log<br>- Individual confirmations |
| FO-P04 | Payout with bank account validation | - First payout for new merchant | 1. Validate bank account details<br>2. Send test transfer ($0.01)<br>3. Confirm receipt<br>4. Process full payout | - Bank account verified<br>- Main payout successful<br>- Status updated |

### 7.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| FO-N01 | Bank transfer failure | - Invalid bank account number | 1. Attempt transfer<br>2. Bank rejects | - Transfer failed<br>- Status: "Failed"<br>- Admin alerted<br>- Merchant contacted to update details |
| FO-N02 | Insufficient platform balance | - Platform account < total payout amount | 1. Calculate payouts<br>2. Attempt transfer | - Error: "Insufficient balance"<br>- Financial alert<br>- Payouts held |
| FO-N03 | Merchant account suspended before payout | - Suspension occurred mid-week | 1. Payout calculation runs<br>2. Account suspended | - Payout held<br>- Flagged for review<br>- Manual decision required |
| FO-N04 | Payout amount mismatch | - Calculated amount differs from expected | 1. System calculates $5,000<br>2. Expected was $5,200 | - Discrepancy flagged<br>- Automatic hold<br>- Investigation required |

### 7.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|
| FO-E01 | Payout on bank holiday | Friday is public holiday in Cambodia | - System detects holiday<br>- Moves payout to previous business day<br>- Notification sent |
| FO-E02 | Zero earnings for a merchant | Merchant had no redemptions this week | - Payout = $0<br>- Skip transfer<br>- No email sent |
| FO-E03 | Micro-payout below minimum threshold | Merchant earned $0.50 total | - Below $1 minimum<br>- Rolled over to next week<br>- Accumulates until threshold met |
| FO-E04 | Refund processed after payout calculation | Refund on Saturday, payout was Friday | - Adjustment in next cycle<br>- Deducted from next payout<br>- Audit trail maintained |

---

## 8. Data & Integration Flow

### Process Overview
Mobile Apps ↔ REST API ↔ Backend Services ↔ Database ↔ External Integrations

### 8.1 Positive Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| DI-P01 | Consumer app syncs data after offline mode | - App was offline for 2 hours<br>- Back online | 1. App reconnects<br>2. Triggers sync<br>3. Fetches updates | - New vouchers downloaded<br>- Purchase history updated<br>- Wallet synced<br>- No data loss |
| DI-P02 | Payment gateway callback received | - Payment completed at ABA<br>- Callback sent | 1. Gateway sends webhook<br>2. API validates signature<br>3. Processes callback | - Payment status updated<br>- Voucher generated<br>- Event published to Kafka |
| DI-P03 | Real-time notification delivery | - Voucher purchased | 1. Order completed<br>2. Notification service triggered | - Push notification sent (FCM)<br>- SMS sent (if enabled)<br>- Email sent (SendGrid)<br>- All within 10 seconds |
| DI-P04 | Database replication sync | - Write to primary PostgreSQL<br>- Read replicas | 1. Create new voucher<br>2. Query read replica | - Data replicated within 1 second<br>- Eventual consistency<br>- No conflicts |

### 8.2 Negative Test Scenarios

| ID | Test Case | Preconditions | Steps | Expected Result |
|---|---|---|---|---|
| DI-N01 | API rate limit exceeded | - Consumer makes 1000 requests/minute | 1. Send burst of API calls | - 429 Too Many Requests<br>- Rate limit header shown<br>- Retry-After header provided |
| DI-N02 | Invalid payment webhook signature | - Malicious callback attempt | 1. Send callback with invalid signature<br>2. API receives | - Signature validation fails<br>- Request rejected<br>- Security alert logged |
| DI-N03 | Database connection pool exhausted | - 1000 concurrent connections | 1. Spike in traffic<br>2. All connections used | - New requests queued<br>- Circuit breaker opens<br>- Graceful degradation |
| DI-N04 | External service timeout | - Payment gateway takes >30 seconds | 1. Initiate payment<br>2. Gateway doesn't respond | - Request timeout<br>- Transaction marked "Pending"<br>- Retry scheduled |

### 8.3 Edge Cases

| ID | Test Case | Scenario | Expected Behavior |
|---|---|---|---|---|
| DI-E01 | Kafka partition rebalancing during purchase | Consumer group rebalances | - Message reprocessed if needed<br>- Idempotency prevents duplicates<br>- No lost events |
| DI-E02 | Redis cache invalidation | Cache cleared during active session | - Cache miss handled<br>- Fetch from PostgreSQL<br>- Repopulate cache |
| DI-E03 | CDN cache serving stale voucher images | Image updated but CDN cached | - Cache-Control headers respected<br>- TTL = 1 hour<br>- Purge API available |
| DI-E04 | Cross-region API latency | User in remote area | - Acceptable latency <500ms<br>- Connection pooling<br>- Compression enabled |

---

## 9. Cross-Process Integration Tests

### 9.1 End-to-End User Journeys

| ID | Test Journey | Steps | Expected Result |
|---|---|---|---|
| E2E-01 | Complete consumer journey | 1. Register account<br>2. Browse vouchers<br>3. Purchase $25 voucher<br>4. Receive in wallet<br>5. Redeem at merchant<br>6. View digital receipt | - Seamless flow<br>- All steps successful<br>- < 2 minutes total<br>- Data consistent across all services |
| E2E-02 | Complete merchant journey | 1. Apply as merchant<br>2. Admin approves<br>3. Login and create voucher<br>4. Consumer purchases<br>5. Redeem at location<br>6. Receive Friday payout | - End-to-end flow works<br>- Money flows correctly<br>- 8%/92% split verified |
| E2E-03 | Gift voucher journey | 1. User A purchases voucher as gift<br>2. Sends to User B email<br>3. User B receives email<br>4. Claims voucher<br>5. Redeems at merchant | - Gift transfer successful<br>- Both users notified<br>- Voucher ownership transferred |

### 9.2 Failure & Recovery Scenarios

| ID | Test Scenario | Failure Injected | Expected Recovery |
|---|---|---|---|
| FR-01 | Payment succeeds but notification fails | Email service down | - Voucher still generated<br>- Notification queued<br>- Retry when service up<br>- User can see in wallet |
| FR-02 | Database fails during redemption | PostgreSQL connection lost | - Request fails gracefully<br>- User sees error message<br>- Can retry<br>- No voucher marked used |
| FR-03 | Kafka broker down during purchase | Messaging system unavailable | - Events buffered<br>- Synchronous flow continues<br>- Events published when broker up<br>- Analytics eventually consistent |

### 9.3 Performance & Load Tests

| ID | Test Scenario | Load Profile | Success Criteria |
|---|---|---|---|
| PERF-01 | Black Friday sale | 10,000 concurrent purchases | - 95% < 3 seconds response time<br>- 0% failed transactions<br>- System stable |
| PERF-02 | Mass redemption event | 5,000 redemptions/hour | - QR scans < 2 seconds<br>- Real-time sync maintained<br>- No conflicts |
| PERF-03 | Admin dashboard load | 50 admins viewing simultaneously | - Dashboard loads < 5 seconds<br>- Charts render smoothly<br>- No database locks |

---

## Test Execution Guidelines

### Priority Levels
- **P0 (Critical):** Must pass before release - blocking issues
- **P1 (High):** Core functionality - fix before release
- **P2 (Medium):** Important but not blocking
- **P3 (Low):** Nice to have, can defer

### Test Environments
1. **Development:** Unit tests, integration tests
2. **Staging:** Full test suite, UAT
3. **Production:** Smoke tests, monitoring

### Automation Strategy
- **Unit Tests:** 80% coverage minimum
- **API Tests:** Postman/REST Assured
- **UI Tests:** Selenium/Appium for mobile
- **Load Tests:** JMeter/k6
- **Security Tests:** OWASP ZAP

### Defect Severity
- **Critical:** System down, data loss, security breach
- **High:** Major feature broken, workaround difficult
- **Medium:** Feature partially broken, workaround available
- **Low:** Minor issue, cosmetic

---

## Appendix: Test Data Matrix

### Sample Test Users

| Type | Email | Password | Bank Account | Status |
|---|---|---|---|---|
| Consumer 1 | consumer1@test.com | Test@123 | N/A | Active |
| Consumer 2 | consumer2@test.com | Test@123 | N/A | Active |
| Merchant 1 | merchant1@test.com | Test@123 | 001-123-456 | Approved |
| Merchant 2 | merchant2@test.com | Test@123 | 001-789-012 | Pending |
| Admin | admin@kado24.com | Admin@123 | N/A | Active |

### Sample Vouchers

| ID | Merchant | Amount | Status | Expiry |
|---|---|---|---|---|
| V001 | Coffee Shop | $5, $10, $25 | Active | 90 days |
| V002 | Restaurant | $10, $25, $50 | Active | 60 days |
| V003 | Spa | $50, $100 | Active | 180 days |
| V004 | Retail Store | $25 | Expired | -30 days |

### Sample Payment Gateways (Mock)

| Gateway | Test Card | Expected Result |
|---|---|---|
| ABA Pay | 4111111111111111 | Success |
| ABA Pay | 4000000000000002 | Decline |
| Wing | 012-345-678 | Success |
| Pi Pay | test@pi.com | Success |

---

**Document Control**
- **Author:** QA Team
- **Reviewers:** Product, Engineering, Operations
- **Next Review:** Monthly
- **Version History:** 
  - v1.0 (Nov 15, 2025): Initial release

---

**End of Test Scenarios Document**
