package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;

/**
 * Event published when order-related actions occur
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class OrderEvent extends BaseEvent {
    
    /**
     * Order database ID
     */
    private Long orderId;
    
    /**
     * Unique order number
     */
    private String orderNumber;
    
    /**
     * User who created the order
     */
    private Long userId;
    
    /**
     * Voucher being purchased
     */
    private Long voucherId;
    
    /**
     * Merchant who owns the voucher
     */
    private Long merchantId;
    
    /**
     * Order quantity
     */
    private Integer quantity;
    
    /**
     * Total order amount
     */
    private BigDecimal totalAmount;
    
    /**
     * Platform commission (8%)
     */
    private BigDecimal platformFee;
    
    /**
     * Merchant payout amount (92%)
     */
    private BigDecimal merchantAmount;
    
    /**
     * Payment method used
     */
    private String paymentMethod;
    
    /**
     * Current payment status
     */
    private String paymentStatus;
    
    /**
     * Current order status
     */
    private String orderStatus;

    // Event types
    public static final String ORDER_CREATED = "ORDER_CREATED";
    public static final String ORDER_CONFIRMED = "ORDER_CONFIRMED";
    public static final String ORDER_CANCELLED = "ORDER_CANCELLED";
    public static final String ORDER_REFUNDED = "ORDER_REFUNDED";
    public static final String PAYMENT_COMPLETED = "PAYMENT_COMPLETED";
    public static final String PAYMENT_FAILED = "PAYMENT_FAILED";

    /**
     * Create ORDER_CREATED event
     */
    public static OrderEvent created(Long orderId, String orderNumber, Long userId, Long voucherId, 
                                    Long merchantId, Integer quantity, BigDecimal totalAmount,
                                    BigDecimal platformFee, BigDecimal merchantAmount) {
        OrderEvent event = OrderEvent.builder()
                .orderId(orderId)
                .orderNumber(orderNumber)
                .userId(userId)
                .voucherId(voucherId)
                .merchantId(merchantId)
                .quantity(quantity)
                .totalAmount(totalAmount)
                .platformFee(platformFee)
                .merchantAmount(merchantAmount)
                .orderStatus("PENDING")
                .paymentStatus("PENDING")
                .build();
        event.initDefaults(ORDER_CREATED, "order-service");
        return event;
    }

    /**
     * Create ORDER_CONFIRMED event
     */
    public static OrderEvent confirmed(Long orderId, String orderNumber, String paymentMethod) {
        OrderEvent event = OrderEvent.builder()
                .orderId(orderId)
                .orderNumber(orderNumber)
                .paymentMethod(paymentMethod)
                .orderStatus("CONFIRMED")
                .paymentStatus("COMPLETED")
                .build();
        event.initDefaults(ORDER_CONFIRMED, "order-service");
        return event;
    }
}






































