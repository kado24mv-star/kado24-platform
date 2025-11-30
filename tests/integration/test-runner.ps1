# =============================================
# Integration Test Runner
# Main script to run all integration tests
# =============================================

param(
    [switch]$SkipPrerequisites,
    [switch]$OAuth2Only,
    [switch]$GatewayOnly,
    [switch]$ApiOnly,
    [switch]$All
)

$ErrorActionPreference = "Stop"

# Import test utilities
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptPath\test-config.ps1"
. "$scriptPath\test-utils.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform Integration Tests" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (-not $SkipPrerequisites) {
    Write-Host "Checking prerequisites..." -ForegroundColor Yellow
    
    # Check if services are running
    $services = @(
        @{Name = "Auth Service"; Url = "$script:AUTH_SERVICE_URL/actuator/health"},
        @{Name = "API Gateway"; Url = "$script:API_GATEWAY_URL/health"}
    )
    
    $allServicesReady = $true
    foreach ($service in $services) {
        try {
            $response = Invoke-WebRequest -Uri $service.Url -Method GET -TimeoutSec 5 -ErrorAction Stop
            Write-Host "  ✅ $($service.Name) is running" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ $($service.Name) is not running" -ForegroundColor Red
            $allServicesReady = $false
        }
    }
    
    if (-not $allServicesReady) {
        Write-Host ""
        Write-Host "Some services are not running. Please start them first:" -ForegroundColor Yellow
        Write-Host "  docker-compose -f docker-compose.services.yml up -d" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or run with -SkipPrerequisites to continue anyway" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    
    Write-Host ""
}

# Wait for services to be fully ready
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Wait-ForService -Url $script:AUTH_SERVICE_URL -Timeout 30 | Out-Null
Wait-ForService -Url $script:API_GATEWAY_URL -Timeout 30 | Out-Null
Write-Host ""

# Run tests based on flags
$testResults = @()

if ($All -or (-not $OAuth2Only -and -not $GatewayOnly -and -not $ApiOnly)) {
    # Run all tests
    Write-Host "Running all integration tests..." -ForegroundColor Cyan
    Write-Host ""
    
    # OAuth2 Tests
    & "$scriptPath\test-oauth2.ps1"
    
    # Gateway Tests
    & "$scriptPath\test-gateway.ps1"
    
    # API Endpoint Tests
    . "$scriptPath\test-api-endpoints.ps1"
    Test-ServiceHealthChecks
    Test-UserServiceEndpoints
    Test-VoucherServiceEndpoints
    Test-MerchantServiceEndpoints
    Test-OrderServiceEndpoints
} else {
    if ($OAuth2Only) {
        Write-Host "Running OAuth2 tests only..." -ForegroundColor Cyan
        Write-Host ""
        & "$scriptPath\test-oauth2.ps1"
    }
    
    if ($GatewayOnly) {
        Write-Host "Running Gateway tests only..." -ForegroundColor Cyan
        Write-Host ""
        & "$scriptPath\test-gateway.ps1"
    }
    
    if ($ApiOnly) {
        Write-Host "Running API endpoint tests only..." -ForegroundColor Cyan
        Write-Host ""
        & "$scriptPath\test-api-endpoints.ps1"
    }
}

# Show summary
$allPassed = Show-TestSummary

# Exit with appropriate code
if ($allPassed) {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Some tests failed!" -ForegroundColor Red
    exit 1
}

