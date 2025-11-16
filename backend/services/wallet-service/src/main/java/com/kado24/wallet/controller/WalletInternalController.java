package com.kado24.wallet.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.wallet.dto.IssueWalletVoucherRequest;
import com.kado24.wallet.dto.WalletVoucherDTO;
import com.kado24.wallet.service.WalletService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/wallet/internal")
@RequiredArgsConstructor
@Tag(name = "Wallet Internal", description = "Internal wallet issuance endpoints")
public class WalletInternalController {

    private final WalletService walletService;

    @Value("${internal.api.secret:kado24-internal-secret}")
    private String internalSecret;

    @Operation(summary = "Issue vouchers", description = "Issue wallet vouchers directly (internal use only)")
    @PostMapping("/issue")
    public ResponseEntity<ApiResponse<List<WalletVoucherDTO>>> issueVouchers(
            @RequestHeader(value = "X-Internal-Secret", required = false) String providedSecret,
            @Valid @RequestBody IssueWalletVoucherRequest request) {

        log.info("Received internal wallet issuance request for order {} (quantity {})",
                request.getOrderId(), request.getQuantity());

        validateSecret(providedSecret);

        int quantity = request.getQuantity() != null && request.getQuantity() > 0
                ? request.getQuantity()
                : 1;

        List<WalletVoucherDTO> vouchers = walletService.createWalletVouchers(
                request.getOrderId(),
                request.getUserId(),
                request.getVoucherId(),
                request.getMerchantId(),
                request.getDenomination(),
                quantity
        );

        return ResponseEntity.ok(ApiResponse.success("Wallet vouchers issued", vouchers));
    }

    private void validateSecret(String providedSecret) {
        if (internalSecret == null || internalSecret.isBlank()) {
            log.warn("Internal API secret is not configured; allowing request");
            return;
        }
        if (!internalSecret.equals(providedSecret)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Invalid internal secret");
        }
    }
}

