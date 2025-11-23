package com.kado24.notification.consumer;

import com.kado24.kafka.event.NotificationEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationEventConsumer {

    @KafkaListener(topics = "notification-events", groupId = "notification-service-group")
    public void consumeNotificationEvent(NotificationEvent event) {
        log.info("Received notification event for user: {}", event.getUserId());
        
        try {
            // Send via requested channels
            if (event.getChannels().contains("PUSH")) {
                sendPushNotification(event);
            }
            if (event.getChannels().contains("EMAIL")) {
                sendEmailNotification(event);
            }
            if (event.getChannels().contains("SMS")) {
                sendSMSNotification(event);
            }
            
            log.info("Notification sent successfully: {}", event.getNotificationType());
        } catch (Exception e) {
            log.error("Failed to send notification", e);
        }
    }

    private void sendPushNotification(NotificationEvent event) {
        // TODO: Firebase FCM integration
        log.info("PUSH notification sent to user {}: {}", event.getUserId(), event.getTitle());
    }

    private void sendEmailNotification(NotificationEvent event) {
        // TODO: SendGrid or SMTP integration
        log.info("EMAIL notification sent to user {}: {}", event.getUserId(), event.getTitle());
    }

    private void sendSMSNotification(NotificationEvent event) {
        // TODO: SMS gateway integration
        log.info("SMS notification sent to user {}: {}", event.getUserId(), event.getMessage());
    }
}






































