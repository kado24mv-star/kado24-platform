# 🚀 Deploy Now - Simple 3-Step Guide

## Step 1: Install Tools (10 minutes)

### Install AWS CLI
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run installer
3. **Restart PowerShell**

### Install Terraform
1. Download: https://developer.hashicorp.com/terraform/downloads
2. Extract to `C:\terraform`
3. Add to PATH:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")
   ```
4. **Restart PowerShell**

## Step 2: Configure AWS (2 minutes)

1. Get credentials: https://console.aws.amazon.com/iam/
2. Run: `aws configure`
3. Enter your Access Key ID and Secret Access Key

## Step 3: Deploy (1 command)

```powershell
cd infrastructure/aws/scripts
.\install-and-deploy.ps1
```

This script will:
- ✅ Check if tools are installed
- ✅ Check if AWS is configured
- ✅ Guide you through installation if needed
- ✅ Deploy everything automatically

## That's It!

After deployment completes, you'll have:
- ✅ All 12 microservices running
- ✅ Database initialized
- ✅ Frontend apps deployed
- ✅ Platform accessible via ALB

**Total Time: ~2 hours**

---

**Need help?** See [START-DEPLOYMENT.md](../../START-DEPLOYMENT.md) for detailed guide.

