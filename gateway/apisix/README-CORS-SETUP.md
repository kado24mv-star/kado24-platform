# APISIX CORS Setup - Permanent Configuration

This guide helps you set up CORS for all frontend applications permanently.

## Quick Setup After PC Restart

After restarting your PC or Docker containers, run this script to configure all routes with CORS:

### Option 1: From Project Root
```powershell
cd C:\workspaces\kado24-platform
.\scripts\setup-apisix-routes.ps1
```

### Option 2: From Gateway Directory
```powershell
cd C:\workspaces\kado24-platform\gateway\apisix
.\setup-all-routes-cors.ps1
```

## What This Script Does

1. **Creates all upstreams** for backend services
2. **Creates all routes** with CORS enabled for:
   - Consumer App (localhost:8002)
   - Merchant App (localhost:8001)
   - Admin Portal (localhost:4200)

## Routes Configured

### Consumer App Routes
- `/api/v1/auth/*` - Authentication
- `/api/v1/users/*` - User management
- `/api/v1/vouchers/*` - Voucher browsing
- `/api/v1/categories` - Categories
- `/api/v1/orders/*` - Order management
- `/api/v1/wallet/*` - Wallet management
- `/api/v1/payments` - Payment processing
- `/api/v1/notifications/*` - Notifications
- `/api/mock/payment/*` - Mock payment gateway

### Merchant App Routes
- `/api/v1/merchants/*` - Merchant management
- `/api/v1/vouchers/my-vouchers` - Merchant vouchers
- `/api/v1/redemptions/*` - Redemption processing
- `/api/v1/payouts/*` - Payout management

### Admin Portal Routes
- `/api/v1/admin/*` - Admin operations
- `/api/v1/admin/verifications/*` - User verifications

## CORS Configuration

All routes are configured with:
- **Allowed Origins**: `http://localhost:4200`, `http://localhost:8001`, `http://localhost:8002`
- **Allowed Methods**: GET, POST, PUT, DELETE, PATCH, OPTIONS
- **Allowed Headers**: Authorization, Content-Type, Accept, X-Requested-With
- **Credentials**: Enabled
- **Max Age**: 3600 seconds

## Troubleshooting

If routes fail to create:
1. Check if APISIX is running: `docker ps | findstr apisix`
2. Check if etcd is running: `docker ps | findstr etcd`
3. Verify admin API is accessible: `curl http://localhost:9091/apisix/admin/routes`

## Automation (Optional)

You can create a batch file to run this automatically:

**Create `start-platform.ps1` in project root:**
```powershell
# Start infrastructure
cd infrastructure\docker
docker compose up -d

# Wait for APISIX to be ready
Start-Sleep -Seconds 10

# Setup routes
cd ..\..\gateway\apisix
.\setup-all-routes-cors.ps1

# Start backend services
cd ..\..
docker compose -f docker-compose.services.yml up -d auth-service user-service voucher-service order-service wallet-service redemption-service merchant-service admin-portal-backend notification-service payout-service analytics-service payment-service
```

Then run: `.\start-platform.ps1`

