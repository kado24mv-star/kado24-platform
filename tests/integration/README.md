# Integration Tests - Kado24 Platform

This directory contains automated integration tests for the Kado24 platform.

## Test Structure

```
tests/integration/
├── test-config.ps1          # Test configuration and constants
├── test-utils.ps1            # Test utility functions
├── test-oauth2.ps1           # OAuth2 authentication tests
├── test-gateway.ps1          # API Gateway tests
├── test-api-endpoints.ps1    # API endpoint tests
├── test-runner.ps1           # Main test runner script
└── README.md                 # This file
```

## Prerequisites

1. **Services Running**: All backend services must be running
   ```powershell
   docker-compose -f docker-compose.services.yml up -d
   ```

2. **APISIX Gateway**: Gateway must be running and routes configured
   ```powershell
   cd gateway\apisix
   .\setup-all-routes-cors.ps1
   .\setup-oauth2-validation.ps1
   ```

3. **PowerShell**: Requires PowerShell 5.1 or later

## Running Tests

### Run All Tests

```powershell
cd tests\integration
.\test-runner.ps1
```

### Run Specific Test Suites

```powershell
# OAuth2 tests only
.\test-runner.ps1 -OAuth2Only

# Gateway tests only
.\test-runner.ps1 -GatewayOnly

# API endpoint tests only
.\test-runner.ps1 -ApiOnly
```

### Skip Prerequisites Check

```powershell
.\test-runner.ps1 -SkipPrerequisites
```

## Test Suites

### 1. OAuth2 Tests (`test-oauth2.ps1`)

Tests OAuth2 authentication and authorization:

- OIDC Discovery Endpoint
- JWKS Endpoint
- Token Endpoint (Client Credentials)
- Token Validation
- Invalid Token Rejection
- Auth Service Endpoints

### 2. Gateway Tests (`test-gateway.ps1`)

Tests API Gateway functionality:

- Gateway Health Check
- Route Configuration
- CORS Configuration
- OAuth2 Token Validation at Gateway
- Protected Route Access Control

### 3. API Endpoint Tests (`test-api-endpoints.ps1`)

Tests individual service endpoints:

- User Service Endpoints
- Voucher Service Endpoints
- Merchant Service Endpoints
- Order Service Endpoints

## Test Configuration

Edit `test-config.ps1` to modify:

- Service URLs
- OAuth2 client credentials
- Test timeouts
- Test credentials

## Test Utilities

The `test-utils.ps1` file provides:

- `Invoke-ApiRequest` - Make HTTP requests with error handling
- `Get-OAuth2Token` - Obtain OAuth2 access tokens
- `Wait-ForService` - Wait for services to become ready
- `Write-TestResult` - Record test results
- `Show-TestSummary` - Display test summary

## Example Test Output

```
========================================
Kado24 Platform Integration Tests
========================================

Checking prerequisites...
  ✅ Auth Service is running
  ✅ API Gateway is running

Running all integration tests...

========================================
OAuth2 Endpoints Tests
========================================
  ✅ PASS: OIDC Discovery Endpoint
  ✅ PASS: JWKS Endpoint
  ✅ PASS: OAuth2 Token Endpoint (Client Credentials)
  ✅ PASS: OAuth2 Token Endpoint (Invalid Client)

========================================
Token Validation Tests
========================================
  ✅ PASS: Valid Token Validation
  ✅ PASS: Invalid Token Rejection
  ✅ PASS: Missing Token Rejection

========================================
Test Summary
========================================

Total Tests: 15
  ✅ Passed: 15
  ❌ Failed: 0
  ⏭️  Skipped: 0

✅ All tests passed!
```

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Integration Tests
  run: |
    docker-compose -f docker-compose.services.yml up -d
    Start-Sleep -Seconds 30
    cd tests\integration
    .\test-runner.ps1
```

## Troubleshooting

### Services Not Running

```
❌ Auth Service is not running
```

**Solution**: Start services:
```powershell
docker-compose -f docker-compose.services.yml up -d
```

### Gateway Routes Not Configured

```
❌ FAIL: Gateway Routing Tests
```

**Solution**: Configure APISIX routes:
```powershell
cd gateway\apisix
.\setup-all-routes-cors.ps1
.\setup-oauth2-validation.ps1
```

### Token Validation Fails

```
❌ FAIL: Valid Token Validation
```

**Solution**: 
1. Check OAuth2 client credentials in `test-config.ps1`
2. Verify auth-service is running and OIDC is enabled
3. Check gateway OAuth2 validation configuration

## Adding New Tests

1. Create a new test file: `test-<feature>.ps1`
2. Import utilities: `. "$PSScriptRoot\test-utils.ps1"`
3. Write test functions following the existing pattern
4. Add test execution to `test-runner.ps1`

Example:

```powershell
# test-new-feature.ps1
. "$PSScriptRoot\test-utils.ps1"

function Test-NewFeature {
    Write-TestHeader "New Feature Tests"
    
    $testName = "Test New Feature"
    $response = Invoke-ApiRequest -Url "http://localhost:9080/api/v1/new-feature"
    Write-TestResult -TestName $testName -Passed $response.Success
}
```

## Best Practices

1. **Use Test Utilities**: Always use `Invoke-ApiRequest` for HTTP requests
2. **Handle Errors**: Use try-catch blocks for error handling
3. **Skip When Appropriate**: Use `Write-TestSkipped` for tests that can't run
4. **Clear Messages**: Provide meaningful test result messages
5. **Independent Tests**: Tests should be independent and not rely on each other

## Related Documentation

- `OAUTH2-GATEWAY-IMPLEMENTATION.md` - OAuth2 implementation details
- `OAUTH2-PROTECTION-STATUS.md` - Security status
- `VERIFY-BACKEND-APIS.md` - API verification guide

