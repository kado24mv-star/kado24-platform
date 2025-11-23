package com.kado24.common.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Standard pagination request parameters
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Pagination request parameters")
public class PageRequest {
    
    @Min(0)
    @Builder.Default
    @Schema(description = "Page number (0-indexed)", example = "0", defaultValue = "0")
    private int page = 0;
    
    @Min(1)
    @Max(100)
    @Builder.Default
    @Schema(description = "Number of items per page", example = "20", defaultValue = "20")
    private int size = 20;
    
    @Schema(description = "Sort field", example = "createdAt")
    private String sortBy;
    
    @Builder.Default
    @Schema(description = "Sort direction (ASC or DESC)", example = "DESC", defaultValue = "DESC")
    private String sortDirection = "DESC";

    /**
     * Convert to Spring Data PageRequest
     */
    public org.springframework.data.domain.PageRequest toSpringPageRequest() {
        org.springframework.data.domain.Sort sort = null;
        if (sortBy != null && !sortBy.isEmpty()) {
            sort = "ASC".equalsIgnoreCase(sortDirection)
                    ? org.springframework.data.domain.Sort.by(sortBy).ascending()
                    : org.springframework.data.domain.Sort.by(sortBy).descending();
        }
        
        return sort != null
                ? org.springframework.data.domain.PageRequest.of(page, size, sort)
                : org.springframework.data.domain.PageRequest.of(page, size);
    }
}






































