package com.kado24.user.service;

import com.kado24.common.exception.ResourceNotFoundException;
import com.kado24.common.exception.ValidationException;
import com.kado24.kafka.event.AuditEvent;
import com.kado24.kafka.producer.EventPublisher;
import com.kado24.user.dto.UpdateProfileRequest;
import com.kado24.user.dto.UserProfileDTO;
import com.kado24.user.entity.User;
import com.kado24.user.mapper.UserMapper;
import com.kado24.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

/**
 * User profile management service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final EventPublisher eventPublisher;

    /**
     * Get user profile by ID
     */
    public UserProfileDTO getUserProfile(Long userId) {
        log.debug("Fetching profile for user ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
        
        return userMapper.toDTO(user);
    }

    /**
     * Get user profile by phone number
     */
    public UserProfileDTO getUserByPhone(String phoneNumber) {
        log.debug("Fetching profile for phone: {}", phoneNumber);
        
        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseThrow(() -> new ResourceNotFoundException("User", phoneNumber));
        
        return userMapper.toDTO(user);
    }

    /**
     * Update user profile
     */
    @Transactional
    public UserProfileDTO updateProfile(Long userId, UpdateProfileRequest request) {
        log.info("Updating profile for user ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
        
        // Store old values for audit
        Map<String, Object> oldValues = new HashMap<>();
        Map<String, Object> newValues = new HashMap<>();
        
        // Update full name
        if (request.getFullName() != null && !request.getFullName().equals(user.getFullName())) {
            oldValues.put("fullName", user.getFullName());
            user.setFullName(request.getFullName());
            newValues.put("fullName", request.getFullName());
        }
        
        // Update email
        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
            // Check if email is already taken
            if (userRepository.findByEmail(request.getEmail()).isPresent()) {
                throw new ValidationException("Email is already in use");
            }
            oldValues.put("email", user.getEmail());
            user.setEmail(request.getEmail());
            user.setEmailVerified(false); // Require re-verification
            newValues.put("email", request.getEmail());
        }
        
        // Update avatar URL
        if (request.getAvatarUrl() != null && !request.getAvatarUrl().equals(user.getAvatarUrl())) {
            oldValues.put("avatarUrl", user.getAvatarUrl());
            user.setAvatarUrl(request.getAvatarUrl());
            newValues.put("avatarUrl", request.getAvatarUrl());
        }
        
        // Save changes
        user = userRepository.save(user);
        
        // Publish audit event
        if (!oldValues.isEmpty()) {
            publishProfileUpdateEvent(userId, oldValues, newValues);
        }
        
        log.info("Profile updated successfully for user ID: {}", userId);
        
        return userMapper.toDTO(user);
    }

    /**
     * Delete user account (soft delete)
     */
    @Transactional
    public void deleteAccount(Long userId) {
        log.info("Deleting account for user ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
        
        // Soft delete - change status
        user.setStatus(User.UserStatus.DELETED);
        userRepository.save(user);
        
        // Publish audit event
        publishAccountDeleteEvent(userId);
        
        log.info("Account deleted for user ID: {}", userId);
    }

    /**
     * Get all users (admin only)
     */
    public Page<UserProfileDTO> getAllUsers(Pageable pageable) {
        log.debug("Fetching all users with pagination");
        
        Page<User> users = userRepository.findAll(pageable);
        
        return users.map(userMapper::toDTO);
    }

    /**
     * Search users by name (admin only)
     */
    public Page<UserProfileDTO> searchUsers(String query, Pageable pageable) {
        log.debug("Searching users with query: {}", query);
        
        Page<User> users = userRepository.searchByName(query, pageable);
        
        return users.map(userMapper::toDTO);
    }

    /**
     * Get user statistics (admin only)
     */
    public Map<String, Long> getUserStatistics() {
        Map<String, Long> stats = new HashMap<>();
        
        stats.put("totalUsers", userRepository.count());
        stats.put("totalConsumers", userRepository.countByRole(User.UserRole.CONSUMER));
        stats.put("totalMerchants", userRepository.countByRole(User.UserRole.MERCHANT));
        stats.put("activeUsers", userRepository.countByStatus(User.UserStatus.ACTIVE));
        stats.put("pendingVerification", userRepository.countByStatus(User.UserStatus.PENDING_VERIFICATION));
        
        return stats;
    }

    /**
     * Publish profile update audit event
     */
    private void publishProfileUpdateEvent(Long userId, Map<String, Object> oldValues, 
                                          Map<String, Object> newValues) {
        try {
            AuditEvent event = AuditEvent.update(userId, "USER", userId, oldValues, newValues, null);
            eventPublisher.publishAuditEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish profile update event", e);
        }
    }

    /**
     * Publish account delete audit event
     */
    private void publishAccountDeleteEvent(Long userId) {
        try {
            AuditEvent event = AuditEvent.builder()
                    .userId(userId)
                    .action(AuditEvent.DELETE)
                    .entityType("USER")
                    .entityId(userId)
                    .build();
            event.initDefaults(AuditEvent.DELETE, "user-service");
            eventPublisher.publishAuditEvent(event);
        } catch (Exception e) {
            log.error("Failed to publish account delete event", e);
        }
    }
}



















