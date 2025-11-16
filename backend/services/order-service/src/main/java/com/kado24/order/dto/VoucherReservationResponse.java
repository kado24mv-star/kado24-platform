package com.kado24.order.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class VoucherReservationResponse {
    private Long voucherId;
    private Long merchantId;
    private String voucherTitle;
    private BigDecimal denomination;
    private Integer remainingStock;
    private Boolean unlimitedStock;
}




