# =============================================
# Kado24 Platform - APISIX Route Configuration (PowerShell)
# =============================================

$APISIX_ADMIN = "http://localhost:9091/apisix/admin"
$API_KEY = "edd1c9f034335f136f87ad84b625c8f1"
$headers = @{
    "X-API-KEY" = $API_KEY
    "Content-Type" = "application/json"
}

Write-Host "🚀 Configuring APISIX routes for Kado24 platform..." -ForegroundColor Green

# Helper function to create/update routes
function Create-Route {
    param(
        [string]$RouteId,
        [string]$Config
    )
    
    Write-Host "📍 Creating route: $RouteId" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/routes/$RouteId" `
            -Headers $headers `
            -Method PUT `
            -Body $Config `
            -ErrorAction Stop
        Write-Host "  ✅ Route $RouteId created successfully" -ForegroundColor Green
        return $response.Content | ConvertFrom-Json
    } catch {
        Write-Host "  ❌ Failed to create route $RouteId : $_" -ForegroundColor Red
        return $null
    }
}

# Helper function to create upstream
function Create-Upstream {
    param(
        [string]$UpstreamId,
        [string]$Config
    )
    
    Write-Host "🔗 Creating upstream: $UpstreamId" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "$APISIX_ADMIN/upstreams/$UpstreamId" `
            -Headers $headers `
            -Method PUT `
            -Body $Config `
            -ErrorAction Stop
        Write-Host "  ✅ Upstream $UpstreamId created successfully" -ForegroundColor Green
        return $response.Content | ConvertFrom-Json
    } catch {
        Write-Host "  ❌ Failed to create upstream $UpstreamId : $_" -ForegroundColor Red
        return $null
    }
}

# =============================================
# UPSTREAMS
# =============================================

Write-Host ""
Write-Host "📡 Creating upstreams..." -ForegroundColor Yellow

# Auth Service Upstream
Create-Upstream "auth-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-auth-service:8081": 1
  },
  "timeout": {
    "connect": 6,
    "send": 6,
    "read": 6
  },
  "keepalive_pool": {
    "idle_timeout": 60,
    "requests": 1000,
    "size": 320
  },
  "checks": {
    "active": {
      "type": "http",
      "http_path": "/actuator/health",
      "healthy": {
        "interval": 10,
        "successes": 2
      },
      "unhealthy": {
        "interval": 5,
        "http_failures": 3
      }
    }
  }
}
'@

# User Service Upstream
Create-Upstream "user-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-user-service:8082": 1
  },
  "timeout": {
    "connect": 6,
    "send": 6,
    "read": 6
  },
  "checks": {
    "active": {
      "type": "http",
      "http_path": "/actuator/health",
      "healthy": {
        "interval": 10,
        "successes": 2
      }
    }
  }
}
'@

# Voucher Service Upstream
Create-Upstream "voucher-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-voucher-service:8083": 1
  },
  "checks": {
    "active": {
      "type": "http",
      "http_path": "/actuator/health",
      "healthy": {
        "interval": 10,
        "successes": 2
      }
    }
  }
}
'@

# Order Service Upstream
Create-Upstream "order-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-order-service:8084": 1
  }
}
'@

# Payment Service Upstream (Mock Payment Service)
Create-Upstream "payment-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-mock-payment-service:8095": 1
  }
}
'@

# Wallet Service Upstream
Create-Upstream "wallet-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-wallet-service:8086": 1
  }
}
'@

# Redemption Service Upstream
Create-Upstream "redemption-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-redemption-service:8087": 1
  }
}
'@

# Merchant Service Upstream
Create-Upstream "merchant-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-merchant-service:8088": 1
  }
}
'@

# Admin Portal Backend Upstream
Create-Upstream "admin-portal-backend-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-admin-portal-backend:8089": 1
  }
}
'@

# Notification Service Upstream
Create-Upstream "notification-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-notification-service:8091": 1
  }
}
'@

# Payout Service Upstream
Create-Upstream "payout-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-payout-service:8092": 1
  }
}
'@

# Analytics Service Upstream
Create-Upstream "analytics-service-upstream" @'
{
  "type": "roundrobin",
  "nodes": {
    "kado24-analytics-service:8093": 1
  }
}
'@

# =============================================
# ROUTES
# =============================================

Write-Host ""
Write-Host "🛤️  Creating routes..." -ForegroundColor Yellow

# 1. Auth Service Routes (Public)
Create-Route "1" @'
{
  "name": "auth-service-route",
  "uri": "/api/v1/auth/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  "upstream_id": "auth-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-req": {
      "rate": 20,
      "burst": 10,
      "key": "remote_addr",
      "rejected_code": 429,
      "rejected_msg": "Too many requests"
    },
    "prometheus": {}
  }
}
'@

# 2. User Service Routes (Protected) - Backend handles JWT validation
Create-Route "2" @'
{
  "name": "user-service-route",
  "uri": "/api/v1/users/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  "upstream_id": "user-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-count": {
      "count": 100,
      "time_window": 60,
      "key": "remote_addr",
      "rejected_code": 429
    },
    "prometheus": {}
  }
}
'@

# 3. Voucher Service - Public READ
Create-Route "3" @'
{
  "name": "voucher-service-public-read",
  "uri": "/api/v1/vouchers",
  "methods": ["GET", "OPTIONS"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-count": {
      "count": 200,
      "time_window": 60,
      "key": "remote_addr"
    },
    "prometheus": {}
  }
}
'@

# 4. Voucher Service - Single Voucher (Public)
Create-Route "4" @'
{
  "name": "voucher-service-single",
  "uri": "/api/v1/vouchers/*",
  "methods": ["GET", "OPTIONS"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-count": {
      "count": 150,
      "time_window": 60
    },
    "prometheus": {}
  }
}
'@

# 5. Voucher Service - Protected WRITE
Create-Route "5" @'
{
  "name": "voucher-service-protected-write",
  "uri": "/api/v1/vouchers/*",
  "methods": ["POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 6. Order Service Routes (Protected)
Create-Route "6" @'
{
  "name": "order-service-route",
  "uri": "/api/v1/orders/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  "upstream_id": "order-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-count": {
      "count": 50,
      "time_window": 60
    },
    "prometheus": {}
  }
}
'@

# 7. Payment Service Routes (Protected)
Create-Route "7" @'
{
  "name": "payment-service-route",
  "uri": "/api/v1/payments/*",
  "methods": ["GET", "POST", "OPTIONS"],
  "upstream_id": "payment-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-req": {
      "rate": 10,
      "burst": 5,
      "key": "remote_addr"
    },
    "prometheus": {}
  }
}
'@

# 8. Payment Callbacks (Public - from payment gateways)
Create-Route "8" @'
{
  "name": "payment-callbacks",
  "uri": "/api/v1/payments/callbacks/*",
  "methods": ["GET", "POST", "OPTIONS"],
  "upstream_id": "payment-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "*",
      "allow_methods": "GET,POST,OPTIONS",
      "allow_headers": "Content-Type,Accept",
      "max_age": 3600
    },
    "prometheus": {}
  }
}
'@

# 9. Wallet Service Routes (Protected)
Create-Route "9" @'
{
  "name": "wallet-service-route",
  "uri": "/api/v1/wallet/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  "upstream_id": "wallet-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 10. Redemption Service Routes (Protected)
Create-Route "10" @'
{
  "name": "redemption-service-route",
  "uri": "/api/v1/redemptions/*",
  "methods": ["GET", "POST", "OPTIONS"],
  "upstream_id": "redemption-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "limit-req": {
      "rate": 30,
      "burst": 10,
      "key": "remote_addr"
    },
    "prometheus": {}
  }
}
'@

# 11. Merchant Service Routes (Protected)
Create-Route "11" @'
{
  "name": "merchant-service-route",
  "uri": "/api/v1/merchants/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  "upstream_id": "merchant-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 12. Admin Portal Backend Routes (Admin Only) - via auth-service
Create-Route "12" @'
{
  "name": "admin-portal-backend-route",
  "uri": "/api/v1/admin/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  "upstream_id": "auth-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 13. Health Check Route (Public)
Create-Route "13" @'
{
  "name": "health-check-route",
  "uri": "/health",
  "methods": ["GET"],
  "plugins": {
    "echo": {
      "body": "{\"status\": \"ok\", \"service\": \"APISIX Gateway\"}"
    }
  }
}
'@

# 14. Notification Service Routes
Create-Route "14" @'
{
  "name": "notification-service-route",
  "uri": "/api/v1/notifications/*",
  "methods": ["GET","POST","PUT","DELETE","PATCH","OPTIONS"],
  "upstream_id": "notification-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 15. Payout Service Routes
Create-Route "15" @'
{
  "name": "payout-service-route",
  "uri": "/api/v1/payouts/*",
  "methods": ["GET","POST","PUT","DELETE","PATCH","OPTIONS"],
  "upstream_id": "payout-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

# 16. Analytics Service Routes
Create-Route "16" @'
{
  "name": "analytics-service-route",
  "uri": "/api/v1/analytics/*",
  "methods": ["GET","POST","OPTIONS"],
  "upstream_id": "analytics-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {
      "allow_origins": "http://localhost:4200,http://localhost:8001,http://localhost:8002",
      "allow_methods": "GET,POST,OPTIONS",
      "allow_headers": "Authorization,Content-Type,Accept",
      "expose_headers": "Authorization,Content-Type,Accept",
      "max_age": 3600,
      "allow_credential": true
    },
    "prometheus": {}
  }
}
'@

Write-Host ""
Write-Host "✅ APISIX routes configured successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access points:" -ForegroundColor Cyan
Write-Host "  - Gateway: http://localhost:9080"
Write-Host "  - Admin API: http://localhost:9091"
Write-Host "  - Prometheus Metrics: http://localhost:9091/apisix/prometheus/metrics"
Write-Host ""
Write-Host "Admin API Key: $API_KEY" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test with: curl http://localhost:9080/health" -ForegroundColor Cyan

