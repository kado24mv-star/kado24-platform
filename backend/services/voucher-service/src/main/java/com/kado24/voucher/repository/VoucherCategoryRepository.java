package com.kado24.voucher.repository;

import com.kado24.voucher.entity.VoucherCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for VoucherCategory entity
 */
@Repository
public interface VoucherCategoryRepository extends JpaRepository<VoucherCategory, Long> {

    /**
     * Find category by slug
     */
    Optional<VoucherCategory> findBySlug(String slug);

    /**
     * Find all active categories ordered by display order
     */
    List<VoucherCategory> findByIsActiveTrueOrderBySortOrderAsc();

    /**
     * Check if slug exists
     */
    boolean existsBySlug(String slug);

    /**
     * Check if name exists
     */
    boolean existsByName(String name);
}







