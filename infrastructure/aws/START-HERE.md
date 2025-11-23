# 🚀 Start Here - Deploy Kado24 Platform to AWS

## Current Status

✅ **Installed:**
- Docker
- Maven
- Node.js

❌ **Missing:**
- AWS CLI
- Terraform

## Quick Installation (Missing Tools)

### Option 1: Using Chocolatey (Fastest)

If you have Chocolatey installed:
```powershell
choco install awscli terraform -y
```

If you don't have Chocolatey, install it first:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Then install tools:
```powershell
choco install awscli terraform -y
```

### Option 2: Manual Installation

**AWS CLI:**
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run installer
3. Restart PowerShell

**Terraform:**
1. Download: https://developer.hashicorp.com/terraform/downloads
2. Extract to `C:\terraform`
3. Add to PATH: `$env:Path += ";C:\terraform"`

## Step-by-Step Deployment

### Step 1: Install Missing Tools

Run the installation command above, then verify:
```powershell
cd infrastructure/aws/scripts
.\check-prerequisites.ps1
```

### Step 2: Configure AWS CLI

```powershell
aws configure
```

You'll need:
- **AWS Access Key ID**: Get from AWS Console → IAM → Users → Your User → Security Credentials
- **AWS Secret Access Key**: Same location
- **Default region**: `us-east-1`
- **Default output format**: `json`

Verify:
```powershell
aws sts get-caller-identity
# Should show Account: 577004485374
```

### Step 3: Run Deployment

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

## What the Deployment Does

1. ✅ Checks prerequisites
2. ✅ Verifies AWS configuration
3. ✅ Sets up Terraform
4. ✅ Deploys infrastructure (VPC, RDS, Redis, ECS, ALB)
5. ✅ Initializes database
6. ✅ Builds and pushes Docker images
7. ✅ Deploys ECS services
8. ✅ Deploys frontend applications

**Total Time:** ~1-2 hours (mostly waiting for AWS resources)

## Quick Commands

### Check Prerequisites
```powershell
.\check-prerequisites.ps1
```

### Verify AWS Account
```powershell
aws sts get-caller-identity
```

### Get Deployment Status
```powershell
# After deployment
terraform -chdir=../terraform output
```

## Troubleshooting

### AWS CLI Installation Issues
- Restart PowerShell after installation
- Verify PATH: `$env:Path`
- Reinstall if needed

### Terraform Installation Issues
- Restart PowerShell
- Verify: `terraform version`
- Check PATH environment variable

### AWS Configuration Issues
- Verify credentials in AWS Console
- Check IAM permissions
- Ensure account ID matches: 577004485374

## Cost Information

### Development Environment
- **Monthly**: ~$50-100
- **Features**: Single NAT, smaller instances, minimal backups

### Production Environment
- **Monthly**: ~$400-800
- **Features**: Multi-AZ, larger instances, full backups

## Next Steps After Deployment

1. **Get ALB URL**:
   ```powershell
   terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
   ```

2. **Test API**:
   ```powershell
   $url = terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
   Invoke-WebRequest -Uri "http://$url/actuator/health"
   ```

3. **Access Frontend**:
   - Admin Portal: Check S3 bucket website endpoint
   - Consumer App: Check S3 bucket website endpoint
   - Merchant App: Check S3 bucket website endpoint

## Documentation

- **Prerequisites**: [SETUP-PREREQUISITES.md](./SETUP-PREREQUISITES.md)
- **Full Guide**: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- **Quick Deploy**: [DEPLOY-NOW.md](./DEPLOY-NOW.md)
- **Cost Optimization**: [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md)

---

## Ready to Deploy?

1. Install missing tools (AWS CLI + Terraform)
2. Configure AWS: `aws configure`
3. Run: `.\deploy-step-by-step.ps1 -Environment development`

**Your AWS Account ID: 577004485374** ✅

