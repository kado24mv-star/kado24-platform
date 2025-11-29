package com.kado24.admin.controller;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/admin")
@CrossOrigin(
    origins = {"http://localhost:4200", "http://localhost:9080"}, 
    allowCredentials = "true", 
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
public class AdminDashboardController {

    @PersistenceContext
    private EntityManager entityManager;

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Map<String, Object> response = new HashMap<>();
        Map<String, Object> data = new HashMap<>();
        
        // Get total users (excluding admin) - independent query
        try {
            Query userQuery = entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM auth_schema.users WHERE role != 'ADMIN'"
            );
            long totalUsers = ((Number) userQuery.getSingleResult()).longValue();
            log.info("Dashboard query - Total users: {}", totalUsers);
            data.put("totalUsers", totalUsers);
        } catch (Exception e) {
            log.error("Error querying total users: {}", e.getMessage(), e);
            data.put("totalUsers", 0);
        }
        
        // Get total merchants - independent query
        try {
            Query merchantQuery = entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM merchant_schema.merchants"
            );
            long totalMerchants = ((Number) merchantQuery.getSingleResult()).longValue();
            log.info("Dashboard query - Total merchants: {}", totalMerchants);
            data.put("totalMerchants", totalMerchants);
        } catch (Exception e) {
            log.error("Error querying total merchants: {}", e.getMessage(), e);
            data.put("totalMerchants", 0);
        }
        
        // Get total vouchers - independent query
        try {
            Query voucherQuery = entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM voucher_schema.vouchers"
            );
            long totalVouchers = ((Number) voucherQuery.getSingleResult()).longValue();
            log.info("Dashboard query - Total vouchers: {}", totalVouchers);
            data.put("totalVouchers", totalVouchers);
        } catch (Exception e) {
            log.error("Error querying total vouchers: {}", e.getMessage(), e);
            data.put("totalVouchers", 0);
        }
        
        // Get total orders - independent query
        try {
            Query orderQuery = entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM order_schema.orders"
            );
            long totalOrders = ((Number) orderQuery.getSingleResult()).longValue();
            log.info("Dashboard query - Total orders: {}", totalOrders);
            data.put("totalOrders", totalOrders);
        } catch (Exception e) {
            log.error("Error querying total orders: {}", e.getMessage(), e);
            data.put("totalOrders", 0);
        }
        
        // Get platform revenue (sum of commission from completed orders) - independent query
        try {
            Query revenueQuery = entityManager.createNativeQuery(
                "SELECT COALESCE(SUM(platform_commission), 0) FROM order_schema.orders WHERE status = 'COMPLETED'"
            );
            Object revenueResult = revenueQuery.getSingleResult();
            double platformRevenue = 0.0;
            if (revenueResult != null) {
                if (revenueResult instanceof BigDecimal) {
                    platformRevenue = ((BigDecimal) revenueResult).doubleValue();
                } else if (revenueResult instanceof Number) {
                    platformRevenue = ((Number) revenueResult).doubleValue();
                }
            }
            log.info("Dashboard query - Platform revenue: {}", platformRevenue);
            data.put("platformRevenue", platformRevenue);
        } catch (Exception e) {
            log.error("Error querying platform revenue: {}", e.getMessage(), e);
            data.put("platformRevenue", 0.0);
        }
        
        response.put("success", true);
        response.put("data", data);
        
        return ResponseEntity.ok(response);
    }
}
