package com.kado24.voucher.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Converter for PostgreSQL BigDecimal array types
 */
@Converter
public class PostgreSQLBigDecimalArrayConverter implements AttributeConverter<List<BigDecimal>, String> {

    @Override
    public String convertToDatabaseColumn(List<BigDecimal> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return null;
        }
        
        // Convert list to PostgreSQL array string format: {5.00,10.00,25.00}
        String values = attribute.stream()
                .map(BigDecimal::toString)
                .collect(Collectors.joining(","));
        
        return "{" + values + "}";
    }

    @Override
    public List<BigDecimal> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return null;
        }
        
        // Handle PostgreSQL array string format: {5.00,10.00,25.00}
        if (dbData.startsWith("{") && dbData.endsWith("}")) {
            String cleaned = dbData.substring(1, dbData.length() - 1);
            if (cleaned.isEmpty()) {
                return List.of();
            }
            return Arrays.stream(cleaned.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(BigDecimal::new)
                    .collect(Collectors.toList());
        }
        
        // Fallback: try to parse as single value
        try {
            return List.of(new BigDecimal(dbData));
        } catch (NumberFormatException e) {
            return List.of();
        }
    }
}

