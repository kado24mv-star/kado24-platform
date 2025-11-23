package com.kado24.payout.dto;

import com.kado24.payout.entity.Payout;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class PayoutDTO {
    private Long id;
    private Long merchantId;
    private String payoutNumber;
    private BigDecimal amount;
    private String currency;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private Payout.PayoutStatus status;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;

    public static PayoutDTO fromEntity(Payout payout) {
        return PayoutDTO.builder()
                .id(payout.getId())
                .merchantId(payout.getMerchantId())
                .payoutNumber(payout.getPayoutNumber())
                .amount(payout.getAmount())
                .currency(payout.getCurrency())
                .periodStart(payout.getPeriodStart())
                .periodEnd(payout.getPeriodEnd())
                .status(payout.getStatus())
                .paidAt(payout.getPaidAt())
                .createdAt(payout.getCreatedAt())
                .build();
    }
}

