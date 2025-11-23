# 📋 Kado24 Platform - Business Flow Documentation

**Complete Business Process Flows for All User Roles**

---

## 📑 Table of Contents

1. [Consumer Business Flows](#consumer-business-flows)
2. [Merchant Business Flows](#merchant-business-flows)
3. [Admin Business Flows](#admin-business-flows)
4. [Cross-Role Interactions](#cross-role-interactions)

---

## 👤 Consumer Business Flows

### 1. Registration & Verification Flow

**Purpose:** New consumer account creation with OTP verification

**Steps:**
1. **User Initiates Registration**
   - Opens Consumer App
   - Clicks "Create Account" or "Sign Up"
   - Navigates to Registration Screen

2. **Fill Registration Form**
   - Full Name (required)
   - Phone Number (required, format: +855XXXXXXXXX)
   - Email (optional)
   - Password (required, min 8 characters)
   - Confirm Password (required)
   - Accept Terms & Conditions (required)

3. **Submit Registration**
   - Frontend validates form
   - POST `/api/v1/auth/register`
   - Backend creates user with status: `PENDING_VERIFICATION`
   - Backend generates OTP
   - OTP sent to phone number (SMS/mock)
   - OTP stored in `auth_schema.verification_requests` for admin support

4. **OTP Verification Screen**
   - User redirected to OTP Screen
   - Purpose: `REGISTRATION`
   - User enters 6-digit OTP code
   - POST `/api/v1/auth/verify-otp` with:
     - `phoneNumber`
     - `otpCode`
     - `purpose: "REGISTRATION"`

5. **Verification Success**
   - Backend validates OTP
   - User status updated to `ACTIVE`
   - Phone verified: `true`
   - JWT tokens generated (access + refresh)
   - User redirected to Home Screen
   - User profile created in `user_schema.user_profiles`

**Decision Points:**
- ❌ **Invalid OTP**: Show error, allow resend OTP
- ❌ **OTP Expired**: Show error, allow resend OTP
- ✅ **Valid OTP**: Account activated, proceed to home

**Alternative Flows:**
- **Admin Verification**: If OTP fails multiple times, admin can verify manually via Admin Portal
- **Resend OTP**: User can request new OTP (max 3 attempts per 15 minutes)

---

### 2. Login & Authentication Flow

**Purpose:** Authenticate existing consumer

**Steps:**
1. **User Opens App**
   - Opens Consumer App
   - Checks for stored access token
   - If valid token exists → Auto-login
   - If no token → Show Login Screen

2. **Login Screen**
   - Enter Phone Number or Email (identifier)
   - Enter Password
   - Click "Login"

3. **Submit Login**
   - POST `/api/v1/auth/login`
   - Backend validates credentials
   - Check user status

4. **Status Check:**
   - **If `ACTIVE`**: Generate tokens, login successful
   - **If `PENDING_VERIFICATION`**: 
     - Generate OTP
     - Return error: `OTP_VERIFICATION_REQUIRED`
     - Redirect to OTP Screen with purpose: `LOGIN_VERIFICATION`
   - **If `SUSPENDED`**: Show error, contact support
   - **If `DELETED`**: Show error, account not found

5. **OTP Verification (if required)**
   - User enters OTP
   - POST `/api/v1/auth/verify-otp` with purpose: `LOGIN_VERIFICATION`
   - On success: Activate account, generate tokens

6. **Login Success**
   - Store access token & refresh token
   - Store user data
   - Navigate to Home Screen
   - Update last login timestamp

**Decision Points:**
- ❌ **Invalid Credentials**: Show error message
- ⚠️ **Pending Verification**: Redirect to OTP screen
- ✅ **Active Account**: Login successful

---

### 3. Browse & Search Vouchers Flow

**Purpose:** Discover and find vouchers

**Steps:**
1. **Home Screen**
   - User lands on Home Screen
   - Display featured vouchers
   - Display categories
   - Display recent/popular vouchers

2. **Category Selection**
   - User taps category (Food, Spa, Entertainment, etc.)
   - Filter vouchers by category
   - GET `/api/v1/vouchers?categoryId={id}&status=ACTIVE`
   - Display filtered results

3. **Search Functionality**
   - User taps search icon
   - Enter search query (voucher title, merchant name)
   - GET `/api/v1/vouchers?search={query}&status=ACTIVE`
   - Display search results

4. **Voucher List**
   - Display vouchers with:
     - Image
     - Title
     - Merchant name
     - Price range (min - max)
     - Discount percentage (if applicable)
     - Rating (if available)

5. **Voucher Detail**
   - User taps voucher card
   - Navigate to Voucher Detail Screen
   - GET `/api/v1/vouchers/{id}`
   - Display:
     - Full description
     - Available denominations
     - Terms & conditions
     - Reviews
     - Merchant information

**Decision Points:**
- **No Results**: Show "No vouchers found" message
- **Filter Applied**: Show active filter chips
- **Clear Filter**: Reset to all vouchers

---

### 4. Purchase Voucher Flow

**Purpose:** Buy voucher and add to wallet

**Steps:**
1. **Select Voucher**
   - User on Voucher Detail Screen
   - Reviews voucher details
   - Selects denomination (if multiple options)

2. **Add to Cart / Purchase**
   - User clicks "Buy Now" or "Add to Cart"
   - If not logged in → Redirect to Login
   - If logged in → Proceed to Checkout

3. **Checkout Screen**
   - Review voucher details
   - Select quantity
   - Review total amount
   - Select payment method (if multiple available)

4. **Payment Processing**
   - POST `/api/v1/orders` with:
     - `voucherId`
     - `denomination` (selected price)
     - `quantity`
     - `paymentMethod`
   - Backend creates order with status: `PENDING_PAYMENT`
   - Backend calculates:
     - Subtotal
     - Platform commission (8%)
     - Merchant payout (92%)
     - Total amount

5. **Payment Gateway**
   - Redirect to payment gateway (mock or real)
   - User completes payment
   - Payment gateway callback
   - POST `/api/v1/orders/{id}/confirm-payment`

6. **Order Confirmation**
   - Backend updates order status: `PAID`
   - Backend creates transaction record
   - Backend adds voucher to user's wallet
   - POST `/api/v1/wallet/vouchers` (add voucher)
   - Send notification to user

7. **Success Screen**
   - Show order confirmation
   - Display voucher in wallet
   - Option to "View Wallet" or "Continue Shopping"

**Decision Points:**
- ❌ **Payment Failed**: Show error, allow retry
- ❌ **Insufficient Stock**: Show error, update quantity
- ✅ **Payment Success**: Add to wallet, send notification

**Business Rules:**
- Commission: 8% platform, 92% merchant
- Voucher expires based on merchant terms
- Refund policy applies (if applicable)

---

### 5. Wallet Management Flow

**Purpose:** View and manage purchased vouchers

**Steps:**
1. **Access Wallet**
   - User navigates to "My Wallet" or "My Vouchers"
   - GET `/api/v1/wallet/vouchers`
   - Display all vouchers in wallet

2. **Wallet Display**
   - Group vouchers by status:
     - **Active**: Available for redemption
     - **Redeemed**: Already used
     - **Expired**: Past expiration date
     - **Gifted**: Sent to another user

3. **Voucher Actions**
   - **View Details**: Show voucher information
   - **Gift**: Send to another user (see Gift Flow)
   - **Redeem**: Use voucher at merchant (see Redemption Flow)

4. **Filter & Sort**
   - Filter by status
   - Sort by date, value, merchant
   - Search within wallet

**Decision Points:**
- **Empty Wallet**: Show "No vouchers" message with CTA to browse
- **Expired Voucher**: Show expiration notice
- **Redeemed Voucher**: Show redemption details

---

### 6. Gift Voucher Flow

**Purpose:** Send voucher to another user

**Steps:**
1. **Select Voucher**
   - User in Wallet
   - Selects voucher to gift
   - Clicks "Gift" button

2. **Gift Screen**
   - Enter recipient phone number
   - Enter optional message
   - Review voucher details
   - Confirm gift

3. **Submit Gift**
   - POST `/api/v1/wallet/gift` with:
     - `walletVoucherId`
     - `recipientPhoneNumber`
     - `message` (optional)
   - Backend validates recipient exists
   - Backend transfers voucher ownership

4. **Gift Confirmation**
   - Voucher removed from sender's wallet
   - Voucher added to recipient's wallet
   - Notification sent to recipient
   - Confirmation shown to sender

**Decision Points:**
- ❌ **Recipient Not Found**: Show error, recipient must register first
- ✅ **Gift Success**: Transfer complete, send notifications

---

### 7. Redemption Flow

**Purpose:** Use voucher at merchant location

**Steps:**
1. **Prepare for Redemption**
   - User at merchant location
   - Opens Consumer App
   - Navigates to Wallet
   - Selects voucher to redeem

2. **Show QR Code / Voucher Code**
   - Display QR code (if available)
   - Display voucher code/PIN
   - Show voucher details

3. **Merchant Scans QR / Enters Code**
   - Merchant uses Merchant App QR Scanner
   - Scans QR code or enters voucher code
   - Merchant validates voucher

4. **Redemption Processing**
   - POST `/api/v1/redemptions` (by merchant)
   - Backend validates:
     - Voucher exists
     - Voucher is active
     - Voucher not already redeemed
     - Voucher not expired
   - Backend creates redemption record
   - Backend updates voucher status: `REDEEMED`

5. **Redemption Confirmation**
   - Notification sent to consumer
   - Voucher marked as redeemed in wallet
   - Transaction recorded

**Decision Points:**
- ❌ **Invalid Voucher**: Show error to merchant
- ❌ **Already Redeemed**: Show error, prevent double redemption
- ❌ **Expired**: Show error, voucher expired
- ✅ **Valid**: Process redemption, update status

---

### 8. Profile Management Flow

**Purpose:** Manage consumer profile and settings

**Steps:**
1. **Access Profile**
   - User navigates to "Profile" or "Settings"
   - GET `/api/v1/users/profile`
   - Display current profile information

2. **View Profile**
   - Full Name
   - Phone Number (verified status)
   - Email (verified status)
   - Avatar
   - Addresses
   - Preferences

3. **Edit Profile**
   - Update Full Name
   - Update Email
   - Upload Avatar
   - Add/Edit Addresses
   - Update Preferences

4. **Save Changes**
   - PUT `/api/v1/users/profile`
   - Backend validates and updates
   - Show success message

**Decision Points:**
- **Email Change**: May require re-verification
- **Phone Change**: Requires OTP verification

---

## 🏪 Merchant Business Flows

### 1. Registration & Approval Flow

**Purpose:** Merchant account creation and admin approval

**Steps:**
1. **Merchant Initiates Registration**
   - Opens Merchant App
   - Clicks "Register as Merchant"
   - Navigates to Registration Screen

2. **Fill Registration Form**
   - Business Name (required)
   - Owner Full Name (required)
   - Phone Number (required)
   - Email (required)
   - Password (required)
   - Business Type/Category
   - Business Description

3. **Submit Registration**
   - POST `/api/v1/auth/register` with role: `MERCHANT`
   - Backend creates user with status: `PENDING_VERIFICATION`
   - Backend creates merchant record with status: `PENDING_APPROVAL`
   - OTP sent for phone verification

4. **OTP Verification**
   - User verifies phone with OTP
   - Account status: `ACTIVE` (user)
   - Merchant status: `PENDING_APPROVAL` (still pending)

5. **Upload Documents** (Optional at registration, required for approval)
   - Business License
   - Tax ID
   - Bank Account Details
   - Business Photos
   - Location Information

6. **Admin Review**
   - Admin receives notification of new merchant application
   - Admin reviews in Admin Portal
   - Admin checks documents
   - Admin approves or rejects

7. **Approval Decision**
   - **If Approved**:
     - Merchant status: `ACTIVE`
     - User status: `ACTIVE` (if not already)
     - Notification sent to merchant
     - Merchant can now create vouchers
   - **If Rejected**:
     - Merchant status: `REJECTED`
     - Rejection reason sent to merchant
     - Merchant can reapply

**Decision Points:**
- ⏳ **Pending Approval**: Merchant cannot create vouchers yet
- ✅ **Approved**: Merchant can access full features
- ❌ **Rejected**: Merchant must reapply or contact support

**Timeline:**
- Registration: Immediate
- Admin Review: 24-48 hours
- Approval: Immediate after admin action

---

### 2. Login & Authentication Flow

**Purpose:** Authenticate merchant

**Steps:**
1. **Merchant Opens App**
   - Opens Merchant App
   - Checks for stored token
   - If valid → Auto-login
   - If no token → Show Login Screen

2. **Login Screen**
   - Enter Phone Number or Email
   - Enter Password
   - Click "Login"

3. **Submit Login**
   - POST `/api/v1/auth/login`
   - Backend validates credentials
   - Check user status and merchant status

4. **Status Check:**
   - **If User `ACTIVE` and Merchant `ACTIVE`**: Login successful
   - **If User `PENDING_VERIFICATION`**: Redirect to OTP screen
   - **If Merchant `PENDING_APPROVAL`**: Show "Awaiting Approval" message
   - **If Merchant `REJECTED`**: Show rejection message with reason
   - **If Merchant `SUSPENDED`**: Show suspension message

5. **Login Success**
   - Store tokens
   - Navigate to Dashboard
   - Load merchant statistics

**Decision Points:**
- ⏳ **Pending Approval**: Limited access, show approval status
- ✅ **Active**: Full access to all features
- ❌ **Rejected/Suspended**: Restricted access

---

### 3. Create Voucher Flow

**Purpose:** Create new voucher for sale

**Steps:**
1. **Navigate to Voucher Creation**
   - Merchant on Dashboard
   - Clicks "Create Voucher" or "Add New Voucher"
   - Navigate to Create Voucher Screen

2. **Fill Voucher Details**
   - **Basic Information**:
     - Title (required)
     - Description (required)
     - Category (required)
     - Image (upload)
   - **Pricing**:
     - Select denomination(s) or price range
     - Add multiple price options
     - Set discount percentage (optional)
   - **Terms & Conditions**:
     - Validity period
     - Usage restrictions
     - Expiration policy
   - **Inventory**:
     - Stock quantity (or unlimited)
     - Availability dates

3. **Save as Draft or Publish**
   - **Save as Draft**: Status = `DRAFT`
     - Can edit later
     - Not visible to consumers
   - **Publish**: Status = `ACTIVE`
     - Immediately visible to consumers
     - Can be purchased

4. **Submit Voucher**
   - POST `/api/v1/vouchers` (for new)
   - PUT `/api/v1/vouchers/{id}` (for draft update)
   - Backend validates:
     - Merchant is active
     - Required fields present
     - Pricing valid
   - Backend creates voucher record

5. **Confirmation**
   - Show success message
   - Navigate to "My Vouchers" screen
   - Voucher appears in list

**Decision Points:**
- **Draft**: Can edit and publish later
- **Publish**: Immediately active, can pause later
- **Validation Errors**: Show errors, prevent save

**Business Rules:**
- Merchant must be `ACTIVE` to create vouchers
- Minimum price: $1
- Maximum price: Based on merchant tier
- Stock cannot be negative

---

### 4. Edit Voucher Flow

**Purpose:** Update existing voucher

**Steps:**
1. **Select Voucher to Edit**
   - Merchant on "My Vouchers" screen
   - Clicks "Edit" on voucher card
   - Navigate to Edit Voucher Screen

2. **Load Voucher Data**
   - GET `/api/v1/vouchers/{id}`
   - Pre-fill form with existing data
   - Show current status

3. **Edit Voucher Details**
   - Modify any field (title, description, price, etc.)
   - Update image if needed
   - Change stock quantity
   - Update terms & conditions

4. **Save Changes**
   - PUT `/api/v1/vouchers/{id}`
   - Backend validates changes
   - Backend updates voucher

5. **Status Considerations:**
   - **DRAFT**: Can change anything
   - **ACTIVE**: Can update most fields (some restrictions may apply)
   - **PAUSED**: Can update and resume
   - **EXPIRED**: Cannot edit (read-only)

**Decision Points:**
- **Active Voucher**: Some changes may require republishing
- **Paused Voucher**: Can edit and resume
- **Draft Voucher**: Full editing allowed

---

### 5. Voucher Status Management Flow

**Purpose:** Pause, resume, or publish vouchers

**Steps:**
1. **Pause Voucher** (ACTIVE → PAUSED)
   - Merchant on "My Vouchers"
   - Selects ACTIVE voucher
   - Clicks "Pause" button
   - POST `/api/v1/vouchers/{id}/toggle-pause`
   - Backend updates status: `PAUSED`
   - Voucher no longer visible to consumers
   - Voucher cannot be purchased

2. **Resume Voucher** (PAUSED → ACTIVE)
   - Merchant selects PAUSED voucher
   - Clicks "Resume" button
   - POST `/api/v1/vouchers/{id}/toggle-pause`
   - Backend updates status: `ACTIVE`
   - Voucher visible to consumers again
   - Voucher can be purchased

3. **Publish Draft** (DRAFT → ACTIVE)
   - Merchant selects DRAFT voucher
   - Clicks "Publish" button
   - POST `/api/v1/vouchers/{id}/publish`
   - Backend updates status: `ACTIVE`
   - Voucher becomes available for purchase

**Decision Points:**
- **DRAFT**: Can only publish, cannot pause
- **ACTIVE**: Can pause, cannot publish (already published)
- **PAUSED**: Can resume, cannot publish

**Business Rules:**
- Cannot pause voucher with pending orders
- Cannot delete voucher with sales history
- Status changes are immediate

---

### 6. QR Scanner & Redemption Flow

**Purpose:** Redeem voucher at point of sale

**Steps:**
1. **Open QR Scanner**
   - Merchant on Dashboard
   - Clicks "Scan QR" or "Redeem Voucher"
   - Opens QR Scanner Screen
   - Camera activated

2. **Scan QR Code**
   - Merchant points camera at consumer's QR code
   - QR code contains voucher ID or redemption code
   - App decodes QR code

3. **Validate Voucher**
   - POST `/api/v1/redemptions` with:
     - `voucherCode` or `walletVoucherId`
     - `merchantId` (from authenticated merchant)
   - Backend validates:
     - Voucher exists
     - Voucher belongs to merchant (if merchant-specific)
     - Voucher is ACTIVE
     - Voucher not already redeemed
     - Voucher not expired

4. **Redemption Processing**
   - If valid:
     - Backend creates redemption record
     - Backend updates voucher status: `REDEEMED`
     - Backend updates wallet voucher status
     - Show success message
     - Send notification to consumer
   - If invalid:
     - Show error message
     - Display reason (expired, already redeemed, etc.)

5. **Manual Entry** (Alternative)
   - If QR scan fails
   - Merchant can manually enter voucher code
   - Same validation process

**Decision Points:**
- ✅ **Valid Voucher**: Process redemption, update status
- ❌ **Invalid Voucher**: Show error, prevent redemption
- ❌ **Wrong Merchant**: Show error if voucher not for this merchant

**Business Rules:**
- One redemption per voucher
- Redemption is final (no undo)
- Redemption timestamp recorded

---

### 7. Sales Dashboard Flow

**Purpose:** View sales statistics and analytics

**Steps:**
1. **Access Dashboard**
   - Merchant opens app
   - Lands on Dashboard (default screen)
   - GET `/api/v1/merchants/my-statistics`

2. **Display Statistics**
   - **Today's Sales**:
     - Revenue
     - Number of orders
     - Number of redemptions
   - **This Week/Month**:
     - Total revenue
     - Growth percentage
     - Top selling vouchers
   - **Charts**:
     - Revenue over time (line chart)
     - Sales by voucher (bar chart)
     - Redemption rate

3. **Recent Transactions**
   - GET `/api/v1/orders?merchantId={id}`
   - Display recent orders:
     - Order number
     - Voucher title
     - Amount
     - Date
     - Status

4. **Filter & Date Range**
   - Filter by date range
   - Filter by voucher
   - Filter by status
   - Export data (if available)

**Decision Points:**
- **No Sales**: Show "No sales yet" with encouragement
- **Data Available**: Display charts and statistics

---

### 8. Transaction Management Flow

**Purpose:** View and manage transactions

**Steps:**
1. **Access Transactions**
   - Merchant navigates to "Transactions" or "Sales History"
   - GET `/api/v1/orders?merchantId={id}&page=0&size=20`

2. **Transaction List**
   - Display transactions with:
     - Order number
     - Voucher title
     - Customer (if available)
     - Amount
     - Commission (8%)
     - Payout amount (92%)
     - Date
     - Status

3. **Transaction Details**
   - Tap transaction to view details
   - GET `/api/v1/orders/{id}`
   - Display:
     - Full order details
     - Payment method
     - Commission breakdown
     - Payout information

4. **Filter & Search**
   - Filter by date range
   - Filter by status
   - Search by order number
   - Sort by date, amount

**Decision Points:**
- **Empty List**: Show "No transactions" message
- **Filter Applied**: Show active filters

---

### 9. Payout Tracking Flow

**Purpose:** Track merchant payouts

**Steps:**
1. **Access Payouts**
   - Merchant navigates to "Payouts" or "Earnings"
   - GET `/api/v1/payouts?merchantId={id}`

2. **Payout List**
   - Display payouts with:
     - Payout ID
     - Period (week/month)
     - Total amount
     - Status (PENDING, PROCESSING, COMPLETED, FAILED)
     - Date

3. **Payout Details**
   - Tap payout to view details
   - GET `/api/v1/payouts/{id}`
   - Display:
     - Breakdown of transactions
     - Commission deducted
     - Net payout amount
     - Bank account
     - Status timeline

4. **Payout Schedule**
   - Weekly automated payouts
   - Payout day: Every Monday (or configured day)
   - Processing time: 1-3 business days

**Decision Points:**
- **Pending**: Awaiting processing
- **Processing**: In progress
- **Completed**: Funds transferred
- **Failed**: Contact support

**Business Rules:**
- Minimum payout threshold: $50 (configurable)
- Commission: 8% deducted automatically
- Payout: 92% to merchant

---

## 👨‍💼 Admin Business Flows

### 1. Login & Authentication Flow

**Purpose:** Authenticate admin user

**Steps:**
1. **Admin Opens Portal**
   - Opens Admin Portal (http://localhost:4200)
   - Shows Login Screen

2. **Login**
   - Enter Email: `admin@kado24.com`
   - Enter Password: `Admin@123456`
   - Click "Login"

3. **Submit Login**
   - POST `/api/v1/auth/login`
   - Backend validates credentials
   - Check role: `ADMIN`
   - Check status: `ACTIVE`

4. **Login Success**
   - Generate JWT tokens
   - Store tokens
   - Navigate to Admin Dashboard

**Decision Points:**
- ❌ **Invalid Credentials**: Show error
- ❌ **Not Admin Role**: Access denied
- ✅ **Valid Admin**: Login successful

---

### 2. Merchant Approval Flow

**Purpose:** Review and approve/reject merchant applications

**Steps:**
1. **Access Pending Approvals**
   - Admin on Dashboard
   - Navigates to "Merchant Approvals" or "Pending Applications"
   - GET `/api/v1/admin/merchants/pending`

2. **View Merchant Applications**
   - Display list of pending merchants:
     - Business Name
     - Owner Name
     - Phone Number
     - Email
     - Registration Date
     - Documents Status

3. **Review Merchant Details**
   - Click merchant to view details
   - GET `/api/v1/admin/merchants/{id}`
   - Display:
     - Full business information
     - Uploaded documents
     - Business license
     - Tax ID
     - Bank account details
     - Location information

4. **Review Documents**
   - View uploaded documents
   - Verify business license
   - Check tax ID validity
   - Verify bank account

5. **Make Decision**
   - **Approve**:
     - POST `/api/v1/admin/merchants/{id}/approve`
     - Backend updates merchant status: `ACTIVE`
     - Backend updates user status: `ACTIVE` (if pending)
     - Notification sent to merchant
     - Merchant can now create vouchers
   - **Reject**:
     - POST `/api/v1/admin/merchants/{id}/reject`
     - Enter rejection reason
     - Backend updates merchant status: `REJECTED`
     - Notification sent to merchant with reason

6. **Approval Confirmation**
   - Show success message
   - Merchant removed from pending list
   - Added to active merchants list

**Decision Points:**
- ✅ **Approve**: Merchant activated, can create vouchers
- ❌ **Reject**: Merchant notified, can reapply
- ⏳ **Request More Info**: Contact merchant for additional documents

**Business Rules:**
- Review within 24-48 hours
- Rejection reason required
- Approved merchants can immediately create vouchers

---

### 3. User Verification Management Flow

**Purpose:** Manage consumer verification requests

**Steps:**
1. **Access Verification Requests**
   - Admin navigates to "User Verifications" or "Verification Requests"
   - GET `/api/v1/admin/verifications/pending`

2. **View Pending Verifications**
   - Display list of pending verifications:
     - User Name
     - Phone Number
     - Registration Date
     - Verification Method (OTP, Manual)
     - OTP Code (for admin support)
     - Status

3. **Review Verification Request**
   - Click request to view details
   - GET `/api/v1/admin/verifications/{id}`
   - Display:
     - User information
     - OTP code (if available)
     - Verification history
     - Notes

4. **Verify User**
   - **Approve Verification**:
     - POST `/api/v1/admin/verifications/{id}/verify`
     - Backend updates user status: `ACTIVE`
     - Backend updates verification request status: `VERIFIED`
     - Backend marks phone as verified
     - Notification sent to user
   - **Reject Verification**:
     - POST `/api/v1/admin/verifications/{id}/reject`
     - Enter rejection reason
     - Backend updates verification request status: `REJECTED`
     - User remains `PENDING_VERIFICATION`
     - Notification sent to user

5. **Verification Statistics**
   - View verification statistics:
     - Total pending
     - Verified today
     - Rejected today
     - Average verification time

**Decision Points:**
- ✅ **Verify**: User activated, can use platform
- ❌ **Reject**: User remains pending, can retry
- **Bulk Actions**: Verify/reject multiple users

**Business Rules:**
- Admin can override OTP verification
- Rejection reason optional but recommended
- Verification history tracked

---

### 4. Platform Monitoring Flow

**Purpose:** Monitor platform health and activity

**Steps:**
1. **Access Dashboard**
   - Admin opens Admin Portal
   - Lands on Dashboard
   - GET `/api/v1/admin/dashboard`

2. **Platform Statistics**
   - **Users**:
     - Total users
     - Active users
     - New registrations (today/week/month)
   - **Merchants**:
     - Total merchants
     - Active merchants
     - Pending approvals
   - **Transactions**:
     - Total revenue
     - Today's revenue
     - Commission earned
   - **Vouchers**:
     - Total vouchers
     - Active vouchers
     - Redemptions today

3. **Activity Feed**
   - Recent registrations
   - Recent transactions
   - Recent redemptions
   - System events

4. **Charts & Analytics**
   - Revenue trends
   - User growth
   - Merchant growth
   - Top performing merchants
   - Popular voucher categories

**Decision Points:**
- **Anomalies Detected**: Flag for review
- **High Activity**: Monitor for performance
- **Low Activity**: Investigate issues

---

### 5. Analytics & Reporting Flow

**Purpose:** Generate reports and analyze platform data

**Steps:**
1. **Access Analytics**
   - Admin navigates to "Analytics" or "Reports"
   - GET `/api/v1/admin/analytics`

2. **Select Report Type**
   - **Revenue Reports**:
     - Daily, weekly, monthly revenue
     - Commission breakdown
     - Payout summaries
   - **User Reports**:
     - Registration trends
     - Active user counts
     - User retention
   - **Merchant Reports**:
     - Merchant performance
     - Top merchants
     - Merchant growth
   - **Voucher Reports**:
     - Best selling vouchers
     - Category performance
     - Redemption rates

3. **Set Date Range**
   - Select start date
   - Select end date
   - Apply filters

4. **Generate Report**
   - Backend queries analytics data
   - Aggregates data by date/category
   - Returns report data

5. **View Report**
   - Display charts
   - Display tables
   - Export to CSV/PDF (if available)

**Decision Points:**
- **Custom Reports**: Create custom date ranges
- **Export**: Download reports for external analysis

---

### 6. Fraud Detection Flow

**Purpose:** Detect and handle fraudulent activity

**Steps:**
1. **Access Fraud Alerts**
   - Admin navigates to "Fraud Detection" or "Alerts"
   - GET `/api/v1/admin/fraud-alerts`

2. **View Alerts**
   - Display fraud alerts:
     - Alert type
     - User/Merchant involved
     - Severity
     - Date
     - Status

3. **Review Alert**
   - Click alert to view details
   - Review transaction history
   - Review user behavior
   - Check for patterns

4. **Take Action**
   - **False Positive**: Dismiss alert
   - **Suspend User/Merchant**: Temporarily suspend
   - **Block Account**: Permanently block
   - **Investigate Further**: Flag for manual review

5. **Alert Resolution**
   - Update alert status
   - Add notes
   - Track resolution

**Decision Points:**
- **High Severity**: Immediate action required
- **Medium Severity**: Review within 24 hours
- **Low Severity**: Monitor and review

---

## 🔄 Cross-Role Interactions

### Consumer ↔ Merchant Interaction

**Purchase Flow:**
1. Consumer browses vouchers
2. Consumer purchases voucher
3. Order created, payment processed
4. Voucher added to consumer wallet
5. Merchant receives notification of sale
6. Commission calculated (8% platform, 92% merchant)

**Redemption Flow:**
1. Consumer shows QR code at merchant location
2. Merchant scans QR code
3. Redemption processed
4. Consumer notified of redemption
5. Merchant sees redemption in dashboard

### Admin ↔ Merchant Interaction

**Approval Flow:**
1. Merchant registers
2. Admin reviews application
3. Admin approves/rejects
4. Merchant notified
5. Merchant can create vouchers (if approved)

**Monitoring Flow:**
1. Admin monitors merchant activity
2. Admin views merchant performance
3. Admin can suspend merchant if needed
4. Merchant notified of any actions

### Admin ↔ Consumer Interaction

**Verification Flow:**
1. Consumer registers
2. Consumer receives OTP
3. If OTP fails, admin can verify manually
4. Admin verifies consumer
5. Consumer account activated

**Support Flow:**
1. Consumer contacts support
2. Admin views consumer account
3. Admin resolves issue
4. Consumer notified

---

## 📊 Business Rules Summary

### Commission Model
- **Platform Commission**: 8% of voucher sale
- **Merchant Payout**: 92% of voucher sale
- **Payout Schedule**: Weekly (every Monday)
- **Minimum Payout**: $50 (configurable)

### Voucher Statuses
- **DRAFT**: Created but not published
- **ACTIVE**: Available for purchase
- **PAUSED**: Temporarily unavailable
- **EXPIRED**: Past expiration date
- **SOLD_OUT**: No stock remaining

### User Statuses
- **PENDING_VERIFICATION**: Awaiting OTP or admin verification
- **ACTIVE**: Can use platform
- **SUSPENDED**: Temporarily blocked
- **DELETED**: Account removed

### Merchant Statuses
- **PENDING_APPROVAL**: Awaiting admin review
- **ACTIVE**: Can create vouchers
- **REJECTED**: Application rejected
- **SUSPENDED**: Temporarily blocked

### Order Statuses
- **PENDING_PAYMENT**: Awaiting payment
- **PAID**: Payment received, voucher in wallet
- **CANCELLED**: Order cancelled
- **REFUNDED**: Payment refunded

### Redemption Statuses
- **PENDING**: Redemption initiated
- **COMPLETED**: Voucher redeemed
- **DISPUTED**: Redemption disputed
- **CANCELLED**: Redemption cancelled

---

## 🔐 Security & Compliance

### Authentication
- JWT tokens for all authenticated requests
- Token expiration: 24 hours (configurable)
- Refresh tokens for extended sessions
- Token blacklisting on logout

### Verification
- OTP verification for phone numbers
- Email verification (optional)
- Admin manual verification (backup)
- Verification requests stored for audit

### Data Privacy
- User data encrypted
- Payment information secured
- Personal information protected
- GDPR compliance (if applicable)

---

**Document Version:** 2.0.0  
**Last Updated:** November 2025  
**Status:** ✅ Complete

