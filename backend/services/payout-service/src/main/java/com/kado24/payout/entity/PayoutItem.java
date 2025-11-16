package com.kado24.payout.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payout_items", schema = "payout_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PayoutItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long payoutId;

    @Column(nullable = false)
    private Long redemptionId;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal voucherValue;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal commission;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal merchantAmount;

    @Column(nullable = false)
    private LocalDateTime redemptionDate;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}













