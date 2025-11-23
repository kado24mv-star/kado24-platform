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
public class AdminMerchantController {

    private final RestTemplate restTemplate;
    
    @Value("${services.merchant.base-url:http://kado24-merchant-service:8088}")
    private String merchantServiceUrl;

    public AdminMerchantController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @GetMapping("/merchants/pending")
    public ResponseEntity<Map<String, Object>> getPendingMerchants(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            String url = merchantServiceUrl + "/api/v1/merchants/admin/pending?page=" + page + "&size=" + size;
            
            ResponseEntity<Map> merchantResponse = restTemplate.getForEntity(url, Map.class);
            
            if (merchantResponse.getBody() != null) {
                response.put("success", true);
                response.put("data", merchantResponse.getBody().get("data"));
                response.put("pagination", merchantResponse.getBody().get("pagination"));
            } else {
                response.put("success", false);
                response.put("message", "Failed to fetch pending merchants");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error fetching pending merchants: " + e.getMessage());
            response.put("data", Map.of("content", List.of())); // Return empty list on error
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/merchants/{merchantId}/approve")
    public ResponseEntity<Map<String, Object>> approveMerchant(@PathVariable Long merchantId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String url = merchantServiceUrl + "/api/v1/merchants/admin/" + merchantId + "/approve";
            ResponseEntity<Map> merchantResponse = restTemplate.postForEntity(url, null, Map.class);
            
            if (merchantResponse.getBody() != null) {
                response.put("success", true);
                response.put("message", "Merchant approved successfully");
                response.put("data", merchantResponse.getBody().get("data"));
            } else {
                response.put("success", false);
                response.put("message", "Failed to approve merchant");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error approving merchant: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/merchants/{merchantId}/reject")
    public ResponseEntity<Map<String, Object>> rejectMerchant(
            @PathVariable Long merchantId,
            @RequestParam String reason) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            String url = merchantServiceUrl + "/api/v1/merchants/admin/" + merchantId + "/reject?reason=" + reason;
            ResponseEntity<Map> merchantResponse = restTemplate.postForEntity(url, null, Map.class);
            
            if (merchantResponse.getBody() != null) {
                response.put("success", true);
                response.put("message", "Merchant rejected");
                response.put("data", merchantResponse.getBody().get("data"));
            } else {
                response.put("success", false);
                response.put("message", "Failed to reject merchant");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error rejecting merchant: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/merchants/{merchantId}")
    public ResponseEntity<Map<String, Object>> getMerchantDetails(@PathVariable Long merchantId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Use admin endpoint that doesn't require authentication
            String url = merchantServiceUrl + "/api/v1/merchants/admin/" + merchantId;
            ResponseEntity<Map> merchantResponse = restTemplate.getForEntity(url, Map.class);
            
            if (merchantResponse.getBody() != null) {
                response.put("success", true);
                response.put("data", merchantResponse.getBody().get("data"));
            } else {
                response.put("success", false);
                response.put("message", "Merchant not found");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error fetching merchant: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}


