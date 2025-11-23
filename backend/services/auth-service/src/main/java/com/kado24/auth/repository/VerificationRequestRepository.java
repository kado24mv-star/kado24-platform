package com.kado24.auth.repository;

import com.kado24.auth.entity.VerificationRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Repository for VerificationRequest entity
 */
@Repository
public interface VerificationRequestRepository extends JpaRepository<VerificationRequest, Long> {

    /**
     * Find verification request by user ID
     */
    Optional<VerificationRequest> findByUserId(Long userId);

    /**
     * Find verification request by phone number and status
     */
    Optional<VerificationRequest> findByPhoneNumberAndStatus(String phoneNumber, VerificationRequest.VerificationStatus status);

    /**
     * Find pending verification requests
     */
    Page<VerificationRequest> findByStatus(VerificationRequest.VerificationStatus status, Pageable pageable);

    /**
     * Find pending verification requests ordered by creation date
     */
    Page<VerificationRequest> findByStatusOrderByCreatedAtDesc(
            VerificationRequest.VerificationStatus status,
            Pageable pageable
    );

    /**
     * Find expired verification requests
     */
    @Query("SELECT v FROM VerificationRequest v WHERE v.status = 'PENDING' AND v.expiresAt < :now")
    Page<VerificationRequest> findExpiredVerifications(@Param("now") LocalDateTime now, Pageable pageable);

    /**
     * Count pending verifications
     */
    long countByStatus(VerificationRequest.VerificationStatus status);
}

