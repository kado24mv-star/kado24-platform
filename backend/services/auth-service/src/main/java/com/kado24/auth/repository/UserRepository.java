package com.kado24.auth.repository;

import com.kado24.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for User entity
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Find user by phone number
     */
    Optional<User> findByPhoneNumber(String phoneNumber);

    /**
     * Find user by email
     */
    Optional<User> findByEmail(String email);

    /**
     * Find user by phone number or email
     */
    @Query("SELECT u FROM User u WHERE u.phoneNumber = :identifier OR u.email = :identifier")
    Optional<User> findByPhoneNumberOrEmail(String identifier);

    /**
     * Check if phone number exists
     */
    boolean existsByPhoneNumber(String phoneNumber);

    /**
     * Check if email exists
     */
    boolean existsByEmail(String email);

    /**
     * Find active user by phone number
     */
    Optional<User> findByPhoneNumberAndStatus(String phoneNumber, User.UserStatus status);

    /**
     * Find active user by email
     */
    Optional<User> findByEmailAndStatus(String email, User.UserStatus status);
}



















