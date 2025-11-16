package com.kado24.order.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class VoucherReservationRequest {
    private Long voucherId;
    private BigDecimal denomination;
    private Integer quantity;
}




