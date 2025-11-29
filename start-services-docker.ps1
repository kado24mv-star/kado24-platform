# Start Backend Services using Docker
# This script starts backend services in Docker containers
# Services will use AWS RDS if environment variables are set

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Backend Services (Docker)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set AWS RDS environment variables if script exists
if (Test-Path "set-dev-env.ps1") {
    Write-Host "[1/4] Setting AWS RDS environment variables..." -ForegroundColor Yellow
    . .\set-dev-env.ps1
    Write-Host "✓ Environment variables set" -ForegroundColor Green
    Write-Host "  Database: $env:POSTGRES_HOST" -ForegroundColor Gray
} else {
    Write-Host "[1/4] Using default localhost database (set-dev-env.ps1 not found)" -ForegroundColor Yellow
}
Write-Host ""

# Check infrastructure
Write-Host "[2/4] Checking infrastructure..." -ForegroundColor Yellow
$redis = docker ps --filter "name=kado24-redis" --format "{{.Names}}"
if (-not $redis) {
    Write-Host "Starting infrastructure..." -ForegroundColor Cyan
    cd infrastructure\docker
    docker compose up -d
    cd ..\..
    Start-Sleep -Seconds 5
}
Write-Host "✓ Infrastructure ready" -ForegroundColor Green
Write-Host ""

# Build services if needed
Write-Host "[3/4] Building/Starting services..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first run..." -ForegroundColor Gray
Write-Host ""

# Start all backend services
docker compose -f docker-compose.services.yml up -d --build `
    auth-service `
    user-service `
    voucher-service `
    order-service `
    wallet-service `
    redemption-service `
    merchant-service `
    admin-portal-backend `
    notification-service `
    payout-service `
    analytics-service `
    mock-payment-service

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Services Started Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Show service status
    Write-Host "Service Status:" -ForegroundColor Cyan
    docker ps --filter "name=kado24" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-Object -Skip 1
    
    Write-Host ""
    Write-Host "Service URLs:" -ForegroundColor Cyan
    Write-Host "  - Auth Service: http://localhost:8081" -ForegroundColor Gray
    Write-Host "  - User Service: http://localhost:8082" -ForegroundColor Gray
    Write-Host "  - Voucher Service: http://localhost:8083" -ForegroundColor Gray
    Write-Host "  - Order Service: http://localhost:8084" -ForegroundColor Gray
    Write-Host "  - Wallet Service: http://localhost:8086" -ForegroundColor Gray
    Write-Host "  - Redemption Service: http://localhost:8087" -ForegroundColor Gray
    Write-Host "  - Merchant Service: http://localhost:8088" -ForegroundColor Gray
    Write-Host "  - Admin Portal Backend: http://localhost:8089" -ForegroundColor Gray
    Write-Host "  - Notification Service: http://localhost:8091" -ForegroundColor Gray
    Write-Host "  - Payout Service: http://localhost:8092" -ForegroundColor Gray
    Write-Host "  - Analytics Service: http://localhost:8093" -ForegroundColor Gray
    Write-Host "  - Mock Payment Service: http://localhost:8095" -ForegroundColor Gray
    Write-Host ""
    Write-Host "API Gateway: http://localhost:9080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To view logs:" -ForegroundColor Yellow
    Write-Host "  docker logs -f kado24-auth-service" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To stop services:" -ForegroundColor Yellow
    Write-Host "  docker compose -f docker-compose.services.yml down" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "✗ Failed to start services" -ForegroundColor Red
    Write-Host "Check logs with: docker compose -f docker-compose.services.yml logs" -ForegroundColor Yellow
}

