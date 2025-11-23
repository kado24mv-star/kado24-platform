package com.kado24.voucher.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import com.kado24.voucher.dto.CreateVoucherRequest;
import com.kado24.voucher.dto.UpdateVoucherRequest;
import com.kado24.voucher.dto.VoucherDTO;
import com.kado24.voucher.service.VoucherService;
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

/**
 * Voucher management REST controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/vouchers")
@RequiredArgsConstructor
@Tag(name = "Vouchers", description = "Voucher management endpoints")
public class VoucherController {

    private final VoucherService voucherService;

    @Operation(summary = "Get active vouchers", description = "Get paginated list of active vouchers (public)")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<VoucherDTO>>> getActiveVouchers(
            @ModelAttribute PageRequest pageRequest) {
        
        log.info("Fetching active vouchers");
        
        Page<VoucherDTO> vouchers = voucherService.getActiveVouchers(pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                vouchers.getNumber(),
                vouchers.getSize(),
                vouchers.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(vouchers, pagination));
    }

    @Operation(summary = "Get voucher details", description = "Get voucher by ID or slug (public)")
    @GetMapping("/{slugOrId}")
    public ResponseEntity<ApiResponse<VoucherDTO>> getVoucher(@PathVariable String slugOrId) {
        log.info("Fetching voucher: {}", slugOrId);
        
        VoucherDTO voucher = voucherService.getVoucher(slugOrId);
        
        return ResponseEntity.ok(ApiResponse.success(voucher));
    }

    @Operation(summary = "Search vouchers", description = "Search vouchers by title/description (public)")
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Page<VoucherDTO>>> searchVouchers(
            @RequestParam String query,
            @ModelAttribute PageRequest pageRequest) {
        
        log.info("Searching vouchers with query: {}", query);
        
        Page<VoucherDTO> vouchers = voucherService.searchVouchers(query, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                vouchers.getNumber(),
                vouchers.getSize(),
                vouchers.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(vouchers, pagination));
    }

    @Operation(summary = "Get vouchers by category", description = "Get vouchers in a specific category (public)")
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<ApiResponse<Page<VoucherDTO>>> getVouchersByCategory(
            @PathVariable Long categoryId,
            @ModelAttribute PageRequest pageRequest) {
        
        log.info("Fetching vouchers for category: {}", categoryId);
        
        Page<VoucherDTO> vouchers = voucherService.getVouchersByCategory(categoryId, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                vouchers.getNumber(),
                vouchers.getSize(),
                vouchers.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(vouchers, pagination));
    }

    @Operation(summary = "Create voucher", description = "Create new voucher (merchant only)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @PostMapping
    public ResponseEntity<ApiResponse<VoucherDTO>> createVoucher(
            HttpServletRequest request,
            @Valid @RequestBody CreateVoucherRequest createRequest) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            log.error("userId is null in request attributes. Available attributes: {}", request.getAttributeNames());
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        Long merchantId;
        try {
            merchantId = voucherService.getMerchantIdByUserId(userId);
        } catch (Exception e) {
            log.error("Error getting merchant ID for user ID: {}", userId, e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to retrieve merchant information. Please try again later."));
        }
        
        if (merchantId == null) {
            log.error("No merchant found for user ID: {}", userId);
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Creating voucher for merchant: {} (user: {})", merchantId, userId);
        
        VoucherDTO voucher = voucherService.createVoucher(merchantId, createRequest);
        
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Voucher created successfully", voucher));
    }

    @Operation(summary = "Update voucher", description = "Update voucher (merchant only)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @PutMapping("/{voucherId}")
    public ResponseEntity<ApiResponse<VoucherDTO>> updateVoucher(
            HttpServletRequest request,
            @PathVariable Long voucherId,
            @Valid @RequestBody UpdateVoucherRequest updateRequest) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        Long merchantId = voucherService.getMerchantIdByUserId(userId);
        if (merchantId == null) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Updating voucher: {} by merchant: {} (user: {})", voucherId, merchantId, userId);
        
        VoucherDTO voucher = voucherService.updateVoucher(voucherId, merchantId, updateRequest);
        
        return ResponseEntity.ok(ApiResponse.success("Voucher updated successfully", voucher));
    }

    @Operation(summary = "Publish voucher", description = "Make voucher active (merchant only)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @PostMapping("/{voucherId}/publish")
    public ResponseEntity<ApiResponse<VoucherDTO>> publishVoucher(
            HttpServletRequest request,
            @PathVariable Long voucherId) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        Long merchantId = voucherService.getMerchantIdByUserId(userId);
        if (merchantId == null) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Publishing voucher: {} by merchant: {} (user: {})", voucherId, merchantId, userId);
        
        VoucherDTO voucher = voucherService.publishVoucher(voucherId, merchantId);
        
        return ResponseEntity.ok(ApiResponse.success("Voucher published successfully", voucher));
    }

    @Operation(summary = "Pause/Unpause voucher", description = "Toggle voucher pause status (merchant only)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @PostMapping("/{voucherId}/toggle-pause")
    public ResponseEntity<ApiResponse<VoucherDTO>> togglePauseVoucher(
            HttpServletRequest request,
            @PathVariable Long voucherId) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        Long merchantId = voucherService.getMerchantIdByUserId(userId);
        if (merchantId == null) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Toggling pause status for voucher: {} by merchant: {} (user: {})", voucherId, merchantId, userId);
        
        VoucherDTO voucher = voucherService.togglePauseVoucher(voucherId, merchantId);
        
        return ResponseEntity.ok(ApiResponse.success("Voucher status updated successfully", voucher));
    }

    @Operation(summary = "Delete voucher", description = "Soft delete voucher (merchant only)")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @DeleteMapping("/{voucherId}")
    public ResponseEntity<ApiResponse<Void>> deleteVoucher(
            HttpServletRequest request,
            @PathVariable Long voucherId) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        Long merchantId = voucherService.getMerchantIdByUserId(userId);
        if (merchantId == null) {
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Deleting voucher: {} by merchant: {} (user: {})", voucherId, merchantId, userId);
        
        voucherService.deleteVoucher(voucherId, merchantId);
        
        return ResponseEntity.ok(ApiResponse.success("Voucher deleted successfully", null));
    }

    @Operation(summary = "Get my vouchers", description = "Get merchant's own vouchers")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @GetMapping("/my-vouchers")
    public ResponseEntity<ApiResponse<Page<VoucherDTO>>> getMyVouchers(
            HttpServletRequest request,
            @ModelAttribute PageRequest pageRequest) {
        
        Long userId = (Long) request.getAttribute("userId");
        
        if (userId == null) {
            log.error("userId is null in request attributes");
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("User ID not found in token. Please login again."));
        }
        
        // Get merchant_id from user_id
        // Check for null merchantId BEFORE making potentially expensive queries
        Long merchantId;
        try {
            merchantId = voucherService.getMerchantIdByUserId(userId);
        } catch (Exception e) {
            log.error("Error getting merchant ID for user ID: {}", userId, e);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to retrieve merchant information. Please try again later."));
        }
        
        if (merchantId == null) {
            log.error("No merchant found for user ID: {}", userId);
            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Merchant account not found for this user."));
        }
        
        log.info("Fetching vouchers for merchant: {} (user: {})", merchantId, userId);
        
        Page<VoucherDTO> vouchers = voucherService.getMerchantVouchers(merchantId, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                vouchers.getNumber(),
                vouchers.getSize(),
                vouchers.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(vouchers, pagination));
    }
}

























