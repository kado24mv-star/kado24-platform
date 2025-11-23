# Fix all APISIX routes to have jwt-auth on protected routes (except auth routes)
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

Write-Host "`n=== Fixing APISIX Routes with JWT Auth ===" -ForegroundColor Cyan
Write-Host ""

# Public routes (should NOT have jwt-auth)
$publicRoutes = @(
    @{id="1"; uri="/api/v1/auth/*"; name="auth-service-route"},
    @{id="3"; uri="/api/v1/vouchers"; name="voucher-service-public-read"},
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

# Protected routes (SHOULD have jwt-auth)
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
    @{id="19"; uri="/api/v1/wallet"; name="wallet-service-base-route"},
    @{id="35"; uri="/api/v1/wallet/*/gift"; name="wallet-gift-route"},
    @{id="10"; uri="/api/v1/redemptions/*"; name="redemption-service-route"},
    @{id="22"; uri="/api/v1/redemptions"; name="redemption-service-base-route"},
    @{id="36"; uri="/api/v1/redemptions/redeem"; name="redemptions-redeem-route"},
    @{id="37"; uri="/api/v1/redemptions/my-redemptions"; name="redemptions-my-redemptions-route"},
    @{id="11"; uri="/api/v1/merchants/*"; name="merchant-service-route"},
    @{id="23"; uri="/api/v1/merchants"; name="merchant-service-base-route"},
    @{id="38"; uri="/api/v1/merchants/register"; name="merchants-register-route"},
    @{id="39"; uri="/api/v1/merchants/my-profile"; name="merchants-my-profile-route"},
    @{id="40"; uri="/api/v1/merchants/my-statistics"; name="merchants-my-statistics-route"},
    @{id="12"; uri="/api/v1/admin/*"; name="admin-portal-backend-route"},
    @{id="14"; uri="/api/v1/notifications/*"; name="notification-service-route"},
    @{id="24"; uri="/api/v1/notifications"; name="notification-service-base-route"},
    @{id="41"; uri="/api/v1/notifications/*/read"; name="notifications-read-route"},
    @{id="42"; uri="/api/v1/notifications/read-all"; name="notifications-read-all-route"},
    @{id="15"; uri="/api/v1/payouts/*"; name="payout-service-route"},
    @{id="25"; uri="/api/v1/payouts"; name="payout-service-base-route"},
    @{id="16"; uri="/api/v1/analytics/*"; name="analytics-service-route"},
    @{id="26"; uri="/api/v1/analytics"; name="analytics-service-base-route"},
    @{id="52"; uri="/api/v1/admin/verifications/pending"; name="admin-verifications-pending-route"},
    @{id="53"; uri="/api/v1/admin/verifications/*/verify"; name="admin-verifications-verify-route"},
    @{id="54"; uri="/api/v1/admin/verifications/*/reject"; name="admin-verifications-reject-route"}
)

Write-Host "Fixing public routes (removing jwt-auth)..." -ForegroundColor Yellow
foreach ($route in $publicRoutes) {
    $methods = if ($route.methods) { $route.methods } else { @("GET","POST","PUT","DELETE","OPTIONS") }
    $upstreamId = switch -Wildcard ($route.uri) {
        "*auth*" { "auth-service-upstream" }
        "*vouchers*" { "voucher-service-upstream" }
        "*categories*" { "voucher-service-upstream" }
        "*payment*" { "payment-service-upstream" }
        default { "voucher-service-upstream" }
    }
    
    $routeConfig = @{
        name = $route.name
        uri = $route.uri
        methods = $methods
        upstream_id = $upstreamId
        plugins = @{
            cors = $CORS_CONFIG
        }
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$($route.id)" -Method PUT -Headers $headers -Body $routeConfig -ErrorAction Stop | Out-Null
        Write-Host "  ✅ Route $($route.id) ($($route.uri)) - Public (no jwt-auth)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Route $($route.id): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`nFixing protected routes (adding jwt-auth)..." -ForegroundColor Yellow
foreach ($route in $protectedRoutes) {
    $methods = if ($route.methods) { $route.methods } else { @("GET","POST","PUT","DELETE","OPTIONS") }
    $upstreamId = switch -Wildcard ($route.uri) {
        "*users*" { "user-service-upstream" }
        "*vouchers*" { "voucher-service-upstream" }
        "*orders*" { "order-service-upstream" }
        "*payments*" { "order-service-upstream" }
        "*wallet*" { "wallet-service-upstream" }
        "*redemptions*" { "redemption-service-upstream" }
        "*merchants*" { "merchant-service-upstream" }
        "*admin*" { "auth-service-upstream" }
        "*notifications*" { "notification-service-upstream" }
        "*payouts*" { "payout-service-upstream" }
        "*analytics*" { "analytics-service-upstream" }
        default { "auth-service-upstream" }
    }
    
    $routeConfig = @{
        name = $route.name
        uri = $route.uri
        methods = $methods
        upstream_id = $upstreamId
        plugins = @{
            cors = $CORS_CONFIG
            "jwt-auth" = @{}
        }
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$($route.id)" -Method PUT -Headers $headers -Body $routeConfig -ErrorAction Stop | Out-Null
        Write-Host "  ✅ Route $($route.id) ($($route.uri)) - Protected (jwt-auth enabled)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Route $($route.id): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ All routes fixed!" -ForegroundColor Green
Write-Host "`nPublic routes (no jwt-auth):" -ForegroundColor Cyan
Write-Host "  - /api/v1/auth/* (login, register, etc.)" -ForegroundColor White
Write-Host "  - /api/v1/vouchers (public read)" -ForegroundColor White
Write-Host "  - /api/v1/categories" -ForegroundColor White
Write-Host "  - /api/mock/payment/*" -ForegroundColor White
Write-Host "`nProtected routes (jwt-auth enabled):" -ForegroundColor Cyan
Write-Host "  - All other routes require valid JWT token" -ForegroundColor White
Write-Host "  - 401/403 errors will redirect to login in frontend apps" -ForegroundColor White

