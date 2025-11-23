# Check if everything is ready for deployment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Readiness Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allReady = $true

# Add AWS CLI to PATH temporarily
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

# Check AWS CLI
Write-Host "1. Checking AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] $awsVersion" -ForegroundColor Green
    } else {
        throw
    }
} catch {
    Write-Host "   [MISSING] AWS CLI not found" -ForegroundColor Red
    $allReady = $false
}

# Check Terraform
Write-Host "2. Checking Terraform..." -ForegroundColor Yellow
$terraformReady = $false

# Try common locations
$terraformPaths = @(
    "C:\terraform\terraform.exe",
    "$env:USERPROFILE\terraform\terraform.exe",
    "$env:LOCALAPPDATA\terraform\terraform.exe"
)

foreach ($path in $terraformPaths) {
    if (Test-Path $path) {
        $terraformDir = Split-Path $path -Parent
        $env:Path += ";$terraformDir"
        try {
            $tfVersion = terraform version 2>&1 | Select-Object -First 1
            Write-Host "   [OK] $tfVersion" -ForegroundColor Green
            Write-Host "   Location: $terraformDir" -ForegroundColor Gray
            $terraformReady = $true
            break
        } catch {
            # Continue checking
        }
    }
}

if (-not $terraformReady) {
    Write-Host "   [MISSING] Terraform not found" -ForegroundColor Red
    Write-Host "   Run: .\setup-terraform.ps1" -ForegroundColor Yellow
    $allReady = $false
}

# Check AWS Configuration
Write-Host "3. Checking AWS Configuration..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    if ($identity.Account) {
        Write-Host "   [OK] AWS configured" -ForegroundColor Green
        Write-Host "   Account: $($identity.Account)" -ForegroundColor Gray
        Write-Host "   User: $($identity.Arn)" -ForegroundColor Gray
        
        if ($identity.Account -eq "577004485374") {
            Write-Host "   [OK] Correct account!" -ForegroundColor Green
        } else {
            Write-Host "   [WARNING] Account mismatch. Expected: 577004485374" -ForegroundColor Yellow
        }
    } else {
        throw
    }
} catch {
    Write-Host "   [NOT CONFIGURED] AWS credentials needed" -ForegroundColor Red
    Write-Host "   Run: aws configure" -ForegroundColor Yellow
    Write-Host "   Get credentials: https://console.aws.amazon.com/iam/" -ForegroundColor Yellow
    $allReady = $false
}

# Check Docker
Write-Host "4. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] $dockerVersion" -ForegroundColor Green
    } else {
        throw
    }
} catch {
    Write-Host "   [MISSING] Docker not found" -ForegroundColor Red
    $allReady = $false
}

# Check Maven
Write-Host "5. Checking Maven..." -ForegroundColor Yellow
try {
    $mavenVersion = mvn --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] $mavenVersion" -ForegroundColor Green
    } else {
        throw
    }
} catch {
    Write-Host "   [MISSING] Maven not found" -ForegroundColor Red
    $allReady = $false
}

# Check Node.js
Write-Host "6. Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Node.js $nodeVersion" -ForegroundColor Green
    } else {
        throw
    }
} catch {
    Write-Host "   [MISSING] Node.js not found" -ForegroundColor Red
    $allReady = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allReady) {
    Write-Host "✅ All prerequisites met!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ready to deploy! Choose an option:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Quick Deploy (Automated)" -ForegroundColor Green
    Write-Host "   .\quick-deploy.ps1 -Environment development" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Step-by-Step (Interactive)" -ForegroundColor Cyan
    Write-Host "   .\deploy-step-by-step.ps1 -Environment development" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Install & Deploy (Guided)" -ForegroundColor Yellow
    Write-Host "   .\install-and-deploy.ps1" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter choice (1, 2, or 3) or press Enter to exit"
    
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
            Write-Host "`nStarting Install & Deploy..." -ForegroundColor Cyan
            & "$PSScriptRoot\install-and-deploy.ps1"
        }
        default {
            Write-Host "Exiting. Run this script again when ready to deploy." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ Some prerequisites are missing" -ForegroundColor Red
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Install missing tools" -ForegroundColor White
    Write-Host "2. Configure AWS: aws configure" -ForegroundColor White
    Write-Host "3. Run this script again to verify" -ForegroundColor White
    Write-Host ""
}

