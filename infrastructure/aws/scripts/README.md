# Deployment Scripts

This directory contains scripts for deploying the Kado24 platform to AWS.

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform infrastructure deployed
3. Docker installed (for building images)
4. Maven installed (for building Java services)
5. Node.js and npm (for building admin portal)
6. Flutter SDK (for building Flutter apps)
7. PostgreSQL client (psql) for database setup

## Scripts

### `build-and-push-images.sh`

Builds all Docker images and pushes them to Amazon ECR.

```bash
./build-and-push-images.sh
```

**Environment Variables:**
- `AWS_REGION` - AWS region (default: us-east-1)
- `AWS_ACCOUNT_ID` - AWS account ID (auto-detected if not set)

### `deploy-services.sh`

Deploys all ECS services to the cluster.

```bash
./deploy-services.sh
```

**Environment Variables:**
- `AWS_REGION` - AWS region (default: us-east-1)
- `ECS_CLUSTER_NAME` - ECS cluster name (default: kado24-cluster)
- `AWS_ACCOUNT_ID` - AWS account ID (auto-detected if not set)

### `setup-rds.sh`

Initializes the RDS PostgreSQL database with all schemas.

```bash
./setup-rds.sh
```

**Environment Variables:**
- `AWS_REGION` - AWS region (default: us-east-1)
- `RDS_ENDPOINT` - RDS endpoint (auto-detected from Secrets Manager if not set)
- `DB_USER` - Database user (default: kado24_user)
- `DB_NAME` - Database name (default: kado24_db)

### `deploy-frontend.sh`

Builds and deploys frontend applications to S3.

```bash
./deploy-frontend.sh
```

**Environment Variables:**
- `AWS_REGION` - AWS region (default: us-east-1)
- `CLOUDFRONT_DIST_ID_ADMIN` - CloudFront distribution ID for admin portal (optional)
- `CLOUDFRONT_DIST_ID_CONSUMER` - CloudFront distribution ID for consumer app (optional)
- `CLOUDFRONT_DIST_ID_MERCHANT` - CloudFront distribution ID for merchant app (optional)

### `generate-task-definitions.sh`

Generates ECS task definitions for all services from the auth-service template.

```bash
./generate-task-definitions.sh
```

**Requirements:**
- `jq` must be installed

## Usage

### Complete Deployment

1. **Deploy Infrastructure** (using Terraform):
   ```bash
   cd ../terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. **Setup Database**:
   ```bash
   ./setup-rds.sh
   ```

3. **Build and Push Images**:
   ```bash
   ./build-and-push-images.sh
   ```

4. **Deploy Services**:
   ```bash
   ./deploy-services.sh
   ```

5. **Deploy Frontend**:
   ```bash
   ./deploy-frontend.sh
   ```

### Updating a Single Service

To update a single service:

```bash
# Build and push the specific service
cd ../../../backend/services/auth-service
mvn clean package -DskipTests
docker build -t kado24/auth-service:latest .
docker tag kado24/auth-service:latest ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/kado24/auth-service:latest
docker push ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/kado24/auth-service:latest

# Force new deployment
aws ecs update-service \
  --cluster kado24-cluster \
  --service kado24-auth-service \
  --force-new-deployment \
  --region us-east-1
```

## Troubleshooting

### Images fail to push

- Verify ECR repositories exist
- Check IAM permissions
- Ensure you're logged into ECR

### Services fail to start

- Check CloudWatch logs
- Verify security groups
- Check task definition
- Verify secrets in Secrets Manager

### Database connection fails

- Verify RDS security group allows ECS
- Check RDS endpoint
- Verify credentials in Secrets Manager

### Frontend build fails

- Ensure all dependencies are installed
- Check Node.js/Flutter versions
- Verify build configuration

## Notes

- All scripts use bash and require `set -e` for error handling
- Scripts output colored messages for better readability
- Make scripts executable: `chmod +x *.sh`
- Scripts assume they're run from the `infrastructure/aws/scripts` directory

