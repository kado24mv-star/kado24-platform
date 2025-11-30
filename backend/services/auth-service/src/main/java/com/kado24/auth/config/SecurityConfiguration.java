package com.kado24.auth.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.context.annotation.Primary;
import org.springframework.core.annotation.Order;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.NegatedRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.stream.Collectors;

/**
 * Security configuration for Auth Service
 * All auth endpoints are public except logout
 */
@Slf4j
@Configuration
@EnableMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfiguration {
    
    // NOTE: @EnableWebSecurity is on OAuth2AuthorizationServerConfig only
    // This class just defines an additional SecurityFilterChain bean

    private final JwtDecoder jwtDecoder;
    
    @jakarta.annotation.PostConstruct
    public void init() {
        log.info("SecurityConfiguration initialized with JwtDecoder: {}", jwtDecoder != null ? jwtDecoder.getClass().getName() : "null");
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            // Extract roles from JWT claims
            log.info("=== JWT Authentication Converter Called ===");
            log.info("JWT ID: {}", jwt.getId());
            log.info("JWT Subject: {}", jwt.getSubject());
            log.info("JWT All Claims: {}", jwt.getClaims());
            
            Object rolesClaim = jwt.getClaim("roles");
            log.info("JWT roles claim (raw): {}", rolesClaim);
            log.info("JWT roles claim type: {}", rolesClaim != null ? rolesClaim.getClass() : "null");
            
            if (rolesClaim == null) {
                log.warn("No roles claim found in JWT token");
                return Collections.emptyList();
            }
            
            // Handle both single role (String) and multiple roles (Collection)
            Collection<String> roles;
            if (rolesClaim instanceof String) {
                roles = Collections.singletonList((String) rolesClaim);
            } else if (rolesClaim instanceof Collection) {
                @SuppressWarnings("unchecked")
                Collection<String> rolesCollection = (Collection<String>) rolesClaim;
                roles = rolesCollection;
            } else {
                log.warn("Roles claim is not String or Collection: {}", rolesClaim.getClass());
                return Collections.emptyList();
            }
            
            // Convert roles to authorities
            // hasRole('ADMIN') checks for "ROLE_ADMIN" or "ADMIN"
            Collection<GrantedAuthority> authorities = roles.stream()
                    .map(role -> {
                        // Add ROLE_ prefix if not present
                        String authority = role.startsWith("ROLE_") ? role : "ROLE_" + role;
                        log.debug("Converting role '{}' to authority '{}'", role, authority);
                        return (GrantedAuthority) new SimpleGrantedAuthority(authority);
                    })
                    .collect(Collectors.toList());
            
            log.debug("Final authorities extracted from JWT: {}", authorities);
            return authorities;
        });
        return converter;
    }

    // NOTE: JwtTokenProvider and JwtAuthenticationFilter are excluded from component scanning
    // This prevents the shared filter from being created
    // OAuth2 Resource Server will handle all JWT validation

    /**
     * Security filter chain for API and Actuator endpoints.
     * This filter chain handles all non-OAuth2 requests.
     */
    @Bean(name = "voucherSecurityFilterChain")
    @Order(2)
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/api/**", "/actuator/**", "/swagger-ui/**", "/v3/api-docs/**", "/api-docs/**", "/health", "/error")
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(allowAllCorsConfigurationSource()))
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> {
                            jwt.decoder(jwtDecoder);
                            jwt.jwtAuthenticationConverter(jwtAuthenticationConverter());
                        })
                )
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/v1/auth/register",
                                "/api/v1/auth/login",
                                "/api/v1/auth/send-otp",
                                "/api/v1/auth/verify-otp",
                                "/api/v1/auth/forgot-password",
                                "/api/v1/auth/reset-password",
                                "/api/v1/auth/refresh",
                                "/api/v1/admin-utils/**",
                                "/actuator/**",
                                "/swagger-ui/**",
                                "/v3/api-docs/**",
                                "/api-docs/**",
                                "/health",
                                "/error"
                        ).permitAll()
                        .requestMatchers("/api/v1/auth/logout").authenticated()
                        .anyRequest().authenticated()
                )
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    // Configure CORS to allow frontend origins (APISIX will also handle CORS)
    @Bean
    public CorsConfigurationSource allowAllCorsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // Allow all localhost origins for development (including any port)
        configuration.setAllowedOriginPatterns(Arrays.asList(
                "http://localhost:*",  // Allow all localhost ports for development
                "http://127.0.0.1:*"   // Also allow 127.0.0.1
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






































