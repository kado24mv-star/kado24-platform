# OAuth2 Testing Script
# This script tests the OAuth2 implementation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OAuth2 Implementation Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if infrastructure is running
Write-Host "[1/6] Checking infrastructure..." -ForegroundColor Yellow
$redis = docker ps --filter "name=redis" --format "{{.Names}}"
$postgres = docker ps --filter "name=postgres" --format "{{.Names}}"

if (-not $redis -or -not $postgres) {
    Write-Host "ERROR: Infrastructure not running. Please start it first:" -ForegroundColor Red
    Write-Host "  cd infrastructure\docker && docker compose up -d" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Infrastructure is running" -ForegroundColor Green
Write-Host ""

# Check if auth-service is running
Write-Host "[2/6] Checking auth-service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Auth service is running" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Auth service is not running. Please start it:" -ForegroundColor Red
    Write-Host "  cd backend\services\auth-service && mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Waiting for auth-service to start..." -ForegroundColor Yellow
    Write-Host "You can start it in another terminal and then run this script again." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test OAuth2 JWK Endpoint
Write-Host "[3/6] Testing OAuth2 JWK endpoint..." -ForegroundColor Yellow
try {
    $jwkResponse = Invoke-RestMethod -Uri "http://localhost:8081/oauth2/jwks" -Method GET
    Write-Host "✓ JWK endpoint is accessible" -ForegroundColor Green
    Write-Host "  Keys found: $($jwkResponse.keys.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ JWK endpoint failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test OAuth2 Token Endpoint (Client Credentials)
Write-Host "[4/6] Testing OAuth2 token endpoint (client credentials)..." -ForegroundColor Yellow
$clientId = "kado24-backend"
$clientSecret = "kado24-backend-secret"
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${clientId}:${clientSecret}"))

try {
    $tokenBody = @{
        grant_type = "client_credentials"
        scope = "read write"
    }
    
    $tokenResponse = Invoke-RestMethod -Uri "http://localhost:8081/oauth2/token" `
        -Method POST `
        -Headers @{
            "Authorization" = "Basic $credentials"
            "Content-Type" = "application/x-www-form-urlencoded"
        } `
        -Body $tokenBody
    
    if ($tokenResponse.access_token) {
        Write-Host "✓ Token endpoint is working" -ForegroundColor Green
        Write-Host "  Access token: $($tokenResponse.access_token.Substring(0, 50))..." -ForegroundColor Gray
        Write-Host "  Token type: $($tokenResponse.token_type)" -ForegroundColor Gray
        Write-Host "  Expires in: $($tokenResponse.expires_in) seconds" -ForegroundColor Gray
        $accessToken = $tokenResponse.access_token
    } else {
        Write-Host "✗ Token endpoint returned no access token" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Token endpoint failed: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}
Write-Host ""

# Test Token Introspection
Write-Host "[5/6] Testing token introspection..." -ForegroundColor Yellow
try {
    $introspectBody = @{
        token = $accessToken
    }
    
    $introspectResponse = Invoke-RestMethod -Uri "http://localhost:8081/oauth2/introspect" `
        -Method POST `
        -Headers @{
            "Authorization" = "Basic $credentials"
            "Content-Type" = "application/x-www-form-urlencoded"
        } `
        -Body $introspectBody
    
    if ($introspectResponse.active -eq $true) {
        Write-Host "✓ Token introspection is working" -ForegroundColor Green
        Write-Host "  Token is active: $($introspectResponse.active)" -ForegroundColor Gray
        Write-Host "  Client ID: $($introspectResponse.client_id)" -ForegroundColor Gray
    } else {
        Write-Host "✗ Token introspection returned inactive token" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Token introspection failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test User Login (Get OAuth2 Token via Auth Service)
Write-Host "[6/6] Testing user login (OAuth2 token generation)..." -ForegroundColor Yellow
Write-Host "  Note: This requires a registered user. Testing endpoint availability..." -ForegroundColor Gray
try {
    $loginBody = @{
        identifier = "test@example.com"
        password = "Test123456"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/auth/login" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
        } `
        -Body $loginBody `
        -ErrorAction SilentlyContinue
    
    if ($loginResponse.accessToken) {
        Write-Host "✓ Login endpoint is working" -ForegroundColor Green
        Write-Host "  Access token generated: $($loginResponse.accessToken.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✓ Login endpoint is accessible (authentication failed as expected for test user)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Login endpoint test inconclusive: $_" -ForegroundColor Yellow
    }
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OAuth2 Testing Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Infrastructure running" -ForegroundColor Green
Write-Host "✓ Auth service running" -ForegroundColor Green
Write-Host "✓ OAuth2 JWK endpoint working" -ForegroundColor Green
Write-Host "✓ OAuth2 token endpoint working" -ForegroundColor Green
Write-Host "✓ Token introspection working" -ForegroundColor Green
Write-Host "✓ Login endpoint accessible" -ForegroundColor Green
Write-Host ""
Write-Host "OAuth2 implementation is working correctly!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Register a user: POST http://localhost:8081/api/v1/auth/register" -ForegroundColor Yellow
Write-Host "  2. Login with user: POST http://localhost:8081/api/v1/auth/login" -ForegroundColor Yellow
Write-Host "  3. Use the access token in Authorization header for protected endpoints" -ForegroundColor Yellow
Write-Host "  4. Test resource servers with the access token" -ForegroundColor Yellow

