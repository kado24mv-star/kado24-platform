package com.kado24.wallet.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class GiftVoucherRequest {

    @NotNull(message = "Recipient user id is required")
    private Long recipientUserId;

    @Size(max = 250, message = "Gift message cannot exceed 250 characters")
    private String giftMessage;
}




