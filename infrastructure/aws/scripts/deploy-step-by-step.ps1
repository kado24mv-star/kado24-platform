# Step-by-step deployment script for Kado24 Platform
# This script guides you through the deployment process

param(
    [string]$Environment = "development",
    [switch]$SkipPrerequisites = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - AWS Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Account ID: 577004485374" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check Prerequisites
if (-not $SkipPrerequisites) {
    Write-Host "Step 1: Checking Prerequisites..." -ForegroundColor Cyan
    & "$PSScriptRoot\setup-prerequisites.ps1"
    Write-Host ""
    
    $response = Read-Host "Continue with deployment? (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "Deployment cancelled." -ForegroundColor Yellow
        exit
    }
}

# Step 2: Configure AWS
Write-Host "Step 2: Configuring AWS..." -ForegroundColor Cyan
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    if ($identity.Account -eq "577004485374") {
        Write-Host "  ✓ AWS CLI configured correctly" -ForegroundColor Green
        Write-Host "  Account: $($identity.Account)" -ForegroundColor Green
        Write-Host "  User: $($identity.Arn)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Warning: Account ID mismatch!" -ForegroundColor Yellow
        Write-Host "  Expected: 577004485374" -ForegroundColor Yellow
        Write-Host "  Found: $($identity.Account)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ AWS CLI not configured" -ForegroundColor Red
    Write-Host "  Run: aws configure" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 3: Setup Terraform
Write-Host "Step 3: Setting up Terraform..." -ForegroundColor Cyan
$terraformDir = Join-Path $PSScriptRoot "..\terraform"
Set-Location $terraformDir

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "  Creating terraform.tfvars from template..." -ForegroundColor Yellow
    if ($Environment -eq "development") {
        Copy-Item "terraform.tfvars.dev" "terraform.tfvars"
        Write-Host "  ✓ Using development configuration (cost-optimized)" -ForegroundColor Green
    } else {
        Copy-Item "terraform.tfvars.example" "terraform.tfvars"
        Write-Host "  ✓ Using production configuration" -ForegroundColor Green
    }
    Write-Host "  ⚠ IMPORTANT: Edit terraform.tfvars and set:" -ForegroundColor Yellow
    Write-Host "    - db_password (secure password)" -ForegroundColor Yellow
    Write-Host "    - jwt_secret (secure secret, minimum 256 bits)" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Have you edited terraform.tfvars? (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "Please edit terraform.tfvars first, then run this script again." -ForegroundColor Yellow
        exit
    }
}

# Initialize Terraform
Write-Host "  Initializing Terraform..." -ForegroundColor Yellow
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Terraform initialization failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Terraform initialized" -ForegroundColor Green
Write-Host ""

# Step 4: Plan Infrastructure
Write-Host "Step 4: Planning Infrastructure..." -ForegroundColor Cyan
Write-Host "  Running terraform plan..." -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Terraform plan failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Plan created successfully" -ForegroundColor Green
Write-Host ""
Write-Host "  ⚠ Review the plan above carefully!" -ForegroundColor Yellow
$response = Read-Host "Apply this plan? (Y/N)"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Deployment cancelled. Plan saved as tfplan" -ForegroundColor Yellow
    exit
}

# Step 5: Apply Infrastructure
Write-Host "Step 5: Deploying Infrastructure..." -ForegroundColor Cyan
Write-Host "  This will take 15-20 minutes..." -ForegroundColor Yellow
terraform apply tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Infrastructure deployment failed" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Infrastructure deployed successfully" -ForegroundColor Green
Write-Host ""

# Step 6: Setup Database
Write-Host "Step 6: Setting up Database..." -ForegroundColor Cyan
Set-Location $PSScriptRoot
& .\setup-rds.sh
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Database setup failed" -ForegroundColor Red
    Write-Host "  You can retry this step later with: .\setup-rds.sh" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Database setup complete" -ForegroundColor Green
}
Write-Host ""

# Step 7: Build and Push Images
Write-Host "Step 7: Building and Pushing Docker Images..." -ForegroundColor Cyan
Write-Host "  This will take 30-45 minutes for all services..." -ForegroundColor Yellow
$response = Read-Host "Continue with image build? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\build-and-push-images.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Image build/push failed" -ForegroundColor Red
        Write-Host "  You can retry this step later with: .\build-and-push-images.sh" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Images built and pushed successfully" -ForegroundColor Green
    }
} else {
    Write-Host "  Skipped. Run later with: .\build-and-push-images.sh" -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Deploy Services
Write-Host "Step 8: Deploying ECS Services..." -ForegroundColor Cyan
$response = Read-Host "Deploy services now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\deploy-services.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Service deployment failed" -ForegroundColor Red
        Write-Host "  You can retry this step later with: .\deploy-services.sh" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Services deployed successfully" -ForegroundColor Green
    }
} else {
    Write-Host "  Skipped. Run later with: .\deploy-services.sh" -ForegroundColor Yellow
}
Write-Host ""

# Step 9: Deploy Frontend
Write-Host "Step 9: Deploying Frontend Applications..." -ForegroundColor Cyan
$response = Read-Host "Deploy frontend now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    & .\deploy-frontend.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Frontend deployment failed" -ForegroundColor Red
        Write-Host "  You can retry this step later with: .\deploy-frontend.sh" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Frontend deployed successfully" -ForegroundColor Green
    }
} else {
    Write-Host "  Skipped. Run later with: .\deploy-frontend.sh" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ Infrastructure deployed" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Get ALB DNS name:" -ForegroundColor White
Write-Host "   terraform -chdir=terraform output -raw alb_dns_name" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Check service status:" -ForegroundColor White
Write-Host "   aws ecs list-services --cluster kado24-cluster" -ForegroundColor Gray
Write-Host ""
Write-Host "3. View service logs:" -ForegroundColor White
Write-Host "   aws logs tail /ecs/kado24-auth-service --follow" -ForegroundColor Gray
Write-Host ""
Write-Host "Deployment complete! 🎉" -ForegroundColor Green

