# Setting Up JWT Auth in APISIX

## Overview

APISIX JWT Auth validates JWT tokens at the gateway level, providing:
- ✅ Better performance (validates before reaching backend)
- ✅ Centralized auth management
- ✅ Invalid tokens rejected early (403 from APISIX)

## Setup Steps

### Step 1: Create JWT Consumer

The JWT consumer must be created **before** routes are configured with jwt-auth.

```powershell
cd gateway\apisix
.\setup-jwt-consumer.ps1
```

This creates a consumer with:
- **Username**: `wallet-jwt-consumer`
- **Key**: `wallet-service-key`
- **Algorithm**: `HS256`
- **Secret**: `kado24-secret-key-change-this-in-production-minimum-256-bits-required-for-security`

### Step 2: Configure Routes

Run the main setup script to configure all routes with jwt-auth enabled for wallet routes:

```powershell
.\setup-all-routes-cors.ps1
```

This will:
- Enable `jwt-auth` on routes 9, 19, and 35 (wallet routes)
- Keep CORS enabled
- Configure all other routes

### Step 3: Verify Configuration

Check that the consumer exists:
```powershell
Invoke-RestMethod -Uri "http://localhost:9091/apisix/admin/consumers/wallet-jwt-consumer" `
    -Headers @{"X-API-KEY" = "edd1c9f034335f136f87ad84b625c8f1"}
```

Check that routes have jwt-auth:
```powershell
Invoke-RestMethod -Uri "http://localhost:9091/apisix/admin/routes/19" `
    -Headers @{"X-API-KEY" = "edd1c9f034335f136f87ad84b625c8f1"} | 
    Select-Object -ExpandProperty value | 
    Select-Object -ExpandProperty plugins
```

Should show `jwt_auth` in the plugins.

## How It Works

```
Frontend Request
    ↓
    Authorization: Bearer <jwt-token>
    ↓
APISIX Gateway (localhost:9080)
    ↓
    jwt-auth plugin validates token
    ↓
    ✅ Valid → Pass to wallet service
    ❌ Invalid → Return 403 Forbidden
    ↓
Wallet Service (localhost:8086)
    ↓
    Backend also validates (defense in depth)
    ↓
    Controller processes request
```

## JWT Secret

**Important:** The JWT secret must match between:
- APISIX consumer config
- Backend services (`application.yml` → `jwt.secret`)

Current default:
```
kado24-secret-key-change-this-in-production-minimum-256-bits-required-for-security
```

**⚠️ Change this in production!**

Generate a strong secret:
```bash
openssl rand -base64 32
```

## Troubleshooting

### 403 Forbidden

1. **Check if consumer exists:**
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:9091/apisix/admin/consumers/wallet-jwt-consumer" `
       -Headers @{"X-API-KEY" = "edd1c9f034335f136f87ad84b625c8f1"}
   ```

2. **Check if routes have jwt-auth:**
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:9091/apisix/admin/routes/19" `
       -Headers @{"X-API-KEY" = "edd1c9f034335f136f87ad84b625c8f1"}
   ```

3. **Check APISIX logs:**
   ```powershell
   docker logs kado24-apisix --tail 50
   ```

4. **Verify token is valid:**
   - Check if token is expired
   - Verify token is being sent in Authorization header
   - Check browser console Network tab

### Token Validation Errors

- **"Invalid JWT signature"**: JWT secret mismatch between APISIX and backend
- **"Expired JWT token"**: Token has expired, user needs to log in again
- **"Invalid JWT token"**: Token is malformed or invalid

## Files

- `setup-jwt-consumer.ps1` - Creates JWT consumer
- `setup-all-routes-cors.ps1` - Configures all routes (updated to use jwt-auth for wallet)
- `configure-jwt-auth.ps1` - Complete setup script (alternative)

## Next Steps

After setup:
1. Make sure you're logged in to the consumer app
2. Refresh the wallet screen
3. Valid JWT tokens should work!

The backend will still validate tokens (defense in depth), but APISIX will handle the primary validation at the gateway level.

