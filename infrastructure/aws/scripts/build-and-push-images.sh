#!/bin/bash

# Script to build and push all Docker images to ECR

set -e

# Load configuration if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.env"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

REGION=${AWS_REGION:-us-east-1}
ACCOUNT_ID=${AWS_ACCOUNT_ID:-577004485374}
ECR_BASE="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Building and pushing Docker images to ECR...${NC}"
echo "Region: ${REGION}"
echo "Account ID: ${ACCOUNT_ID}"
echo "ECR Base: ${ECR_BASE}"

# Login to ECR
echo -e "\n${YELLOW}Logging into ECR...${NC}"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_BASE}

# Services to build
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

# Build shared libraries first
echo -e "\n${YELLOW}Building shared libraries...${NC}"
cd "$(dirname "$0")/../../.."

cd backend/shared/common-lib
mvn clean install -DskipTests
echo -e "${GREEN}✓ common-lib built${NC}"

cd ../security-lib
mvn clean install -DskipTests
echo -e "${GREEN}✓ security-lib built${NC}"

cd ../kafka-lib
mvn clean install -DskipTests
echo -e "${GREEN}✓ kafka-lib built${NC}"

# Build and push each service
for SERVICE in "${SERVICES[@]}"; do
  echo -e "\n${YELLOW}Building ${SERVICE}...${NC}"
  cd "../../services/${SERVICE}"
  
  # Build JAR
  mvn clean package -DskipTests
  
  # Build Docker image
  IMAGE_NAME="kado24/${SERVICE}"
  IMAGE_TAG="${ECR_BASE}/${IMAGE_NAME}"
  
  echo "Building Docker image: ${IMAGE_TAG}"
  docker build -t ${IMAGE_NAME}:latest .
  docker tag ${IMAGE_NAME}:latest ${IMAGE_TAG}:latest
  
  # Push to ECR
  echo "Pushing to ECR..."
  docker push ${IMAGE_TAG}:latest
  
  echo -e "${GREEN}✓ ${SERVICE} built and pushed${NC}"
  
  cd ../../..
done

echo -e "\n${GREEN}All images built and pushed successfully!${NC}"

