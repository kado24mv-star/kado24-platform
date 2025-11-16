package com.kado24.redemption.service;

import com.kado24.common.util.StringUtil;
import com.kado24.kafka.event.NotificationEvent;
import com.kado24.kafka.event.RedemptionEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.redemption.dto.RedeemVoucherRequest;
import com.kado24.redemption.dto.RedemptionDTO;
import com.kado24.redemption.entity.Redemption;
import com.kado24.redemption.repository.RedemptionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedemptionService {

	private final RedemptionRepository repository;
	private final EventPublisher eventPublisher;

	// Simple in-memory idempotency to prevent duplicate redemptions by voucherCode within service lifetime
	private static final Map<String, Long> voucherCodeToRedemptionId = new ConcurrentHashMap<>();

	@Transactional
	public RedemptionDTO redeemVoucher(RedeemVoucherRequest request, Long merchantUserId) {
		log.info("Redeeming voucher: {} at merchant: {}", request.getVoucherCode(), merchantUserId);

		// Idempotency: if this voucherCode was already redeemed, return the same redemption snapshot
		Long existingId = voucherCodeToRedemptionId.get(request.getVoucherCode());
		if (existingId != null) {
			log.info("Voucher {} already redeemed previously, returning existing redemption {}", request.getVoucherCode(), existingId);
			Optional<Redemption> existingOpt = repository.findById(existingId);
			if (existingOpt.isPresent()) {
				Redemption existing = existingOpt.get();
				return RedemptionDTO.builder()
						.id(existing.getId())
						.voucherCode(request.getVoucherCode())
						.amount(existing.getRedemptionAmount())
						.status(existing.getStatus().name())
						.redeemedAt(existing.getRedeemedAt())
						.build();
			}
		}

		// TODO: Validate wallet voucher exists and is valid
		// TODO: Verify merchant ownership
		// TODO: Update wallet voucher status to USED

		Redemption redemption = Redemption.builder()
				.redemptionCode(StringUtil.generateVoucherCode())
				.walletVoucherId(1L) // TODO: Get from validation
				.merchantId(merchantUserId)
				.voucherId(1L) // TODO: Get from voucher service
				.redeemedByUserId(1L) // TODO: Get from wallet voucher
				.scannedByUserId(merchantUserId)
				.redemptionAmount(request.getAmount())
				.redeemedValue(request.getAmount())
				.redemptionMethod(Redemption.RedemptionMethod.QR_SCAN)
				.redemptionLocation(request.getLocation())
				.status(Redemption.RedemptionStatus.CONFIRMED)
				.build();

		redemption = repository.save(redemption);

		// Track idempotency for this voucherCode
		voucherCodeToRedemptionId.putIfAbsent(request.getVoucherCode(), redemption.getId());

		log.info("Voucher redeemed successfully: {}", redemption.getId());

		// Publish events
		publishRedemptionEvent(redemption);
		publishRedemptionNotification(redemption);

		return RedemptionDTO.builder()
				.id(redemption.getId())
				.voucherCode(request.getVoucherCode())
				.amount(redemption.getRedemptionAmount())
				.status(redemption.getStatus().name())
				.redeemedAt(redemption.getRedeemedAt())
				.build();
	}

	private void publishRedemptionEvent(Redemption redemption) {
		try {
			RedemptionEvent event = RedemptionEvent.completed(
					redemption.getId(),
					redemption.getWalletVoucherId(),
					"VOUCHER-CODE",
					redemption.getMerchantId(),
					"Merchant Name",
					redemption.getRedeemedByUserId(),
					redemption.getRedemptionAmount(),
					redemption.getRedemptionLocation()
			);
			eventPublisher.publishRedemptionEvent(event);
		} catch (Exception e) {
			log.error("Failed to publish redemption event", e);
		}
	}

	private void publishRedemptionNotification(Redemption redemption) {
		try {
			NotificationEvent event = NotificationEvent.voucherRedeemed(
					redemption.getRedeemedByUserId(),
					"VOUCHER-CODE",
					"Merchant Name"
			);
			eventPublisher.publishNotificationEvent(event);
		} catch (Exception e) {
			log.error("Failed to publish notification", e);
		}
	}

	public Page<RedemptionDTO> getMyRedemptions(Long userId, Pageable pageable) {
		log.info("Fetching redemptions for user: {}", userId);
		Page<Redemption> redemptions = repository.findByRedeemedByUserIdOrderByRedeemedAtDesc(userId, pageable);
		return redemptions.map(this::toDTO);
	}

	public Page<RedemptionDTO> getMerchantRedemptions(Long merchantId, Long currentUserId, Pageable pageable) {
		log.info("Fetching redemptions for merchant: {} by user: {}", merchantId, currentUserId);
		// TODO: Verify currentUserId is the merchant owner
		Page<Redemption> redemptions = repository.findByMerchantIdOrderByRedeemedAtDesc(merchantId, pageable);
		return redemptions.map(this::toDTO);
	}

	private RedemptionDTO toDTO(Redemption redemption) {
		return RedemptionDTO.builder()
				.id(redemption.getId())
				.voucherCode("VOUCHER-" + redemption.getWalletVoucherId()) // TODO: Get actual code
				.amount(redemption.getRedemptionAmount())
				.status(redemption.getStatus().name())
				.redeemedAt(redemption.getRedeemedAt())
				.build();
	}
}







