package com.kado24.analytics.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_metrics", schema = "analytics_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyMetric {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private LocalDate metricDate;

    private Integer totalUsers;
    private Integer newUsers;
    private Integer activeUsers;
    private Integer totalMerchants;
    private Integer newMerchants;
    private Integer activeMerchants;
    private Integer totalOrders;

    @Column(precision = 15, scale = 2)
    private BigDecimal totalRevenue;

    @Column(precision = 15, scale = 2)
    private BigDecimal totalCommission;

    private Integer totalRedemptions;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
































