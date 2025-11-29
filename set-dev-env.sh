#!/bin/bash
# Bash script to set development environment variables for AWS RDS
# Usage: source ./set-dev-env.sh

echo "Setting development environment variables for AWS RDS..."

# AWS RDS PostgreSQL Configuration
export POSTGRES_HOST=kado24-dev-db.cfcki64aaw44.ap-southeast-1.rds.amazonaws.com
export POSTGRES_PORT=5432
export POSTGRES_DB=postgres
export POSTGRES_USER=kado24_dev_user
export POSTGRES_PASSWORD=docTod-dyfvi0-nesbux

# Alternative variable names (for compatibility)
export DB_HOST=${POSTGRES_HOST}
export DB_PORT=${POSTGRES_PORT}
export DB_NAME=${POSTGRES_DB}
export DB_USER=${POSTGRES_USER}
export DB_PASSWORD=${POSTGRES_PASSWORD}

# Redis Configuration (keep local for now)
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=kado24_redis_pass

echo "Environment variables set successfully!"
echo ""
echo "Database Configuration:"
echo "  Host: $POSTGRES_HOST"
echo "  Port: $POSTGRES_PORT"
echo "  Database: $POSTGRES_DB"
echo "  User: $POSTGRES_USER"
echo ""
echo "To verify, run: env | grep -E 'POSTGRES|DB_'"

