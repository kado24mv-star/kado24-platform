package com.kado24.order.dto;

import com.kado24.order.entity.Order;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {

    private Long orderId;
    private String paymentId;
    private String paymentMethod;
    private Order.PaymentStatus status;
    private BigDecimal amount;
    private LocalDateTime paidAt;
    private String message;

    public static PaymentResponse fromOrder(Order order, String message) {
        return PaymentResponse.builder()
                .orderId(order.getId())
                .paymentId(order.getPaymentId())
                .paymentMethod(order.getPaymentMethod())
                .status(order.getPaymentStatus())
                .amount(order.getTotalAmount())
                .paidAt(order.getPaidAt())
                .message(message)
                .build();
    }
}












