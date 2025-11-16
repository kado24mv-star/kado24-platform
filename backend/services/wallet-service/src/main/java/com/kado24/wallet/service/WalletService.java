package com.kado24.wallet.service;

import com.kado24.common.exception.BusinessException;
import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.common.util.StringUtil;
import com.kado24.kafka.event.NotificationEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.wallet.dto.GiftVoucherRequest;
import com.kado24.wallet.dto.WalletVoucherDTO;
import com.kado24.wallet.entity.WalletVoucher;
import com.kado24.wallet.mapper.WalletVoucherMapper;
import com.kado24.wallet.repository.WalletVoucherRepository;
import com.kado24.wallet.util.QRCodeGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class WalletService {

    private final WalletVoucherRepository repository;
    private final WalletVoucherMapper mapper;
    private final EventPublisher eventPublisher;
    private final QRCodeGenerator qrCodeGenerator;

    @Transactional
    public WalletVoucherDTO createWalletVoucher(Long orderId, Long userId, Long voucherId, 
                                                 Long merchantId, BigDecimal denomination) {
        log.info("Creating wallet voucher for order: {}", orderId);

        String voucherCode = StringUtil.generateVoucherCode();
        String qrCode = qrCodeGenerator.generateQRCodeBase64(voucherCode);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusYears(1);

        WalletVoucher voucher = WalletVoucher.builder()
                .voucherCode(voucherCode)
                .qrCodeUrl(qrCode)
                .userId(userId)
                .voucherId(voucherId)
                .orderId(orderId)
                .merchantId(merchantId)
                .denomination(denomination)
                .voucherValue(denomination)
                .remainingValue(denomination)
                .status(WalletVoucher.VoucherStatus.ACTIVE)
                .validFrom(now)
                .validUntil(expiresAt)
                .expiresAt(expiresAt)
                .build();

        voucher = repository.save(voucher);

        log.info("Wallet voucher created: {}", voucherCode);

        publishVoucherCreatedNotification(voucher);

        return mapper.toDTO(voucher);
    }

    @Transactional
    public List<WalletVoucherDTO> createWalletVouchers(Long orderId,
                                                       Long userId,
                                                       Long voucherId,
                                                       Long merchantId,
                                                       BigDecimal denomination,
                                                       int quantity) {
        List<WalletVoucherDTO> vouchers = new ArrayList<>();
        for (int i = 0; i < quantity; i++) {
            vouchers.add(createWalletVoucher(orderId, userId, voucherId, merchantId, denomination));
        }
        return vouchers;
    }

    @Transactional(readOnly = true)
    public Page<WalletVoucherDTO> getMyVouchers(Long userId, Pageable pageable) {
        Page<WalletVoucher> vouchers = repository.findByUserIdOrderByPurchasedAtDesc(userId, pageable);
        return vouchers.map(mapper::toDTO);
    }

    @Transactional(readOnly = true)
    public WalletVoucherDTO getVoucherDetails(Long voucherId, Long userId) {
        WalletVoucher voucher = repository.findByIdAndUserId(voucherId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet voucher", voucherId));
        return mapper.toDTO(voucher);
    }

    @Transactional
    public WalletVoucherDTO giftVoucher(Long senderUserId, Long voucherId, GiftVoucherRequest request) {
        WalletVoucher voucher = repository.findByIdAndUserId(voucherId, senderUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet voucher", voucherId));

        if (voucher.getStatus() != WalletVoucher.VoucherStatus.ACTIVE) {
            throw new BusinessException("Only active vouchers can be gifted");
        }
        if (voucher.getRemainingValue() == null || voucher.getRemainingValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BusinessException("Voucher balance is zero");
        }
        if (senderUserId.equals(request.getRecipientUserId())) {
            throw new BusinessException("Cannot gift voucher to yourself");
        }

        log.info("User {} gifting voucher {} to user {}", senderUserId, voucherId, request.getRecipientUserId());

        voucher.setUserId(request.getRecipientUserId());
        voucher.setGiftedToUserId(request.getRecipientUserId());
        voucher.setGiftMessage(request.getGiftMessage());
        voucher.setGiftedAt(LocalDateTime.now());
        voucher.setIsGift(true);
        voucher.setStatus(WalletVoucher.VoucherStatus.ACTIVE);

        voucher = repository.save(voucher);

        publishVoucherGiftedNotification(voucher, senderUserId, request.getRecipientUserId());

        return mapper.toDTO(voucher);
    }

    private void publishVoucherCreatedNotification(WalletVoucher voucher) {
        try {
            NotificationEvent event = NotificationEvent.builder()
                    .userId(voucher.getUserId())
                    .notificationType("VOUCHER_RECEIVED")
                    .title("Voucher Received! 🎁")
                    .message("Your voucher is ready in your wallet")
                    .channels(java.util.List.of("PUSH", "EMAIL"))
                    .build();
            event.initDefaults("VOUCHER_RECEIVED", "wallet-service");
            eventPublisher.publishNotificationEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish notification", e);
        }
    }

    private void publishVoucherGiftedNotification(WalletVoucher voucher, Long senderUserId, Long recipientUserId) {
        try {
            NotificationEvent event = NotificationEvent.builder()
                    .userId(recipientUserId)
                    .notificationType(NotificationEvent.VOUCHER_GIFTED)
                    .title("You've received a gift! 🎁")
                    .message("A friend just sent you a voucher. Open your wallet to view it.")
                    .channels(List.of("PUSH", "EMAIL"))
                    .entityType("VOUCHER")
                    .entityId(voucher.getId())
                    .data(Map.of(
                            "voucherCode", voucher.getVoucherCode(),
                            "senderUserId", senderUserId
                    ))
                    .build();
            event.initDefaults(NotificationEvent.VOUCHER_GIFTED, "wallet-service");
            eventPublisher.publishNotificationEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish gifted voucher notification", e);
        }
    }
}








