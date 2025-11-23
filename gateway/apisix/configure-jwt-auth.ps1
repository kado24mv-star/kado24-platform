# Configure JWT Auth in APISIX for Wallet Service
# This script properly sets up JWT authentication at the gateway level

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

# JWT Secret (must match backend services)
# Default: kado24-secret-key-change-this-in-production-minimum-256-bits-required-for-security
$JWT_SECRET = "kado24-secret-key-change-this-in-production-minimum-256-bits-required-for-security"

Write-Host "`n=== Configuring JWT Auth in APISIX ===" -ForegroundColor Cyan
Write-Host "`nThis will:" -ForegroundColor Yellow
Write-Host "  1. Create a JWT consumer in APISIX" -ForegroundColor White
Write-Host "  2. Configure JWT secret (must match backend)" -ForegroundColor White
Write-Host "  3. Enable jwt-auth on wallet routes" -ForegroundColor White
Write-Host "`nNote: JWT secret must match backend services!" -ForegroundColor Yellow
Write-Host "  Backend uses: $JWT_SECRET" -ForegroundColor Gray
Write-Host ""

# Step 1: Create JWT Consumer
Write-Host "Step 1: Creating JWT consumer..." -ForegroundColor Cyan

$consumerConfig = @{
    username = "wallet-jwt-consumer"
    plugins = @{
        jwt_auth = @{
            key = "wallet-service-key"
            secret = $JWT_SECRET
            algorithm = "HS256"
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/consumers" -Method PUT -Headers $headers -Body $consumerConfig -ErrorAction Stop
    Write-Host "  ✅ JWT consumer created successfully" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Consumer may already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    # Try to update existing consumer
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/consumers/wallet-jwt-consumer" -Method PUT -Headers $headers -Body $consumerConfig -ErrorAction Stop
        Write-Host "  ✅ JWT consumer updated successfully" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Failed to create/update consumer: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Update wallet routes to use jwt-auth
Write-Host "`nStep 2: Updating wallet routes to use jwt-auth..." -ForegroundColor Cyan

$CORS_CONFIG = @{
    allow_origins = "http://localhost:4200,http://localhost:8001,http://localhost:8002"
    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
    expose_headers = "Authorization,Content-Type,Accept"
    max_age = 3600
    allow_credential = $true
}

# Route 19: /api/v1/wallet
Write-Host "  Updating route 19..." -ForegroundColor Yellow
$route19 = @{
    name = "wallet-service-base-route"
    uri = "/api/v1/wallet"
    methods = @("GET","POST","PUT","DELETE","OPTIONS")
    upstream_id = "wallet-service-upstream"
    plugins = @{
        cors = $CORS_CONFIG
        jwt_auth = @{}
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/19" -Method PUT -Headers $headers -Body $route19 -ErrorAction Stop
    Write-Host "    ✅ Route 19 updated" -ForegroundColor Green
} catch {
    Write-Host "    ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Route 9: /api/v1/wallet/*
Write-Host "  Updating route 9..." -ForegroundColor Yellow
$route9 = @{
    name = "wallet-service-route"
    uri = "/api/v1/wallet/*"
    methods = @("GET","POST","PUT","DELETE","OPTIONS")
    upstream_id = "wallet-service-upstream"
    plugins = @{
        cors = $CORS_CONFIG
        jwt_auth = @{}
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/9" -Method PUT -Headers $headers -Body $route9 -ErrorAction Stop
    Write-Host "    ✅ Route 9 updated" -ForegroundColor Green
} catch {
    Write-Host "    ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ JWT Auth configured in APISIX!" -ForegroundColor Green
Write-Host "`nImportant Notes:" -ForegroundColor Yellow
Write-Host "  1. APISIX will now validate JWT tokens at the gateway level" -ForegroundColor White
Write-Host "  2. Backend wallet service will still validate (redundant but safe)" -ForegroundColor White
Write-Host "  3. Invalid tokens will be rejected by APISIX (403) before reaching backend" -ForegroundColor White
Write-Host "  4. JWT secret must match between APISIX and backend services" -ForegroundColor White
Write-Host "`nTo disable backend validation (since APISIX handles it):" -ForegroundColor Cyan
Write-Host "  Modify WalletSecurityConfig.java to skip JWT validation" -ForegroundColor Gray
Write-Host "  (Not recommended - defense in depth is better)" -ForegroundColor Gray
Write-Host ""

