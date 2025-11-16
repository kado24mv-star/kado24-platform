package com.kado24.payout.controller;

import com.kado24.common.dto.ApiResponse;
import com.kado24.payout.dto.PayoutHoldDTO;
import com.kado24.payout.dto.PayoutSimulationRequest;
import com.kado24.payout.entity.PayoutHold;
import com.kado24.payout.service.PayoutHoldService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/v1/payouts")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class PayoutController {

	private final PayoutHoldService payoutHoldService;

	@Operation(summary = "Simulate weekly payouts", description = "Runs payout aggregation and returns hold queue")
	@PostMapping("/simulate")
	public ApiResponse<Map<String, Object>> simulatePayout(
			@Valid @RequestBody PayoutSimulationRequest request
	) {
		log.info("Simulating payout for week ending {}", request.getWeekEnding());
		List<PayoutHoldDTO> holds = payoutHoldService.getActiveHolds()
				.stream()
				.map(this::toDto)
				.collect(Collectors.toList());

		Map<String, Object> payload = Map.of(
				"weekEnding", request.getWeekEnding(),
				"payouts", Collections.emptyList(),
				"holdQueue", holds
		);

		return ApiResponse.success("Payout simulation completed", payload);
	}

	private PayoutHoldDTO toDto(PayoutHold hold) {
		return PayoutHoldDTO.builder()
				.merchantId(hold.getMerchantId())
				.reason(hold.getReason())
				.createdAt(hold.getCreatedAt())
				.build();
	}
}


