package com.kado24.wallet.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class IssueWalletVoucherRequest {

    @NotNull
    private Long orderId;

    @NotNull
    private Long userId;

    @NotNull
    private Long voucherId;

    @NotNull
    private Long merchantId;

    @NotNull
    @DecimalMin(value = "0.01")
    private BigDecimal denomination;

    @Min(1)
    private Integer quantity = 1;
}































