#!/bin/bash

# Script to generate ECS task definitions for all services
# This script reads the auth-service template and generates task definitions for all services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_DEF_DIR="$SCRIPT_DIR/../ecs-task-definitions"
TEMPLATE_FILE="$TASK_DEF_DIR/auth-service-task.json"

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

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Generating ECS task definitions...${NC}"

for SERVICE_NAME in "${!SERVICES[@]}"; do
  PORT="${SERVICES[$SERVICE_NAME]}"
  OUTPUT_FILE="$TASK_DEF_DIR/${SERVICE_NAME}-task.json"
  
  echo -e "${GREEN}Generating task definition for $SERVICE_NAME (port $PORT)...${NC}"
  
  # Use jq to modify the template
  jq --arg service "$SERVICE_NAME" \
     --arg port "$PORT" \
     --arg family "kado24-$SERVICE_NAME" \
     --arg image "ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/kado24/$SERVICE_NAME:latest" \
     --arg log_group "/ecs/kado24-$SERVICE_NAME" \
     '.family = $family |
      .containerDefinitions[0].name = $service |
      .containerDefinitions[0].image = $image |
      .containerDefinitions[0].portMappings[0].containerPort = ($port | tonumber) |
      .containerDefinitions[0].environment[1].value = $port |
      .containerDefinitions[0].healthCheck.command[1] = ("curl -f http://localhost:" + $port + "/actuator/health || exit 1") |
      .containerDefinitions[0].logConfiguration.options."awslogs-group" = $log_group' \
     "$TEMPLATE_FILE" > "$OUTPUT_FILE"
  
  echo "  ✓ Created $OUTPUT_FILE"
done

echo -e "${GREEN}All task definitions generated successfully!${NC}"
echo -e "${BLUE}Note: Remember to replace ACCOUNT_ID, REGION, and IAM role ARNs in the generated files.${NC}"

