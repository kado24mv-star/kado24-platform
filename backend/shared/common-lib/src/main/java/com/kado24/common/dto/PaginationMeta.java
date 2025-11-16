package com.kado24.common.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Pagination metadata for paginated API responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Pagination metadata")
public class PaginationMeta {
    
    @Schema(description = "Current page number (0-indexed)", example = "0")
    private int currentPage;
    
    @Schema(description = "Number of items per page", example = "20")
    private int pageSize;
    
    @Schema(description = "Total number of items", example = "150")
    private long totalItems;
    
    @Schema(description = "Total number of pages", example = "8")
    private int totalPages;
    
    @Schema(description = "Whether there is a next page", example = "true")
    private boolean hasNext;
    
    @Schema(description = "Whether there is a previous page", example = "false")
    private boolean hasPrevious;

    /**
     * Create pagination metadata from Spring Data Page
     */
    public static PaginationMeta from(int currentPage, int pageSize, long totalItems) {
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        return PaginationMeta.builder()
                .currentPage(currentPage)
                .pageSize(pageSize)
                .totalItems(totalItems)
                .totalPages(totalPages)
                .hasNext(currentPage < totalPages - 1)
                .hasPrevious(currentPage > 0)
                .build();
    }
}



















