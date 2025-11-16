package com.kado24.security.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * Service for managing blacklisted (revoked) tokens using Redis
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenBlacklistService {

    private final RedisTemplate<String, String> redisTemplate;
    
    private static final String BLACKLIST_PREFIX = "blacklist:token:";
    private static final long DEFAULT_EXPIRATION_HOURS = 24;

    /**
     * Add token to blacklist
     */
    public void blacklistToken(String token, long expirationTimeMs) {
        String key = BLACKLIST_PREFIX + token;
        long ttl = Math.max(expirationTimeMs - System.currentTimeMillis(), 0);
        
        if (ttl > 0) {
            redisTemplate.opsForValue().set(key, "revoked", ttl, TimeUnit.MILLISECONDS);
            log.info("Token blacklisted successfully");
        }
    }

    /**
     * Add token to blacklist with default expiration
     */
    public void blacklistToken(String token) {
        String key = BLACKLIST_PREFIX + token;
        redisTemplate.opsForValue().set(key, "revoked", DEFAULT_EXPIRATION_HOURS, TimeUnit.HOURS);
        log.info("Token blacklisted with default expiration");
    }

    /**
     * Check if token is blacklisted
     */
    public boolean isTokenBlacklisted(String token) {
        String key = BLACKLIST_PREFIX + token;
        Boolean exists = redisTemplate.hasKey(key);
        return Boolean.TRUE.equals(exists);
    }

    /**
     * Remove token from blacklist (if needed)
     */
    public void removeFromBlacklist(String token) {
        String key = BLACKLIST_PREFIX + token;
        redisTemplate.delete(key);
        log.info("Token removed from blacklist");
    }
}



















