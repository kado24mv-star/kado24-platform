# Migration Script: Change image_url column from VARCHAR(500) to TEXT
# This script requires psql to be installed and accessible in PATH

param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$Database = "kado24_db",
    [string]$DbUser = "kado24_user",
    [string]$DbPassword = "kado24_pass"
)

Write-Host "=== Running Database Migration ===" -ForegroundColor Cyan
Write-Host "Database: $Database" -ForegroundColor Yellow
Write-Host "Schema: voucher_schema" -ForegroundColor Yellow
Write-Host "Column: image_url" -ForegroundColor Yellow
Write-Host ""

$env:PGPASSWORD = $DbPassword

$sqlCommand = "ALTER TABLE voucher_schema.vouchers ALTER COLUMN image_url TYPE TEXT;"

try {
    $result = & psql -h $DbHost -p $DbPort -U $DbUser -d $Database -c $sqlCommand 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Migration completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Verifying column type..." -ForegroundColor Cyan
        $verifySql = "SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_schema = 'voucher_schema' AND table_name = 'vouchers' AND column_name = 'image_url';"
        & psql -h $DbHost -p $DbPort -U $DbUser -d $Database -c $verifySql
    } else {
        Write-Host "❌ Migration failed!" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error running migration: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "  1. PostgreSQL is running" -ForegroundColor White
    Write-Host "  2. psql is installed and in PATH" -ForegroundColor White
    Write-Host "  3. Database credentials are correct" -ForegroundColor White
    Write-Host ""
    Write-Host "You can also run the SQL manually:" -ForegroundColor Cyan
    Write-Host "  ALTER TABLE voucher_schema.vouchers ALTER COLUMN image_url TYPE TEXT;" -ForegroundColor White
    exit 1
} finally {
    $env:PGPASSWORD = $null
}

