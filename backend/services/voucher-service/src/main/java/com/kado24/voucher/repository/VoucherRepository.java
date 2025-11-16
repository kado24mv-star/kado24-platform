package com.kado24.voucher.repository;

import com.kado24.voucher.entity.Voucher;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Lock;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Voucher entity
 */
@Repository
public interface VoucherRepository extends JpaRepository<Voucher, Long>, JpaSpecificationExecutor<Voucher> {

    /**
     * Find voucher by slug
     */
    Optional<Voucher> findBySlug(String slug);

    /**
     * Find vouchers by merchant
     */
    Page<Voucher> findByMerchantId(Long merchantId, Pageable pageable);

    /**
     * Find vouchers by category
     */
    Page<Voucher> findByCategoryId(Long categoryId, Pageable pageable);

    /**
     * Find vouchers by status
     */
    Page<Voucher> findByStatus(Voucher.VoucherStatus status, Pageable pageable);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT v FROM Voucher v WHERE v.id = :id")
    Optional<Voucher> findByIdForUpdate(@Param("id") Long id);

    /**
     * Find active vouchers (for public browsing)
     */
    @Query("SELECT v FROM Voucher v WHERE v.status = 'ACTIVE' " +
           "AND (v.validFrom IS NULL OR v.validFrom <= CURRENT_TIMESTAMP) " +
           "AND (v.validUntil IS NULL OR v.validUntil >= CURRENT_TIMESTAMP) " +
           "AND (v.unlimitedStock = true OR v.stockQuantity > 0)")
    Page<Voucher> findActiveVouchers(Pageable pageable);

    /**
     * Find active vouchers by category
     */
    @Query("SELECT v FROM Voucher v WHERE v.status = 'ACTIVE' " +
           "AND v.categoryId = :categoryId " +
           "AND (v.validFrom IS NULL OR v.validFrom <= CURRENT_TIMESTAMP) " +
           "AND (v.validUntil IS NULL OR v.validUntil >= CURRENT_TIMESTAMP) " +
           "AND (v.unlimitedStock = true OR v.stockQuantity > 0)")
    Page<Voucher> findActiveVouchersByCategory(@Param("categoryId") Long categoryId, Pageable pageable);

    /**
     * Search vouchers by title using full-text search
     */
    @Query(value = "SELECT * FROM vouchers WHERE search_vector @@ plainto_tsquery('english', :query) " +
           "AND status = 'ACTIVE'", nativeQuery = true)
    Page<Voucher> searchVouchers(@Param("query") String query, Pageable pageable);

    /**
     * Find featured vouchers (high rating, active)
     */
    @Query("SELECT v FROM Voucher v WHERE v.status = 'ACTIVE' " +
           "AND v.rating >= 4.0 " +
           "ORDER BY v.rating DESC, v.totalSold DESC")
    List<Voucher> findFeaturedVouchers(Pageable pageable);

    /**
     * Find trending vouchers (recently sold)
     */
    @Query("SELECT v FROM Voucher v WHERE v.status = 'ACTIVE' " +
           "ORDER BY v.totalSold DESC, v.createdAt DESC")
    List<Voucher> findTrendingVouchers(Pageable pageable);

    /**
     * Count vouchers by merchant
     */
    long countByMerchantId(Long merchantId);

    /**
     * Count active vouchers by merchant
     */
    long countByMerchantIdAndStatus(Long merchantId, Voucher.VoucherStatus status);
}
















