package com.kado24.merchant.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.kado24.merchant.entity.Merchant.VerificationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Merchant information")
public class MerchantDTO {

    @Schema(description = "Merchant ID", example = "1")
    private Long id;

    @Schema(description = "User ID", example = "5")
    private Long userId;

    @Schema(description = "Business name", example = "Blue Pumpkin Cafe")
    private String businessName;

    @Schema(description = "Business type", example = "Restaurant")
    private String businessType;

    @Schema(description = "Business license number")
    private String businessLicense;

    @Schema(description = "Tax ID")
    private String taxId;

    @Schema(description = "Phone number", example = "+85512345678")
    private String phoneNumber;

    @Schema(description = "Email", example = "info@bluepumpkin.com")
    private String email;

    @Schema(description = "Logo URL")
    private String logoUrl;

    @Schema(description = "Banner URL")
    private String bannerUrl;

    @Schema(description = "Description")
    private String description;

    @Schema(description = "Full address")
    private String address;

    @Schema(description = "City", example = "Phnom Penh")
    private String city;

    @Schema(description = "Province", example = "Phnom Penh")
    private String province;

    @Schema(description = "Latitude", example = "11.5564")
    private BigDecimal latitude;

    @Schema(description = "Longitude", example = "104.9282")
    private BigDecimal longitude;

    @Schema(description = "Bank name", example = "ABA Bank")
    private String bankName;

    @Schema(description = "Bank account number")
    private String bankAccountNumber;

    @Schema(description = "Bank account name")
    private String bankAccountName;

    @Schema(description = "Verification status", example = "APPROVED")
    private VerificationStatus verificationStatus;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Verified date")
    private LocalDateTime verifiedAt;

    @Schema(description = "Rejection reason (if rejected)")
    private String rejectionReason;

    @Schema(description = "Average rating", example = "4.5")
    private BigDecimal rating;

    @Schema(description = "Total reviews", example = "45")
    private Integer totalReviews;

    @Schema(description = "Total vouchers sold", example = "1250")
    private Integer totalVouchersSold;

    @Schema(description = "Total revenue", example = "25000.00")
    private BigDecimal totalRevenue;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Created date")
    private LocalDateTime createdAt;
}



















