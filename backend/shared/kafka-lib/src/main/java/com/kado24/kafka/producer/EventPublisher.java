package com.kado24.kafka.producer;

import com.kado24.kafka.event.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * Central event publisher for all Kafka events
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    // Topic names
    private static final String TOPIC_ORDER_EVENTS = "order-events";
    private static final String TOPIC_PAYMENT_EVENTS = "payment-events";
    private static final String TOPIC_NOTIFICATION_EVENTS = "notification-events";
    private static final String TOPIC_REDEMPTION_EVENTS = "redemption-events";
    private static final String TOPIC_ANALYTICS_EVENTS = "analytics-events";
    private static final String TOPIC_AUDIT_EVENTS = "audit-events";

    /**
     * Publish order event
     */
    public void publishOrderEvent(OrderEvent event) {
        publish(TOPIC_ORDER_EVENTS, event.getOrderNumber(), event);
        log.info("Published order event: {} for order: {}", event.getEventType(), event.getOrderNumber());
    }

    /**
     * Publish payment event
     */
    public void publishPaymentEvent(PaymentEvent event) {
        publish(TOPIC_PAYMENT_EVENTS, event.getPaymentId(), event);
        log.info("Published payment event: {} for payment: {}", event.getEventType(), event.getPaymentId());
    }

    /**
     * Publish notification event
     */
    public void publishNotificationEvent(NotificationEvent event) {
        publish(TOPIC_NOTIFICATION_EVENTS, event.getUserId().toString(), event);
        log.info("Published notification event: {} for user: {}", event.getNotificationType(), event.getUserId());
    }

    /**
     * Publish redemption event
     */
    public void publishRedemptionEvent(RedemptionEvent event) {
        publish(TOPIC_REDEMPTION_EVENTS, event.getVoucherCode(), event);
        log.info("Published redemption event: {} for voucher: {}", event.getEventType(), event.getVoucherCode());
    }

    /**
     * Publish analytics event
     */
    public void publishAnalyticsEvent(AnalyticsEvent event) {
        publish(TOPIC_ANALYTICS_EVENTS, event.getEventId(), event);
        log.debug("Published analytics event: {} - action: {}", event.getEventType(), event.getAction());
    }

    /**
     * Publish audit event
     */
    public void publishAuditEvent(AuditEvent event) {
        publish(TOPIC_AUDIT_EVENTS, event.getEventId(), event);
        log.info("Published audit event: {} by user: {} on {}", 
                event.getAction(), event.getUserId(), event.getEntityType());
    }

    /**
     * Generic publish method with callback
     */
    private void publish(String topic, String key, Object event) {
        CompletableFuture<SendResult<String, Object>> future = kafkaTemplate.send(topic, key, event);
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                log.debug("Event sent successfully to topic: {} with offset: {}", 
                        topic, result.getRecordMetadata().offset());
            } else {
                log.error("Failed to send event to topic: {}", topic, ex);
            }
        });
    }

    /**
     * Synchronous publish (waits for acknowledgment)
     */
    public void publishSync(String topic, String key, Object event) {
        try {
            SendResult<String, Object> result = kafkaTemplate.send(topic, key, event).get();
            log.info("Event sent synchronously to topic: {} with offset: {}", 
                    topic, result.getRecordMetadata().offset());
        } catch (Exception e) {
            log.error("Failed to send event synchronously to topic: {}", topic, e);
            throw new RuntimeException("Event publishing failed", e);
        }
    }
}






































