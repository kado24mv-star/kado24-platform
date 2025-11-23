package com.kado24.voucher.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.voucher.dto.CategoryDTO;
import com.kado24.voucher.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Voucher category REST controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Categories", description = "Voucher category endpoints")
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "Get all categories", description = "Get all active voucher categories (public)")
    @GetMapping
    public ResponseEntity<ApiResponse<List<CategoryDTO>>> getAllCategories() {
        log.info("Fetching all categories");
        
        List<CategoryDTO> categories = categoryService.getAllCategories();
        
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    @Operation(summary = "Get category by slug", description = "Get category details by slug (public)")
    @GetMapping("/{slug}")
    public ResponseEntity<ApiResponse<CategoryDTO>> getCategoryBySlug(@PathVariable String slug) {
        log.info("Fetching category by slug: {}", slug);
        
        CategoryDTO category = categoryService.getCategoryBySlug(slug);
        
        return ResponseEntity.ok(ApiResponse.success(category));
    }
}






































