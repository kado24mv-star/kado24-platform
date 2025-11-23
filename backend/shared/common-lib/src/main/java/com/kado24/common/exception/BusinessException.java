package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown for business logic violations
 */
public class BusinessException extends BaseException {
    
    private static final String ERROR_CODE = "BUSINESS_ERROR";
    
    public BusinessException(String message) {
        super(message, ERROR_CODE, HttpStatus.BAD_REQUEST);
    }
    
    public BusinessException(String message, String errorCode) {
        super(message, errorCode, HttpStatus.BAD_REQUEST);
    }
    
    public BusinessException(String message, Object details) {
        super(message, ERROR_CODE, HttpStatus.BAD_REQUEST, details);
    }
}






































