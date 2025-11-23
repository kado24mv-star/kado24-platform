package com.kado24.payout.service;

import com.kado24.payout.dto.PayoutDTO;
import com.kado24.payout.entity.Payout;
import com.kado24.payout.repository.PayoutRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PayoutService {

    private final PayoutRepository payoutRepository;

    /**
     * Get payouts for a merchant
     */
    @Transactional(readOnly = true)
    public Page<PayoutDTO> getMerchantPayouts(Long merchantId, Pageable pageable) {
        log.info("Fetching payouts for merchant: {}", merchantId);
        
        Page<Payout> payouts = payoutRepository.findByMerchantId(merchantId, pageable);
        
        return payouts.map(PayoutDTO::fromEntity);
    }
}

