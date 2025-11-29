# Backend Services Startup Guide

## Current Situation

Backend services need to be **built first** before they can start. Services are configured as WAR files for Tomcat deployment.

## Quick Start (Recommended)

### Step 1: Build Services
```powershell
# Build shared libraries
cd backend\shared\common-lib
mvn clean install -DskipTests
cd ..\security-lib
mvn clean install -DskipTests
cd ..\..\..

# Build all backend services
.\build-maven-services.ps1
```

### Step 2: Set AWS RDS Environment Variables
```powershell
. .\set-dev-env.ps1
```

### Step 3: Start Infrastructure
```powershell
cd infrastructure\docker
docker compose up -d
cd ..\..
```

### Step 4: Start Services

**Option A: Start in Docker (if using local database)**
```powershell
docker compose -f docker-compose.services.yml up -d --build
```

**Option B: Start Locally (recommended for AWS RDS)**
```powershell
# Start auth-service as example
cd backend\services\auth-service
java -jar target\auth-service-1.0.0.war
```

## Important Notes

### AWS RDS Connection from Docker

⚠️ **Docker containers cannot directly connect to AWS RDS** using `host.docker.internal`.

**Solutions:**
1. **Run services locally** (not in Docker) - Recommended
2. **Use AWS RDS endpoint directly** in docker-compose (update POSTGRES_HOST)
3. **Use VPN or bastion host** to access AWS RDS

### For Local Development with AWS RDS

1. Set environment variables: `. .\set-dev-env.ps1`
2. Build services: `.\build-maven-services.ps1`
3. Start services locally (not Docker)
4. Services will connect to AWS RDS directly

## Available Scripts

- `build-and-start-services.ps1` - Builds and starts everything
- `start-services-simple.ps1` - Simple startup with error checking
- `start-services-docker.ps1` - Docker-only startup
- `start-backend-services.ps1` - Local startup (opens separate windows)

## Check Service Status

```powershell
# Docker services
docker ps --filter "name=kado24"

# Test health endpoint
curl http://localhost:8081/actuator/health
```

## Troubleshooting

See `TROUBLESHOOT-SERVICES.md` for detailed troubleshooting guide.

## Next Steps

1. ✅ Build services first
2. ✅ Set AWS RDS environment variables
3. ✅ Start infrastructure (Redis, etcd, APISIX)
4. ✅ Start services (locally recommended for AWS RDS)
5. ✅ Verify services are running

