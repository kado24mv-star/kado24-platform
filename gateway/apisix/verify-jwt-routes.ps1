# Verify all routes have jwt-auth except auth routes
$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
}

Write-Host "`n=== Verifying APISIX JWT Auth Configuration ===" -ForegroundColor Cyan
Write-Host ""

try {
    $routes = Invoke-RestMethod -Uri "$APISIX_ADMIN/routes" -Headers $headers -ErrorAction Stop
    
    $issues = @()
    $correct = @()
    
    foreach ($route in $routes.value.list) {
        $routeId = $route.value.id
        $uri = $route.value.uri
        $name = $route.value.name
        $plugins = $route.value.plugins.PSObject.Properties.Name
        $hasJwt = $plugins -contains "jwt-auth"
        $isAuth = $uri -like "*auth*" -or $uri -like "/health" -or $uri -like "*categories*" -or $uri -like "*mock/payment*"
        
        if ($isAuth) {
            if ($hasJwt) {
                $issues += "Route $routeId ($uri) - Should NOT have jwt-auth (public route)"
            } else {
                $correct += "Route $routeId ($uri) - Correctly has no jwt-auth"
            }
        } else {
            if ($hasJwt) {
                $correct += "Route $routeId ($uri) - Has jwt-auth ✓"
            } else {
                $issues += "Route $routeId ($uri) - Missing jwt-auth (should be protected)"
            }
        }
    }
    
    Write-Host "✅ Correctly Configured Routes:" -ForegroundColor Green
    foreach ($item in $correct) {
        Write-Host "  $item" -ForegroundColor Gray
    }
    
    if ($issues.Count -gt 0) {
        Write-Host "`n❌ Issues Found:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  $issue" -ForegroundColor Yellow
        }
        Write-Host "`nRun .\setup-all-routes-cors.ps1 to fix issues" -ForegroundColor Cyan
    } else {
        Write-Host "`n✅ All routes are correctly configured!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

