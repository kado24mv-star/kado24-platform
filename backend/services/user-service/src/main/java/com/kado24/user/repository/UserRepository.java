package com.kado24.user.repository;

import com.kado24.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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
     * Search users by name
     */
    @Query("SELECT u FROM User u WHERE LOWER(u.fullName) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<User> searchByName(@Param("query") String query, Pageable pageable);

    /**
     * Find users by role
     */
    Page<User> findByRole(User.UserRole role, Pageable pageable);

    /**
     * Find users by status
     */
    Page<User> findByStatus(User.UserStatus status, Pageable pageable);

    /**
     * Count users by role
     */
    long countByRole(User.UserRole role);

    /**
     * Count active users
     */
    long countByStatus(User.UserStatus status);
}






































