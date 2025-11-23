# 🚀 Start Deployment - Complete Guide

## Current Status: ✅ Ready to Deploy

All configuration files, scripts, and documentation are ready. You just need to install 2 tools and configure AWS.

## ⚡ Quick Start (3 Steps)

### Step 1: Install Tools (10 minutes)

**AWS CLI:**
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run installer
3. **Restart PowerShell**

**Terraform:**
1. Download: https://developer.hashicorp.com/terraform/downloads
2. Extract ZIP to `C:\terraform`
3. Add to PATH:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")
   ```
4. **Restart PowerShell**

**Verify:**
```powershell
aws --version
terraform version
```

### Step 2: Configure AWS (2 minutes)

1. **Get AWS Credentials:**
   - Go to: https://console.aws.amazon.com/iam/
   - Click "Users" → Your username → "Security credentials"
   - Click "Create access key" → "Command Line Interface (CLI)"
   - Copy Access Key ID and Secret Access Key

2. **Configure:**
   ```powershell
   aws configure
   ```
   - AWS Access Key ID: [Paste your key]
   - AWS Secret Access Key: [Paste your secret]
   - Default region: `us-east-1`
   - Default output format: `json`

3. **Verify:**
   ```powershell
   aws sts get-caller-identity
   ```
   Should show: `"Account": "577004485374"`

### Step 3: Deploy! (1.5-2 hours)

```powershell
cd infrastructure/aws/scripts
.\quick-deploy.ps1 -Environment development
```

The script will:
1. ✅ Check prerequisites
2. ✅ Verify AWS configuration
3. ✅ Deploy infrastructure (15-20 min)
4. ✅ Setup database (5 min)
5. ✅ Build and push images (30-45 min)
6. ✅ Deploy services (10-15 min)
7. ✅ Deploy frontend (10-15 min)

## 📋 What Gets Deployed

### Infrastructure
- **VPC**: Network with public/private subnets
- **RDS PostgreSQL**: Database (db.t3.micro, 20GB)
- **ElastiCache Redis**: Cache (cache.t3.micro)
- **ECS Cluster**: Container orchestration
- **Application Load Balancer**: HTTP/HTTPS routing
- **ECR Repositories**: 12 repositories for services
- **Security Groups**: Network security
- **IAM Roles**: Service permissions
- **Secrets Manager**: Secure credential storage

### Services (12 microservices)
- auth-service (8081)
- user-service (8082)
- voucher-service (8083)
- order-service (8084)
- wallet-service (8086)
- redemption-service (8087)
- merchant-service (8088)
- admin-portal-backend (8089)
- notification-service (8091)
- payout-service (8092)
- analytics-service (8093)
- mock-payment-service (8095)

### Frontend (3 applications)
- Admin Portal (Angular) → S3
- Consumer App (Flutter) → S3
- Merchant App (Flutter) → S3

## 💰 Cost Breakdown

| Service | Monthly Cost |
|---------|-------------|
| RDS PostgreSQL (db.t3.micro) | $15-20 |
| ElastiCache Redis (cache.t3.micro) | $12-15 |
| ECS Fargate (12 services × 1 task) | $30-60 |
| Application Load Balancer | $20 |
| NAT Gateway (single) | $32 |
| S3 + Data Transfer | $10-20 |
| **Total** | **~$50-100/month** |

## ✅ After Deployment

### Get Your URLs

```powershell
# Get ALB URL (API Gateway)
terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name

# Frontend URLs (S3 website endpoints)
# Admin Portal: http://kado24-admin-portal.s3-website-us-east-1.amazonaws.com
# Consumer App: http://kado24-consumer-app.s3-website-us-east-1.amazonaws.com
# Merchant App: http://kado24-merchant-app.s3-website-us-east-1.amazonaws.com
```

### Test Your Deployment

```powershell
# Test health endpoint
$url = terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
Invoke-WebRequest -Uri "http://$url/actuator/health"

# Check service status
aws ecs list-services --cluster kado24-cluster

# View logs
aws logs tail /ecs/kado24-auth-service --follow
```

## 🔧 Management Commands

### Stop Services (Save Costs)
```powershell
cd infrastructure/aws/scripts
.\stop-dev-services.sh
```

### Start Services
```powershell
.\start-dev-services.sh
```

### Update Single Service
```powershell
# After making code changes
cd backend/services/auth-service
mvn clean package -DskipTests
docker build -t kado24/auth-service:latest .
# Push to ECR and update service
```

### View Costs
```powershell
aws ce get-cost-and-usage \
  --time-period Start=$(Get-Date -Format "yyyy-MM-01"),End=$(Get-Date -Format "yyyy-MM-dd") \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## 📚 Documentation

- **Install Tools**: [infrastructure/aws/INSTALL-TOOLS.md](infrastructure/aws/INSTALL-TOOLS.md)
- **Deployment Checklist**: [infrastructure/aws/DEPLOYMENT-CHECKLIST.md](infrastructure/aws/DEPLOYMENT-CHECKLIST.md)
- **Full Guide**: [infrastructure/aws/DEPLOYMENT-GUIDE.md](infrastructure/aws/DEPLOYMENT-GUIDE.md)
- **Cost Optimization**: [infrastructure/aws/COST-OPTIMIZATION.md](infrastructure/aws/COST-OPTIMIZATION.md)

## 🆘 Troubleshooting

### Tools Not Found After Installation
- **Restart PowerShell** (required!)
- Check PATH: `$env:Path`
- Reinstall if needed

### AWS Configuration Issues
- Verify credentials in AWS Console
- Check IAM permissions
- Ensure account ID: 577004485374

### Deployment Fails
- Check CloudWatch logs
- Verify security groups
- Check IAM roles
- Review Terraform outputs

## 🎯 Success Criteria

After deployment, you should have:

✅ All 12 services running on ECS  
✅ Database initialized with all schemas  
✅ Frontend apps accessible via S3  
✅ ALB routing traffic to services  
✅ Health checks passing  
✅ Logs visible in CloudWatch  

## 🚀 Ready to Start?

1. **Install AWS CLI and Terraform** (see Step 1 above)
2. **Configure AWS** (see Step 2 above)
3. **Run deployment** (see Step 3 above)

**Estimated Total Time: ~2 hours**

---

**Your AWS Account: 577004485374** ✅  
**Configuration: Ready** ✅  
**Scripts: Ready** ✅  

**Just install the tools and deploy!** 🚀

