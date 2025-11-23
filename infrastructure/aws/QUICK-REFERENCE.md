# Quick Reference - AWS Account: 577004485374

## Your AWS Account Information

- **Account ID**: 577004485374
- **Default Region**: us-east-1
- **Project Name**: kado24

## Important ARNs and URLs

### ECR Repositories
```
577004485374.dkr.ecr.us-east-1.amazonaws.com/kado24/<service-name>
```

### IAM Roles
```
arn:aws:iam::577004485374:role/kado24-ecs-task-execution-role
arn:aws:iam::577004485374:role/kado24-ecs-task-role
arn:aws:iam::577004485374:role/github-actions-kado24
```

### Secrets Manager
```
arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/database
arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/redis
arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/jwt-secret
```

### ECS Resources
- **Cluster**: kado24-cluster
- **Services**: kado24-<service-name>
- **Task Definitions**: kado24-<service-name>

## Quick Commands

### Source Configuration
```bash
cd infrastructure/aws
source config.env
```

### Verify Account
```bash
aws sts get-caller-identity --query Account --output text
# Should output: 577004485374
```

### Login to ECR
```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  577004485374.dkr.ecr.us-east-1.amazonaws.com
```

### List ECR Repositories
```bash
aws ecr describe-repositories \
  --query "repositories[?contains(repositoryName, 'kado24')].repositoryName" \
  --output table
```

### Check ECS Services
```bash
aws ecs list-services --cluster kado24-cluster
```

### View Service Status
```bash
aws ecs describe-services \
  --cluster kado24-cluster \
  --services kado24-auth-service \
  --query "services[0].[status,runningCount,desiredCount]"
```

## GitHub Actions Secret

Add to GitHub repository secrets:
- **Name**: `AWS_ACCOUNT_ID`
- **Value**: `577004485374`

## Cost Estimation

### Development: ~$50-100/month
### Production: ~$400-800/month

See [COST-OPTIMIZATION.md](./COST-OPTIMIZATION.md) for details.

