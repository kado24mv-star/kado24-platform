package com.kado24.auth.dto;

import com.kado24.auth.entity.VerificationRequest;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for Verification Request
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Verification request information")
public class VerificationRequestDTO {

    @Schema(description = "Verification request ID")
    private Long id;

    @Schema(description = "User ID")
    private Long userId;

    @Schema(description = "Phone number")
    private String phoneNumber;

    @Schema(description = "OTP code (only visible to admins)")
    private String otpCode;

    @Schema(description = "Verification status")
    private String status;

    @Schema(description = "Verification method")
    private String verificationMethod;

    @Schema(description = "When verification was requested")
    private LocalDateTime requestedAt;

    @Schema(description = "When verification was completed")
    private LocalDateTime verifiedAt;

    @Schema(description = "Admin user ID who verified")
    private Long verifiedBy;

    @Schema(description = "When OTP expires")
    private LocalDateTime expiresAt;

    @Schema(description = "Admin notes")
    private String notes;

    @Schema(description = "User full name (from user table)")
    private String userFullName;

    @Schema(description = "User email (from user table)")
    private String userEmail;

    @Schema(description = "Is expired")
    private Boolean isExpired;
}

