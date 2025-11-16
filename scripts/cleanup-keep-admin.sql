-- =========================================================
-- Kado24 Platform - Data Cleanup (Keep Admin Only)
-- ---------------------------------------------------------
-- This script removes all runtime/sample data while keeping
-- only the seeded admin account and OAuth clients required
-- for authentication.
--
-- Usage:
--   psql -h <host> -U <user> -d <database> -f scripts/cleanup-keep-admin.sql
--
-- Make sure the database user has permission to TRUNCATE and
-- DELETE the listed tables.
-- =========================================================

DO $cleanup$
DECLARE
    tables_to_truncate TEXT[] := ARRAY[
        'admin_schema.audit_logs',
        'admin_schema.fraud_alerts',
        'analytics_schema.daily_metrics',
        'notification_schema.support_tickets',
        'notification_schema.notifications',
        'payout_schema.payout_items',
        'payout_schema.payouts',
        'redemption_schema.disputes',
        'redemption_schema.redemptions',
        'wallet_schema.wallet_vouchers',
        'order_schema.transactions',
        'order_schema.orders',
        'voucher_schema.reviews',
        'voucher_schema.vouchers',
        'merchant_schema.merchant_documents',
        'merchant_schema.merchant_bank_accounts',
        'merchant_schema.merchant_locations',
        'merchant_schema.merchants',
        'user_schema.user_addresses',
        'user_schema.user_profiles',
        'shared_schema.file_uploads',
        'shared_schema.voucher_categories',
        'shared_schema.system_settings',
        'auth_schema.oauth2_tokens'
    ];
    tbl TEXT;
    schema_name TEXT;
    tbl_name TEXT;
BEGIN
    -- Truncate runtime data across schemas when tables exist
    FOREACH tbl IN ARRAY tables_to_truncate LOOP
        schema_name := split_part(tbl, '.', 1);
        tbl_name := split_part(tbl, '.', 2);

        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = schema_name
              AND table_name = tbl_name
        ) THEN
            EXECUTE format('TRUNCATE TABLE %I.%I RESTART IDENTITY CASCADE', schema_name, tbl_name);
        ELSE
            RAISE NOTICE 'Skipping %.%, table does not exist.', schema_name, tbl_name;
        END IF;
    END LOOP;

    -- Remove every auth user except the platform admin
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'auth_schema'
          AND table_name = 'users'
    ) THEN
        EXECUTE $sql$
            DELETE FROM auth_schema.users
            WHERE email IS DISTINCT FROM 'admin@kado24.com'
        $sql$;

        PERFORM 1
        FROM auth_schema.users
        WHERE email = 'admin@kado24.com';

        IF NOT FOUND THEN
            INSERT INTO auth_schema.users (
                full_name,
                phone_number,
                email,
                password_hash,
                role,
                status,
                email_verified,
                phone_verified
            ) VALUES (
                'Platform Administrator',
                '+85512000000',
                'admin@kado24.com',
                '$2a$10$rZ5jYhF5YJ5h5YqGqE7hOeN9X4YrYqW4YqGqE7hOeN9X4YrYqW4Yq',
                'ADMIN',
                'ACTIVE',
                TRUE,
                TRUE
            );
        END IF;
    ELSE
        RAISE NOTICE 'Skipping auth cleanup, auth_schema.users not found.';
    END IF;

    -- Ensure OAuth clients exist
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'auth_schema'
          AND table_name = 'oauth2_clients'
    ) THEN
        INSERT INTO auth_schema.oauth2_clients (id, client_secret, client_name, grant_types, scopes)
        VALUES
            ('consumer-app', '$2a$10$secrethash', 'Kado24 Consumer App', ARRAY['password', 'refresh_token'], ARRAY['read', 'write']),
            ('merchant-app', '$2a$10$secrethash', 'Kado24 Merchant App', ARRAY['password', 'refresh_token'], ARRAY['read', 'write']),
            ('admin-portal', '$2a$10$secrethash', 'Kado24 Admin Portal', ARRAY['password', 'refresh_token'], ARRAY['read', 'write', 'admin'])
        ON CONFLICT (id) DO UPDATE
        SET
            client_secret = EXCLUDED.client_secret,
            client_name = EXCLUDED.client_name,
            grant_types = EXCLUDED.grant_types,
            scopes = EXCLUDED.scopes;
    ELSE
        RAISE NOTICE 'Skipping OAuth client seed, auth_schema.oauth2_clients not found.';
    END IF;

    -- Re-seed shared voucher categories and system settings
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'shared_schema'
          AND table_name = 'voucher_categories'
    ) THEN
        INSERT INTO shared_schema.voucher_categories (name, display_name, icon, color, sort_order)
        VALUES
            ('food-beverage', 'Food & Beverage', 'food', '#FF5722', 1),
            ('spa-wellness', 'Spa & Wellness', 'spa', '#9C27B0', 2),
            ('entertainment', 'Entertainment', 'entertainment', '#2196F3', 3),
            ('shopping', 'Shopping', 'shopping', '#4CAF50', 4),
            ('travel', 'Travel & Hotels', 'travel', '#FF9800', 5),
            ('services', 'Services', 'services', '#607D8B', 6)
        ON CONFLICT (name) DO UPDATE
        SET
            display_name = EXCLUDED.display_name,
            icon = EXCLUDED.icon,
            color = EXCLUDED.color,
            sort_order = EXCLUDED.sort_order,
            is_active = TRUE;
    ELSE
        RAISE NOTICE 'Skipping voucher category seed, shared_schema.voucher_categories not found.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'shared_schema'
          AND table_name = 'system_settings'
    ) THEN
        INSERT INTO shared_schema.system_settings (key, value, value_type, description, is_public)
        VALUES
            ('platform.commission_rate', '0.08', 'DECIMAL', 'Platform commission rate (8%)', FALSE),
            ('platform.currency', 'USD', 'STRING', 'Default platform currency', TRUE),
            ('platform.timezone', 'Asia/Phnom_Penh', 'STRING', 'Platform timezone', TRUE)
        ON CONFLICT (key) DO UPDATE
        SET
            value = EXCLUDED.value,
            value_type = EXCLUDED.value_type,
            description = EXCLUDED.description,
            is_public = EXCLUDED.is_public,
            updated_at = CURRENT_TIMESTAMP,
            updated_by = 'cleanup-script';
    ELSE
        RAISE NOTICE 'Skipping system settings seed, shared_schema.system_settings not found.';
    END IF;

    RAISE NOTICE 'Database cleaned across schemas. Admin user and reference data restored.';
END
$cleanup$;


