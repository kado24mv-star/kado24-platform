package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.util.Map;

/**
 * Event published for analytics and reporting
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class AnalyticsEvent extends BaseEvent {
    
    /**
     * User ID (if applicable)
     */
    private Long userId;
    
    /**
     * Merchant ID (if applicable)
     */
    private Long merchantId;
    
    /**
     * Voucher ID (if applicable)
     */
    private Long voucherId;
    
    /**
     * Action performed
     */
    private String action;
    
    /**
     * Category of the action
     */
    private String category;
    
    /**
     * Monetary value (if applicable)
     */
    private BigDecimal value;
    
    /**
     * Additional properties
     */
    private Map<String, Object> properties;
    
    /**
     * Session ID
     */
    private String sessionId;
    
    /**
     * Device type
     */
    private String deviceType;
    
    /**
     * IP address
     */
    private String ipAddress;

    // Event types
    public static final String VOUCHER_VIEWED = "VOUCHER_VIEWED";
    public static final String VOUCHER_SEARCHED = "VOUCHER_SEARCHED";
    public static final String VOUCHER_PURCHASED = "VOUCHER_PURCHASED";
    public static final String VOUCHER_REDEEMED = "VOUCHER_REDEEMED";
    public static final String USER_REGISTERED = "USER_REGISTERED";
    public static final String USER_LOGIN = "USER_LOGIN";
    public static final String MERCHANT_REGISTERED = "MERCHANT_REGISTERED";

    /**
     * Create VOUCHER_VIEWED event
     */
    public static AnalyticsEvent voucherViewed(Long voucherId, Long userId) {
        AnalyticsEvent event = AnalyticsEvent.builder()
                .voucherId(voucherId)
                .userId(userId)
                .action("VIEW")
                .category("VOUCHER")
                .build();
        event.initDefaults(VOUCHER_VIEWED, "voucher-service");
        return event;
    }

    /**
     * Create VOUCHER_PURCHASED event
     */
    public static AnalyticsEvent voucherPurchased(Long voucherId, Long userId, Long merchantId, 
                                                  BigDecimal amount) {
        AnalyticsEvent event = AnalyticsEvent.builder()
                .voucherId(voucherId)
                .userId(userId)
                .merchantId(merchantId)
                .action("PURCHASE")
                .category("VOUCHER")
                .value(amount)
                .build();
        event.initDefaults(VOUCHER_PURCHASED, "order-service");
        return event;
    }
}






































