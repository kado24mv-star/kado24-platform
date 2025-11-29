# Kado24 Merchant Service

Merchant management and verification service for the Kado24 platform.

## 📦 Features

- Merchant registration
- Merchant profile management
- Admin approval workflow
- Merchant verification
- Statistics and metrics

## 🚀 Quick Start

```bash
mvn spring-boot:run
```

## 📚 API Documentation

Swagger UI: http://localhost:8088/swagger-ui.html

## 🔌 Endpoints

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| POST | `/api/v1/merchants/register` | Register merchant | User |
| GET | `/api/v1/merchants/{id}` | Get merchant profile | Any |
| GET | `/api/v1/merchants/my-profile` | Get my merchant profile | Merchant |
| GET | `/api/v1/merchants/pending` | Get pending merchants | Admin |
| POST | `/api/v1/merchants/{id}/approve` | Approve merchant | Admin |
| POST | `/api/v1/merchants/{id}/reject` | Reject merchant | Admin |
| GET | `/api/v1/merchants/statistics` | Get statistics | Admin |

## 📝 Usage Examples

### Register Merchant

```bash
curl -X POST http://localhost:8088/api/v1/merchants/register \
  -H "Authorization: Bearer USER_OAUTH2_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "businessName": "Blue Pumpkin Cafe",
    "businessType": "Restaurant",
    "businessLicense": "BL-12345",
    "phoneNumber": "+85512345678",
    "email": "info@bluepumpkin.com",
    "city": "Phnom Penh"
  }'
```

### Approve Merchant (Admin)

```bash
curl -X POST http://localhost:8088/api/v1/merchants/1/approve \
  -H "Authorization: Bearer ADMIN_OAUTH2_TOKEN"
```

## 🔗 Dependencies

- common-lib, security-lib, kafka-lib
- PostgreSQL
- Spring Boot 3.2+






































