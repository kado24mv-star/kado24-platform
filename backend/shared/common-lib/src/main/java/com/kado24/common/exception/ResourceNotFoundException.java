package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when a requested resource is not found
 */
public class ResourceNotFoundException extends BaseException {
    
    private static final String ERROR_CODE = "RESOURCE_NOT_FOUND";
    
    public ResourceNotFoundException(String resource, String identifier) {
        super(
            String.format("%s not found with identifier: %s", resource, identifier),
            ERROR_CODE,
            HttpStatus.NOT_FOUND
        );
    }
    
    public ResourceNotFoundException(String resource, Long id) {
        super(
            String.format("%s not found with id: %d", resource, id),
            ERROR_CODE,
            HttpStatus.NOT_FOUND
        );
    }
    
    public ResourceNotFoundException(String message) {
        super(message, ERROR_CODE, HttpStatus.NOT_FOUND);
    }
}



















