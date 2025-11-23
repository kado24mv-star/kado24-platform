# Deploy Kado24 Platform to AWS - Quick Guide

## Your AWS Account: 577004485374

## Step-by-Step Deployment

### Step 1: Install Prerequisites

Run the prerequisites check:
```powershell
cd infrastructure/aws/scripts
.\setup-prerequisites.ps1
```

**If tools are missing, install them:**

**Option A: Using Chocolatey (Recommended)**
```powershell
# Install Chocolatey first if needed: https://chocolatey.org/install
choco install awscli terraform docker-desktop maven nodejs -y
```

**Option B: Manual Installation**
- AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi
- Terraform: https://developer.hashicorp.com/terraform/downloads
- Docker: https://www.docker.com/products/docker-desktop/
- Maven: https://maven.apache.org/download.cgi
- Node.js: https://nodejs.org/

See [SETUP-PREREQUISITES.md](./SETUP-PREREQUISITES.md) for detailed instructions.

### Step 2: Configure AWS CLI

```powershell
aws configure
```

You'll need:
- **AWS Access Key ID**: Get from AWS Console → IAM → Users → Your User → Security Credentials
- **AWS Secret Access Key**: Same location
- **Default region**: `us-east-1`
- **Default output format**: `json`

Verify configuration:
```powershell
aws sts get-caller-identity
# Should show Account: 577004485374
```

### Step 3: Run Deployment Script

**For Development (Cost Optimized - ~$50-100/month):**
```powershell
cd infrastructure/aws/scripts
.\deploy-step-by-step.ps1 -Environment development
```

**For Production:**
```powershell
cd infrastructure/aws/scripts
.\deploy-step-by-step.ps1 -Environment production
```

The script will guide you through:
1. ✅ Prerequisites check
2. ✅ AWS configuration verification
3. ✅ Terraform setup
4. ✅ Infrastructure deployment
5. ✅ Database setup
6. ✅ Build and push Docker images
7. ✅ Deploy ECS services
8. ✅ Deploy frontend applications

### Step 4: Manual Deployment (Alternative)

If you prefer manual steps:

#### 3.1 Setup Terraform
```powershell
cd infrastructure/aws/terraform

# For development (cost-optimized)
Copy-Item terraform.tfvars.dev terraform.tfvars

# Edit terraform.tfvars and set:
# - db_password (secure password)
# - jwt_secret (secure secret, minimum 256 bits)

terraform init
terraform plan
terraform apply
```

#### 3.2 Setup Database
```powershell
cd ..\scripts
.\setup-rds.sh
```

#### 3.3 Build and Push Images
```powershell
.\build-and-push-images.sh
```

#### 3.4 Deploy Services
```powershell
.\deploy-services.sh
```

#### 3.5 Deploy Frontend
```powershell
.\deploy-frontend.sh
```

## Quick Commands Reference

### Check Deployment Status
```powershell
# Get ALB URL
terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name

# List ECS services
aws ecs list-services --cluster kado24-cluster

# Check service status
aws ecs describe-services --cluster kado24-cluster --services kado24-auth-service

# View logs
aws logs tail /ecs/kado24-auth-service --follow
```

### Stop Services (Save Costs)
```powershell
cd infrastructure/aws/scripts
.\stop-dev-services.sh
```

### Start Services
```powershell
.\start-dev-services.sh
```

## Troubleshooting

### AWS CLI Not Found
- Restart PowerShell after installation
- Verify: `aws --version`
- Reinstall if needed

### Terraform Not Found
- Restart PowerShell
- Verify: `terraform version`
- Check PATH environment variable

### Docker Not Running
- Start Docker Desktop
- Wait for it to fully start
- Verify: `docker ps`

### Deployment Fails
- Check CloudWatch logs: `aws logs tail /ecs/kado24-auth-service`
- Verify security groups allow traffic
- Check IAM permissions
- Review Terraform outputs: `terraform output`

## Cost Information

### Development Environment
- **Monthly Cost**: ~$50-100
- **Optimizations**: Single NAT gateway, smaller instances, minimal backups

### Production Environment
- **Monthly Cost**: ~$400-800
- **Features**: Multi-AZ, larger instances, full backups

See [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md) for details.

## Next Steps After Deployment

1. **Get ALB URL**:
   ```powershell
   terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
   ```

2. **Test API**:
   ```powershell
   $ALB_URL = terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
   curl http://$ALB_URL/actuator/health
   ```

3. **Access Frontend**:
   - Admin Portal: `http://kado24-admin-portal.s3-website-us-east-1.amazonaws.com`
   - Consumer App: `http://kado24-consumer-app.s3-website-us-east-1.amazonaws.com`
   - Merchant App: `http://kado24-merchant-app.s3-website-us-east-1.amazonaws.com`

4. **Setup CI/CD**:
   - Add GitHub secret: `AWS_ACCOUNT_ID = 577004485374`
   - Push to main branch to trigger deployment

## Support

- **Prerequisites**: [SETUP-PREREQUISITES.md](./SETUP-PREREQUISITES.md)
- **Full Guide**: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- **Cost Optimization**: [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md)
- **Account Setup**: [ACCOUNT-SETUP.md](./ACCOUNT-SETUP.md)

---

**Ready to deploy?** Start with Step 1 above! 🚀

