# Kado24 Common Library

Shared DTOs, exceptions, utilities, and constants used across all Kado24 microservices.

## 📦 Installation

Add this dependency to your service's `pom.xml`:

```xml
<dependency>
    <groupId>com.kado24</groupId>
    <artifactId>common-lib</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 🔧 Build

```bash
cd backend/shared/common-lib
mvn clean install
```

## 📚 Components

### DTOs (Data Transfer Objects)

- **`ApiResponse<T>`**: Standard wrapper for all API responses
- **`ApiError`**: Error details structure
- **`PaginationMeta`**: Pagination metadata
- **`PageRequest`**: Standard pagination request parameters

### Exceptions

All custom exceptions extend `BaseException`:

- **`ResourceNotFoundException`**: Resource not found (404)
- **`ValidationException`**: Validation failures (400)
- **`UnauthorizedException`**: Authentication required (401)
- **`ForbiddenException`**: Insufficient permissions (403)
- **`BusinessException`**: Business logic violations (400)
- **`PaymentException`**: Payment processing errors (402)
- **`ConflictException`**: Data conflicts (409)

### Exception Handler

- **`GlobalExceptionHandler`**: Global exception handling for all services

### Utilities

- **`DateTimeUtil`**: Date/time operations, timezone handling
- **`StringUtil`**: String manipulation, code generation, validation
- **`AppConstants`**: Application-wide constants

## 💡 Usage Examples

### API Response

```java
// Success response with data
return ResponseEntity.ok(ApiResponse.success(userData));

// Success with message
return ResponseEntity.ok(ApiResponse.success("User created successfully", userData));

// Error response
return ResponseEntity
    .status(HttpStatus.BAD_REQUEST)
    .body(ApiResponse.error("Invalid input", "VALIDATION_ERROR"));

// Paginated response
return ResponseEntity.ok(
    ApiResponse.paginated(userList, PaginationMeta.from(page, size, totalItems))
);
```

### Exception Handling

```java
// Throw custom exception
if (user == null) {
    throw new ResourceNotFoundException("User", userId);
}

// Business exception
if (voucher.getStock() <= 0) {
    throw new BusinessException("Voucher is out of stock");
}

// The GlobalExceptionHandler automatically converts these to proper API responses
```

### Utilities

```java
// Generate codes
String voucherCode = StringUtil.generateVoucherCode(); // "KADO-ABCD-1234"
String orderNumber = StringUtil.generateOrderNumber(); // "ORD-20251111-001234"

// Date operations
LocalDateTime now = DateTimeUtil.nowInCambodia();
boolean isExpired = DateTimeUtil.isPast(voucher.getValidUntil());

// String operations
String slug = StringUtil.slugify("Amazing Voucher Deal!"); // "amazing-voucher-deal"
String masked = StringUtil.maskPhoneNumber("+85512345678"); // "+855****5678"
```

### Pagination

```java
@GetMapping
public ResponseEntity<ApiResponse<List<VoucherDTO>>> getVouchers(
        @ModelAttribute PageRequest pageRequest) {
    
    org.springframework.data.domain.PageRequest springPageRequest = 
        pageRequest.toSpringPageRequest();
    
    Page<Voucher> page = voucherRepository.findAll(springPageRequest);
    
    PaginationMeta pagination = PaginationMeta.from(
        page.getNumber(),
        page.getSize(),
        page.getTotalElements()
    );
    
    return ResponseEntity.ok(
        ApiResponse.paginated(page.getContent(), pagination)
    );
}
```

## 🎯 Best Practices

1. **Always use `ApiResponse`** for consistency across all services
2. **Throw custom exceptions** instead of returning error responses directly
3. **Use constants** from `AppConstants` instead of hard-coding values
4. **Leverage utilities** for common operations
5. **Follow pagination standards** using `PageRequest` and `PaginationMeta`

## 📝 Notes

- All date/time operations use Cambodia timezone (`Asia/Phnom_Penh`)
- JWT tokens expire after 24 hours (configurable in `AppConstants`)
- Platform commission is 8%, merchant payout is 92%
- Maximum file upload size is 5MB
- Default pagination size is 20 items per page






































