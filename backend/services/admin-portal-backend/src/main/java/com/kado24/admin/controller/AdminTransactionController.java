package com.kado24.admin.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(
    origins = {"http://localhost:4200", "http://localhost:9080"}, 
    allowCredentials = "true", 
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
public class AdminTransactionController {

    private final RestTemplate restTemplate;
    
    @Value("${services.order.base-url:http://localhost:8084}")
    private String orderServiceUrl;

    public AdminTransactionController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @GetMapping("/transactions")
    public ResponseEntity<Map<String, Object>> getAllTransactions(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Fetch orders from order-service
            String url = orderServiceUrl + "/api/v1/orders/admin/all?page=" + page + "&size=" + size;
            if (status != null && !status.equals("all")) {
                url += "&status=" + status;
            }
            
            ResponseEntity<Map> orderResponse = restTemplate.getForEntity(url, Map.class);
            
            if (orderResponse.getBody() != null) {
                response.put("success", true);
                response.put("data", orderResponse.getBody().get("data"));
                response.put("pagination", orderResponse.getBody().get("pagination"));
            } else {
                response.put("success", false);
                response.put("message", "Failed to fetch transactions");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error fetching transactions: " + e.getMessage());
            response.put("data", List.of()); // Return empty list on error
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/transactions/{orderId}")
    public ResponseEntity<Map<String, Object>> getTransactionDetails(@PathVariable Long orderId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String url = orderServiceUrl + "/api/v1/orders/" + orderId;
            ResponseEntity<Map> orderResponse = restTemplate.getForEntity(url, Map.class);
            
            if (orderResponse.getBody() != null) {
                response.put("success", true);
                response.put("data", orderResponse.getBody().get("data"));
            } else {
                response.put("success", false);
                response.put("message", "Transaction not found");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error fetching transaction: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}


