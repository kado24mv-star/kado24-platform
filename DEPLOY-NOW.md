# 🚀 Deploy Now - Quick Guide

## Current Status

✅ **AWS CLI**: Installed  
⏳ **Terraform**: Needs setup  
⏳ **AWS Config**: Needs verification  

## Quick Steps to Deploy

### Step 1: Setup Terraform (if not done)

```powershell
cd infrastructure/aws/scripts
.\setup-terraform.ps1
```

Or manually:
1. Extract Terraform ZIP to `C:\terraform`
2. Add to PATH: `[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")`
3. **Restart PowerShell**

### Step 2: Verify Everything

```powershell
cd infrastructure/aws/scripts
.\check-deployment-ready.ps1
```

This will check:
- ✅ AWS CLI
- ✅ Terraform
- ✅ AWS Configuration
- ✅ Docker, Maven, Node.js

### Step 3: Configure AWS (if needed)

```powershell
aws configure
```

Get credentials from: https://console.aws.amazon.com/iam/

Enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`
- Default output: `json`

### Step 4: Deploy!

**Option 1: Quick Deploy (Recommended)**
```powershell
cd infrastructure/aws/scripts
.\quick-deploy.ps1 -Environment development
```

**Option 2: Step-by-Step (Interactive)**
```powershell
.\deploy-step-by-step.ps1 -Environment development
```

**Option 3: Guided**
```powershell
.\install-and-deploy.ps1
```

## What Happens During Deployment

1. **Infrastructure** (15-20 min)
   - VPC, Subnets, Security Groups
   - RDS PostgreSQL
   - ElastiCache Redis
   - ECS Cluster
   - Application Load Balancer

2. **Database Setup** (5 min)
   - Initialize schemas
   - Create tables
   - Seed data

3. **Build Images** (30-45 min)
   - Build 12 Docker images
   - Push to ECR

4. **Deploy Services** (10-15 min)
   - Deploy to ECS
   - Configure ALB routing

5. **Deploy Frontend** (10-15 min)
   - Build Angular/Flutter apps
   - Deploy to S3

**Total Time: ~1.5-2 hours**

## After Deployment

Get your URLs:
```powershell
cd infrastructure/aws/terraform
terraform output alb_dns_name
```

## Troubleshooting

**Tools not found?**
- Restart PowerShell after installation
- Check PATH: `$env:Path`

**AWS not configured?**
- Run: `aws configure`
- Get credentials from AWS IAM console

**Deployment fails?**
- Check CloudWatch logs
- Verify security groups
- Check IAM permissions

## Need Help?

- **Full Guide**: [START-DEPLOYMENT.md](START-DEPLOYMENT.md)
- **Checklist**: [infrastructure/aws/DEPLOYMENT-CHECKLIST.md](infrastructure/aws/DEPLOYMENT-CHECKLIST.md)
- **Cost Info**: [infrastructure/aws/COST-OPTIMIZATION.md](infrastructure/aws/COST-OPTIMIZATION.md)

---

**Ready?** Run `.\check-deployment-ready.ps1` to verify everything! 🚀

