package com.kado24.merchant.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Register merchant request")
public class RegisterMerchantRequest {

    @NotBlank(message = "Business name is required")
    @Schema(description = "Business name", example = "Blue Pumpkin Cafe")
    private String businessName;

    @NotBlank(message = "Business type is required")
    @Schema(description = "Business type", example = "Restaurant")
    private String businessType;

    @NotBlank(message = "Business license is required")
    @Schema(description = "Business license number", example = "BL-12345")
    private String businessLicense;

    @Schema(description = "Tax ID", example = "TAX-67890")
    private String taxId;

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+855\\d{8,9}$")
    @Schema(description = "Phone number", example = "+85512345678")
    private String phoneNumber;

    @Email
    @Schema(description = "Email", example = "info@bluepumpkin.com")
    private String email;

    @Schema(description = "Description")
    private String description;

    // Address
    @Schema(description = "Address line 1", example = "123 Street 240")
    private String addressLine1;

    @Schema(description = "Address line 2")
    private String addressLine2;

    @Schema(description = "City", example = "Phnom Penh")
    private String city;

    @Schema(description = "Province", example = "Phnom Penh")
    private String province;

    @Schema(description = "Postal code")
    private String postalCode;

    @Schema(description = "Latitude", example = "11.5564")
    private BigDecimal latitude;

    @Schema(description = "Longitude", example = "104.9282")
    private BigDecimal longitude;

    // Bank details
    @Schema(description = "Bank name", example = "ABA Bank")
    private String bankName;

    @Schema(description = "Bank account number")
    private String bankAccountNumber;

    @Schema(description = "Bank account name")
    private String bankAccountName;
}






































