package com.kado24.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception thrown when payment processing fails
 */
public class PaymentException extends BaseException {
    
    private static final String ERROR_CODE = "PAYMENT_ERROR";
    
    public PaymentException(String message) {
        super(message, ERROR_CODE, HttpStatus.PAYMENT_REQUIRED);
    }
    
    public PaymentException(String message, String errorCode) {
        super(message, errorCode, HttpStatus.PAYMENT_REQUIRED);
    }
    
    public PaymentException(String message, Throwable cause) {
        super(message, cause, ERROR_CODE, HttpStatus.PAYMENT_REQUIRED);
    }
}






































