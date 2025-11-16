package com.kado24.voucher.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;
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
@Schema(description = "Update voucher request")
public class UpdateVoucherRequest {

    @Size(min = 3, max = 255)
    @Schema(description = "Voucher title", example = "$25 Blue Pumpkin Gift Voucher")
    private String title;

    @Schema(description = "Voucher description")
    private String description;

    @Schema(description = "Terms and conditions")
    private String termsAndConditions;

    @Schema(description = "Available denominations", example = "[5.00, 10.00, 25.00, 50.00]")
    private List<BigDecimal> denominations;

    @DecimalMin(value = "0.0")
    @DecimalMax(value = "100.0")
    @Schema(description = "Discount percentage", example = "10.00")
    private BigDecimal discountPercentage;

    @Schema(description = "Main image URL")
    private String imageUrl;

    @Schema(description = "Additional image URLs")
    private List<String> additionalImages;

    @Schema(description = "Stock quantity (null if unlimited)")
    private Integer stockQuantity;

    @Schema(description = "Unlimited stock flag", example = "false")
    private Boolean unlimitedStock;

    @Schema(description = "Valid from date")
    private LocalDateTime validFrom;

    @Schema(description = "Valid until date")
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



















