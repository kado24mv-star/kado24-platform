package com.kado24.user.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.kado24.user.entity.User.UserRole;
import com.kado24.user.entity.User.UserStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * User profile DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "User profile information")
public class UserProfileDTO {

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

    @Schema(description = "Avatar image URL")
    private String avatarUrl;

    @Schema(description = "Email verified status")
    private Boolean emailVerified;

    @Schema(description = "Phone verified status")
    private Boolean phoneVerified;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Account creation date")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Last login date")
    private LocalDateTime lastLoginAt;
}






































