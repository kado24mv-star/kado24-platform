# Quick deployment script - Runs all deployment steps automatically

param(
    [string]$Environment = "development"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Quick Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Account ID: 577004485374" -ForegroundColor Yellow
Write-Host ""

# Check prerequisites first
Write-Host "Step 1: Checking Prerequisites..." -ForegroundColor Cyan
& "$PSScriptRoot\check-prerequisites.ps1" | Out-Null

$tools = @("aws", "terraform")
$missing = @()

foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        $missing += $tool
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`n❌ Missing tools: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Please install them first. See INSTALL-TOOLS.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quick install:" -ForegroundColor Cyan
    Write-Host "  AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor White
    Write-Host "  Terraform: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor White
    exit 1
}

# Check AWS configuration
Write-Host "`nStep 2: Checking AWS Configuration..." -ForegroundColor Cyan
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    if ($identity.Account -eq "577004485374") {
        Write-Host "  [OK] AWS configured correctly" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Account mismatch: $($identity.Account)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] AWS not configured" -ForegroundColor Red
    Write-Host "  Run: aws configure" -ForegroundColor Yellow
    exit 1
}

# Deploy infrastructure
Write-Host "`nStep 3: Deploying Infrastructure..." -ForegroundColor Cyan
$terraformDir = Join-Path $PSScriptRoot "..\terraform"
Set-Location $terraformDir

if (-not (Test-Path ".terraform")) {
    Write-Host "  Initializing Terraform..." -ForegroundColor Yellow
    terraform init
}

Write-Host "  Planning infrastructure..." -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Terraform plan failed" -ForegroundColor Red
    exit 1
}

Write-Host "  Applying infrastructure (this takes 15-20 minutes)..." -ForegroundColor Yellow
terraform apply tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Infrastructure deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "  [OK] Infrastructure deployed" -ForegroundColor Green

# Setup database
Write-Host "`nStep 4: Setting up Database..." -ForegroundColor Cyan
Set-Location $PSScriptRoot
& .\setup-rds.sh
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [WARNING] Database setup had issues" -ForegroundColor Yellow
    Write-Host "  You can retry later with: .\setup-rds.sh" -ForegroundColor Yellow
}

# Build and push images
Write-Host "`nStep 5: Building and Pushing Images..." -ForegroundColor Cyan
Write-Host "  This takes 30-45 minutes..." -ForegroundColor Yellow
$response = Read-Host "Continue? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\build-and-push-images.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARNING] Image build had issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Skipped. Run later with: .\build-and-push-images.sh" -ForegroundColor Yellow
}

# Deploy services
Write-Host "`nStep 6: Deploying Services..." -ForegroundColor Cyan
$response = Read-Host "Deploy services now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\deploy-services.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARNING] Service deployment had issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Skipped. Run later with: .\deploy-services.sh" -ForegroundColor Yellow
}

# Deploy frontend
Write-Host "`nStep 7: Deploying Frontend..." -ForegroundColor Cyan
$response = Read-Host "Deploy frontend now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\deploy-frontend.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARNING] Frontend deployment had issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Skipped. Run later with: .\deploy-frontend.sh" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Get ALB URL:" -ForegroundColor Yellow
Write-Host "  terraform -chdir=..\terraform output -raw alb_dns_name" -ForegroundColor White
Write-Host ""
Write-Host "Check services:" -ForegroundColor Yellow
Write-Host "  aws ecs list-services --cluster kado24-cluster" -ForegroundColor White
Write-Host ""

