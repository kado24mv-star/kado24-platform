package com.kado24.auth.mapper;

import com.kado24.auth.dto.UserDTO;
import com.kado24.auth.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 * Mapper for User entity to UserDTO
 */
@Mapper(componentModel = "spring")
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    /**
     * Convert User entity to UserDTO
     * Excludes sensitive information like password hash
     */
    @Mapping(target = "id", source = "id")
    @Mapping(target = "fullName", source = "fullName")
    @Mapping(target = "phoneNumber", source = "phoneNumber")
    @Mapping(target = "email", source = "email")
    @Mapping(target = "role", source = "role")
    @Mapping(target = "status", source = "status")
    @Mapping(target = "avatarUrl", source = "avatarUrl")
    @Mapping(target = "emailVerified", source = "emailVerified")
    @Mapping(target = "phoneVerified", source = "phoneVerified")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "lastLoginAt", source = "lastLoginAt")
    UserDTO toDTO(User user);
}






































