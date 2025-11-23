# Database Connection Configuration - Kado24 Platform

## Overview

All backend services connect to the same PostgreSQL database (`kado24_db`) but use **different schemas** for data isolation in a microservices architecture.

## Database Connection Details

### Base Configuration
- **Database Name**: `kado24_db`
- **Host**: `localhost` (configurable via environment variables)
- **Port**: `5432` (configurable via environment variables)
- **Username**: `kado24_user` (configurable via environment variables)
- **Password**: `kado24_pass` (configurable via environment variables)

### Environment Variables
Services support the following environment variables (with fallback order):
- `POSTGRES_HOST` or `DB_HOST` → defaults to `localhost`
- `POSTGRES_PORT` or `DB_PORT` → defaults to `5432`
- `POSTGRES_DB` or `DB_NAME` → defaults to `kado24_db`
- `POSTGRES_USER` or `DB_USER` → defaults to `kado24_user`
- `POSTGRES_PASSWORD` or `DB_PASSWORD` → defaults to `kado24_pass`

---

## Service-Specific Connections

### 1. Auth Service (Port 8081)
**Schema**: `auth_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=auth_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
    minimum-idle: 1
    connection-timeout: 20000
    idle-timeout: 300000
    max-lifetime: 1200000
```

**Tables**: `users`, `oauth2_clients`, `oauth2_tokens`

---

### 2. User Service (Port 8082)
**Schema**: `user_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=user_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `user_profiles`, `user_addresses`

---

### 3. Voucher Service (Port 8083)
**Schema**: `public` + `shared_schema` (search path)

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=public&searchPath=public,shared_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `vouchers` (in public schema), `voucher_categories` (in shared_schema)

---

### 4. Order Service (Port 8084)
**Schema**: `order_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=order_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `orders`, `order_items`, `transactions`

---

### 5. Wallet Service (Port 8086)
**Schema**: `wallet_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=wallet_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `wallet_vouchers`

---

### 6. Redemption Service (Port 8087)
**Schema**: `redemption_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=redemption_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `redemptions`, `disputes`

---

### 7. Merchant Service (Port 8088)
**Schema**: `merchant_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=merchant_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `merchants`, `merchant_locations`, `merchant_bank_accounts`, `merchant_documents`

---

### 8. Admin Portal Backend (Port 8089)
**Schema**: `admin_schema` (but can query across all schemas)

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=admin_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `audit_logs`, `fraud_alerts` (in admin_schema)
**Note**: Uses native SQL queries to access other schemas for dashboard statistics

---

### 9. Notification Service (Port 8091)
**Schema**: `notification_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=notification_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `notifications`, `support_tickets`

---

### 10. Payout Service (Port 8092)
**Schema**: `payout_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=payout_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `payouts`, `payout_items`

---

### 11. Analytics Service (Port 8093)
**Schema**: `analytics_schema`

```yaml
datasource:
  url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=analytics_schema
  username: ${POSTGRES_USER:${DB_USER:kado24_user}}
  password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
  driver-class-name: org.postgresql.Driver
  hikari:
    maximum-pool-size: 3
```

**Tables**: `daily_metrics`, `analytics_events`

---

## Connection Pool Settings (HikariCP)

Most services use HikariCP with:
- **Maximum Pool Size**: 3 connections per service
- **Driver**: `org.postgresql.Driver`

Auth Service has additional settings:
- **Minimum Idle**: 1
- **Connection Timeout**: 20000ms (20 seconds)
- **Idle Timeout**: 300000ms (5 minutes)
- **Max Lifetime**: 1200000ms (20 minutes)

---

## Schema Architecture

The platform uses **schema-based data isolation**:

```
kado24_db
├── auth_schema          (Auth Service)
├── user_schema          (User Service)
├── merchant_schema      (Merchant Service)
├── voucher_schema       (Voucher Service - uses public)
├── order_schema         (Order Service)
├── wallet_schema        (Wallet Service)
├── redemption_schema    (Redemption Service)
├── notification_schema  (Notification Service)
├── payout_schema        (Payout Service)
├── analytics_schema     (Analytics Service)
├── admin_schema         (Admin Portal Backend)
└── shared_schema        (Shared lookup tables)
```

---

## Example Connection String Breakdown

For **Auth Service**:
```
jdbc:postgresql://localhost:5432/kado24_db?currentSchema=auth_schema
```

- `jdbc:postgresql://` - PostgreSQL JDBC protocol
- `localhost:5432` - Host and port
- `/kado24_db` - Database name
- `?currentSchema=auth_schema` - Sets the default schema for queries

---

## Testing Connections

You can test database connectivity using:

```bash
# Using psql
psql -h localhost -p 5432 -U kado24_user -d kado24_db

# Check service health endpoints
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
# ... etc for each service
```

---

## Notes

1. **Schema Isolation**: Each service operates in its own schema, preventing accidental cross-service data access
2. **Shared Schema**: `shared_schema` contains lookup tables (like `voucher_categories`) accessible by multiple services
3. **Admin Portal**: Can query across schemas using native SQL with schema prefixes (e.g., `auth_schema.users`)
4. **Environment Variables**: All connection parameters can be overridden via environment variables for different environments (dev, staging, prod)

