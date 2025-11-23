package com.kado24.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for user login
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User login request")
public class LoginRequest {

    @NotBlank(message = "Identifier is required (phone number or email)")
    @Schema(description = "Phone number or email", example = "+85512345678")
    private String identifier;

    @NotBlank(message = "Password is required")
    @Schema(description = "User password", example = "MyP@ssw0rd")
    private String password;
}






































