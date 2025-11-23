package com.kado24.merchant.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.merchant.dto.MerchantDTO;
import com.kado24.merchant.service.MerchantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@Slf4j
@RestController
@RequestMapping("/api/v1/merchants/internal")
@RequiredArgsConstructor
@Tag(name = "Merchant Internal", description = "Internal merchant endpoints for inter-service communication")
public class MerchantInternalController {

    private final MerchantService merchantService;

    @Value("${internal.api.secret:kado24-internal-secret}")
    private String internalSecret;

    @Operation(summary = "Get merchant by ID (internal)", description = "Get merchant details by ID for internal service calls")
    @GetMapping("/{merchantId}")
    public ResponseEntity<ApiResponse<MerchantDTO>> getMerchantInternal(
            @RequestHeader(value = "X-Internal-Secret", required = false) String providedSecret,
            @PathVariable Long merchantId) {

        log.debug("Internal request to fetch merchant: {}", merchantId);

        validateSecret(providedSecret);

        MerchantDTO merchant = merchantService.getMerchant(merchantId);

        return ResponseEntity.ok(ApiResponse.success(merchant));
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

