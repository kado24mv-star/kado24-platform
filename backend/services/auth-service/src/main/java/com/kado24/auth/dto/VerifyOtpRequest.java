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
 * Request DTO for OTP verification
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "OTP verification request")
public class VerifyOtpRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+855\\d{8,9}$", message = "Phone number must be in format 0XXXXXXXX or +855XXXXXXXX")
    @JsonDeserialize(using = PhoneNumberDeserializer.class)
    @Schema(description = "Phone number (0XXXXXXXX or +855XXXXXXXX)", example = "012345678 or +85512345678")
    private String phoneNumber;

    @NotBlank(message = "OTP code is required")
    @Size(min = 6, max = 6, message = "OTP must be 6 digits")
    @Pattern(regexp = "^\\d{6}$", message = "OTP must be 6 digits")
    @Schema(description = "6-digit OTP code", example = "123456")
    private String otpCode;

    @Schema(description = "OTP purpose", example = "REGISTRATION", allowableValues = {"REGISTRATION", "LOGIN", "PASSWORD_RESET"})
    private String purpose;
}



























