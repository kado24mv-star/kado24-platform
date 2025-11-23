# 🚀 Deployment Quick Start

## Current Status: Ready to Deploy

✅ All configuration files are ready  
✅ AWS Account ID configured: **577004485374**  
✅ Development cost-optimized settings configured  
✅ All scripts and documentation created  

## What You Need to Do

### 1. Install Missing Tools (10 minutes)

**AWS CLI:**
- Download: https://awscli.amazonaws.com/AWSCLIV2.msi
- Install and restart PowerShell

**Terraform:**
- Download: https://developer.hashicorp.com/terraform/downloads
- Extract to `C:\terraform`
- Add to PATH: `[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")`
- Restart PowerShell

### 2. Configure AWS (2 minutes)

```powershell
aws configure
```

Get credentials from: https://console.aws.amazon.com/iam/

### 3. Deploy! (1.5-2 hours)

**Option A: Automated (Recommended)**
```powershell
cd infrastructure/aws/scripts
.\quick-deploy.ps1 -Environment development
```

**Option B: Step-by-Step**
```powershell
cd infrastructure/aws/scripts
.\deploy-step-by-step.ps1 -Environment development
```

**Option C: Manual**
```powershell
# 1. Deploy infrastructure
cd infrastructure/aws/terraform
terraform init
terraform apply

# 2. Setup database
cd ..\scripts
.\setup-rds.sh

# 3. Build and push images
.\build-and-push-images.sh

# 4. Deploy services
.\deploy-services.sh

# 5. Deploy frontend
.\deploy-frontend.sh
```

## What Gets Deployed

1. **Infrastructure** (Terraform):
   - VPC with subnets
   - RDS PostgreSQL (db.t3.micro)
   - ElastiCache Redis
   - ECS Cluster
   - Application Load Balancer
   - Security Groups & IAM Roles
   - ECR Repositories

2. **Database**:
   - 12 schemas
   - 30+ tables
   - Seed data

3. **Services**:
   - 12 microservices on ECS
   - Docker images in ECR

4. **Frontend**:
   - Admin Portal (S3)
   - Consumer App (S3)
   - Merchant App (S3)

## Cost

**Development: ~$50-100/month**

## Quick Commands

```powershell
# Check prerequisites
.\check-prerequisites.ps1

# Verify setup
.\verify-setup.ps1

# Get ALB URL (after deployment)
terraform -chdir=..\terraform output -raw alb_dns_name

# Check services
aws ecs list-services --cluster kado24-cluster

# View logs
aws logs tail /ecs/kado24-auth-service --follow
```

## Documentation

- **Checklist**: [DEPLOYMENT-CHECKLIST.md](./DEPLOYMENT-CHECKLIST.md)
- **Install Tools**: [INSTALL-TOOLS.md](./INSTALL-TOOLS.md)
- **Next Steps**: [NEXT-STEPS.md](./NEXT-STEPS.md)
- **Full Guide**: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)

---

**Ready?** Install tools, configure AWS, then run `.\quick-deploy.ps1`! 🚀

