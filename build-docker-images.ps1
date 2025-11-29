# Build Docker Images for Backend Services
# Prerequisites: Docker Desktop must be running

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Docker Images" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker Desktop..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker Desktop is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Desktop is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Set environment variables
Write-Host "Setting environment variables..." -ForegroundColor Yellow
if (Test-Path "set-dev-env.ps1") {
    . .\set-dev-env.ps1
    Write-Host "✓ Environment variables set" -ForegroundColor Green
} else {
    Write-Host "⚠ set-dev-env.ps1 not found. Using defaults." -ForegroundColor Yellow
}
Write-Host ""

# Build Docker images
Write-Host "Building Docker images..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes..." -ForegroundColor Gray
Write-Host ""

docker compose -f docker-compose.services.yml build --no-cache

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Docker Images Built Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Built Images:" -ForegroundColor Cyan
    docker images --filter "reference=kado24/*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Start services: docker compose -f docker-compose.services.yml up -d" -ForegroundColor Gray
    Write-Host "  2. Check status: docker ps --filter 'name=kado24'" -ForegroundColor Gray
    Write-Host "  3. View logs: docker logs kado24-auth-service" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "✗ Failed to build Docker images" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Ensure Docker Desktop is running" -ForegroundColor Gray
    Write-Host "  2. Check disk space: docker system df" -ForegroundColor Gray
    Write-Host "  3. Check logs above for specific errors" -ForegroundColor Gray
    exit 1
}

