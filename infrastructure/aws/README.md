# AWS Deployment Guide for Kado24 Platform

## Overview

This directory contains all infrastructure as code and deployment configurations for deploying the Kado24 platform to AWS.

## AWS Account Configuration

**Your AWS Account ID: 577004485374**

This account ID has been pre-configured in:
- `config.env` - Main configuration file
- ECS task definitions
- Deployment scripts

See [ACCOUNT-SETUP.md](./ACCOUNT-SETUP.md) for details.

## Architecture

```
Internet
  ↓
CloudFront (CDN for frontend)
  ↓
Application Load Balancer (ALB)
  ↓
ECS Fargate Services (13 microservices)
  ↓
RDS PostgreSQL (Multi-AZ)
ElastiCache Redis
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** >= 1.0 (for infrastructure)
4. **Docker** installed (for building images)
5. **Domain name** (optional, for production)

## Quick Start

### 1. Setup AWS Credentials

```bash
aws configure
# Or use IAM roles for GitHub Actions
```

### 2. Initialize Terraform

```bash
cd infrastructure/aws/terraform
terraform init
```

### 3. Configure Variables

Edit `terraform/terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "staging"
db_password = "your-secure-password"
jwt_secret = "your-jwt-secret"
```

### 4. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### 5. Setup Database

```bash
cd ../../scripts
./setup-rds.sh
```

### 6. Build and Push Images

```bash
cd infrastructure/aws/scripts
./build-and-push-images.sh
```

### 7. Deploy Services

```bash
./deploy-services.sh
```

## Directory Structure

```
infrastructure/aws/
├── README.md                    # This file
├── terraform/                   # Terraform infrastructure
│   ├── main.tf                 # Main configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf             # Output values
│   ├── vpc.tf                  # VPC configuration
│   ├── rds.tf                  # RDS PostgreSQL
│   ├── ecs.tf                  # ECS cluster and services
│   ├── alb.tf                  # Application Load Balancer
│   ├── ecr.tf                  # ECR repositories
│   └── terraform.tfvars        # Variable values
├── ecs-task-definitions/        # ECS task definitions
│   ├── auth-service-task.json
│   ├── user-service-task.json
│   └── ...
├── scripts/                     # Deployment scripts
│   ├── build-and-push-images.sh
│   ├── deploy-services.sh
│   ├── setup-rds.sh
│   └── update-service.sh
└── cloudformation/              # Alternative CloudFormation templates
    └── infrastructure.yaml
```

## Services

### Backend Services (13 microservices)

1. **auth-service** (Port 8081) - Authentication & Authorization
2. **user-service** (Port 8082) - User Management
3. **voucher-service** (Port 8083) - Voucher Management
4. **order-service** (Port 8084) - Order Processing
5. **wallet-service** (Port 8086) - Wallet Management
6. **redemption-service** (Port 8087) - Redemption Processing
7. **merchant-service** (Port 8088) - Merchant Management
8. **admin-portal-backend** (Port 8089) - Admin Operations
9. **notification-service** (Port 8091) - Notifications
10. **payout-service** (Port 8092) - Payout Processing
11. **analytics-service** (Port 8093) - Analytics
12. **mock-payment-service** (Port 8095) - Payment Processing

### Frontend Applications

1. **Admin Portal** - Angular application
2. **Consumer App** - Flutter web application
3. **Merchant App** - Flutter web application

## Cost Estimation

### Production Environment

| Service | Monthly Cost (USD) |
|---------|-------------------|
| ECS Fargate (13 services) | $200-400 |
| RDS PostgreSQL (db.t3.medium Multi-AZ) | $150-300 |
| ElastiCache Redis (cache.t3.micro) | $15-30 |
| Application Load Balancer | $20 |
| S3 + CloudFront | $10-50 |
| Data Transfer | Variable |
| **Total** | **~$400-800/month** |

### Development Environment (Cost Optimized)

| Service | Monthly Cost (USD) |
|---------|-------------------|
| ECS Fargate (13 services, 1 task each) | $30-60 |
| RDS PostgreSQL (db.t3.micro Single-AZ) | $15-20 |
| ElastiCache Redis (cache.t3.micro) | $12-15 |
| Application Load Balancer | $20 |
| NAT Gateway (single) | $32 |
| S3 + CloudFront | $10-50 |
| Data Transfer | Variable |
| **Total** | **~$50-100/month** |

**Savings: ~75-85% reduction for development!**

See [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md) and [DEV-QUICK-START.md](./DEV-QUICK-START.md) for details.

## Security Best Practices

1. ✅ Use VPC with private subnets for services
2. ✅ Enable encryption at rest and in transit
3. ✅ Use IAM roles for service authentication
4. ✅ Store secrets in AWS Secrets Manager
5. ✅ Enable CloudWatch logging
6. ✅ Use WAF for API protection
7. ✅ Regular security updates
8. ✅ Enable VPC Flow Logs
9. ✅ Use security groups with least privilege

## Monitoring

- **CloudWatch Logs**: All service logs
- **CloudWatch Metrics**: Service metrics
- **X-Ray**: Distributed tracing (optional)
- **ECS Service Health**: Health checks

## CI/CD Integration

GitHub Actions workflows are configured in `.github/workflows/`:

- `ci.yml`: Continuous Integration (build and test)
- `cd-deploy-aws.yml`: Continuous Deployment to AWS

## Troubleshooting

### Service won't start

1. Check CloudWatch logs
2. Verify security groups
3. Check task definition
4. Verify secrets in Secrets Manager

### Database connection issues

1. Verify RDS security group allows ECS
2. Check RDS endpoint
3. Verify credentials in Secrets Manager

### Image pull errors

1. Verify ECR repository exists
2. Check IAM permissions
3. Verify image tags

## Support

For issues or questions, please refer to:
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)

