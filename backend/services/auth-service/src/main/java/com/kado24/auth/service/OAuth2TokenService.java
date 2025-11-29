package com.kado24.auth.service;

import com.kado24.auth.entity.User;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.RSASSASigner;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2RefreshToken;
import org.springframework.security.oauth2.server.authorization.OAuth2Authorization;
import org.springframework.security.oauth2.server.authorization.OAuth2AuthorizationService;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

/**
 * Service for generating OAuth2 tokens
 * Generates OAuth2-compliant JWT tokens directly
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OAuth2TokenService {

    private final RegisteredClientRepository clientRepository;
    private final OAuth2AuthorizationService authorizationService;
    private final JWKSource<SecurityContext> jwkSource;

    @Value("${spring.security.oauth2.authorizationserver.issuer:http://localhost:8081}")
    private String issuer;

    /**
     * Generate OAuth2 access and refresh tokens for a user
     */
    public TokenPair generateTokens(User user, String clientId) {
        log.debug("Generating OAuth2 tokens for user: {} with client: {}", user.getPhoneNumber(), clientId);

        RegisteredClient registeredClient = clientRepository.findByClientId(clientId);
        if (registeredClient == null) {
            throw new IllegalArgumentException("Client not found: " + clientId);
        }

        try {
            // Get RSA key from JWK source
            RSAKey rsaKey = getRSAKey();

            // Generate access token (JWT)
            Instant now = Instant.now();
            Instant expiresAt = now.plus(24, ChronoUnit.HOURS);

            JWTClaimsSet accessTokenClaims = new JWTClaimsSet.Builder()
                    .issuer(issuer)
                    .subject(user.getPhoneNumber())
                    .audience(clientId)
                    .issueTime(Date.from(now))
                    .expirationTime(Date.from(expiresAt))
                    .claim("userId", user.getId())
                    .claim("roles", user.getRole().name())
                    .claim("scope", "read write openid profile")
                    .jwtID(UUID.randomUUID().toString())
                    .build();

            SignedJWT accessTokenJWT = new SignedJWT(
                    new JWSHeader.Builder(JWSAlgorithm.RS256).keyID(rsaKey.getKeyID()).build(),
                    accessTokenClaims
            );
            accessTokenJWT.sign(new RSASSASigner(rsaKey.toRSAPrivateKey()));

            String accessTokenValue = accessTokenJWT.serialize();

            // Generate refresh token (opaque token)
            String refreshTokenValue = UUID.randomUUID().toString();

            // Create OAuth2 tokens
            OAuth2AccessToken accessToken = new OAuth2AccessToken(
                    OAuth2AccessToken.TokenType.BEARER,
                    accessTokenValue,
                    now,
                    expiresAt
            );

            Instant refreshExpiresAt = now.plus(7, ChronoUnit.DAYS);
            OAuth2RefreshToken refreshToken = new OAuth2RefreshToken(
                    refreshTokenValue,
                    now,
                    refreshExpiresAt
            );

            // Save authorization
            OAuth2Authorization authorization = OAuth2Authorization.withRegisteredClient(registeredClient)
                    .id(UUID.randomUUID().toString())
                    .principalName(user.getPhoneNumber())
                    .authorizationGrantType(org.springframework.security.oauth2.core.AuthorizationGrantType.AUTHORIZATION_CODE)
                    .token(accessToken)
                    .token(refreshToken)
                    .attribute("userId", user.getId())
                    .attribute("role", user.getRole().name())
                    .build();

            authorizationService.save(authorization);

            log.debug("Generated OAuth2 tokens for user: {}", user.getPhoneNumber());

            return new TokenPair(
                    accessTokenValue,
                    refreshTokenValue,
                    ChronoUnit.SECONDS.between(now, expiresAt)
            );
        } catch (Exception e) {
            log.error("Error generating OAuth2 tokens: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate OAuth2 tokens", e);
        }
    }

    /**
     * Get RSA key from JWK source
     */
    private RSAKey getRSAKey() throws JOSEException {
        try {
            JWKSet jwkSet = ((ImmutableJWKSet<SecurityContext>) jwkSource).getJWKSet();
            return jwkSet.getKeys().stream()
                    .filter(key -> key instanceof RSAKey)
                    .map(key -> (RSAKey) key)
                    .findFirst()
                    .orElseThrow(() -> new IllegalStateException("No RSA key found in JWK set"));
        } catch (Exception e) {
            throw new JOSEException("Failed to get RSA key", e);
        }
    }

    /**
     * Token pair DTO
     */
    public static class TokenPair {
        private final String accessToken;
        private final String refreshToken;
        private final Long expiresIn;

        public TokenPair(String accessToken, String refreshToken, Long expiresIn) {
            this.accessToken = accessToken;
            this.refreshToken = refreshToken;
            this.expiresIn = expiresIn;
        }

        public String getAccessToken() {
            return accessToken;
        }

        public String getRefreshToken() {
            return refreshToken;
        }

        public Long getExpiresIn() {
            return expiresIn;
        }
    }
}
