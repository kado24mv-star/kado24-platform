-- =============================================
-- Kado24 Platform - Database Schema
-- PostgreSQL 17
-- Version: 1.0.0
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For full-text search
-- CREATE EXTENSION IF NOT EXISTS "postgis";  -- For geospatial queries (optional) - DISABLED: Not available in alpine image

-- =============================================
-- USERS & AUTHENTICATION
-- =============================================

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
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
    CONSTRAINT chk_contact CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_metadata ON users USING GIN (metadata);

COMMENT ON TABLE users IS 'Core user table for all platform users (consumers, merchants, admins)';
COMMENT ON COLUMN users.role IS 'User role: CONSUMER (app user), MERCHANT (business), ADMIN (platform operator)';
COMMENT ON COLUMN users.status IS 'Account status for access control';

-- OAuth2 Clients
CREATE TABLE oauth2_clients (
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

COMMENT ON TABLE oauth2_clients IS 'OAuth2 registered clients (mobile apps, admin portal)';

-- OAuth2 Tokens
CREATE TABLE oauth2_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token VARCHAR(500) UNIQUE NOT NULL,
    refresh_token VARCHAR(500) UNIQUE,
    token_type VARCHAR(20) DEFAULT 'Bearer',
    expires_at TIMESTAMP NOT NULL,
    scopes TEXT[],
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP
);

CREATE INDEX idx_tokens_user ON oauth2_tokens(user_id);
CREATE INDEX idx_tokens_access ON oauth2_tokens(access_token);
CREATE INDEX idx_tokens_refresh ON oauth2_tokens(refresh_token);
CREATE INDEX idx_tokens_expires ON oauth2_tokens(expires_at);

-- =============================================
-- MERCHANTS
-- =============================================

CREATE TABLE merchants (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(100),
    business_license VARCHAR(100),
    tax_id VARCHAR(50),
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    description TEXT,
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(2) DEFAULT 'KH',
    
    -- Geolocation
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Bank Details
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_name VARCHAR(255),
    
    -- Status & Verification
    verification_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED')),
    verified_at TIMESTAMP,
    verified_by BIGINT REFERENCES users(id),
    rejection_reason TEXT,
    
    -- Metrics
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INT DEFAULT 0,
    total_vouchers_sold INT DEFAULT 0,
    total_revenue DECIMAL(15, 2) DEFAULT 0.00,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    metadata JSONB
);

CREATE INDEX idx_merchants_user ON merchants(user_id);
CREATE INDEX idx_merchants_status ON merchants(verification_status);
CREATE INDEX idx_merchants_business_name ON merchants USING GIN (to_tsvector('english', business_name));
CREATE INDEX idx_merchants_location ON merchants(latitude, longitude);

COMMENT ON TABLE merchants IS 'Merchant business profiles and verification details';
COMMENT ON COLUMN merchants.verification_status IS 'Admin approval status: PENDING (awaiting review), APPROVED (active), REJECTED (denied), SUSPENDED (temporary ban)';

-- Merchant Documents
CREATE TABLE merchant_documents (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_merchant_docs_merchant ON merchant_documents(merchant_id);

COMMENT ON TABLE merchant_documents IS 'Supporting documents for merchant verification (licenses, tax certificates, ID)';

-- =============================================
-- VOUCHERS
-- =============================================

CREATE TABLE voucher_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_slug ON voucher_categories(slug);
CREATE INDEX idx_categories_active ON voucher_categories(is_active, display_order);

CREATE TABLE vouchers (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES voucher_categories(id),
    
    -- Basic Info
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    terms_and_conditions TEXT,
    
    -- Pricing
    denominations DECIMAL(10, 2)[] NOT NULL,
    discount_percentage DECIMAL(5, 2),
    
    -- Media
    image_url VARCHAR(500),
    additional_images TEXT[],
    
    -- Availability
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' 
        CHECK (status IN ('DRAFT', 'ACTIVE', 'PAUSED', 'EXPIRED', 'DELETED')),
    stock_quantity INT,
    unlimited_stock BOOLEAN DEFAULT FALSE,
    
    -- Validity
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    redemption_locations TEXT[],
    
    -- Restrictions
    min_purchase_amount DECIMAL(10, 2),
    max_purchase_per_user INT,
    usage_instructions TEXT,
    
    -- Metrics
    total_sold INT DEFAULT 0,
    total_redeemed INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INT DEFAULT 0,
    view_count INT DEFAULT 0,
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    search_vector TSVECTOR,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    
    metadata JSONB,
    
    CONSTRAINT chk_voucher_validity CHECK (valid_from IS NULL OR valid_until IS NULL OR valid_from < valid_until),
    CONSTRAINT chk_stock CHECK (unlimited_stock = TRUE OR stock_quantity IS NOT NULL)
);

CREATE INDEX idx_vouchers_merchant ON vouchers(merchant_id);
CREATE INDEX idx_vouchers_category ON vouchers(category_id);
CREATE INDEX idx_vouchers_status ON vouchers(status);
CREATE INDEX idx_vouchers_validity ON vouchers(valid_from, valid_until);
CREATE INDEX idx_vouchers_search ON vouchers USING GIN (search_vector);
CREATE INDEX idx_vouchers_slug ON vouchers(slug);
CREATE INDEX idx_vouchers_rating ON vouchers(rating DESC);

COMMENT ON TABLE vouchers IS 'Voucher products offered by merchants';
COMMENT ON COLUMN vouchers.denominations IS 'Available voucher values in USD (e.g., {5.00, 10.00, 25.00, 50.00})';
COMMENT ON COLUMN vouchers.status IS 'DRAFT (not published), ACTIVE (available), PAUSED (temporarily unavailable), EXPIRED (past validity), DELETED (soft delete)';

-- Trigger to update search_vector
CREATE OR REPLACE FUNCTION vouchers_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.terms_and_conditions, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_vouchers_search_update
    BEFORE INSERT OR UPDATE OF title, description, terms_and_conditions ON vouchers
    FOR EACH ROW EXECUTE FUNCTION vouchers_search_vector_update();

-- =============================================
-- ORDERS & TRANSACTIONS
-- =============================================

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id),
    voucher_id BIGINT NOT NULL REFERENCES vouchers(id),
    merchant_id BIGINT NOT NULL REFERENCES merchants(id),
    
    -- Pricing
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    denomination DECIMAL(10, 2) NOT NULL CHECK (denomination > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal > 0),
    platform_fee DECIMAL(10, 2) NOT NULL CHECK (platform_fee >= 0),
    merchant_amount DECIMAL(10, 2) NOT NULL CHECK (merchant_amount >= 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount > 0),
    
    -- Payment
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (payment_status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED')),
    payment_id VARCHAR(255),
    paid_at TIMESTAMP,
    
    -- Order Status
    order_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (order_status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'REFUNDED')),
    
    -- Metadata
    customer_notes TEXT,
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_order_amounts CHECK (subtotal = quantity * denomination)
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_merchant ON orders(merchant_id);
CREATE INDEX idx_orders_voucher ON orders(voucher_id);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(order_status, payment_status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_orders_payment_method ON orders(payment_method);

COMMENT ON TABLE orders IS 'Customer purchase orders with payment tracking';
COMMENT ON COLUMN orders.platform_fee IS '8% commission to Kado24 platform';
COMMENT ON COLUMN orders.merchant_amount IS '92% payout amount to merchant';

-- =============================================
-- WALLET & PURCHASED VOUCHERS
-- =============================================

CREATE TABLE wallet_vouchers (
    id BIGSERIAL PRIMARY KEY,
    voucher_code VARCHAR(50) UNIQUE NOT NULL,
    qr_code_url VARCHAR(500),
    
    user_id BIGINT NOT NULL REFERENCES users(id),
    voucher_id BIGINT NOT NULL REFERENCES vouchers(id),
    order_id BIGINT NOT NULL REFERENCES orders(id),
    merchant_id BIGINT NOT NULL REFERENCES merchants(id),
    
    -- Value
    denomination DECIMAL(10, 2) NOT NULL CHECK (denomination > 0),
    remaining_value DECIMAL(10, 2) NOT NULL CHECK (remaining_value >= 0),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
        CHECK (status IN ('ACTIVE', 'USED', 'EXPIRED', 'CANCELLED', 'GIFTED')),
    
    -- Validity
    purchased_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    
    -- Redemption
    redeemed_at TIMESTAMP,
    redemption_location VARCHAR(255),
    redemption_notes TEXT,
    
    -- Gifting
    is_gift BOOLEAN DEFAULT FALSE,
    gifted_to_user_id BIGINT REFERENCES users(id),
    gift_message TEXT,
    gifted_at TIMESTAMP,
    
    -- Security
    pin_code VARCHAR(10),
    
    metadata JSONB,
    
    CONSTRAINT chk_wallet_validity CHECK (valid_from < valid_until),
    CONSTRAINT chk_remaining_value CHECK (remaining_value <= denomination)
);

CREATE INDEX idx_wallet_user ON wallet_vouchers(user_id);
CREATE INDEX idx_wallet_voucher ON wallet_vouchers(voucher_id);
CREATE INDEX idx_wallet_order ON wallet_vouchers(order_id);
CREATE INDEX idx_wallet_code ON wallet_vouchers(voucher_code);
CREATE INDEX idx_wallet_status ON wallet_vouchers(status);
CREATE INDEX idx_wallet_validity ON wallet_vouchers(valid_until) WHERE status = 'ACTIVE';

COMMENT ON TABLE wallet_vouchers IS 'Digital vouchers in user wallets after purchase';
COMMENT ON COLUMN wallet_vouchers.voucher_code IS 'Unique redemption code (alphanumeric, 12-16 chars)';
COMMENT ON COLUMN wallet_vouchers.remaining_value IS 'For partial redemptions (if supported)';

-- =============================================
-- REDEMPTIONS
-- =============================================

CREATE TABLE redemptions (
    id BIGSERIAL PRIMARY KEY,
    wallet_voucher_id BIGINT NOT NULL REFERENCES wallet_vouchers(id),
    merchant_id BIGINT NOT NULL REFERENCES merchants(id),
    redeemed_by_user_id BIGINT REFERENCES users(id),
    scanned_by_user_id BIGINT REFERENCES users(id),
    
    -- Redemption Details
    redemption_amount DECIMAL(10, 2) NOT NULL CHECK (redemption_amount > 0),
    transaction_reference VARCHAR(100),
    redemption_method VARCHAR(20) DEFAULT 'QR_SCAN' 
        CHECK (redemption_method IN ('QR_SCAN', 'PIN_CODE', 'MANUAL')),
    
    -- Location
    redemption_location VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED' 
        CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELLED', 'DISPUTED')),
    
    notes TEXT,
    metadata JSONB,
    
    redeemed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_redemptions_wallet_voucher ON redemptions(wallet_voucher_id);
CREATE INDEX idx_redemptions_merchant ON redemptions(merchant_id);
CREATE INDEX idx_redemptions_date ON redemptions(redeemed_at DESC);
CREATE INDEX idx_redemptions_status ON redemptions(status);

COMMENT ON TABLE redemptions IS 'Voucher redemption transactions at merchant locations';

-- =============================================
-- REVIEWS & RATINGS
-- =============================================

CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    voucher_id BIGINT REFERENCES vouchers(id),
    merchant_id BIGINT REFERENCES merchants(id),
    order_id BIGINT REFERENCES orders(id),
    
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    
    -- Verification
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'HIDDEN')),
    moderated_by BIGINT REFERENCES users(id),
    moderation_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_review_target CHECK (
        (voucher_id IS NOT NULL AND merchant_id IS NULL) OR
        (voucher_id IS NULL AND merchant_id IS NOT NULL)
    )
);

CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_voucher ON reviews(voucher_id);
CREATE INDEX idx_reviews_merchant ON reviews(merchant_id);
CREATE INDEX idx_reviews_status ON reviews(status);
CREATE INDEX idx_reviews_rating ON reviews(rating);

COMMENT ON TABLE reviews IS 'Customer reviews and ratings for vouchers and merchants';

-- =============================================
-- PAYOUTS
-- =============================================

CREATE TABLE payouts (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchants(id),
    
    -- Payout Details
    payout_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Bank Transfer
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    transaction_reference VARCHAR(255),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    
    -- Approval
    approved_by BIGINT REFERENCES users(id),
    approved_at TIMESTAMP,
    
    -- Payment
    paid_at TIMESTAMP,
    payment_method VARCHAR(50),
    
    notes TEXT,
    metadata JSONB,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_payout_period CHECK (period_start <= period_end)
);

CREATE INDEX idx_payouts_merchant ON payouts(merchant_id);
CREATE INDEX idx_payouts_status ON payouts(status);
CREATE INDEX idx_payouts_period ON payouts(period_start, period_end);
CREATE INDEX idx_payouts_number ON payouts(payout_number);

COMMENT ON TABLE payouts IS 'Weekly merchant payout batches (92% of voucher sales)';

-- Payout Items
CREATE TABLE payout_items (
    id BIGSERIAL PRIMARY KEY,
    payout_id BIGINT NOT NULL REFERENCES payouts(id) ON DELETE CASCADE,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payout_items_payout ON payout_items(payout_id);
CREATE INDEX idx_payout_items_order ON payout_items(order_id);

COMMENT ON TABLE payout_items IS 'Individual orders included in each payout batch';

CREATE TABLE payout_holds (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT NOT NULL REFERENCES merchants(id),
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'RELEASED')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP
);

CREATE INDEX idx_payout_holds_merchant ON payout_holds(merchant_id);
CREATE INDEX idx_payout_holds_status ON payout_holds(status);

-- =============================================
-- NOTIFICATIONS
-- =============================================

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Delivery Channels
    channels VARCHAR(20)[] DEFAULT ARRAY['PUSH'],
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    -- Related Entity
    entity_type VARCHAR(50),
    entity_id BIGINT,
    
    -- Delivery Status
    push_sent BOOLEAN DEFAULT FALSE,
    email_sent BOOLEAN DEFAULT FALSE,
    sms_sent BOOLEAN DEFAULT FALSE,
    
    metadata JSONB,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);

COMMENT ON TABLE notifications IS 'User notifications across multiple channels (push, email, SMS)';

-- =============================================
-- FILE UPLOADS
-- =============================================

CREATE TABLE file_uploads (
    id BIGSERIAL PRIMARY KEY,
    uploaded_by BIGINT REFERENCES users(id),
    
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    mime_type VARCHAR(100) NOT NULL,
    
    -- Association
    entity_type VARCHAR(50),
    entity_id BIGINT,
    
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    metadata JSONB
);

CREATE INDEX idx_uploads_entity ON file_uploads(entity_type, entity_id);
CREATE INDEX idx_uploads_uploader ON file_uploads(uploaded_by);

COMMENT ON TABLE file_uploads IS 'File upload tracking (images, documents, avatars)';

-- =============================================
-- AUDIT LOG
-- =============================================

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT,
    
    old_values JSONB,
    new_values JSONB,
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_action ON audit_logs(action);

COMMENT ON TABLE audit_logs IS 'Complete audit trail of all system actions';

-- =============================================
-- FUNCTIONS & TRIGGERS
-- =============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vouchers_updated_at BEFORE UPDATE ON vouchers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payouts_updated_at BEFORE UPDATE ON payouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- SEED DATA
-- =============================================

-- Insert voucher categories
INSERT INTO voucher_categories (name, slug, description, display_order, icon_url) VALUES
('Food & Dining', 'food-dining', 'Restaurants, cafes, and food delivery services', 1, 'food'),
('Entertainment', 'entertainment', 'Movies, events, concerts, and activities', 2, 'entertainment'),
('Health & Beauty', 'health-beauty', 'Spas, salons, gyms, and wellness centers', 3, 'health'),
('Shopping', 'shopping', 'Retail stores, fashion, and electronics', 4, 'shopping'),
('Travel & Hotels', 'travel-hotels', 'Hotels, resorts, and travel services', 5, 'travel'),
('Services', 'services', 'Professional and personal services', 6, 'services');

-- Insert sample admin user (password: Admin@123456)
-- Password hash generated with BCrypt strength 10
INSERT INTO users (full_name, phone_number, email, password_hash, role, status, phone_verified, email_verified)
VALUES (
    'System Administrator',
    '+85512345678',
    'admin@kado24.com',
    '$2a$10$XqKJYlVqcVY7uXU4.Pu4ZeN9TlQXZGHhVz8gKzZvHlXGz1RzYxK1y',
    'ADMIN',
    'ACTIVE',
    TRUE,
    TRUE
);

-- Insert OAuth2 clients
INSERT INTO oauth2_clients (id, client_secret, client_name, redirect_uris, grant_types, scopes, access_token_validity, refresh_token_validity) VALUES
('consumer-app', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Kado24 Consumer Mobile App', 
 ARRAY['kado24://oauth/callback', 'http://localhost:3000/callback'], 
 ARRAY['authorization_code', 'refresh_token', 'password'], 
 ARRAY['read', 'write'], 
 3600, 86400),
('merchant-app', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Kado24 Merchant Mobile App', 
 ARRAY['kado24-merchant://oauth/callback', 'http://localhost:3001/callback'], 
 ARRAY['authorization_code', 'refresh_token', 'password'], 
 ARRAY['read', 'write', 'merchant'], 
 3600, 86400),
('admin-portal', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Kado24 Admin Portal', 
 ARRAY['http://localhost:4200/callback', 'http://admin.kado24.com/callback'], 
 ARRAY['authorization_code', 'refresh_token'], 
 ARRAY['read', 'write', 'admin'], 
 3600, 86400);

-- Create view for active vouchers
CREATE OR REPLACE VIEW active_vouchers AS
SELECT 
    v.*,
    m.business_name as merchant_name,
    m.logo_url as merchant_logo,
    m.rating as merchant_rating,
    c.name as category_name
FROM vouchers v
JOIN merchants m ON v.merchant_id = m.id
LEFT JOIN voucher_categories c ON v.category_id = c.id
WHERE v.status = 'ACTIVE'
  AND m.verification_status = 'APPROVED'
  AND (v.valid_until IS NULL OR v.valid_until > CURRENT_TIMESTAMP)
  AND (v.unlimited_stock = TRUE OR v.stock_quantity > 0);

COMMENT ON VIEW active_vouchers IS 'Currently available vouchers with merchant information';

-- Create view for merchant dashboard metrics
CREATE OR REPLACE VIEW merchant_metrics AS
SELECT 
    m.id as merchant_id,
    m.business_name,
    COUNT(DISTINCT v.id) as total_vouchers,
    COUNT(DISTINCT o.id) as total_orders,
    COALESCE(SUM(o.merchant_amount), 0) as total_revenue,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(DISTINCT r.id) as total_reviews
FROM merchants m
LEFT JOIN vouchers v ON m.id = v.merchant_id
LEFT JOIN orders o ON m.id = o.merchant_id AND o.payment_status = 'COMPLETED'
LEFT JOIN reviews r ON m.id = r.merchant_id AND r.status = 'APPROVED'
GROUP BY m.id, m.business_name;

COMMENT ON VIEW merchant_metrics IS 'Aggregated metrics for merchant dashboards';

-- Grant permissions (adjust based on your database user setup)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO kado24_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO kado24_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO kado24_user;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Kado24 database schema initialized successfully.';
    RAISE NOTICE 'Created tables, indexes, triggers, and seed data.';
    RAISE NOTICE 'Admin credentials: admin@kado24.com / Admin@123456';
END $$;







