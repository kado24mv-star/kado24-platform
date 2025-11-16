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

    private static final ParameterizedTypeReference<ApiResponse<Map<String, Object>>> RESPONSE_TYPE =
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
            ResponseEntity<ApiResponse<Map<String, Object>>> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    RESPONSE_TYPE
            );

            if (!response.getStatusCode().is2xxSuccessful()
                    || response.getBody() == null
                    || !response.getBody().isSuccess()) {
                throw new BusinessException("Wallet service rejected voucher issuance request");
            }

            log.info("Wallet vouchers issued for order {}", request.getOrderId());
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Failed to call wallet service to issue vouchers", ex);
            String rootMessage = ex.getMessage() != null ? ex.getMessage() : "unknown error";
            throw new BusinessException("Unable to issue vouchers to wallet: " + rootMessage);
        }
    }
}

