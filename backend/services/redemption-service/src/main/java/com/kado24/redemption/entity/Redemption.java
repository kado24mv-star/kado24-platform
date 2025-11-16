package com.kado24.redemption.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "redemptions", schema = "redemption_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Redemption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "redemption_code", nullable = false, unique = true, length = 50)
    private String redemptionCode;

    @Column(nullable = false)
    private Long walletVoucherId;

    @Column(name = "user_id", nullable = false)
    private Long redeemedByUserId;

    @Column(nullable = false)
    private Long merchantId;

    @Column(name = "voucher_id", nullable = false)
    private Long voucherId;

    private Long scannedByUserId;

    @Column(name = "redemption_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal redemptionAmount;

    @Column(name = "redeemed_value", precision = 10, scale = 2)
    private BigDecimal redeemedValue;

    @Column(length = 100)
    private String transactionReference;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RedemptionMethod redemptionMethod = RedemptionMethod.QR_SCAN;

    private String redemptionLocation;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RedemptionStatus status = RedemptionStatus.CONFIRMED;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(nullable = false)
    private LocalDateTime redeemedAt;

    public enum RedemptionMethod {
        QR_SCAN, PIN_CODE, MANUAL
    }

    public enum RedemptionStatus {
        PENDING, CONFIRMED, CANCELLED, DISPUTED
    }
}







