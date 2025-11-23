package com.kado24.user.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * User Address entity
 */
@Entity
@Table(name = "user_addresses", schema = "user_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(length = 20)
    private String addressType;  // HOME, WORK, OTHER

    @Column(nullable = false)
    private String addressLine1;

    private String addressLine2;

    @Column(length = 100)
    private String city;

    @Column(length = 100)
    private String province;

    @Column(length = 20)
    private String postalCode;

    @Column(length = 100)
    private String country;

    private Boolean isDefault;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
































