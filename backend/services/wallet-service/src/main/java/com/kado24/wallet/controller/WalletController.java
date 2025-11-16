package com.kado24.wallet.controller;

import com.kado24.common.dto.*;
import com.kado24.wallet.dto.GiftVoucherRequest;
import com.kado24.wallet.dto.WalletVoucherDTO;
import com.kado24.wallet.service.WalletService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<WalletVoucherDTO>>> getMyVouchers(
            HttpServletRequest request,
            @ModelAttribute PageRequest pageRequest) {
        
        Long userId = (Long) request.getAttribute("userId");
        Page<WalletVoucherDTO> vouchers = walletService.getMyVouchers(userId, pageRequest.toSpringPageRequest());
        
        PaginationMeta pagination = PaginationMeta.from(
                vouchers.getNumber(), vouchers.getSize(), vouchers.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.paginated(vouchers, pagination));
    }

    @GetMapping("/{voucherId}")
    public ResponseEntity<ApiResponse<WalletVoucherDTO>> getVoucherDetails(
            HttpServletRequest request,
            @PathVariable Long voucherId) {
        
        Long userId = (Long) request.getAttribute("userId");
        WalletVoucherDTO voucher = walletService.getVoucherDetails(voucherId, userId);
        
        return ResponseEntity.ok(ApiResponse.success(voucher));
    }

    @PostMapping("/{voucherId}/gift")
    public ResponseEntity<ApiResponse<WalletVoucherDTO>> giftVoucher(
            HttpServletRequest request,
            @PathVariable Long voucherId,
            @Valid @RequestBody GiftVoucherRequest giftVoucherRequest
    ) {

        Long senderUserId = (Long) request.getAttribute("userId");
        WalletVoucherDTO giftedVoucher = walletService.giftVoucher(senderUserId, voucherId, giftVoucherRequest);

        return ResponseEntity.ok(ApiResponse.success("Voucher gifted successfully", giftedVoucher));
    }
}
















