package com.kado24.auth.controller;

import com.kado24.auth.dto.VerificationRequestDTO;
import com.kado24.auth.entity.VerificationRequest;
import com.kado24.auth.repository.UserRepository;
import com.kado24.auth.service.VerificationRequestService;
import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.stream.Collectors;

/**
 * Admin endpoints for managing verification requests
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/admin/verifications")
@RequiredArgsConstructor
@Tag(name = "Admin Verification", description = "Admin endpoints for managing user verifications")
@PreAuthorize("hasRole('ADMIN')")
@SecurityRequirement(name = "bearerAuth")
public class AdminVerificationController {

    private final VerificationRequestService verificationRequestService;
    private final UserRepository userRepository;

    @Operation(summary = "Get pending verifications", description = "Get paginated list of pending verification requests")
    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<Page<VerificationRequestDTO>>> getPendingVerifications(
            @ModelAttribute PageRequest pageRequest,
            HttpServletRequest request) {

        Long adminId = (Long) request.getAttribute("userId");
        if (adminId == null) {
            // Try to get from SecurityContext if not in request attribute
            try {
                org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
                if (auth != null && auth.getPrincipal() instanceof org.springframework.security.oauth2.jwt.Jwt) {
                    org.springframework.security.oauth2.jwt.Jwt jwt = (org.springframework.security.oauth2.jwt.Jwt) auth.getPrincipal();
                    adminId = jwt.getClaim("userId");
                }
            } catch (Exception e) {
                log.warn("Could not extract userId from SecurityContext: {}", e.getMessage());
            }
        }
        log.info("Admin {} fetching pending verifications", adminId);

        Page<VerificationRequest> verifications = verificationRequestService.getPendingVerifications(
                pageRequest.toSpringPageRequest()
        );

        // Convert to DTO with user details
        Page<VerificationRequestDTO> dtos = verifications.map(this::toDTO);

        PaginationMeta pagination = PaginationMeta.from(
                dtos.getNumber(),
                dtos.getSize(),
                dtos.getTotalElements()
        );

        return ResponseEntity.ok(ApiResponse.paginated(dtos, pagination));
    }

    @Operation(summary = "Get verification by ID", description = "Get verification request details")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<VerificationRequestDTO>> getVerification(
            @PathVariable Long id) {

        VerificationRequest verification = verificationRequestService.getByUserId(id)
                .orElseThrow(() -> new RuntimeException("Verification request not found"));

        return ResponseEntity.ok(ApiResponse.success(toDTO(verification)));
    }

    @Operation(summary = "Manually verify user", description = "Admin manually verifies and activates user account")
    @PostMapping("/{id}/verify")
    public ResponseEntity<ApiResponse<VerificationRequestDTO>> verifyUser(
            @PathVariable Long id,
            @Valid @RequestBody VerifyRequest verifyRequest,
            HttpServletRequest request) {

        Long adminId = (Long) request.getAttribute("userId");
        log.info("Admin {} verifying user {}", adminId, id);

        VerificationRequest verification = verificationRequestService.verifyManually(
                id,
                adminId,
                verifyRequest.getNotes()
        );

        return ResponseEntity.ok(ApiResponse.success("User verified successfully", toDTO(verification)));
    }

    @Operation(summary = "Reject verification", description = "Admin rejects verification request")
    @PostMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<VerificationRequestDTO>> rejectVerification(
            @PathVariable Long id,
            @Valid @RequestBody RejectRequest rejectRequest,
            HttpServletRequest request) {

        Long adminId = (Long) request.getAttribute("userId");
        log.info("Admin {} rejecting verification {}", adminId, id);

        VerificationRequest verification = verificationRequestService.rejectVerification(
                id,
                adminId,
                rejectRequest.getNotes()
        );

        return ResponseEntity.ok(ApiResponse.success("Verification rejected", toDTO(verification)));
    }

    @Operation(summary = "Get verification statistics", description = "Get counts of verification requests by status")
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<VerificationStats>> getStatistics() {
        long pending = verificationRequestService.countPendingVerifications();
        return ResponseEntity.ok(ApiResponse.success(new VerificationStats(pending)));
    }

    /**
     * Convert entity to DTO
     */
    private VerificationRequestDTO toDTO(VerificationRequest verification) {
        VerificationRequestDTO.VerificationRequestDTOBuilder builder = VerificationRequestDTO.builder()
                .id(verification.getId())
                .userId(verification.getUserId())
                .phoneNumber(verification.getPhoneNumber())
                .otpCode(verification.getOtpCode()) // Admins can see OTP
                .status(verification.getStatus().name())
                .verificationMethod(verification.getVerificationMethod().name())
                .requestedAt(verification.getRequestedAt())
                .verifiedAt(verification.getVerifiedAt())
                .verifiedBy(verification.getVerifiedBy())
                .expiresAt(verification.getExpiresAt())
                .notes(verification.getNotes())
                .isExpired(verification.isExpired());

        // Add user details
        userRepository.findById(verification.getUserId()).ifPresent(user -> {
            builder.userFullName(user.getFullName());
            builder.userEmail(user.getEmail());
        });

        return builder.build();
    }

    @Data
    public static class VerifyRequest {
        private String notes;
    }

    @Data
    public static class RejectRequest {
        @NotBlank(message = "Rejection reason is required")
        private String notes;
    }

    @Data
    @RequiredArgsConstructor
    public static class VerificationStats {
        private final long pendingCount;
    }
}

