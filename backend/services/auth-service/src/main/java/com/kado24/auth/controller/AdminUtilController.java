package com.kado24.auth.controller;

import com.kado24.auth.entity.User;
import com.kado24.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Temporary utility controller for admin operations
 * TODO: Remove this in production or secure it properly
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/admin-utils")
@RequiredArgsConstructor
public class AdminUtilController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Generate BCrypt hash for a password
     * GET /api/v1/admin-utils/generate-hash?password=Admin@123456
     */
    @GetMapping("/generate-hash")
    public ResponseEntity<Map<String, String>> generateHash(@RequestParam String password) {
        String hash = passwordEncoder.encode(password);
        
        Map<String, String> response = new HashMap<>();
        response.put("password", password);
        response.put("hash", hash);
        response.put("verified", String.valueOf(passwordEncoder.matches(password, hash)));
        
        log.info("Generated hash for password: {}", password);
        
        return ResponseEntity.ok(response);
    }

    /**
     * Update admin user password
     * POST /api/v1/admin-utils/update-admin-password
     * Body: {"password": "Admin@123456"}
     */
    @PostMapping("/update-admin-password")
    public ResponseEntity<Map<String, String>> updateAdminPassword(@RequestBody Map<String, String> request) {
        String password = request.get("password");
        
        User admin = userRepository.findByEmail("admin@kado24.com")
                .orElseThrow(() -> new RuntimeException("Admin user not found"));
        
        String hash = passwordEncoder.encode(password);
        admin.setPasswordHash(hash);
        userRepository.save(admin);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Admin password updated successfully");
        response.put("email", admin.getEmail());
        response.put("hash", hash);
        response.put("verified", String.valueOf(passwordEncoder.matches(password, hash)));
        
        log.info("Updated admin password for: {}", admin.getEmail());
        
        return ResponseEntity.ok(response);
    }
}

