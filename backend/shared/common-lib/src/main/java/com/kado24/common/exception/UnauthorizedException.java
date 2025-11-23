package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when authentication fails or user is not authenticated
 */
public class UnauthorizedException extends BaseException {
    
    private static final String ERROR_CODE = "UNAUTHORIZED";
    
    public UnauthorizedException(String message) {
        super(message, ERROR_CODE, HttpStatus.UNAUTHORIZED);
    }
    
    public UnauthorizedException() {
        super("Authentication required", ERROR_CODE, HttpStatus.UNAUTHORIZED);
    }
}






































