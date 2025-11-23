package com.kado24.payout.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "payout_holds", schema = "payout_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayoutHold {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long merchantId;

    @Column(nullable = false, length = 200)
    private String reason;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private HoldStatus status = HoldStatus.ACTIVE;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime releasedAt;

    public enum HoldStatus {
        ACTIVE,
        RELEASED
    }

    public boolean isActive() {
        return this.status == HoldStatus.ACTIVE;
    }

    public void release() {
        this.status = HoldStatus.RELEASED;
        this.releasedAt = LocalDateTime.now();
    }
}























