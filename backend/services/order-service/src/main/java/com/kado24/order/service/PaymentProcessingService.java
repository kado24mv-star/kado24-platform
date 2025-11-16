package com.kado24.order.service;

import com.kado24.common.exception.BusinessException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.order.client.VoucherClient;
import com.kado24.order.client.WalletClient;
import com.kado24.order.dto.OrderDTO;
import com.kado24.order.dto.PaymentRequest;
import com.kado24.order.dto.PaymentResponse;
import com.kado24.order.dto.VoucherReservationRequest;
import com.kado24.order.dto.WalletIssuanceRequest;
import com.kado24.order.entity.Order;
import com.kado24.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentProcessingService {

    private final OrderRepository orderRepository;
    private final OrderService orderService;
    private final WalletClient walletClient;
    private final VoucherClient voucherClient;

    @Transactional
    public PaymentResponse processPayment(Long userId, PaymentRequest request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new ResourceNotFoundException("Order", request.getOrderId()));

        validateOrderOwnership(order, userId);
        validatePaymentAmount(order.getTotalAmount(), request.getAmount());

        if (order.getOrderStatus() == Order.OrderStatus.CONFIRMED) {
            log.info("Order {} already confirmed, skipping payment duplication", order.getId());
            return PaymentResponse.fromOrder(order, "Payment already completed");
        }

        voucherClient.reserveVoucher(
                VoucherReservationRequest.builder()
                        .voucherId(order.getVoucherId())
                        .denomination(order.getDenomination())
                        .quantity(order.getQuantity())
                        .build()
        );

        String paymentId = generatePaymentId(request.getPaymentMethod());
        OrderDTO confirmedOrder = orderService.confirmOrder(order.getId(), paymentId, request.getPaymentMethod());

        boolean walletIssued = true;
        try {
            walletClient.issueVouchers(WalletIssuanceRequest.builder()
                    .orderId(confirmedOrder.getId())
                    .userId(confirmedOrder.getUserId())
                    .voucherId(confirmedOrder.getVoucherId())
                    .merchantId(confirmedOrder.getMerchantId())
                    .denomination(confirmedOrder.getDenomination())
                    .quantity(confirmedOrder.getQuantity())
                    .build());
        } catch (BusinessException ex) {
            walletIssued = false;
            log.warn("Wallet issuance failed for order {}: {}", confirmedOrder.getId(), ex.getMessage());
        }

        return PaymentResponse.builder()
                .orderId(confirmedOrder.getId())
                .paymentId(paymentId)
                .paymentMethod(confirmedOrder.getPaymentMethod())
                .status(confirmedOrder.getPaymentStatus())
                .amount(confirmedOrder.getTotalAmount())
                .paidAt(confirmedOrder.getPaidAt())
                .message(walletIssued ? "Payment completed successfully" : "Payment completed - wallet sync pending")
                .build();
    }

    public PaymentResponse getPaymentStatus(Long userId, Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));

        validateOrderOwnership(order, userId);

        String message = switch (order.getPaymentStatus()) {
            case COMPLETED -> "Payment completed";
            case FAILED -> "Payment failed";
            case CANCELLED -> "Payment cancelled";
            case PENDING -> "Awaiting payment";
            case PROCESSING -> "Payment is processing";
            case REFUNDED -> "Payment refunded";
        };

        return PaymentResponse.fromOrder(order, message);
    }

    private void validateOrderOwnership(Order order, Long userId) {
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException("You do not have access to this order");
        }
    }

    private void validatePaymentAmount(BigDecimal expected, BigDecimal provided) {
        if (provided == null || expected.compareTo(provided) != 0) {
            throw new BusinessException("Payment amount does not match order total");
        }
    }

    private String generatePaymentId(String method) {
        String prefix = (method != null && !method.isBlank())
                ? method.replaceAll("[^A-Za-z0-9]", "").toUpperCase()
                : "PAY";
        return "%s-%s".formatted(prefix, UUID.randomUUID().toString().replace("-", "").substring(0, 12));
    }
}

