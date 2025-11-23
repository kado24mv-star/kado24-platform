# =============================================
# Kado24 Platform - Complete Startup Script
# Starts infrastructure, configures routes, and starts services
# Run this after restarting your PC
# =============================================

Write-Host "=============================================" -ForegroundColor Green
Write-Host "Kado24 Platform - Complete Startup" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Step 1: Start Infrastructure
Write-Host "Step 1: Starting infrastructure services..." -ForegroundColor Cyan
cd infrastructure\docker
docker compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start infrastructure" -ForegroundColor Red
    exit 1
}
Write-Host "Infrastructure started. Waiting for APISIX..." -ForegroundColor Green
Start-Sleep -Seconds 15

# Step 2: Setup APISIX Routes with CORS
Write-Host ""
Write-Host "Step 2: Configuring APISIX routes with CORS..." -ForegroundColor Cyan
cd ..\..\gateway\apisix
.\setup-all-routes-cors.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Some routes may have failed. Continuing..." -ForegroundColor Yellow
}

# Step 3: Start Backend Services
Write-Host ""
Write-Host "Step 3: Starting backend services..." -ForegroundColor Cyan
cd ..\..
docker compose -f docker-compose.services.yml up -d auth-service user-service voucher-service order-service wallet-service redemption-service merchant-service admin-portal-backend notification-service payout-service analytics-service payment-service

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Platform Started Successfully!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "  - API Gateway: http://localhost:9080"
Write-Host "  - Admin Portal: http://localhost:4200"
Write-Host "  - Merchant App: http://localhost:8001"
Write-Host "  - Consumer App: http://localhost:8002"
Write-Host ""
Write-Host "To start frontend apps:" -ForegroundColor Yellow
Write-Host "  Consumer: cd frontend\consumer-app && flutter run -d chrome --web-port=8002"
Write-Host "  Merchant: cd frontend\merchant-app && flutter run -d chrome --web-port=8001"
Write-Host "  Admin: cd frontend\admin-portal && ng serve --port 4200"
Write-Host ""

