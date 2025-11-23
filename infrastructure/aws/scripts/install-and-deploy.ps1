# Complete installation and deployment script
# This script helps install tools and then deploy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Install & Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check current status
Write-Host "Checking current status..." -ForegroundColor Yellow
& "$PSScriptRoot\check-prerequisites.ps1" | Out-Null

$tools = @("aws", "terraform")
$missing = @()

foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        $missing += $tool
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`nMissing tools: $($missing -join ', ')" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation Options:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Manual Installation (Recommended)" -ForegroundColor Cyan
    Write-Host "  AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor White
    Write-Host "  Terraform: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Using Chocolatey (Requires Admin)" -ForegroundColor Cyan
    Write-Host "  Run PowerShell as Administrator, then:" -ForegroundColor White
    Write-Host "  choco install awscli terraform -y" -ForegroundColor White
    Write-Host ""
    Write-Host "After installation, RESTART PowerShell and run this script again." -ForegroundColor Yellow
    Write-Host ""
    
    # Try to open download pages
    $response = Read-Host "Open download pages in browser? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Start-Process "https://awscli.amazonaws.com/AWSCLIV2.msi"
        Start-Process "https://developer.hashicorp.com/terraform/downloads"
        Write-Host "Download pages opened. Install the tools, restart PowerShell, then run this script again." -ForegroundColor Green
    }
    
    exit
}

# Tools are installed, check AWS configuration
Write-Host "`nChecking AWS configuration..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    if ($identity.Account -eq "577004485374") {
        Write-Host "  [OK] AWS configured correctly" -ForegroundColor Green
        Write-Host "  Account: $($identity.Account)" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Account mismatch!" -ForegroundColor Yellow
        Write-Host "  Expected: 577004485374" -ForegroundColor Yellow
        Write-Host "  Found: $($identity.Account)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] AWS not configured" -ForegroundColor Red
    Write-Host ""
    Write-Host "Configure AWS CLI:" -ForegroundColor Yellow
    Write-Host "  1. Get credentials from: https://console.aws.amazon.com/iam/" -ForegroundColor White
    Write-Host "  2. Run: aws configure" -ForegroundColor White
    Write-Host "  3. Enter your Access Key ID and Secret Access Key" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "Open AWS IAM console? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Start-Process "https://console.aws.amazon.com/iam/"
        Write-Host "IAM console opened. Get your credentials, then run: aws configure" -ForegroundColor Green
    }
    
    exit
}

# Everything is ready, proceed with deployment
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All Prerequisites Met!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ready to deploy. Choose deployment method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Quick Deploy (Automated - Recommended)" -ForegroundColor Green
Write-Host "2. Step-by-Step (Interactive)" -ForegroundColor Cyan
Write-Host "3. Manual (You run each step)" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Enter choice (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host "`nStarting Quick Deploy..." -ForegroundColor Cyan
        & "$PSScriptRoot\quick-deploy.ps1" -Environment development
    }
    "2" {
        Write-Host "`nStarting Step-by-Step Deploy..." -ForegroundColor Cyan
        & "$PSScriptRoot\deploy-step-by-step.ps1" -Environment development
    }
    "3" {
        Write-Host "`nManual Deployment Steps:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Deploy Infrastructure:" -ForegroundColor Yellow
        Write-Host "   cd ..\terraform" -ForegroundColor White
        Write-Host "   terraform init" -ForegroundColor White
        Write-Host "   terraform apply" -ForegroundColor White
        Write-Host ""
        Write-Host "2. Setup Database:" -ForegroundColor Yellow
        Write-Host "   cd ..\scripts" -ForegroundColor White
        Write-Host "   .\setup-rds.sh" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Build and Push Images:" -ForegroundColor Yellow
        Write-Host "   .\build-and-push-images.sh" -ForegroundColor White
        Write-Host ""
        Write-Host "4. Deploy Services:" -ForegroundColor Yellow
        Write-Host "   .\deploy-services.sh" -ForegroundColor White
        Write-Host ""
        Write-Host "5. Deploy Frontend:" -ForegroundColor Yellow
        Write-Host "   .\deploy-frontend.sh" -ForegroundColor White
        Write-Host ""
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    }
}

