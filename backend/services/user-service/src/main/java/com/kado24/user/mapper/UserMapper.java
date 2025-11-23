package com.kado24.user.mapper;

import com.kado24.user.dto.UserProfileDTO;
import com.kado24.user.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

/**
 * Mapper for User entity to UserProfileDTO
 */
@Mapper(componentModel = "spring")
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    /**
     * Convert User entity to UserProfileDTO
     */
    UserProfileDTO toDTO(User user);
}






































