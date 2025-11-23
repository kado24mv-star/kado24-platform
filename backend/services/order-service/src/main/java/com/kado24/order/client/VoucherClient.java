package com.kado24.order.client;

import com.kado24.common.dto.ApiResponse;
import com.kado24.common.exception.BusinessException;
import com.kado24.order.dto.VoucherReservationRequest;
import com.kado24.order.dto.VoucherReservationResponse;
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

@Slf4j
@Component
@RequiredArgsConstructor
public class VoucherClient {

    private final RestTemplate restTemplate;

    @Value("${services.voucher.base-url:http://localhost:8083}")
    private String voucherBaseUrl;

    @Value("${services.voucher.reserve-path:/api/v1/vouchers/internal}")
    private String reserveBasePath;

    @Value("${services.voucher.internal-secret:kado24-internal-secret}")
    private String internalSecret;

    private static final ParameterizedTypeReference<ApiResponse<VoucherReservationResponse>> RESPONSE_TYPE =
            new ParameterizedTypeReference<>() {};

    public VoucherReservationResponse reserveVoucher(VoucherReservationRequest request) {
        String url = "%s%s/%d/reserve".formatted(voucherBaseUrl, reserveBasePath, request.getVoucherId());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (internalSecret != null && !internalSecret.isBlank()) {
            headers.set("X-Internal-Secret", internalSecret);
        }

        HttpEntity<VoucherReservationRequest> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<ApiResponse<VoucherReservationResponse>> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    RESPONSE_TYPE
            );

            if (response.getBody() == null || !response.getStatusCode().is2xxSuccessful()
                    || !response.getBody().isSuccess()) {
                throw new BusinessException("Voucher reservation failed");
            }

            VoucherReservationResponse payload = response.getBody().getData();
            if (payload == null) {
                throw new BusinessException("Voucher service returned empty reservation payload");
            }
            return payload;
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Failed to reserve voucher stock", ex);
            String message = ex.getMessage() != null ? ex.getMessage() : "unknown error";
            throw new BusinessException("Unable to reserve voucher stock: " + message);
        }
    }
}























