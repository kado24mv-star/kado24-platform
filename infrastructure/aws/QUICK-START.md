# Quick Start - AWS Deployment

This is a condensed guide for experienced users. For detailed instructions, see [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md).

## Prerequisites

- AWS CLI configured
- Terraform installed
- Docker, Maven, Node.js, Flutter installed

## 5-Minute Deployment

```bash
# 1. Configure variables
cd infrastructure/aws/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Deploy infrastructure
terraform init
terraform apply

# 3. Setup database
cd ../scripts
chmod +x *.sh
./setup-rds.sh

# 4. Build and push images
./build-and-push-images.sh

# 5. Deploy services
./deploy-services.sh

# 6. Deploy frontend
./deploy-frontend.sh
```

## Environment Variables

Set these before running scripts:

```bash
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECS_CLUSTER_NAME=kado24-cluster
```

## Quick Commands

```bash
# Check service status
aws ecs describe-services --cluster kado24-cluster --services kado24-auth-service

# View logs
aws logs tail /ecs/kado24-auth-service --follow

# Update single service
aws ecs update-service --cluster kado24-cluster --service kado24-auth-service --force-new-deployment

# Get ALB URL
terraform -chdir=infrastructure/aws/terraform output -raw alb_dns_name
```

## Troubleshooting

```bash
# Check what's wrong
aws ecs describe-services --cluster kado24-cluster --services kado24-auth-service --query "services[0].events[0:5]"

# Check logs
aws logs tail /ecs/kado24-auth-service --since 1h

# Restart service
aws ecs update-service --cluster kado24-cluster --service kado24-auth-service --force-new-deployment
```

That's it! 🚀

