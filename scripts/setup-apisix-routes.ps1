# =============================================
# Quick Setup Script - APISIX Routes with CORS
# Run this from project root after restarting PC
# =============================================

Write-Host "🚀 Setting up APISIX routes with CORS..." -ForegroundColor Green
Write-Host ""

# Navigate to gateway directory
$scriptPath = Join-Path $PSScriptRoot "..\gateway\apisix\setup-all-routes-cors.ps1"

if (Test-Path $scriptPath) {
    & $scriptPath
} else {
    Write-Host "❌ Script not found at: $scriptPath" -ForegroundColor Red
    Write-Host "Please run from project root directory" -ForegroundColor Yellow
    exit 1
}

