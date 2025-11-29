# Backend API Status Verification Script
$results = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend API Status Verification" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Backend services to check
$backendServices = @(
    @{Name="Auth Service"; Port=8081; Container="kado24-auth-service"},
    @{Name="User Service"; Port=8082; Container="kado24-user-service"},
    @{Name="Voucher Service"; Port=8083; Container="kado24-voucher-service"},
    @{Name="Order Service"; Port=8084; Container="kado24-order-service"},
    @{Name="Wallet Service"; Port=8086; Container="kado24-wallet-service"},
    @{Name="Redemption Service"; Port=8087; Container="kado24-redemption-service"},
    @{Name="Merchant Service"; Port=8088; Container="kado24-merchant-service"},
    @{Name="Admin Portal Backend"; Port=8089; Container="kado24-admin-portal-backend"},
    @{Name="Notification Service"; Port=8091; Container="kado24-notification-service"},
    @{Name="Payout Service"; Port=8092; Container="kado24-payout-service"},
    @{Name="Analytics Service"; Port=8093; Container="kado24-analytics-service"},
    @{Name="Payment Service"; Port=8095; Container="kado24-mock-payment-service"}
)

Write-Host "Checking Docker Containers..." -ForegroundColor Yellow
Write-Host ""

$runningContainers = 0
foreach ($svc in $backendServices) {
    $containerStatus = docker ps --filter "name=$($svc.Container)" --format "{{.Status}}" 2>&1
    if ($containerStatus -and $containerStatus -notmatch "error|Cannot") {
        Write-Host "  [CONTAINER] $($svc.Name) - $containerStatus" -ForegroundColor Green
        $runningContainers++
    } else {
        Write-Host "  [CONTAINER] $($svc.Name) - Not running" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Checking Health Endpoints..." -ForegroundColor Yellow
Write-Host ""

$healthyServices = 0
foreach ($svc in $backendServices) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($svc.Port)/actuator/health" -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $healthData = $response.Content | ConvertFrom-Json
            $status = $healthData.status
            Write-Host "  [HEALTH] $($svc.Name) (Port $($svc.Port)) - $status" -ForegroundColor Green
            $healthyServices++
            $results += [PSCustomObject]@{
                Service = $svc.Name
                Port = $svc.Port
                Container = "Running"
                Health = $status
            }
        }
    } catch {
        Write-Host "  [HEALTH] $($svc.Name) (Port $($svc.Port)) - Not responding" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Service = $svc.Name
            Port = $svc.Port
            Container = "Unknown"
            Health = "Failed"
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Containers Running: $runningContainers/$($backendServices.Count)" -ForegroundColor $(if ($runningContainers -eq $backendServices.Count) { "Green" } else { "Yellow" })
Write-Host "Services Healthy: $healthyServices/$($backendServices.Count)" -ForegroundColor $(if ($healthyServices -eq $backendServices.Count) { "Green" } else { "Yellow" })
Write-Host ""

if ($healthyServices -eq $backendServices.Count) {
    Write-Host "✅ All backend APIs are running and healthy!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services are not responding. Check logs with:" -ForegroundColor Yellow
    Write-Host "   docker logs <container-name>" -ForegroundColor Gray
}

# Export results
$results | Export-Csv -Path "backend-status.csv" -NoTypeInformation
Write-Host ""
Write-Host "Results saved to: backend-status.csv" -ForegroundColor Gray

