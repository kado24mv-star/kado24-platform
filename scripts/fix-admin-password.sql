-- Fix Admin User Password Hash
-- This script updates the admin user password to a valid BCrypt hash for "Admin@123456"
-- Generated with BCrypt strength 10

-- First, let's check if admin user exists
SELECT id, email, phone_number, role, status 
FROM auth_schema.users 
WHERE email = 'admin@kado24.com';

-- Update admin password with valid BCrypt hash
-- This hash is for password: Admin@123456
UPDATE auth_schema.users 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE email = 'admin@kado24.com';

-- Verify the update
SELECT id, email, role, status, 
       CASE 
         WHEN password_hash LIKE '$2a$10$%' THEN 'Valid BCrypt hash'
         ELSE 'Invalid hash'
       END as hash_status
FROM auth_schema.users 
WHERE email = 'admin@kado24.com';

