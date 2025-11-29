package com.kado24.voucher.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filter to extract userId from JWT token and set it as request attribute
 * This runs after OAuth2 Resource Server validation
 */
@Slf4j
@Component
public class JwtUserIdExtractorFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            
            log.debug("JwtUserIdExtractorFilter: Authentication type: {}, authenticated: {}", 
                    authentication != null ? authentication.getClass().getSimpleName() : "null",
                    authentication != null && authentication.isAuthenticated());
            
            if (authentication instanceof JwtAuthenticationToken) {
                JwtAuthenticationToken jwtAuth = (JwtAuthenticationToken) authentication;
                Jwt jwt = jwtAuth.getToken();
                
                log.debug("JwtUserIdExtractorFilter: JWT token found. Available claims: {}", jwt.getClaims().keySet());
                
                // Extract userId from JWT claims
                Object userIdObj = jwt.getClaim("userId");
                
                if (userIdObj != null) {
                    Long userId;
                    if (userIdObj instanceof Long) {
                        userId = (Long) userIdObj;
                    } else if (userIdObj instanceof Integer) {
                        userId = ((Integer) userIdObj).longValue();
                    } else if (userIdObj instanceof String) {
                        userId = Long.parseLong((String) userIdObj);
                    } else {
                        log.warn("Unexpected userId type in JWT: {}. Value: {}", userIdObj.getClass(), userIdObj);
                        userId = null;
                    }
                    
                    if (userId != null) {
                        request.setAttribute("userId", userId);
                        log.info("JwtUserIdExtractorFilter: Extracted userId {} from JWT token for request: {}", 
                                userId, request.getRequestURI());
                    } else {
                        log.warn("JwtUserIdExtractorFilter: Could not extract userId from JWT token. Claim value: {}, type: {}", 
                                userIdObj, userIdObj != null ? userIdObj.getClass() : "null");
                    }
                } else {
                    log.warn("JwtUserIdExtractorFilter: JWT token missing userId claim. Available claims: {}", 
                            jwt.getClaims().keySet());
                    log.warn("JwtUserIdExtractorFilter: All claims: {}", jwt.getClaims());
                }
            } else {
                log.warn("JwtUserIdExtractorFilter: Authentication is not JwtAuthenticationToken. Type: {}", 
                        authentication != null ? authentication.getClass().getName() : "null");
            }
        } catch (Exception ex) {
            log.error("JwtUserIdExtractorFilter: Error extracting userId from JWT token", ex);
        }
        
        filterChain.doFilter(request, response);
    }
}

