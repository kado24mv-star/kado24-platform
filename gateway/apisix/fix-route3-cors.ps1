# Fix Route 3 CORS Configuration
$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

Write-Host "=== Updating Route 3 CORS Configuration ===" -ForegroundColor Cyan

$routeConfig = @{
    name = "voucher-service-public"
    uri = "/api/v1/vouchers"
    methods = @("GET", "POST", "OPTIONS")
    upstream_id = "voucher-service-upstream"
    plugins = @{
        cors = @{
            allow_origins = "http://localhost:4200,http://localhost:8001,http://localhost:8002"
            allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
            allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
            expose_headers = "Authorization,Content-Type,Accept"
            max_age = 3600
            allow_credential = $true
        }
        prometheus = @{}
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/3" -Headers $headers -Method PUT -Body $routeConfig
    Write-Host "✅ Route 3 updated successfully!" -ForegroundColor Green
    Write-Host "   URI: $($response.value.uri)" -ForegroundColor White
    Write-Host "   Methods: $($response.value.methods -join ', ')" -ForegroundColor White
    Write-Host "   CORS Origins: $($response.value.plugins.cors.allow_origins)" -ForegroundColor White
} catch {
    Write-Host "❌ Error updating route: $_" -ForegroundColor Red
    Write-Host "   Response: $($_.Exception.Response)" -ForegroundColor Yellow
    exit 1
}

