# JWT Auth Verification - All Frontend Apps

## Overview

All frontend apps (Consumer, Merchant, Admin Portal) now:
- ✅ Use JWT auth via APISIX (except login/register screens)
- ✅ Redirect to login screen on 401/403 errors
- ✅ Clear auth state when authentication fails

## APISIX Route Configuration

### Public Routes (NO jwt-auth)
These routes are accessible without authentication:
- `/api/v1/auth/*` - Login, register, OTP, etc.
- `/api/v1/vouchers` - Public voucher listing (GET)
- `/api/v1/vouchers/*` - Public voucher details (GET)
- `/api/v1/vouchers/search` - Public search
- `/api/v1/vouchers/category/*` - Public category listing
- `/api/v1/vouchers/*/reviews` - Public reviews
- `/api/v1/categories` - Public categories
- `/api/mock/payment/*` - Mock payment endpoints

### Protected Routes (jwt-auth ENABLED)
All other routes require valid JWT token:
- `/api/v1/users/*` - User management
- `/api/v1/vouchers/*` - Voucher write operations (POST, PUT, DELETE)
- `/api/v1/vouchers/my-vouchers` - User's vouchers
- `/api/v1/orders/*` - Order management
- `/api/v1/payments/*` - Payment processing
- `/api/v1/wallet/*` - Wallet operations
- `/api/v1/redemptions/*` - Redemption operations
- `/api/v1/merchants/*` - Merchant operations
- `/api/v1/notifications/*` - Notifications
- `/api/v1/payouts/*` - Payouts
- `/api/v1/analytics/*` - Analytics
- `/api/v1/admin/*` - Admin operations

## Frontend Error Handling

### Consumer App (Flutter)
**Files Updated:**
- `lib/services/api_service.dart` - Handles 401/403 in all HTTP methods
- `lib/utils/auth_error_handler.dart` - Utility for auth error handling
- `lib/screens/wallet/wallet_screen.dart` - Example of error handling

**How it works:**
```dart
try {
  // API call
} catch (e) {
  if (AuthErrorHandler.isAuthError(e)) {
    AuthErrorHandler.handleAuthError(context, e);
    // Redirects to /login and clears auth state
  }
}
```

### Merchant App (Flutter)
**Files Updated:**
- `lib/services/merchant_api_service.dart` - All methods handle 401/403
- `lib/utils/auth_error_handler.dart` - Utility for auth error handling

**How it works:**
- All API methods throw exceptions with status code
- Screens should catch and use `AuthErrorHandler.handleAuthError()`

### Admin Portal (Angular)
**Files Updated:**
- `src/app/interceptors/auth.interceptor.ts` - HTTP interceptor
- `src/app/app.module.ts` - Registered interceptor

**How it works:**
- Interceptor automatically adds JWT token to requests
- Catches 401/403 errors and redirects to `/login`
- Clears auth state via `AuthService.logout()`

## Verification

### Check APISIX Routes
```powershell
cd gateway\apisix
.\verify-jwt-routes.ps1
```

### Fix Routes
```powershell
cd gateway\apisix
.\setup-jwt-consumer.ps1  # Create consumer first
.\fix-all-jwt-routes.ps1  # Fix all routes
```

### Test Frontend
1. **Consumer App:**
   - Try accessing wallet without login → Should redirect to login
   - Try accessing with expired token → Should redirect to login

2. **Merchant App:**
   - Try accessing dashboard without login → Should redirect to login
   - Try API call with invalid token → Should redirect to login

3. **Admin Portal:**
   - Try accessing dashboard without login → Should redirect to login
   - API calls with 401/403 → Should redirect to login

## Files Created/Modified

### Consumer App
- ✅ `lib/services/api_service.dart` - Updated to handle 401/403
- ✅ `lib/utils/auth_error_handler.dart` - New utility
- ✅ `lib/screens/wallet/wallet_screen.dart` - Updated error handling

### Merchant App
- ✅ `lib/services/merchant_api_service.dart` - Updated all methods
- ✅ `lib/utils/auth_error_handler.dart` - New utility

### Admin Portal
- ✅ `src/app/interceptors/auth.interceptor.ts` - New interceptor
- ✅ `src/app/app.module.ts` - Registered interceptor

### APISIX
- ✅ `gateway/apisix/setup-jwt-consumer.ps1` - JWT consumer setup
- ✅ `gateway/apisix/fix-all-jwt-routes.ps1` - Route fix script
- ✅ `gateway/apisix/verify-jwt-routes.ps1` - Verification script
- ✅ `gateway/apisix/setup-all-routes-cors.ps1` - Updated for jwt-auth

## Testing Checklist

- [ ] Consumer app redirects to login on 401/403
- [ ] Merchant app redirects to login on 401/403
- [ ] Admin portal redirects to login on 401/403
- [ ] Login/register screens work (no jwt-auth required)
- [ ] Protected routes require valid JWT token
- [ ] Invalid/expired tokens redirect to login
- [ ] Valid tokens allow access to protected routes

