package com.kado24.user.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import com.kado24.user.dto.UpdateProfileRequest;
import com.kado24.user.dto.UserProfileDTO;
import com.kado24.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * User profile management REST controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "User Profile", description = "User profile management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @Operation(summary = "Get current user profile", description = "Get authenticated user's profile")
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileDTO>> getMyProfile(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        
        log.info("Fetching profile for user ID: {}", userId);
        
        UserProfileDTO profile = userService.getUserProfile(userId);
        
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    @Operation(summary = "Update current user profile", description = "Update authenticated user's profile")
    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileDTO>> updateMyProfile(
            HttpServletRequest request,
            @Valid @RequestBody UpdateProfileRequest updateRequest) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        log.info("Updating profile for user ID: {}", userId);
        
        UserProfileDTO profile = userService.updateProfile(userId, updateRequest);
        
        return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", profile));
    }

    @Operation(summary = "Delete current user account", description = "Soft delete authenticated user's account")
    @DeleteMapping("/profile")
    public ResponseEntity<ApiResponse<Void>> deleteMyAccount(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        
        log.info("Deleting account for user ID: {}", userId);
        
        userService.deleteAccount(userId);
        
        return ResponseEntity.ok(ApiResponse.success("Account deleted successfully", null));
    }

    @Operation(summary = "Get user by ID", description = "Get user profile by ID (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserProfileDTO>> getUserById(@PathVariable Long userId) {
        log.info("Admin fetching user profile for ID: {}", userId);
        
        UserProfileDTO profile = userService.getUserProfile(userId);
        
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    @Operation(summary = "Get all users", description = "Get paginated list of all users (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<UserProfileDTO>>> getAllUsers(
            @ModelAttribute PageRequest pageRequest) {
        
        log.info("Admin fetching all users");
        
        Page<UserProfileDTO> users = userService.getAllUsers(pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                users.getNumber(),
                users.getSize(),
                users.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(users, pagination));
    }

    @Operation(summary = "Search users", description = "Search users by name (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Page<UserProfileDTO>>> searchUsers(
            @RequestParam String query,
            @ModelAttribute PageRequest pageRequest) {
        
        log.info("Admin searching users with query: {}", query);
        
        Page<UserProfileDTO> users = userService.searchUsers(query, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                users.getNumber(),
                users.getSize(),
                users.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(users, pagination));
    }

    @Operation(summary = "Get user statistics", description = "Get platform user statistics (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUserStatistics() {
        log.info("Admin fetching user statistics");
        
        Map<String, Long> stats = userService.getUserStatistics();
        
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}



















