# Simple APISIX Route Setup Script
$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

$corsConfig = @{
    allow_origins = "http://localhost:4200,http://localhost:8001,http://localhost:8002"
    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
    expose_headers = "Authorization,Content-Type,Accept"
    max_age = 3600
    allow_credential = $true
}

function Create-Upstream {
    param($id, $service, $port)
    $body = @{
        type = "roundrobin"
        nodes = @{
            "$service`:$port" = 1
        }
    } | ConvertTo-Json -Compress
    
    try {
        Invoke-WebRequest -Uri "$APISIX_ADMIN/upstreams/$id" -Headers $headers -Method PUT -Body $body | Out-Null
        Write-Host "Created upstream: $id" -ForegroundColor Green
    } catch {
        Write-Host "Failed upstream: $id - $_" -ForegroundColor Red
    }
}

function Create-Route {
    param($id, $name, $uri, $methods, $upstreamId, $isPublic = $false, $skipJwtAuth = $false)
    
    $plugins = @{
        cors = $corsConfig
        prometheus = @{}
    }
    
    # Ensure OPTIONS is in methods array for CORS preflight
    if ($methods -notcontains "OPTIONS") {
        $methods = $methods + @("OPTIONS")
    }
    
    # Only add APISIX jwt-auth if route is protected AND not skipping (skip for routes where backend validates JWT)
    if (-not $isPublic -and -not $skipJwtAuth) {
        # Add JWT auth for protected routes, but skip for OPTIONS requests
        $plugins."jwt-auth" = @{
            header = "Authorization"
            query = "token"
        }
    }
    
    if ($isPublic) {
        $plugins."limit-req" = @{
            rate = 20
            burst = 10
            key = "remote_addr"
            rejected_code = 429
        }
    }
    
    $body = @{
        name = $name
        uri = $uri
        methods = $methods
        upstream_id = $upstreamId
        plugins = $plugins
    } | ConvertTo-Json -Depth 10
    
    try {
        Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$id" -Headers $headers -Method PUT -Body $body | Out-Null
        Write-Host "Created route: $name" -ForegroundColor Green
    } catch {
        Write-Host "Failed route: $name - $_" -ForegroundColor Red
    }
}

Write-Host "Creating upstreams..." -ForegroundColor Yellow
Create-Upstream "auth-service-upstream" "kado24-auth-service" "8081"
Create-Upstream "user-service-upstream" "kado24-user-service" "8082"
Create-Upstream "voucher-service-upstream" "kado24-voucher-service" "8083"
Create-Upstream "order-service-upstream" "kado24-order-service" "8084"
Create-Upstream "payment-service-upstream" "kado24-mock-payment-service" "8095"
Create-Upstream "wallet-service-upstream" "kado24-wallet-service" "8086"
Create-Upstream "redemption-service-upstream" "kado24-redemption-service" "8087"
Create-Upstream "merchant-service-upstream" "kado24-merchant-service" "8088"
Create-Upstream "admin-portal-backend-upstream" "kado24-admin-portal-backend" "8089"
Create-Upstream "notification-service-upstream" "kado24-notification-service" "8091"
Create-Upstream "payout-service-upstream" "kado24-payout-service" "8092"
Create-Upstream "analytics-service-upstream" "kado24-analytics-service" "8093"

Write-Host "`nCreating routes..." -ForegroundColor Yellow
Create-Route "1" "auth-service-route" "/api/v1/auth/*" @("GET","POST","PUT","DELETE","OPTIONS") "auth-service-upstream" $true
# User service route - backend handles JWT validation, so skip APISIX jwt-auth
Create-Route "2" "user-service-route" "/api/v1/users/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "user-service-upstream" $false $true
# Voucher service route - backend handles JWT validation, so skip APISIX jwt-auth
Create-Route "3" "voucher-service-public" "/api/v1/vouchers" @("GET","POST","OPTIONS") "voucher-service-upstream" $false $true
# Specific route for my-vouchers endpoint (protected, needs authentication)
Create-Route "20" "voucher-service-my-vouchers" "/api/v1/vouchers/my-vouchers" @("GET","OPTIONS") "voucher-service-upstream" $false $true
Create-Route "4" "voucher-service-single" "/api/v1/vouchers/*" @("GET","OPTIONS") "voucher-service-upstream" $true
# Voucher service write route - backend handles JWT validation, so skip APISIX jwt-auth
Create-Route "5" "voucher-service-write" "/api/v1/vouchers/*" @("POST","PUT","DELETE","PATCH","OPTIONS") "voucher-service-upstream" $false $true
Create-Route "18" "categories-service-route-exact" "/api/v1/categories" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "voucher-service-upstream" $true
Create-Route "19" "categories-service-route-wildcard" "/api/v1/categories/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "voucher-service-upstream" $true
Create-Route "6" "order-service-route" "/api/v1/orders/*" @("GET","POST","PUT","DELETE","OPTIONS") "order-service-upstream" $false
Create-Route "6a" "order-service-route-exact" "/api/v1/orders" @("GET","POST","PUT","DELETE","OPTIONS") "order-service-upstream" $false
Create-Route "7" "payment-service-route" "/api/v1/payments/*" @("GET","POST","OPTIONS") "payment-service-upstream" $false
Create-Route "9" "wallet-service-route" "/api/v1/wallet/*" @("GET","POST","PUT","DELETE","OPTIONS") "wallet-service-upstream" $false
Create-Route "10" "redemption-service-route" "/api/v1/redemptions/*" @("GET","POST","OPTIONS") "redemption-service-upstream" $false
Create-Route "11" "merchant-service-route" "/api/v1/merchants/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "merchant-service-upstream" $false
Create-Route "12" "admin-verifications-route" "/api/v1/admin/verifications/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "auth-service-upstream" $false
Create-Route "13" "admin-portal-route-v1" "/api/v1/admin/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "admin-portal-backend-upstream" $false
Create-Route "17" "admin-portal-route" "/api/admin/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "admin-portal-backend-upstream" $false
Create-Route "14" "notification-service-route" "/api/v1/notifications/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "notification-service-upstream" $false
Create-Route "15" "payout-service-route" "/api/v1/payouts/*" @("GET","POST","PUT","DELETE","PATCH","OPTIONS") "payout-service-upstream" $false
Create-Route "16" "analytics-service-route" "/api/v1/analytics/*" @("GET","POST","OPTIONS") "analytics-service-upstream" $false

Write-Host "`nDone!" -ForegroundColor Green

