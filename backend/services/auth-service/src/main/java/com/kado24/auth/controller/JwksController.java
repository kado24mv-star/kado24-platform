package com.kado24.auth.controller;

import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * JWKS (JSON Web Key Set) Controller
 * Exposes the public keys for JWT token validation
 */
@Slf4j
@RestController
@RequestMapping("/oauth2")
@RequiredArgsConstructor
public class JwksController {

    private final JWKSource<SecurityContext> jwkSource;

    @GetMapping(value = "/jwks", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> getJwks() {
        try {
            log.debug("JWKS endpoint accessed");
            
            // Get JWK set from the source
            JWKSet jwkSet = ((ImmutableJWKSet<SecurityContext>) jwkSource).getJWKSet();
            
            // Convert to Map for JSON response
            Map<String, Object> jwksMap = jwkSet.toJSONObject();
            
            log.debug("JWKS returned successfully with {} keys", jwkSet.getKeys().size());
            
            return ResponseEntity.ok(jwksMap);
        } catch (Exception e) {
            log.error("Error generating JWKS", e);
            throw new RuntimeException("Failed to generate JWKS", e);
        }
    }
}

