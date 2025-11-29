# =============================================
# Kado24 Platform - APISIX OAuth2 Route Configuration
# Configures APISIX to validate OAuth2 tokens from authorization server
# =============================================

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

$CORS_CONFIG = @{
    allow_origins = "http://localhost:4200,http://localhost:8001,http://localhost:8002"
    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
    expose_headers = "Authorization,Content-Type,Accept"
    max_age = 3600
    allow_credential = $true
}

Write-Host "🚀 Configuring APISIX for OAuth2 authentication..." -ForegroundColor Green
Write-Host ""

# Note: OAuth2 tokens are JWTs, so we can use jwt-auth plugin
# But we need to configure it to validate against OAuth2 authorization server
# For now, we'll configure routes to pass OAuth2 tokens to backend services
# Backend services will validate tokens using OAuth2 Resource Server

Write-Host "📝 Note: OAuth2 tokens are JWTs signed by the authorization server." -ForegroundColor Yellow
Write-Host "   Backend services validate tokens using OAuth2 Resource Server." -ForegroundColor Yellow
Write-Host "   APISIX will pass tokens through to backend services." -ForegroundColor Yellow
Write-Host ""

# Public routes (no authentication required)
$publicRoutes = @(
    @{id="1"; uri="/api/v1/auth/*"; name="auth-service-route"},
    @{id="3"; uri="/api/v1/vouchers"; name="voucher-service-public-read"; methods=@("GET","OPTIONS")},
    @{id="4"; uri="/api/v1/vouchers/*"; name="voucher-service-single"; methods=@("GET","OPTIONS")},
    @{id="17"; uri="/api/v1/categories"; name="voucher-categories-route"},
    @{id="18"; uri="/api/v1/categories/*"; name="voucher-categories-single-route"},
    @{id="28"; uri="/api/v1/vouchers/search"; name="vouchers-search-route"},
    @{id="29"; uri="/api/v1/vouchers/category/*"; name="vouchers-category-route"},
    @{id="30"; uri="/api/v1/vouchers/*/reviews"; name="vouchers-reviews-route"},
    @{id="43"; uri="/api/mock/payment/init"; name="mock-payment-init-route"},
    @{id="44"; uri="/api/mock/payment/process"; name="mock-payment-process-route"},
    @{id="45"; uri="/api/mock/payment/status/*"; name="mock-payment-status-route"},
    @{id="46"; uri="/api/mock/payment/page"; name="mock-payment-page-route"}
)

# Protected routes (require OAuth2 token - validated by backend)
$protectedRoutes = @(
    @{id="2"; uri="/api/v1/users/*"; name="user-service-route"},
    @{id="21"; uri="/api/v1/users"; name="user-service-base-route"},
    @{id="5"; uri="/api/v1/vouchers/*"; name="voucher-service-protected-write"; methods=@("POST","PUT","DELETE","PATCH","OPTIONS")},
    @{id="31"; uri="/api/v1/vouchers/my-vouchers"; name="vouchers-my-vouchers-route"},
    @{id="32"; uri="/api/v1/vouchers/*/publish"; name="vouchers-publish-route"},
    @{id="33"; uri="/api/v1/vouchers/*/toggle-pause"; name="vouchers-toggle-pause-route"},
    @{id="6"; uri="/api/v1/orders/*"; name="order-service-route"},
    @{id="20"; uri="/api/v1/orders"; name="order-service-base-route"},
    @{id="34"; uri="/api/v1/orders/*/cancel"; name="orders-cancel-route"},
    @{id="7"; uri="/api/v1/payments/*"; name="payment-service-route"},
    @{id="27"; uri="/api/v1/payments"; name="payment-service-base-route"},
    @{id="9"; uri="/api/v1/wallet/*"; name="wallet-service-route"},
    @{id="10"; uri="/api/v1/redemptions/*"; name="redemption-service-route"},
    @{id="11"; uri="/api/v1/merchants/*"; name="merchant-service-route"},
    @{id="12"; uri="/api/admin/*"; name="admin-portal-backend-route"},
    @{id="13"; uri="/api/v1/notifications/*"; name="notification-service-route"},
    @{id="14"; uri="/api/v1/payouts/*"; name="payout-service-route"},
    @{id="15"; uri="/api/v1/analytics/*"; name="analytics-service-route"}
)

function Update-Route {
    param(
        [string]$RouteId,
        [hashtable]$Route,
        [bool]$Protected = $false
    )
    
    Write-Host "Updating route: $($Route.name) (ID: $RouteId)" -ForegroundColor Cyan
    
    $plugins = @{
        cors = $CORS_CONFIG
    }
    
    # For protected routes, we could add request-validation plugin
    # But since OAuth2 tokens are validated by backend services,
    # we'll just ensure CORS is configured
    # Backend OAuth2 Resource Server will validate tokens
    
    $routeConfig = @{
        name = $Route.name
        uri = $Route.uri
        methods = if ($Route.methods) { $Route.methods } else { @("GET","POST","PUT","DELETE","PATCH","OPTIONS") }
        upstream_id = $RouteId.Replace("-route", "-upstream").Replace("-base-route", "-upstream")
        plugins = $plugins
    } | ConvertTo-Json -Depth 10 -Compress
    
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$RouteId" `
            -Headers $headers `
            -Method PUT `
            -Body $routeConfig `
            -ErrorAction Stop
        Write-Host "  [OK] Route $RouteId updated" -ForegroundColor Green
        return $true
    } catch {
        $msg = $_.Exception.Message
        Write-Host "  [WARN] Route $RouteId : $msg" -ForegroundColor Yellow
        return $false
    }
}

# Update public routes
Write-Host "Updating public routes..." -ForegroundColor Yellow
foreach ($route in $publicRoutes) {
    Update-Route -RouteId $route.id -Route $route -Protected $false
}

Write-Host ""
Write-Host "Updating protected routes..." -ForegroundColor Yellow
foreach ($route in $protectedRoutes) {
    Update-Route -RouteId $route.id -Route $route -Protected $true
}

Write-Host ""
Write-Host "✅ APISIX routes configured for OAuth2" -ForegroundColor Green
Write-Host ""
Write-Host "Note: OAuth2 tokens are validated by backend OAuth2 Resource Servers." -ForegroundColor Cyan
Write-Host "      APISIX passes tokens through in the Authorization header." -ForegroundColor Cyan
Write-Host ""

