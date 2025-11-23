# Script to install missing prerequisites using Chocolatey

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Missing Prerequisites" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Chocolatey is installed
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Chocolatey installed. Please restart PowerShell and run this script again." -ForegroundColor Green
    exit
}

Write-Host "Chocolatey found. Installing missing tools..." -ForegroundColor Green
Write-Host ""

# Check what's missing
$missing = @()

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    $missing += "awscli"
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    $missing += "terraform"
}

if ($missing.Count -eq 0) {
    Write-Host "All tools are already installed!" -ForegroundColor Green
    exit
}

Write-Host "Installing: $($missing -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Install missing tools
foreach ($package in $missing) {
    Write-Host "Installing $package..." -ForegroundColor Cyan
    choco install $package -y
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] $package installed" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] Failed to install $package" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Please restart PowerShell for changes to take effect!" -ForegroundColor Yellow
Write-Host ""
Write-Host "After restarting, verify installation:" -ForegroundColor Yellow
Write-Host "  .\check-prerequisites.ps1" -ForegroundColor White
Write-Host ""

