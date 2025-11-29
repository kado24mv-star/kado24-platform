package com.kado24.auth.service;

import com.kado24.auth.dto.*;
import com.kado24.auth.entity.User;
import com.kado24.auth.entity.VerificationRequest;
import com.kado24.auth.mapper.UserMapper;
import com.kado24.auth.repository.UserRepository;
import com.kado24.auth.repository.VerificationRequestRepository;
import com.kado24.common.exception.ConflictException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.common.exception.UnauthorizedException;
import com.kado24.common.exception.ValidationException;
import com.kado24.common.util.PhoneNumberUtil;
import com.kado24.common.util.StringUtil;
import com.kado24.kafka.event.AnalyticsEvent;
import com.kado24.kafka.event.AuditEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.security.service.TokenBlacklistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Authentication Service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final OAuth2TokenService oauth2TokenService;
    private final TokenBlacklistService tokenBlacklistService;
    private final OtpService otpService;
    private final EventPublisher eventPublisher;
    private final UserMapper userMapper;
    private final VerificationRequestService verificationRequestService;
    private final VerificationRequestRepository verificationRequestRepository;


    /**
     * Register new user
     */
    @Transactional
    public TokenResponse register(RegisterRequest request) {
        log.info("Processing registration for phone: {}", request.getPhoneNumber());

        // Check if phone number already exists with the same role
        // Allow same phone number for different roles (e.g., CONSUMER and MERCHANT)
        if (userRepository.existsByPhoneNumberAndRole(request.getPhoneNumber(), request.getRole())) {
            throw new ConflictException("Phone number already registered with this role. Please try logging in instead.");
        }

        // Check if email already exists with the same role (if provided)
        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
            if (userRepository.existsByEmailAndRole(request.getEmail(), request.getRole())) {
                throw new ConflictException("Email already registered with this role. Please try logging in instead.");
            }
        }

        // Create user entity with PENDING_VERIFICATION status
        // User will be activated after OTP verification
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
        
        // Flush to ensure user is persisted in database before creating verification request
        // This prevents foreign key constraint violation
        userRepository.flush();
        
        log.info("User registered successfully with ID: {}, sending OTP for verification", user.getId());

        // Generate and send OTP
        OtpRequest otpRequest = OtpRequest.builder()
                .phoneNumber(request.getPhoneNumber())
                .purpose("REGISTRATION")
                .build();
        OtpResponse otpResponse = sendOtp(otpRequest);
        
        // Store OTP in database for admin support (Option 3)
        if (otpResponse.getOtpCode() != null) {
            try {
                log.info("Attempting to store OTP in database for user ID: {}, phone: {}, OTP: {}", 
                        user.getId(), request.getPhoneNumber(), otpResponse.getOtpCode());
                VerificationRequest verificationRequest = verificationRequestService.createVerificationRequest(
                        user.getId(),
                        request.getPhoneNumber(),
                        otpResponse.getOtpCode()
                );
                log.info("OTP stored successfully in database. Verification request ID: {}", verificationRequest.getId());
            } catch (Exception e) {
                log.error("Failed to store OTP in database for user ID: {}, phone: {}. Error: {}", 
                        user.getId(), request.getPhoneNumber(), e.getMessage(), e);
                // Don't fail registration if OTP storage fails - OTP is still in Redis
                // But log the error for investigation
            }
        } else {
            log.warn("OTP code is null in response, cannot store in database for user ID: {}, phone: {}", 
                    user.getId(), request.getPhoneNumber());
        }
        
        log.info("OTP sent to phone: {} for registration", request.getPhoneNumber());

        // Publish analytics event
        publishUserRegisteredEvent(user);

        // Don't return tokens - user needs to verify OTP first
        // Return user info without tokens
        return TokenResponse.builder()
                .accessToken(null) // No token until OTP is verified
                .refreshToken(null)
                .tokenType("Bearer")
                .expiresIn(0L)
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * User login
     */
    @Transactional
    public TokenResponse login(LoginRequest request) {
        log.info("Processing login for: {}", request.getIdentifier());

        // Normalize identifier if it's a phone number
        String identifier = request.getIdentifier();
        if (PhoneNumberUtil.isValid(identifier)) {
            identifier = PhoneNumberUtil.normalize(identifier);
            log.debug("Normalized phone number: {}", identifier);
        }

        // Find user by phone or email
        User user = userRepository.findByPhoneNumberOrEmail(identifier)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with provided credentials"));

        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            log.warn("Invalid password attempt for: {}", request.getIdentifier());
            throw new UnauthorizedException("Invalid credentials");
        }

        // Check if user needs OTP verification (PENDING_VERIFICATION status)
        // For consumers, allow self-verification via OTP (no admin required)
        if (user.getStatus() == User.UserStatus.PENDING_VERIFICATION) {
            log.info("User {} needs OTP verification for self-verification, sending OTP", user.getPhoneNumber());
            
            // Send OTP for verification
            OtpRequest otpRequest = OtpRequest.builder()
                    .phoneNumber(user.getPhoneNumber())
                    .purpose("LOGIN_VERIFICATION")
                    .build();
            OtpResponse otpResponse = sendOtp(otpRequest);
            
            // Store OTP in database for admin support (optional)
            log.info("Checking OTP response - OTP code is null: {}, response: {}", 
                    otpResponse.getOtpCode() == null, otpResponse);
            if (otpResponse.getOtpCode() != null) {
                log.info("OTP code received: {}, storing in database for user {}", 
                        otpResponse.getOtpCode(), user.getId());
                // Check if there's an existing pending verification request
                Optional<VerificationRequest> existing = verificationRequestService.getByUserId(user.getId());
                if (existing.isEmpty() || existing.get().getStatus() != VerificationRequest.VerificationStatus.PENDING) {
                    VerificationRequest created = verificationRequestService.createVerificationRequest(
                            user.getId(),
                            user.getPhoneNumber(),
                            otpResponse.getOtpCode()
                    );
                    log.info("Created verification request with ID: {} for user {}", created.getId(), user.getId());
                } else {
                    // Update existing request with new OTP - invalidate old and create new
                    VerificationRequest existingReq = existing.get();
                    existingReq.setStatus(VerificationRequest.VerificationStatus.EXPIRED);
                    verificationRequestRepository.save(existingReq);
                    // Create new verification request with updated OTP
                    VerificationRequest created = verificationRequestService.createVerificationRequest(
                            user.getId(),
                            user.getPhoneNumber(),
                            otpResponse.getOtpCode()
                    );
                    log.info("Updated verification request, created new one with ID: {} for user {}", 
                            created.getId(), user.getId());
                }
            } else {
                log.warn("OTP code is null in response, cannot store in database for user {}", user.getId());
            }
            
            // Throw special exception to indicate OTP verification is required
            // Frontend will catch this and navigate to OTP screen
            throw new UnauthorizedException("OTP_VERIFICATION_REQUIRED: Account pending verification. OTP sent to " + 
                    StringUtil.maskPhoneNumber(user.getPhoneNumber()));
        }

        // Check if user is active (other statuses like SUSPENDED, DELETED)
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new UnauthorizedException("Account is not active. Status: " + user.getStatus());
        }

        // Update last login time
        user.updateLastLogin();
        userRepository.save(user);

        log.info("User logged in successfully: {} (ID: {})", user.getPhoneNumber(), user.getId());

        // Publish analytics event
        publishUserLoginEvent(user);

        // Generate OAuth2 tokens
        OAuth2TokenService.TokenPair tokenPair = oauth2TokenService.generateTokens(user, "kado24-frontend");

        return TokenResponse.builder()
                .accessToken(tokenPair.getAccessToken())
                .refreshToken(tokenPair.getRefreshToken())
                .tokenType("Bearer")
                .expiresIn(tokenPair.getExpiresIn())
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * Refresh access token using OAuth2 refresh token grant
     */
    public TokenResponse refreshToken(String refreshToken) {
        log.info("Processing OAuth2 token refresh");

        // For OAuth2, refresh should be handled via /oauth2/token endpoint
        // This is a simplified version - in production, call the OAuth2 token endpoint
        // For now, we'll validate and generate new tokens
        // TODO: Implement proper OAuth2 refresh token flow via token endpoint
        
        throw new UnauthorizedException("Please use /oauth2/token endpoint with grant_type=refresh_token to refresh tokens");
    }

    /**
     * Logout user - revoke OAuth2 token
     */
    public void logout(String token) {
        log.info("Processing OAuth2 logout");

        // For OAuth2, token revocation should be handled via /oauth2/revoke endpoint
        // This is a simplified version - in production, call the OAuth2 revoke endpoint
        // For now, we'll add to blacklist
        tokenBlacklistService.blacklistToken(token, System.currentTimeMillis() + 86400000);
        log.info("OAuth2 token revoked successfully");
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

        // Build response (include OTP code for development/admin support)
        // Always include OTP code so it can be stored in database for admin support
        OtpResponse response = OtpResponse.builder()
                .message("OTP sent successfully")
                .phoneNumber(StringUtil.maskPhoneNumber(request.getPhoneNumber()))
                .expiresIn(300) // 5 minutes
                .otpCode(otp) // Always include OTP code for admin support
                .build();

        log.info("OTP generated: {} for phone: {}, included in response: {}", 
                otp, request.getPhoneNumber(), response.getOtpCode() != null);

        return response;
    }

    /**
     * Verify OTP and login user
     */
    @Transactional
    public TokenResponse verifyOtp(VerifyOtpRequest request) {
        log.info("Verifying OTP for phone: {}, purpose: {}", request.getPhoneNumber(), request.getPurpose());

        // Determine OTP purpose (default to LOGIN if not provided)
        String purpose = (request.getPurpose() != null && !request.getPurpose().isEmpty()) 
                ? request.getPurpose() 
                : "LOGIN";

        // Verify OTP
        boolean isValid = otpService.verifyOtp(
                request.getPhoneNumber(),
                request.getOtpCode(),
                purpose
        );

        if (!isValid) {
            throw new ValidationException("Invalid OTP code");
        }

        // Find user
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Mark phone as verified and activate account if pending verification
        user.verifyPhone();
        user.updateLastLogin();
        userRepository.save(user);

        log.info("OTP verified successfully for phone: {}, user activated: {}", 
                request.getPhoneNumber(), user.getStatus() == User.UserStatus.ACTIVE);

        // Generate OAuth2 tokens
        OAuth2TokenService.TokenPair tokenPair = oauth2TokenService.generateTokens(user, "kado24-frontend");

        return TokenResponse.builder()
                .accessToken(tokenPair.getAccessToken())
                .refreshToken(tokenPair.getRefreshToken())
                .tokenType("Bearer")
                .expiresIn(tokenPair.getExpiresIn())
                .user(userMapper.toDTO(user))
                .build();
    }

    /**
     * Initiate password reset
     */
    public void forgotPassword(ForgotPasswordRequest request) {
        log.info("Processing forgot password for: {}", request.getIdentifier());

        // Normalize identifier if it's a phone number
        String identifier = request.getIdentifier();
        if (PhoneNumberUtil.isValid(identifier)) {
            identifier = PhoneNumberUtil.normalize(identifier);
            log.debug("Normalized phone number: {}", identifier);
        }

        // Find user
        User user = userRepository.findByPhoneNumberOrEmail(identifier)
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



























