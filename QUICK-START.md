# Kado24 Platform - Quick Start Guide

## After PC Restart - Quick Setup

### Option 1: Complete Platform Startup (Recommended)
```powershell
cd C:\workspaces\kado24-platform
.\start-platform.ps1
```

This script will:
1. ✅ Start infrastructure (Redis, etcd, APISIX)
2. ✅ Configure all APISIX routes with CORS
3. ✅ Start all backend services

### Option 2: Manual Step-by-Step

**1. Start Infrastructure:**
```powershell
cd infrastructure\docker
docker compose up -d
```

**2. Setup APISIX Routes with CORS:**
```powershell
cd ..\..\gateway\apisix
.\setup-all-routes-cors.ps1
```

**3. Start Backend Services:**
```powershell
cd ..\..
docker compose -f docker-compose.services.yml up -d auth-service user-service voucher-service order-service wallet-service redemption-service merchant-service admin-portal-backend notification-service payout-service analytics-service payment-service
```

**4. Start Frontend Apps:**
```powershell
# Consumer App
cd frontend\consumer-app
flutter run -d chrome --web-port=8002

# Merchant App (new terminal)
cd frontend\merchant-app
flutter run -d chrome --web-port=8001

# Admin Portal (new terminal)
cd frontend\admin-portal
ng serve --port 4200
```

## CORS Configuration

All routes are automatically configured with CORS for:
- **Consumer App**: http://localhost:8002
- **Merchant App**: http://localhost:8001
- **Admin Portal**: http://localhost:4200

## Troubleshooting

**If CORS errors occur:**
1. Run the setup script: `.\gateway\apisix\setup-all-routes-cors.ps1`
2. Verify APISIX is running: `docker ps | findstr apisix`
3. Check routes: `curl http://localhost:9091/apisix/admin/routes`

**If services don't start:**
1. Check Docker: `docker ps`
2. Check logs: `docker logs kado24-auth-service`
3. Verify network: `docker network ls | findstr kado24`

## Files Created

- `start-platform.ps1` - Complete startup script
- `gateway\apisix\setup-all-routes-cors.ps1` - CORS route setup script
- `scripts\setup-apisix-routes.ps1` - Quick route setup from root
- `gateway\apisix\README-CORS-SETUP.md` - Detailed CORS setup guide

## Quick Commands

```powershell
# Setup CORS routes only
.\scripts\setup-apisix-routes.ps1

# Or from gateway directory
cd gateway\apisix
.\setup-all-routes-cors.ps1
```

