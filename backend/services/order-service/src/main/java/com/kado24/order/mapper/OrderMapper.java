package com.kado24.order.mapper;

import com.kado24.order.dto.OrderDTO;
import com.kado24.order.entity.Order;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 * Mapper for Order entity to OrderDTO
 */
@Mapper(componentModel = "spring")
public interface OrderMapper {

    OrderMapper INSTANCE = Mappers.getMapper(OrderMapper.class);

    /**
     * Convert Order entity to OrderDTO
     */
    @Mapping(target = "voucherTitle", ignore = true) // Set manually if needed
    @Mapping(target = "merchantName", ignore = true) // Set manually if needed
    OrderDTO toDTO(Order order);
}



















