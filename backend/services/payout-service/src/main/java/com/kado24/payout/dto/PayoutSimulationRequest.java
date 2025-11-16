package com.kado24.payout.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class PayoutSimulationRequest {
    @NotBlank
    private String weekEnding;

    private Boolean dryRun;
}

