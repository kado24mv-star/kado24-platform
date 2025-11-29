# Simple Service Startup Script
# Starts services one by one with proper error handling

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Backend Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
if (Test-Path "set-dev-env.ps1") {
    Write-Host "Setting AWS RDS environment variables..." -ForegroundColor Yellow
    . .\set-dev-env.ps1
}

# Check infrastructure
Write-Host "Checking infrastructure..." -ForegroundColor Yellow
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

# Try to start services
Write-Host "Starting backend services..." -ForegroundColor Yellow
Write-Host ""

# Start services one by one to see which ones fail
$services = @(
    "auth-service",
    "user-service", 
    "voucher-service",
    "order-service",
    "wallet-service",
    "redemption-service",
    "merchant-service",
    "admin-portal-backend",
    "notification-service",
    "payout-service",
    "analytics-service",
    "mock-payment-service"
)

$started = @()
$failed = @()

foreach ($service in $services) {
    Write-Host "Starting $service..." -ForegroundColor Cyan
    docker compose -f docker-compose.services.yml up -d --build $service 2>&1 | Out-Null
    
    Start-Sleep -Seconds 3
    
    $container = docker ps --filter "name=kado24-$service" --format "{{.Names}}"
    if ($container) {
        $status = docker ps --filter "name=kado24-$service" --format "{{.Status}}"
        Write-Host "  ✓ $service started - $status" -ForegroundColor Green
        $started += $service
    } else {
        Write-Host "  ✗ $service failed to start" -ForegroundColor Red
        $failed += $service
        
        # Show logs for failed service
        Write-Host "  Checking logs..." -ForegroundColor Yellow
        docker compose -f docker-compose.services.yml logs --tail=20 $service
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor $(if ($failed.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "Startup Summary" -ForegroundColor $(if ($failed.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "========================================" -ForegroundColor $(if ($failed.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

Write-Host "Started: $($started.Count)" -ForegroundColor Green
$started | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed: $($failed.Count)" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  1. Services need to be built first: .\build-maven-services.ps1" -ForegroundColor Gray
    Write-Host "  2. Check Docker logs: docker logs kado24-$($failed[0])" -ForegroundColor Gray
    Write-Host "  3. Verify database connection" -ForegroundColor Gray
    Write-Host "  4. Check if ports are available" -ForegroundColor Gray
}

Write-Host ""
Write-Host "All services status:" -ForegroundColor Cyan
docker ps --filter "name=kado24" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

