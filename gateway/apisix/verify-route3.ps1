# Verify and Fix Route 3 CORS Configuration
$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

Write-Host "=== Verifying Route 3 ===" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/3" -Headers $headers -Method GET -ErrorAction Stop
    Write-Host "✅ Route 3 Found!" -ForegroundColor Green
    Write-Host "   URI: $($response.value.uri)" -ForegroundColor White
    Write-Host "   Methods: $($response.value.methods -join ', ')" -ForegroundColor White
    
    if ($response.value.plugins.cors) {
        Write-Host "   CORS: ✅ Configured" -ForegroundColor Green
        Write-Host "      Origins: $($response.value.plugins.cors.allow_origins)" -ForegroundColor Gray
        Write-Host "      Methods: $($response.value.plugins.cors.allow_methods)" -ForegroundColor Gray
    } else {
        Write-Host "   CORS: ❌ Missing - Updating now..." -ForegroundColor Yellow
        
        # Update route with CORS
        $routeConfig = @{
            name = $response.value.name
            uri = $response.value.uri
            methods = $response.value.methods
            upstream_id = $response.value.upstream_id
            plugins = @{
                cors = @{
                    allow_origins = "http://localhost:4200,http://localhost:8001,http://localhost:8002"
                    allow_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
                    allow_headers = "Authorization,Content-Type,Accept,X-Requested-With"
                    expose_headers = "Authorization,Content-Type,Accept"
                    max_age = 3600
                    allow_credential = $true
                }
            }
        }
        
        # Preserve other plugins
        if ($response.value.plugins) {
            foreach ($plugin in $response.value.plugins.PSObject.Properties) {
                if ($plugin.Name -ne "cors") {
                    $routeConfig.plugins[$plugin.Name] = $plugin.Value
                }
            }
        }
        
        $updateBody = $routeConfig | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/3" -Headers $headers -Method PUT -Body $updateBody | Out-Null
        Write-Host "   ✅ CORS added to Route 3!" -ForegroundColor Green
    }
    
    # Check if OPTIONS is in methods
    if ($response.value.methods -notcontains "OPTIONS") {
        Write-Host "   ⚠️  OPTIONS method missing - Adding..." -ForegroundColor Yellow
        $methods = $response.value.methods + @("OPTIONS")
        $routeConfig = @{
            name = $response.value.name
            uri = $response.value.uri
            methods = $methods
            upstream_id = $response.value.upstream_id
            plugins = $response.value.plugins
        } | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri "$APISIX_ADMIN/routes/3" -Headers $headers -Method PUT -Body $routeConfig | Out-Null
        Write-Host "   ✅ OPTIONS method added!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "   APISIX Admin API may not be ready yet." -ForegroundColor Yellow
    Write-Host "   Wait a few seconds and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Route 3 is properly configured!" -ForegroundColor Green

