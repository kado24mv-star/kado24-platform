package com.kado24.auth.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * Verification Request Entity
 * Stores OTP codes and verification status for admin support
 */
@Entity
@Table(name = "verification_requests", schema = "auth_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerificationRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "phone_number", nullable = false, length = 20)
    private String phoneNumber;

    @Column(name = "otp_code", nullable = false, length = 6)
    private String otpCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private VerificationStatus status = VerificationStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_method", nullable = false, length = 20)
    @Builder.Default
    private VerificationMethod verificationMethod = VerificationMethod.OTP;

    @Column(name = "requested_at", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime requestedAt;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @Column(name = "verified_by")
    private Long verifiedBy; // Admin user ID

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public enum VerificationStatus {
        PENDING,
        VERIFIED,
        REJECTED,
        EXPIRED
    }

    public enum VerificationMethod {
        OTP,      // User verifies via OTP
        MANUAL,   // Admin manually verifies
        AUTO      // System auto-verifies
    }

    /**
     * Check if verification request is expired
     */
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    /**
     * Check if verification request is still valid
     */
    public boolean isValid() {
        return status == VerificationStatus.PENDING && !isExpired();
    }
}

