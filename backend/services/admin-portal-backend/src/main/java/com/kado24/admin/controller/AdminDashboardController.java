package com.kado24.admin.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@CrossOrigin(
    origins = {"http://localhost:4200", "http://localhost:9080"}, 
    allowCredentials = "true", 
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
public class AdminDashboardController {

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Map<String, Object> response = new HashMap<>();
        Map<String, Object> data = new HashMap<>();
        
        data.put("totalUsers", 150);
        data.put("totalMerchants", 28);
        data.put("totalVouchers", 142);
        data.put("totalOrders", 523);
        data.put("platformRevenue", 4184.00);
        
        response.put("success", true);
        response.put("data", data);
        
        return ResponseEntity.ok(response);
    }
}
