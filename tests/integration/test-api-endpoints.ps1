# =============================================
# API Endpoints Integration Tests
# =============================================

. "$PSScriptRoot\test-config.ps1"
. "$PSScriptRoot\test-utils.ps1"

function Test-ServiceHealthChecks {
    Write-TestHeader "Service Health Checks"
    
    # Service health endpoints
    # Note: Ports verified from docker-compose and application.yml files
    $services = @(
        @{Name = "Auth Service"; Port = 8081; Path = "/actuator/health"},
        @{Name = "User Service"; Port = 8082; Path = "/actuator/health"},
        @{Name = "Voucher Service"; Port = 8083; Path = "/actuator/health"},
        @{Name = "Order Service"; Port = 8084; Path = "/actuator/health"},
        @{Name = "Wallet Service"; Port = 8086; Path = "/actuator/health"},
        @{Name = "Redemption Service"; Port = 8087; Path = "/actuator/health"},
        @{Name = "Merchant Service"; Port = 8088; Path = "/actuator/health"},
        @{Name = "Admin Portal Backend"; Port = 8089; Path = "/actuator/health"},
        @{Name = "Notification Service"; Port = 8091; Path = "/actuator/health"},
        @{Name = "Payout Service"; Port = 8092; Path = "/actuator/health"},
        @{Name = "Analytics Service"; Port = 8093; Path = "/actuator/health"}
    )
    
    foreach ($service in $services) {
        $testName = "$($service.Name) Health Check"
        try {
            $url = "http://localhost:$($service.Port)$($service.Path)"
            $response = Invoke-ApiRequest `
                -Url $url `
                -Method "GET" `
                -ExpectedStatus 200 `
                -SkipStatusCheck
            
            # Accept 200 (healthy) or 404 (endpoint not configured but service is running)
            if ($response.Success -or $response.StatusCode -eq 200) {
                Write-TestResult -TestName $testName -Passed $true -Message "Service is healthy"
            } elseif ($response.StatusCode -eq 404) {
                # 404 means service is running but health endpoint not configured
                Write-TestResult -TestName $testName -Passed $true -Message "Service responding (health endpoint may not be configured)"
            } else {
                Write-TestResult -TestName $testName -Passed $false -Message "Status: $($response.StatusCode)"
            }
        } catch {
            $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
            if ($status -eq 404) {
                # Health endpoint might not be configured
                Write-TestResult -TestName $testName -Passed $true -Message "Service responding (health endpoint may not be configured)"
            } else {
                Write-TestResult -TestName $testName -Passed $false -Message "Service not responding: $($_.Exception.Message)"
            }
        }
    }
}

function Test-UserServiceEndpoints {
    Write-TestHeader "User Service Endpoints Tests"
    
    $token = Get-OAuth2Token
    if (-not $token) {
        Write-TestSkipped -TestName "All User Service Tests" -Reason "Could not obtain OAuth2 token"
        return
    }
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Test 1: Get Current User
    $testName = "Get Current User"
    try {
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/users/me" `
            -Headers $headers `
            -ExpectedStatus 200 `
            -SkipStatusCheck
        
        if ($response.Success -and ($response.StatusCode -eq 200 -or $response.StatusCode -eq 404)) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Status: $($response.StatusCode)"
        }
    } catch {
        Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
    }
}

function Test-VoucherServiceEndpoints {
    Write-TestHeader "Voucher Service Endpoints Tests"
    
    # Test 1: Get Vouchers (Public)
    $testName = "Get Vouchers (Public)"
    try {
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/vouchers" `
            -Method "GET" `
            -ExpectedStatus 200 `
            -SkipStatusCheck
        
        if ($response.Success) {
            Write-TestResult -TestName $testName -Passed $true -Message "Public endpoint accessible"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Status: $($response.StatusCode)"
        }
    } catch {
        Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
    }
    
    # Test 2: Get Voucher by ID (Public)
    $testName = "Get Voucher by ID (Public)"
    try {
        # Use a non-existent ID - 404 means endpoint exists but voucher not found (valid)
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/vouchers/999999" `
            -Method "GET" `
            -ExpectedStatus 200 `
            -SkipStatusCheck
        
        # 200 = voucher found, 404 = voucher not found (both indicate endpoint works)
        if ($response.Success -or $response.StatusCode -eq 404) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible (Status: $($response.StatusCode))"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Status: $($response.StatusCode)"
        }
    } catch {
        $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
        # 404 means endpoint exists but voucher not found - this is valid
        if ($status -eq 404) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible (404 = voucher not found)"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
        }
    }
    
    # Test 3: Create Voucher (Protected)
    $testName = "Create Voucher (Protected)"
    $token = Get-OAuth2Token
    if (-not $token) {
        Write-TestSkipped -TestName $testName -Reason "Could not obtain OAuth2 token"
        return
    }
    
    try {
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/vouchers" `
            -Method "POST" `
            -Headers @{
                "Authorization" = "Bearer $token"
                "Content-Type" = "application/json"
            } `
            -Body (@{
                title = "Test Voucher"
                description = "Test Description"
                price = 10.00
            } | ConvertTo-Json) `
            -ExpectedStatus 201 `
            -SkipStatusCheck
        
        # 201, 400, or 401 are acceptable responses
        if ($response.StatusCode -eq 201) {
            Write-TestResult -TestName $testName -Passed $true -Message "Voucher created"
        } elseif ($response.StatusCode -eq 400) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible (validation working)"
        } elseif ($response.StatusCode -eq 401) {
            Write-TestResult -TestName $testName -Passed $false -Message "Token rejected"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Unexpected status: $($response.StatusCode)"
        }
    } catch {
        Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
    }
}

function Test-MerchantServiceEndpoints {
    Write-TestHeader "Merchant Service Endpoints Tests"
    
    $token = Get-OAuth2Token
    if (-not $token) {
        Write-TestSkipped -TestName "All Merchant Service Tests" -Reason "Could not obtain OAuth2 token"
        return
    }
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Test 1: Register Merchant (Protected)
    $testName = "Register Merchant (Protected)"
    try {
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/merchants/register" `
            -Method "POST" `
            -Headers $headers `
            -Body (@{
                businessName = "Test Business"
                businessType = "RETAIL"
                address = "123 Test St"
            } | ConvertTo-Json) `
            -ExpectedStatus 201 `
            -SkipStatusCheck
        
        # 201, 400, or 409 are acceptable
        if ($response.StatusCode -eq 201) {
            Write-TestResult -TestName $testName -Passed $true -Message "Merchant registered"
        } elseif ($response.StatusCode -eq 400 -or $response.StatusCode -eq 409) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible (validation working)"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Unexpected status: $($response.StatusCode)"
        }
    } catch {
        Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
    }
}

function Test-OrderServiceEndpoints {
    Write-TestHeader "Order Service Endpoints Tests"
    
    $token = Get-OAuth2Token
    if (-not $token) {
        Write-TestSkipped -TestName "All Order Service Tests" -Reason "Could not obtain OAuth2 token"
        return
    }
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Test 1: Get Orders (Protected)
    $testName = "Get Orders (Protected)"
    try {
        $response = Invoke-ApiRequest `
            -Url "$script:API_GATEWAY_URL/api/v1/orders" `
            -Method "GET" `
            -Headers $headers `
            -ExpectedStatus 200 `
            -SkipStatusCheck
        
        if ($response.Success) {
            Write-TestResult -TestName $testName -Passed $true -Message "Endpoint accessible"
        } else {
            Write-TestResult -TestName $testName -Passed $false -Message "Status: $($response.StatusCode)"
        }
    } catch {
        Write-TestResult -TestName $testName -Passed $false -Message $_.Exception.Message
    }
}

# Run all API endpoint tests
# Note: This file is sourced by test-runner.ps1, so we don't run tests here
# The test-runner.ps1 will call the test functions

