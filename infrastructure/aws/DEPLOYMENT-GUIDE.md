# Complete AWS Deployment Guide

This guide walks you through deploying the Kado24 platform to AWS from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deploy Infrastructure](#deploy-infrastructure)
4. [Setup Database](#setup-database)
5. [Build and Push Images](#build-and-push-images)
6. [Deploy Services](#deploy-services)
7. [Deploy Frontend](#deploy-frontend)
8. [Configure CI/CD](#configure-cicd)
9. [Verification](#verification)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **AWS CLI** (v2.x) - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform** (>= 1.0) - [Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **Docker** - [Install Guide](https://docs.docker.com/get-docker/)
- **Maven** (3.6+) - [Install Guide](https://maven.apache.org/install.html)
- **Node.js** (18+) and npm - [Install Guide](https://nodejs.org/)
- **Flutter SDK** (3.16+) - [Install Guide](https://docs.flutter.dev/get-started/install)
- **PostgreSQL Client** (psql) - [Install Guide](https://www.postgresql.org/download/)

### AWS Account Setup

1. **Create AWS Account** if you don't have one
2. **Configure AWS CLI**:
   ```bash
   aws configure
   # Enter your Access Key ID
   # Enter your Secret Access Key
   # Enter default region (e.g., us-east-1)
   # Enter default output format (json)
   ```

3. **Get Account ID**:
   ```bash
   aws sts get-caller-identity --query Account --output text
   ```

4. **Create IAM User for GitHub Actions** (for CI/CD):
   - Go to IAM Console
   - Create user: `github-actions-kado24`
   - Attach policies: `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess`, `AmazonS3FullAccess`, `SecretsManagerReadWrite`
   - Create access key and save credentials

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/kado24mv-star/kado24-platform.git
cd kado24-platform
```

### 2. Configure Terraform Variables

**For Development (Cost Optimized):**
```bash
cd infrastructure/aws/terraform
cp terraform.tfvars.dev terraform.tfvars  # Use development config
```

**For Production:**
```bash
cd infrastructure/aws/terraform
cp terraform.tfvars.example terraform.tfvars  # Use production config
```

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "staging"
project_name = "kado24"

# Generate secure passwords
db_password = "YOUR_SECURE_DB_PASSWORD_HERE"
jwt_secret = "YOUR_SECURE_JWT_SECRET_HERE_MINIMUM_256_BITS"

# Optional: Configure Terraform backend
# terraform {
#   backend "s3" {
#     bucket = "kado24-terraform-state"
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#   }
# }
```

**Important:** Generate secure passwords:
```bash
# Generate DB password
openssl rand -base64 32

# Generate JWT secret
openssl rand -base64 64
```

### 3. Create S3 Bucket for Terraform State (Optional but Recommended)

```bash
aws s3 mb s3://kado24-terraform-state-$(aws sts get-caller-identity --query Account --output text)
aws s3api put-bucket-versioning \
  --bucket kado24-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --versioning-configuration Status=Enabled
```

## Deploy Infrastructure

### 1. Initialize Terraform

```bash
cd infrastructure/aws/terraform
terraform init
```

### 2. Review Plan

```bash
terraform plan
```

Review the changes that will be created:
- VPC with public and private subnets
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- ECS cluster
- Application Load Balancer
- ECR repositories
- Security groups
- IAM roles
- Secrets Manager secrets

### 3. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This will take approximately 15-20 minutes.

### 4. Save Outputs

After deployment, save the outputs:

```bash
terraform output -json > outputs.json
```

Important outputs:
- `rds_endpoint` - RDS database endpoint
- `redis_endpoint` - Redis endpoint
- `ecs_cluster_name` - ECS cluster name
- `alb_dns_name` - Load balancer URL
- `ecr_repository_urls` - ECR repository URLs

## Setup Database

### 1. Initialize Database

```bash
cd infrastructure/aws/scripts
chmod +x *.sh
./setup-rds.sh
```

This will:
- Connect to RDS
- Run the initialization script
- Create all 12 schemas
- Create all tables
- Insert seed data

### 2. Verify Database

```bash
# Get RDS endpoint from Secrets Manager
RDS_ENDPOINT=$(aws secretsmanager get-secret-value \
  --secret-id kado24/database \
  --query SecretString \
  --output text | jq -r '.host')

# Connect and verify
psql -h $RDS_ENDPOINT -U kado24_user -d kado24_db -c "\dn"
```

You should see all 12 schemas listed.

## Build and Push Images

### 1. Build and Push All Images

```bash
cd infrastructure/aws/scripts
./build-and-push-images.sh
```

This will:
- Build shared libraries
- Build all 12 microservices
- Create Docker images
- Push to ECR

**Note:** This takes approximately 30-45 minutes for all services.

### 2. Verify Images in ECR

```bash
aws ecr describe-repositories --query "repositories[*].repositoryName"
```

## Deploy Services

### 1. Generate Task Definitions

```bash
cd infrastructure/aws/scripts
./generate-task-definitions.sh
```

This generates task definitions for all services from the template.

### 2. Update Task Definitions

Before deploying, update the task definitions with your account ID and region:

```bash
cd ../ecs-task-definitions
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

# Update all task definitions
for file in *-task.json; do
  sed -i.bak "s/ACCOUNT_ID/${ACCOUNT_ID}/g; s/REGION/${REGION}/g" "$file"
  rm "${file}.bak"
done
```

### 3. Deploy Services

```bash
cd ../scripts
./deploy-services.sh
```

This will:
- Register task definitions
- Create or update ECS services
- Attach to load balancer
- Start services

### 4. Monitor Deployment

```bash
# Watch service status
aws ecs describe-services \
  --cluster kado24-cluster \
  --services kado24-auth-service \
  --query "services[0].deployments[*].[status,desiredCount,runningCount]" \
  --output table

# Check service logs
aws logs tail /ecs/kado24-auth-service --follow
```

## Deploy Frontend

### 1. Build and Deploy Frontend Apps

```bash
cd infrastructure/aws/scripts
./deploy-frontend.sh
```

This will:
- Build Angular admin portal
- Build Flutter consumer app
- Build Flutter merchant app
- Deploy to S3
- Invalidate CloudFront (if configured)

### 2. Access Frontend Applications

After deployment, access via S3 website endpoints or CloudFront URLs:

- Admin Portal: `http://kado24-admin-portal.s3-website-REGION.amazonaws.com`
- Consumer App: `http://kado24-consumer-app.s3-website-REGION.amazonaws.com`
- Merchant App: `http://kado24-merchant-app.s3-website-REGION.amazonaws.com`

## Configure CI/CD

### 1. GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

- `AWS_ACCOUNT_ID` - Your AWS account ID
- `AWS_ROLE_ARN` - IAM role ARN for GitHub Actions (if using OIDC)
- `AWS_ACCESS_KEY_ID` - Access key (if not using OIDC)
- `AWS_SECRET_ACCESS_KEY` - Secret key (if not using OIDC)
- `CLOUDFRONT_DIST_ID_ADMIN` - CloudFront distribution ID for admin portal (optional)
- `CLOUDFRONT_DIST_ID_CONSUMER` - CloudFront distribution ID for consumer app (optional)
- `CLOUDFRONT_DIST_ID_MERCHANT` - CloudFront distribution ID for merchant app (optional)

### 2. IAM Role for GitHub Actions (OIDC - Recommended)

```bash
# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role with trust policy
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:kado24mv-star/kado24-platform:*"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
  --role-name github-actions-kado24 \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name github-actions-kado24 \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

aws iam attach-role-policy \
  --role-name github-actions-kado24 \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```

### 3. Test CI/CD

Push to main branch to trigger deployment:

```bash
git add .
git commit -m "Setup CI/CD"
git push origin main
```

Check GitHub Actions tab to see the workflow running.

## Verification

### 1. Check Service Health

```bash
# Get ALB DNS name
ALB_DNS=$(terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name)

# Check health endpoints
curl http://${ALB_DNS}/actuator/health
```

### 2. Test API Endpoints

```bash
# Test auth service
curl -X POST http://${ALB_DNS}/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+85512345678",
    "email": "test@example.com",
    "password": "Test@123456",
    "fullName": "Test User"
  }'
```

### 3. Check Logs

```bash
# View service logs
aws logs tail /ecs/kado24-auth-service --follow

# View all log groups
aws logs describe-log-groups --query "logGroups[*].logGroupName" | grep kado24
```

### 4. Monitor Resources

- **ECS Console**: https://console.aws.amazon.com/ecs/
- **RDS Console**: https://console.aws.amazon.com/rds/
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/
- **ECR Console**: https://console.aws.amazon.com/ecr/

## Troubleshooting

### Services Not Starting

1. **Check CloudWatch Logs**:
   ```bash
   aws logs tail /ecs/kado24-auth-service --follow
   ```

2. **Check Service Events**:
   ```bash
   aws ecs describe-services \
     --cluster kado24-cluster \
     --services kado24-auth-service \
     --query "services[0].events[0:5]"
   ```

3. **Verify Security Groups**: Ensure ECS can reach RDS and Redis

4. **Check Task Definition**: Verify secrets and environment variables

### Database Connection Issues

1. **Verify RDS Security Group**: Should allow traffic from ECS security group
2. **Check RDS Endpoint**: Verify endpoint in Secrets Manager
3. **Test Connection**:
   ```bash
   psql -h <RDS_ENDPOINT> -U kado24_user -d kado24_db
   ```

### Image Pull Errors

1. **Verify ECR Repository Exists**:
   ```bash
   aws ecr describe-repositories
   ```

2. **Check IAM Permissions**: ECS task execution role needs ECR permissions

3. **Verify Image Tags**: Ensure images are tagged correctly

### Frontend Not Loading

1. **Check S3 Bucket Policy**: Should allow public read access
2. **Verify CloudFront**: If using CloudFront, check distribution status
3. **Check CORS**: Verify API endpoints allow requests from frontend domain

## Next Steps

1. **Setup Custom Domain**: Configure Route 53 and ACM certificate
2. **Enable CloudFront**: For better performance and HTTPS
3. **Setup Monitoring**: Configure CloudWatch alarms
4. **Backup Strategy**: Setup automated RDS snapshots
5. **Scaling**: Configure auto-scaling for ECS services
6. **Security**: Review and tighten security groups
7. **Cost Optimization**: Use Reserved Instances for RDS

## Support

For issues or questions:
- Check [AWS Documentation](https://docs.aws.amazon.com/)
- Review [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Check GitHub Issues

## Cost Optimization Tips

1. **Use Spot Instances** for non-critical services
2. **Right-size RDS** instance based on actual usage
3. **Enable RDS Auto Scaling**
4. **Use S3 Intelligent Tiering** for frontend assets
5. **Enable CloudWatch Logs retention** policies
6. **Use Reserved Capacity** for predictable workloads

---

**Deployment Complete!** 🎉

Your Kado24 platform is now running on AWS!

