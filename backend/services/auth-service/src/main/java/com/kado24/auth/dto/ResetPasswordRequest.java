package com.kado24.auth.dto;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.kado24.common.util.PhoneNumberDeserializer;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for password reset
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Password reset request")
public class ResetPasswordRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+855\\d{8,9}$", message = "Phone number must be in format 0XXXXXXXX or +855XXXXXXXX")
    @JsonDeserialize(using = PhoneNumberDeserializer.class)
    @Schema(description = "Phone number (0XXXXXXXX or +855XXXXXXXX)", example = "012345678 or +85512345678")
    private String phoneNumber;

    @NotBlank(message = "OTP code is required")
    @Size(min = 6, max = 6, message = "OTP must be 6 digits")
    @Schema(description = "6-digit OTP code received via SMS", example = "123456")
    private String otpCode;

    @NotBlank(message = "New password is required")
    @Size(min = 8, max = 50, message = "Password must be between 8 and 50 characters")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$",
        message = "Password must contain at least one uppercase letter, one lowercase letter, and one digit"
    )
    @Schema(description = "New password", example = "NewP@ssw0rd")
    private String newPassword;
}




























