package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;

/**
 * Event published when payment-related actions occur
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class PaymentEvent extends BaseEvent {
    
    /**
     * Order ID associated with this payment
     */
    private Long orderId;
    
    /**
     * External payment gateway transaction ID
     */
    private String paymentId;
    
    /**
     * Payment method used
     */
    private String paymentMethod;
    
    /**
     * Payment amount
     */
    private BigDecimal amount;
    
    /**
     * Currency code
     */
    private String currency;
    
    /**
     * Payment status
     */
    private String status;
    
    /**
     * Payment gateway response
     */
    private String gatewayResponse;
    
    /**
     * Failure reason (if failed)
     */
    private String failureReason;
    
    /**
     * User ID who initiated payment
     */
    private Long userId;

    // Event types
    public static final String PAYMENT_INITIATED = "PAYMENT_INITIATED";
    public static final String PAYMENT_PROCESSING = "PAYMENT_PROCESSING";
    public static final String PAYMENT_SUCCESS = "PAYMENT_SUCCESS";
    public static final String PAYMENT_FAILED = "PAYMENT_FAILED";
    public static final String PAYMENT_REFUNDED = "PAYMENT_REFUNDED";
    public static final String PAYMENT_CANCELLED = "PAYMENT_CANCELLED";

    /**
     * Create PAYMENT_INITIATED event
     */
    public static PaymentEvent initiated(Long orderId, String paymentId, String paymentMethod, 
                                        BigDecimal amount, String currency, Long userId) {
        PaymentEvent event = PaymentEvent.builder()
                .orderId(orderId)
                .paymentId(paymentId)
                .paymentMethod(paymentMethod)
                .amount(amount)
                .currency(currency)
                .status("INITIATED")
                .userId(userId)
                .build();
        event.initDefaults(PAYMENT_INITIATED, "payment-service");
        return event;
    }

    /**
     * Create PAYMENT_SUCCESS event
     */
    public static PaymentEvent success(Long orderId, String paymentId, BigDecimal amount, 
                                      String gatewayResponse) {
        PaymentEvent event = PaymentEvent.builder()
                .orderId(orderId)
                .paymentId(paymentId)
                .amount(amount)
                .status("COMPLETED")
                .gatewayResponse(gatewayResponse)
                .build();
        event.initDefaults(PAYMENT_SUCCESS, "payment-service");
        return event;
    }

    /**
     * Create PAYMENT_FAILED event
     */
    public static PaymentEvent failed(Long orderId, String paymentId, String failureReason) {
        PaymentEvent event = PaymentEvent.builder()
                .orderId(orderId)
                .paymentId(paymentId)
                .status("FAILED")
                .failureReason(failureReason)
                .build();
        event.initDefaults(PAYMENT_FAILED, "payment-service");
        return event;
    }
}






































