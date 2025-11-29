package com.kado24.merchant.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import com.kado24.merchant.dto.MerchantDTO;
import com.kado24.merchant.dto.RegisterMerchantRequest;
import com.kado24.merchant.dto.SuspendMerchantRequest;
import com.kado24.merchant.service.MerchantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Merchant management REST controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/merchants")
@RequiredArgsConstructor
@Tag(name = "Merchants", description = "Merchant management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class MerchantController {

    private final MerchantService merchantService;

    @Operation(summary = "Register merchant", description = "Create merchant profile for current user")
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<MerchantDTO>> registerMerchant(
            HttpServletRequest request,
            @Valid @RequestBody RegisterMerchantRequest registerRequest) {

        Long userId = (Long) request.getAttribute("userId");

        log.info("Merchant registration for user: {}", userId);

        MerchantDTO merchant = merchantService.registerMerchant(userId, registerRequest);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Merchant registration submitted. Awaiting admin approval.", merchant));
    }

    @Operation(summary = "Get my merchant profile", description = "Get current user's merchant profile")
    @GetMapping("/my-profile")
    public ResponseEntity<ApiResponse<MerchantDTO>> getMyMerchantProfile(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");

        log.info("Fetching merchant profile for user: {}", userId);

        MerchantDTO merchant = merchantService.getMerchantByUserId(userId);

        return ResponseEntity.ok(ApiResponse.success(merchant));
    }

    @Operation(summary = "Get my merchant statistics", description = "Get statistics for current merchant")
    @GetMapping("/my-statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMyMerchantStatistics(
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        log.info("Merchant fetching own statistics: {}", userId);

        Map<String, Object> stats = merchantService.getMyMerchantStatistics(userId);

        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @Operation(summary = "Get merchant profile", description = "Get merchant by ID")
    @GetMapping("/{merchantId}")
    public ResponseEntity<ApiResponse<MerchantDTO>> getMerchant(@PathVariable Long merchantId) {
        log.info("Fetching merchant: {}", merchantId);

        MerchantDTO merchant = merchantService.getMerchant(merchantId);

        return ResponseEntity.ok(ApiResponse.success(merchant));
    }

    @Operation(summary = "Get pending merchants", description = "Get merchants awaiting approval (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<Page<MerchantDTO>>> getPendingMerchants(
            @ModelAttribute PageRequest pageRequest) {

        log.info("Admin fetching pending merchants");

        Page<MerchantDTO> merchants = merchantService.getPendingMerchants(pageRequest.toSpringPageRequest());

        PaginationMeta pagination = PaginationMeta.from(
                merchants.getNumber(),
                merchants.getSize(),
                merchants.getTotalElements()
        );

        return ResponseEntity.ok(ApiResponse.paginated(merchants, pagination));
    }

    @Operation(summary = "Approve merchant", description = "Approve merchant application (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{merchantId}/approve")
    public ResponseEntity<ApiResponse<MerchantDTO>> approveMerchant(
            HttpServletRequest request,
            @PathVariable Long merchantId) {

        Long adminId = (Long) request.getAttribute("userId");

        log.info("Admin {} approving merchant: {}", adminId, merchantId);

        MerchantDTO merchant = merchantService.approveMerchant(merchantId, adminId);

        return ResponseEntity.ok(ApiResponse.success("Merchant approved successfully", merchant));
    }

    @Operation(summary = "Reject merchant", description = "Reject merchant application (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{merchantId}/reject")
    public ResponseEntity<ApiResponse<MerchantDTO>> rejectMerchant(
            HttpServletRequest request,
            @PathVariable Long merchantId,
            @RequestParam String reason) {

        Long adminId = (Long) request.getAttribute("userId");

        log.info("Admin {} rejecting merchant: {}", adminId, merchantId);

        MerchantDTO merchant = merchantService.rejectMerchant(merchantId, adminId, reason);

        return ResponseEntity.ok(ApiResponse.success("Merchant rejected", merchant));
    }

    @Operation(summary = "Suspend merchant", description = "Suspend an approved merchant (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{merchantId}/suspend")
    public ResponseEntity<ApiResponse<MerchantDTO>> suspendMerchant(
            HttpServletRequest request,
            @PathVariable Long merchantId,
            @Valid @RequestBody SuspendMerchantRequest suspendRequest) {

        Long adminId = (Long) request.getAttribute("userId");
        log.info("Admin {} suspending merchant: {}", adminId, merchantId);

        MerchantDTO merchant = merchantService.suspendMerchant(merchantId, adminId, suspendRequest.getReason());

        return ResponseEntity.ok(ApiResponse.success("Merchant suspended", merchant));
    }

    @Operation(summary = "Get merchant statistics", description = "Get merchant statistics (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getMerchantStatistics() {
        log.info("Admin fetching merchant statistics");

        Map<String, Long> stats = merchantService.getMerchantStatistics();

        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    // Admin endpoints (public for admin-portal-backend proxy)
    @Operation(summary = "Get pending merchants (Admin API)", description = "Get merchants awaiting approval for admin portal")
    @GetMapping("/admin/pending")
    @PreAuthorize("permitAll()")
    public ResponseEntity<ApiResponse<Page<MerchantDTO>>> getAdminPendingMerchants(
            @ModelAttribute PageRequest pageRequest) {

        log.info("Admin API: Fetching pending merchants");

        Page<MerchantDTO> merchants = merchantService.getPendingMerchants(pageRequest.toSpringPageRequest());

        PaginationMeta pagination = PaginationMeta.from(
                merchants.getNumber(),
                merchants.getSize(),
                merchants.getTotalElements()
        );

        return ResponseEntity.ok(ApiResponse.paginated(merchants, pagination));
    }

    @Operation(summary = "Approve merchant (Admin API)", description = "Approve merchant application from admin portal")
    @PostMapping("/admin/{merchantId}/approve")
    @PreAuthorize("permitAll()")
    public ResponseEntity<ApiResponse<MerchantDTO>> adminApproveMerchant(@PathVariable Long merchantId) {
        log.info("Admin API: Approving merchant: {}", merchantId);

        // Using default adminId of 1 for admin portal
        MerchantDTO merchant = merchantService.approveMerchant(merchantId, 1L);

        return ResponseEntity.ok(ApiResponse.success("Merchant approved successfully", merchant));
    }

    @Operation(summary = "Reject merchant (Admin API)", description = "Reject merchant application from admin portal")
    @PostMapping("/admin/{merchantId}/reject")
    @PreAuthorize("permitAll()")
    public ResponseEntity<ApiResponse<MerchantDTO>> adminRejectMerchant(
            @PathVariable Long merchantId,
            @RequestParam String reason) {

        log.info("Admin API: Rejecting merchant: {}", merchantId);

        // Using default adminId of 1 for admin portal
        MerchantDTO merchant = merchantService.rejectMerchant(merchantId, 1L, reason);

        return ResponseEntity.ok(ApiResponse.success("Merchant rejected", merchant));
    }

    @Operation(summary = "Get merchant details (Admin API)", description = "Get merchant details by ID for admin portal")
    @GetMapping("/admin/{merchantId}")
    @PreAuthorize("permitAll()")
    public ResponseEntity<ApiResponse<MerchantDTO>> getAdminMerchantDetails(@PathVariable Long merchantId) {
        log.info("Admin API: Fetching merchant details: {}", merchantId);

        MerchantDTO merchant = merchantService.getMerchant(merchantId);

        return ResponseEntity.ok(ApiResponse.success(merchant));
    }
}







