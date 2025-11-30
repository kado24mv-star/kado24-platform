# OAuth2 Token Endpoint Fix - Final Solution

## Problem
OAuth2 token endpoint (`/oauth2/token`) returns 500 error: "No static resource oauth2/token"

## Root Cause
The request is reaching `DispatcherServlet` and being mapped to `ResourceHttpRequestHandler` (static resources) instead of being processed by `OAuth2TokenEndpointFilter`. This indicates that:
1. The OAuth2 filter chain is not matching the request correctly
2. OR the filter is not processing the request before it reaches DispatcherServlet

## Solution

Based on Spring Security documentation and web search results, the issue is that `applyDefaultSecurity` should automatically configure request matchers, but there might be a conflict with the SecurityConfiguration filter chain.

### Option 1: Ensure OAuth2 Filter Chain Has Explicit Request Matcher (Recommended)

Add an explicit request matcher to ensure the OAuth2 filter chain matches OAuth2 requests:

```java
@Bean
@Order(1)
public SecurityFilterChain authorizationServerSecurityFilterChain(HttpSecurity http) throws Exception {
    // Apply default OAuth2 Authorization Server security
    OAuth2AuthorizationServerConfiguration.applyDefaultSecurity(http);
    
    // Explicitly ensure this filter chain matches OAuth2 endpoints
    // (applyDefaultSecurity should do this, but being explicit helps)
    http.requestMatchers((matchers) -> matchers
            .requestMatchers("/oauth2/**", "/.well-known/**")
    );
    
    // Configure OIDC
    http.getConfigurer(OAuth2AuthorizationServerConfigurer.class)
            .oidc(Customizer.withDefaults());
    
    // Disable CSRF
    http.csrf(AbstractHttpConfigurer::disable);
    
    // Exception handling
    http.exceptionHandling((exceptions) -> exceptions
            .defaultAuthenticationEntryPointFor(
                    new LoginUrlAuthenticationEntryPoint("/login"),
                    new MediaTypeRequestMatcher(MediaType.TEXT_HTML)
            )
    );
    
    // Resource server
    http.oauth2ResourceServer((resourceServer) -> resourceServer
            .jwt(Customizer.withDefaults()));

    return http.build();
}
```

### Option 2: Ensure SecurityConfiguration Doesn't Match OAuth2 Requests

Make sure SecurityConfiguration (Order 2) has a securityMatcher that excludes OAuth2:

```java
@Bean
@Order(2)
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
            .securityMatcher("/api/**", "/actuator/**", "/swagger-ui/**", "/v3/api-docs/**", "/api-docs/**", "/health", "/error")
            // This ensures OAuth2 endpoints are NOT matched by this filter chain
            .csrf(AbstractHttpConfigurer::disable)
            // ... rest of config
}
```

## Current Status

- ✅ OAuth2TokenEndpointFilter is registered in filter chain
- ✅ Filter chain order is correct (Order 1 for OAuth2, Order 2 for main)
- ❌ OAuth2TokenEndpointFilter is not processing requests
- ❌ Request reaches DispatcherServlet instead

## Next Steps

1. Try Option 1: Add explicit request matcher to OAuth2 filter chain
2. If that doesn't work, verify that `applyDefaultSecurity` is correctly configuring request matchers
3. Check Spring Boot 3.2.0 release notes for any OAuth2-related changes
4. Consider testing with a minimal OAuth2 configuration to isolate the issue

## Files to Modify

- `backend/services/auth-service/src/main/java/com/kado24/auth/config/OAuth2AuthorizationServerConfig.java`
  - Add explicit request matcher configuration

- `backend/services/auth-service/src/main/java/com/kado24/auth/config/SecurityConfiguration.java`
  - Ensure securityMatcher excludes OAuth2 endpoints (already done)

## Testing

After applying the fix:
```powershell
$body = "grant_type=client_credentials&client_id=kado24-backend&client_secret=kado24-backend-secret&scope=read write"
Invoke-WebRequest -Uri "http://localhost:8081/oauth2/token" `
  -Method POST `
  -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} `
  -Body $body
```

Expected: 200 OK with access token
Current: 500 Internal Server Error

