# Setup JWT Consumer for APISIX
# This must be run BEFORE routes are configured with jwt-auth

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

# JWT Secret (must match backend services)
$JWT_SECRET = "kado24-secret-key-change-this-in-production-minimum-256-bits-required-for-security"

Write-Host "`n=== Setting up JWT Consumer for APISIX ===" -ForegroundColor Cyan
Write-Host "JWT Secret: $JWT_SECRET" -ForegroundColor Gray
Write-Host ""

# APISIX JWT consumer configuration
# Note: APISIX uses "jwt-auth" (with hyphen) in JSON, not "jwt_auth"
$consumerConfig = '{"username":"wallet_jwt_consumer","plugins":{"jwt-auth":{"key":"wallet-service-key","secret":"' + $JWT_SECRET + '"}}}'

try {
    Write-Host "Creating JWT consumer..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/consumers/wallet_jwt_consumer" `
        -Method PUT `
        -Headers $headers `
        -Body $consumerConfig `
        -ErrorAction Stop
    
    Write-Host "✅ JWT consumer created successfully!" -ForegroundColor Green
    Write-Host "`nConsumer Details:" -ForegroundColor Cyan
    Write-Host "  Username: wallet_jwt_consumer" -ForegroundColor White
    Write-Host "  Key: wallet-service-key" -ForegroundColor White
    Write-Host "  Algorithm: HS256" -ForegroundColor White
    Write-Host "  Secret: $JWT_SECRET" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ You can now configure routes with jwt-auth!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error creating consumer: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
    exit 1
}

