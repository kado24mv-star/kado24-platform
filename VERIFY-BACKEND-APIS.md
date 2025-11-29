# Backend API Verification Guide

## Quick Verification Commands

### 1. Check All Docker Containers
```powershell
docker ps --filter "name=kado24" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 2. Check Docker Compose Status
```powershell
docker-compose -f docker-compose.services.yml ps
```

### 3. Test Health Endpoints (All Services)
```powershell
# Auth Service
curl http://localhost:8081/actuator/health

# User Service
curl http://localhost:8082/actuator/health

# Voucher Service
curl http://localhost:8083/actuator/health

# Order Service
curl http://localhost:8084/actuator/health

# Wallet Service
curl http://localhost:8086/actuator/health

# Redemption Service
curl http://localhost:8087/actuator/health

# Merchant Service
curl http://localhost:8088/actuator/health

# Admin Portal Backend
curl http://localhost:8089/actuator/health

# Notification Service
curl http://localhost:8091/actuator/health

# Payout Service
curl http://localhost:8092/actuator/health

# Analytics Service
curl http://localhost:8093/actuator/health

# Payment Service
curl http://localhost:8095/actuator/health
```

### 4. Quick Test Script
Run the verification script:
```powershell
.\check-backend-status.ps1
```

### 5. Check Service Logs
```powershell
# View logs for a specific service
docker logs kado24-auth-service --tail 50
docker logs kado24-user-service --tail 50
docker logs kado24-voucher-service --tail 50
# ... etc for each service
```

### 6. Test API Gateway Routing
```powershell
# Test through API Gateway
curl http://localhost:9080/api/v1/auth/login -Method POST -Body '{"identifier":"test","password":"test"}' -ContentType "application/json"
```

## Expected Services (12 Backend Services)

| Service | Port | Container Name | Health Endpoint |
|---------|------|----------------|-----------------|
| Auth Service | 8081 | kado24-auth-service | /actuator/health |
| User Service | 8082 | kado24-user-service | /actuator/health |
| Voucher Service | 8083 | kado24-voucher-service | /actuator/health |
| Order Service | 8084 | kado24-order-service | /actuator/health |
| Wallet Service | 8086 | kado24-wallet-service | /actuator/health |
| Redemption Service | 8087 | kado24-redemption-service | /actuator/health |
| Merchant Service | 8088 | kado24-merchant-service | /actuator/health |
| Admin Portal Backend | 8089 | kado24-admin-portal-backend | /actuator/health |
| Notification Service | 8091 | kado24-notification-service | /actuator/health |
| Payout Service | 8092 | kado24-payout-service | /actuator/health |
| Analytics Service | 8093 | kado24-analytics-service | /actuator/health |
| Payment Service | 8095 | kado24-mock-payment-service | /actuator/health |

## Infrastructure Services

| Service | Port | Container Name |
|---------|------|----------------|
| Redis | 6379 | kado24-redis |
| Kafka | 9092 | kado24-kafka |
| Zookeeper | 2181 | kado24-zookeeper |
| ETCD | 2379 | kado24-etcd |
| APISIX Gateway | 9080 | kado24-apisix |
| Prometheus | 9090 | kado24-prometheus |
| Grafana | 3000 | kado24-grafana |
| Redis Commander | 8090 | kado24-redis-commander |
| Kafka UI | 9000 | kado24-kafka-ui |

## Troubleshooting

### If a service is not responding:

1. **Check if container is running:**
   ```powershell
   docker ps --filter "name=kado24-auth-service"
   ```

2. **Check container logs:**
   ```powershell
   docker logs kado24-auth-service --tail 100
   ```

3. **Restart the service:**
   ```powershell
   docker-compose -f docker-compose.services.yml restart auth-service
   ```

4. **Check if port is in use:**
   ```powershell
   netstat -ano | findstr :8081
   ```

5. **Rebuild and restart:**
   ```powershell
   docker-compose -f docker-compose.services.yml up -d --build auth-service
   ```

## Expected Health Response

A healthy service should return:
```json
{
  "status": "UP"
}
```

Or with more details:
```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "redis": { "status": "UP" }
  }
}
```

## Quick Status Check (One-liner)

```powershell
@(8081, 8082, 8083, 8084, 8086, 8087, 8088, 8089, 8091, 8092, 8093, 8095) | ForEach-Object { $p = $_; try { $r = Invoke-WebRequest "http://localhost:$p/actuator/health" -TimeoutSec 2; Write-Host "✅ Port $p - OK" -ForegroundColor Green } catch { Write-Host "❌ Port $p - FAILED" -ForegroundColor Red } }
```

