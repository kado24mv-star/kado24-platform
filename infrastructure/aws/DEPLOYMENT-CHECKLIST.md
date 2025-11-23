# ✅ Deployment Checklist

## Current Status

✅ **Configuration Ready:**
- Terraform variables configured
- Database passwords set
- JWT secret configured
- AWS account ID: 577004485374
- All scripts and documentation ready

❌ **Action Required:**
- [ ] Install AWS CLI
- [ ] Install Terraform
- [ ] Configure AWS credentials
- [ ] Deploy infrastructure
- [ ] Setup database
- [ ] Build and push images
- [ ] Deploy services
- [ ] Deploy frontend

## Step-by-Step Checklist

### Phase 1: Install Tools (10 minutes)

- [ ] **Install AWS CLI**
  - Download: https://awscli.amazonaws.com/AWSCLIV2.msi
  - Install and restart PowerShell
  - Verify: `aws --version`

- [ ] **Install Terraform**
  - Download: https://developer.hashicorp.com/terraform/downloads
  - Extract to `C:\terraform`
  - Add to PATH: `[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "User")`
  - Restart PowerShell
  - Verify: `terraform version`

### Phase 2: Configure AWS (2 minutes)

- [ ] **Get AWS Credentials**
  - Go to: https://console.aws.amazon.com/iam/
  - Users → Your username → Security credentials
  - Create access key → CLI
  - Copy Access Key ID and Secret Access Key

- [ ] **Configure AWS CLI**
  ```powershell
  aws configure
  ```
  - AWS Access Key ID: [Your key]
  - AWS Secret Access Key: [Your secret]
  - Default region: `us-east-1`
  - Default output format: `json`

- [ ] **Verify Configuration**
  ```powershell
  aws sts get-caller-identity
  ```
  - Should show Account: 577004485374

### Phase 3: Deploy Infrastructure (15-20 minutes)

- [ ] **Initialize Terraform**
  ```powershell
  cd infrastructure/aws/terraform
  terraform init
  ```

- [ ] **Review Plan**
  ```powershell
  terraform plan
  ```
  - Review what will be created
  - Check costs and resources

- [ ] **Deploy Infrastructure**
  ```powershell
  terraform apply
  ```
  - Type `yes` when prompted
  - Wait 15-20 minutes for completion

- [ ] **Save Outputs**
  ```powershell
  terraform output -json > outputs.json
  ```

### Phase 4: Setup Database (5 minutes)

- [ ] **Initialize Database**
  ```powershell
  cd ..\scripts
  .\setup-rds.sh
  ```
  - Creates all 12 schemas
  - Creates all tables
  - Inserts seed data

### Phase 5: Build and Push Images (30-45 minutes)

- [ ] **Build and Push**
  ```powershell
  .\build-and-push-images.sh
  ```
  - Builds all 12 microservices
  - Pushes to ECR
  - Takes 30-45 minutes

### Phase 6: Deploy Services (10-15 minutes)

- [ ] **Update Task Definitions**
  ```powershell
  .\update-task-definitions.sh
  ```

- [ ] **Deploy Services**
  ```powershell
  .\deploy-services.sh
  ```
  - Registers task definitions
  - Creates/updates ECS services
  - Starts all services

### Phase 7: Deploy Frontend (10-15 minutes)

- [ ] **Deploy Frontend**
  ```powershell
  .\deploy-frontend.sh
  ```
  - Builds Angular admin portal
  - Builds Flutter consumer app
  - Builds Flutter merchant app
  - Deploys to S3

### Phase 8: Verification (5 minutes)

- [ ] **Get ALB URL**
  ```powershell
  terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
  ```

- [ ] **Test Health Endpoint**
  ```powershell
  $url = terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
  Invoke-WebRequest -Uri "http://$url/actuator/health"
  ```

- [ ] **Check Service Status**
  ```powershell
  aws ecs list-services --cluster kado24-cluster
  ```

- [ ] **View Logs**
  ```powershell
  aws logs tail /ecs/kado24-auth-service --follow
  ```

## Quick Commands

### All-in-One Deployment (After tools installed)
```powershell
cd infrastructure/aws/scripts
.\deploy-step-by-step.ps1 -Environment development
```

### Verify Setup
```powershell
.\verify-setup.ps1
```

### Check Prerequisites
```powershell
.\check-prerequisites.ps1
```

## Estimated Timeline

- **Phase 1**: 10 minutes (install tools)
- **Phase 2**: 2 minutes (configure AWS)
- **Phase 3**: 15-20 minutes (infrastructure)
- **Phase 4**: 5 minutes (database)
- **Phase 5**: 30-45 minutes (build images)
- **Phase 6**: 10-15 minutes (deploy services)
- **Phase 7**: 10-15 minutes (deploy frontend)
- **Phase 8**: 5 minutes (verification)

**Total: ~1.5-2 hours**

## Cost Estimate

**Development Environment: ~$50-100/month**

## Troubleshooting

### Tools Not Found
- Restart PowerShell after installation
- Check PATH environment variable
- Reinstall if needed

### AWS Configuration Issues
- Verify credentials in AWS Console
- Check IAM permissions
- Ensure account ID matches: 577004485374

### Deployment Fails
- Check CloudWatch logs
- Verify security groups
- Check IAM roles and permissions

## Documentation

- **Install Tools**: [INSTALL-TOOLS.md](./INSTALL-TOOLS.md)
- **Next Steps**: [NEXT-STEPS.md](./NEXT-STEPS.md)
- **Full Guide**: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- **Cost Optimization**: [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md)

---

**Ready to start?** Begin with Phase 1! 🚀

