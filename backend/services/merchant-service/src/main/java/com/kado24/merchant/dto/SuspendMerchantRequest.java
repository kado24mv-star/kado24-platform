package com.kado24.merchant.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SuspendMerchantRequest {

    @NotBlank(message = "Suspension reason is required")
    private String reason;
}




