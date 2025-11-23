package com.kado24.order.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class WalletIssuanceRequest {

    private Long orderId;
    private Long userId;
    private Long voucherId;
    private Long merchantId;
    private BigDecimal denomination;
    private Integer quantity;
}































