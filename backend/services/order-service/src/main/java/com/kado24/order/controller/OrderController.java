package com.kado24.order.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.dto.PageRequest;
import com.kado24.common.dto.PaginationMeta;
import com.kado24.order.dto.CreateOrderRequest;
import com.kado24.order.dto.OrderDTO;
import com.kado24.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Order management REST controller
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Orders", description = "Order management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class OrderController {

    private final OrderService orderService;

    @Operation(summary = "Create order", description = "Create new order for voucher purchase")
    @PostMapping
    public ResponseEntity<ApiResponse<OrderDTO>> createOrder(
            HttpServletRequest request,
            @Valid @RequestBody CreateOrderRequest createRequest) {

        Long userId = (Long) request.getAttribute("userId");

        log.info("Creating order for user: {}", userId);

        OrderDTO order = orderService.createOrder(userId, createRequest);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Order created successfully", order));
    }

    @Operation(summary = "Get order", description = "Get order by ID")
    @GetMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderDTO>> getOrder(@PathVariable Long orderId) {
        log.info("Fetching order: {}", orderId);

        OrderDTO order = orderService.getOrder(orderId);

        return ResponseEntity.ok(ApiResponse.success(order));
    }

    @Operation(summary = "Get my orders", description = "Get current user's orders")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<OrderDTO>>> getMyOrders(
            HttpServletRequest request,
            @ModelAttribute PageRequest pageRequest) {

        Long userId = (Long) request.getAttribute("userId");

        log.info("Fetching orders for user: {}", userId);

        Page<OrderDTO> orders = orderService.getUserOrders(userId, pageRequest.toSpringPageRequest());

        PaginationMeta pagination = PaginationMeta.from(
                orders.getNumber(),
                orders.getSize(),
                orders.getTotalElements()
        );

        return ResponseEntity.ok(ApiResponse.paginated(orders, pagination));
    }

    @Operation(summary = "Cancel order", description = "Cancel pending order")
    @PostMapping("/{orderId}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelOrder(
            HttpServletRequest request,
            @PathVariable Long orderId) {

        Long userId = (Long) request.getAttribute("userId");

        log.info("Cancelling order: {} by user: {}", orderId, userId);

        orderService.cancelOrder(orderId, userId);

        return ResponseEntity.ok(ApiResponse.success("Order cancelled successfully", null));
    }
}



















