package com.kado24.payout.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.payout.dto.CreateHoldRequest;
import com.kado24.payout.dto.PayoutHoldDTO;
import com.kado24.payout.entity.PayoutHold;
import com.kado24.payout.service.PayoutHoldService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/v1/payouts/internal")
@RequiredArgsConstructor
public class PayoutInternalController {

	private final PayoutHoldService payoutHoldService;

	@Value("${internal.api.secret:kado24-internal-secret}")
	private String internalSecret;

	@PostMapping("/holds")
	public ResponseEntity<ApiResponse<PayoutHoldDTO>> createHold(
			@RequestHeader(value = "X-Internal-Secret", required = false) String providedSecret,
			@Valid @RequestBody CreateHoldRequest request
	) {
		validateSecret(providedSecret);
		log.info("Registering payout hold for merchant {}", request.getMerchantId());
		PayoutHold hold = payoutHoldService.createHold(request.getMerchantId(), request.getReason());
		PayoutHoldDTO dto = PayoutHoldDTO.builder()
				.merchantId(hold.getMerchantId())
				.reason(hold.getReason())
				.createdAt(hold.getCreatedAt())
				.build();
		return ResponseEntity.ok(ApiResponse.success("Hold registered", dto));
	}

	@GetMapping("/holds")
	public ResponseEntity<ApiResponse<List<PayoutHoldDTO>>> listHolds(
			@RequestHeader(value = "X-Internal-Secret", required = false) String providedSecret
	) {
		validateSecret(providedSecret);
		List<PayoutHoldDTO> holds = payoutHoldService.getActiveHolds().stream()
				.map(h -> PayoutHoldDTO.builder()
						.merchantId(h.getMerchantId())
						.reason(h.getReason())
						.createdAt(h.getCreatedAt())
						.build())
				.collect(Collectors.toList());
		return ResponseEntity.ok(ApiResponse.success("Active holds", holds));
	}

	private void validateSecret(String providedSecret) {
		if (internalSecret == null || internalSecret.isBlank()) {
			return;
		}
		if (!internalSecret.equals(providedSecret)) {
			throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Invalid internal secret");
		}
	}
}


