package com.kado24.common.util;

import org.apache.commons.lang3.StringUtils;

/**
 * Utility class for Cambodia phone number operations
 * Supports both "0" prefix (local format) and "+855" prefix (international format)
 */
public final class PhoneNumberUtil {
    
    private PhoneNumberUtil() {
        throw new UnsupportedOperationException("Utility class");
    }
    
    private static final String CAMBODIA_COUNTRY_CODE = "+855";
    private static final String CAMBODIA_LOCAL_PREFIX = "0";
    
    /**
     * Normalize phone number to international format (+855XXXXXXXX)
     * Accepts:
     * - "0XXXXXXXX" -> "+855XXXXXXXX"
     * - "+855XXXXXXXX" -> "+855XXXXXXXX" (no change)
     * - "855XXXXXXXX" -> "+855XXXXXXXX"
     * 
     * @param phoneNumber Phone number in any format
     * @return Normalized phone number in +855 format, or null if invalid
     */
    public static String normalize(String phoneNumber) {
        if (StringUtils.isBlank(phoneNumber)) {
            return null;
        }
        
        // Remove all spaces, dashes, and parentheses
        String cleaned = phoneNumber.replaceAll("[\\s\\-\\(\\)]", "");
        
        // Handle "0" prefix (local format) - convert to +855
        if (cleaned.startsWith(CAMBODIA_LOCAL_PREFIX)) {
            // Remove leading "0" and add +855
            String digits = cleaned.substring(1);
            if (isValidDigits(digits)) {
                return CAMBODIA_COUNTRY_CODE + digits;
            }
        }
        
        // Handle "+855" prefix (already in international format)
        if (cleaned.startsWith(CAMBODIA_COUNTRY_CODE)) {
            String digits = cleaned.substring(4); // Remove "+855"
            if (isValidDigits(digits)) {
                return CAMBODIA_COUNTRY_CODE + digits;
            }
        }
        
        // Handle "855" prefix (without +)
        if (cleaned.startsWith("855") && cleaned.length() >= 11) {
            String digits = cleaned.substring(3); // Remove "855"
            if (isValidDigits(digits)) {
                return CAMBODIA_COUNTRY_CODE + digits;
            }
        }
        
        // If already in correct format, return as is
        if (cleaned.startsWith("+") && cleaned.length() >= 12) {
            return cleaned;
        }
        
        return null;
    }
    
    /**
     * Check if phone number is valid (accepts both 0 and +855 formats)
     * 
     * @param phoneNumber Phone number to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValid(String phoneNumber) {
        if (StringUtils.isBlank(phoneNumber)) {
            return false;
        }
        
        String cleaned = phoneNumber.replaceAll("[\\s\\-\\(\\)]", "");
        
        // Check for "0" prefix format (0XXXXXXXX where X is 8-9 digits)
        if (cleaned.startsWith(CAMBODIA_LOCAL_PREFIX)) {
            String digits = cleaned.substring(1);
            return isValidDigits(digits);
        }
        
        // Check for "+855" format
        if (cleaned.startsWith(CAMBODIA_COUNTRY_CODE)) {
            String digits = cleaned.substring(4);
            return isValidDigits(digits);
        }
        
        // Check for "855" format (without +)
        if (cleaned.startsWith("855") && cleaned.length() >= 11) {
            String digits = cleaned.substring(3);
            return isValidDigits(digits);
        }
        
        return false;
    }
    
    /**
     * Validate that digits are 8-9 digits (Cambodia phone number length)
     */
    private static boolean isValidDigits(String digits) {
        if (StringUtils.isBlank(digits)) {
            return false;
        }
        // Cambodia phone numbers are 8-9 digits after country code
        return digits.matches("^\\d{8,9}$");
    }
    
    /**
     * Format phone number for display (e.g., "+855 12 345 678")
     */
    public static String formatForDisplay(String phoneNumber) {
        String normalized = normalize(phoneNumber);
        if (normalized == null) {
            return phoneNumber;
        }
        
        // Format: +855 XX XXX XXX
        if (normalized.length() == 12) { // +855 + 8 digits
            return String.format("%s %s %s %s",
                normalized.substring(0, 4), // +855
                normalized.substring(4, 6), // XX
                normalized.substring(6, 9),  // XXX
                normalized.substring(9));   // XXX
        } else if (normalized.length() == 13) { // +855 + 9 digits
            return String.format("%s %s %s %s",
                normalized.substring(0, 4), // +855
                normalized.substring(4, 6), // XX
                normalized.substring(6, 9), // XXX
                normalized.substring(9));   // XXXX
        }
        
        return normalized;
    }
    
    /**
     * Convert international format to local format (for display)
     * +85512345678 -> 012345678
     */
    public static String toLocalFormat(String phoneNumber) {
        String normalized = normalize(phoneNumber);
        if (normalized == null || !normalized.startsWith(CAMBODIA_COUNTRY_CODE)) {
            return phoneNumber;
        }
        
        return CAMBODIA_LOCAL_PREFIX + normalized.substring(4);
    }
}

