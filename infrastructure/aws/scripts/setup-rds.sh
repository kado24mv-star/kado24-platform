#!/bin/bash

# Script to setup RDS database with schemas

set -e

REGION=${AWS_REGION:-us-east-1}
RDS_ENDPOINT=${RDS_ENDPOINT:-""}
DB_USER=${DB_USER:-"kado24_user"}
DB_NAME=${DB_NAME:-"kado24_db"}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up RDS database...${NC}"

# Get RDS endpoint from Terraform output or Secrets Manager
if [ -z "$RDS_ENDPOINT" ]; then
  echo -e "${YELLOW}Getting RDS endpoint from Secrets Manager...${NC}"
  DB_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "kado24/database" \
    --query "SecretString" \
    --output text \
    --region ${REGION} 2>/dev/null || echo "")
  
  if [ -n "$DB_SECRET" ]; then
    RDS_ENDPOINT=$(echo $DB_SECRET | jq -r '.host')
    DB_USER=$(echo $DB_SECRET | jq -r '.username')
    DB_NAME=$(echo $DB_SECRET | jq -r '.db')
    DB_PASSWORD=$(echo $DB_SECRET | jq -r '.password')
  else
    echo -e "${RED}Error: Could not get RDS endpoint. Please set RDS_ENDPOINT environment variable.${NC}"
    exit 1
  fi
else
  # Get password from Secrets Manager
  echo -e "${YELLOW}Getting database password from Secrets Manager...${NC}"
  DB_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "kado24/database" \
    --query "SecretString" \
    --output text \
    --region ${REGION})
  
  DB_PASSWORD=$(echo $DB_SECRET | jq -r '.password')
fi

if [ -z "$RDS_ENDPOINT" ] || [ "$RDS_ENDPOINT" == "null" ]; then
  echo -e "${RED}Error: RDS endpoint not found. Make sure RDS is deployed and Secrets Manager is configured.${NC}"
  exit 1
fi

echo "RDS Endpoint: ${RDS_ENDPOINT}"
echo "Database: ${DB_NAME}"
echo "User: ${DB_USER}"

# Check if psql is available
if ! command -v psql &> /dev/null; then
  echo -e "${RED}Error: psql is not installed. Please install PostgreSQL client.${NC}"
  exit 1
fi

# Check if initialization script exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="${SCRIPT_DIR}/../../../scripts/init-database-schemas.sql"

if [ ! -f "$INIT_SCRIPT" ]; then
  echo -e "${RED}Error: Database initialization script not found: ${INIT_SCRIPT}${NC}"
  exit 1
fi

echo -e "\n${YELLOW}Running database initialization script...${NC}"
export PGPASSWORD="${DB_PASSWORD}"

# Run initialization script
psql -h ${RDS_ENDPOINT} -U ${DB_USER} -d ${DB_NAME} -f "${INIT_SCRIPT}"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Database initialized successfully!${NC}"
else
  echo -e "${RED}✗ Database initialization failed!${NC}"
  exit 1
fi

unset PGPASSWORD

echo -e "\n${GREEN}Database setup complete!${NC}"

