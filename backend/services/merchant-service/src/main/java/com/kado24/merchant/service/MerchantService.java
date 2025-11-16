package com.kado24.merchant.service;

import com.kado24.common.exception.BusinessException;
import com.kado24.common.exception.ConflictException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.kafka.event.NotificationEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.merchant.client.PayoutClient;
import com.kado24.merchant.dto.MerchantDTO;
import com.kado24.merchant.dto.RegisterMerchantRequest;
import com.kado24.merchant.entity.Merchant;
import com.kado24.merchant.mapper.MerchantMapper;
import com.kado24.merchant.repository.MerchantRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

/**
 * Merchant management service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MerchantService {

    private final MerchantRepository merchantRepository;
    private final MerchantMapper merchantMapper;
    private final EventPublisher eventPublisher;
    private final PayoutClient payoutClient;

    /**
     * Register merchant (creates merchant profile for existing user)
     */
    @Transactional
    public MerchantDTO registerMerchant(Long userId, RegisterMerchantRequest request) {
        log.info("Registering merchant for user: {}", userId);

        // Check if merchant already exists for this user
        if (merchantRepository.existsByUserId(userId)) {
            throw new ConflictException("Merchant profile already exists for this user");
        }

        // Create merchant entity
        Merchant merchant = Merchant.builder()
                .userId(userId)
                .businessName(request.getBusinessName())
                .businessType(request.getBusinessType())
                .businessLicense(request.getBusinessLicense())
                .taxId(request.getTaxId())
                .phoneNumber(request.getPhoneNumber())
                .email(request.getEmail())
                .description(request.getDescription())
                .addressLine1(request.getAddressLine1())
                .addressLine2(request.getAddressLine2())
                .city(request.getCity())
                .province(request.getProvince())
                .postalCode(request.getPostalCode())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .bankName(request.getBankName())
                .bankAccountNumber(request.getBankAccountNumber())
                .bankAccountName(request.getBankAccountName())
                .verificationStatus(Merchant.VerificationStatus.PENDING)
                .build();

        merchant = merchantRepository.save(merchant);

        log.info("Merchant registered with ID: {} - Pending verification", merchant.getId());

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Get merchant by ID
     */
    public MerchantDTO getMerchant(Long merchantId) {
        log.debug("Fetching merchant: {}", merchantId);

        Merchant merchant = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Get merchant by user ID
     */
    public MerchantDTO getMerchantByUserId(Long userId) {
        log.debug("Fetching merchant for user: {}", userId);

        Merchant merchant = merchantRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant not found for user", userId.toString()));

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Get pending merchants (admin only)
     */
    public Page<MerchantDTO> getPendingMerchants(Pageable pageable) {
        log.debug("Fetching pending merchants");

        Page<Merchant> merchants = merchantRepository.findByVerificationStatus(
                Merchant.VerificationStatus.PENDING, pageable);

        return merchants.map(merchantMapper::toDTO);
    }

    /**
     * Approve merchant (admin only)
     */
    @Transactional
    public MerchantDTO approveMerchant(Long merchantId, Long adminId) {
        log.info("Approving merchant: {} by admin: {}", merchantId, adminId);

        Merchant merchant = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));

        if (merchant.getVerificationStatus() != Merchant.VerificationStatus.PENDING) {
            throw new BusinessException("Merchant is not in pending status");
        }

        merchant.approve(adminId);
        merchant = merchantRepository.save(merchant);

        // Send approval notification
        publishMerchantApprovedNotification(merchant);

        log.info("Merchant approved: {}", merchantId);

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Reject merchant (admin only)
     */
    @Transactional
    public MerchantDTO rejectMerchant(Long merchantId, Long adminId, String reason) {
        log.info("Rejecting merchant: {} by admin: {}", merchantId, adminId);

        Merchant merchant = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));

        merchant.reject(adminId, reason);
        merchant = merchantRepository.save(merchant);

        // Send rejection notification
        publishMerchantRejectedNotification(merchant, reason);

        log.info("Merchant rejected: {}", merchantId);

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Suspend merchant (admin only)
     */
    @Transactional
    public MerchantDTO suspendMerchant(Long merchantId, Long adminId, String reason) {
        log.info("Suspending merchant: {} by admin: {}", merchantId, adminId);

        Merchant merchant = merchantRepository.findById(merchantId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", merchantId));

        if (merchant.getVerificationStatus() == Merchant.VerificationStatus.SUSPENDED) {
            throw new BusinessException("Merchant already suspended");
        }

        merchant.suspend(reason);
        merchant.setVerifiedBy(adminId);
        merchant.setVerifiedAt(java.time.LocalDateTime.now());
        merchant = merchantRepository.save(merchant);

        try {
            payoutClient.createHold(merchantId, reason);
        } catch (Exception ex) {
            log.warn("Failed to notify payout service about merchant suspension: {}", ex.getMessage());
        }

        log.info("Merchant suspended: {}", merchantId);

        return merchantMapper.toDTO(merchant);
    }

    /**
     * Get merchant statistics (admin)
     */
    public Map<String, Long> getMerchantStatistics() {
        Map<String, Long> stats = new HashMap<>();

        stats.put("total", merchantRepository.count());
        stats.put("pending", merchantRepository.countByVerificationStatus(Merchant.VerificationStatus.PENDING));
        stats.put("approved", merchantRepository.countByVerificationStatus(Merchant.VerificationStatus.APPROVED));
        stats.put("rejected", merchantRepository.countByVerificationStatus(Merchant.VerificationStatus.REJECTED));
        stats.put("suspended", merchantRepository.countByVerificationStatus(Merchant.VerificationStatus.SUSPENDED));

        return stats;
    }

    /**
     * Get my merchant statistics
     */
    public Map<String, Object> getMyMerchantStatistics(Long userId) {
        Merchant merchant = merchantRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Merchant", userId));

        Map<String, Object> stats = new HashMap<>();
        stats.put("merchantId", merchant.getId());
        stats.put("businessName", merchant.getBusinessName());
        stats.put("verificationStatus", merchant.getVerificationStatus().name());
        stats.put("rating", merchant.getRating());
        stats.put("totalReviews", merchant.getTotalReviews());
        stats.put("totalVouchersSold", merchant.getTotalVouchersSold());
        stats.put("totalRevenue", merchant.getTotalRevenue());

        return stats;
    }

    /**
     * Publish merchant approved notification
     */
    private void publishMerchantApprovedNotification(Merchant merchant) {
        try {
            NotificationEvent event = NotificationEvent.builder()
                    .userId(merchant.getUserId())
                    .notificationType(NotificationEvent.MERCHANT_APPROVED)
                    .title("Merchant Application Approved! 🎉")
                    .message(String.format("Your business '%s' has been approved! You can now create vouchers.", 
                            merchant.getBusinessName()))
                    .channels(java.util.List.of("PUSH", "EMAIL"))
                    .priority("HIGH")
                    .build();
            event.initDefaults(NotificationEvent.MERCHANT_APPROVED, "merchant-service");
            eventPublisher.publishNotificationEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish merchant approved notification", e);
        }
    }

    /**
     * Publish merchant rejected notification
     */
    private void publishMerchantRejectedNotification(Merchant merchant, String reason) {
        try {
            NotificationEvent event = NotificationEvent.builder()
                    .userId(merchant.getUserId())
                    .notificationType(NotificationEvent.MERCHANT_REJECTED)
                    .title("Merchant Application Rejected")
                    .message(String.format("Your application for '%s' was not approved. Reason: %s", 
                            merchant.getBusinessName(), reason))
                    .channels(java.util.List.of("PUSH", "EMAIL"))
                    .priority("HIGH")
                    .build();
            event.initDefaults(NotificationEvent.MERCHANT_REJECTED, "merchant-service");
            eventPublisher.publishNotificationEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish merchant rejected notification", e);
        }
    }
}







