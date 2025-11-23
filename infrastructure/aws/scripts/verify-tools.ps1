# Verify AWS CLI and Terraform installation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verifying Tool Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Temporarily add AWS CLI to PATH
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

# Check AWS CLI
Write-Host "Checking AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] AWS CLI: $awsVersion" -ForegroundColor Green
        $awsInstalled = $true
    } else {
        throw
    }
} catch {
    Write-Host "  [MISSING] AWS CLI" -ForegroundColor Red
    Write-Host "  Install from: https://awscli.amazonaws.com/AWSCLIV2.msi" -ForegroundColor Yellow
    $awsInstalled = $false
}

# Check Terraform
Write-Host "Checking Terraform..." -ForegroundColor Yellow
$terraformFound = $false
$terraformPath = $null

# Check common locations
$terraformPaths = @(
    "C:\terraform\terraform.exe",
    "$env:USERPROFILE\terraform\terraform.exe",
    "$env:LOCALAPPDATA\terraform\terraform.exe",
    "$env:ProgramFiles\Terraform\terraform.exe"
)

foreach ($path in $terraformPaths) {
    if (Test-Path $path) {
        $terraformPath = Split-Path $path -Parent
        $env:Path += ";$terraformPath"
        $terraformFound = $true
        break
    }
}

if ($terraformFound) {
    try {
        $tfVersion = terraform version 2>&1 | Select-Object -First 1
        Write-Host "  [OK] Terraform: $tfVersion" -ForegroundColor Green
        Write-Host "  Location: $terraformPath" -ForegroundColor Gray
    } catch {
        Write-Host "  [FOUND BUT ERROR] Terraform at $terraformPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [MISSING] Terraform" -ForegroundColor Red
    Write-Host "  Install from: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor Yellow
    Write-Host "  Extract to: C:\terraform" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($awsInstalled -and $terraformFound) {
    Write-Host "All tools ready! Proceeding to AWS configuration..." -ForegroundColor Green
    Write-Host ""
    
    # Check AWS configuration
    Write-Host "Checking AWS configuration..." -ForegroundColor Yellow
    try {
        $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
        Write-Host "  [OK] AWS configured" -ForegroundColor Green
        Write-Host "  Account: $($identity.Account)" -ForegroundColor Green
        Write-Host "  User: $($identity.Arn)" -ForegroundColor Gray
        
        if ($identity.Account -eq "577004485374") {
            Write-Host "  [OK] Correct account!" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] Account mismatch. Expected: 577004485374" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Ready to deploy!" -ForegroundColor Green
        Write-Host "Run: .\install-and-deploy.ps1" -ForegroundColor Cyan
    } catch {
        Write-Host "  [NOT CONFIGURED] AWS credentials needed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Configure AWS:" -ForegroundColor Yellow
        Write-Host "  1. Get credentials: https://console.aws.amazon.com/iam/" -ForegroundColor White
        Write-Host "  2. Run: aws configure" -ForegroundColor White
    }
} else {
    Write-Host "Please install missing tools and restart PowerShell" -ForegroundColor Yellow
}

