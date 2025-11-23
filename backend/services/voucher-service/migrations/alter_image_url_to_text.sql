-- Migration: Change image_url column from VARCHAR(500) to TEXT
-- This allows storing base64 image data URLs of any length

ALTER TABLE voucher_schema.vouchers 
ALTER COLUMN image_url TYPE TEXT;

-- Verify the change
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_schema = 'voucher_schema' 
  AND table_name = 'vouchers' 
  AND column_name = 'image_url';

