package com.kado24.redemption.repository;

import com.kado24.redemption.entity.Redemption;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RedemptionRepository extends JpaRepository<Redemption, Long> {
    
    Page<Redemption> findByMerchantIdOrderByRedeemedAtDesc(Long merchantId, Pageable pageable);
    
    Page<Redemption> findByRedeemedByUserIdOrderByRedeemedAtDesc(Long userId, Pageable pageable);
}






































