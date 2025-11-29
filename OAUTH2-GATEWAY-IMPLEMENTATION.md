# OAuth2 Gateway Implementation - Kado24 Platform

## Overview

This document describes the implementation of OAuth2 token validation at the APISIX gateway level.

## Implementation Strategy

### Approach: OpenID Connect Plugin

We use APISIX's `openid-connect` plugin in `bearer_only` mode to validate OAuth2 JWT tokens at the gateway level.

### Why OpenID Connect Plugin?

1. **OIDC Discovery**: Auth-service has OIDC enabled (`.oidc(Customizer.withDefaults())`)
2. **Automatic Configuration**: Plugin automatically discovers JWKS endpoint from OIDC discovery
3. **Token Validation**: Validates JWT signature, expiration, and issuer
4. **Early Rejection**: Invalid tokens are rejected before reaching backend services

## Configuration

### OAuth2 Authorization Server

- **Service**: `auth-service` (Port 8081)
- **OIDC Discovery**: `http://kado24-auth-service:8081/.well-known/openid-configuration`
- **JWKS Endpoint**: `http://kado24-auth-service:8081/oauth2/jwks`
- **Issuer**: `http://kado24-auth-service:8081`

### APISIX Plugin Configuration

```json
{
  "openid_connect": {
    "bearer_only": true,
    "discovery": "http://kado24-auth-service:8081/.well-known/openid-configuration",
    "client_id": "apisix-gateway",
    "client_secret": "apisix-gateway-secret",
    "verify_claims": true,
    "verify_claims_options": {
      "iss": "http://kado24-auth-service:8081"
    },
    "ssl_verify": false,
    "timeout": 3000
  }
}
```

## Setup Scripts

### 1. `setup-oauth2-validation.ps1`

**Purpose**: Configure APISIX routes with OAuth2 token validation

**Usage**:
```powershell
cd gateway\apisix
.\setup-oauth2-validation.ps1
```

**What it does**:
- Tests OIDC discovery endpoint connectivity
- Updates all protected routes with `openid-connect` plugin
- Configures token validation settings
- Falls back to basic mode if plugin is unavailable

### 2. `setup-all-routes-cors.ps1`

**Purpose**: Configure CORS for all routes

**Usage**:
```powershell
cd gateway\apisix
.\setup-all-routes-cors.ps1
```

**Note**: This script only sets up CORS. OAuth2 validation is configured separately.

## Protected Routes

All routes that require authentication are configured with OAuth2 validation:

- User Service: `/api/v1/users/*`
- Voucher Service (write operations): `/api/v1/vouchers/*` (POST, PUT, DELETE, PATCH)
- Order Service: `/api/v1/orders/*`
- Payment Service: `/api/v1/payments/*`
- Wallet Service: `/api/v1/wallet/*`
- Redemption Service: `/api/v1/redemptions/*`
- Merchant Service: `/api/v1/merchants/*`
- Notification Service: `/api/v1/notifications/*`
- Payout Service: `/api/v1/payouts/*`
- Analytics Service: `/api/v1/analytics/*`

## Public Routes

Routes that don't require authentication:

- Auth Service: `/api/v1/auth/*`
- Voucher Service (read): `/api/v1/vouchers` (GET)
- Categories: `/api/v1/categories/*`
- Mock Payment: `/api/mock/payment/*`

## Security Flow

```
Client Request
    ↓
APISIX Gateway (Port 9080)
    ├─ Extract Authorization header
    ├─ Validate JWT token using openid-connect plugin
    │   ├─ Fetch OIDC discovery configuration
    │   ├─ Get JWKS from auth-service
    │   ├─ Validate JWT signature
    │   ├─ Verify token expiration
    │   └─ Verify issuer
    ├─ If valid: Forward to backend service
    └─ If invalid: Return 401 Unauthorized
        ↓
Backend Service (OAuth2 Resource Server)
    ├─ Extract JWT from Authorization header
    ├─ Validate token (defense in depth)
    └─ Process request
```

## Benefits

1. **Early Rejection**: Invalid tokens are rejected at gateway level
2. **Reduced Load**: Backend services don't process invalid requests
3. **Better Security**: Multiple layers of validation
4. **Centralized Configuration**: Token validation logic in one place

## Testing

### Test Without Token (Should Fail)

```bash
curl http://localhost:9080/api/v1/merchants/register
```

**Expected**: `401 Unauthorized`

### Test With Invalid Token (Should Fail)

```bash
curl -H "Authorization: Bearer invalid-token" \
  http://localhost:9080/api/v1/merchants/register
```

**Expected**: `401 Unauthorized`

### Test With Valid Token (Should Succeed)

```bash
# First, get a valid token from auth-service
TOKEN=$(curl -X POST http://localhost:8081/oauth2/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=kado24-backend&client_secret=kado24-backend-secret" \
  | jq -r '.access_token')

# Then use it
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:9080/api/v1/merchants/register
```

**Expected**: `200 OK` or appropriate response from backend

## Troubleshooting

### Issue: OIDC Discovery Endpoint Not Found

**Symptom**: Routes fail to validate tokens, fall back to basic mode

**Solution**:
1. Ensure auth-service is running
2. Check if OIDC is enabled in `OAuth2AuthorizationServerConfig.java`
3. Verify endpoint: `http://localhost:8081/.well-known/openid-configuration`

### Issue: Plugin Not Available

**Symptom**: Script shows warnings, routes use fallback mode

**Solution**:
1. Ensure APISIX has `openid-connect` plugin installed
2. Check APISIX version (requires 2.10+)
3. Install plugin if missing: `luarocks install apisix-plugin-openid-connect`

### Issue: Token Validation Fails

**Symptom**: Valid tokens are rejected

**Solution**:
1. Check issuer matches: `http://kado24-auth-service:8081`
2. Verify JWKS endpoint is accessible
3. Check token expiration
4. Verify token was issued by correct auth-service instance

## Fallback Behavior

If the `openid-connect` plugin is not available or fails to configure:

1. Routes are configured with CORS only
2. Backend services perform full token validation
3. System continues to work, but without gateway-level validation

## Next Steps

1. **Test Implementation**: Run setup script and test with valid/invalid tokens
2. **Monitor Performance**: Check gateway logs for validation metrics
3. **Optimize**: Consider caching JWKS to reduce auth-service calls
4. **Document**: Update API documentation with authentication requirements

## Related Files

- `gateway/apisix/setup-oauth2-validation.ps1` - Main setup script
- `gateway/apisix/setup-all-routes-cors.ps1` - CORS configuration
- `backend/services/auth-service/src/main/java/com/kado24/auth/config/OAuth2AuthorizationServerConfig.java` - OAuth2 server config
- `OAUTH2-PROTECTION-STATUS.md` - Current protection status

