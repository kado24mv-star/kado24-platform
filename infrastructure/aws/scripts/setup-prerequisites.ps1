# PowerShell script to check and guide installation of prerequisites

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Prerequisites Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$missing = @()
$installed = @()

# Check AWS CLI
Write-Host "Checking AWS CLI..." -ForegroundColor Yellow
$awsCheck = Get-Command aws -ErrorAction SilentlyContinue
if ($awsCheck) {
    $awsVersion = aws --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ AWS CLI installed: $awsVersion" -ForegroundColor Green
    $installed += "AWS CLI"
} else {
    Write-Host "  ✗ AWS CLI not found" -ForegroundColor Red
    $missing += "AWS CLI"
}

# Check Terraform
Write-Host "Checking Terraform..." -ForegroundColor Yellow
$tfCheck = Get-Command terraform -ErrorAction SilentlyContinue
if ($tfCheck) {
    $tfVersion = terraform version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Terraform installed: $tfVersion" -ForegroundColor Green
    $installed += "Terraform"
} else {
    Write-Host "  ✗ Terraform not found" -ForegroundColor Red
    $missing += "Terraform"
}

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
$dockerCheck = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCheck) {
    $dockerVersion = docker --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Docker installed: $dockerVersion" -ForegroundColor Green
    $installed += "Docker"
} else {
    Write-Host "  ✗ Docker not found" -ForegroundColor Red
    $missing += "Docker"
}

# Check Maven
Write-Host "Checking Maven..." -ForegroundColor Yellow
$mvnCheck = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvnCheck) {
    $mvnVersion = mvn --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Maven installed: $mvnVersion" -ForegroundColor Green
    $installed += "Maven"
} else {
    Write-Host "  ✗ Maven not found" -ForegroundColor Red
    $missing += "Maven"
}

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCheck) {
    $nodeVersion = node --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Node.js installed: $nodeVersion" -ForegroundColor Green
    $installed += "Node.js"
} else {
    Write-Host "  ✗ Node.js not found" -ForegroundColor Red
    $missing += "Node.js"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installed: $($installed.Count) tools" -ForegroundColor Green
Write-Host "Missing: $($missing.Count) tools" -ForegroundColor $(if ($missing.Count -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($missing.Count -gt 0) {
    Write-Host "Missing tools:" -ForegroundColor Red
    foreach ($tool in $missing) {
        Write-Host "  - $tool" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Installation options:" -ForegroundColor Yellow
    Write-Host "1. Using Chocolatey (if installed):" -ForegroundColor Cyan
    Write-Host "   choco install awscli terraform docker-desktop maven nodejs -y" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Manual installation:" -ForegroundColor Cyan
    Write-Host "   See SETUP-PREREQUISITES.md for detailed instructions" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Download links:" -ForegroundColor Cyan
    if ($missing -contains "AWS CLI") {
        Write-Host "   AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor White
    }
    if ($missing -contains "Terraform") {
        Write-Host "   Terraform: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor White
    }
    if ($missing -contains "Docker") {
        Write-Host "   Docker: https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    }
    if ($missing -contains "Maven") {
        Write-Host "   Maven: https://maven.apache.org/download.cgi" -ForegroundColor White
    }
    if ($missing -contains "Node.js") {
        Write-Host "   Node.js: https://nodejs.org/" -ForegroundColor White
    }
} else {
    Write-Host "All prerequisites are installed! ✓" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Configure AWS CLI: aws configure" -ForegroundColor White
    Write-Host "2. Verify AWS account: aws sts get-caller-identity" -ForegroundColor White
    Write-Host "3. Proceed with deployment" -ForegroundColor White
}

Write-Host ""

