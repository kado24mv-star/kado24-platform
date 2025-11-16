package com.kado24.voucher.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Voucher category")
public class CategoryDTO {

    @Schema(description = "Category ID", example = "1")
    private Long id;

    @Schema(description = "Category name", example = "Food & Dining")
    private String name;

    @Schema(description = "URL-friendly slug", example = "food-dining")
    private String slug;

    @Schema(description = "Category description")
    private String description;

    @Schema(description = "Icon URL or emoji", example = "🍽️")
    private String iconUrl;

    @Schema(description = "Display order", example = "1")
    private Integer displayOrder;

    @Schema(description = "Active status", example = "true")
    private Boolean isActive;

    @Schema(description = "Total vouchers in category", example = "25")
    private Long voucherCount;
}



















