package com.kado24.auth.controller;

import com.kado24.auth.dto.*;
import com.kado24.auth.service.AuthService;
import com.kado24.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication REST Controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "User authentication and authorization endpoints")
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Register new user", description = "Create a new user account (consumer or merchant)")
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<TokenResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        
        log.info("Registration request received for phone: {}", request.getPhoneNumber());
        
        TokenResponse response = authService.register(request);
        
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Registration successful", response));
    }

    @Operation(summary = "Login user", description = "Authenticate user with phone/email and password")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<TokenResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        
        log.info("Login request received for: {}", request.getIdentifier());
        
        TokenResponse response = authService.login(request);
        
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }

    @Operation(summary = "Refresh access token", description = "Get new access token using refresh token")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request) {
        
        TokenResponse response = authService.refreshToken(request.getRefreshToken());
        
        return ResponseEntity.ok(ApiResponse.success("Token refreshed successfully", response));
    }

    @Operation(summary = "Logout user", description = "Revoke current access token")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader("Authorization") String authHeader) {
        
        // Extract JWT from Bearer token
        String token = authHeader.startsWith("Bearer ") 
                ? authHeader.substring(7) 
                : authHeader;
        
        authService.logout(token);
        
        return ResponseEntity.ok(ApiResponse.success("Logout successful", null));
    }

    @Operation(summary = "Send OTP", description = "Send OTP code to phone number via SMS")
    @PostMapping("/send-otp")
    public ResponseEntity<ApiResponse<OtpResponse>> sendOtp(
            @Valid @RequestBody OtpRequest request) {
        
        log.info("OTP request received for: {} (purpose: {})", 
                request.getPhoneNumber(), request.getPurpose());
        
        OtpResponse response = authService.sendOtp(request);
        
        return ResponseEntity.ok(ApiResponse.success("OTP sent successfully", response));
    }

    @Operation(summary = "Verify OTP and login", description = "Verify OTP code and authenticate user")
    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<TokenResponse>> verifyOtp(
            @Valid @RequestBody VerifyOtpRequest request) {
        
        log.info("OTP verification request for: {}", request.getPhoneNumber());
        
        TokenResponse response = authService.verifyOtp(request);
        
        return ResponseEntity.ok(ApiResponse.success("OTP verified successfully", response));
    }

    @Operation(summary = "Forgot password", description = "Initiate password reset process")
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {
        
        log.info("Forgot password request for: {}", request.getIdentifier());
        
        authService.forgotPassword(request);
        
        return ResponseEntity.ok(
                ApiResponse.success("Password reset OTP has been sent to your phone", null));
    }

    @Operation(summary = "Reset password", description = "Reset password using OTP code")
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        
        log.info("Password reset request for: {}", request.getPhoneNumber());
        
        authService.resetPassword(request);
        
        return ResponseEntity.ok(ApiResponse.success("Password reset successful", null));
    }
}



















