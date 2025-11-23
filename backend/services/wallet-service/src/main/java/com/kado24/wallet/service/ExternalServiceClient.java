package com.kado24.wallet.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ExternalServiceClient {

    private final RestTemplate restTemplate;

    @Value("${services.voucher.url:http://kado24-voucher-service:8083}")
    private String voucherServiceUrl;

    @Value("${services.merchant.url:http://kado24-merchant-service:8088}")
    private String merchantServiceUrl;

    @SuppressWarnings("unchecked")
    public String getVoucherTitle(Long voucherId) {
        try {
            String url = voucherServiceUrl + "/api/v1/vouchers/" + voucherId;
            log.debug("Fetching voucher title from: {}", url);
            Map<String, Object> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                null, 
                new ParameterizedTypeReference<Map<String, Object>>() {}
            ).getBody();
            
            if (response != null && response.containsKey("data")) {
                Object dataObj = response.get("data");
                if (dataObj instanceof Map) {
                    Map<String, Object> data = (Map<String, Object>) dataObj;
                    if (data.containsKey("title")) {
                        Object title = data.get("title");
                        String titleStr = title != null ? title.toString() : null;
                        log.debug("Fetched voucher title: {}", titleStr);
                        return titleStr;
                    }
                }
            }
            log.warn("Voucher response missing title field for voucherId: {}", voucherId);
        } catch (Exception e) {
            log.error("Failed to fetch voucher title for voucherId {}: {}", voucherId, e.getMessage(), e);
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    public String getMerchantName(Long merchantId) {
        try {
            // Use internal endpoint with internal secret
            String url = merchantServiceUrl + "/api/v1/merchants/internal/" + merchantId;
            log.debug("Fetching merchant name from internal endpoint: {}", url);
            
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.set("X-Internal-Secret", "kado24-internal-secret");
            org.springframework.http.HttpEntity<?> entity = new org.springframework.http.HttpEntity<>(headers);
            
            Map<String, Object> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                new ParameterizedTypeReference<Map<String, Object>>() {}
            ).getBody();
            
            if (response != null && response.containsKey("data")) {
                Object dataObj = response.get("data");
                if (dataObj instanceof Map) {
                    Map<String, Object> data = (Map<String, Object>) dataObj;
                    String name = extractMerchantName(data);
                    if (name != null) {
                        log.debug("Fetched merchant name: {}", name);
                        return name;
                    }
                }
            }
            log.warn("Merchant response missing name field for merchantId: {}", merchantId);
        } catch (Exception e) {
            log.error("Failed to fetch merchant name for merchantId {}: {}", merchantId, e.getMessage(), e);
        }
        return null;
    }
    
    private String extractMerchantName(Map<String, Object> data) {
        if (data.containsKey("name")) {
            Object name = data.get("name");
            if (name != null) {
                return name.toString();
            }
        }
        if (data.containsKey("businessName")) {
            Object businessName = data.get("businessName");
            if (businessName != null) {
                return businessName.toString();
            }
        }
        return null;
    }
}

