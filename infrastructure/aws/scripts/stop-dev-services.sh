#!/bin/bash

# Script to stop all ECS services for cost savings (development only)

set -e

REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME=${ECS_CLUSTER_NAME:-kado24-cluster}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping all ECS services to save costs...${NC}"

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
  
  echo "Stopping ${SERVICE_FULL_NAME}..."
  aws ecs update-service \
    --cluster ${CLUSTER_NAME} \
    --service ${SERVICE_FULL_NAME} \
    --desired-count 0 \
    --region ${REGION} > /dev/null 2>&1 || echo "  Service ${SERVICE_FULL_NAME} not found or already stopped"
done

echo -e "${GREEN}All services stopped. Estimated savings: ~$30-60/month${NC}"
echo -e "${BLUE}To start services again, run: ./start-dev-services.sh${NC}"

