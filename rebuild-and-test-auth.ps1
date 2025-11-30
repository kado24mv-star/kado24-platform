# =============================================
# Automated Rebuild and Test Script for Auth Service
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Rebuilding and Testing Auth Service" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Rebuild
Write-Host "Step 1: Rebuilding auth-service..." -ForegroundColor Yellow
docker-compose -f docker-compose.services.yml build auth-service
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Build successful" -ForegroundColor Green
Write-Host ""

# Step 2: Restart
Write-Host "Step 2: Restarting auth-service..." -ForegroundColor Yellow
docker-compose -f docker-compose.services.yml restart auth-service
Write-Host "  Waiting for service to start (45 seconds)..." -ForegroundColor Gray
Start-Sleep -Seconds 45
Write-Host "  ✅ Service restarted" -ForegroundColor Green
Write-Host ""

# Step 3: Verify health
Write-Host "Step 3: Verifying service health..." -ForegroundColor Yellow
for ($i = 1; $i -le 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ Auth Service is healthy" -ForegroundColor Green
            break
        }
    } catch {
        if ($i -eq 10) {
            Write-Host "  ⚠️  Service may still be starting" -ForegroundColor Yellow
        } else {
            Write-Host "  Attempt $i/10: Waiting..." -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    }
}
Write-Host ""

# Step 4: Test OAuth2 token endpoint
Write-Host "Step 4: Testing OAuth2 token endpoint..." -ForegroundColor Yellow
$body = "grant_type=client_credentials&client_id=kado24-backend&client_secret=kado24-backend-secret&scope=read write"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/oauth2/token" -Method POST -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} -Body $body -ErrorAction Stop
    Write-Host "  ✅ OAuth2 Token Endpoint: Working (Status: $($response.StatusCode))" -ForegroundColor Green
    $json = $response.Content | ConvertFrom-Json
    Write-Host "  Token Type: $($json.token_type)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ OAuth2 Token Endpoint: Failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Test OIDC discovery
Write-Host "Step 5: Testing OIDC discovery endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/.well-known/openid-configuration" -Method GET -ErrorAction Stop
    Write-Host "  ✅ OIDC Discovery: Working (Status: $($response.StatusCode))" -ForegroundColor Green
    $json = $response.Content | ConvertFrom-Json
    Write-Host "  Issuer: $($json.issuer)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ OIDC Discovery: Failed" -ForegroundColor Red
}
Write-Host ""

# Step 6: Run integration tests
Write-Host "Step 6: Running integration tests..." -ForegroundColor Yellow
Write-Host ""
& .\tests\run-all-tests.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Process Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
