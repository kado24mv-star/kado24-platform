package com.kado24.voucher.mapper;

import com.kado24.voucher.dto.VoucherDTO;
import com.kado24.voucher.entity.Voucher;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Mapper for Voucher entity to VoucherDTO
 */
@Mapper(componentModel = "spring")
public interface VoucherMapper {

    VoucherMapper INSTANCE = Mappers.getMapper(VoucherMapper.class);

    /**
     * Convert Voucher entity to VoucherDTO
     */
    @Mapping(target = "merchantName", ignore = true) // Set manually
    @Mapping(target = "categoryName", ignore = true) // Set manually
    @Mapping(target = "isAvailable", expression = "java(voucher.isAvailable())")
    VoucherDTO toDTO(Voucher voucher);

    /**
     * Parse denominations from PostgreSQL array format
     */
    default List<BigDecimal> parseDenominations(String denominations) {
        if (denominations == null || denominations.isEmpty()) {
            return List.of();
        }
        // PostgreSQL array format: "{5.00,10.00,25.00}"
        String cleaned = denominations.replaceAll("[{}]", "");
        return Arrays.stream(cleaned.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(BigDecimal::new)
                .collect(Collectors.toList());
    }

    /**
     * Convert denominations to PostgreSQL array format
     */
    default String formatDenominations(List<BigDecimal> denominations) {
        if (denominations == null || denominations.isEmpty()) {
            return null;
        }
        String values = denominations.stream()
                .map(BigDecimal::toString)
                .collect(Collectors.joining(","));
        return "{" + values + "}";
    }

    /**
     * Parse string array from PostgreSQL
     */
    default List<String> parseStringArray(String array) {
        if (array == null || array.isEmpty()) {
            return List.of();
        }
        String cleaned = array.replaceAll("[{}]", "");
        return Arrays.stream(cleaned.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    /**
     * Format string list to PostgreSQL array
     * Returns null for empty lists to avoid inserting empty arrays
     */
    default String formatStringArray(List<String> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        // Escape quotes and format as PostgreSQL array
        String values = list.stream()
                .map(s -> s.replace("\"", "\\\"").replace("\\", "\\\\"))
                .map(s -> "\"" + s + "\"")
                .collect(Collectors.joining(","));
        return "{" + values + "}";
    }
}







