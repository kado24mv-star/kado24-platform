<# 
    Helper script to start/stop the Angular Admin Portal dev server.
    Usage examples:
        .\admin-portal-frontend.ps1 -Action start
        .\admin-portal-frontend.ps1 -Action stop
        .\admin-portal-frontend.ps1 -Action status
#>

[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'status', 'restart')]
    [string]$Action = 'start',

    [int]$Port = 4200,

    [switch]$ForceInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $repoRoot 'frontend\admin-portal'
$pidFile = Join-Path $frontendPath '.admin-portal-frontend.pid'
$npmExecutable = $null
$shellExecutable = $null

try {
    $npmExecutable = (Get-Command npm -ErrorAction Stop).Source
    $shellExecutable = (Get-Command powershell -ErrorAction Stop).Source
} catch {
    Write-Error "npm or PowerShell executable not found in PATH. Install Node.js / ensure PowerShell is available before running this script."
    exit 1
}

function Get-ProcessState {
    if (-not (Test-Path $pidFile)) {
        return $null
    }

    try {
        $raw = Get-Content $pidFile -Raw
        $state = $raw | ConvertFrom-Json
    } catch {
        Remove-Item $pidFile -ErrorAction SilentlyContinue
        return $null
    }

    if (-not $state.Pid) {
        Remove-Item $pidFile -ErrorAction SilentlyContinue
        return $null
    }

    try {
        $proc = Get-Process -Id $state.Pid -ErrorAction Stop
        return [PSCustomObject]@{
            Process = $proc
            Port    = $state.Port
        }
    } catch {
        Remove-Item $pidFile -ErrorAction SilentlyContinue
        return $null
    }
}

function Ensure-Dependencies {
    $nodeModules = Join-Path $frontendPath 'node_modules'
    if ($ForceInstall -or -not (Test-Path $nodeModules)) {
        Write-Host "Installing npm dependencies..."
        Push-Location $frontendPath
        try {
            npm install | Write-Host
        } finally {
            Pop-Location
        }
    }
}

function Start-AdminPortal {
    $current = Get-ProcessState
    if ($null -ne $current) {
        Write-Host "Admin portal frontend already running (PID $($current.Process.Id)) on http://localhost:$($current.Port)."
        return
    }

    Ensure-Dependencies

    $command = "npm run start -- --port $Port"
    $process = Start-Process -FilePath $shellExecutable `
        -ArgumentList @('-NoExit', '-Command', $command) `
        -WorkingDirectory $frontendPath `
        -WindowStyle Normal `
        -PassThru

    @{
        Pid  = $process.Id
        Port = $Port
        Date = (Get-Date)
    } | ConvertTo-Json | Set-Content -Path $pidFile

    Write-Host "Admin portal frontend started on http://localhost:$Port (PID $($process.Id))."
}

function Stop-AdminPortal {
    $current = Get-ProcessState
    if ($null -eq $current) {
        Write-Host "Admin portal frontend is not running."
        return
    }

    Write-Host "Stopping admin portal frontend (PID $($current.Process.Id))..."
    Stop-Process -Id $current.Process.Id -ErrorAction SilentlyContinue
    Remove-Item $pidFile -ErrorAction SilentlyContinue
    Write-Host "Stopped."
}

switch ($Action.ToLowerInvariant()) {
    'start'   { Start-AdminPortal }
    'stop'    { Stop-AdminPortal }
    'status'  {
        $current = Get-ProcessState
        if ($null -eq $current) {
            Write-Host "Admin portal frontend is not running."
        } else {
            Write-Host "Admin portal frontend running (PID $($current.Process.Id)) on http://localhost:$($current.Port)."
        }
    }
    'restart' {
        Stop-AdminPortal
        Start-AdminPortal
    }
}

