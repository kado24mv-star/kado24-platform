# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-redis-subnet-group"
    }
  )
}

# Security Group for ElastiCache
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-redis-sg"
    }
  )
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.project_name}-redis"
  description               = "Redis cluster for ${var.project_name}"
  
  engine               = "redis"
  engine_version        = "7.0"
  node_type             = var.redis_node_type
  port                  = 6379
  parameter_group_name  = "default.redis7"
  
  num_cache_clusters = var.environment == "production" ? 2 : 1
  
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  automatic_failover_enabled = var.environment == "production"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-redis"
    }
  )
}

# Secrets Manager - Redis Credentials
resource "aws_secretsmanager_secret" "redis" {
  name = "${var.project_name}/redis"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    host     = aws_elasticache_replication_group.redis.configuration_endpoint_address
    port     = 6379
    password = var.redis_password != "" ? var.redis_password : null
  })
}

