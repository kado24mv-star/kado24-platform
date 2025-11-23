package com.kado24.payout.repository;

import com.kado24.payout.entity.Payout;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PayoutRepository extends JpaRepository<Payout, Long> {
    /**
     * Find payouts by merchant ID
     */
    Page<Payout> findByMerchantId(Long merchantId, Pageable pageable);
}


























