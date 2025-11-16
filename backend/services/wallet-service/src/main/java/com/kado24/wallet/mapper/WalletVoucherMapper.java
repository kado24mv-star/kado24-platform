package com.kado24.wallet.mapper;

import com.kado24.wallet.dto.WalletVoucherDTO;
import com.kado24.wallet.entity.WalletVoucher;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface WalletVoucherMapper {
    
    @Mapping(target = "voucherTitle", ignore = true)
    @Mapping(target = "merchantName", ignore = true)
    @Mapping(target = "isValid", expression = "java(voucher.isValid())")
    WalletVoucherDTO toDTO(WalletVoucher voucher);
}



















