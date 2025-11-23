# Verify all setup is complete before deployment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Readiness Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allReady = $true

# Check prerequisites
Write-Host "Checking Prerequisites..." -ForegroundColor Yellow
& "$PSScriptRoot\check-prerequisites.ps1" | Out-Null

$tools = @("aws", "terraform", "docker", "mvn", "node")
$missing = @()

foreach ($tool in $tools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        $missing += $tool
        $allReady = $false
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`nMissing tools: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Install them first. See INSTALL-TOOLS.md" -ForegroundColor Yellow
    $allReady = $false
}

# Check AWS configuration
Write-Host "`nChecking AWS Configuration..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    if ($identity.Account -eq "577004485374") {
        Write-Host "  [OK] AWS CLI configured" -ForegroundColor Green
        Write-Host "  Account: $($identity.Account)" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Account mismatch!" -ForegroundColor Yellow
        Write-Host "  Expected: 577004485374" -ForegroundColor Yellow
        Write-Host "  Found: $($identity.Account)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] AWS CLI not configured" -ForegroundColor Red
    Write-Host "  Run: aws configure" -ForegroundColor Yellow
    $allReady = $false
}

# Check Terraform configuration
Write-Host "`nChecking Terraform Configuration..." -ForegroundColor Yellow
$tfDir = Join-Path $PSScriptRoot "..\terraform"
if (Test-Path (Join-Path $tfDir "terraform.tfvars")) {
    Write-Host "  [OK] terraform.tfvars exists" -ForegroundColor Green
    
    # Check if passwords are set
    $tfvars = Get-Content (Join-Path $tfDir "terraform.tfvars") -Raw
    if ($tfvars -match 'db_password\s*=\s*"CHANGE_THIS' -or $tfvars -notmatch 'db_password\s*=') {
        Write-Host "  [WARNING] db_password may need to be set" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] db_password configured" -ForegroundColor Green
    }
    
    if ($tfvars -match 'jwt_secret\s*=\s*"CHANGE_THIS') {
        Write-Host "  [WARNING] jwt_secret may need to be set" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] jwt_secret configured" -ForegroundColor Green
    }
} else {
    Write-Host "  [ERROR] terraform.tfvars not found" -ForegroundColor Red
    Write-Host "  Run: .\prepare-deployment.ps1" -ForegroundColor Yellow
    $allReady = $false
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($allReady) {
    Write-Host "`n✅ All checks passed! Ready to deploy." -ForegroundColor Green
    Write-Host "`nNext command:" -ForegroundColor Yellow
    Write-Host "  .\deploy-step-by-step.ps1 -Environment development" -ForegroundColor White
} else {
    Write-Host "`n❌ Some checks failed. Please fix issues above." -ForegroundColor Red
    Write-Host "`nSee:" -ForegroundColor Yellow
    Write-Host "  - INSTALL-TOOLS.md (for tool installation)" -ForegroundColor White
    Write-Host "  - NEXT-STEPS.md (for complete guide)" -ForegroundColor White
}

Write-Host ""

