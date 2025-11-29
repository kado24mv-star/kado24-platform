package com.kado24.auth.service;

import com.kado24.auth.dto.VerificationRequestDTO;
import com.kado24.auth.entity.User;
import com.kado24.auth.entity.VerificationRequest;
import com.kado24.auth.repository.UserRepository;
import com.kado24.auth.repository.VerificationRequestRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Service for managing verification requests
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VerificationRequestService {

    private final VerificationRequestRepository verificationRequestRepository;
    private final UserRepository userRepository;
    private static final int OTP_EXPIRATION_MINUTES = 5;

    /**
     * Create verification request with OTP
     * Uses default transaction propagation to be part of the parent transaction
     * This ensures the user exists before creating the verification request
     */
    @Transactional
    public VerificationRequest createVerificationRequest(Long userId, String phoneNumber, String otpCode) {
        log.info("Creating verification request for user: {}, phone: {}, OTP: {}", userId, phoneNumber, otpCode);

        // Invalidate any existing pending requests for this user
        Optional<VerificationRequest> existing = verificationRequestRepository.findByUserId(userId);
        if (existing.isPresent() && existing.get().getStatus() == VerificationRequest.VerificationStatus.PENDING) {
            VerificationRequest existingReq = existing.get();
            log.info("Invalidating existing verification request ID: {} for user: {}", existingReq.getId(), userId);
            existingReq.setStatus(VerificationRequest.VerificationStatus.EXPIRED);
            verificationRequestRepository.save(existingReq);
        }

        VerificationRequest request = VerificationRequest.builder()
                .userId(userId)
                .phoneNumber(phoneNumber)
                .otpCode(otpCode)
                .status(VerificationRequest.VerificationStatus.PENDING)
                .verificationMethod(VerificationRequest.VerificationMethod.OTP)
                .expiresAt(LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES))
                .build();

        VerificationRequest saved = verificationRequestRepository.save(request);
        // Flush to ensure it's persisted immediately
        verificationRequestRepository.flush();
        
        log.info("Verification request created successfully. ID: {}, User ID: {}, Phone: {}, OTP: {}, Expires at: {}", 
                saved.getId(), saved.getUserId(), saved.getPhoneNumber(), saved.getOtpCode(), saved.getExpiresAt());
        
        return saved;
    }

    /**
     * Get verification request by user ID
     */
    public Optional<VerificationRequest> getByUserId(Long userId) {
        return verificationRequestRepository.findByUserId(userId);
    }

    /**
     * Get verification request by phone number
     */
    public Optional<VerificationRequest> getByPhoneNumber(String phoneNumber) {
        return verificationRequestRepository.findByPhoneNumberAndStatus(
                phoneNumber,
                VerificationRequest.VerificationStatus.PENDING
        );
    }

    /**
     * Get all pending verification requests (for admin)
     */
    public Page<VerificationRequest> getPendingVerifications(Pageable pageable) {
        return verificationRequestRepository.findByStatusOrderByCreatedAtDesc(
                VerificationRequest.VerificationStatus.PENDING,
                pageable
        );
    }

    /**
     * Verify user account manually (admin action)
     */
    @Transactional
    public VerificationRequest verifyManually(Long verificationRequestId, Long adminUserId, String notes) {
        log.info("Admin {} manually verifying request {}", adminUserId, verificationRequestId);

        VerificationRequest request = verificationRequestRepository.findById(verificationRequestId)
                .orElseThrow(() -> new RuntimeException("Verification request not found"));

        if (request.getStatus() != VerificationRequest.VerificationStatus.PENDING) {
            throw new RuntimeException("Verification request is not pending");
        }

        // Update verification request
        request.setStatus(VerificationRequest.VerificationStatus.VERIFIED);
        request.setVerifiedAt(LocalDateTime.now());
        request.setVerifiedBy(adminUserId);
        request.setVerificationMethod(VerificationRequest.VerificationMethod.MANUAL);
        request.setNotes(notes);

        // Activate user account
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setStatus(User.UserStatus.ACTIVE);
        user.setPhoneVerified(true);
        userRepository.save(user);

        log.info("User {} verified manually by admin {}", request.getUserId(), adminUserId);

        return verificationRequestRepository.save(request);
    }

    /**
     * Reject verification request (admin action)
     */
    @Transactional
    public VerificationRequest rejectVerification(Long verificationRequestId, Long adminUserId, String notes) {
        log.info("Admin {} rejecting verification request {}", adminUserId, verificationRequestId);

        VerificationRequest request = verificationRequestRepository.findById(verificationRequestId)
                .orElseThrow(() -> new RuntimeException("Verification request not found"));

        request.setStatus(VerificationRequest.VerificationStatus.REJECTED);
        request.setVerifiedAt(LocalDateTime.now());
        request.setVerifiedBy(adminUserId);
        request.setNotes(notes);

        return verificationRequestRepository.save(request);
    }

    /**
     * Mark expired verification requests
     */
    @Transactional
    public void markExpiredVerifications() {
        log.info("Marking expired verification requests");
        Page<VerificationRequest> expired = verificationRequestRepository.findExpiredVerifications(
                LocalDateTime.now(),
                org.springframework.data.domain.PageRequest.of(0, 100)
        );

        expired.forEach(request -> {
            request.setStatus(VerificationRequest.VerificationStatus.EXPIRED);
            verificationRequestRepository.save(request);
        });

        log.info("Marked {} verification requests as expired", expired.getTotalElements());
    }

    /**
     * Count pending verifications
     */
    public long countPendingVerifications() {
        return verificationRequestRepository.countByStatus(VerificationRequest.VerificationStatus.PENDING);
    }
}

