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
public class MockPaymentResponse {
    private String paymentId;
    private String orderId;
    private BigDecimal amount;
    private String paymentUrl;
    private String qrCode;
    private Integer expiresIn;
    private String status;
}






































