package com.kado24.voucher.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class VoucherReservationRequest {

    @Schema(description = "Requested denomination", example = "25.00")
    @NotNull(message = "Denomination is required")
    private BigDecimal denomination;

    @Schema(description = "Quantity to reserve", example = "1")
    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity = 1;
}




