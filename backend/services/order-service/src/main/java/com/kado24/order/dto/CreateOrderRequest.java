package com.kado24.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Create order request")
public class CreateOrderRequest {

    @NotNull(message = "Voucher ID is required")
    @Schema(description = "Voucher ID", example = "1")
    private Long voucherId;

    @NotNull(message = "Denomination is required")
    @Schema(description = "Selected denomination", example = "25.00")
    private BigDecimal denomination;

    @Min(value = 1, message = "Quantity must be at least 1")
    @Builder.Default
    @Schema(description = "Quantity", example = "1")
    private Integer quantity = 1;

    @Schema(description = "Customer notes")
    private String customerNotes;
}






































