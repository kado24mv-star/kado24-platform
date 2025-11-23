package com.kado24.voucher.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class VoucherReservationResponse {
    private Long voucherId;
    private Long merchantId;
    private String voucherTitle;
    private BigDecimal denomination;
    private Integer remainingStock;
    private Boolean unlimitedStock;
}























