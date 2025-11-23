# Simple prerequisites check script

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Prerequisites Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$missing = @()
$installed = @()

# Check AWS CLI
Write-Host "Checking AWS CLI..." -ForegroundColor Yellow
if (Get-Command aws -ErrorAction SilentlyContinue) {
    $version = aws --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] AWS CLI: $version" -ForegroundColor Green
    $installed += "AWS CLI"
} else {
    Write-Host "  [MISSING] AWS CLI" -ForegroundColor Red
    $missing += "AWS CLI"
}

# Check Terraform
Write-Host "Checking Terraform..." -ForegroundColor Yellow
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $version = terraform version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] Terraform: $version" -ForegroundColor Green
    $installed += "Terraform"
} else {
    Write-Host "  [MISSING] Terraform" -ForegroundColor Red
    $missing += "Terraform"
}

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $version = docker --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] Docker: $version" -ForegroundColor Green
    $installed += "Docker"
} else {
    Write-Host "  [MISSING] Docker" -ForegroundColor Red
    $missing += "Docker"
}

# Check Maven
Write-Host "Checking Maven..." -ForegroundColor Yellow
if (Get-Command mvn -ErrorAction SilentlyContinue) {
    $version = mvn --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] Maven: $version" -ForegroundColor Green
    $installed += "Maven"
} else {
    Write-Host "  [MISSING] Maven" -ForegroundColor Red
    $missing += "Maven"
}

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    $version = node --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] Node.js: $version" -ForegroundColor Green
    $installed += "Node.js"
} else {
    Write-Host "  [MISSING] Node.js" -ForegroundColor Red
    $missing += "Node.js"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installed: $($installed.Count)/5 tools" -ForegroundColor $(if ($installed.Count -eq 5) { "Green" } else { "Yellow" })
Write-Host ""

if ($missing.Count -gt 0) {
    Write-Host "Missing tools:" -ForegroundColor Red
    foreach ($tool in $missing) {
        Write-Host "  - $tool" -ForegroundColor Red
    }
    Write-Host "`nInstallation:" -ForegroundColor Yellow
    Write-Host "1. Using Chocolatey: choco install awscli terraform docker-desktop maven nodejs -y" -ForegroundColor White
    Write-Host "2. See SETUP-PREREQUISITES.md for manual installation" -ForegroundColor White
} else {
    Write-Host "All prerequisites installed! Ready to deploy." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Configure AWS: aws configure" -ForegroundColor White
    Write-Host "2. Verify account: aws sts get-caller-identity" -ForegroundColor White
    Write-Host "3. Run deployment: .\deploy-step-by-step.ps1" -ForegroundColor White
}

Write-Host ""

