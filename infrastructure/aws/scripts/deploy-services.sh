#!/bin/bash

# Script to deploy all ECS services

set -e

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.env"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME=${ECS_CLUSTER_NAME:-kado24-cluster}
ACCOUNT_ID=${AWS_ACCOUNT_ID:-577004485374}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_DEF_DIR="$SCRIPT_DIR/../ecs-task-definitions"

echo -e "${BLUE}Deploying ECS services...${NC}"
echo "Region: ${REGION}"
echo "Cluster: ${CLUSTER_NAME}"
echo "Account ID: ${ACCOUNT_ID}"

# Get VPC and subnet information from Terraform outputs
echo -e "\n${YELLOW}Getting infrastructure information...${NC}"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=kado24" --query "Vpcs[0].VpcId" --output text --region ${REGION})
PRIVATE_SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Type,Values=private" --query "Subnets[*].SubnetId" --output text --region ${REGION})
SECURITY_GROUP=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=${VPC_ID}" "Name=group-name,Values=kado24-ecs-sg" --query "SecurityGroups[0].GroupId" --output text --region ${REGION})

if [ -z "$VPC_ID" ] || [ "$VPC_ID" == "None" ]; then
  echo -e "${RED}Error: Could not find VPC. Make sure Terraform infrastructure is deployed.${NC}"
  exit 1
fi

echo "VPC ID: ${VPC_ID}"
echo "Private Subnets: ${PRIVATE_SUBNETS}"
echo "Security Group: ${SECURITY_GROUP}"

# Service configurations: name:port
declare -A SERVICES=(
  ["auth-service"]="8081"
  ["user-service"]="8082"
  ["voucher-service"]="8083"
  ["order-service"]="8084"
  ["wallet-service"]="8086"
  ["redemption-service"]="8087"
  ["merchant-service"]="8088"
  ["admin-portal-backend"]="8089"
  ["notification-service"]="8091"
  ["payout-service"]="8092"
  ["analytics-service"]="8093"
  ["mock-payment-service"]="8095"
)

# Get target group ARNs
echo -e "\n${YELLOW}Getting target group ARNs...${NC}"
declare -A TARGET_GROUPS
for SERVICE_NAME in "${!SERVICES[@]}"; do
  TG_ARN=$(aws elbv2 describe-target-groups --names "kado24-${SERVICE_NAME}-tg" --query "TargetGroups[0].TargetGroupArn" --output text --region ${REGION} 2>/dev/null || echo "")
  if [ -n "$TG_ARN" ] && [ "$TG_ARN" != "None" ]; then
    TARGET_GROUPS["$SERVICE_NAME"]="$TG_ARN"
    echo "  ${SERVICE_NAME}: ${TG_ARN}"
  fi
done

# Get secrets ARNs
echo -e "\n${YELLOW}Getting secrets ARNs...${NC}"
DB_SECRET_ARN=$(aws secretsmanager describe-secret --secret-id "kado24/database" --query "ARN" --output text --region ${REGION} 2>/dev/null || echo "")
REDIS_SECRET_ARN=$(aws secretsmanager describe-secret --secret-id "kado24/redis" --query "ARN" --output text --region ${REGION} 2>/dev/null || echo "")
JWT_SECRET_ARN=$(aws secretsmanager describe-secret --secret-id "kado24/jwt-secret" --query "ARN" --output text --region ${REGION} 2>/dev/null || echo "")

# Get IAM role ARNs
EXECUTION_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/kado24-ecs-task-execution-role"
TASK_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/kado24-ecs-task-role"

# Process each service
for SERVICE_NAME in "${!SERVICES[@]}"; do
  PORT="${SERVICES[$SERVICE_NAME]}"
  SERVICE_FULL_NAME="kado24-${SERVICE_NAME}"
  TASK_DEF_FILE="${TASK_DEF_DIR}/${SERVICE_NAME}-task.json"
  
  echo -e "\n${YELLOW}Processing ${SERVICE_NAME}...${NC}"
  
  # Check if task definition file exists
  if [ ! -f "$TASK_DEF_FILE" ]; then
    echo -e "${RED}  ✗ Task definition file not found: ${TASK_DEF_FILE}${NC}"
    continue
  fi
  
  # Replace placeholders in task definition
  TASK_DEF_TEMP=$(mktemp)
  sed "s/ACCOUNT_ID/${ACCOUNT_ID}/g; s/REGION/${REGION}/g" "$TASK_DEF_FILE" > "$TASK_DEF_TEMP"
  
  # Register task definition
  echo "  Registering task definition..."
  TASK_DEF_ARN=$(aws ecs register-task-definition \
    --cli-input-json file://"$TASK_DEF_TEMP" \
    --query "taskDefinition.taskDefinitionArn" \
    --output text \
    --region ${REGION})
  
  echo "  Task Definition ARN: ${TASK_DEF_ARN}"
  
  # Check if service exists
  SERVICE_EXISTS=$(aws ecs describe-services \
    --cluster ${CLUSTER_NAME} \
    --services ${SERVICE_FULL_NAME} \
    --query "services[0].status" \
    --output text \
    --region ${REGION} 2>/dev/null || echo "MISSING")
  
  if [ "$SERVICE_EXISTS" == "ACTIVE" ]; then
    # Update existing service
    echo "  Updating existing service..."
    aws ecs update-service \
      --cluster ${CLUSTER_NAME} \
      --service ${SERVICE_FULL_NAME} \
      --task-definition ${TASK_DEF_ARN} \
      --force-new-deployment \
      --region ${REGION} > /dev/null
    echo -e "  ${GREEN}✓ Service updated${NC}"
  else
    # Create new service
    echo "  Creating new service..."
    
    # Get target group ARN if available
    TG_ARN="${TARGET_GROUPS[$SERVICE_NAME]}"
    LOAD_BALANCER_CONFIG=""
    if [ -n "$TG_ARN" ] && [ "$TG_ARN" != "None" ]; then
      LOAD_BALANCER_CONFIG="loadBalancers=[{targetGroupArn=${TG_ARN},containerName=${SERVICE_NAME},containerPort=${PORT}}]"
    fi
    
    aws ecs create-service \
      --cluster ${CLUSTER_NAME} \
      --service-name ${SERVICE_FULL_NAME} \
      --task-definition ${TASK_DEF_ARN} \
      --desired-count 2 \
      --launch-type FARGATE \
      --network-configuration "awsvpcConfiguration={subnets=[$(echo $PRIVATE_SUBNETS | tr ' ' ',')],securityGroups=[${SECURITY_GROUP}],assignPublicIp=DISABLED}" \
      ${LOAD_BALANCER_CONFIG:+--load-balancers $LOAD_BALANCER_CONFIG} \
      --region ${REGION} > /dev/null
    
    echo -e "  ${GREEN}✓ Service created${NC}"
  fi
  
  rm "$TASK_DEF_TEMP"
done

echo -e "\n${GREEN}All services deployed successfully!${NC}"
echo -e "${BLUE}Services are starting up. Check ECS console for status.${NC}"

