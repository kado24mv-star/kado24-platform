package com.kado24.voucher.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Create voucher request")
public class CreateVoucherRequest {

    @NotNull(message = "Category ID is required")
    @Schema(description = "Voucher category ID", example = "1")
    private Long categoryId;

    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 255)
    @Schema(description = "Voucher title", example = "$25 Blue Pumpkin Gift Voucher")
    private String title;

    @NotBlank(message = "Description is required")
    @Schema(description = "Voucher description")
    private String description;

    @Schema(description = "Terms and conditions")
    private String termsAndConditions;

    @NotEmpty(message = "At least one denomination is required")
    @Schema(description = "Available denominations", example = "[5.00, 10.00, 25.00, 50.00]")
    private List<BigDecimal> denominations;

    @DecimalMin(value = "0.0", message = "Discount must be positive")
    @DecimalMax(value = "100.0", message = "Discount cannot exceed 100%")
    @Schema(description = "Discount percentage", example = "10.00")
    private BigDecimal discountPercentage;

    @Schema(description = "Voucher image URL (one image per voucher)")
    private String imageUrl;

    @Schema(description = "Stock quantity (null if unlimited)")
    private Integer stockQuantity;

    @Builder.Default
    @Schema(description = "Unlimited stock flag", example = "false")
    private Boolean unlimitedStock = false;

    @Schema(description = "Valid from date (optional)")
    private LocalDateTime validFrom;

    @Schema(description = "Valid until date (optional)")
    private LocalDateTime validUntil;

    @Schema(description = "Redemption locations")
    private List<String> redemptionLocations;

    @Schema(description = "Minimum purchase amount", example = "5.00")
    private BigDecimal minPurchaseAmount;

    @Schema(description = "Max purchase per user", example = "5")
    private Integer maxPurchasePerUser;

    @Schema(description = "Usage instructions")
    private String usageInstructions;
}

































