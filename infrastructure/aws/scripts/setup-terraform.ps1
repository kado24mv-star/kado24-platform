# Setup Terraform - Extract and add to PATH

Write-Host "Setting up Terraform..." -ForegroundColor Cyan
Write-Host ""

$terraformDir = "C:\terraform"
$downloadsPath = "$env:USERPROFILE\Downloads"

# Check if already exists
if (Test-Path "$terraformDir\terraform.exe") {
    Write-Host "Terraform already exists at: $terraformDir" -ForegroundColor Green
    Write-Host "Adding to PATH..." -ForegroundColor Yellow
    
    # Add to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$terraformDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$terraformDir", "User")
        $env:Path += ";$terraformDir"
        Write-Host "  [OK] Added to PATH" -ForegroundColor Green
    } else {
        Write-Host "  [OK] Already in PATH" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "RESTART PowerShell, then verify with: terraform version" -ForegroundColor Yellow
    exit
}

# Look for downloaded Terraform ZIP
Write-Host "Looking for Terraform ZIP in Downloads..." -ForegroundColor Yellow
$terraformZip = Get-ChildItem -Path $downloadsPath -Filter "terraform_*.zip" -ErrorAction SilentlyContinue | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

if ($terraformZip) {
    Write-Host "  Found: $($terraformZip.Name)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Extracting Terraform..." -ForegroundColor Yellow
    
    # Create directory
    if (-not (Test-Path $terraformDir)) {
        New-Item -ItemType Directory -Path $terraformDir -Force | Out-Null
    }
    
    # Extract
    Expand-Archive -Path $terraformZip.FullName -DestinationPath $terraformDir -Force
    
    # Verify
    if (Test-Path "$terraformDir\terraform.exe") {
        Write-Host "  [OK] Extracted successfully" -ForegroundColor Green
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$terraformDir*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$terraformDir", "User")
            $env:Path += ";$terraformDir"
            Write-Host "  [OK] Added to PATH" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Terraform setup complete!" -ForegroundColor Green
        Write-Host "RESTART PowerShell, then verify with: terraform version" -ForegroundColor Yellow
    } else {
        Write-Host "  [ERROR] Extraction failed" -ForegroundColor Red
        Write-Host "  Please extract manually to: $terraformDir" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [NOT FOUND] Terraform ZIP not found in Downloads" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Cyan
    Write-Host "  1. Download Terraform: https://developer.hashicorp.com/terraform/downloads" -ForegroundColor White
    Write-Host "  2. Extract the ZIP to: C:\terraform" -ForegroundColor White
    Write-Host "  3. Run this script again" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "Open Terraform download page? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Start-Process "https://developer.hashicorp.com/terraform/downloads"
    }
}

