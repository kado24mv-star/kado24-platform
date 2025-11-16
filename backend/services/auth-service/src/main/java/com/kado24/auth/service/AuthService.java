package com.kado24.auth.service;

import com.kado24.auth.dto.*;
import com.kado24.auth.entity.User;
import com.kado24.auth.mapper.UserMapper;
import com.kado24.auth.repository.UserRepository;
import com.kado24.common.exception.ConflictException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.common.exception.UnauthorizedException;
import com.kado24.common.exception.ValidationException;
import com.kado24.common.util.StringUtil;
import com.kado24.kafka.event.AnalyticsEvent;
import com.kado24.kafka.event.AuditEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.security.jwt.JwtTokenProvider;
import com.kado24.security.service.TokenBlacklistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

/**
 * Authentication Service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final TokenBlacklistService tokenBlacklistService;
    private final OtpService otpService;
    private final EventPublisher eventPublisher;
    private final UserMapper userMapper;

    @Value("${jwt.expiration:86400000}")
    private long jwtExpirationMs;

    /**
     * Register new user
     */
    @Transactional
    public TokenResponse register(RegisterRequest request) {
        log.info("Processing registration for phone: {}", request.getPhoneNumber());

        // Check if phone number already exists
        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new ConflictException("Phone number already registered");
        }

        // Check if email already exists (if provided)
        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new ConflictException("Email already registered");
            }
        }

        // Create user entity
        User user = User.builder()
                .fullName(request.getFullName())
                .phoneNumber(request.getPhoneNumber())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .status(User.UserStatus.PENDING_VERIFICATION)
                .emailVerified(false)
                .phoneVerified(false)
                .build();

        // Save to database
        user = userRepository.save(user);
        
        log.info("User registered successfully with ID: {}", user.getId());

        // Publish analytics event
        publishUserRegisteredEvent(user);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getPhoneNumber(),
                user.getRole().name(),
                user.getId()
        );
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getPhoneNumber());

        // Build response
        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtExpirationMs / 1000) // Convert to seconds
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * User login
     */
    @Transactional
    public TokenResponse login(LoginRequest request) {
        log.info("Processing login for: {}", request.getIdentifier());

        // Find user by phone or email
        User user = userRepository.findByPhoneNumberOrEmail(request.getIdentifier())
                .orElseThrow(() -> new ResourceNotFoundException("User not found with provided credentials"));

        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            log.warn("Invalid password attempt for: {}", request.getIdentifier());
            throw new UnauthorizedException("Invalid credentials");
        }

        // Check if user is active
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new UnauthorizedException("Account is not active. Status: " + user.getStatus());
        }

        // Update last login time
        user.updateLastLogin();
        userRepository.save(user);

        log.info("User logged in successfully: {} (ID: {})", user.getPhoneNumber(), user.getId());

        // Publish analytics event
        publishUserLoginEvent(user);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getPhoneNumber(),
                user.getRole().name(),
                user.getId()
        );
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getPhoneNumber());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtExpirationMs / 1000)
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * Refresh access token
     */
    public TokenResponse refreshToken(String refreshToken) {
        log.info("Processing token refresh");

        // Validate refresh token
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new UnauthorizedException("Invalid or expired refresh token");
        }

        // Check if token is blacklisted
        if (tokenBlacklistService.isTokenBlacklisted(refreshToken)) {
            throw new UnauthorizedException("Token has been revoked");
        }

        // Get username from token
        String username = jwtTokenProvider.getUsernameFromToken(refreshToken);

        // Find user
        User user = userRepository.findByPhoneNumberOrEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Generate new access token
        String newAccessToken = jwtTokenProvider.generateAccessToken(
                user.getPhoneNumber(),
                user.getRole().name(),
                user.getId()
        );

        log.info("Access token refreshed for user: {}", username);

        return TokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken) // Same refresh token
                .tokenType("Bearer")
                .expiresIn(jwtExpirationMs / 1000)
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * Logout user
     */
    public void logout(String token) {
        log.info("Processing logout");

        // Add token to blacklist
        if (jwtTokenProvider.validateToken(token)) {
            long expirationTime = jwtTokenProvider.getExpirationDateFromToken(token).getTime();
            tokenBlacklistService.blacklistToken(token, expirationTime);
            log.info("User logged out successfully");
        }
    }

    /**
     * Send OTP to phone number
     */
    public OtpResponse sendOtp(OtpRequest request) {
        log.info("Generating OTP for phone: {} (purpose: {})", 
                request.getPhoneNumber(), request.getPurpose());

        // Generate OTP
        String otp = otpService.generateOtp(request.getPhoneNumber(), request.getPurpose());

        // In production, send SMS here
        // smsService.sendOtp(request.getPhoneNumber(), otp);
        
        log.info("OTP sent successfully to: {}", request.getPhoneNumber());

        // Build response
        OtpResponse response = OtpResponse.builder()
                .message("OTP sent successfully")
                .phoneNumber(StringUtil.maskPhoneNumber(request.getPhoneNumber()))
                .expiresIn(300) // 5 minutes
                .build();

        // In development mode, include OTP in response
        if (isDevelopmentMode()) {
            response.setOtpCode(otp);
            log.debug("DEV MODE: OTP code is {}", otp);
        }

        return response;
    }

    /**
     * Verify OTP and login user
     */
    @Transactional
    public TokenResponse verifyOtp(VerifyOtpRequest request) {
        log.info("Verifying OTP for phone: {}", request.getPhoneNumber());

        // Verify OTP
        boolean isValid = otpService.verifyOtp(
                request.getPhoneNumber(),
                request.getOtpCode(),
                "LOGIN"
        );

        if (!isValid) {
            throw new ValidationException("Invalid OTP code");
        }

        // Find or create user
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Mark phone as verified
        user.verifyPhone();
        user.updateLastLogin();
        userRepository.save(user);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getPhoneNumber(),
                user.getRole().name(),
                user.getId()
        );
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getPhoneNumber());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtExpirationMs / 1000)
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * Initiate password reset
     */
    public void forgotPassword(ForgotPasswordRequest request) {
        log.info("Processing forgot password for: {}", request.getIdentifier());

        // Find user
        User user = userRepository.findByPhoneNumberOrEmail(request.getIdentifier())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Generate and send OTP
        String otp = otpService.generateOtp(user.getPhoneNumber(), "PASSWORD_RESET");

        // In production, send SMS
        // smsService.sendPasswordResetOtp(user.getPhoneNumber(), otp);

        log.info("Password reset OTP sent to: {}", StringUtil.maskPhoneNumber(user.getPhoneNumber()));
    }

    /**
     * Reset password with OTP
     */
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        log.info("Processing password reset for: {}", request.getPhoneNumber());

        // Verify OTP
        otpService.verifyOtp(request.getPhoneNumber(), request.getOtpCode(), "PASSWORD_RESET");

        // Find user
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Publish audit event
        publishPasswordResetEvent(user);

        log.info("Password reset successfully for user: {}", user.getId());
    }

    /**
     * Check if running in development mode
     */
    private boolean isDevelopmentMode() {
        String profile = System.getProperty("spring.profiles.active", "");
        return profile.contains("dev") || profile.contains("local");
    }

    /**
     * Publish user registered analytics event
     */
    private void publishUserRegisteredEvent(User user) {
        try {
            AnalyticsEvent event = AnalyticsEvent.builder()
                    .userId(user.getId())
                    .action("REGISTER")
                    .category("USER")
                    .build();
            event.initDefaults(AnalyticsEvent.USER_REGISTERED, "auth-service");
            eventPublisher.publishAnalyticsEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish user registered event", e);
        }
    }

    /**
     * Publish user login analytics event
     */
    private void publishUserLoginEvent(User user) {
        try {
            AnalyticsEvent event = AnalyticsEvent.builder()
                    .userId(user.getId())
                    .action("LOGIN")
                    .category("USER")
                    .build();
            event.initDefaults(AnalyticsEvent.USER_LOGIN, "auth-service");
            eventPublisher.publishAnalyticsEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish user login event", e);
        }
    }

    /**
     * Publish password reset audit event
     */
    private void publishPasswordResetEvent(User user) {
        try {
            Map<String, Object> context = new HashMap<>();
            context.put("action", "password_reset");
            context.put("method", "OTP");
            
            AuditEvent event = AuditEvent.builder()
                    .userId(user.getId())
                    .action("UPDATE")
                    .entityType("USER")
                    .entityId(user.getId())
                    .context(context)
                    .build();
            event.initDefaults("UPDATE", "auth-service");
            eventPublisher.publishAuditEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish password reset event", e);
        }
    }
}



















