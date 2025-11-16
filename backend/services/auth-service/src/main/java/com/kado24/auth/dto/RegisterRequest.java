package com.kado24.auth.dto;

import com.kado24.auth.entity.User.UserRole;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for user registration
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User registration request")
public class RegisterRequest {

    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 255, message = "Full name must be between 2 and 255 characters")
    @Schema(description = "User's full name", example = "Sok Dara")
    private String fullName;

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+855\\d{8,9}$", message = "Phone number must be in format +855XXXXXXXX")
    @Schema(description = "Phone number in Cambodia format", example = "+85512345678")
    private String phoneNumber;

    @Email(message = "Email must be valid")
    @Schema(description = "Email address (optional)", example = "sokdara@example.com")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 50, message = "Password must be between 8 and 50 characters")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$",
        message = "Password must contain at least one uppercase letter, one lowercase letter, and one digit"
    )
    @Schema(description = "Password (min 8 chars, must include uppercase, lowercase, and digit)", 
            example = "MyP@ssw0rd")
    private String password;

    @NotNull(message = "User role is required")
    @Schema(description = "User role", example = "CONSUMER")
    private UserRole role;
}



















