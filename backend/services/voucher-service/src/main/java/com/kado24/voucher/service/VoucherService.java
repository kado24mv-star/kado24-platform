package com.kado24.voucher.service;

import com.kado24.common.exception.BusinessException;
import com.kado24.common.exception.ForbiddenException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.common.util.StringUtil;
import com.kado24.kafka.event.AnalyticsEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.voucher.dto.CreateVoucherRequest;
import com.kado24.voucher.dto.UpdateVoucherRequest;
import com.kado24.voucher.dto.VoucherDTO;
import com.kado24.voucher.dto.VoucherReservationRequest;
import com.kado24.voucher.dto.VoucherReservationResponse;
import com.kado24.voucher.entity.Voucher;
import com.kado24.voucher.entity.VoucherCategory;
import com.kado24.voucher.mapper.VoucherMapper;
import com.kado24.voucher.repository.VoucherCategoryRepository;
import com.kado24.voucher.repository.VoucherRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Voucher management service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VoucherService {

    private final VoucherRepository voucherRepository;
    private final VoucherCategoryRepository categoryRepository;
    private final VoucherMapper voucherMapper;
    private final EventPublisher eventPublisher;
    
    @PersistenceContext
    private EntityManager entityManager;

    /**
     * Create voucher (merchant only)
     */
    @Transactional
    public VoucherDTO createVoucher(Long merchantId, CreateVoucherRequest request) {
        log.info("Creating voucher for merchant: {}", merchantId);

        // Verify category exists
        VoucherCategory category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", request.getCategoryId()));

        // Generate slug
        String slug = StringUtil.slugify(request.getTitle()) + "-" + System.currentTimeMillis();

        // Prepare array fields (null when empty)
        List<BigDecimal> denominations = request.getDenominations();
        if (denominations != null && denominations.isEmpty()) {
            denominations = null;
        }
        List<String> redemptionLocations = request.getRedemptionLocations();
        if (redemptionLocations != null && redemptionLocations.isEmpty()) {
            redemptionLocations = null;
        }
        
        // Calculate minValue and maxValue from denominations (required by database)
        BigDecimal minValue = BigDecimal.ZERO;
        BigDecimal maxValue = BigDecimal.ZERO;
        if (denominations != null && !denominations.isEmpty()) {
            minValue = denominations.stream()
                    .min(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
            maxValue = denominations.stream()
                    .max(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
        }
        // If no denominations, both are zero (should not happen due to validation)
        
        // Build voucher - don't set createdAt/updatedAt, let @CreationTimestamp/@UpdateTimestamp handle it
        Voucher voucher = Voucher.builder()
                .merchantId(merchantId)
                .categoryId(request.getCategoryId())
                .title(request.getTitle())
                .slug(slug)
                .description(request.getDescription())
                .termsAndConditions(request.getTermsAndConditions())
                .denominations(denominations)
                .minValue(minValue)
                .maxValue(maxValue)
                .discountPercentage(request.getDiscountPercentage())
                .imageUrl(request.getImageUrl())
                .additionalImages(null) // Not used - one image per voucher only
                .status(Voucher.VoucherStatus.DRAFT)
                .stockQuantity(request.getStockQuantity())
                .unlimitedStock(request.getUnlimitedStock() != null ? request.getUnlimitedStock() : false)
                .validFrom(request.getValidFrom())
                .validUntil(request.getValidUntil())
                .redemptionLocations(redemptionLocations)
                .minPurchaseAmount(request.getMinPurchaseAmount())
                .maxPurchasePerUser(request.getMaxPurchasePerUser())
                .usageInstructions(request.getUsageInstructions())
                // Explicitly set timestamps to ensure they're not null
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        voucher = voucherRepository.save(voucher);

        log.info("Voucher created with ID: {}", voucher.getId());

        return enrichVoucherDTO(voucherMapper.toDTO(voucher));
    }

    /**
     * Get active vouchers (public)
     */
    public Page<VoucherDTO> getActiveVouchers(Pageable pageable) {
        log.debug("Fetching active vouchers");
        Page<Voucher> vouchers = voucherRepository.findActiveVouchers(pageable);
        return vouchers.map(v -> enrichVoucherDTO(voucherMapper.toDTO(v)));
    }

    /**
     * Get voucher by ID or slug
     */
    @Transactional
    public VoucherDTO getVoucher(String slugOrId) {
        log.debug("Fetching voucher: {}", slugOrId);

        Voucher voucher;
        
        // Try to find by slug first
        voucher = voucherRepository.findBySlug(slugOrId).orElse(null);
        
        // If not found, try by ID
        if (voucher == null) {
            try {
                Long id = Long.parseLong(slugOrId);
                voucher = voucherRepository.findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Voucher", slugOrId));
            } catch (NumberFormatException e) {
                throw new ResourceNotFoundException("Voucher", slugOrId);
            }
        }

        // Increment view count
        voucher.incrementViewCount();
        voucherRepository.save(voucher);

        // Publish analytics event
        publishVoucherViewedEvent(voucher.getId());

        return enrichVoucherDTO(voucherMapper.toDTO(voucher));
    }

    /**
     * Search vouchers
     */
    public Page<VoucherDTO> searchVouchers(String query, Pageable pageable) {
        log.debug("Searching vouchers with query: {}", query);
        Page<Voucher> vouchers = voucherRepository.searchVouchers(query, pageable);
        return vouchers.map(v -> enrichVoucherDTO(voucherMapper.toDTO(v)));
    }

    /**
     * Get vouchers by category
     */
    public Page<VoucherDTO> getVouchersByCategory(Long categoryId, Pageable pageable) {
        log.debug("Fetching vouchers for category: {}", categoryId);
        
        // Verify category exists
        categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Category", categoryId));
        
        Page<Voucher> vouchers = voucherRepository.findActiveVouchersByCategory(categoryId, pageable);
        return vouchers.map(v -> enrichVoucherDTO(voucherMapper.toDTO(v)));
    }

    /**
     * Get merchant's vouchers
     */
    /**
     * Get merchant ID from user ID
     */
    public Long getMerchantIdByUserId(Long userId) {
        try {
            String sql = "SELECT id FROM merchant_schema.merchants WHERE user_id = :userId";
            Object result = entityManager.createNativeQuery(sql)
                    .setParameter("userId", userId)
                    .getSingleResult();
            
            if (result instanceof Number) {
                return ((Number) result).longValue();
            }
            return null;
        } catch (NoResultException e) {
            log.warn("No merchant found for user ID: {}", userId);
            return null;
        } catch (Exception e) {
            log.error("Error getting merchant ID for user ID: {}", userId, e);
            return null;
        }
    }

    public Page<VoucherDTO> getMerchantVouchers(Long merchantId, Pageable pageable) {
        log.debug("Fetching vouchers for merchant: {}", merchantId);
        Page<Voucher> vouchers = voucherRepository.findByMerchantId(merchantId, pageable);
        return vouchers.map(v -> enrichVoucherDTO(voucherMapper.toDTO(v)));
    }

    /**
     * Update voucher
     */
    @Transactional
    public VoucherDTO updateVoucher(Long voucherId, Long merchantId, UpdateVoucherRequest request) {
        log.info("Updating voucher: {} by merchant: {}", voucherId, merchantId);

        Voucher voucher = voucherRepository.findById(voucherId)
                .orElseThrow(() -> new ResourceNotFoundException("Voucher", voucherId));

        // Verify ownership
        if (!voucher.getMerchantId().equals(merchantId)) {
            throw new ForbiddenException("You don't own this voucher");
        }

        // Update fields if provided
        if (request.getTitle() != null) {
            voucher.setTitle(request.getTitle());
            voucher.setSlug(StringUtil.slugify(request.getTitle()));
        }
        if (request.getDescription() != null) {
            voucher.setDescription(request.getDescription());
        }
        if (request.getTermsAndConditions() != null) {
            voucher.setTermsAndConditions(request.getTermsAndConditions());
        }
        if (request.getDenominations() != null) {
            voucher.setDenominations(request.getDenominations());
        }
        if (request.getDiscountPercentage() != null) {
            voucher.setDiscountPercentage(request.getDiscountPercentage());
        }
        if (request.getImageUrl() != null) {
            voucher.setImageUrl(request.getImageUrl());
        }
        if (request.getStockQuantity() != null) {
            voucher.setStockQuantity(request.getStockQuantity());
        }
        if (request.getUnlimitedStock() != null) {
            voucher.setUnlimitedStock(request.getUnlimitedStock());
        }
        if (request.getValidFrom() != null) {
            voucher.setValidFrom(request.getValidFrom());
        }
        if (request.getValidUntil() != null) {
            voucher.setValidUntil(request.getValidUntil());
        }

        voucher = voucherRepository.save(voucher);

        log.info("Voucher updated: {}", voucherId);

        return enrichVoucherDTO(voucherMapper.toDTO(voucher));
    }

    /**
     * Publish voucher (merchant)
     */
    @Transactional
    public VoucherDTO publishVoucher(Long voucherId, Long merchantId) {
        log.info("Publishing voucher: {}", voucherId);

        Voucher voucher = voucherRepository.findById(voucherId)
                .orElseThrow(() -> new ResourceNotFoundException("Voucher", voucherId));

        // Verify ownership
        if (!voucher.getMerchantId().equals(merchantId)) {
            throw new ForbiddenException("You don't own this voucher");
        }

        // Validate voucher is ready to publish
        if (voucher.getTitle() == null || voucher.getDescription() == null) {
            throw new BusinessException("Voucher must have title and description");
        }

        voucher.setStatus(Voucher.VoucherStatus.ACTIVE);
        voucher.setPublishedAt(LocalDateTime.now());
        voucher = voucherRepository.save(voucher);

        log.info("Voucher published: {}", voucherId);

        return enrichVoucherDTO(voucherMapper.toDTO(voucher));
    }

    /**
     * Toggle pause status of voucher
     */
    @Transactional
    public VoucherDTO togglePauseVoucher(Long voucherId, Long merchantId) {
        log.info("Toggling pause status for voucher: {}", voucherId);

        Voucher voucher = voucherRepository.findById(voucherId)
                .orElseThrow(() -> new ResourceNotFoundException("Voucher", voucherId));

        // Verify ownership
        if (!voucher.getMerchantId().equals(merchantId)) {
            throw new ForbiddenException("You don't own this voucher");
        }

        // Toggle between ACTIVE and PAUSED
        if (voucher.getStatus() == Voucher.VoucherStatus.ACTIVE) {
            voucher.setStatus(Voucher.VoucherStatus.PAUSED);
            log.info("Voucher paused: {}", voucherId);
        } else if (voucher.getStatus() == Voucher.VoucherStatus.PAUSED) {
            voucher.setStatus(Voucher.VoucherStatus.ACTIVE);
            log.info("Voucher unpaused (activated): {}", voucherId);
        } else {
            throw new BusinessException("Can only pause/unpause ACTIVE or PAUSED vouchers");
        }

        voucher = voucherRepository.save(voucher);

        return enrichVoucherDTO(voucherMapper.toDTO(voucher));
    }

    /**
     * Delete voucher (soft delete)
     */
    @Transactional
    public void deleteVoucher(Long voucherId, Long merchantId) {
        log.info("Deleting voucher: {}", voucherId);

        Voucher voucher = voucherRepository.findById(voucherId)
                .orElseThrow(() -> new ResourceNotFoundException("Voucher", voucherId));

        // Verify ownership
        if (!voucher.getMerchantId().equals(merchantId)) {
            throw new ForbiddenException("You don't own this voucher");
        }

        voucher.setStatus(Voucher.VoucherStatus.DELETED);
        voucherRepository.save(voucher);

        log.info("Voucher deleted: {}", voucherId);
    }

    /**
     * Publish voucher viewed analytics event
     */
    private void publishVoucherViewedEvent(Long voucherId) {
        try {
            AnalyticsEvent event = AnalyticsEvent.voucherViewed(voucherId, null);
            eventPublisher.publishAnalyticsEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish voucher viewed event", e);
        }
    }

    /**
     * Reserve voucher stock (internal use by order/payment services)
     */
    @Transactional
    public VoucherReservationResponse reserveVoucher(Long voucherId, VoucherReservationRequest request) {
        int quantity = request.getQuantity() != null && request.getQuantity() > 0 ? request.getQuantity() : 1;
        BigDecimal denomination = request.getDenomination();
        if (denomination == null) {
            throw new BusinessException("Denomination is required for reservation");
        }

        Voucher voucher = voucherRepository.findByIdForUpdate(voucherId)
                .orElseThrow(() -> new ResourceNotFoundException("Voucher", voucherId));

        if (!voucher.isAvailable()) {
            throw new BusinessException("Voucher is not available for purchase");
        }

        List<BigDecimal> allowedDenominations = voucher.getDenominations();
        if (allowedDenominations != null && !allowedDenominations.isEmpty()
                && allowedDenominations.stream().noneMatch(value -> value.compareTo(denomination) == 0)) {
            throw new BusinessException("Invalid voucher denomination selected");
        }

        if (!Boolean.TRUE.equals(voucher.getUnlimitedStock())) {
            Integer currentStock = voucher.getStockQuantity();
            if (currentStock == null || currentStock < quantity) {
                throw new BusinessException("Insufficient voucher stock");
            }
            voucher.setStockQuantity(currentStock - quantity);
        }

        voucher.setTotalSold((voucher.getTotalSold() != null ? voucher.getTotalSold() : 0) + quantity);
        voucherRepository.save(voucher);

        return VoucherReservationResponse.builder()
                .voucherId(voucher.getId())
                .merchantId(voucher.getMerchantId())
                .voucherTitle(voucher.getTitle())
                .denomination(denomination)
                .remainingStock(Boolean.TRUE.equals(voucher.getUnlimitedStock()) ? null : voucher.getStockQuantity())
                .unlimitedStock(voucher.getUnlimitedStock())
                .build();
    }

    /**
     * Enrich VoucherDTO with merchant name and category name
     */
    private VoucherDTO enrichVoucherDTO(VoucherDTO dto) {
        if (dto == null) {
            return null;
        }

        // Fetch merchant name from merchant_schema
        // Handle both cases: merchant_id could be merchant.id or merchant.user_id
        if (dto.getMerchantId() != null && (dto.getMerchantName() == null || dto.getMerchantName().isEmpty())) {
            try {
                log.debug("Enriching voucher DTO with merchant name for merchantId: {}", dto.getMerchantId());
                // First try to find by merchant.id
                String merchantName = null;
                try {
                    merchantName = (String) entityManager.createNativeQuery(
                        "SELECT business_name FROM merchant_schema.merchants WHERE id = :merchantId"
                    )
                    .setParameter("merchantId", dto.getMerchantId())
                    .getSingleResult();
                } catch (NoResultException e) {
                    // If not found by id, try to find by user_id (in case merchant_id is actually user_id)
                    log.debug("Merchant not found by id, trying user_id: {}", dto.getMerchantId());
                    try {
                        merchantName = (String) entityManager.createNativeQuery(
                            "SELECT business_name FROM merchant_schema.merchants WHERE user_id = :userId"
                        )
                        .setParameter("userId", dto.getMerchantId())
                        .getSingleResult();
                    } catch (NoResultException e2) {
                        log.warn("No merchant found for merchantId/userId: {}", dto.getMerchantId());
                    }
                }
                
                if (merchantName != null && !merchantName.isEmpty()) {
                    dto.setMerchantName(merchantName);
                    log.debug("Successfully enriched merchant name: {}", merchantName);
                } else {
                    log.warn("Merchant name is null or empty for merchantId: {}", dto.getMerchantId());
                    dto.setMerchantName("Unknown Merchant");
                }
            } catch (Exception e) {
                log.warn("Failed to fetch merchant name for merchantId: {}, error: {}", dto.getMerchantId(), e.getMessage());
                dto.setMerchantName("Unknown Merchant");
            }
        }

        // Fetch category name if not already set
        if (dto.getCategoryId() != null && dto.getCategoryName() == null) {
            try {
                VoucherCategory category = categoryRepository.findById(dto.getCategoryId()).orElse(null);
                if (category != null) {
                    dto.setCategoryName(category.getDisplayName());
                }
            } catch (Exception e) {
                log.warn("Failed to fetch category name for categoryId: {}, error: {}", dto.getCategoryId(), e.getMessage());
            }
        }

        return dto;
    }
}







