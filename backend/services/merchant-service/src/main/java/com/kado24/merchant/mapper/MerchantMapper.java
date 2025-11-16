package com.kado24.merchant.mapper;

import com.kado24.merchant.dto.MerchantDTO;
import com.kado24.merchant.entity.Merchant;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 * Mapper for Merchant entity to MerchantDTO
 */
@Mapper(componentModel = "spring")
public interface MerchantMapper {

    MerchantMapper INSTANCE = Mappers.getMapper(MerchantMapper.class);

    /**
     * Convert Merchant entity to MerchantDTO
     */
    @Mapping(target = "address", expression = "java(buildAddress(merchant))")
    MerchantDTO toDTO(Merchant merchant);

    /**
     * Build full address string
     */
    default String buildAddress(Merchant merchant) {
        if (merchant.getAddressLine1() == null) {
            return null;
        }
        StringBuilder address = new StringBuilder(merchant.getAddressLine1());
        if (merchant.getAddressLine2() != null) {
            address.append(", ").append(merchant.getAddressLine2());
        }
        if (merchant.getCity() != null) {
            address.append(", ").append(merchant.getCity());
        }
        if (merchant.getProvince() != null) {
            address.append(", ").append(merchant.getProvince());
        }
        return address.toString();
    }
}



















