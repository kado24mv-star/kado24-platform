# Stop All Kado24 Platform Services and Apps
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Stopping All Kado24 Platform Services" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Stop Backend Services
Write-Host "Stopping backend services..." -ForegroundColor Yellow
docker compose -f docker-compose.services.yml down
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backend services stopped" -ForegroundColor Green
} else {
    Write-Host "⚠ Some backend services may not have stopped" -ForegroundColor Yellow
}

Write-Host ""

# Stop Infrastructure
Write-Host "Stopping infrastructure services..." -ForegroundColor Yellow
cd infrastructure\docker
docker compose down
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Infrastructure services stopped" -ForegroundColor Green
} else {
    Write-Host "⚠ Some infrastructure services may not have stopped" -ForegroundColor Yellow
}
cd ..\..

Write-Host ""

# Stop Frontend Apps (Flutter and Angular)
Write-Host "Stopping frontend apps..." -ForegroundColor Yellow
$processes = Get-Process | Where-Object {
    ($_.ProcessName -match "flutter|dart") -or
    ($_.ProcessName -eq "node" -and $_.MainWindowTitle -like "*admin*") -or
    ($_.MainWindowTitle -like "*merchant*" -or $_.MainWindowTitle -like "*consumer*" -or $_.MainWindowTitle -like "*admin*")
}

if ($processes) {
    $processes | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            Write-Host "  Stopped: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Gray
        } catch {
            Write-Host "  Could not stop: $($_.ProcessName)" -ForegroundColor Yellow
        }
    }
    Write-Host "✓ Frontend apps stopped" -ForegroundColor Green
} else {
    Write-Host "✓ No frontend apps running" -ForegroundColor Green
}

Write-Host ""

# Stop any remaining Docker containers
Write-Host "Stopping any remaining Docker containers..." -ForegroundColor Yellow
$containers = docker ps -q
if ($containers) {
    $containers | ForEach-Object {
        docker stop $_ | Out-Null
    }
    Write-Host "✓ All Docker containers stopped" -ForegroundColor Green
} else {
    Write-Host "✓ No Docker containers running" -ForegroundColor Green
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "All Services Stopped!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "To start everything again, run:" -ForegroundColor Cyan
Write-Host "  .\start-platform.ps1" -ForegroundColor Yellow
Write-Host ""

