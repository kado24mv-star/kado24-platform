package com.kado24.payout.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class PayoutHoldDTO {
    private Long merchantId;
    private String reason;
    private LocalDateTime createdAt;
}




