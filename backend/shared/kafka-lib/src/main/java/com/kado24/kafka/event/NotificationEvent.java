package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Event published when a notification needs to be sent
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class NotificationEvent extends BaseEvent {
    
    /**
     * Target user ID
     */
    private Long userId;
    
    /**
     * Notification type
     */
    private String notificationType;
    
    /**
     * Notification title
     */
    private String title;
    
    /**
     * Notification message/body
     */
    private String message;
    
    /**
     * Additional data for the notification
     */
    private Map<String, Object> data;
    
    /**
     * Delivery channels (PUSH, EMAIL, SMS)
     */
    private List<String> channels;
    
    /**
     * Priority level
     */
    private String priority;
    
    /**
     * Related entity type (ORDER, VOUCHER, PAYOUT)
     */
    private String entityType;
    
    /**
     * Related entity ID
     */
    private Long entityId;

    // Notification types
    public static final String ORDER_CONFIRMED = "ORDER_CONFIRMED";
    public static final String PAYMENT_SUCCESS = "PAYMENT_SUCCESS";
    public static final String PAYMENT_FAILED = "PAYMENT_FAILED";
    public static final String VOUCHER_PURCHASED = "VOUCHER_PURCHASED";
    public static final String VOUCHER_REDEEMED = "VOUCHER_REDEEMED";
    public static final String VOUCHER_EXPIRING = "VOUCHER_EXPIRING";
    public static final String PAYOUT_PROCESSED = "PAYOUT_PROCESSED";
    public static final String VOUCHER_GIFTED = "VOUCHER_GIFTED";
    public static final String MERCHANT_APPROVED = "MERCHANT_APPROVED";
    public static final String MERCHANT_REJECTED = "MERCHANT_REJECTED";

    /**
     * Create ORDER_CONFIRMED notification
     */
    public static NotificationEvent orderConfirmed(Long userId, String orderNumber, String voucherTitle) {
        NotificationEvent event = NotificationEvent.builder()
                .userId(userId)
                .notificationType(ORDER_CONFIRMED)
                .title("Order Confirmed! 🎉")
                .message(String.format("Your order %s for %s has been confirmed!", orderNumber, voucherTitle))
                .channels(List.of("PUSH", "EMAIL"))
                .priority("HIGH")
                .build();
        event.initDefaults(ORDER_CONFIRMED, "order-service");
        return event;
    }

    /**
     * Create VOUCHER_REDEEMED notification
     */
    public static NotificationEvent voucherRedeemed(Long userId, String voucherCode, String merchantName) {
        NotificationEvent event = NotificationEvent.builder()
                .userId(userId)
                .notificationType(VOUCHER_REDEEMED)
                .title("Voucher Redeemed Successfully ✅")
                .message(String.format("Your voucher %s was redeemed at %s", voucherCode, merchantName))
                .channels(List.of("PUSH", "EMAIL"))
                .priority("MEDIUM")
                .build();
        event.initDefaults(VOUCHER_REDEEMED, "redemption-service");
        return event;
    }

    /**
     * Create PAYOUT_PROCESSED notification
     */
    public static NotificationEvent payoutProcessed(Long userId, String payoutNumber, BigDecimal amount) {
        NotificationEvent event = NotificationEvent.builder()
                .userId(userId)
                .notificationType(PAYOUT_PROCESSED)
                .title("Payout Processed 💰")
                .message(String.format("Your payout %s of $%.2f has been processed", payoutNumber, amount))
                .channels(List.of("PUSH", "EMAIL", "SMS"))
                .priority("HIGH")
                .build();
        event.initDefaults(PAYOUT_PROCESSED, "payout-service");
        return event;
    }
}

