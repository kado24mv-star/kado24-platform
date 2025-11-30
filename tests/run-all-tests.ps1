# =============================================
# Run All Integration Tests
# Convenience script to run all tests from project root
# =============================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kado24 Platform - Integration Tests" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testDir = Join-Path $PSScriptRoot "integration"
$testRunner = Join-Path $testDir "test-runner.ps1"

if (-not (Test-Path $testRunner)) {
    Write-Host "❌ Test runner not found: $testRunner" -ForegroundColor Red
    exit 1
}

# Change to test directory and run
Push-Location $testDir
try {
    & .\test-runner.ps1 @args
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

exit $exitCode

