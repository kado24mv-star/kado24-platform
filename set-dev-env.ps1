# PowerShell script to set development environment variables for AWS RDS
# Usage: . .\set-dev-env.ps1

Write-Host "Setting development environment variables for AWS RDS..." -ForegroundColor Cyan

# AWS RDS PostgreSQL Configuration
$env:POSTGRES_HOST = "kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com"
$env:POSTGRES_PORT = "5432"
$env:POSTGRES_DB = "postgres"
$env:POSTGRES_USER = "kado24_dev_user"
$env:POSTGRES_PASSWORD = "docTod-dyfvi0-nesbux"

# Alternative variable names (for compatibility)
$env:DB_HOST = $env:POSTGRES_HOST
$env:DB_PORT = $env:POSTGRES_PORT
$env:DB_NAME = $env:POSTGRES_DB
$env:DB_USER = $env:POSTGRES_USER
$env:DB_PASSWORD = $env:POSTGRES_PASSWORD

# Redis Configuration (keep local for now)
$env:REDIS_HOST = "localhost"
$env:REDIS_PORT = "6379"
$env:REDIS_PASSWORD = "kado24_redis_pass"

Write-Host "Environment variables set successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Database Configuration:" -ForegroundColor Yellow
Write-Host "  Host: $env:POSTGRES_HOST" -ForegroundColor Gray
Write-Host "  Port: $env:POSTGRES_PORT" -ForegroundColor Gray
Write-Host "  Database: $env:POSTGRES_DB" -ForegroundColor Gray
Write-Host "  User: $env:POSTGRES_USER" -ForegroundColor Gray
Write-Host ""
Write-Host "To verify, run: Get-ChildItem Env: | Where-Object { `$_.Name -like '*POSTGRES*' -or `$_.Name -like '*DB_*' }" -ForegroundColor Cyan

