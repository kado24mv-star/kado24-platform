# Fix PATH for AWS CLI and Terraform
# Run this if tools are installed but not found

Write-Host "Fixing PATH for AWS CLI and Terraform..." -ForegroundColor Cyan
Write-Host ""

# Common installation paths
$awsPaths = @(
    "C:\Program Files\Amazon\AWSCLIV2",
    "$env:ProgramFiles\Amazon\AWSCLIV2",
    "$env:LOCALAPPDATA\Programs\Python\Python*\Scripts"
)

$terraformPaths = @(
    "C:\terraform",
    "$env:USERPROFILE\terraform",
    "$env:LOCALAPPDATA\terraform"
)

$pathsToAdd = @()

# Find AWS CLI
Write-Host "Looking for AWS CLI..." -ForegroundColor Yellow
foreach ($path in $awsPaths) {
    $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
    if ($resolved) {
        $awsExe = Join-Path $resolved "aws.exe"
        if (Test-Path $awsExe) {
            Write-Host "  Found: $resolved" -ForegroundColor Green
            $pathsToAdd += $resolved
            break
        }
    }
}

# Find Terraform
Write-Host "Looking for Terraform..." -ForegroundColor Yellow
foreach ($path in $terraformPaths) {
    if (Test-Path $path) {
        $terraformExe = Join-Path $path "terraform.exe"
        if (Test-Path $terraformExe) {
            Write-Host "  Found: $path" -ForegroundColor Green
            $pathsToAdd += $path
            break
        }
    }
}

# Check current PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User") -split ';'
$missingPaths = $pathsToAdd | Where-Object { $currentPath -notcontains $_ }

if ($missingPaths.Count -eq 0) {
    Write-Host "`nAll paths are already in PATH!" -ForegroundColor Green
    Write-Host "If tools still not found, RESTART PowerShell." -ForegroundColor Yellow
    exit
}

# Add missing paths
Write-Host "`nAdding paths to user PATH..." -ForegroundColor Yellow
foreach ($path in $missingPaths) {
    Write-Host "  Adding: $path" -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$path", "User")
    $env:Path += ";$path"
}

Write-Host "`nPaths added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: RESTART PowerShell for changes to take effect!" -ForegroundColor Yellow
Write-Host ""
Write-Host "After restarting, verify with:" -ForegroundColor Cyan
Write-Host "  aws --version" -ForegroundColor White
Write-Host "  terraform version" -ForegroundColor White

