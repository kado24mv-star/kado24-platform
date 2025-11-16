package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when there's a conflict with existing data
 */
public class ConflictException extends BaseException {
    
    private static final String ERROR_CODE = "CONFLICT";
    
    public ConflictException(String message) {
        super(message, ERROR_CODE, HttpStatus.CONFLICT);
    }
    
    public ConflictException(String message, Object details) {
        super(message, ERROR_CODE, HttpStatus.CONFLICT, details);
    }
}



















