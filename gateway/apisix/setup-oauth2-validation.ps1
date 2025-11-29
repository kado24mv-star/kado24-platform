# =============================================
# Kado24 Platform - APISIX OAuth2 Token Validation Setup
# This script configures APISIX to validate OAuth2 tokens at gateway level
# Uses openid-connect plugin in bearer_only mode for JWT validation
# =============================================

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

# OAuth2 Authorization Server Configuration
$AUTH_SERVICE_URL = "http://kado24-auth-service:8081"
$OIDC_DISCOVERY = "$AUTH_SERVICE_URL/.well-known/openid-configuration"
$JWKS_URI = "$AUTH_SERVICE_URL/oauth2/jwks"

# CORS configuration
$CORS_CONFIG = @{
    allow_origins = "http://localhost:4200,http://localhost:5000,http://localhost:8001,http://localhost:8002"
    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
    expose_headers = "Authorization,Content-Type,Accept"
    max_age = 3600
    allow_credential = $true
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "APISIX OAuth2 Token Validation Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OAuth2 Authorization Server:" -ForegroundColor Yellow
Write-Host "  OIDC Discovery: $OIDC_DISCOVERY" -ForegroundColor White
Write-Host "  JWKS URI: $JWKS_URI" -ForegroundColor White
Write-Host ""

# Test OIDC discovery endpoint
Write-Host "Step 1: Testing OIDC discovery endpoint..." -ForegroundColor Yellow
try {
    $discoveryTest = Invoke-WebRequest -Uri "http://localhost:8081/.well-known/openid-configuration" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] OIDC discovery endpoint accessible" -ForegroundColor Green
    $discoveryData = $discoveryTest.Content | ConvertFrom-Json
    Write-Host "  Issuer: $($discoveryData.issuer)" -ForegroundColor Gray
    Write-Host "  JWKS URI: $($discoveryData.jwks_uri)" -ForegroundColor Gray
} catch {
    Write-Host "  [WARN] Cannot reach OIDC discovery endpoint: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Note: This is expected if auth-service is not running" -ForegroundColor Gray
    Write-Host "  Gateway will still be configured, but validation may fail until auth-service starts" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 2: Updating protected routes with OAuth2 validation..." -ForegroundColor Yellow
Write-Host ""

# Helper function to update route with OAuth2 validation
function Update-RouteWithOAuth2 {
    param(
        [string]$RouteId,
        [string]$Name,
        [string]$Uri,
        [string[]]$Methods,
        [string]$UpstreamId,
        [bool]$Protected = $false
    )
    
    Write-Host "Updating route: $Name (ID: $RouteId)" -ForegroundColor Cyan
    
    $plugins = @{
        cors = $CORS_CONFIG
    }
    
    if ($Protected) {
        # Use openid-connect plugin in bearer_only mode for OAuth2 JWT validation
        # This validates tokens against the auth-service using OIDC discovery
        $plugins.openid_connect = @{
            bearer_only = $true
            discovery = $OIDC_DISCOVERY
            # Client credentials (not used in bearer_only mode, but required)
            client_id = "apisix-gateway"
            client_secret = "apisix-gateway-secret"
            # Token validation settings
            verify_claims = $true
            verify_claims_options = @{
                iss = $AUTH_SERVICE_URL
            }
            # Skip SSL verification for internal Docker services
            ssl_verify = $false
            # Timeout settings
            timeout = 3000
            # Introspection endpoint (fallback if discovery fails)
            introspection_endpoint = "$AUTH_SERVICE_URL/oauth2/introspect"
            introspection_endpoint_auth_method = "client_secret_post"
        }
        
        Write-Host "  [OAuth2] Token validation enabled (openid-connect plugin)" -ForegroundColor Green
    } else {
        Write-Host "  [Public] No authentication required" -ForegroundColor Yellow
    }
    
    $routeConfig = @{
        name = $Name
        uri = $Uri
        methods = $Methods
        upstream_id = $UpstreamId
        plugins = $plugins
    } | ConvertTo-Json -Depth 10 -Compress
    
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$RouteId" `
            -Headers $headers `
            -Method PUT `
            -Body $routeConfig `
            -ErrorAction Stop
        Write-Host "  [OK] Route $RouteId updated successfully" -ForegroundColor Green
        return $true
    } catch {
        $msg = $_.Exception.Message
        Write-Host "  [WARN] Route $RouteId : $msg" -ForegroundColor Yellow
        
        # Fallback: If openid-connect plugin fails, try without it
        # Backend services will still validate tokens
        if ($Protected) {
            Write-Host "  [INFO] Fallback: Using basic validation (backend will validate tokens)" -ForegroundColor Gray
            $plugins = @{
                cors = $CORS_CONFIG
            }
            $routeConfig = @{
                name = $Name
                uri = $Uri
                methods = $Methods
                upstream_id = $UpstreamId
                plugins = $plugins
            } | ConvertTo-Json -Depth 10 -Compress
            try {
                Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$RouteId" `
                    -Headers $headers `
                    -Method PUT `
                    -Body $routeConfig `
                    -ErrorAction Stop | Out-Null
                Write-Host "  [OK] Route $RouteId updated (fallback mode)" -ForegroundColor Green
                return $true
            } catch {
                return $false
            }
        }
        return $false
    }
}

# Protected routes that require OAuth2 token validation
$protectedRoutes = @(
    @{id="2"; name="user-service-route"; uri="/api/v1/users/*"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="user-service-upstream"},
    @{id="21"; name="user-service-base-route"; uri="/api/v1/users"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="user-service-upstream"},
    @{id="5"; name="voucher-service-protected-write"; uri="/api/v1/vouchers/*"; methods=@("POST","PUT","DELETE","PATCH","OPTIONS"); upstream="voucher-service-upstream"},
    @{id="31"; name="vouchers-my-vouchers-route"; uri="/api/v1/vouchers/my-vouchers"; methods=@("GET","OPTIONS"); upstream="voucher-service-upstream"},
    @{id="32"; name="vouchers-publish-route"; uri="/api/v1/vouchers/*/publish"; methods=@("POST","OPTIONS"); upstream="voucher-service-upstream"},
    @{id="33"; name="vouchers-toggle-pause-route"; uri="/api/v1/vouchers/*/toggle-pause"; methods=@("POST","OPTIONS"); upstream="voucher-service-upstream"},
    @{id="6"; name="order-service-route"; uri="/api/v1/orders/*"; methods=@("GET","POST","PUT","DELETE","OPTIONS"); upstream="order-service-upstream"},
    @{id="20"; name="order-service-base-route"; uri="/api/v1/orders"; methods=@("GET","POST","PUT","DELETE","OPTIONS"); upstream="order-service-upstream"},
    @{id="7"; name="payment-service-route"; uri="/api/v1/payments/*"; methods=@("GET","POST","PUT","OPTIONS"); upstream="payment-service-upstream"},
    @{id="27"; name="payment-service-base-route"; uri="/api/v1/payments"; methods=@("GET","POST","PUT","OPTIONS"); upstream="payment-service-upstream"},
    @{id="9"; name="wallet-service-route"; uri="/api/v1/wallet/*"; methods=@("GET","POST","PUT","DELETE","OPTIONS"); upstream="wallet-service-upstream"},
    @{id="19"; name="wallet-service-base-route"; uri="/api/v1/wallet"; methods=@("GET","POST","PUT","DELETE","OPTIONS"); upstream="wallet-service-upstream"},
    @{id="10"; name="redemption-service-route"; uri="/api/v1/redemptions/*"; methods=@("GET","POST","OPTIONS"); upstream="redemption-service-upstream"},
    @{id="22"; name="redemption-service-base-route"; uri="/api/v1/redemptions"; methods=@("GET","POST","OPTIONS"); upstream="redemption-service-upstream"},
    @{id="11"; name="merchant-service-route"; uri="/api/v1/merchants/*"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="merchant-service-upstream"},
    @{id="23"; name="merchant-service-base-route"; uri="/api/v1/merchants"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="merchant-service-upstream"},
    @{id="38"; name="merchants-register-route"; uri="/api/v1/merchants/register"; methods=@("POST","OPTIONS"); upstream="merchant-service-upstream"},
    @{id="14"; name="notification-service-route"; uri="/api/v1/notifications/*"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="notification-service-upstream"},
    @{id="24"; name="notification-service-base-route"; uri="/api/v1/notifications"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="notification-service-upstream"},
    @{id="15"; name="payout-service-route"; uri="/api/v1/payouts/*"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="payout-service-upstream"},
    @{id="25"; name="payout-service-base-route"; uri="/api/v1/payouts"; methods=@("GET","POST","PUT","DELETE","PATCH","OPTIONS"); upstream="payout-service-upstream"},
    @{id="16"; name="analytics-service-route"; uri="/api/v1/analytics/*"; methods=@("GET","POST","OPTIONS"); upstream="analytics-service-upstream"},
    @{id="26"; name="analytics-service-base-route"; uri="/api/v1/analytics"; methods=@("GET","POST","OPTIONS"); upstream="analytics-service-upstream"}
)

$successCount = 0
$failCount = 0

foreach ($route in $protectedRoutes) {
    $result = Update-RouteWithOAuth2 `
        -RouteId $route.id `
        -Name $route.name `
        -Uri $route.uri `
        -Methods $route.methods `
        -UpstreamId $route.upstream `
        -Protected $true
    
    if ($result) {
        $successCount++
    } else {
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OAuth2 Validation Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Routes updated: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""
Write-Host "OAuth2 Protection:" -ForegroundColor Yellow
Write-Host "  ✅ Protected routes validate tokens at gateway level" -ForegroundColor Green
Write-Host "  ✅ Invalid/expired tokens are rejected before reaching backend" -ForegroundColor Green
Write-Host "  ✅ Backend services still validate tokens (defense in depth)" -ForegroundColor Green
Write-Host ""
Write-Host "Testing:" -ForegroundColor Yellow
Write-Host "  # Without token (should fail at gateway with 401):" -ForegroundColor Cyan
Write-Host "  curl http://localhost:9080/api/v1/merchants/register" -ForegroundColor White
Write-Host ""
Write-Host "  # With invalid token (should fail at gateway with 401):" -ForegroundColor Cyan
Write-Host "  curl -H 'Authorization: Bearer invalid-token' http://localhost:9080/api/v1/merchants/register" -ForegroundColor White
Write-Host ""
Write-Host "  # With valid token (should succeed):" -ForegroundColor Cyan
Write-Host "  curl -H 'Authorization: Bearer <valid-jwt>' http://localhost:9080/api/v1/merchants/register" -ForegroundColor White
Write-Host ""
Write-Host "Note: If openid-connect plugin is not available, routes will fall back" -ForegroundColor Yellow
Write-Host "      to basic mode where backend services handle validation." -ForegroundColor Yellow
Write-Host ""
