package com.kado24.voucher.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.voucher.dto.VoucherReservationRequest;
import com.kado24.voucher.dto.VoucherReservationResponse;
import com.kado24.voucher.service.VoucherService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@Slf4j
@RestController
@RequestMapping("/api/v1/vouchers/internal")
@RequiredArgsConstructor
public class VoucherInternalController {

    private final VoucherService voucherService;

    @Value("${internal.api.secret:kado24-internal-secret}")
    private String internalSecret;

    @PostMapping("/{voucherId}/reserve")
    public ResponseEntity<ApiResponse<VoucherReservationResponse>> reserveVoucher(
            @RequestHeader(value = "X-Internal-Secret", required = false) String providedSecret,
            @PathVariable Long voucherId,
            @Valid @RequestBody VoucherReservationRequest request
    ) {
        validateSecret(providedSecret);

        log.info("Received internal reservation request for voucher {} quantity {}", voucherId, request.getQuantity());

        VoucherReservationResponse response = voucherService.reserveVoucher(voucherId, request);
        return ResponseEntity.ok(ApiResponse.success("Voucher reserved", response));
    }

    private void validateSecret(String providedSecret) {
        if (internalSecret == null || internalSecret.isBlank()) {
            log.warn("Internal API secret not configured; allowing request");
            return;
        }
        if (!internalSecret.equals(providedSecret)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Invalid internal secret");
        }
    }
}























