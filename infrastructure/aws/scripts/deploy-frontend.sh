#!/bin/bash

# Script to build and deploy frontend applications to S3

set -e

REGION=${AWS_REGION:-us-east-1}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../.."

echo -e "${BLUE}Building and deploying frontend applications...${NC}"

# Admin Portal (Angular)
echo -e "\n${YELLOW}Building Admin Portal (Angular)...${NC}"
cd "${PROJECT_ROOT}/frontend/admin-portal"

if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm ci
fi

echo "Building Angular application..."
npm run build -- --configuration production

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Admin Portal built successfully${NC}"
  
  # Deploy to S3
  S3_BUCKET="kado24-admin-portal"
  echo "Deploying to S3: s3://${S3_BUCKET}"
  
  # Check if bucket exists, create if not
  if ! aws s3 ls "s3://${S3_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket..."
    aws s3 mb "s3://${S3_BUCKET}" --region ${REGION}
    
    # Enable static website hosting
    aws s3 website "s3://${S3_BUCKET}" \
      --index-document index.html \
      --error-document index.html
  fi
  
  # Sync files
  aws s3 sync dist/admin-portal "s3://${S3_BUCKET}" --delete --region ${REGION}
  
  echo -e "${GREEN}✓ Admin Portal deployed to S3${NC}"
else
  echo -e "${RED}✗ Admin Portal build failed${NC}"
  exit 1
fi

# Consumer App (Flutter)
echo -e "\n${YELLOW}Building Consumer App (Flutter)...${NC}"
cd "${PROJECT_ROOT}/frontend/consumer-app"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}Error: Flutter is not installed. Please install Flutter.${NC}"
  exit 1
fi

echo "Getting Flutter dependencies..."
flutter pub get

echo "Building Flutter web application..."
flutter build web --release

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Consumer App built successfully${NC}"
  
  # Deploy to S3
  S3_BUCKET="kado24-consumer-app"
  echo "Deploying to S3: s3://${S3_BUCKET}"
  
  # Check if bucket exists, create if not
  if ! aws s3 ls "s3://${S3_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket..."
    aws s3 mb "s3://${S3_BUCKET}" --region ${REGION}
    
    # Enable static website hosting
    aws s3 website "s3://${S3_BUCKET}" \
      --index-document index.html \
      --error-document index.html
  fi
  
  # Sync files
  aws s3 sync build/web "s3://${S3_BUCKET}" --delete --region ${REGION}
  
  echo -e "${GREEN}✓ Consumer App deployed to S3${NC}"
else
  echo -e "${RED}✗ Consumer App build failed${NC}"
  exit 1
fi

# Merchant App (Flutter)
echo -e "\n${YELLOW}Building Merchant App (Flutter)...${NC}"
cd "${PROJECT_ROOT}/frontend/merchant-app"

echo "Getting Flutter dependencies..."
flutter pub get

echo "Building Flutter web application..."
flutter build web --release

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Merchant App built successfully${NC}"
  
  # Deploy to S3
  S3_BUCKET="kado24-merchant-app"
  echo "Deploying to S3: s3://${S3_BUCKET}"
  
  # Check if bucket exists, create if not
  if ! aws s3 ls "s3://${S3_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket..."
    aws s3 mb "s3://${S3_BUCKET}" --region ${REGION}
    
    # Enable static website hosting
    aws s3 website "s3://${S3_BUCKET}" \
      --index-document index.html \
      --error-document index.html
  fi
  
  # Sync files
  aws s3 sync build/web "s3://${S3_BUCKET}" --delete --region ${REGION}
  
  echo -e "${GREEN}✓ Merchant App deployed to S3${NC}"
else
  echo -e "${RED}✗ Merchant App build failed${NC}"
  exit 1
fi

echo -e "\n${GREEN}All frontend applications deployed successfully!${NC}"

# Invalidate CloudFront if distribution IDs are set
if [ -n "$CLOUDFRONT_DIST_ID_ADMIN" ]; then
  echo "Invalidating CloudFront for Admin Portal..."
  aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_DIST_ID_ADMIN} \
    --paths "/*" \
    --region ${REGION} > /dev/null
fi

if [ -n "$CLOUDFRONT_DIST_ID_CONSUMER" ]; then
  echo "Invalidating CloudFront for Consumer App..."
  aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_DIST_ID_CONSUMER} \
    --paths "/*" \
    --region ${REGION} > /dev/null
fi

if [ -n "$CLOUDFRONT_DIST_ID_MERCHANT" ]; then
  echo "Invalidating CloudFront for Merchant App..."
  aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_DIST_ID_MERCHANT} \
    --paths "/*" \
    --region ${REGION} > /dev/null
fi

