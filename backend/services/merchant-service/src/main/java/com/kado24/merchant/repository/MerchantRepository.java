package com.kado24.merchant.repository;

import com.kado24.merchant.entity.Merchant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for Merchant entity
 */
@Repository
public interface MerchantRepository extends JpaRepository<Merchant, Long> {

    /**
     * Find merchant by user ID
     */
    Optional<Merchant> findByUserId(Long userId);

    /**
     * Check if merchant exists for user
     */
    boolean existsByUserId(Long userId);

    /**
     * Find merchants by verification status
     */
    Page<Merchant> findByVerificationStatus(Merchant.VerificationStatus status, Pageable pageable);

    /**
     * Search merchants by business name
     */
    @Query("SELECT m FROM Merchant m WHERE LOWER(m.businessName) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<Merchant> searchByBusinessName(String query, Pageable pageable);

    /**
     * Count merchants by status
     */
    long countByVerificationStatus(Merchant.VerificationStatus status);

    /**
     * Find approved merchants
     */
    Page<Merchant> findByVerificationStatusOrderByCreatedAtDesc(
            Merchant.VerificationStatus status, Pageable pageable);
}






































