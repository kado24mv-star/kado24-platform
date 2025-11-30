package com.kado24.voucher.entity;

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
import java.util.List;

/**
 * Voucher entity
 */
@Entity
@Table(name = "vouchers", schema = "voucher_schema", indexes = {
        @Index(name = "idx_vouchers_merchant", columnList = "merchantId"),
        @Index(name = "idx_vouchers_category", columnList = "categoryId"),
        @Index(name = "idx_vouchers_status", columnList = "status"),
        @Index(name = "idx_vouchers_slug", columnList = "slug")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Voucher {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "merchant_id", nullable = false)
    private Long merchantId;

    @Column(name = "category_id")
    private Long categoryId;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String slug;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "terms_conditions", columnDefinition = "TEXT", nullable = true)
    private String termsAndConditions;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "denominations", columnDefinition = "numeric[]")
    private BigDecimal[] denominations;

    @Column(name = "discount_percentage", precision = 5, scale = 2)
    private BigDecimal discountPercentage;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "additional_image", columnDefinition = "text[]", nullable = true)
    private String[] additionalImages;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private VoucherStatus status = VoucherStatus.DRAFT;

    @Column(name = "stock_quantity")
    private Integer stockQuantity;

    @Builder.Default
    @Column(name = "unlimited_stock")
    private Boolean unlimitedStock = false;

    @Column(name = "valid_from")
    private LocalDateTime validFrom;

    @Column(name = "valid_until")
    private LocalDateTime validUntil;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "redemption_locations", columnDefinition = "text[]", nullable = true)
    private String[] redemptionLocations;

    @Column(name = "min_value", precision = 10, scale = 2, nullable = false)
    private BigDecimal minValue;

    @Column(name = "max_value", precision = 10, scale = 2, nullable = false)
    private BigDecimal maxValue;

    @Column(name = "min_purchase_amount", precision = 10, scale = 2)
    private BigDecimal minPurchaseAmount;

    @Column(name = "max_purchase_per_user")
    private Integer maxPurchasePerUser;

    @Column(name = "usage_instructions", columnDefinition = "TEXT", nullable = true)
    private String usageInstructions;

    @Builder.Default
    @Column(name = "total_sold")
    private Integer totalSold = 0;

    @Builder.Default
    @Column(name = "total_redeemed")
    private Integer totalRedeemed = 0;

    @Builder.Default
    @Column(name = "rating", precision = 3, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "total_reviews")
    private Integer totalReviews = 0;

    @Builder.Default
    @Column(name = "view_count")
    private Integer viewCount = 0;

    @Column(name = "meta_title", length = 255)
    private String metaTitle;

    @Column(name = "meta_description", columnDefinition = "TEXT", nullable = true)
    private String metaDescription;

    @CreationTimestamp
    @Column(name = "createdat", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updatedat", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb", nullable = true)
    private String metadata;

    public enum VoucherStatus {
        DRAFT,
        ACTIVE,
        PAUSED,
        EXPIRED,
        DELETED
    }

    /**
     * Check if voucher is available for purchase
     */
    public boolean isAvailable() {
        if (this.status != VoucherStatus.ACTIVE) {
            return false;
        }

        LocalDateTime now = LocalDateTime.now();
        if (this.validFrom != null && now.isBefore(this.validFrom)) {
            return false;
        }
        if (this.validUntil != null && now.isAfter(this.validUntil)) {
            return false;
        }

        if (!this.unlimitedStock && (this.stockQuantity == null || this.stockQuantity <= 0)) {
            return false;
        }

        return true;
    }

    /**
     * Increment view count
     */
    public void incrementViewCount() {
        this.viewCount = (this.viewCount != null ? this.viewCount : 0) + 1;
    }

    /**
     * Increment total sold
     */
    public void incrementTotalSold(int quantity) {
        this.totalSold = (this.totalSold != null ? this.totalSold : 0) + quantity;
        if (!this.unlimitedStock && this.stockQuantity != null) {
            this.stockQuantity = Math.max(0, this.stockQuantity - quantity);
        }
    }

    /**
     * Update rating
     */
    public void updateRating(BigDecimal newRating, int reviewCount) {
        this.rating = newRating;
        this.totalReviews = reviewCount;
    }
}







