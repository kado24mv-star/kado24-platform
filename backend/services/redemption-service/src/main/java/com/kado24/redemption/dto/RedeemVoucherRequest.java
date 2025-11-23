package com.kado24.redemption.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RedeemVoucherRequest {
    
    @NotBlank
    private String voucherCode;
    
    @NotNull
    private BigDecimal amount;
    
    private String location;
    private String pinCode;
}






































