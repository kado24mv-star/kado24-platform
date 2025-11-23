package com.kado24.mock.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MockPaymentRequest {
    private String orderId;
    private BigDecimal amount;
    private String method; // ABA, WING, PIPAY, KHQR
    private String currency;
}






































