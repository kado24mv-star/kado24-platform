package com.kado24.wallet.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.kado24.wallet.entity.WalletVoucher.VoucherStatus;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletVoucherDTO {
    private Long id;
    private String voucherCode;
    private String qrCodeUrl;
    private Long voucherId;
    private String voucherTitle;
    private Long merchantId;
    private String merchantName;
    private BigDecimal denomination;
    private BigDecimal voucherValue;
    private BigDecimal remainingValue;
    private VoucherStatus status;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime validFrom;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime validUntil;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime purchasedAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime redeemedAt;
    
    private Boolean isValid;
    private Boolean isGift;
    private Long giftedToUserId;
    private String giftMessage;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime giftedAt;
}








