-- =============================================
-- Kado24 Platform - Multi-Schema Database
-- PostgreSQL 17 - Microservices Architecture
-- Each service has its own schema for isolation
-- Version: 2.0.0
-- =============================================

-- Enable required extensions (database level)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For full-text search

-- =============================================
-- CREATE SCHEMAS FOR EACH MICROSERVICE
-- =============================================

CREATE SCHEMA IF NOT EXISTS auth_schema;
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE SCHEMA IF NOT EXISTS merchant_schema;
CREATE SCHEMA IF NOT EXISTS voucher_schema;
CREATE SCHEMA IF NOT EXISTS order_schema;
CREATE SCHEMA IF NOT EXISTS wallet_schema;
CREATE SCHEMA IF NOT EXISTS redemption_schema;
CREATE SCHEMA IF NOT EXISTS notification_schema;
CREATE SCHEMA IF NOT EXISTS payout_schema;
CREATE SCHEMA IF NOT EXISTS analytics_schema;
CREATE SCHEMA IF NOT EXISTS admin_schema;
CREATE SCHEMA IF NOT EXISTS system_schema;  -- For system-wide configuration and reference data

COMMENT ON SCHEMA auth_schema IS 'Authentication & Authorization Service Schema';
COMMENT ON SCHEMA user_schema IS 'User Management Service Schema';
COMMENT ON SCHEMA merchant_schema IS 'Merchant Management Service Schema';
COMMENT ON SCHEMA voucher_schema IS 'Voucher Service Schema';
COMMENT ON SCHEMA order_schema IS 'Order Processing Service Schema';
COMMENT ON SCHEMA wallet_schema IS 'Wallet Service Schema';
COMMENT ON SCHEMA redemption_schema IS 'Redemption Service Schema';
COMMENT ON SCHEMA notification_schema IS 'Notification Service Schema';
COMMENT ON SCHEMA payout_schema IS 'Payout Service Schema';
COMMENT ON SCHEMA analytics_schema IS 'Analytics Service Schema';
COMMENT ON SCHEMA admin_schema IS 'Admin Portal Service Schema';
COMMENT ON SCHEMA system_schema IS 'System-wide configuration and reference data';

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

GRANT USAGE ON SCHEMA auth_schema TO kado24_user;
GRANT USAGE ON SCHEMA user_schema TO kado24_user;
GRANT USAGE ON SCHEMA merchant_schema TO kado24_user;
GRANT USAGE ON SCHEMA voucher_schema TO kado24_user;
GRANT USAGE ON SCHEMA order_schema TO kado24_user;
GRANT USAGE ON SCHEMA wallet_schema TO kado24_user;
GRANT USAGE ON SCHEMA redemption_schema TO kado24_user;
GRANT USAGE ON SCHEMA notification_schema TO kado24_user;
GRANT USAGE ON SCHEMA payout_schema TO kado24_user;
GRANT USAGE ON SCHEMA analytics_schema TO kado24_user;
GRANT USAGE ON SCHEMA admin_schema TO kado24_user;
GRANT USAGE ON SCHEMA system_schema TO kado24_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA user_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA merchant_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA voucher_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA order_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wallet_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA redemption_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notification_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA payout_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA admin_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA system_schema TO kado24_user;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA user_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA merchant_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA voucher_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA order_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA wallet_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA redemption_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA notification_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA payout_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA analytics_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA admin_schema TO kado24_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA system_schema TO kado24_user;

-- =============================================
-- SYSTEM SCHEMA - System Configuration
-- =============================================

-- Note: Voucher Categories moved to voucher_schema (see VOUCHER SCHEMA section)

-- System Settings
CREATE TABLE system_schema.system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    value_type VARCHAR(20) DEFAULT 'STRING',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(255)
);

COMMENT ON TABLE system_schema.system_settings IS 'Platform-wide configuration settings';

-- =============================================
-- AUTH SCHEMA - Authentication & Authorization
-- =============================================

CREATE TABLE auth_schema.users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('CONSUMER', 'MERCHANT', 'ADMIN')),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING_VERIFICATION' 
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION', 'DELETED')),
    avatar_url VARCHAR(500),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    metadata JSONB,
    CONSTRAINT chk_contact CHECK (email IS NOT NULL OR phone_number IS NOT NULL),
    CONSTRAINT users_phone_role_unique UNIQUE (phone_number, role)
);

CREATE INDEX idx_auth_users_phone ON auth_schema.users(phone_number);
CREATE INDEX idx_auth_users_email ON auth_schema.users(email);
CREATE INDEX idx_auth_users_role ON auth_schema.users(role);
CREATE INDEX idx_auth_users_status ON auth_schema.users(status);

COMMENT ON TABLE auth_schema.users IS 'Core user authentication table (owned by auth-service)';

CREATE TABLE auth_schema.oauth2_clients (
    id VARCHAR(100) PRIMARY KEY,
    client_secret VARCHAR(255) NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    redirect_uris TEXT[],
    grant_types TEXT[],
    scopes TEXT[],
    access_token_validity INT DEFAULT 3600,
    refresh_token_validity INT DEFAULT 86400,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE auth_schema.oauth2_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,  -- Reference to auth_schema.users(id)
    access_token VARCHAR(500) UNIQUE NOT NULL,
    refresh_token VARCHAR(500) UNIQUE,
    token_type VARCHAR(20) DEFAULT 'Bearer',
    expires_at TIMESTAMP NOT NULL,
    scopes TEXT[],
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP
);

CREATE INDEX idx_auth_tokens_user ON auth_schema.oauth2_tokens(user_id);
CREATE INDEX idx_auth_tokens_access ON auth_schema.oauth2_tokens(access_token);
CREATE INDEX idx_auth_tokens_refresh ON auth_schema.oauth2_tokens(refresh_token);

-- Verification Requests (for OTP verification and admin support)
CREATE TABLE auth_schema.verification_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES auth_schema.users(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED')),
    verification_method VARCHAR(20) NOT NULL DEFAULT 'OTP',
        CHECK (verification_method IN ('OTP', 'MANUAL', 'AUTO')),
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP,
    verified_by BIGINT REFERENCES auth_schema.users(id),
    expires_at TIMESTAMP NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_verification_user_id ON auth_schema.verification_requests(user_id);
CREATE INDEX idx_verification_status ON auth_schema.verification_requests(status);
CREATE INDEX idx_verification_phone ON auth_schema.verification_requests(phone_number);
CREATE INDEX idx_verification_expires ON auth_schema.verification_requests(expires_at);

COMMENT ON TABLE auth_schema.verification_requests IS 'Stores OTP codes and verification requests for user account activation';
COMMENT ON COLUMN auth_schema.verification_requests.user_id IS 'Reference to the user account being verified';
COMMENT ON COLUMN auth_schema.verification_requests.otp_code IS '6-digit OTP code for verification';
COMMENT ON COLUMN auth_schema.verification_requests.status IS 'Current status: PENDING, VERIFIED, REJECTED, EXPIRED';
COMMENT ON COLUMN auth_schema.verification_requests.verification_method IS 'Method used: OTP (user), MANUAL (admin), AUTO (system)';
COMMENT ON COLUMN auth_schema.verification_requests.verified_by IS 'Admin user ID who verified the account (if manual)';
COMMENT ON COLUMN auth_schema.verification_requests.expires_at IS 'When the OTP expires (typically 5 minutes)';

-- OTP Codes Table (dedicated table for OTP storage)
CREATE TABLE auth_schema.otp_codes (
    id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    purpose VARCHAR(50) NOT NULL DEFAULT 'LOGIN_VERIFICATION',
        CHECK (purpose IN ('LOGIN_VERIFICATION', 'REGISTRATION', 'PASSWORD_RESET', 'PHONE_VERIFICATION')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        CHECK (status IN ('ACTIVE', 'USED', 'EXPIRED', 'INVALIDATED')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    attempts INT NOT NULL DEFAULT 0,
    max_attempts INT NOT NULL DEFAULT 5,
    metadata JSONB,
    CONSTRAINT chk_expires_after_created CHECK (expires_at > created_at)
);

CREATE INDEX idx_otp_phone_purpose ON auth_schema.otp_codes(phone_number, purpose);
CREATE INDEX idx_otp_status ON auth_schema.otp_codes(status);
CREATE INDEX idx_otp_expires ON auth_schema.otp_codes(expires_at);
CREATE INDEX idx_otp_created ON auth_schema.otp_codes(created_at DESC);

COMMENT ON TABLE auth_schema.otp_codes IS 'Stores OTP codes for various purposes (login, registration, password reset)';
COMMENT ON COLUMN auth_schema.otp_codes.phone_number IS 'Phone number the OTP was sent to';
COMMENT ON COLUMN auth_schema.otp_codes.otp_code IS '6-digit OTP code';
COMMENT ON COLUMN auth_schema.otp_codes.purpose IS 'Purpose of the OTP: LOGIN_VERIFICATION, REGISTRATION, PASSWORD_RESET, PHONE_VERIFICATION';
COMMENT ON COLUMN auth_schema.otp_codes.status IS 'Status: ACTIVE (can be used), USED (already verified), EXPIRED (time expired), INVALIDATED (too many attempts)';
COMMENT ON COLUMN auth_schema.otp_codes.expires_at IS 'When the OTP expires (typically 5 minutes from creation)';
COMMENT ON COLUMN auth_schema.otp_codes.attempts IS 'Number of verification attempts made';
COMMENT ON COLUMN auth_schema.otp_codes.max_attempts IS 'Maximum allowed verification attempts (default: 5)';

-- Function to automatically mark expired OTPs
CREATE OR REPLACE FUNCTION auth_schema.mark_expired_otps()
RETURNS void AS $$
BEGIN
    UPDATE auth_schema.otp_codes
    SET status = 'EXPIRED'
    WHERE status = 'ACTIVE'
      AND expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Function to get active OTP for phone and purpose
CREATE OR REPLACE FUNCTION auth_schema.get_active_otp(
    p_phone_number VARCHAR(20),
    p_purpose VARCHAR(50)
)
RETURNS TABLE (
    id BIGINT,
    otp_code VARCHAR(6),
    expires_at TIMESTAMP,
    attempts INT,
    max_attempts INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        oc.id,
        oc.otp_code,
        oc.expires_at,
        oc.attempts,
        oc.max_attempts
    FROM auth_schema.otp_codes oc
    WHERE oc.phone_number = p_phone_number
      AND oc.purpose = p_purpose
      AND oc.status = 'ACTIVE'
      AND oc.expires_at > CURRENT_TIMESTAMP
    ORDER BY oc.created_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION auth_schema.get_active_otp IS 'Returns the most recent active OTP for a phone number and purpose';

-- =============================================
-- USER SCHEMA - User Profiles & Preferences
-- =============================================

CREATE TABLE user_schema.user_profiles (
    user_id BIGINT PRIMARY KEY,  -- Links to auth_schema.users(id)
    bio TEXT,
    date_of_birth DATE,
    gender VARCHAR(20),
    preferred_language VARCHAR(10) DEFAULT 'km',
    preferred_currency VARCHAR(10) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'Asia/Phnom_Penh',
    notification_preferences JSONB,
    privacy_settings JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_schema.user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    address_type VARCHAR(20) CHECK (address_type IN ('HOME', 'WORK', 'OTHER')),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Cambodia',
    is_default BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_addresses_user ON user_schema.user_addresses(user_id);

COMMENT ON TABLE user_schema.user_profiles IS 'Extended user profile information (owned by user-service)';
COMMENT ON TABLE user_schema.user_addresses IS 'User saved addresses';

-- =============================================
-- MERCHANT SCHEMA - Merchant Management
-- =============================================

CREATE TABLE merchant_schema.merchants (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,  -- Links to auth_schema.users(id)
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(100),
    business_license VARCHAR(100),
    tax_id VARCHAR(50),
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    description TEXT,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED', 'ACTIVE')),
    approval_status VARCHAR(20),
    approved_by BIGINT,  -- Links to auth_schema.users(id)
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    total_sales DECIMAL(15,2) DEFAULT 0.00,
    total_redemptions INT DEFAULT 0,
    commission_rate DECIMAL(5,4) DEFAULT 0.0800,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_merchants_user ON merchant_schema.merchants(user_id);
CREATE INDEX idx_merchants_status ON merchant_schema.merchants(status);
CREATE INDEX idx_merchants_location ON merchant_schema.merchants(latitude, longitude);

COMMENT ON TABLE merchant_schema.merchants IS 'Merchant business information (owned by merchant-service)';

CREATE TABLE merchant_schema.merchant_locations (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchant_schema.merchants(id) ON DELETE CASCADE,
    location_name VARCHAR(255) NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    phone_number VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT FALSE,
    operating_hours JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_merchant_locations_merchant ON merchant_schema.merchant_locations(merchant_id);

CREATE TABLE merchant_schema.merchant_bank_accounts (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchant_schema.merchants(id) ON DELETE CASCADE,
    bank_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    account_holder_name VARCHAR(255) NOT NULL,
    bank_branch VARCHAR(100),
    swift_code VARCHAR(20),
    is_primary BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_merchant_bank_merchant ON merchant_schema.merchant_bank_accounts(merchant_id);

CREATE TABLE merchant_schema.merchant_documents (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchant_schema.merchants(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    document_number VARCHAR(100),
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_merchant_docs_merchant ON merchant_schema.merchant_documents(merchant_id);

-- =============================================
-- VOUCHER SCHEMA - Voucher Management
-- =============================================

-- Voucher Categories
CREATE TABLE voucher_schema.voucher_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    display_order INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_voucher_categories_active ON voucher_schema.voucher_categories(is_active);
CREATE INDEX idx_voucher_categories_name ON voucher_schema.voucher_categories(name);
CREATE INDEX idx_voucher_categories_slug ON voucher_schema.voucher_categories(slug);

COMMENT ON TABLE voucher_schema.voucher_categories IS 'Voucher categories (Food, Spa, Entertainment, etc.)';

CREATE TABLE voucher_schema.vouchers (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    category_id BIGINT,  -- Links to voucher_schema.voucher_categories(id)
    title VARCHAR(255) NOT NULL,
    description TEXT,
    terms_conditions TEXT,
    image_url TEXT,
    min_value DECIMAL(10,2) NOT NULL,
    max_value DECIMAL(10,2) NOT NULL,
    validity_months INT NOT NULL DEFAULT 12,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    total_sold INT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_voucher_value CHECK (min_value > 0 AND max_value >= min_value)
);

CREATE INDEX idx_vouchers_merchant ON voucher_schema.vouchers(merchant_id);
CREATE INDEX idx_vouchers_category ON voucher_schema.vouchers(category_id);
CREATE INDEX idx_vouchers_active ON voucher_schema.vouchers(is_active);
CREATE INDEX idx_vouchers_featured ON voucher_schema.vouchers(is_featured);

COMMENT ON TABLE voucher_schema.vouchers IS 'Voucher offerings created by merchants (owned by voucher-service)';

CREATE TABLE voucher_schema.reviews (
    id BIGSERIAL PRIMARY KEY,
    voucher_id BIGINT NOT NULL REFERENCES voucher_schema.vouchers(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[],
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_voucher ON voucher_schema.reviews(voucher_id);
CREATE INDEX idx_reviews_user ON voucher_schema.reviews(user_id);
CREATE INDEX idx_reviews_merchant ON voucher_schema.reviews(merchant_id);

-- =============================================
-- ORDER SCHEMA - Order Processing
-- =============================================

CREATE TABLE order_schema.orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    voucher_id BIGINT NOT NULL,  -- Links to voucher_schema.vouchers(id)
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    quantity INT NOT NULL DEFAULT 1,
    voucher_value DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    platform_commission DECIMAL(10,2) NOT NULL,
    merchant_earnings DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'PENDING' 
        CHECK (payment_status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED')),
    status VARCHAR(20) DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')),
    is_gift BOOLEAN DEFAULT FALSE,
    gift_recipient_phone VARCHAR(20),
    gift_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    CONSTRAINT chk_order_amount CHECK (total_amount > 0)
);

CREATE INDEX idx_orders_user ON order_schema.orders(user_id);
CREATE INDEX idx_orders_voucher ON order_schema.orders(voucher_id);
CREATE INDEX idx_orders_merchant ON order_schema.orders(merchant_id);
CREATE INDEX idx_orders_status ON order_schema.orders(status);
CREATE INDEX idx_orders_payment_status ON order_schema.orders(payment_status);
CREATE INDEX idx_orders_number ON order_schema.orders(order_number);

COMMENT ON TABLE order_schema.orders IS 'Purchase orders (owned by order-service)';

CREATE TABLE order_schema.transactions (
    id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    order_id BIGINT NOT NULL REFERENCES order_schema.orders(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(50),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED')),
    payment_provider_response JSONB,
    failure_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_transactions_order ON order_schema.transactions(order_id);
CREATE INDEX idx_transactions_user ON order_schema.transactions(user_id);
CREATE INDEX idx_transactions_status ON order_schema.transactions(status);

COMMENT ON TABLE order_schema.transactions IS 'Payment transactions (owned by order-service)';

-- =============================================
-- WALLET SCHEMA - Digital Wallet
-- =============================================

CREATE TABLE wallet_schema.wallet_vouchers (
    id BIGSERIAL PRIMARY KEY,
    voucher_code VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    order_id BIGINT,  -- Links to order_schema.orders(id)
    voucher_id BIGINT NOT NULL,  -- Links to voucher_schema.vouchers(id)
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    voucher_value DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
        CHECK (status IN ('ACTIVE', 'USED', 'EXPIRED', 'GIFTED', 'CANCELLED')),
    qr_code_data TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    purchased_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP,
    gifted_to_user_id BIGINT,  -- Links to auth_schema.users(id)
    gifted_at TIMESTAMP,
    gift_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wallet_user ON wallet_schema.wallet_vouchers(user_id);
CREATE INDEX idx_wallet_voucher ON wallet_schema.wallet_vouchers(voucher_id);
CREATE INDEX idx_wallet_code ON wallet_schema.wallet_vouchers(voucher_code);
CREATE INDEX idx_wallet_status ON wallet_schema.wallet_vouchers(status);
CREATE INDEX idx_wallet_expires ON wallet_schema.wallet_vouchers(expires_at);

COMMENT ON TABLE wallet_schema.wallet_vouchers IS 'User voucher wallet (owned by wallet-service)';

-- =============================================
-- REDEMPTION SCHEMA - Voucher Redemption
-- =============================================

CREATE TABLE redemption_schema.redemptions (
    id BIGSERIAL PRIMARY KEY,
    redemption_code VARCHAR(50) UNIQUE NOT NULL,
    wallet_voucher_id BIGINT NOT NULL,  -- Links to wallet_schema.wallet_vouchers(id)
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    voucher_id BIGINT NOT NULL,  -- Links to voucher_schema.vouchers(id)
    merchant_location_id BIGINT,  -- Links to merchant_schema.merchant_locations(id)
    redeemed_value DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'DISPUTED')),
    redemption_type VARCHAR(20) CHECK (redemption_type IN ('QR_SCAN_MERCHANT', 'QR_SCAN_CUSTOMER', 'MANUAL')),
    notes TEXT,
    metadata JSONB,
    redeemed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE INDEX idx_redemptions_wallet_voucher ON redemption_schema.redemptions(wallet_voucher_id);
CREATE INDEX idx_redemptions_user ON redemption_schema.redemptions(user_id);
CREATE INDEX idx_redemptions_merchant ON redemption_schema.redemptions(merchant_id);
CREATE INDEX idx_redemptions_status ON redemption_schema.redemptions(status);
CREATE INDEX idx_redemptions_date ON redemption_schema.redemptions(redeemed_at);

COMMENT ON TABLE redemption_schema.redemptions IS 'Voucher redemption transactions (owned by redemption-service)';

CREATE TABLE redemption_schema.disputes (
    id BIGSERIAL PRIMARY KEY,
    dispute_number VARCHAR(50) UNIQUE NOT NULL,
    redemption_id BIGINT REFERENCES redemption_schema.redemptions(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    reason TEXT NOT NULL,
    user_evidence TEXT[],
    merchant_response TEXT,
    merchant_evidence TEXT[],
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED')),
    resolution VARCHAR(20) CHECK (resolution IN ('USER_FAVOR', 'MERCHANT_FAVOR', 'PARTIAL_REFUND', 'NO_ACTION')),
    resolved_by BIGINT,  -- Links to auth_schema.users(id)
    resolved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_disputes_redemption ON redemption_schema.disputes(redemption_id);
CREATE INDEX idx_disputes_user ON redemption_schema.disputes(user_id);
CREATE INDEX idx_disputes_merchant ON redemption_schema.disputes(merchant_id);

-- =============================================
-- NOTIFICATION SCHEMA - Notifications
-- =============================================

CREATE TABLE notification_schema.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    notification_type VARCHAR(50) NOT NULL,
    channel VARCHAR(20) CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    template_name VARCHAR(100),
    template_data JSONB,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'DELIVERED', 'READ')),
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    failure_reason TEXT,
    provider VARCHAR(50),
    provider_message_id VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notification_schema.notifications(user_id);
CREATE INDEX idx_notifications_status ON notification_schema.notifications(status);
CREATE INDEX idx_notifications_channel ON notification_schema.notifications(channel);
CREATE INDEX idx_notifications_created ON notification_schema.notifications(created_at);

COMMENT ON TABLE notification_schema.notifications IS 'Email, SMS, Push notifications (owned by notification-service)';

CREATE TABLE notification_schema.support_tickets (
    id BIGSERIAL PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,  -- Links to auth_schema.users(id)
    category VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    assigned_to BIGINT,  -- Links to auth_schema.users(id) (admin)
    resolution TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE INDEX idx_tickets_user ON notification_schema.support_tickets(user_id);
CREATE INDEX idx_tickets_status ON notification_schema.support_tickets(status);
CREATE INDEX idx_tickets_number ON notification_schema.support_tickets(ticket_number);

-- =============================================
-- PAYOUT SCHEMA - Merchant Payouts
-- =============================================

CREATE TABLE payout_schema.payouts (
    id BIGSERIAL PRIMARY KEY,
    payout_number VARCHAR(50) UNIQUE NOT NULL,
    merchant_id BIGINT NOT NULL,  -- Links to merchant_schema.merchants(id)
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_revenue DECIMAL(15,2) NOT NULL,
    platform_commission DECIMAL(15,2) NOT NULL,
    payout_amount DECIMAL(15,2) NOT NULL,
    redemption_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    bank_account_id BIGINT,  -- Links to merchant_schema.merchant_bank_accounts(id)
    transfer_reference VARCHAR(100),
    transfer_date DATE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP
);

CREATE INDEX idx_payouts_merchant ON payout_schema.payouts(merchant_id);
CREATE INDEX idx_payouts_status ON payout_schema.payouts(status);
CREATE INDEX idx_payouts_period ON payout_schema.payouts(period_start, period_end);

COMMENT ON TABLE payout_schema.payouts IS 'Merchant payout batches (owned by payout-service)';

CREATE TABLE payout_schema.payout_items (
    id BIGSERIAL PRIMARY KEY,
    payout_id BIGINT NOT NULL REFERENCES payout_schema.payouts(id) ON DELETE CASCADE,
    redemption_id BIGINT NOT NULL,  -- Links to redemption_schema.redemptions(id)
    voucher_value DECIMAL(10,2) NOT NULL,
    commission DECIMAL(10,2) NOT NULL,
    merchant_amount DECIMAL(10,2) NOT NULL,
    redemption_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payout_items_payout ON payout_schema.payout_items(payout_id);
CREATE INDEX idx_payout_items_redemption ON payout_schema.payout_items(redemption_id);

CREATE TABLE payout_schema.payout_holds (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'RELEASED')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP
);

CREATE INDEX idx_payout_holds_merchant ON payout_schema.payout_holds(merchant_id);
CREATE INDEX idx_payout_holds_status ON payout_schema.payout_holds(status);

-- =============================================
-- ANALYTICS SCHEMA - Reports & Analytics
-- =============================================

CREATE TABLE analytics_schema.daily_metrics (
    id BIGSERIAL PRIMARY KEY,
    metric_date DATE NOT NULL,
    total_users INT DEFAULT 0,
    new_users INT DEFAULT 0,
    active_users INT DEFAULT 0,
    total_merchants INT DEFAULT 0,
    new_merchants INT DEFAULT 0,
    active_merchants INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    total_commission DECIMAL(15,2) DEFAULT 0.00,
    total_redemptions INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(metric_date)
);

CREATE INDEX idx_daily_metrics_date ON analytics_schema.daily_metrics(metric_date);

COMMENT ON TABLE analytics_schema.daily_metrics IS 'Daily aggregated metrics (owned by analytics-service)';

-- =============================================
-- ADMIN SCHEMA - Admin Portal
-- =============================================

CREATE TABLE admin_schema.fraud_alerts (
    id BIGSERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    user_id BIGINT,  -- Links to auth_schema.users(id)
    merchant_id BIGINT,  -- Links to merchant_schema.merchants(id)
    description TEXT NOT NULL,
    details JSONB,
    status VARCHAR(20) DEFAULT 'NEW' CHECK (status IN ('NEW', 'INVESTIGATING', 'RESOLVED', 'FALSE_POSITIVE')),
    investigated_by BIGINT,  -- Links to auth_schema.users(id)
    resolution_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE INDEX idx_fraud_alerts_status ON admin_schema.fraud_alerts(status);
CREATE INDEX idx_fraud_alerts_severity ON admin_schema.fraud_alerts(severity);
CREATE INDEX idx_fraud_alerts_user ON admin_schema.fraud_alerts(user_id);

COMMENT ON TABLE admin_schema.fraud_alerts IS 'Fraud detection alerts (owned by admin-portal-backend)';

CREATE TABLE admin_schema.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,  -- Links to auth_schema.users(id)
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON admin_schema.audit_logs(user_id);
CREATE INDEX idx_audit_entity ON admin_schema.audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON admin_schema.audit_logs(created_at);
CREATE INDEX idx_audit_action ON admin_schema.audit_logs(action);

COMMENT ON TABLE admin_schema.audit_logs IS 'System audit trail (owned by admin-portal-backend)';

-- =============================================
-- FILE UPLOADS (Shared)
-- =============================================

CREATE TABLE system_schema.file_uploads (
    id BIGSERIAL PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    uploader_id BIGINT,  -- Links to auth_schema.users(id)
    entity_type VARCHAR(50),
    entity_id BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_uploads_uploader ON system_schema.file_uploads(uploader_id);
CREATE INDEX idx_uploads_entity ON system_schema.file_uploads(entity_type, entity_id);

-- =============================================
-- INSERT SEED DATA
-- =============================================

-- Voucher Categories
INSERT INTO voucher_schema.voucher_categories (name, display_name, icon, color, sort_order) VALUES
('food-beverage', 'Food & Beverage', '🍽️', '#FF5722', 1),
('spa-wellness', 'Spa & Wellness', '💆', '#9C27B0', 2),
('entertainment', 'Entertainment', '🎭', '#2196F3', 3),
('shopping', 'Shopping', '🛍️', '#4CAF50', 4),
('travel', 'Travel & Hotels', '✈️', '#FF9800', 5),
('services', 'Services', '🔧', '#607D8B', 6);

-- System Settings
INSERT INTO system_schema.system_settings (key, value, value_type, description, is_public) VALUES
('platform.commission_rate', '0.08', 'DECIMAL', 'Platform commission rate (8%)', FALSE),
('platform.currency', 'USD', 'STRING', 'Default platform currency', TRUE),
('platform.timezone', 'Asia/Phnom_Penh', 'STRING', 'Platform timezone', TRUE);

-- Create Admin User in auth schema
INSERT INTO auth_schema.users (full_name, phone_number, email, password_hash, role, status, email_verified, phone_verified)
VALUES (
    'Platform Administrator',
    '+85512000000',
    'admin@kado24.com',
    '$2a$10$rZ5jYhF5YJ5h5YqGqE7hOeN9X4YrYqW4YqGqE7hOeN9X4YrYqW4Yq',  -- Admin@123456
    'ADMIN',
    'ACTIVE',
    TRUE,
    TRUE
);

-- OAuth2 Clients
INSERT INTO auth_schema.oauth2_clients (id, client_secret, client_name, grant_types, scopes) VALUES
('consumer-app', '$2a$10$secrethash', 'Kado24 Consumer App', ARRAY['password', 'refresh_token'], ARRAY['read', 'write']),
('merchant-app', '$2a$10$secrethash', 'Kado24 Merchant App', ARRAY['password', 'refresh_token'], ARRAY['read', 'write']),
('admin-portal', '$2a$10$secrethash', 'Kado24 Admin Portal', ARRAY['password', 'refresh_token'], ARRAY['read', 'write', 'admin']);

-- =============================================
-- CREATE VIEWS FOR CROSS-SCHEMA QUERIES
-- =============================================

-- View for merchant summary (joins across schemas)
CREATE VIEW analytics_schema.merchant_performance AS
SELECT 
    m.id AS merchant_id,
    m.business_name,
    m.rating_average,
    m.rating_count,
    m.total_sales,
    m.total_redemptions,
    COUNT(DISTINCT o.id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS revenue,
    COALESCE(SUM(o.platform_commission), 0) AS commission_paid,
    COALESCE(SUM(r.redeemed_value), 0) AS redemption_value,
    COUNT(DISTINCT r.id) AS redemption_count
FROM merchant_schema.merchants m
LEFT JOIN order_schema.orders o ON m.id = o.merchant_id AND o.status = 'COMPLETED'
LEFT JOIN redemption_schema.redemptions r ON m.id = r.merchant_id AND r.status = 'CONFIRMED'
GROUP BY m.id, m.business_name, m.rating_average, m.rating_count, m.total_sales, m.total_redemptions;

COMMENT ON VIEW analytics_schema.merchant_performance IS 'Merchant performance metrics aggregated across schemas';

-- View for platform overview  
CREATE VIEW analytics_schema.platform_overview AS
SELECT 
    (SELECT COUNT(*) FROM auth_schema.users WHERE role = 'CONSUMER') AS total_consumers,
    (SELECT COUNT(*) FROM auth_schema.users WHERE role = 'MERCHANT') AS total_merchants,
    (SELECT COUNT(*) FROM merchant_schema.merchants WHERE status = 'ACTIVE') AS active_merchants,
    (SELECT COUNT(*) FROM voucher_schema.vouchers WHERE is_active = TRUE) AS active_vouchers,
    (SELECT COUNT(*) FROM order_schema.orders WHERE status = 'COMPLETED') AS completed_orders,
    (SELECT COALESCE(SUM(total_amount), 0) FROM order_schema.orders WHERE status = 'COMPLETED') AS total_gmv,
    (SELECT COALESCE(SUM(platform_commission), 0) FROM order_schema.orders WHERE status = 'COMPLETED') AS platform_revenue,
    (SELECT COUNT(*) FROM redemption_schema.redemptions WHERE status = 'CONFIRMED') AS total_redemptions;

COMMENT ON VIEW analytics_schema.platform_overview IS 'Platform-wide metrics overview';

-- =============================================
-- GRANT PERMISSIONS ON TABLES
-- =============================================

-- Grant permissions on future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA auth_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA merchant_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA voucher_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA order_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA wallet_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA redemption_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA notification_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payout_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA admin_schema GRANT ALL ON TABLES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA system_schema GRANT ALL ON TABLES TO kado24_user;

-- Grant permissions on future sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA auth_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA user_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA merchant_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA voucher_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA order_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA wallet_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA redemption_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA notification_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payout_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA admin_schema GRANT ALL ON SEQUENCES TO kado24_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA system_schema GRANT ALL ON SEQUENCES TO kado24_user;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Kado24 multi-schema database initialized successfully!';
    RAISE NOTICE '📊 Created 11 schemas with proper table separation';
    RAISE NOTICE '🔐 Admin credentials: admin@kado24.com / Admin@123456';
    RAISE NOTICE '📋 Schemas: auth, user, merchant, voucher, order, wallet, redemption, notification, payout, analytics, admin, shared';
END $$;










