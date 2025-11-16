package com.kado24.merchant.client;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.exception.BusinessException;
import com.kado24.merchant.dto.SuspendMerchantRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class PayoutClient {

    private final RestTemplate restTemplate;

    @Value("${services.payout.base-url:http://localhost:8092}")
    private String payoutBaseUrl;

    @Value("${services.payout.hold-path:/api/v1/payouts/internal/holds}")
    private String holdPath;

    @Value("${services.payout.internal-secret:kado24-internal-secret}")
    private String internalSecret;

    private static final ParameterizedTypeReference<ApiResponse<Map<String, Object>>> RESPONSE_TYPE =
            new ParameterizedTypeReference<>() {};

    public void createHold(Long merchantId, String reason) {
        String url = payoutBaseUrl + holdPath;
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (internalSecret != null && !internalSecret.isBlank()) {
            headers.set("X-Internal-Secret", internalSecret);
        }
        Map<String, Object> payload = Map.of(
                "merchantId", merchantId,
                "reason", reason
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        try {
            ResponseEntity<ApiResponse<Map<String, Object>>> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    RESPONSE_TYPE
            );
            if (response.getStatusCode().is2xxSuccessful()) {
                log.info("Payout hold registered for merchant {}", merchantId);
            } else {
                throw new BusinessException("Failed to register payout hold");
            }
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Error registering payout hold for merchant {}", merchantId, ex);
            throw new BusinessException("Unable to notify payout service about suspension");
        }
    }
}

