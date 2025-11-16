package com.kado24.redemption.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import com.kado24.redemption.dto.RedeemVoucherRequest;
import com.kado24.redemption.dto.RedemptionDTO;
import com.kado24.redemption.service.RedemptionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/redemptions")
@RequiredArgsConstructor
public class RedemptionController {

    private final RedemptionService redemptionService;

    @PostMapping("/redeem")
    public ResponseEntity<ApiResponse<RedemptionDTO>> redeemVoucher(
            HttpServletRequest request,
            @Valid @RequestBody RedeemVoucherRequest redeemRequest) {

        Long merchantId = (Long) request.getAttribute("userId");
        
        RedemptionDTO redemption = redemptionService.redeemVoucher(redeemRequest, merchantId);
        
        return ResponseEntity.ok(ApiResponse.success("Voucher redeemed successfully", redemption));
    }

    @GetMapping("/my-redemptions")
    public ResponseEntity<ApiResponse<Page<RedemptionDTO>>> getMyRedemptions(
            HttpServletRequest request,
            @ModelAttribute PageRequest pageRequest) {

        Long userId = (Long) request.getAttribute("userId");
        
        Page<RedemptionDTO> redemptions = redemptionService.getMyRedemptions(userId, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                redemptions.getNumber(),
                redemptions.getSize(),
                redemptions.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(redemptions, pagination));
    }

    @GetMapping("/merchant/{merchantId}")
    public ResponseEntity<ApiResponse<Page<RedemptionDTO>>> getMerchantRedemptions(
            HttpServletRequest request,
            @PathVariable Long merchantId,
            @ModelAttribute PageRequest pageRequest) {

        Long currentUserId = (Long) request.getAttribute("userId");
        
        Page<RedemptionDTO> redemptions = redemptionService.getMerchantRedemptions(merchantId, currentUserId, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                redemptions.getNumber(),
                redemptions.getSize(),
                redemptions.getTotalElements()
        );
        
        return ResponseEntity.ok(ApiResponse.paginated(redemptions, pagination));
    }
}







