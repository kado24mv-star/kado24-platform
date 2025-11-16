package com.kado24.security.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Utility class for password encoding operations
 */
public final class PasswordEncoderUtil {

    private PasswordEncoderUtil() {
        throw new UnsupportedOperationException("Utility class");
    }

    private static final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);

    /**
     * Encode a raw password
     */
    public static String encode(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    /**
     * Check if raw password matches encoded password
     */
    public static boolean matches(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    /**
     * Get the password encoder instance
     */
    public static PasswordEncoder getEncoder() {
        return passwordEncoder;
    }

    /**
     * Validate password strength
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }

        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;

        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else hasSpecial = true;
        }

        // Password must have at least 3 of the 4 criteria
        int criteriaCount = (hasUpper ? 1 : 0) + (hasLower ? 1 : 0) + 
                           (hasDigit ? 1 : 0) + (hasSpecial ? 1 : 0);
        
        return criteriaCount >= 3;
    }

    /**
     * Get password strength message
     */
    public static String getPasswordStrengthMessage(String password) {
        if (password == null || password.isEmpty()) {
            return "Password is required";
        }
        
        if (password.length() < 8) {
            return "Password must be at least 8 characters long";
        }

        if (!isStrongPassword(password)) {
            return "Password must contain at least 3 of: uppercase letter, lowercase letter, digit, special character";
        }

        return "Password is strong";
    }
}



















