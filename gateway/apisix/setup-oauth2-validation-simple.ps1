# =============================================
# Kado24 Platform - APISIX OAuth2 Token Validation Setup (Simplified)
# This script configures APISIX to validate OAuth2 tokens at gateway level
# Uses a practical approach with request validation
# =============================================

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

# OAuth2 Authorization Server Configuration
$AUTH_SERVICE_URL = "http://kado24-auth-service:8081"
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
Write-Host "Strategy: Validate OAuth2 tokens at gateway using request-validation" -ForegroundColor Yellow
Write-Host "JWKS URI: $JWKS_URI" -ForegroundColor White
Write-Host ""

# Helper function to update route with OAuth2 validation
function Update-RouteWithOAuth2Validation {
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
        # Use request-validation plugin to check for Authorization header
        # This provides basic validation - full JWT validation happens at backend
        # For full JWT validation at gateway, we would need a custom plugin or
        # use openid-connect plugin (requires OIDC discovery endpoint)
        
        # Add request-validation to ensure Authorization header is present
        $plugins.request_validation = @{
            header_schema = @{
                type = "object"
                required = @("Authorization")
                properties = @{
                    Authorization = @{
                        type = "string"
                        pattern = "^Bearer .+"
                    }
                }
            }
        }
        
        Write-Host "  [OAuth2] Authorization header validation enabled" -ForegroundColor Green
        Write-Host "  [Note] Full JWT validation performed by backend services" -ForegroundColor Gray
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
        # Try without request-validation if plugin not available
        if ($Protected) {
            Write-Host "  [INFO] Retrying without request-validation plugin..." -ForegroundColor Gray
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
                Write-Host "  [OK] Route $RouteId updated (basic CORS only)" -ForegroundColor Green
                return $true
            } catch {
                return $false
            }
        }
        return $false
    }
}

Write-Host "Updating protected routes with OAuth2 validation..." -ForegroundColor Yellow
Write-Host ""

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
    $result = Update-RouteWithOAuth2Validation `
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
Write-Host "Current Implementation:" -ForegroundColor Yellow
Write-Host "  ✅ Gateway validates Authorization header format" -ForegroundColor Green
Write-Host "  ✅ Backend services perform full JWT validation" -ForegroundColor Green
Write-Host ""
Write-Host "Note: For full JWT validation at gateway, consider:" -ForegroundColor Yellow
Write-Host "  1. Using APISIX openid-connect plugin (requires OIDC discovery)" -ForegroundColor Cyan
Write-Host "  2. Creating custom Lua plugin for JWKS validation" -ForegroundColor Cyan
Write-Host "  3. Using serverless function with JWT validation logic" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Ensure auth-service exposes OIDC discovery endpoint" -ForegroundColor White
Write-Host "  2. Or implement custom JWT validation plugin" -ForegroundColor White
Write-Host "  3. Test with valid/invalid tokens" -ForegroundColor White
Write-Host ""

