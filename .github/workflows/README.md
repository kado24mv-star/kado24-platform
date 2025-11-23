# GitHub Actions CI/CD Workflows

This directory contains GitHub Actions workflows for continuous integration and deployment.

## Workflows

### `ci.yml` - Continuous Integration

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**
1. **build-backend** - Builds and tests all 12 backend microservices
2. **build-frontend** - Builds all 3 frontend applications
3. **lint-and-validate** - Validates YAML and Dockerfiles

**Duration:** ~15-20 minutes

### `cd-deploy-aws.yml` - Continuous Deployment

**Triggers:**
- Push to `main` branch
- Tags starting with `v*` (e.g., `v1.0.0`)
- Manual workflow dispatch

**Jobs:**
1. **build-and-push-images** - Builds Docker images and pushes to ECR
2. **deploy-to-ecs** - Deploys services to ECS
3. **deploy-frontend** - Builds and deploys frontend to S3

**Duration:** ~30-45 minutes

## Setup

### 1. Configure GitHub Secrets

Go to: Repository Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `AWS_ACCOUNT_ID` | AWS Account ID | `123456789012` |
| `AWS_ROLE_ARN` | IAM Role ARN for OIDC | `arn:aws:iam::123456789012:role/github-actions-kado24` |
| `AWS_ACCESS_KEY_ID` | AWS Access Key (if not using OIDC) | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key (if not using OIDC) | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `CLOUDFRONT_DIST_ID_ADMIN` | CloudFront Distribution ID (optional) | `E1234567890ABC` |
| `CLOUDFRONT_DIST_ID_CONSUMER` | CloudFront Distribution ID (optional) | `E1234567890DEF` |
| `CLOUDFRONT_DIST_ID_MERCHANT` | CloudFront Distribution ID (optional) | `E1234567890GHI` |

### 2. Setup IAM Role for OIDC (Recommended)

Using OIDC is more secure than access keys. Follow these steps:

1. **Create OIDC Provider** (one-time):
   ```bash
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   ```

2. **Create IAM Role**:
   ```bash
   # Create trust policy
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
   ```

3. **Attach Policies**:
   ```bash
   aws iam attach-role-policy \
     --role-name github-actions-kado24 \
     --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
   
   aws iam attach-role-policy \
     --role-name github-actions-kado24 \
     --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
   
   aws iam attach-role-policy \
     --role-name github-actions-kado24 \
     --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
   
   aws iam attach-role-policy \
     --role-name github-actions-kado24 \
     --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite
   ```

4. **Get Role ARN**:
   ```bash
   aws iam get-role --role-name github-actions-kado24 --query Role.Arn --output text
   ```

5. **Add to GitHub Secrets**: Set `AWS_ROLE_ARN` to the role ARN

### 3. Update Workflow Files

Update the workflow files with your account ID:

```bash
# In cd-deploy-aws.yml, update:
env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com
```

## Usage

### Automatic Deployment

1. **Push to main branch** - Automatically triggers deployment
2. **Create a tag** - Deploys when you push a tag like `v1.0.0`

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual Deployment

1. Go to Actions tab
2. Select "CD - Deploy to AWS"
3. Click "Run workflow"
4. Select environment (staging/production)
5. Click "Run workflow"

### View Workflow Runs

- Go to Actions tab
- Click on a workflow run to see details
- Click on a job to see logs

## Workflow Status Badge

Add this to your README.md:

```markdown
![CI](https://github.com/kado24mv-star/kado24-platform/workflows/CI%20-%20Build%20and%20Test/badge.svg)
![CD](https://github.com/kado24mv-star/kado24-platform/workflows/CD%20-%20Deploy%20to%20AWS/badge.svg)
```

## Troubleshooting

### Workflow Fails at ECR Login

- Verify `AWS_ACCOUNT_ID` secret is set correctly
- Check IAM permissions for ECR

### Workflow Fails at ECS Update

- Verify ECS cluster exists
- Check service names match
- Verify IAM role has ECS permissions

### Workflow Fails at S3 Deploy

- Verify S3 buckets exist
- Check IAM permissions for S3
- Verify bucket names in workflow

### Images Not Found

- Ensure images are built and pushed first
- Check ECR repository names
- Verify image tags

## Best Practices

1. **Use Environments**: Configure staging and production environments
2. **Branch Protection**: Protect main branch, require PR reviews
3. **Tag Releases**: Use semantic versioning (v1.0.0)
4. **Monitor Deployments**: Set up notifications for failed deployments
5. **Review Logs**: Check workflow logs regularly
6. **Test First**: Always test in staging before production

## Customization

### Change Deployment Region

Update `AWS_REGION` in workflow files:

```yaml
env:
  AWS_REGION: eu-west-1  # Change this
```

### Add More Services

Add to the services array in `build-and-push-images` job:

```yaml
strategy:
  matrix:
    service:
      - auth-service
      - new-service  # Add here
```

### Custom Build Steps

Add steps before/after build:

```yaml
- name: Custom step
  run: |
    echo "Do something custom"
```

## Security

- ✅ Uses OIDC for authentication (no long-lived credentials)
- ✅ Secrets stored in GitHub Secrets
- ✅ Least privilege IAM policies
- ✅ Encrypted ECR repositories
- ✅ Private subnets for ECS tasks

## Cost

GitHub Actions minutes:
- **CI**: ~15-20 minutes per run
- **CD**: ~30-45 minutes per run
- **Free tier**: 2,000 minutes/month for private repos
- **Paid**: $0.008/minute after free tier

Optimize by:
- Only running CI on PRs
- Using workflow concurrency
- Caching dependencies

