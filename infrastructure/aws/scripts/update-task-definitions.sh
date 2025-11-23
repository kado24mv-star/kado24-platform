#!/bin/bash

# Script to update all ECS task definitions with actual account ID and region

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_DEF_DIR="$SCRIPT_DIR/../ecs-task-definitions"
CONFIG_FILE="$SCRIPT_DIR/../config.env"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Warning: config.env not found. Using defaults or auto-detection."
  AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
  AWS_REGION=${AWS_REGION:-$(aws configure get region || echo "us-east-1")}
fi

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Updating ECS task definitions with account ID and region...${NC}"
echo "Account ID: ${AWS_ACCOUNT_ID}"
echo "Region: ${AWS_REGION}"

# Update all task definition files
for TASK_DEF_FILE in "$TASK_DEF_DIR"/*-task.json; do
  if [ -f "$TASK_DEF_FILE" ]; then
    SERVICE_NAME=$(basename "$TASK_DEF_FILE" -task.json)
    echo -e "${YELLOW}Updating ${SERVICE_NAME}...${NC}"
    
    # Create backup
    cp "$TASK_DEF_FILE" "${TASK_DEF_FILE}.bak"
    
    # Replace placeholders
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "s/ACCOUNT_ID/${AWS_ACCOUNT_ID}/g" "$TASK_DEF_FILE"
      sed -i '' "s/REGION/${AWS_REGION}/g" "$TASK_DEF_FILE"
    else
      # Linux
      sed -i "s/ACCOUNT_ID/${AWS_ACCOUNT_ID}/g" "$TASK_DEF_FILE"
      sed -i "s/REGION/${AWS_REGION}/g" "$TASK_DEF_FILE"
    fi
    
    echo -e "${GREEN}  ✓ Updated ${SERVICE_NAME}${NC}"
  fi
done

echo -e "\n${GREEN}All task definitions updated successfully!${NC}"
echo -e "${BLUE}Backup files created with .bak extension${NC}"

