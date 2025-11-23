package com.kado24.order.repository;

import com.kado24.order.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for Order entity
 */
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    /**
     * Find order by order number
     */
    Optional<Order> findByOrderNumber(String orderNumber);

    /**
     * Find user's orders
     */
    Page<Order> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * Find merchant's orders
     */
    Page<Order> findByMerchantIdOrderByCreatedAtDesc(Long merchantId, Pageable pageable);

    /**
     * Find orders by payment status
     */
    Page<Order> findByPaymentStatusOrderByCreatedAtDesc(
            Order.PaymentStatus status, Pageable pageable);

    /**
     * Find confirmed orders for merchant (for payout calculation)
     */
    @Query("SELECT o FROM Order o WHERE o.merchantId = :merchantId " +
           "AND o.orderStatus = 'CONFIRMED' " +
           "AND o.paymentStatus = 'COMPLETED'")
    Page<Order> findConfirmedOrdersByMerchant(Long merchantId, Pageable pageable);

    /**
     * Count orders by user
     */
    long countByUserId(Long userId);

    /**
     * Count orders by merchant
     */
    long countByMerchantId(Long merchantId);

    /**
     * Find all orders ordered by created date (Admin)
     */
    Page<Order> findAllByOrderByCreatedAtDesc(Pageable pageable);

    /**
     * Find orders by status ordered by created date (Admin)
     */
    Page<Order> findByOrderStatusOrderByCreatedAtDesc(Order.OrderStatus status, Pageable pageable);
}






















