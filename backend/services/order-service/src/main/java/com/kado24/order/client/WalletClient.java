package com.kado24.order.client;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.exception.BusinessException;
import com.kado24.order.dto.WalletIssuanceRequest;
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

import java.util.List;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class WalletClient {

    private final RestTemplate restTemplate;

    @Value("${services.wallet.base-url:http://localhost:8086}")
    private String walletBaseUrl;

    @Value("${services.wallet.issue-path:/api/v1/wallet/internal/issue}")
    private String walletIssuePath;

    @Value("${services.wallet.internal-secret:kado24-internal-secret}")
    private String internalSecret;

    // Wallet service returns ApiResponse<List<WalletVoucherDTO>>
    private static final ParameterizedTypeReference<ApiResponse<List<Map<String, Object>>>> RESPONSE_TYPE =
            new ParameterizedTypeReference<>() {};

    public void issueVouchers(WalletIssuanceRequest request) {
        String url = walletBaseUrl + walletIssuePath;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (internalSecret != null && !internalSecret.isBlank()) {
            headers.set("X-Internal-Secret", internalSecret);
        }

        HttpEntity<WalletIssuanceRequest> entity = new HttpEntity<>(request, headers);

        try {
            log.debug("Calling wallet service to issue vouchers for order {}", request.getOrderId());
            ResponseEntity<ApiResponse<List<Map<String, Object>>>> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    RESPONSE_TYPE
            );

            if (!response.getStatusCode().is2xxSuccessful()) {
                log.warn("Wallet service returned non-2xx status: {}", response.getStatusCode());
                throw new BusinessException("Wallet service returned status: " + response.getStatusCode());
            }

            if (response.getBody() == null) {
                log.warn("Wallet service returned null response body");
                throw new BusinessException("Wallet service returned null response");
            }

            if (!response.getBody().isSuccess()) {
                String errorMsg = response.getBody().getMessage() != null 
                        ? response.getBody().getMessage() 
                        : "Wallet service rejected voucher issuance request";
                log.warn("Wallet service rejected request: {}", errorMsg);
                throw new BusinessException(errorMsg);
            }

            List<Map<String, Object>> vouchers = response.getBody().getData();
            int voucherCount = vouchers != null ? vouchers.size() : 0;
            log.info("Successfully issued {} wallet voucher(s) for order {}", voucherCount, request.getOrderId());
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Failed to call wallet service to issue vouchers for order {}: {}", 
                    request.getOrderId(), ex.getMessage(), ex);
            String rootMessage = ex.getMessage() != null ? ex.getMessage() : "unknown error";
            throw new BusinessException("Unable to issue vouchers to wallet: " + rootMessage);
        }
    }
}

