# Troubleshooting Backend Services Startup

## Quick Diagnosis

Run this to check what's wrong:
```powershell
powershell -ExecutionPolicy Bypass -File start-services-simple.ps1
```

## Common Issues and Solutions

### Issue 1: Services Not Built

**Symptoms:**
- Docker containers exit immediately
- No JAR/WAR files in `target/` directories

**Solution:**
```powershell
# Build shared libraries first
cd backend\shared\common-lib
mvn clean install -DskipTests
cd ..\security-lib
mvn clean install -DskipTests
cd ..\..\..

# Build all services
.\build-maven-services.ps1
```

### Issue 2: Database Connection Failed

**Symptoms:**
- Services start but exit with database errors
- Logs show "Connection refused" or "Authentication failed"

**Solution:**
```powershell
# Set AWS RDS environment variables
. .\set-dev-env.ps1

# Verify connection
# Test from your machine (not Docker)
Test-NetConnection -ComputerName kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com -Port 5432
```

**For Docker services:**
- Docker containers can't use `host.docker.internal` to reach AWS RDS
- You need to either:
  1. Use AWS RDS endpoint directly (if security group allows)
  2. Or use a VPN/bastion host
  3. Or run services locally (not in Docker)

### Issue 3: Port Already in Use

**Symptoms:**
- Docker error: "port is already allocated"

**Solution:**
```powershell
# Find what's using the port
netstat -ano | findstr :8081

# Stop existing containers
docker stop kado24-auth-service
docker rm kado24-auth-service
```

### Issue 4: Docker Build Fails

**Symptoms:**
- Build errors during `docker compose up --build`

**Solution:**
```powershell
# Check Dockerfile
cat backend\services\auth-service\Dockerfile

# Build manually to see errors
cd backend\services\auth-service
docker build -t kado24/auth-service:latest .
```

### Issue 5: Missing Dependencies

**Symptoms:**
- Maven build fails
- "Cannot resolve dependency" errors

**Solution:**
```powershell
# Clean and rebuild
cd backend\shared\common-lib
mvn clean install -DskipTests
cd ..\security-lib
mvn clean install -DskipTests
cd ..\..\services\auth-service
mvn clean install -DskipTests
```

## Step-by-Step Startup Process

### Option A: Start Locally (Recommended for AWS RDS)

1. **Set environment variables:**
   ```powershell
   . .\set-dev-env.ps1
   ```

2. **Build services:**
   ```powershell
   .\build-maven-services.ps1
   ```

3. **Start infrastructure:**
   ```powershell
   cd infrastructure\docker
   docker compose up -d
   cd ..\..
   ```

4. **Start services locally:**
   ```powershell
   cd backend\services\auth-service
   java -jar target\auth-service-1.0.0.jar
   ```

### Option B: Start in Docker (For Local Database)

1. **Build services:**
   ```powershell
   .\build-maven-services.ps1
   ```

2. **Start everything:**
   ```powershell
   docker compose -f docker-compose.services.yml up -d --build
   ```

## Check Service Status

```powershell
# Check running containers
docker ps --filter "name=kado24"

# Check all containers (including stopped)
docker ps -a --filter "name=kado24"

# Check logs
docker logs kado24-auth-service

# Check health
curl http://localhost:8081/actuator/health
```

## Next Steps

1. Run the diagnostic script: `.\start-services-simple.ps1`
2. Check the output to see which services failed
3. Review logs for failed services
4. Fix issues based on error messages
5. Try starting again

