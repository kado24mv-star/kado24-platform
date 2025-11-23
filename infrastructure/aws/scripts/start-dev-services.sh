#!/bin/bash

# Script to start all ECS services (development)

set -e

REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME=${ECS_CLUSTER_NAME:-kado24-cluster}
DESIRED_COUNT=${DESIRED_COUNT:-1}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting all ECS services...${NC}"

# Service names
SERVICES=(
  "auth-service"
  "user-service"
  "voucher-service"
  "order-service"
  "wallet-service"
  "redemption-service"
  "merchant-service"
  "admin-portal-backend"
  "notification-service"
  "payout-service"
  "analytics-service"
  "mock-payment-service"
)

for SERVICE_NAME in "${SERVICES[@]}"; do
  SERVICE_FULL_NAME="kado24-${SERVICE_NAME}"
  
  echo "Starting ${SERVICE_FULL_NAME}..."
  aws ecs update-service \
    --cluster ${CLUSTER_NAME} \
    --service ${SERVICE_FULL_NAME} \
    --desired-count ${DESIRED_COUNT} \
    --region ${REGION} > /dev/null 2>&1 || echo "  Service ${SERVICE_FULL_NAME} not found"
done

echo -e "${GREEN}All services started with desired count: ${DESIRED_COUNT}${NC}"

