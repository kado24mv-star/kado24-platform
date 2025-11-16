package com.kado24.order.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.kado24.order.entity.Order.OrderStatus;
import com.kado24.order.entity.Order.PaymentStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Order information")
public class OrderDTO {

    @Schema(description = "Order ID", example = "1")
    private Long id;

    @Schema(description = "Order number", example = "ORD-20251111-001234")
    private String orderNumber;

    @Schema(description = "User ID", example = "5")
    private Long userId;

    @Schema(description = "Voucher ID", example = "10")
    private Long voucherId;

    @Schema(description = "Voucher title", example = "$25 Restaurant Voucher")
    private String voucherTitle;

    @Schema(description = "Merchant ID", example = "3")
    private Long merchantId;

    @Schema(description = "Merchant name", example = "Blue Pumpkin")
    private String merchantName;

    @Schema(description = "Quantity", example = "1")
    private Integer quantity;

    @Schema(description = "Denomination per voucher", example = "25.00")
    private BigDecimal denomination;

    @Schema(description = "Subtotal (quantity × denomination)", example = "25.00")
    private BigDecimal subtotal;

    @Schema(description = "Platform fee (8%)", example = "2.00")
    private BigDecimal platformFee;

    @Schema(description = "Merchant amount (92%)", example = "23.00")
    private BigDecimal merchantAmount;

    @Schema(description = "Total amount", example = "25.00")
    private BigDecimal totalAmount;

    @Schema(description = "Payment method", example = "ABA")
    private String paymentMethod;

    @Schema(description = "Payment status", example = "COMPLETED")
    private PaymentStatus paymentStatus;

    @Schema(description = "Order status", example = "CONFIRMED")
    private OrderStatus orderStatus;

    @Schema(description = "Payment ID from gateway")
    private String paymentId;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Order created date")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Schema(description = "Payment completed date")
    private LocalDateTime paidAt;
}



















