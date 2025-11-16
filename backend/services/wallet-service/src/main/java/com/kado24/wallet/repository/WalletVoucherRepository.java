package com.kado24.wallet.repository;

import com.kado24.wallet.entity.WalletVoucher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface WalletVoucherRepository extends JpaRepository<WalletVoucher, Long> {

    Optional<WalletVoucher> findByVoucherCode(String voucherCode);
    
    Page<WalletVoucher> findByUserIdOrderByPurchasedAtDesc(Long userId, Pageable pageable);
    
    Page<WalletVoucher> findByUserIdAndStatusOrderByPurchasedAtDesc(
            Long userId, WalletVoucher.VoucherStatus status, Pageable pageable);
    
    Optional<WalletVoucher> findByIdAndUserId(Long id, Long userId);
    
    long countByUserIdAndStatus(Long userId, WalletVoucher.VoucherStatus status);
}



















