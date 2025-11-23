# Cost Optimization Guide for Development Environment

This guide shows how to minimize AWS costs for development/testing environments.

## Cost Comparison

### Production Configuration
- **Monthly Cost**: ~$400-800
- **RDS**: db.t3.medium Multi-AZ ($150-300/month)
- **ECS**: 2 tasks per service, 512 CPU, 1024 MB ($200-400/month)
- **Redis**: cache.t3.micro ($15-30/month)
- **ALB**: $20/month
- **NAT Gateways**: 2x ($64/month)
- **Backups**: 7 days retention
- **Logs**: 7 days retention

### Development Configuration (Optimized)
- **Monthly Cost**: ~$50-100
- **RDS**: db.t3.micro Single-AZ ($15-20/month)
- **ECS**: 1 task per service, 256 CPU, 512 MB ($30-60/month)
- **Redis**: cache.t3.micro ($12-15/month)
- **ALB**: $20/month
- **NAT Gateway**: 1x ($32/month) or 0x with VPC endpoints
- **Backups**: 1 day retention
- **Logs**: 3 days retention

**Savings: ~75-85% reduction in costs**

## Development Configuration

### 1. Use Development Terraform Variables

```bash
cd infrastructure/aws/terraform
cp terraform.tfvars.dev terraform.tfvars
# Edit with your values
```

Key optimizations in `terraform.tfvars.dev`:
- `db_instance_class = "db.t3.micro"` (smallest instance)
- `db_allocated_storage = 20` (minimum storage)
- `ecs_cpu = 256` (0.25 vCPU per service)
- `ecs_memory = 512` (512 MB per service)
- `ecs_desired_count = 1` (single instance)
- `enable_container_insights = false` (saves ~$10/month)
- `log_retention_days = 3` (shorter retention)
- `backup_retention_days = 1` (minimal backups)

### 2. Additional Cost Optimizations

#### Option A: Use Single NAT Gateway (Recommended)
- Saves ~$32/month vs 2 NAT gateways
- Already configured in `vpc-dev.tf`

#### Option B: Use VPC Endpoints (Advanced)
- Eliminates NAT gateway costs (~$32/month)
- Requires VPC endpoints for ECR, S3, Secrets Manager
- More complex setup but maximum savings

#### Option C: Use RDS Serverless v2 (Future)
- Pay only for what you use
- Auto-scales and auto-pauses
- Good for intermittent development

### 3. Schedule-Based Scaling (Optional)

For development, you can stop services during off-hours:

```bash
# Stop all ECS services at night
aws ecs update-service --cluster kado24-cluster --service kado24-auth-service --desired-count 0

# Start in the morning
aws ecs update-service --cluster kado24-cluster --service kado24-auth-service --desired-count 1
```

Or use AWS EventBridge to automate:

```json
{
  "ScheduleExpression": "cron(0 22 * * ? *)",  // 10 PM daily
  "Target": {
    "Arn": "arn:aws:ecs:region:account:cluster/kado24-cluster",
    "RoleArn": "arn:aws:iam::account:role/EventBridgeRole",
    "EcsParameters": {
      "TaskDefinitionArn": "arn:aws:ecs:region:account:task-definition/kado24-auth-service",
      "LaunchType": "FARGATE",
      "NetworkConfiguration": {
        "awsvpcConfiguration": {
          "Subnets": ["subnet-xxx"],
          "SecurityGroups": ["sg-xxx"],
          "AssignPublicIp": "ENABLED"
        }
      }
    }
  }
}
```

## Cost Breakdown (Development)

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| RDS PostgreSQL | db.t3.micro, 20GB, Single-AZ | $15-20 |
| ElastiCache Redis | cache.t3.micro | $12-15 |
| ECS Fargate | 12 services × 1 task × 0.25 vCPU | $30-60 |
| Application Load Balancer | Standard | $20 |
| NAT Gateway | 1 gateway | $32 |
| Data Transfer | Variable | $5-10 |
| CloudWatch Logs | 3 days retention | $5-10 |
| **Total** | | **~$50-100/month** |

## Additional Savings Tips

### 1. Use Spot Instances (Advanced)
- Can save up to 90% on ECS tasks
- Requires handling interruptions
- Not recommended for critical services

### 2. Use Reserved Capacity
- For predictable workloads
- Save up to 75% on RDS
- Requires 1-3 year commitment

### 3. Right-Size Resources
- Monitor actual usage
- Adjust CPU/memory based on metrics
- Use CloudWatch to identify over-provisioned services

### 4. Clean Up Unused Resources
- Delete old ECR images
- Remove unused snapshots
- Clean up old CloudWatch logs

### 5. Use AWS Free Tier
- New accounts get 12 months free tier
- Includes: 750 hours EC2, 20 GB RDS, etc.
- Can save significant costs initially

## Monitoring Costs

### Set Up Billing Alerts

```bash
# Create SNS topic for billing alerts
aws sns create-topic --name billing-alerts

# Create CloudWatch alarm
aws cloudwatch put-metric-alarm \
  --alarm-name kado24-monthly-billing \
  --alarm-description "Alert when monthly costs exceed $100" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=Currency,Value=USD
```

### Use AWS Cost Explorer

1. Go to AWS Cost Explorer
2. Filter by tags: `Project=kado24`
3. Set up cost reports
4. Review monthly trends

### Tag Resources

All resources are tagged with:
- `Project = kado24`
- `Environment = development`
- `ManagedBy = Terraform`

This allows easy cost tracking and filtering.

## Development vs Production

| Feature | Development | Production |
|---------|------------|------------|
| RDS Instance | db.t3.micro | db.t3.medium+ |
| RDS Multi-AZ | No | Yes |
| ECS Tasks/Service | 1 | 2+ |
| ECS CPU/Memory | 256/512 | 512/1024+ |
| Backup Retention | 1 day | 7 days |
| Log Retention | 3 days | 7-30 days |
| Container Insights | Disabled | Enabled |
| NAT Gateways | 1 | 2 |
| Cost | ~$50-100/month | ~$400-800/month |

## Quick Start - Development Setup

```bash
# 1. Use development configuration
cd infrastructure/aws/terraform
cp terraform.tfvars.dev terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Deploy with optimized settings
terraform init
terraform plan
terraform apply

# 3. Verify costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## Cost Optimization Checklist

- [ ] Use `terraform.tfvars.dev` for development
- [ ] Set `ecs_desired_count = 1` for single instance
- [ ] Use `db.t3.micro` for RDS
- [ ] Disable Container Insights
- [ ] Reduce log retention to 3 days
- [ ] Reduce backup retention to 1 day
- [ ] Use single NAT gateway
- [ ] Set up billing alerts
- [ ] Tag all resources
- [ ] Review costs monthly

## Estimated Monthly Costs

### Development (Optimized)
- **Minimum**: ~$50/month (light usage)
- **Average**: ~$75/month (normal usage)
- **Maximum**: ~$100/month (heavy usage)

### Production
- **Minimum**: ~$400/month
- **Average**: ~$600/month
- **Maximum**: ~$800/month

## Next Steps

1. Deploy with development configuration
2. Monitor costs for first month
3. Adjust resources based on actual usage
4. Set up billing alerts
5. Review and optimize regularly

---

**Remember**: Development environments don't need production-level redundancy and performance. Optimize for cost while maintaining functionality.

