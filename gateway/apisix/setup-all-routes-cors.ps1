# =============================================
# Kado24 Platform - Complete APISIX Route Configuration with CORS
# This script sets up ALL routes with CORS for all frontend apps
# Run this script after restarting your PC or Docker containers
# =============================================

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

# CORS configuration for all routes
$CORS_CONFIG = @{
    allow_origins = "http://localhost:4200,http://localhost:5000,http://localhost:8001,http://localhost:8002"
    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
    expose_headers = "Authorization,Content-Type,Accept"
    max_age = 3600
    allow_credential = $true
}

Write-Host "🚀 Configuring APISIX routes with CORS for Kado24 platform..." -ForegroundColor Green
Write-Host ""

# Helper function to create/update routes
function Create-Route {
    param(
        [string]$RouteId,
        [string]$Name,
        [string]$Uri,
        [string[]]$Methods,
        [string]$UpstreamId,
        [bool]$Protected = $false
    )
    
    Write-Host "Creating route: $Name (ID: $RouteId)" -ForegroundColor Cyan
    
    $plugins = @{
        cors = $CORS_CONFIG
    }
    
    # Note: OAuth2 token validation is configured separately using setup-oauth2-validation.ps1
    # This script only sets up CORS. For OAuth2 validation, run setup-oauth2-validation.ps1
    # if ($Protected) {
    #     $plugins.jwt_auth = @{}
    # }
    
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
        Write-Host "  [OK] Route $RouteId created successfully" -ForegroundColor Green
        return $true
    } catch {
        $msg = $_.Exception.Message
        Write-Host "  [WARN] Route $RouteId : $msg" -ForegroundColor Yellow
        return $false
    }
}

# Helper function to create upstream
function Create-Upstream {
    param(
        [string]$UpstreamId,
        [string]$ServiceName,
        [int]$Port
    )
    
    Write-Host "Creating upstream: $UpstreamId" -ForegroundColor Cyan
    
    $upstreamConfig = @{
        type = "roundrobin"
        nodes = @{
            "kado24-$ServiceName`:$Port" = 1
        }
    } | ConvertTo-Json -Compress
    
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/upstreams/$UpstreamId" `
            -Headers $headers `
            -Method PUT `
            -Body $upstreamConfig `
            -ErrorAction Stop
        Write-Host "  [OK] Upstream $UpstreamId created successfully" -ForegroundColor Green
        return $true
    } catch {
        $msg = $_.Exception.Message
        Write-Host "  [WARN] Upstream $UpstreamId : $msg" -ForegroundColor Yellow
        return $false
    }
}

# =============================================
# UPSTREAMS
# =============================================

Write-Host "Creating upstreams..." -ForegroundColor Yellow
Write-Host ""

Create-Upstream "auth-service-upstream" "auth-service" 8081
Create-Upstream "user-service-upstream" "user-service" 8082
Create-Upstream "voucher-service-upstream" "voucher-service" 8083
Create-Upstream "order-service-upstream" "order-service" 8084
Create-Upstream "wallet-service-upstream" "wallet-service" 8086
Create-Upstream "redemption-service-upstream" "redemption-service" 8087
Create-Upstream "merchant-service-upstream" "merchant-service" 8088
Create-Upstream "admin-portal-backend-upstream" "admin-portal-backend" 8089
Create-Upstream "notification-service-upstream" "notification-service" 8091
Create-Upstream "payout-service-upstream" "payout-service" 8092
Create-Upstream "analytics-service-upstream" "analytics-service" 8093
Create-Upstream "payment-service-upstream" "mock-payment-service" 8095

# =============================================
# ROUTES
# =============================================

Write-Host ""
Write-Host "Creating routes with CORS..." -ForegroundColor Yellow
Write-Host ""

# 1. Auth Service Routes (Public)
Create-Route "1" "auth-service-route" "/api/v1/auth/*" @("GET","POST","PUT","DELETE","OPTIONS") "auth-service-upstream" $false

# 2. User Service Routes (Protected)
Create-Route "2" "user-service-route" "/api/v1/users/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "user-service-upstream" $true
Create-Route "21" "user-service-base-route" "/api/v1/users" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "user-service-upstream" $true

# 3-5. Voucher Service Routes
Create-Route "3" "voucher-service-public-read" "/api/v1/vouchers" @("GET","OPTIONS") "voucher-service-upstream" $false
Create-Route "55" "voucher-service-create" "/api/v1/vouchers" @("POST","OPTIONS") "voucher-service-upstream" $false
Create-Route "4" "voucher-service-single" "/api/v1/vouchers/*" @("GET","OPTIONS") "voucher-service-upstream" $false
Create-Route "5" "voucher-service-protected-write" "/api/v1/vouchers/*" @("POST","PUT","DELETE","PATCH","OPTIONS") "voucher-service-upstream" $true
Create-Route "28" "vouchers-search-route" "/api/v1/vouchers/search" @("GET","OPTIONS") "voucher-service-upstream" $false
Create-Route "29" "vouchers-category-route" "/api/v1/vouchers/category/*" @("GET","OPTIONS") "voucher-service-upstream" $false
Create-Route "30" "vouchers-reviews-route" "/api/v1/vouchers/*/reviews" @("GET","POST","OPTIONS") "voucher-service-upstream" $false
Create-Route "31" "vouchers-my-vouchers-route" "/api/v1/vouchers/my-vouchers" @("GET","OPTIONS") "voucher-service-upstream" $true
Create-Route "32" "vouchers-publish-route" "/api/v1/vouchers/*/publish" @("POST","OPTIONS") "voucher-service-upstream" $true
Create-Route "33" "vouchers-toggle-pause-route" "/api/v1/vouchers/*/toggle-pause" @("POST","OPTIONS") "voucher-service-upstream" $true

# 6. Order Service Routes (Protected)
Create-Route "6" "order-service-route" "/api/v1/orders/*" @("GET","POST","PUT","DELETE","OPTIONS") "order-service-upstream" $true
Create-Route "20" "order-service-base-route" "/api/v1/orders" @("GET","POST","PUT","DELETE","OPTIONS") "order-service-upstream" $true
Create-Route "34" "orders-cancel-route" "/api/v1/orders/*/cancel" @("POST","OPTIONS") "order-service-upstream" $true

# 7. Payment Service Routes (Protected)
Create-Route "7" "payment-service-route" "/api/v1/payments/*" @("GET","POST","PUT","OPTIONS") "order-service-upstream" $true
Create-Route "27" "payment-service-base-route" "/api/v1/payments" @("GET","POST","PUT","OPTIONS") "order-service-upstream" $true

# 9. Wallet Service Routes (Protected with APISIX jwt-auth)
# Note: APISIX handles JWT validation at gateway level for better performance
Create-Route "9" "wallet-service-route" "/api/v1/wallet/*" @("GET","POST","PUT","DELETE","OPTIONS") "wallet-service-upstream" $true
Create-Route "19" "wallet-service-base-route" "/api/v1/wallet" @("GET","POST","PUT","DELETE","OPTIONS") "wallet-service-upstream" $true
Create-Route "35" "wallet-gift-route" "/api/v1/wallet/*/gift" @("POST","OPTIONS") "wallet-service-upstream" $true

# 10. Redemption Service Routes (Protected)
Create-Route "10" "redemption-service-route" "/api/v1/redemptions/*" @("GET","POST","OPTIONS") "redemption-service-upstream" $true
Create-Route "22" "redemption-service-base-route" "/api/v1/redemptions" @("GET","POST","OPTIONS") "redemption-service-upstream" $true
Create-Route "36" "redemptions-redeem-route" "/api/v1/redemptions/redeem" @("POST","OPTIONS") "redemption-service-upstream" $true
Create-Route "37" "redemptions-my-redemptions-route" "/api/v1/redemptions/my-redemptions" @("GET","OPTIONS") "redemption-service-upstream" $true

# 11. Merchant Service Routes (Protected)
Create-Route "11" "merchant-service-route" "/api/v1/merchants/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "merchant-service-upstream" $true
Create-Route "23" "merchant-service-base-route" "/api/v1/merchants" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "merchant-service-upstream" $true
Create-Route "38" "merchants-register-route" "/api/v1/merchants/register" @("POST","OPTIONS") "merchant-service-upstream" $true
Create-Route "39" "merchants-my-profile-route" "/api/v1/merchants/my-profile" @("GET","PUT","OPTIONS") "merchant-service-upstream" $true
Create-Route "40" "merchants-my-statistics-route" "/api/v1/merchants/my-statistics" @("GET","OPTIONS") "merchant-service-upstream" $true

# 12. Admin Portal Backend Routes
Create-Upstream "admin-portal-backend-upstream" "admin-portal-backend" 8089
Create-Route "12" "admin-portal-backend-route-v1" "/api/v1/admin/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "admin-portal-backend-upstream" $false
Create-Route "47" "admin-portal-backend-route" "/api/admin/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "admin-portal-backend-upstream" $false

# 14. Notification Service Routes (Protected)
Create-Route "14" "notification-service-route" "/api/v1/notifications/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "notification-service-upstream" $true
Create-Route "24" "notification-service-base-route" "/api/v1/notifications" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "notification-service-upstream" $true
Create-Route "41" "notifications-read-route" "/api/v1/notifications/*/read" @("POST","OPTIONS") "notification-service-upstream" $true
Create-Route "42" "notifications-read-all-route" "/api/v1/notifications/read-all" @("POST","OPTIONS") "notification-service-upstream" $true

# 15. Payout Service Routes (Protected)
Create-Route "15" "payout-service-route" "/api/v1/payouts/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "payout-service-upstream" $true
Create-Route "25" "payout-service-base-route" "/api/v1/payouts" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "payout-service-upstream" $true

# 16. Analytics Service Routes (Protected)
Create-Route "16" "analytics-service-route" "/api/v1/analytics/*" @("GET","POST","OPTIONS") "analytics-service-upstream" $true
Create-Route "26" "analytics-service-base-route" "/api/v1/analytics" @("GET","POST","OPTIONS") "analytics-service-upstream" $true

# 17-18. Categories Routes (Public)
Create-Route "17" "voucher-categories-route" "/api/v1/categories" @("GET","OPTIONS") "voucher-service-upstream" $false
Create-Route "18" "voucher-categories-single-route" "/api/v1/categories/*" @("GET","OPTIONS") "voucher-service-upstream" $false

# 43-46. Mock Payment Service Routes (Public)
Create-Route "43" "mock-payment-init-route" "/api/mock/payment/init" @("POST","OPTIONS") "payment-service-upstream" $false
Create-Route "44" "mock-payment-process-route" "/api/mock/payment/process" @("POST","OPTIONS") "payment-service-upstream" $false
Create-Route "45" "mock-payment-status-route" "/api/mock/payment/status/*" @("GET","OPTIONS") "payment-service-upstream" $false
Create-Route "46" "mock-payment-page-route" "/api/mock/payment/page" @("GET","OPTIONS") "payment-service-upstream" $false

# 52-54. Admin Verifications Routes
Create-Route "52" "admin-verifications-pending-route" "/api/v1/admin/verifications/pending" @("GET","OPTIONS") "auth-service-upstream" $false
Create-Route "53" "admin-verifications-verify-route" "/api/v1/admin/verifications/*/verify" @("POST","OPTIONS") "auth-service-upstream" $false
Create-Route "54" "admin-verifications-reject-route" "/api/v1/admin/verifications/*/reject" @("POST","OPTIONS") "auth-service-upstream" $false

# 13. Health Check Route (Public)
$healthRoute = @{
    name = "health-check-route"
    uri = "/health"
    methods = @("GET")
    plugins = @{
        echo = @{
            body = '{"status": "ok", "service": "APISIX Gateway"}'
        }
    }
} | ConvertTo-Json -Depth 10 -Compress

try {
    Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/13" -Method PUT -Headers $headers -Body $healthRoute | Out-Null
    Write-Host "  [OK] Route 13: Health Check created" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Route 13: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "SUCCESS: APISIX routes configured with CORS!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access points:" -ForegroundColor Cyan
Write-Host "  - Gateway: http://localhost:9080"
Write-Host "  - Admin API: http://localhost:9091"
Write-Host ""
Write-Host "CORS enabled for:" -ForegroundColor Cyan
Write-Host "  - Admin Portal: http://localhost:4200"
Write-Host "  - Merchant App: http://localhost:5000"
Write-Host "  - Consumer App: http://localhost:8001"
Write-Host "  - Consumer App (Alt): http://localhost:8002"
Write-Host ""
Write-Host "To run this script again after restart:" -ForegroundColor Yellow
Write-Host "  cd gateway\apisix"
Write-Host "  .\setup-all-routes-cors.ps1"
Write-Host ""
Write-Host "Or from project root:" -ForegroundColor Yellow
Write-Host "  .\scripts\setup-apisix-routes.ps1"
Write-Host ""

