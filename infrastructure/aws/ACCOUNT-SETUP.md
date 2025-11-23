# AWS Account Setup - Account ID: 577004485374

Your AWS account ID has been configured in the following files:

## Configuration Files

### 1. `config.env`
Contains your AWS account configuration:
```bash
export AWS_ACCOUNT_ID=577004485374
export AWS_REGION=us-east-1
```

**Usage:**
```bash
source infrastructure/aws/config.env
```

### 2. ECS Task Definitions
The `auth-service-task.json` template has been updated with your account ID. When you generate other task definitions, they will use this account ID.

### 3. Scripts
All deployment scripts will automatically use your account ID from `config.env` or auto-detect it.

## Quick Setup

### 1. Source Configuration

```bash
cd infrastructure/aws
source config.env
```

### 2. Verify Account ID

```bash
echo $AWS_ACCOUNT_ID
# Should output: 577004485374
```

### 3. Update Task Definitions (if needed)

```bash
cd scripts
./update-task-definitions.sh
```

This will update all task definitions with your account ID and region.

## GitHub Actions Setup

Add this secret to your GitHub repository:

1. Go to: Repository Settings → Secrets and variables → Actions
2. Add secret: `AWS_ACCOUNT_ID` = `577004485374`

## IAM Role ARNs

When creating IAM roles, use these ARNs:

- **ECS Task Execution Role**: `arn:aws:iam::577004485374:role/kado24-ecs-task-execution-role`
- **ECS Task Role**: `arn:aws:iam::577004485374:role/kado24-ecs-task-role`
- **GitHub Actions Role**: `arn:aws:iam::577004485374:role/github-actions-kado24`

## ECR Repository URLs

Your ECR repositories will be at:
```
577004485374.dkr.ecr.us-east-1.amazonaws.com/kado24/<service-name>
```

Example:
```
577004485374.dkr.ecr.us-east-1.amazonaws.com/kado24/auth-service
```

## Secrets Manager ARNs

Your secrets will be at:
```
arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/<secret-name>
```

Examples:
- Database: `arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/database`
- Redis: `arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/redis`
- JWT: `arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/jwt-secret`

## Verification

Verify your account ID is correct:

```bash
aws sts get-caller-identity --query Account --output text
# Should output: 577004485374
```

## Next Steps

1. ✅ Account ID configured: `577004485374`
2. ⏭️ Configure AWS credentials: `aws configure`
3. ⏭️ Deploy infrastructure: `terraform apply`
4. ⏭️ Add GitHub secret: `AWS_ACCOUNT_ID = 577004485374`

---

**Account ID**: 577004485374  
**Region**: us-east-1 (default, can be changed in config.env)

