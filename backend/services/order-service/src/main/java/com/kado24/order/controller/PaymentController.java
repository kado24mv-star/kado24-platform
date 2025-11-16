package com.kado24.order.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.order.dto.PaymentRequest;
import com.kado24.order.dto.PaymentResponse;
import com.kado24.order.service.PaymentProcessingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Payment processing endpoints")
@SecurityRequirement(name = "bearerAuth")
public class PaymentController {

    private final PaymentProcessingService paymentProcessingService;

    @Operation(summary = "Initiate payment", description = "Complete payment for an existing order")
    @PostMapping
    public ResponseEntity<ApiResponse<PaymentResponse>> processPayment(
            HttpServletRequest request,
            @Valid @RequestBody PaymentRequest paymentRequest) {

        Long userId = (Long) request.getAttribute("userId");
        log.info("Processing payment for order {} by user {}", paymentRequest.getOrderId(), userId);

        PaymentResponse response = paymentProcessingService.processPayment(userId, paymentRequest);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Payment processed successfully", response));
    }

    @Operation(summary = "Get payment status", description = "Retrieve payment status for an order")
    @GetMapping("/order/{orderId}")
    public ResponseEntity<ApiResponse<PaymentResponse>> getPaymentStatus(
            HttpServletRequest request,
            @PathVariable Long orderId) {

        Long userId = (Long) request.getAttribute("userId");
        log.info("Fetching payment status for order {} by user {}", orderId, userId);

        PaymentResponse response = paymentProcessingService.getPaymentStatus(userId, orderId);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}












