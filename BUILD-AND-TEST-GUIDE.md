# Build and Test Guide - Auth Service Security Fix

## Issue

The security configuration fix (changing filter chain order) requires rebuilding the Maven project to compile the Java changes.

## Current Status

- ✅ Security configuration code fixed
- ❌ Service not rebuilt with new code (needs Maven build)
- ⚠️ OAuth2 endpoints still returning 500 errors

## Solution

### Step 1: Build Maven Project

```powershell
cd backend/services/auth-service
mvn clean package -DskipTests
cd ../../..
```

This will:
- Compile the updated `SecurityConfiguration.java`
- Package as WAR file
- Place WAR in `target/` directory

### Step 2: Rebuild Docker Image

```powershell
docker-compose -f docker-compose.services.yml build auth-service
```

This will:
- Copy the new WAR file into Docker image
- Create new image with updated code

### Step 3: Restart Service

```powershell
docker-compose -f docker-compose.services.yml restart auth-service
```

Wait 30-60 seconds for service to start.

### Step 4: Verify Fix

```powershell
# Test OAuth2 token endpoint
$body = "grant_type=client_credentials&client_id=kado24-backend&client_secret=kado24-backend-secret&scope=read write"
Invoke-WebRequest -Uri "http://localhost:8081/oauth2/token" `
  -Method POST `
  -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} `
  -Body $body
```

Should return 200 with access token.

### Step 5: Run Integration Tests

```powershell
.\tests\run-all-tests.ps1
```

## Automated Script

After building Maven project, you can use:

```powershell
.\rebuild-and-test-auth.ps1
```

## Alternative: Build All Services

If you want to rebuild all services:

```powershell
# Build all Maven projects
cd backend
mvn clean package -DskipTests
cd ..

# Rebuild all Docker images
docker-compose -f docker-compose.services.yml build

# Restart all services
docker-compose -f docker-compose.services.yml restart
```

## Expected Results After Rebuild

- ✅ OAuth2 token endpoint: 200 OK with access token
- ✅ OIDC discovery endpoint: 200 OK with configuration
- ✅ Login endpoint: 200/401 (depending on credentials)
- ✅ Integration tests: 15+ passing

## Files Modified (Need Rebuild)

- `backend/services/auth-service/src/main/java/com/kado24/auth/config/SecurityConfiguration.java`
  - Changed `@Order(HIGHEST_PRECEDENCE)` to `@Order(2)`

## Notes

- The code fix is correct and will work after rebuild
- Current service is running old code (before fix)
- Maven build is required to compile Java changes
- Docker build copies WAR file into image

