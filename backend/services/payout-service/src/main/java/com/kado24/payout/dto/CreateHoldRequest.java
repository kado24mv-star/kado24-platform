package com.kado24.payout.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateHoldRequest {
    @NotNull
    private Long merchantId;

    @NotBlank
    private String reason;
}




