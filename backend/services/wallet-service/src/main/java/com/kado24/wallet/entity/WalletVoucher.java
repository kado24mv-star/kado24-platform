package com.kado24.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallet_vouchers", schema = "wallet_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletVoucher {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String voucherCode;

    @Lob
    @Column(name = "qr_code_data", nullable = false, columnDefinition = "TEXT")
    private String qrCodeUrl;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long voucherId;

    @Column(nullable = false)
    private Long orderId;

    @Column(nullable = false)
    private Long merchantId;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal denomination;

    @Column(name = "voucher_value", nullable = false, precision = 10, scale = 2)
    private BigDecimal voucherValue;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal remainingValue;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private VoucherStatus status = VoucherStatus.ACTIVE;

    @CreationTimestamp
    @Column(nullable = false)
    private LocalDateTime purchasedAt;

    @Column(name = "valid_from", nullable = false)
    private LocalDateTime validFrom;

    @Column(name = "valid_until", nullable = false)
    private LocalDateTime validUntil;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    private LocalDateTime redeemedAt;
    private String redemptionLocation;

    @Builder.Default
    private Boolean isGift = false;

    private Long giftedToUserId;
    private String giftMessage;
    private LocalDateTime giftedAt;

    @Column(length = 10)
    private String pinCode;

    public enum VoucherStatus {
        ACTIVE, USED, EXPIRED, CANCELLED, GIFTED
    }

    public void redeem(String location) {
        this.status = VoucherStatus.USED;
        this.redeemedAt = LocalDateTime.now();
        this.redemptionLocation = location;
        this.remainingValue = BigDecimal.ZERO;
    }

    public boolean isValid() {
        return this.status == VoucherStatus.ACTIVE 
                && LocalDateTime.now().isBefore(this.validUntil)
                && this.remainingValue.compareTo(BigDecimal.ZERO) > 0;
    }
}







