# Start Backend Services Locally
# This script starts backend services as local processes (not Docker)
# Services will connect to AWS RDS when environment variables are set

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Backend Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set AWS RDS environment variables
Write-Host "[1/4] Setting AWS RDS environment variables..." -ForegroundColor Yellow
if (Test-Path "set-dev-env.ps1") {
    . .\set-dev-env.ps1
    Write-Host "✓ Environment variables set" -ForegroundColor Green
} else {
    Write-Host "⚠ set-dev-env.ps1 not found. Using default localhost database." -ForegroundColor Yellow
}
Write-Host ""

# Check if infrastructure is running
Write-Host "[2/4] Checking infrastructure..." -ForegroundColor Yellow
$redis = docker ps --filter "name=redis" --format "{{.Names}}"
$etcd = docker ps --filter "name=etcd" --format "{{.Names}}"

if (-not $redis) {
    Write-Host "⚠ Redis is not running. Starting infrastructure..." -ForegroundColor Yellow
    cd infrastructure\docker
    docker compose up -d redis etcd apisix
    cd ..\..
    Start-Sleep -Seconds 5
    Write-Host "✓ Infrastructure started" -ForegroundColor Green
} else {
    Write-Host "✓ Infrastructure is running" -ForegroundColor Green
}
Write-Host ""

# Check if services are built
Write-Host "[3/4] Checking if services are built..." -ForegroundColor Yellow
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

$builtServices = @()
$needBuild = @()

foreach ($service in $services) {
    $jarPath = "backend\services\$service\target\$service*.jar"
    $jarFiles = Get-ChildItem -Path $jarPath -ErrorAction SilentlyContinue
    if ($jarFiles) {
        $builtServices += $service
    } else {
        $needBuild += $service
    }
}

if ($builtServices.Count -gt 0) {
    Write-Host "✓ Built services: $($builtServices.Count)" -ForegroundColor Green
    $builtServices | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
}

if ($needBuild.Count -gt 0) {
    Write-Host "⚠ Services need to be built: $($needBuild.Count)" -ForegroundColor Yellow
    $needBuild | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    Write-Host ""
    $build = Read-Host "Build services now? (y/n)"
    if ($build -eq "y" -or $build -eq "Y") {
        Write-Host "Building services..." -ForegroundColor Cyan
        .\build-maven-services.ps1
    }
}
Write-Host ""

# Start services
Write-Host "[4/4] Starting backend services..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Services will start in separate windows." -ForegroundColor Cyan
Write-Host "Each service will run in its own PowerShell window." -ForegroundColor Cyan
Write-Host ""

$servicePorts = @{
    "auth-service" = 8081
    "user-service" = 8082
    "voucher-service" = 8083
    "order-service" = 8084
    "wallet-service" = 8086
    "redemption-service" = 8087
    "merchant-service" = 8088
    "admin-portal-backend" = 8089
    "notification-service" = 8091
    "payout-service" = 8092
    "analytics-service" = 8093
    "mock-payment-service" = 8095
}

$startedServices = @()

foreach ($service in $services) {
    $jarPath = "backend\services\$service\target\$service*.jar"
    $jarFiles = Get-ChildItem -Path $jarPath -ErrorAction SilentlyContinue
    
    if ($jarFiles) {
        $jarFile = $jarFiles[0].FullName
        $port = $servicePorts[$service]
        
        Write-Host "Starting $service on port $port..." -ForegroundColor Cyan
        
        # Start service in new window
        Start-Process powershell -ArgumentList @(
            "-NoExit",
            "-Command",
            "cd '$PWD'; `$env:POSTGRES_HOST='$env:POSTGRES_HOST'; `$env:POSTGRES_PORT='$env:POSTGRES_PORT'; `$env:POSTGRES_DB='$env:POSTGRES_DB'; `$env:POSTGRES_USER='$env:POSTGRES_USER'; `$env:POSTGRES_PASSWORD='$env:POSTGRES_PASSWORD'; `$env:REDIS_HOST='$env:REDIS_HOST'; `$env:REDIS_PORT='$env:REDIS_PORT'; `$env:REDIS_PASSWORD='$env:REDIS_PASSWORD'; java -jar '$jarFile'"
        ) -WindowStyle Normal
        
        $startedServices += $service
        Start-Sleep -Seconds 2
    } else {
        Write-Host "⚠ Skipping $service (not built)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend Services Started" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Started Services: $($startedServices.Count)" -ForegroundColor Cyan
$startedServices | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
foreach ($service in $startedServices) {
    $port = $servicePorts[$service]
    Write-Host "  - $service : http://localhost:$port" -ForegroundColor Gray
}
Write-Host ""
Write-Host "API Gateway: http://localhost:9080" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop services, close the PowerShell windows." -ForegroundColor Yellow
Write-Host ""

