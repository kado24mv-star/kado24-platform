# =============================================
# Integration Test Utilities
# =============================================

# Import test config
. "$PSScriptRoot\test-config.ps1"

function Write-TestHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Details = ""
    )
    
    $script:TEST_RESULTS.Total++
    
    if ($Passed) {
        $script:TEST_RESULTS.Passed++
        Write-Host "  ✅ PASS: $TestName" -ForegroundColor Green
        if ($Message) {
            Write-Host "     $Message" -ForegroundColor Gray
        }
    } else {
        $script:TEST_RESULTS.Failed++
        $script:TEST_RESULTS.FailedTests += $TestName
        Write-Host "  ❌ FAIL: $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "     $Message" -ForegroundColor Yellow
        }
        if ($Details) {
            Write-Host "     Details: $Details" -ForegroundColor Gray
        }
    }
}

function Write-TestSkipped {
    param([string]$TestName, [string]$Reason = "")
    
    $script:TEST_RESULTS.Total++
    $script:TEST_RESULTS.Skipped++
    Write-Host "  ⏭️  SKIP: $TestName" -ForegroundColor Yellow
    if ($Reason) {
        Write-Host "     $Reason" -ForegroundColor Gray
    }
}

function Invoke-ApiRequest {
    param(
        [string]$Method = "GET",
        [string]$Url,
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [int]$ExpectedStatus = 200,
        [switch]$SkipStatusCheck
    )
    
    try {
        $requestParams = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = $script:HTTP_TIMEOUT
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            if ($Body -is [string]) {
                $requestParams.Body = $Body
            } else {
                $requestParams.Body = ($Body | ConvertTo-Json -Depth 10)
                if (-not $Headers.ContainsKey("Content-Type")) {
                    $requestParams.Headers["Content-Type"] = "application/json"
                }
            }
        }
        
        $response = Invoke-WebRequest @requestParams
        
        if (-not $SkipStatusCheck -and $response.StatusCode -ne $ExpectedStatus) {
            return @{
                Success = $false
                StatusCode = $response.StatusCode
                ExpectedStatus = $ExpectedStatus
                Content = $response.Content
                Error = "Expected status $ExpectedStatus but got $($response.StatusCode)"
            }
        }
        
        $content = $response.Content
        try {
            $jsonContent = $content | ConvertFrom-Json
        } catch {
            $jsonContent = $null
        }
        
        return @{
            Success = $true
            StatusCode = $response.StatusCode
            Content = $content
            JsonContent = $jsonContent
            Headers = $response.Headers
        }
    } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        $errorContent = ""
        try {
            if ($_.Exception.Response) {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $errorContent = $reader.ReadToEnd()
            }
        } catch {
            # Ignore
        }
        
        return @{
            Success = $false
            StatusCode = $statusCode
            Content = $errorContent
            Error = $_.Exception.Message
        }
    }
}

function Get-OAuth2Token {
    param(
        [string]$GrantType = "client_credentials",
        [string]$ClientId = $script:OAUTH2_CLIENT_ID,
        [string]$ClientSecret = $script:OAUTH2_CLIENT_SECRET,
        [string]$Username = "",
        [string]$Password = "",
        [string]$Scope = "read write"
    )
    
    try {
        # Use Basic Authentication for client credentials
        $credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${ClientId}:${ClientSecret}"))
        
        $bodyParams = @{
            grant_type = $GrantType
            scope = $Scope
        }
        
        if ($GrantType -eq "password" -and $Username -and $Password) {
            $bodyParams.username = $Username
            $bodyParams.password = $Password
        }
        
        $body = ($bodyParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join "&"
        
        $headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Authorization" = "Basic $credentials"
        }
        
        $response = Invoke-ApiRequest `
            -Method "POST" `
            -Url $script:OAUTH2_TOKEN_ENDPOINT `
            -Headers $headers `
            -Body $body `
            -ExpectedStatus 200 `
            -SkipStatusCheck
        
        if ($response.Success -and $response.JsonContent -and $response.JsonContent.access_token) {
            return $response.JsonContent.access_token
        }
        
        # Try without Basic Auth (client_secret in body)
        if (-not $response.Success) {
            $bodyParams.client_id = $ClientId
            $bodyParams.client_secret = $ClientSecret
            $body = ($bodyParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join "&"
            
            $headers = @{
                "Content-Type" = "application/x-www-form-urlencoded"
            }
            
            $response = Invoke-ApiRequest `
                -Method "POST" `
                -Url $script:OAUTH2_TOKEN_ENDPOINT `
                -Headers $headers `
                -Body $body `
                -ExpectedStatus 200 `
                -SkipStatusCheck
            
            if ($response.Success -and $response.JsonContent -and $response.JsonContent.access_token) {
                return $response.JsonContent.access_token
            }
        }
    } catch {
        Write-Host "  Error getting OAuth2 token: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    return $null
}

function Wait-ForService {
    param(
        [string]$Url,
        [int]$Timeout = $script:SERVICE_STARTUP_TIMEOUT,
        [string]$HealthEndpoint = "/actuator/health"
    )
    
    $startTime = Get-Date
    $healthUrl = "$Url$HealthEndpoint"
    
    Write-Host "Waiting for service at $Url..." -ForegroundColor Yellow
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $Timeout) {
        try {
            $response = Invoke-WebRequest -Uri $healthUrl -Method GET -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "  ✅ Service is ready" -ForegroundColor Green
                return $true
            }
        } catch {
            # Service not ready yet
        }
        
        Start-Sleep -Seconds 2
    }
    
    Write-Host "  ❌ Service did not become ready within timeout" -ForegroundColor Red
    return $false
}

function Show-TestSummary {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Test Summary" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Tests: $($script:TEST_RESULTS.Total)" -ForegroundColor White
    Write-Host "  ✅ Passed: $($script:TEST_RESULTS.Passed)" -ForegroundColor Green
    Write-Host "  ❌ Failed: $($script:TEST_RESULTS.Failed)" -ForegroundColor Red
    Write-Host "  ⏭️  Skipped: $($script:TEST_RESULTS.Skipped)" -ForegroundColor Yellow
    Write-Host ""
    
    if ($script:TEST_RESULTS.Failed -gt 0) {
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($test in $script:TEST_RESULTS.FailedTests) {
            Write-Host "  - $test" -ForegroundColor Yellow
        }
        Write-Host ""
        return $false
    }
    
    return $true
}

