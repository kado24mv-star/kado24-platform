# Kado24 User Service

User profile management service for the Kado24 platform.

## 📦 Features

- Get user profile
- Update user profile
- Delete user account (soft delete)
- Search users (admin)
- User statistics (admin)

## 🚀 Quick Start

### Run

```bash
mvn spring-boot:run
```

## 📚 API Documentation

Swagger UI: http://localhost:8082/swagger-ui.html

## 🔌 Endpoints

### User Endpoints (Authenticated)

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| GET | `/api/v1/users/profile` | Get current user profile | Any |
| PUT | `/api/v1/users/profile` | Update current user profile | Any |
| DELETE | `/api/v1/users/profile` | Delete account | Any |

### Admin Endpoints

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| GET | `/api/v1/users/{userId}` | Get user by ID | Admin |
| GET | `/api/v1/users` | Get all users (paginated) | Admin |
| GET | `/api/v1/users/search` | Search users | Admin |
| GET | `/api/v1/users/statistics` | Get user statistics | Admin |

## 📝 Usage Examples

### Get My Profile

```bash
curl -X GET http://localhost:8082/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_OAUTH2_TOKEN"
```

### Update Profile

```bash
curl -X PUT http://localhost:8082/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_OAUTH2_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Sok Dara Updated",
    "email": "newemail@example.com"
  }'
```

### Get All Users (Admin)

```bash
curl -X GET "http://localhost:8082/api/v1/users?page=0&size=20" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

### Search Users (Admin)

```bash
curl -X GET "http://localhost:8082/api/v1/users/search?query=Sok&page=0&size=20" \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

### User Statistics (Admin)

```bash
curl -X GET http://localhost:8082/api/v1/users/statistics \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

Response:
```json
{
  "success": true,
  "data": {
    "totalUsers": 150,
    "totalConsumers": 120,
    "totalMerchants": 28,
    "activeUsers": 140,
    "pendingVerification": 10
  }
}
```

## 🔒 Security

All endpoints require OAuth2 authentication. User can only access their own profile unless they have ADMIN role.

## 📁 Project Structure

```
user-service/
├── src/main/java/com/kado24/user/
│   ├── controller/UserController.java
│   ├── dto/
│   │   ├── UserProfileDTO.java
│   │   └── UpdateProfileRequest.java
│   ├── entity/User.java
│   ├── mapper/UserMapper.java
│   ├── repository/UserRepository.java
│   ├── service/UserService.java
│   └── UserServiceApplication.java
└── pom.xml
```

## 🔗 Dependencies

- common-lib
- security-lib
- kafka-lib
- PostgreSQL
- Spring Boot 3.2+






































