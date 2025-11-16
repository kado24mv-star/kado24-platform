package com.kado24.voucher.service;

import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.voucher.dto.CategoryDTO;
import com.kado24.voucher.entity.Voucher;
import com.kado24.voucher.entity.VoucherCategory;
import com.kado24.voucher.mapper.CategoryMapper;
import com.kado24.voucher.repository.VoucherCategoryRepository;
import com.kado24.voucher.repository.VoucherRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Voucher category service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final VoucherCategoryRepository categoryRepository;
    private final VoucherRepository voucherRepository;
    private final CategoryMapper categoryMapper;

    /**
     * Get all active categories
     */
    public List<CategoryDTO> getAllCategories() {
        log.debug("Fetching all active categories");
        
        List<VoucherCategory> categories = categoryRepository.findByIsActiveTrueOrderBySortOrderAsc();
        
        return categories.stream()
                .map(category -> {
                    CategoryDTO dto = categoryMapper.toDTO(category);
                    // Add voucher count
                    long count = voucherRepository.countByMerchantIdAndStatus(
                            null, Voucher.VoucherStatus.ACTIVE);
                    dto.setVoucherCount(count);
                    return dto;
                })
                .collect(Collectors.toList());
    }

    /**
     * Get category by slug
     */
    public CategoryDTO getCategoryBySlug(String slug) {
        log.debug("Fetching category by slug: {}", slug);
        
        VoucherCategory category = categoryRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Category", slug));
        
        return categoryMapper.toDTO(category);
    }
}

