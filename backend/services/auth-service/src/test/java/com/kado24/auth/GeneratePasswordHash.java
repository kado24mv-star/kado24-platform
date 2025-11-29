package com.kado24.auth;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Utility to generate BCrypt hash for admin password
 * Run: mvn test-compile exec:java -Dexec.mainClass="com.kado24.auth.GeneratePasswordHash"
 */
public class GeneratePasswordHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(10);
        String password = "Admin@123456";
        String hash = encoder.encode(password);
        
        System.out.println("========================================");
        System.out.println("Password: " + password);
        System.out.println("BCrypt Hash: " + hash);
        System.out.println("========================================");
        System.out.println("Verification: " + encoder.matches(password, hash));
        System.out.println("========================================");
    }
}

