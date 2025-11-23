# Development Environment - Quick Start (Cost Optimized)

This guide helps you deploy a cost-optimized development environment (~$50-100/month instead of ~$400-800/month).

## Cost Savings Summary

| Optimization | Savings |
|-------------|---------|
| RDS: db.t3.micro (vs db.t3.medium) | ~$130/month |
| ECS: 1 task per service (vs 2) | ~$100/month |
| ECS: 256 CPU / 512 MB (vs 512/1024) | ~$50/month |
| Single NAT Gateway (vs 2) | ~$32/month |
| Disable Container Insights | ~$10/month |
| Shorter log retention (3 vs 7 days) | ~$5/month |
| Minimal backups (1 vs 7 days) | ~$5/month |
| **Total Savings** | **~$330/month** |

**Development Cost: ~$50-100/month** (vs ~$400-800/month for production)

## Quick Setup

### 1. Use Development Configuration

```bash
cd infrastructure/aws/terraform
cp terraform.tfvars.dev terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
environment = "development"  # Important: set to "development"
project_name = "kado24"

# Cost-optimized values (already set in .dev file)
db_instance_class = "db.t3.micro"
db_allocated_storage = 20
ecs_cpu = 256
ecs_memory = 512
ecs_desired_count = 1
enable_container_insights = false
log_retention_days = 3
backup_retention_days = 1
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan  # Review changes
terraform apply
```

### 3. Setup Database

```bash
cd ../scripts
./setup-rds.sh
```

### 4. Build and Deploy

```bash
./build-and-push-images.sh
./deploy-services.sh
./deploy-frontend.sh
```

## Key Differences from Production

| Feature | Development | Production |
|---------|------------|------------|
| RDS Instance | db.t3.micro (1 vCPU, 1GB) | db.t3.medium+ (2+ vCPU, 4GB+) |
| RDS Multi-AZ | ❌ No | ✅ Yes |
| RDS Storage | 20 GB | 100+ GB |
| ECS Tasks/Service | 1 | 2+ |
| ECS CPU | 256 (0.25 vCPU) | 512+ (0.5+ vCPU) |
| ECS Memory | 512 MB | 1024+ MB |
| NAT Gateways | 1 | 2 |
| Container Insights | ❌ Disabled | ✅ Enabled |
| Log Retention | 3 days | 7-30 days |
| Backup Retention | 1 day | 7 days |
| Monthly Cost | ~$50-100 | ~$400-800 |

## Cost Management

### Stop Services When Not in Use

```bash
# Stop all services (saves ~$30-60/month)
cd infrastructure/aws/scripts
./stop-dev-services.sh

# Start services when needed
./start-dev-services.sh
```

### Monitor Costs

```bash
# Check current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query "ResultsByTime[0].Total.BlendedCost.Amount"
```

### Set Up Billing Alerts

1. Go to AWS Billing Console
2. Create budget: $100/month
3. Set alert at 80% ($80)
4. Configure email notifications

## Development Workflow

### Daily Development

1. **Start services** (if stopped):
   ```bash
   ./start-dev-services.sh
   ```

2. **Make changes** and test locally

3. **Deploy updates**:
   ```bash
   # Update single service
   cd backend/services/auth-service
   mvn clean package -DskipTests
   docker build -t kado24/auth-service:latest .
   # Push and deploy...
   ```

4. **Stop services** at end of day (optional):
   ```bash
   ./stop-dev-services.sh
   ```

### Automated Scheduling (Optional)

Use AWS EventBridge to automatically stop/start services:

```bash
# Stop at 10 PM daily
aws events put-rule \
  --name stop-dev-services \
  --schedule-expression "cron(0 22 * * ? *)"

# Start at 8 AM daily
aws events put-rule \
  --name start-dev-services \
  --schedule-expression "cron(0 8 * * ? *)"
```

## Troubleshooting

### Services Running Slow

Development uses minimal resources. If services are slow:

1. **Increase ECS resources** (temporarily):
   ```bash
   # Update task definition with more CPU/memory
   # Or increase desired_count to 2
   ```

2. **Upgrade RDS** (temporarily):
   ```bash
   # Change db.t3.micro to db.t3.small
   terraform apply -var="db_instance_class=db.t3.small"
   ```

### Out of Memory Errors

Increase ECS memory:
```bash
terraform apply -var="ecs_memory=1024"
```

### Database Connection Issues

Check RDS instance status:
```bash
aws rds describe-db-instances \
  --db-instance-identifier kado24-postgres \
  --query "DBInstances[0].DBInstanceStatus"
```

## Cost Optimization Checklist

- [x] Use `terraform.tfvars.dev` configuration
- [x] Set `environment = "development"`
- [x] Use `db.t3.micro` for RDS
- [x] Set `ecs_desired_count = 1`
- [x] Use `ecs_cpu = 256` and `ecs_memory = 512`
- [x] Disable Container Insights
- [x] Use single NAT gateway
- [x] Set log retention to 3 days
- [x] Set backup retention to 1 day
- [ ] Set up billing alerts
- [ ] Schedule services to stop at night (optional)

## Estimated Monthly Costs

### With Services Running 24/7
- **Minimum**: ~$50/month
- **Average**: ~$75/month
- **Maximum**: ~$100/month

### With Services Running 8 hours/day
- **Minimum**: ~$20/month
- **Average**: ~$30/month
- **Maximum**: ~$40/month

### With Services Stopped (Only RDS/Redis/ALB)
- **Minimum**: ~$15/month
- **Average**: ~$20/month
- **Maximum**: ~$25/month

## Next Steps

1. ✅ Deploy with development configuration
2. ✅ Monitor costs for first week
3. ✅ Adjust resources if needed
4. ✅ Set up billing alerts
5. ✅ Consider scheduling services to stop at night

## Resources

- [Complete Cost Optimization Guide](./COST-OPTIMIZATION.md)
- [Deployment Guide](./DEPLOYMENT-GUIDE.md)
- [Quick Start](./QUICK-START.md)

---

**Remember**: Development environments should be cost-effective. Optimize for cost while maintaining functionality for testing and development.

