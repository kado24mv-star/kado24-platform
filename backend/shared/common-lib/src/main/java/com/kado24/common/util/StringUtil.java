package com.kado24.common.util;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Utility class for string operations
 */
public final class StringUtil {
    
    private StringUtil() {
        throw new UnsupportedOperationException("Utility class");
    }
    
    private static final Pattern NON_LATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]");
    
    /**
     * Generate a random alphanumeric string
     */
    public static String generateRandomString(int length) {
        return RandomStringUtils.randomAlphanumeric(length);
    }
    
    /**
     * Generate a random numeric string
     */
    public static String generateRandomNumeric(int length) {
        return RandomStringUtils.randomNumeric(length);
    }
    
    /**
     * Generate a voucher code (e.g., "KADO-ABCD-1234")
     */
    public static String generateVoucherCode() {
        String part1 = RandomStringUtils.randomAlphabetic(4).toUpperCase();
        String part2 = RandomStringUtils.randomNumeric(4);
        return String.format("KADO-%s-%s", part1, part2);
    }
    
    /**
     * Generate an order number (e.g., "ORD-20251111-001234")
     */
    public static String generateOrderNumber() {
        String date = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE);
        String random = RandomStringUtils.randomNumeric(6);
        return String.format("ORD-%s-%s", date, random);
    }
    
    /**
     * Generate a payout number (e.g., "PAY-20251111-001234")
     */
    public static String generatePayoutNumber() {
        String date = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE);
        String random = RandomStringUtils.randomNumeric(6);
        return String.format("PAY-%s-%s", date, random);
    }
    
    /**
     * Create a URL-friendly slug from a string
     */
    public static String slugify(String input) {
        if (StringUtils.isBlank(input)) {
            return "";
        }
        
        String noWhitespace = WHITESPACE.matcher(input).replaceAll("-");
        String normalized = Normalizer.normalize(noWhitespace, Normalizer.Form.NFD);
        String slug = NON_LATIN.matcher(normalized).replaceAll("");
        return slug.toLowerCase(Locale.ENGLISH)
                .replaceAll("-{2,}", "-")
                .replaceAll("^-|-$", "");
    }
    
    /**
     * Mask phone number (e.g., "+85512345678" -> "+855****5678")
     */
    public static String maskPhoneNumber(String phoneNumber) {
        if (StringUtils.isBlank(phoneNumber) || phoneNumber.length() < 8) {
            return phoneNumber;
        }
        int visibleDigits = 4;
        int maskLength = phoneNumber.length() - visibleDigits - (phoneNumber.startsWith("+") ? 4 : 3);
        String prefix = phoneNumber.substring(0, phoneNumber.length() - visibleDigits - maskLength);
        String mask = "*".repeat(maskLength);
        String suffix = phoneNumber.substring(phoneNumber.length() - visibleDigits);
        return prefix + mask + suffix;
    }
    
    /**
     * Mask email (e.g., "user@example.com" -> "u***@example.com")
     */
    public static String maskEmail(String email) {
        if (StringUtils.isBlank(email) || !email.contains("@")) {
            return email;
        }
        String[] parts = email.split("@");
        if (parts[0].length() <= 1) {
            return email;
        }
        String masked = parts[0].charAt(0) + "***";
        return masked + "@" + parts[1];
    }
    
    /**
     * Truncate string to specified length with ellipsis
     */
    public static String truncate(String str, int maxLength) {
        if (StringUtils.isBlank(str) || str.length() <= maxLength) {
            return str;
        }
        return str.substring(0, maxLength - 3) + "...";
    }
    
    /**
     * Capitalize first letter of each word
     */
    public static String capitalizeWords(String str) {
        if (StringUtils.isBlank(str)) {
            return str;
        }
        return StringUtils.capitalize(str.toLowerCase());
    }
    
    /**
     * Check if string is a valid phone number format
     */
    public static boolean isValidPhoneNumber(String phoneNumber) {
        if (StringUtils.isBlank(phoneNumber)) {
            return false;
        }
        // Cambodia phone number format: +855 followed by 8-9 digits
        return phoneNumber.matches("^\\+855\\d{8,9}$");
    }
    
    /**
     * Check if string is a valid email format
     */
    public static boolean isValidEmail(String email) {
        if (StringUtils.isBlank(email)) {
            return false;
        }
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
    
    /**
     * Format currency amount (USD)
     */
    public static String formatCurrency(Double amount) {
        if (amount == null) {
            return "$0.00";
        }
        return String.format("$%.2f", amount);
    }
}



















