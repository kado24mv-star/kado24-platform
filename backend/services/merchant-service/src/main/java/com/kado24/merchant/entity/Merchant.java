package com.kado24.merchant.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Merchant entity
 */
@Entity
@Table(name = "merchants", schema = "merchant_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Merchant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    @Column(nullable = false)
    private String businessName;

    private String businessType;
    private String businessLicense;
    private String taxId;

    @Column(nullable = false)
    private String phoneNumber;

    private String email;
    private String logoUrl;
    private String bannerUrl;

    @Column(columnDefinition = "TEXT")
    private String description;

    // Address fields
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String province;
    private String postalCode;
    
    @Builder.Default
    @Column(length = 2)
    private String country = "KH";

    // Geolocation
    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    // Bank details
    private String bankName;
    private String bankAccountNumber;
    private String bankAccountName;

    // Verification
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private VerificationStatus verificationStatus = VerificationStatus.PENDING;

    private LocalDateTime verifiedAt;
    private Long verifiedBy;

    @Column(columnDefinition = "TEXT")
    private String rejectionReason;

    // Metrics
    @Builder.Default
    @Column(precision = 3, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;

    @Builder.Default
    private Integer totalReviews = 0;

    @Builder.Default
    private Integer totalVouchersSold = 0;

    @Builder.Default
    @Column(precision = 15, scale = 2)
    private BigDecimal totalRevenue = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb", nullable = true)
    private String metadata;

    public enum VerificationStatus {
        PENDING,
        APPROVED,
        REJECTED,
        SUSPENDED
    }

    /**
     * Approve merchant
     */
    public void approve(Long adminId) {
        this.verificationStatus = VerificationStatus.APPROVED;
        this.verifiedAt = LocalDateTime.now();
        this.verifiedBy = adminId;
        this.rejectionReason = null;
    }

    /**
     * Reject merchant
     */
    public void reject(Long adminId, String reason) {
        this.verificationStatus = VerificationStatus.REJECTED;
        this.verifiedAt = LocalDateTime.now();
        this.verifiedBy = adminId;
        this.rejectionReason = reason;
    }

    /**
     * Suspend merchant
     */
    public void suspend(String reason) {
        this.verificationStatus = VerificationStatus.SUSPENDED;
        this.rejectionReason = reason;
    }

    /**
     * Check if approved
     */
    public boolean isApproved() {
        return this.verificationStatus == VerificationStatus.APPROVED;
    }
}







