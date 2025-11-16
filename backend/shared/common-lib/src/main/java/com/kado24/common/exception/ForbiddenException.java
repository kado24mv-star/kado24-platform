package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when user doesn't have permission to access a resource
 */
public class ForbiddenException extends BaseException {
    
    private static final String ERROR_CODE = "FORBIDDEN";
    
    public ForbiddenException(String message) {
        super(message, ERROR_CODE, HttpStatus.FORBIDDEN);
    }
    
    public ForbiddenException() {
        super("You don't have permission to access this resource", ERROR_CODE, HttpStatus.FORBIDDEN);
    }
}



















