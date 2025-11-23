# Prepare deployment - Setup configuration files

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Preparing Deployment Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$terraformDir = Join-Path $PSScriptRoot "..\terraform"

# Check if terraform.tfvars exists
if (-not (Test-Path (Join-Path $terraformDir "terraform.tfvars"))) {
    Write-Host "Creating terraform.tfvars..." -ForegroundColor Yellow
    
    # Ask for environment
    Write-Host "`nSelect environment:" -ForegroundColor Yellow
    Write-Host "1. Development (Cost Optimized - ~$50-100/month)" -ForegroundColor Green
    Write-Host "2. Production (~$400-800/month)" -ForegroundColor Yellow
    $envChoice = Read-Host "Enter choice (1 or 2)"
    
    if ($envChoice -eq "1") {
        Copy-Item (Join-Path $terraformDir "terraform.tfvars.dev") (Join-Path $terraformDir "terraform.tfvars")
        Write-Host "  [OK] Using development configuration" -ForegroundColor Green
    } else {
        Copy-Item (Join-Path $terraformDir "terraform.tfvars.example") (Join-Path $terraformDir "terraform.tfvars")
        Write-Host "  [OK] Using production configuration" -ForegroundColor Green
    }
    
    Write-Host "`nIMPORTANT: Edit terraform.tfvars and set:" -ForegroundColor Yellow
    Write-Host "  - db_password (generate secure password)" -ForegroundColor White
    Write-Host "  - jwt_secret (generate secure secret, minimum 256 bits)" -ForegroundColor White
    Write-Host ""
    Write-Host "Generate passwords:" -ForegroundColor Cyan
    Write-Host "  # DB Password" -ForegroundColor Gray
    Write-Host "  openssl rand -base64 32" -ForegroundColor Gray
    Write-Host "  # JWT Secret" -ForegroundColor Gray
    Write-Host "  openssl rand -base64 64" -ForegroundColor Gray
    Write-Host ""
    
    $response = Read-Host "Press Enter after editing terraform.tfvars"
} else {
    Write-Host "terraform.tfvars already exists" -ForegroundColor Green
}

# Check config.env
$configFile = Join-Path $PSScriptRoot "..\config.env"
if (Test-Path $configFile) {
    Write-Host "config.env found" -ForegroundColor Green
} else {
    Write-Host "config.env not found (this is OK, scripts will auto-detect)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Ready" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Ensure AWS CLI and Terraform are installed" -ForegroundColor White
Write-Host "2. Configure AWS: aws configure" -ForegroundColor White
Write-Host "3. Run deployment: .\deploy-step-by-step.ps1" -ForegroundColor White
Write-Host ""

