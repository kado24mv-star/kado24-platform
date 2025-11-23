# AWS Account Configuration

## Your AWS Account ID: 577004485374

This account ID has been configured in the following locations:

### Configuration File
- `infrastructure/aws/config.env` - Main configuration file

### ECS Task Definitions
- `infrastructure/aws/ecs-task-definitions/auth-service-task.json` - Updated with account ID

### Scripts
All deployment scripts will use this account ID automatically.

## Quick Reference

### ECR Repository URLs
```
577004485374.dkr.ecr.us-east-1.amazonaws.com/kado24/<service-name>
```

### IAM Role ARNs
```
arn:aws:iam::577004485374:role/kado24-ecs-task-execution-role
arn:aws:iam::577004485374:role/kado24-ecs-task-role
```

### Secrets Manager ARNs
```
arn:aws:secretsmanager:us-east-1:577004485374:secret:kado24/<secret-name>
```

## Usage

### Source Configuration
```bash
cd infrastructure/aws
source config.env
```

### Verify
```bash
echo $AWS_ACCOUNT_ID
# Output: 577004485374
```

## GitHub Actions

Add this secret to GitHub:
- **Secret Name**: `AWS_ACCOUNT_ID`
- **Secret Value**: `577004485374`

See [ACCOUNT-SETUP.md](./ACCOUNT-SETUP.md) for complete setup instructions.

