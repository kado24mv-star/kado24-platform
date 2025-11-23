package com.kado24.voucher.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.kado24.voucher.entity.Voucher.VoucherStatus;
import io.swagger.v3.oas.annotations.media.Schema;
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
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Voucher information")
public class VoucherDTO {

    @Schema(description = "Voucher ID", example = "1")
    private Long id;

    @Schema(description = "Merchant ID", example = "5")
    private Long merchantId;

    @Schema(description = "Merchant name", example = "Blue Pumpkin")
    private String merchantName;

    @Schema(description = "Category ID", example = "1")
    private Long categoryId;

    @Schema(description = "Category name", example = "Food & Dining")
    private String categoryName;

    @Schema(description = "Voucher title", example = "$25 Gift Voucher")
    private String title;

    @Schema(description = "URL-friendly slug", example = "blue-pumpkin-25-gift-voucher")
    private String slug;

    @Schema(description = "Description")
    private String description;

    @Schema(description = "Terms and conditions")
    private String termsAndConditions;

    @Schema(description = "Available denominations", example = "[5.00, 10.00, 25.00, 50.00]")
    private List<BigDecimal> denominations;

    @Schema(description = "Discount percentage", example = "10.00")
    private BigDecimal discountPercentage;

    @Schema(description = "Main image URL")
    private String imageUrl;

    @Schema(description = "Additional images")
    private List<String> additionalImages;

    @Schema(description = "Voucher status", example = "ACTIVE")
    private VoucherStatus status;

    @Schema(description = "Stock quantity", example = "100")
    private Integer stockQuantity;

    @Schema(description = "Unlimited stock flag", example = "false")
    private Boolean unlimitedStock;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Valid from date")
    private LocalDateTime validFrom;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
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

    @Schema(description = "Total sold", example = "150")
    private Integer totalSold;

    @Schema(description = "Total redeemed", example = "120")
    private Integer totalRedeemed;

    @Schema(description = "Average rating", example = "4.5")
    private BigDecimal rating;

    @Schema(description = "Total reviews", example = "45")
    private Integer totalReviews;

    @Schema(description = "View count", example = "1250")
    private Integer viewCount;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Created date")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Published date")
    private LocalDateTime publishedAt;

    @Schema(description = "Availability status", example = "true")
    private Boolean isAvailable;
}






































