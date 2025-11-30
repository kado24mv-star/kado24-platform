# OAuth2 Endpoint Issue - Diagnosis

## Current Status

- ✅ Code fixes applied (filter chain order, explicit request matchers)
- ✅ Maven project rebuilt
- ✅ Docker image rebuilt with new code
- ❌ OAuth2 endpoints still returning 500 errors

## Error Details

**Error Message**: "No static resource oauth2/token"
**HTTP Status**: 500 Internal Server Error
**Endpoints Affected**:
- `/oauth2/token` - Token endpoint
- `/.well-known/openid-configuration` - OIDC discovery endpoint

**Working Endpoints**:
- `/oauth2/jwks` - JWKS endpoint (200 OK)

## Root Cause Analysis

The error "No static resource oauth2/token" suggests that:
1. Spring is trying to find `/oauth2/token` as a static resource
2. The OAuth2 Authorization Server endpoints are not being registered
3. The request is not reaching the OAuth2AuthorizationServerConfig filter chain

## Configuration Review

### OAuth2AuthorizationServerConfig
- ✅ `@Order(1)` - Should run before SecurityConfiguration
- ✅ `OAuth2AuthorizationServerConfiguration.applyDefaultSecurity(http)` - Should configure endpoints
- ✅ `AuthorizationServerSettings` bean configured with correct issuer and endpoints
- ✅ `RegisteredClientRepository` configured with clients

### SecurityConfiguration
- ✅ `@Order(2)` - Should run after OAuth2AuthorizationServerConfig
- ✅ OAuth2 endpoints permitted: `.requestMatchers("/oauth2/**", "/.well-known/**").permitAll()`

## Possible Issues

### 1. Filter Chain Not Matching
The OAuth2AuthorizationServerConfig filter chain might not be matching OAuth2 requests. `applyDefaultSecurity` should handle this, but there might be a conflict.

### 2. Missing Dependencies
Check if all required OAuth2 Authorization Server dependencies are present:
- `spring-boot-starter-oauth2-authorization-server`
- `spring-security-oauth2-authorization-server`

### 3. Configuration Order
The `applyDefaultSecurity` might need to be called before other configurations, or the explicit `authorizeHttpRequests` might be conflicting.

### 4. CSRF Configuration
OAuth2 endpoints might need CSRF disabled explicitly in the authorization server filter chain.

## Investigation Steps

### Step 1: Check Startup Logs
```powershell
docker logs kado24-auth-service | Select-String -Pattern "OAuth2|Authorization|FilterChain|Order"
```

Look for:
- Filter chain registration order
- OAuth2 Authorization Server initialization
- Any errors during startup

### Step 2: Verify Dependencies
```powershell
Get-Content backend\services\auth-service\pom.xml | Select-String -Pattern "oauth2-authorization-server"
```

### Step 3: Test Direct Access
```powershell
# Test if endpoint exists at all
Invoke-WebRequest -Uri "http://localhost:8081/oauth2/token" -Method OPTIONS
```

### Step 4: Check Spring Security Debug
Enable debug logging for Spring Security:
```yaml
logging:
  level:
    org.springframework.security: DEBUG
    org.springframework.security.oauth2: DEBUG
```

## Potential Solutions

### Solution 1: Explicit CSRF Disable
Add CSRF disable to OAuth2AuthorizationServerConfig:
```java
http.csrf(AbstractHttpConfigurer::disable)
```

### Solution 2: Remove Explicit authorizeHttpRequests
The `applyDefaultSecurity` should handle authorization. Remove explicit `authorizeHttpRequests` from OAuth2AuthorizationServerConfig.

### Solution 3: Check AuthorizationServerSettings
Verify the issuer URL matches the service URL:
```java
.issuer("http://localhost:8081")  // Should match actual service URL
```

### Solution 4: Verify Request Matchers
Ensure OAuth2AuthorizationServerConfig uses correct request matchers. The default should work, but we might need:
```java
.requestMatchers("/oauth2/**", "/.well-known/**")
```

## Test Results

**Current Test Status**:
- ✅ 10 tests passing
- ❌ 5 tests failing (OAuth2-related)
- ⏭️ 1 test skipped

**Blocking Issues**:
- OAuth2 token generation (blocks most protected endpoint tests)
- OIDC discovery (blocks OIDC-related tests)

## Next Actions

1. **Enable Debug Logging**: Add Spring Security debug logging to see filter chain matching
2. **Review Spring Security Documentation**: Check OAuth2 Authorization Server configuration examples
3. **Test with Minimal Configuration**: Try a minimal OAuth2AuthorizationServerConfig to isolate the issue
4. **Check Spring Boot Version**: Verify compatibility between Spring Boot and OAuth2 Authorization Server versions

## Files Modified

1. `backend/services/auth-service/src/main/java/com/kado24/auth/config/OAuth2AuthorizationServerConfig.java`
   - Added explicit `authorizeHttpRequests` (then removed - didn't help)
   
2. `backend/services/auth-service/src/main/java/com/kado24/auth/config/SecurityConfiguration.java`
   - Changed `@Order(HIGHEST_PRECEDENCE)` to `@Order(2)`

## Notes

- The JWKS endpoint works, which suggests OAuth2 Authorization Server is partially configured
- The token endpoint fails, which suggests the token endpoint specifically isn't being registered
- This might be a Spring Security OAuth2 Authorization Server version or configuration issue

