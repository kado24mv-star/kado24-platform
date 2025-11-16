package com.kado24.auth.service;

import com.kado24.common.exception.ValidationException;
import com.kado24.common.util.StringUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * Service for OTP generation and verification
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private final RedisTemplate<String, String> redisTemplate;

    @Value("${otp.expiration:300}") // 5 minutes in seconds
    private int otpExpirationSeconds;

    @Value("${otp.length:6}")
    private int otpLength;

    private static final String OTP_PREFIX = "otp:";
    private static final String OTP_ATTEMPTS_PREFIX = "otp:attempts:";
    private static final int MAX_ATTEMPTS = 5;

    /**
     * Generate OTP for phone number
     */
    public String generateOtp(String phoneNumber, String purpose) {
        // Generate random 6-digit OTP
        String otp = StringUtil.generateRandomNumeric(otpLength);
        
        // Store in Redis with expiration
        String key = OTP_PREFIX + phoneNumber + ":" + purpose;
        redisTemplate.opsForValue().set(key, otp, otpExpirationSeconds, TimeUnit.SECONDS);
        
        // Reset attempts counter
        String attemptsKey = OTP_ATTEMPTS_PREFIX + phoneNumber + ":" + purpose;
        redisTemplate.delete(attemptsKey);
        
        log.info("OTP generated for phone: {} (purpose: {})", phoneNumber, purpose);
        
        return otp;
    }

    /**
     * Verify OTP
     */
    public boolean verifyOtp(String phoneNumber, String otpCode, String purpose) {
        String key = OTP_PREFIX + phoneNumber + ":" + purpose;
        String attemptsKey = OTP_ATTEMPTS_PREFIX + phoneNumber + ":" + purpose;
        
        // Check attempts
        Integer attempts = incrementAttempts(attemptsKey);
        if (attempts > MAX_ATTEMPTS) {
            log.warn("Too many OTP attempts for phone: {}", phoneNumber);
            throw new ValidationException("Too many failed attempts. Please request a new OTP.");
        }
        
        // Get stored OTP
        String storedOtp = redisTemplate.opsForValue().get(key);
        
        if (storedOtp == null) {
            log.warn("OTP not found or expired for phone: {}", phoneNumber);
            throw new ValidationException("OTP has expired. Please request a new one.");
        }
        
        // Verify OTP
        if (storedOtp.equals(otpCode)) {
            // OTP is valid - delete it so it can't be reused
            redisTemplate.delete(key);
            redisTemplate.delete(attemptsKey);
            log.info("OTP verified successfully for phone: {}", phoneNumber);
            return true;
        } else {
            log.warn("Invalid OTP provided for phone: {}", phoneNumber);
            throw new ValidationException("Invalid OTP code. Please try again.");
        }
    }

    /**
     * Check if OTP exists for phone number
     */
    public boolean otpExists(String phoneNumber, String purpose) {
        String key = OTP_PREFIX + phoneNumber + ":" + purpose;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    /**
     * Get remaining OTP expiration time in seconds
     */
    public long getOtpExpirationTime(String phoneNumber, String purpose) {
        String key = OTP_PREFIX + phoneNumber + ":" + purpose;
        Long ttl = redisTemplate.getExpire(key, TimeUnit.SECONDS);
        return ttl != null ? ttl : 0;
    }

    /**
     * Increment and get OTP verification attempts
     */
    private Integer incrementAttempts(String attemptsKey) {
        Long attempts = redisTemplate.opsForValue().increment(attemptsKey);
        if (attempts != null && attempts == 1) {
            // Set expiration on first attempt
            redisTemplate.expire(attemptsKey, otpExpirationSeconds, TimeUnit.SECONDS);
        }
        return attempts != null ? attempts.intValue() : 0;
    }

    /**
     * Clear OTP for phone number
     */
    public void clearOtp(String phoneNumber, String purpose) {
        String key = OTP_PREFIX + phoneNumber + ":" + purpose;
        redisTemplate.delete(key);
    }
}



















