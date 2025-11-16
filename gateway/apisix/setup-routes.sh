#!/bin/bash

# =============================================
# Kado24 Platform - APISIX Route Configuration
# =============================================

set -e

APISIX_ADMIN="http://localhost:9091/apisix/admin"
API_KEY="edd1c9f034335f136f87ad84b625c8f1"

echo "🚀 Configuring APISIX routes for Kado24 platform..."

# Helper function to create/update routes
create_route() {
    local route_id=$1
    local config=$2
    
    echo "📍 Creating route: ${route_id}"
    
    curl -s -X PUT "${APISIX_ADMIN}/routes/${route_id}" \
        -H "X-API-KEY: ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "${config}" | jq '.'
}

# Helper function to create upstream
create_upstream() {
    local upstream_id=$1
    local config=$2
    
    echo "🔗 Creating upstream: ${upstream_id}"
    
    curl -s -X PUT "${APISIX_ADMIN}/upstreams/${upstream_id}" \
        -H "X-API-KEY: ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "${config}" | jq '.'
}

# =============================================
# UPSTREAMS
# =============================================

echo ""
echo "📡 Creating upstreams..."

# Auth Service Upstream
create_upstream "auth-service-upstream" '{
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
}'

# User Service Upstream
create_upstream "user-service-upstream" '{
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
}'

# Voucher Service Upstream
create_upstream "voucher-service-upstream" '{
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
}'

# Order Service Upstream
create_upstream "order-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-order-service:8084": 1
  }
}'

# Payment Service Upstream
create_upstream "payment-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-payment-service:8085": 1
  }
}'

# Wallet Service Upstream
create_upstream "wallet-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-wallet-service:8086": 1
  }
}'

# Redemption Service Upstream
create_upstream "redemption-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-redemption-service:8087": 1
  }
}'

# Merchant Service Upstream
create_upstream "merchant-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-merchant-service:8088": 1
  }
}'

# Admin Portal Backend Upstream
create_upstream "admin-portal-backend-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-admin-portal-backend:8089": 1
  }
}'

# Notification Service Upstream
create_upstream "notification-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-notification-service:8091": 1
  }
}'

# Payout Service Upstream
create_upstream "payout-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-payout-service:8092": 1
  }
}'

# Analytics Service Upstream
create_upstream "analytics-service-upstream" '{
  "type": "roundrobin",
  "nodes": {
    "kado24-analytics-service:8093": 1
  }
}'

# =============================================
# ROUTES
# =============================================

echo ""
echo "🛤️  Creating routes..."

# 1. Auth Service Routes (Public)
create_route "1" '{
  "name": "auth-service-route",
  "uri": "/api/v1/auth/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  "upstream_id": "auth-service-upstream",
  "plugins": {
    "cors": {
      "allow_origins": "http://localhost:4200",
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
}'

# 2. User Service Routes (Protected)
create_route "2" '{
  "name": "user-service-route",
  "uri": "/api/v1/users/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH"],
  "upstream_id": "user-service-upstream",
  "plugins": {
    "jwt-auth": {
      "header": "Authorization",
      "query": "token"
    },
    "cors": {},
    "limit-count": {
      "count": 100,
      "time_window": 60,
      "key": "remote_addr",
      "rejected_code": 429
    },
    "prometheus": {}
  }
}'

# 3. Voucher Service - Public READ
create_route "3" '{
  "name": "voucher-service-public-read",
  "uri": "/api/v1/vouchers",
  "methods": ["GET"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "cors": {},
    "limit-count": {
      "count": 200,
      "time_window": 60,
      "key": "remote_addr"
    },
    "proxy-cache": {
      "cache_zone": "disk_cache_one",
      "cache_key": ["$uri", "$args"],
      "cache_bypass": ["$arg_nocache"],
      "cache_method": ["GET"],
      "cache_http_status": [200],
      "hide_cache_headers": true,
      "no_cache": ["$arg_nocache"]
    },
    "prometheus": {}
  }
}'

# 4. Voucher Service - Single Voucher (Public)
create_route "4" '{
  "name": "voucher-service-single",
  "uri": "/api/v1/vouchers/*",
  "methods": ["GET"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "cors": {},
    "limit-count": {
      "count": 150,
      "time_window": 60
    },
    "proxy-cache": {
      "cache_zone": "disk_cache_one",
      "cache_key": ["$uri"],
      "cache_method": ["GET"],
      "cache_http_status": [200]
    }
  }
}'

# 5. Voucher Service - Protected WRITE
create_route "5" '{
  "name": "voucher-service-protected-write",
  "uri": "/api/v1/vouchers/*",
  "methods": ["POST", "PUT", "DELETE", "PATCH"],
  "upstream_id": "voucher-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

# 6. Order Service Routes (Protected)
create_route "6" '{
  "name": "order-service-route",
  "uri": "/api/v1/orders/*",
  "methods": ["GET", "POST", "PUT", "DELETE"],
  "upstream_id": "order-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "limit-count": {
      "count": 50,
      "time_window": 60
    },
    "prometheus": {}
  }
}'

# 7. Payment Service Routes (Protected)
create_route "7" '{
  "name": "payment-service-route",
  "uri": "/api/v1/payments/*",
  "methods": ["GET", "POST"],
  "upstream_id": "payment-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "limit-req": {
      "rate": 10,
      "burst": 5,
      "key": "remote_addr"
    },
    "prometheus": {}
  }
}'

# 8. Payment Callbacks (Public - from payment gateways)
create_route "8" '{
  "name": "payment-callbacks",
  "uri": "/api/v1/payments/callbacks/*",
  "methods": ["GET", "POST"],
  "upstream_id": "payment-service-upstream",
  "plugins": {
    "cors": {},
    "ip-restriction": {
      "whitelist": [
        "0.0.0.0/0"
      ]
    },
    "prometheus": {}
  }
}'

# 9. Wallet Service Routes (Protected)
create_route "9" '{
  "name": "wallet-service-route",
  "uri": "/api/v1/wallet/*",
  "methods": ["GET", "POST", "PUT", "DELETE"],
  "upstream_id": "wallet-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

# 10. Redemption Service Routes (Protected)
create_route "10" '{
  "name": "redemption-service-route",
  "uri": "/api/v1/redemptions/*",
  "methods": ["GET", "POST"],
  "upstream_id": "redemption-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "limit-req": {
      "rate": 30,
      "burst": 10,
      "key": "remote_addr"
    },
    "prometheus": {}
  }
}'

# 11. Merchant Service Routes (Protected)
create_route "11" '{
  "name": "merchant-service-route",
  "uri": "/api/v1/merchants/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH"],
  "upstream_id": "merchant-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

# 12. Admin Portal Backend Routes (Admin Only)
create_route "12" '{
  "name": "admin-portal-backend-route",
  "uri": "/api/admin/*",
  "methods": ["GET", "POST", "PUT", "DELETE", "PATCH"],
  "upstream_id": "admin-portal-backend-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "proxy-rewrite": {
      "regex_uri": ["^/api/admin/(.*)", "/api/v1/$1"]
    },
    "prometheus": {}
  }
}'

# 13. Health Check Route (Public)
create_route "13" '{
  "name": "health-check-route",
  "uri": "/health",
  "methods": ["GET"],
  "plugins": {
    "echo": {
      "body": "{\\"status\\": \\"ok\\", \\"service\\": \\"APISIX Gateway\\"}"
    }
  }
}'

# 14. Notification Service Routes
create_route "14" '{
  "name": "notification-service-route",
  "uri": "/api/v1/notifications/*",
  "methods": ["GET","POST","PUT","DELETE","PATCH"],
  "upstream_id": "notification-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

# 15. Payout Service Routes
create_route "15" '{
  "name": "payout-service-route",
  "uri": "/api/v1/payouts/*",
  "methods": ["GET","POST","PUT","DELETE","PATCH"],
  "upstream_id": "payout-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

# 16. Analytics Service Routes
create_route "16" '{
  "name": "analytics-service-route",
  "uri": "/api/v1/analytics/*",
  "methods": ["GET","POST"],
  "upstream_id": "analytics-service-upstream",
  "plugins": {
    "jwt-auth": {},
    "cors": {},
    "prometheus": {}
  }
}'

echo ""
echo "✅ APISIX routes configured successfully!"
echo ""
echo "📊 Access points:"
echo "  - Gateway: http://localhost:9080"
echo "  - Admin API: http://localhost:9091"
echo "  - Prometheus Metrics: http://localhost:9091/apisix/prometheus/metrics"
echo ""
echo "🔑 Admin API Key: ${API_KEY}"
echo ""
echo "Test with: curl http://localhost:9080/health"











