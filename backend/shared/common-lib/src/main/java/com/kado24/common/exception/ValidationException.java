package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when validation fails
 */
public class ValidationException extends BaseException {
    
    private static final String ERROR_CODE = "VALIDATION_ERROR";
    
    public ValidationException(String message) {
        super(message, ERROR_CODE, HttpStatus.BAD_REQUEST);
    }
    
    public ValidationException(String message, Object details) {
        super(message, ERROR_CODE, HttpStatus.BAD_REQUEST, details);
    }
}



















