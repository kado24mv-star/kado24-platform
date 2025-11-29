package com.kado24.payout.config;

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

/**
 * OAuth2 Resource Server Configuration for Payout Service
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfiguration {

	@Bean
	public SecurityFilterChain payoutSecurityFilterChain(HttpSecurity http) throws Exception {
		http
				.csrf(AbstractHttpConfigurer::disable)
				.cors(cors -> cors.configurationSource(payoutCorsConfigurationSource()))
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.oauth2ResourceServer(oauth2 -> oauth2
						.jwt(jwt -> jwt
								.jwkSetUri("http://localhost:8081/oauth2/jwks")
						)
				)
				.authorizeHttpRequests(auth -> auth
						.requestMatchers("/api/v1/payouts/internal/**").permitAll()
						.requestMatchers("/api/v1/payouts/simulate").permitAll()
						.requestMatchers("/actuator/**", "/swagger-ui/**", "/v3/api-docs/**", "/health").permitAll()
						.anyRequest().authenticated()
				);

		return http.build();
	}

	@Bean(name = "payoutCorsConfigurationSource")
	public CorsConfigurationSource payoutCorsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		// Explicitly allow frontend origins
		configuration.setAllowedOrigins(Arrays.asList(
				"http://localhost:8002",  // Consumer app
				"http://localhost:8001",  // Merchant app
				"http://localhost:4200"   // Admin portal
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

