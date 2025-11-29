# =============================================
# Kado24 Platform - Restart All Services
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Restart All Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Step 1: Stop all services
Write-Host "Step 1: Stopping all services..." -ForegroundColor Yellow
$containers = docker ps -q --filter "name=kado24" 2>$null
if ($containers) {
    docker stop $containers | Out-Null
    Write-Host "✅ All services stopped" -ForegroundColor Green
} else {
    Write-Host "⚠️  No services running" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# Step 2: Start infrastructure
Write-Host ""
Write-Host "Step 2: Starting infrastructure services..." -ForegroundColor Yellow
$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
cd "$rootPath\infrastructure\docker"
docker compose up -d | Out-Null
Start-Sleep -Seconds 5
Write-Host "✅ Infrastructure services started" -ForegroundColor Green

# Step 3: Start backend services
Write-Host ""
Write-Host "Step 3: Starting backend services..." -ForegroundColor Yellow
cd $rootPath
docker compose -f docker-compose.services.yml up -d | Out-Null
Start-Sleep -Seconds 10
Write-Host "✅ Backend services started" -ForegroundColor Green

# Step 4: Configure APISIX routes
Write-Host ""
Write-Host "Step 4: Configuring APISIX routes..." -ForegroundColor Yellow
cd "$rootPath\gateway\apisix"
& ".\setup-all-routes-cors.ps1" | Out-Null
Write-Host "✅ APISIX routes configured" -ForegroundColor Green

# Step 5: Verify services
Write-Host ""
Write-Host "Step 5: Verifying services..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

$infraServices = docker ps --filter "name=kado24" --format "{{.Names}}" | Where-Object { $_ -like "*redis*" -or $_ -like "*etcd*" -or $_ -like "*apisix*" }
$backendServices = docker ps --filter "name=kado24" --format "{{.Names}}" | Where-Object { $_ -like "*service*" }

Write-Host ""
Write-Host "Infrastructure Services:" -ForegroundColor Cyan
foreach ($service in $infraServices) {
    $status = docker ps --filter "name=$service" --format "{{.Status}}"
    Write-Host "  ✅ $service - $status" -ForegroundColor Green
}

Write-Host ""
Write-Host "Backend Services:" -ForegroundColor Cyan
$serviceCount = ($backendServices | Measure-Object).Count
Write-Host "  ✅ $serviceCount backend services running" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Services Restart Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Yellow
Write-Host "  • API Gateway: http://localhost:9080" -ForegroundColor White
Write-Host "  • Admin Portal: http://localhost:4200" -ForegroundColor White
Write-Host "  • Merchant App: http://localhost:8001" -ForegroundColor White
Write-Host "  • Consumer App: http://localhost:8002" -ForegroundColor White
Write-Host ""
Write-Host "Note: Frontend apps need to be restarted manually if needed." -ForegroundColor Gray
Write-Host ""

