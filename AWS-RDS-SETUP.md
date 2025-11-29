# AWS RDS Setup Guide

## ✅ Configuration Complete

The project has been configured to use AWS RDS PostgreSQL for development environment.

## Database Connection Details

**Development Environment:**
- **Host**: `kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com`
- **Port**: `5432`
- **Database**: `postgres`
- **Username**: `kado24_dev_user`
- **Password**: `docTod-dyfvi0-nesbux`

## Quick Start

### Option 1: PowerShell (Windows)

```powershell
# Set environment variables
. .\set-dev-env.ps1

# Verify variables are set
Get-ChildItem Env: | Where-Object { $_.Name -like '*POSTGRES*' -or $_.Name -like '*DB_*' }

# Start your service
cd backend\services\auth-service
mvn spring-boot:run
```

### Option 2: Bash (Linux/Mac)

```bash
# Set environment variables
source ./set-dev-env.sh

# Verify variables are set
env | grep -E 'POSTGRES|DB_'

# Start your service
cd backend/services/auth-service
mvn spring-boot:run
```

### Option 3: Manual Environment Variables

Set these environment variables before running services:

**PowerShell:**
```powershell
$env:POSTGRES_HOST = "kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com"
$env:POSTGRES_PORT = "5432"
$env:POSTGRES_DB = "postgres"
$env:POSTGRES_USER = "kado24_dev_user"
$env:POSTGRES_PASSWORD = "docTod-dyfvi0-nesbux"
```

**Bash:**
```bash
export POSTGRES_HOST=kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com
export POSTGRES_PORT=5432
export POSTGRES_DB=postgres
export POSTGRES_USER=kado24_dev_user
export POSTGRES_PASSWORD=docTod-dyfvi0-nesbux
```

## How It Works

All services use environment variables for database configuration. The `application.yml` files already support this pattern:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST:${DB_HOST:localhost}}:${POSTGRES_PORT:${DB_PORT:5432}}/${POSTGRES_DB:${DB_NAME:kado24_db}}?currentSchema=auth_schema
    username: ${POSTGRES_USER:${DB_USER:kado24_user}}
    password: ${POSTGRES_PASSWORD:${DB_PASSWORD:kado24_pass}}
```

**Variable Priority:**
1. `POSTGRES_HOST` (or `DB_HOST`)
2. `POSTGRES_PORT` (or `DB_PORT`)
3. `POSTGRES_DB` (or `DB_NAME`)
4. `POSTGRES_USER` (or `DB_USER`)
5. `POSTGRES_PASSWORD` (or `DB_PASSWORD`)

If environment variables are not set, it falls back to localhost defaults.

## Services Using AWS RDS

All backend services will connect to AWS RDS when environment variables are set:

- ✅ auth-service
- ✅ user-service
- ✅ voucher-service
- ✅ order-service
- ✅ wallet-service
- ✅ redemption-service
- ✅ merchant-service
- ✅ admin-portal-backend
- ✅ notification-service
- ✅ payout-service
- ✅ analytics-service

## Testing Connection

### Test from Command Line

**PowerShell:**
```powershell
. .\set-dev-env.ps1
$env:PGPASSWORD = $env:POSTGRES_PASSWORD
psql -h $env:POSTGRES_HOST -p $env:POSTGRES_PORT -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "SELECT version();"
```

**Bash:**
```bash
source ./set-dev-env.sh
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT version();"
```

### Test from Application

Start any service and check logs for database connection:

```powershell
cd backend\services\auth-service
. ..\..\..\set-dev-env.ps1
mvn spring-boot:run
```

Look for:
```
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
```

## Important Notes

### 1. Security Groups

Ensure your AWS RDS security group allows inbound connections from:
- Your development machine's IP address
- Your application servers (if running on EC2)

**RDS Security Group Rules:**
- Type: PostgreSQL
- Port: 5432
- Source: Your IP address or security group

### 2. Network Access

- RDS must be accessible from your network
- Check VPC and subnet configurations
- Verify security group rules

### 3. SSL Connection (Recommended)

For production, consider enabling SSL connections:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?ssl=true&sslmode=require
```

### 4. Connection Pooling

HikariCP is configured with:
- Maximum pool size: 3 (dev) / 20 (prod)
- Connection timeout: 20 seconds
- Idle timeout: 5 minutes

### 5. Schema Configuration

Each service uses its own schema:
- `auth_schema` - auth-service
- `user_schema` - user-service
- `voucher_schema` - voucher-service
- etc.

Make sure these schemas exist in the RDS database.

## Troubleshooting

### Connection Timeout

**Issue**: Cannot connect to RDS

**Solutions**:
1. Check security group allows your IP
2. Verify RDS is publicly accessible (if needed)
3. Check VPC and subnet configurations
4. Verify network connectivity: `telnet kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com 5432`

### Authentication Failed

**Issue**: Wrong username or password

**Solutions**:
1. Verify environment variables are set correctly
2. Check RDS master username and password
3. Ensure user has proper permissions

### Database Not Found

**Issue**: Database `postgres` doesn't exist

**Solutions**:
1. Create the database in RDS
2. Or update `POSTGRES_DB` to an existing database name

### Schema Not Found

**Issue**: Service schema doesn't exist

**Solutions**:
1. Connect to RDS and create required schemas:
   ```sql
   CREATE SCHEMA IF NOT EXISTS auth_schema;
   CREATE SCHEMA IF NOT EXISTS user_schema;
   CREATE SCHEMA IF NOT EXISTS voucher_schema;
   -- etc.
   ```

## Local Development vs AWS RDS

### Using Local PostgreSQL

If you want to use local PostgreSQL instead:

```powershell
# Unset environment variables or use defaults
Remove-Item Env:POSTGRES_HOST -ErrorAction SilentlyContinue
Remove-Item Env:POSTGRES_PORT -ErrorAction SilentlyContinue
# Services will use localhost defaults
```

### Using AWS RDS

Always set environment variables before starting services:

```powershell
. .\set-dev-env.ps1
# Now start services - they will use AWS RDS
```

## Next Steps

1. ✅ Set environment variables using `set-dev-env.ps1` or `set-dev-env.sh`
2. ✅ Verify connection to AWS RDS
3. ✅ Create required schemas in RDS database
4. ✅ Start services and verify they connect successfully
5. ✅ Test OAuth2 implementation with AWS RDS

## Security Best Practices

1. **Never commit passwords** to version control
2. **Use AWS Secrets Manager** for production passwords
3. **Enable SSL** for production connections
4. **Rotate passwords** regularly
5. **Use IAM database authentication** if possible
6. **Restrict security group** access to specific IPs

