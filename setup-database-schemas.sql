-- Setup Database Schemas for AWS RDS
-- Run this script on your AWS RDS PostgreSQL database
-- Usage: psql -h kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com -U kado24_dev_user -d postgres -f setup-database-schemas.sql

-- Create schemas for all services
CREATE SCHEMA IF NOT EXISTS auth_schema;
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE SCHEMA IF NOT EXISTS voucher_schema;
CREATE SCHEMA IF NOT EXISTS order_schema;
CREATE SCHEMA IF NOT EXISTS wallet_schema;
CREATE SCHEMA IF NOT EXISTS redemption_schema;
CREATE SCHEMA IF NOT EXISTS merchant_schema;
CREATE SCHEMA IF NOT EXISTS admin_schema;
CREATE SCHEMA IF NOT EXISTS notification_schema;
CREATE SCHEMA IF NOT EXISTS payout_schema;
CREATE SCHEMA IF NOT EXISTS analytics_schema;

-- Grant permissions to the database user
GRANT ALL PRIVILEGES ON SCHEMA auth_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA user_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA voucher_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA order_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA wallet_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA redemption_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA merchant_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA admin_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA notification_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA payout_schema TO kado24_dev_user;
GRANT ALL PRIVILEGES ON SCHEMA analytics_schema TO kado24_dev_user;

-- Grant usage on all schemas
GRANT USAGE ON SCHEMA auth_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA user_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA voucher_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA order_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA wallet_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA redemption_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA merchant_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA admin_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA notification_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA payout_schema TO kado24_dev_user;
GRANT USAGE ON SCHEMA analytics_schema TO kado24_dev_user;

-- Verify schemas were created
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name LIKE '%_schema' 
ORDER BY schema_name;

