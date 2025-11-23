# Cost-Optimized VPC for Development
# Uses single NAT gateway or no NAT gateway to reduce costs

# Option 1: Single NAT Gateway (recommended for dev)
# This reduces NAT gateway costs from ~$32/month to ~$32/month total (instead of $64/month for 2)

# Option 2: No NAT Gateway (if services don't need internet access)
# This saves ~$32/month but services won't be able to pull images from ECR
# You'll need to use public subnets for ECS or configure VPC endpoints

# For development, we'll use a single NAT gateway
resource "aws_eip" "nat_single" {
  count  = var.environment == "development" ? 1 : 0
  domain = "vpc"
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat-eip-single"
    }
  )
}

resource "aws_nat_gateway" "single" {
  count         = var.environment == "development" ? 1 : 0
  allocation_id = aws_eip.nat_single[0].id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat-single"
    }
  )
  
  depends_on = [aws_internet_gateway.main]
}

# Single route table for private subnets in dev
resource "aws_route_table" "private_single" {
  count  = var.environment == "development" ? 1 : 0
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.single[0].id
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-rt-single"
    }
  )
}

resource "aws_route_table_association" "private_single" {
  count          = var.environment == "development" ? 2 : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_single[0].id
}

