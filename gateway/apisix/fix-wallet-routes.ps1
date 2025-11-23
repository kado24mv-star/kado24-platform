# Fix wallet routes to remove JWT auth (backend handles it)
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

Write-Host "Updating wallet routes to remove JWT auth..." -ForegroundColor Cyan

# Route 19: /api/v1/wallet
$route19 = @{
    name = "wallet-service-base-route"
    uri = "/api/v1/wallet"
    methods = @("GET","POST","PUT","DELETE","OPTIONS")
    upstream_id = "wallet-service-upstream"
    plugins = @{
        cors = $CORS_CONFIG
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/19" -Method PUT -Headers $headers -Body $route19
    Write-Host "✅ Route 19 (/api/v1/wallet) updated successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error updating route 19: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}

# Route 9: /api/v1/wallet/*
$route9 = @{
    name = "wallet-service-route"
    uri = "/api/v1/wallet/*"
    methods = @("GET","POST","PUT","DELETE","OPTIONS")
    upstream_id = "wallet-service-upstream"
    plugins = @{
        cors = $CORS_CONFIG
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/9" -Method PUT -Headers $headers -Body $route9
    Write-Host "✅ Route 9 (/api/v1/wallet/*) updated successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error updating route 9: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Wallet routes updated! JWT validation is now handled by the backend wallet service." -ForegroundColor Green
Write-Host "Please refresh your wallet screen in the consumer app." -ForegroundColor Yellow

