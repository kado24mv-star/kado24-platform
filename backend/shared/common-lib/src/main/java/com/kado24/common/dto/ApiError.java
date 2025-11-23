package com.kado24.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Error details for API responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Error details")
public class ApiError {
    
    @Schema(description = "Error code", example = "VALIDATION_ERROR")
    private String code;
    
    @Schema(description = "Error message", example = "Validation failed for the request")
    private String message;
    
    @Schema(description = "Detailed error information")
    private Object details;
    
    @Schema(description = "Field-specific validation errors")
    private Map<String, String> fieldErrors;
    
    @Schema(description = "Error timestamp", example = "2025-11-11T10:15:30")
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();
    
    @Schema(description = "Stack trace (only in development)", example = "com.kado24.service.UserService...")
    private String stackTrace;
}






































