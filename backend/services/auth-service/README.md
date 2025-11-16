# Kado24 Auth Service

Authentication and authorization service for the Kado24 platform.

## 📦 Features

- User registration (consumer and merchant)
- Login with phone/email + password
- OTP generation and verification
- Password reset
- JWT token generation
- Token refresh
- Token blacklisting (logout)
- OAuth2 authorization server (future)

## 🚀 Quick Start

### Prerequisites

1. Infrastructure services running:
   ```bash
   cd ../../infrastructure/docker
   docker-compose up -d
   ```

2. Shared libraries built:
   ```bash
   cd ../shared/common-lib && mvn clean install
   cd ../security-lib && mvn clean install
   cd ../kafka-lib && mvn clean install
   ```

### Build

```bash
mvn clean install
```

### Run

```bash
mvn spring-boot:run
```

### Run with specific profile

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

## 📚 API Documentation

Once running, access Swagger UI at:
- http://localhost:8081/swagger-ui.html

API Documentation (OpenAPI):
- http://localhost:8081/api-docs

## 🔌 Endpoints

### Public Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login with credentials |
| POST | `/api/v1/auth/send-otp` | Send OTP to phone |
| POST | `/api/v1/auth/verify-otp` | Verify OTP and login |
| POST | `/api/v1/auth/forgot-password` | Initiate password reset |
| POST | `/api/v1/auth/reset-password` | Reset password with OTP |
| POST | `/api/v1/auth/refresh` | Refresh access token |

### Protected Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/logout` | Logout (requires JWT) |

## 📝 Usage Examples

### Register User

```bash
curl -X POST http://localhost:8081/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Sok Dara",
    "phoneNumber": "+85512345678",
    "email": "sokdara@example.com",
    "password": "MyP@ssw0rd123",
    "role": "CONSUMER"
  }'
```

Response:
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": 2,
      "fullName": "Sok Dara",
      "phoneNumber": "+85512345678",
      "email": "sokdara@example.com",
      "role": "CONSUMER",
      "status": "PENDING_VERIFICATION"
    }
  },
  "timestamp": "2025-11-11T14:30:00"
}
```

### Login

```bash
curl -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "+85512345678",
    "password": "MyP@ssw0rd123"
  }'
```

### Send OTP

```bash
curl -X POST http://localhost:8081/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+85512345678",
    "purpose": "LOGIN"
  }'
```

Response (Dev Mode):
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "message": "OTP sent successfully",
    "phoneNumber": "+855****5678",
    "expiresIn": 300,
    "otpCode": "123456"
  }
}
```

### Verify OTP

```bash
curl -X POST http://localhost:8081/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+85512345678",
    "otpCode": "123456"
  }'
```

### Refresh Token

```bash
curl -X POST http://localhost:8081/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### Logout

```bash
curl -X POST http://localhost:8081/api/v1/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Forgot Password

```bash
curl -X POST http://localhost:8081/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "+85512345678"
  }'
```

### Reset Password

```bash
curl -X POST http://localhost:8081/api/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+85512345678",
    "otpCode": "123456",
    "newPassword": "NewP@ssw0rd456"
  }'
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_HOST` | PostgreSQL host (falls back to `DB_HOST`) | localhost |
| `POSTGRES_PORT` | PostgreSQL port (falls back to `DB_PORT`) | 5432 |
| `POSTGRES_DB` | Database name (falls back to `DB_NAME`) | kado24_db |
| `POSTGRES_USER` | Database username (falls back to `DB_USER`) | kado24_user |
| `POSTGRES_PASSWORD` | Database password (falls back to `DB_PASSWORD`) | kado24_pass |
| `REDIS_HOST` | Redis host | localhost |
| `REDIS_PORT` | Redis port | 6379 |
| `REDIS_PASSWORD` | Redis password | kado24_redis_pass |
| `KAFKA_BOOTSTRAP_SERVERS` | Kafka servers | localhost:9092 |
| `JWT_SECRET` | JWT secret key | (change in production!) |
| `JWT_EXPIRATION` | Token expiration (ms) | 86400000 (24h) |

### JWT Secret

⚠️ **Important**: Always use a strong secret key in production!

```bash
# Generate a secure secret
openssl rand -base64 32

# Set as environment variable
export JWT_SECRET="your-generated-secret-here"
```

## 🧪 Testing

### Unit Tests

```bash
mvn test
```

### Integration Tests

```bash
mvn verify
```

### Manual Testing

Use the provided cURL commands above or import the Postman collection.

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │
│ (Mobile/Web)│
└──────┬──────┘
       │ HTTP POST
       ▼
┌─────────────────────┐
│  AuthController     │
│  - /api/v1/auth/*   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│   AuthService       │
│  - register()       │
│  - login()          │
│  - refreshToken()   │
│  - sendOtp()        │
└──────┬──────────────┘
       │
       ├─────────────────────────────────────┐
       │                                     │
       ▼                                     ▼
┌─────────────────┐                  ┌─────────────────┐
│  UserRepository │                  │   OtpService    │
│  (PostgreSQL)   │                  │   (Redis)       │
└─────────────────┘                  └─────────────────┘
       │                                     │
       └──────────────┬──────────────────────┘
                      │
                      ▼
              ┌───────────────────┐
              │  JwtTokenProvider │
              │  (Generate JWT)   │
              └───────────────────┘
                      │
                      ▼
              ┌───────────────────┐
              │  EventPublisher   │
              │  (Kafka Events)   │
              └───────────────────┘
```

## 🔒 Security

### Password Requirements

- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit

### Token Expiration

- Access Token: 24 hours
- Refresh Token: 7 days
- OTP: 5 minutes

### Rate Limiting

Configure in API Gateway (APISIX):
- Registration: 5 requests/hour per IP
- Login: 20 requests/hour per IP
- OTP: 3 requests/hour per phone

## 📊 Monitoring

### Health Check

```bash
curl http://localhost:8081/actuator/health
```

### Metrics

```bash
curl http://localhost:8081/actuator/metrics
```

### Prometheus Metrics

```bash
curl http://localhost:8081/actuator/prometheus
```

## 🐛 Troubleshooting

### Database Connection Failed

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec kado24-postgres pg_isready -U kado24_user
```

### Redis Connection Failed

```bash
# Check if Redis is running
docker ps | grep redis

# Test connection
docker exec kado24-redis redis-cli --pass kado24_redis_pass ping
```

### Port Already in Use

```bash
# Windows
netstat -ano | findstr :8081

# Kill process (replace PID)
taskkill /PID <PID> /F
```

## 📁 Project Structure

```
auth-service/
├── src/
│   ├── main/
│   │   ├── java/com/kado24/auth/
│   │   │   ├── config/
│   │   │   │   ├── RedisConfig.java
│   │   │   │   └── OpenApiConfig.java
│   │   │   ├── controller/
│   │   │   │   └── AuthController.java
│   │   │   ├── dto/
│   │   │   │   ├── RegisterRequest.java
│   │   │   │   ├── LoginRequest.java
│   │   │   │   ├── TokenResponse.java
│   │   │   │   ├── UserDTO.java
│   │   │   │   ├── OtpRequest.java
│   │   │   │   ├── VerifyOtpRequest.java
│   │   │   │   ├── OtpResponse.java
│   │   │   │   ├── ForgotPasswordRequest.java
│   │   │   │   ├── ResetPasswordRequest.java
│   │   │   │   └── RefreshTokenRequest.java
│   │   │   ├── entity/
│   │   │   │   └── User.java
│   │   │   ├── mapper/
│   │   │   │   └── UserMapper.java
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.java
│   │   │   ├── service/
│   │   │   │   ├── AuthService.java
│   │   │   │   └── OtpService.java
│   │   │   └── AuthServiceApplication.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       └── application-prod.yml
│   └── test/
│       └── java/com/kado24/auth/
└── pom.xml
```

## 📝 Notes

- OTP codes are returned in development mode for easy testing
- In production, OTP should be sent via SMS gateway
- JWT secret must be changed in production
- All passwords are hashed using BCrypt (strength 10)
- Phone numbers must be in format: +855XXXXXXXX (Cambodia)

## 🔗 Dependencies

- common-lib (DTOs, exceptions, utilities)
- security-lib (JWT, password encoding)
- kafka-lib (event publishing)
- Spring Boot 3.2+
- PostgreSQL 17
- Redis 7
- Apache Kafka

## 📞 Support

For issues or questions, refer to:
- Main README: `../../README.md`
- Development Guide: `../../DEVELOPMENT.md`
- Implementation Guide: `../../IMPLEMENTATION-GUIDE.md`











