# Integration Tests - Kado24 Platform

Automated integration test suite for the Kado24 platform covering OAuth2 authentication, API Gateway, and service endpoints.

## Quick Start

```powershell
# From project root
.\tests\run-all-tests.ps1

# Or from tests directory
cd tests\integration
.\test-runner.ps1
```

## Test Coverage

### ✅ OAuth2 Authentication
- OIDC Discovery endpoint
- JWKS endpoint
- Token generation (client credentials)
- Token validation
- Invalid token rejection

### ✅ API Gateway
- Health checks
- Route configuration
- CORS validation
- OAuth2 token validation at gateway
- Protected route access control

### ✅ Service Endpoints
- User Service APIs
- Voucher Service APIs
- Merchant Service APIs
- Order Service APIs

## Test Files

- `tests/integration/test-config.ps1` - Configuration and constants
- `tests/integration/test-utils.ps1` - Utility functions
- `tests/integration/test-oauth2.ps1` - OAuth2 tests
- `tests/integration/test-gateway.ps1` - Gateway tests
- `tests/integration/test-api-endpoints.ps1` - API endpoint tests
- `tests/integration/test-runner.ps1` - Main test runner
- `tests/run-all-tests.ps1` - Convenience script from project root

## Prerequisites

1. Start all services:
   ```powershell
   docker-compose -f docker-compose.services.yml up -d
   ```

2. Configure APISIX routes:
   ```powershell
   cd gateway\apisix
   .\setup-all-routes-cors.ps1
   .\setup-oauth2-validation.ps1
   ```

## Running Tests

### All Tests
```powershell
.\tests\run-all-tests.ps1
```

### Specific Test Suites
```powershell
cd tests\integration

# OAuth2 only
.\test-runner.ps1 -OAuth2Only

# Gateway only
.\test-runner.ps1 -GatewayOnly

# API endpoints only
.\test-runner.ps1 -ApiOnly
```

### Skip Prerequisites Check
```powershell
.\test-runner.ps1 -SkipPrerequisites
```

## Test Results

Tests output results in real-time with:
- ✅ Passed tests (green)
- ❌ Failed tests (red)
- ⏭️ Skipped tests (yellow)

Final summary shows:
- Total tests run
- Passed/Failed/Skipped counts
- List of failed tests

## Configuration

Edit `tests/integration/test-config.ps1` to modify:
- Service URLs
- OAuth2 client credentials
- Test timeouts
- Test data

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Run Integration Tests
  run: |
    docker-compose -f docker-compose.services.yml up -d
    Start-Sleep -Seconds 30
    .\tests\run-all-tests.ps1
```

## Documentation

See `tests/integration/README.md` for detailed documentation.

## Related

- `OAUTH2-GATEWAY-IMPLEMENTATION.md` - OAuth2 implementation
- `OAUTH2-PROTECTION-STATUS.md` - Security status
- `VERIFY-BACKEND-APIS.md` - API verification

