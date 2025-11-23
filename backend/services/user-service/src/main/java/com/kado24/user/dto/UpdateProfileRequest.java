package com.kado24.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating user profile
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Update profile request")
public class UpdateProfileRequest {

    @Size(min = 2, max = 255, message = "Full name must be between 2 and 255 characters")
    @Schema(description = "Full name", example = "Sok Dara Updated")
    private String fullName;

    @Email(message = "Email must be valid")
    @Schema(description = "Email address", example = "newemail@example.com")
    private String email;

    @Schema(description = "Avatar URL", example = "https://cdn.kado24.com/avatars/user123.jpg")
    private String avatarUrl;
}






































