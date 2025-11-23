package com.kado24.merchant.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "merchant_locations", schema = "merchant_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MerchantLocation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long merchantId;

    @Column(nullable = false)
    private String locationName;

    @Column(nullable = false)
    private String addressLine1;

    private String city;

    private String phoneNumber;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    private Boolean isPrimary;

    @Column(columnDefinition = "jsonb")
    private String operatingHours;

    private Boolean isActive;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
































