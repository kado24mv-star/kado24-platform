package com.kado24.payout.repository;

import com.kado24.payout.entity.PayoutHold;
import com.kado24.payout.entity.PayoutHold.HoldStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PayoutHoldRepository extends JpaRepository<PayoutHold, Long> {
    List<PayoutHold> findByStatus(HoldStatus status);
    Optional<PayoutHold> findByMerchantIdAndStatus(Long merchantId, HoldStatus status);
}




