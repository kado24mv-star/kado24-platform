package com.kado24.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for OTP generation
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "OTP request")
public class OtpRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+855\\d{8,9}$", message = "Phone number must be in format +855XXXXXXXX")
    @Schema(description = "Phone number to receive OTP", example = "+85512345678")
    private String phoneNumber;

    @Schema(description = "OTP purpose", example = "REGISTRATION", 
            allowableValues = {"REGISTRATION", "LOGIN", "PASSWORD_RESET", "PHONE_VERIFICATION"})
    @Builder.Default
    private String purpose = "REGISTRATION";
}



















