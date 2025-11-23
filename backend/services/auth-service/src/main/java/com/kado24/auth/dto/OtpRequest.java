package com.kado24.auth.dto;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.kado24.common.util.PhoneNumberDeserializer;
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
    @Pattern(regexp = "^\\+855\\d{8,9}$", message = "Phone number must be in format 0XXXXXXXX or +855XXXXXXXX")
    @JsonDeserialize(using = PhoneNumberDeserializer.class)
    @Schema(description = "Phone number to receive OTP (0XXXXXXXX or +855XXXXXXXX)", example = "012345678 or +85512345678")
    private String phoneNumber;

    @Schema(description = "OTP purpose", example = "REGISTRATION", 
            allowableValues = {"REGISTRATION", "LOGIN", "PASSWORD_RESET", "PHONE_VERIFICATION"})
    @Builder.Default
    private String purpose = "REGISTRATION";
}




























