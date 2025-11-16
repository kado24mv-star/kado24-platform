package com.kado24.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for OTP generation
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "OTP response")
public class OtpResponse {

    @Schema(description = "Success message", example = "OTP sent successfully")
    private String message;

    @Schema(description = "Phone number OTP was sent to (masked)", example = "+855****5678")
    private String phoneNumber;

    @Schema(description = "OTP expiration time in seconds", example = "300")
    private Integer expiresIn;

    @Schema(description = "OTP code (only in development mode)", example = "123456")
    private String otpCode; // Only returned in development mode
}



















