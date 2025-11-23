package com.kado24.auth.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.kado24.auth.entity.User.UserRole;
import com.kado24.auth.entity.User.UserStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * User Data Transfer Object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "User information")
public class UserDTO {

    @Schema(description = "User ID", example = "123")
    private Long id;

    @Schema(description = "Full name", example = "Sok Dara")
    private String fullName;

    @Schema(description = "Phone number", example = "+85512345678")
    private String phoneNumber;

    @Schema(description = "Email address", example = "sokdara@example.com")
    private String email;

    @Schema(description = "User role", example = "CONSUMER")
    private UserRole role;

    @Schema(description = "Account status", example = "ACTIVE")
    private UserStatus status;

    @Schema(description = "Avatar image URL", example = "https://cdn.kado24.com/avatars/user123.jpg")
    private String avatarUrl;

    @Schema(description = "Whether email is verified", example = "true")
    private Boolean emailVerified;

    @Schema(description = "Whether phone is verified", example = "true")
    private Boolean phoneVerified;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Account creation timestamp", example = "2025-11-11T10:15:30")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Last login timestamp", example = "2025-11-11T14:30:00")
    private LocalDateTime lastLoginAt;
}






































