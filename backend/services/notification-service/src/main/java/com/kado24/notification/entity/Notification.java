package com.kado24.notification.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications", schema = "notification_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false, length = 50)
    private String notificationType;

    @Column(length = 20)
    private String channel;  // EMAIL, SMS, PUSH, IN_APP

    @Column(nullable = false)
    private String recipient;

    private String subject;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    private String templateName;

    @Column(columnDefinition = "jsonb")
    private String templateData;

    @Column(length = 20)
    private String status;  // PENDING, SENT, FAILED, DELIVERED, READ

    private LocalDateTime sentAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime readAt;

    @Column(columnDefinition = "TEXT")
    private String failureReason;

    private String provider;
    private String providerMessageId;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}













