# Quick Start: AWS RDS Setup

## 🚀 One-Command Setup

### Windows (PowerShell)
```powershell
. .\set-dev-env.ps1
```

### Linux/Mac (Bash)
```bash
source ./set-dev-env.sh
```

## ✅ Verify Setup

**PowerShell:**
```powershell
Get-ChildItem Env: | Where-Object { $_.Name -like '*POSTGRES*' }
```

**Bash:**
```bash
env | grep POSTGRES
```

## 🧪 Test Connection

**PowerShell:**
```powershell
. .\set-dev-env.ps1
cd backend\services\auth-service
mvn spring-boot:run
```

Look for successful database connection in logs.

## 📋 Database Info

- **Host**: `kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com`
- **Port**: `5432`
- **Database**: `postgres`
- **User**: `kado24_dev_user`

## ⚠️ Important

1. **Set environment variables** before starting any service
2. **Create schemas** in RDS (see `setup-database-schemas.sql`)
3. **Check security group** allows your IP address

## 📚 Full Documentation

See `AWS-RDS-SETUP.md` for complete setup guide.

