package com.kado24.kafka.constants;

/**
 * Kafka topic names used across the Kado24 platform
 */
public final class KafkaTopics {
    
    private KafkaTopics() {
        throw new UnsupportedOperationException("Constants class");
    }

    /**
     * Order lifecycle events
     * Partitions: 3
     * Retention: 7 days
     */
    public static final String ORDER_EVENTS = "order-events";

    /**
     * Payment processing events
     * Partitions: 3
     * Retention: 30 days
     */
    public static final String PAYMENT_EVENTS = "payment-events";

    /**
     * Notification delivery events
     * Partitions: 5
     * Retention: 3 days
     */
    public static final String NOTIFICATION_EVENTS = "notification-events";

    /**
     * Voucher redemption events
     * Partitions: 3
     * Retention: 30 days
     */
    public static final String REDEMPTION_EVENTS = "redemption-events";

    /**
     * Analytics and tracking events
     * Partitions: 5
     * Retention: 90 days
     */
    public static final String ANALYTICS_EVENTS = "analytics-events";

    /**
     * Audit trail events
     * Partitions: 3
     * Retention: 365 days
     */
    public static final String AUDIT_EVENTS = "audit-events";

    /**
     * Get all topic names
     */
    public static String[] getAllTopics() {
        return new String[]{
                ORDER_EVENTS,
                PAYMENT_EVENTS,
                NOTIFICATION_EVENTS,
                REDEMPTION_EVENTS,
                ANALYTICS_EVENTS,
                AUDIT_EVENTS
        };
    }
}






































