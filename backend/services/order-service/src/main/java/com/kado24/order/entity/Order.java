package com.kado24.order.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Order entity
 */
@Entity
@Table(name = "orders", schema = "order_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String orderNumber;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long voucherId;

    @Column(nullable = false)
    private Long merchantId;

    // Pricing
    @Builder.Default
    @Column(nullable = false)
    private Integer quantity = 1;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal denomination;
    
    @Column(name = "voucher_value", nullable = false, precision = 10, scale = 2)
    private BigDecimal voucherValue;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal platformFee; // 8% commission
    
    @Column(name = "platform_commission", nullable = false, precision = 10, scale = 2)
    private BigDecimal platformCommission; // Same as platformFee

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal merchantAmount; // 92% payout
    
    @Column(name = "merchant_earnings", nullable = false, precision = 10, scale = 2)
    private BigDecimal merchantEarnings; // Same as merchantAmount

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    // Payment
    @Column(length = 50)
    private String paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @Column(length = 255)
    private String paymentId; // External payment gateway ID

    private LocalDateTime paidAt;

    // Order status
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private OrderStatus orderStatus = OrderStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String customerNotes;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb", nullable = true)
    private String metadata;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public enum PaymentStatus {
        PENDING,
        PROCESSING,
        COMPLETED,
        FAILED,
        REFUNDED,
        CANCELLED
    }

    public enum OrderStatus {
        PENDING,
        CONFIRMED,
        CANCELLED,
        REFUNDED
    }

    /**
     * Confirm order after successful payment
     */
    public void confirm(String paymentId) {
        this.orderStatus = OrderStatus.CONFIRMED;
        this.paymentStatus = PaymentStatus.COMPLETED;
        this.paymentId = paymentId;
        this.paidAt = LocalDateTime.now();
    }

    /**
     * Cancel order
     */
    public void cancel() {
        this.orderStatus = OrderStatus.CANCELLED;
        this.paymentStatus = PaymentStatus.CANCELLED;
    }

    /**
     * Check if order is confirmed
     */
    public boolean isConfirmed() {
        return this.orderStatus == OrderStatus.CONFIRMED;
    }
}







