package com.kado24.payout.service;

import com.kado24.payout.entity.PayoutHold;
import com.kado24.payout.repository.PayoutHoldRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PayoutHoldService {

    private final PayoutHoldRepository payoutHoldRepository;

    @Transactional
    public PayoutHold createHold(Long merchantId, String reason) {
        return payoutHoldRepository.findByMerchantIdAndStatus(merchantId, PayoutHold.HoldStatus.ACTIVE)
                .orElseGet(() -> {
                    PayoutHold hold = PayoutHold.builder()
                            .merchantId(merchantId)
                            .reason(reason)
                            .status(PayoutHold.HoldStatus.ACTIVE)
                            .build();
                    PayoutHold saved = payoutHoldRepository.save(hold);
                    log.info("Created payout hold for merchant {}", merchantId);
                    return saved;
                });
    }

    public List<PayoutHold> getActiveHolds() {
        return payoutHoldRepository.findByStatus(PayoutHold.HoldStatus.ACTIVE);
    }
}




