package com.kado24.voucher.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Converter for PostgreSQL String array types
 */
@Converter
public class PostgreSQLStringArrayConverter implements AttributeConverter<List<String>, String> {

    @Override
    public String convertToDatabaseColumn(List<String> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return null;
        }
        
        // Convert list to PostgreSQL array string format: {"value1","value2"}
        // Escape quotes and backslashes in values
        String values = attribute.stream()
                .filter(s -> s != null && !s.isEmpty())
                .map(s -> s.replace("\\", "\\\\").replace("\"", "\\\""))
                .map(s -> "\"" + s + "\"")
                .collect(Collectors.joining(","));
        
        if (values.isEmpty()) {
            return null;
        }
        
        return "{" + values + "}";
    }

    @Override
    public List<String> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return null;
        }
        
        // Handle PostgreSQL array string format: {"value1","value2"}
        if (dbData.startsWith("{") && dbData.endsWith("}")) {
            String cleaned = dbData.substring(1, dbData.length() - 1);
            if (cleaned.isEmpty()) {
                return List.of();
            }
            
            // Parse quoted strings, handling escaped quotes
            List<String> result = Arrays.stream(cleaned.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)"))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(s -> {
                        // Remove surrounding quotes if present
                        if (s.startsWith("\"") && s.endsWith("\"")) {
                            s = s.substring(1, s.length() - 1);
                        }
                        // Unescape quotes and backslashes
                        return s.replace("\\\"", "\"").replace("\\\\", "\\");
                    })
                    .collect(Collectors.toList());
            
            return result;
        }
        
        // Fallback: return as single-item list
        return List.of(dbData);
    }
}


