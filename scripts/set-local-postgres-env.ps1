# Sets environment variables so all services use a native PostgreSQL instance.
# Usage:
#   .\set-local-postgres-env.ps1                   # apply defaults for this session
#   .\set-local-postgres-env.ps1 -Persist          # persist defaults for future shells
#   .\set-local-postgres-env.ps1 -Host 192.168.1.5 -Persist:$false
param(
    [string]$Host = "localhost",
    [int]$Port = 5432,
    [string]$Database = "kado24_db",
    [string]$User = "kado24_user",
    [string]$Password = "kado24_pass",
    [switch]$Persist
)

$envMap = @{
    POSTGRES_HOST      = $Host
    POSTGRES_PORT      = $Port
    POSTGRES_DB        = $Database
    POSTGRES_USER      = $User
    POSTGRES_PASSWORD  = $Password
    DB_HOST            = $Host
    DB_PORT            = $Port
    DB_NAME            = $Database
    DB_USER            = $User
    DB_PASSWORD        = $Password
}

foreach ($entry in $envMap.GetEnumerator()) {
    $envName = $entry.Key
    $envValue = "$($entry.Value)"
    $env:$envName = $envValue
}

if ($Persist.IsPresent) {
    foreach ($entry in $envMap.GetEnumerator()) {
        setx $entry.Key "$($entry.Value)" > $null
    }
    Write-Host "Persisted PostgreSQL settings for future PowerShell sessions."
} else {
    Write-Host "Applied PostgreSQL settings for the current PowerShell session."
}

Write-Host ""
Write-Host "POSTGRES_HOST=$Host"
Write-Host "POSTGRES_PORT=$Port"
Write-Host "POSTGRES_DB=$Database"
Write-Host "POSTGRES_USER=$User"









