# Kado24 Voucher Service

Voucher management service for the Kado24 platform.

## 📦 Features

- Browse active vouchers (public)
- Search vouchers with full-text search (public)
- Filter by category (public)
- Get voucher details (public)
- Create vouchers (merchant)
- Update vouchers (merchant)
- Publish vouchers (merchant)
- Delete vouchers (merchant)
- Manage categories
- Image upload support (base64 data URLs with unlimited length)

## 🚀 Quick Start

### Run

```bash
mvn spring-boot:run
```

## 📚 API Documentation

Swagger UI: http://localhost:8083/swagger-ui.html

## 🔌 Endpoints

### Public Endpoints (No Authentication)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/vouchers` | Get active vouchers (paginated) |
| GET | `/api/v1/vouchers/{slugOrId}` | Get voucher details |
| GET | `/api/v1/vouchers/search?query=food` | Search vouchers |
| GET | `/api/v1/vouchers/category/{categoryId}` | Get vouchers by category |
| GET | `/api/v1/categories` | Get all categories |
| GET | `/api/v1/categories/{slug}` | Get category by slug |

### Merchant Endpoints (Requires JWT)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/vouchers` | Create voucher |
| PUT | `/api/v1/vouchers/{id}` | Update voucher |
| POST | `/api/v1/vouchers/{id}/publish` | Publish voucher |
| DELETE | `/api/v1/vouchers/{id}` | Delete voucher |
| GET | `/api/v1/vouchers/my-vouchers` | Get my vouchers |

## 📝 Usage Examples

### Browse Vouchers (Public)

```bash
curl "http://localhost:8083/api/v1/vouchers?page=0&size=20"
```

### Search Vouchers

```bash
curl "http://localhost:8083/api/v1/vouchers/search?query=restaurant&page=0&size=20"
```

### Get Categories

```bash
curl "http://localhost:8083/api/v1/categories"
```

### Create Voucher (Merchant)

```bash
curl -X POST http://localhost:8083/api/v1/vouchers \
  -H "Authorization: Bearer MERCHANT_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "categoryId": 1,
    "title": "$25 Restaurant Gift Voucher",
    "description": "Enjoy dining at our restaurant",
    "termsAndConditions": "Valid for 1 year",
    "denominations": [5.00, 10.00, 25.00, 50.00],
    "unlimitedStock": false,
    "stockQuantity": 100,
    "imageUrl": "data:image/jpeg;base64,..."
  }'
```

**Note:** The `imageUrl` field supports base64 data URLs of unlimited length (TEXT column type).

## 🔒 Security

- Public endpoints: Browse, search, view vouchers
- Merchant endpoints: Create, update, manage own vouchers
- Admin endpoints: Moderate all vouchers

## ⚡ Performance

- **Caching:** Active vouchers cached in Redis (10 min TTL)
- **Full-text Search:** PostgreSQL tsvector for fast searches
- **Indexes:** Optimized database queries
- **Pagination:** All list endpoints paginated

## 📁 Project Structure

```
voucher-service/
├── entity/
│   ├── Voucher.java
│   └── VoucherCategory.java
├── repository/
│   ├── VoucherRepository.java
│   └── VoucherCategoryRepository.java
├── dto/
│   ├── VoucherDTO.java
│   ├── CategoryDTO.java
│   ├── CreateVoucherRequest.java
│   └── UpdateVoucherRequest.java
├── mapper/
│   ├── VoucherMapper.java
│   └── CategoryMapper.java
├── service/
│   ├── VoucherService.java
│   └── CategoryService.java
├── controller/
│   ├── VoucherController.java
│   └── CategoryController.java
└── VoucherServiceApplication.java
```

## 🔗 Dependencies

- common-lib, security-lib, kafka-lib
- PostgreSQL, Redis, Kafka
- Spring Boot 3.2+

































