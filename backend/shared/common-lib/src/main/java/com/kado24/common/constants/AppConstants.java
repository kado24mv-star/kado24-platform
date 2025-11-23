package com.kado24.common.constants;

/**
 * Application-wide constants for Kado24 platform
 */
public final class AppConstants {
    
    private AppConstants() {
        throw new UnsupportedOperationException("Constants class");
    }
    
    // ============================================
    // Business Constants
    // ============================================
    
    /**
     * Platform commission percentage (8%)
     */
    public static final double PLATFORM_COMMISSION_RATE = 0.08;
    
    /**
     * Merchant payout percentage (92%)
     */
    public static final double MERCHANT_PAYOUT_RATE = 0.92;
    
    /**
     * Default voucher validity in days
     */
    public static final int DEFAULT_VOUCHER_VALIDITY_DAYS = 365;
    
    /**
     * Maximum voucher per user purchase limit
     */
    public static final int MAX_VOUCHER_PER_USER = 10;
    
    /**
     * Minimum voucher amount (USD)
     */
    public static final double MIN_VOUCHER_AMOUNT = 5.00;
    
    /**
     * Maximum voucher amount (USD)
     */
    public static final double MAX_VOUCHER_AMOUNT = 1000.00;
    
    /**
     * Payout schedule day (Friday = 5)
     */
    public static final int PAYOUT_DAY_OF_WEEK = 5;
    
    // ============================================
    // Security Constants
    // ============================================
    
    /**
     * JWT token expiration in seconds (24 hours)
     */
    public static final long JWT_EXPIRATION_SECONDS = 86400;
    
    /**
     * Refresh token expiration in seconds (7 days)
     */
    public static final long REFRESH_TOKEN_EXPIRATION_SECONDS = 604800;
    
    /**
     * OTP expiration in seconds (5 minutes)
     */
    public static final long OTP_EXPIRATION_SECONDS = 300;
    
    /**
     * OTP length
     */
    public static final int OTP_LENGTH = 6;
    
    /**
     * Password minimum length
     */
    public static final int PASSWORD_MIN_LENGTH = 8;
    
    /**
     * Maximum login attempts before account lock
     */
    public static final int MAX_LOGIN_ATTEMPTS = 5;
    
    // ============================================
    // Pagination Constants
    // ============================================
    
    /**
     * Default page size for paginated results
     */
    public static final int DEFAULT_PAGE_SIZE = 20;
    
    /**
     * Maximum page size allowed
     */
    public static final int MAX_PAGE_SIZE = 100;
    
    /**
     * Default sort direction
     */
    public static final String DEFAULT_SORT_DIRECTION = "DESC";
    
    // ============================================
    // File Upload Constants
    // ============================================
    
    /**
     * Maximum file size in bytes (5 MB)
     */
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024;
    
    /**
     * Allowed image mime types
     */
    public static final String[] ALLOWED_IMAGE_TYPES = {
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/gif",
        "image/webp"
    };
    
    /**
     * Allowed document mime types
     */
    public static final String[] ALLOWED_DOCUMENT_TYPES = {
        "application/pdf",
        "image/jpeg",
        "image/jpg",
        "image/png"
    };
    
    // ============================================
    // Cache Keys
    // ============================================
    
    public static final String CACHE_VOUCHERS = "vouchers";
    public static final String CACHE_CATEGORIES = "categories";
    public static final String CACHE_MERCHANTS = "merchants";
    public static final String CACHE_USER_PROFILE = "user:profile:";
    public static final String CACHE_OTP = "otp:";
    
    // ============================================
    // Kafka Topics
    // ============================================
    
    public static final String TOPIC_ORDER_EVENTS = "order-events";
    public static final String TOPIC_PAYMENT_EVENTS = "payment-events";
    public static final String TOPIC_NOTIFICATION_EVENTS = "notification-events";
    public static final String TOPIC_REDEMPTION_EVENTS = "redemption-events";
    public static final String TOPIC_ANALYTICS_EVENTS = "analytics-events";
    public static final String TOPIC_AUDIT_EVENTS = "audit-events";
    
    // ============================================
    // Notification Types
    // ============================================
    
    public static final String NOTIFICATION_ORDER_CONFIRMED = "ORDER_CONFIRMED";
    public static final String NOTIFICATION_PAYMENT_SUCCESS = "PAYMENT_SUCCESS";
    public static final String NOTIFICATION_PAYMENT_FAILED = "PAYMENT_FAILED";
    public static final String NOTIFICATION_VOUCHER_REDEEMED = "VOUCHER_REDEEMED";
    public static final String NOTIFICATION_VOUCHER_EXPIRING = "VOUCHER_EXPIRING";
    public static final String NOTIFICATION_PAYOUT_PROCESSED = "PAYOUT_PROCESSED";
    public static final String NOTIFICATION_MERCHANT_APPROVED = "MERCHANT_APPROVED";
    public static final String NOTIFICATION_MERCHANT_REJECTED = "MERCHANT_REJECTED";
    
    // ============================================
    // User Roles
    // ============================================
    
    public static final String ROLE_CONSUMER = "CONSUMER";
    public static final String ROLE_MERCHANT = "MERCHANT";
    public static final String ROLE_ADMIN = "ADMIN";
    
    // ============================================
    // HTTP Headers
    // ============================================
    
    public static final String HEADER_AUTHORIZATION = "Authorization";
    public static final String HEADER_BEARER_PREFIX = "Bearer ";
    public static final String HEADER_REQUEST_ID = "X-Request-Id";
    public static final String HEADER_USER_AGENT = "User-Agent";
    public static final String HEADER_CLIENT_IP = "X-Forwarded-For";
    
    // ============================================
    // API Endpoints
    // ============================================
    
    public static final String API_VERSION = "/api/v1";
    public static final String AUTH_ENDPOINT = API_VERSION + "/auth";
    public static final String USERS_ENDPOINT = API_VERSION + "/users";
    public static final String VOUCHERS_ENDPOINT = API_VERSION + "/vouchers";
    public static final String ORDERS_ENDPOINT = API_VERSION + "/orders";
    public static final String PAYMENTS_ENDPOINT = API_VERSION + "/payments";
    public static final String WALLET_ENDPOINT = API_VERSION + "/wallet";
    public static final String MERCHANTS_ENDPOINT = API_VERSION + "/merchants";
    public static final String ADMIN_ENDPOINT = "/api/admin";
    
    // ============================================
    // Date/Time Formats
    // ============================================
    
    public static final String DATE_FORMAT = "yyyy-MM-dd";
    public static final String DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
    public static final String TIME_FORMAT = "HH:mm:ss";
    
    // ============================================
    // Currencies
    // ============================================
    
    public static final String CURRENCY_USD = "USD";
    public static final String CURRENCY_KHR = "KHR";
    
    // ============================================
    // Payment Methods
    // ============================================
    
    public static final String PAYMENT_METHOD_ABA = "ABA";
    public static final String PAYMENT_METHOD_WING = "WING";
    public static final String PAYMENT_METHOD_PI_PAY = "PI_PAY";
    public static final String PAYMENT_METHOD_KHQR = "KHQR";
}






































