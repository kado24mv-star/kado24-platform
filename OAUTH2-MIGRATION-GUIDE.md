# OAuth2 Migration Guide

## Overview
This document describes the migration from JWT to OAuth2 authentication in the Kado24 platform.

## Completed Changes

### 1. Auth Service (OAuth2 Authorization Server)
- ✅ Added OAuth2 Authorization Server configuration
- ✅ Created OAuth2TokenService for token generation
- ✅ Updated AuthService to use OAuth2 tokens
- ✅ Configured OAuth2 endpoints: `/oauth2/authorize`, `/oauth2/token`, `/oauth2/jwks`, etc.
- ✅ Registered OAuth2 clients (frontend and backend)

### 2. User Service (OAuth2 Resource Server)
- ✅ Added `spring-boot-starter-oauth2-resource-server` dependency
- ✅ Created OAuth2ResourceServerConfig
- ✅ Updated application.yml with OAuth2 resource server configuration

## Remaining Work

### 3. Other Backend Services (OAuth2 Resource Server)
Apply the same changes to all other services:
- voucher-service
- order-service
- wallet-service
- redemption-service
- merchant-service
- admin-portal-backend
- notification-service
- payout-service
- analytics-service
- mock-payment-service

**For each service:**

1. **Update pom.xml** - Add OAuth2 Resource Server dependency:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

2. **Create OAuth2ResourceServerConfig.java** in `src/main/java/com/kado24/{service}/config/`:
```java
package com.kado24.{service}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class OAuth2ResourceServerConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt
                                .jwkSetUri("http://localhost:8081/oauth2/jwks")
                        )
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/actuator/**",
                                "/swagger-ui/**",
                                "/v3/api-docs/**",
                                "/api-docs/**",
                                "/health",
                                "/error"
                        ).permitAll()
                        .anyRequest().authenticated()
                );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(
                "http://localhost:*",
                "http://127.0.0.1:*"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setExposedHeaders(Arrays.asList("Authorization", "X-Request-Id"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

3. **Update application.yml** - Replace JWT config with OAuth2:
```yaml
# Remove JWT configuration
# jwt:
#   secret: ...

# Add OAuth2 Resource Server Configuration
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081
          jwk-set-uri: http://localhost:8081/oauth2/jwks
```

4. **Remove JWT filter** - If using JwtAuthenticationFilter, remove it from SecurityFilterChain

### 4. APISIX Configuration
- ⏳ Update routes to use OAuth2 plugin instead of jwt-auth
- ⏳ Configure OAuth2 client credentials in APISIX
- ⏳ Update route configurations

### 5. Frontend Applications
- ⏳ Update to use OAuth2 authorization code flow
- ⏳ Update token storage and refresh logic
- ⏳ Handle OAuth2 token responses

## OAuth2 Endpoints

### Authorization Server (auth-service:8081)
- Authorization: `http://localhost:8081/oauth2/authorize`
- Token: `http://localhost:8081/oauth2/token`
- JWK Set: `http://localhost:8081/oauth2/jwks`
- Token Introspection: `http://localhost:8081/oauth2/introspect`
- Token Revocation: `http://localhost:8081/oauth2/revoke`
- User Info: `http://localhost:8081/userinfo`

### Registered Clients
- **kado24-frontend**: For frontend applications
  - Client ID: `kado24-frontend`
  - Client Secret: `kado24-frontend-secret`
  - Grant Types: authorization_code, refresh_token, client_credentials
  - Redirect URIs: http://localhost:4200/callback, http://localhost:8001/callback, http://localhost:8002/callback

- **kado24-backend**: For service-to-service communication
  - Client ID: `kado24-backend`
  - Client Secret: `kado24-backend-secret`
  - Grant Types: client_credentials

## Testing

1. **Get OAuth2 Token** (using password grant - if configured):
```bash
curl -X POST http://localhost:8081/oauth2/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'kado24-frontend:kado24-frontend-secret' | base64)" \
  -d "grant_type=password&username=USERNAME&password=PASSWORD&scope=read write"
```

2. **Use Token**:
```bash
curl -X GET http://localhost:8082/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

3. **Refresh Token**:
```bash
curl -X POST http://localhost:8081/oauth2/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'kado24-frontend:kado24-frontend-secret' | base64)" \
  -d "grant_type=refresh_token&refresh_token=YOUR_REFRESH_TOKEN"
```

## Notes

- OAuth2 tokens are JWTs signed with RSA keys (not HMAC)
- Token validation is done via JWK Set endpoint
- All resource servers validate tokens against the authorization server
- Frontend apps should use authorization code flow for better security
- Service-to-service communication can use client credentials grant

