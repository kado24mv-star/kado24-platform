package com.kado24.voucher.mapper;

import com.kado24.voucher.dto.CategoryDTO;
import com.kado24.voucher.entity.VoucherCategory;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 * Mapper for VoucherCategory entity to CategoryDTO
 */
@Mapper(componentModel = "spring")
public interface CategoryMapper {

    CategoryMapper INSTANCE = Mappers.getMapper(CategoryMapper.class);

    /**
     * Convert VoucherCategory entity to CategoryDTO
     */
    @Mapping(target = "voucherCount", ignore = true) // Set manually if needed
    CategoryDTO toDTO(VoucherCategory category);
}



















