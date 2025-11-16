package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;

/**
 * Event published when a voucher is redeemed
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class RedemptionEvent extends BaseEvent {
    
    /**
     * Redemption ID
     */
    private Long redemptionId;
    
    /**
     * Wallet voucher ID
     */
    private Long walletVoucherId;
    
    /**
     * Voucher code
     */
    private String voucherCode;
    
    /**
     * Merchant ID where redemption occurred
     */
    private Long merchantId;
    
    /**
     * Merchant name
     */
    private String merchantName;
    
    /**
     * Consumer who redeemed
     */
    private Long consumerId;
    
    /**
     * Merchant staff who scanned
     */
    private Long scannedBy;
    
    /**
     * Amount redeemed
     */
    private BigDecimal redemptionAmount;
    
    /**
     * Redemption location/address
     */
    private String location;
    
    /**
     * Latitude
     */
    private Double latitude;
    
    /**
     * Longitude
     */
    private Double longitude;
    
    /**
     * Redemption method
     */
    private String redemptionMethod;
    
    /**
     * Transaction reference
     */
    private String transactionReference;

    // Event types
    public static final String REDEMPTION_INITIATED = "REDEMPTION_INITIATED";
    public static final String REDEMPTION_COMPLETED = "REDEMPTION_COMPLETED";
    public static final String REDEMPTION_FAILED = "REDEMPTION_FAILED";
    public static final String REDEMPTION_DISPUTED = "REDEMPTION_DISPUTED";

    /**
     * Create REDEMPTION_COMPLETED event
     */
    public static RedemptionEvent completed(Long redemptionId, Long walletVoucherId, String voucherCode,
                                           Long merchantId, String merchantName, Long consumerId,
                                           BigDecimal amount, String location) {
        RedemptionEvent event = RedemptionEvent.builder()
                .redemptionId(redemptionId)
                .walletVoucherId(walletVoucherId)
                .voucherCode(voucherCode)
                .merchantId(merchantId)
                .merchantName(merchantName)
                .consumerId(consumerId)
                .redemptionAmount(amount)
                .location(location)
                .redemptionMethod("QR_SCAN")
                .build();
        event.initDefaults(REDEMPTION_COMPLETED, "redemption-service");
        return event;
    }
}



















