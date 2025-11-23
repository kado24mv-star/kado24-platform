# Voucher Service Database Migrations

This directory contains database migration scripts for the voucher service.

## Migration History

### 2025-11-20: Image URL Column Type Update

**Migration:** `alter_image_url_to_text.sql`  
**Script:** `run_migration.ps1`

**Change:** Updated `image_url` column from `VARCHAR(500)` to `TEXT` to support base64 image data URLs of unlimited length.

**Reason:** Base64 encoded images can be very long (thousands of characters), exceeding the 500 character limit of VARCHAR(500).

**Status:** ✅ Applied to production database

**Note:** The main database initialization script (`scripts/init-database-schemas.sql`) has been updated to create the column as TEXT from the start. This migration is only needed for existing databases.

## Running Migrations

### PowerShell (Windows)

```powershell
cd backend/services/voucher-service/migrations
.\run_migration.ps1
```

### Manual SQL

```sql
ALTER TABLE voucher_schema.vouchers ALTER COLUMN image_url TYPE TEXT;
```

## Verification

After running the migration, verify the change:

```sql
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_schema = 'voucher_schema' 
  AND table_name = 'vouchers' 
  AND column_name = 'image_url';
```

Expected result: `data_type` should be `text` and `character_maximum_length` should be `null`.

