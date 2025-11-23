#!/bin/bash

# =============================================
# Kado24 Platform - Development Environment Setup
# =============================================

set -e

USE_DOCKER_POSTGRES=${USE_DOCKER_POSTGRES:-false}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-kado24_db}
POSTGRES_USER=${POSTGRES_USER:-kado24_user}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-kado24_pass}

echo "🚀 Setting up Kado24 Platform Development Environment..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

MISSING_TOOLS=0

check_command "docker" || MISSING_TOOLS=1
check_command "docker-compose" || MISSING_TOOLS=1
check_command "java" || MISSING_TOOLS=1
check_command "mvn" || MISSING_TOOLS=1

if [ $MISSING_TOOLS -eq 1 ]; then
    echo ""
    echo -e "${RED}❌ Missing required tools. Please install them and try again.${NC}"
    echo ""
    echo "Required tools:"
    echo "  - Docker: https://docs.docker.com/get-docker/"
    echo "  - Docker Compose: https://docs.docker.com/compose/install/"
    echo "  - Java 17+: https://adoptium.net/"
    echo "  - Maven: https://maven.apache.org/download.cgi"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ All prerequisites are installed${NC}"
echo ""

# Start infrastructure services
echo "🐳 Starting infrastructure services (Redis, APISIX, etc.)..."
cd infrastructure/docker
docker-compose up -d
if [ "$USE_DOCKER_POSTGRES" = "true" ]; then
    echo "   ➕ Starting dockerized PostgreSQL via profile 'local-db'..."
    docker-compose --profile local-db up -d postgres
else
    echo "   ⚠️  Skipping dockerized PostgreSQL (using native instance)"
fi

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check if PostgreSQL is ready
if [ "$USE_DOCKER_POSTGRES" = "true" ]; then
    echo "🔍 Checking PostgreSQL (docker container)..."
    until docker exec kado24-postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; do
        echo "   Waiting for PostgreSQL..."
        sleep 2
    done
else
    echo "🔍 Checking PostgreSQL (native)..."
    until PGPASSWORD="$POSTGRES_PASSWORD" pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" > /dev/null 2>&1; do
        echo "   Waiting for PostgreSQL..."
        sleep 2
    done
fi
echo -e "${GREEN}✓${NC} PostgreSQL is ready"

# Check if Redis is ready
echo "🔍 Checking Redis..."
until docker exec kado24-redis redis-cli --pass kado24_redis_pass ping > /dev/null 2>&1; do
    echo "   Waiting for Redis..."
    sleep 2
done
echo -e "${GREEN}✓${NC} Redis is ready"

cd ../..

# Initialize database
echo ""
echo "🗄️  Initializing database schema..."
if [ "$USE_DOCKER_POSTGRES" = "true" ]; then
    docker exec -i kado24-postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < scripts/init-database.sql
else
    if command -v psql >/dev/null 2>&1; then
        PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f scripts/init-database.sql
    else
        echo -e "${YELLOW}⚠️  psql not found on PATH. Skipping schema initialization.${NC}"
    fi
fi
echo -e "${GREEN}✓${NC} Database initialized (or already up-to-date)"

# Build shared libraries
echo ""
echo "📚 Building shared libraries..."

cd backend/shared/common-lib
echo "   Building common-lib..."
mvn clean install -DskipTests > /dev/null 2>&1
echo -e "${GREEN}✓${NC} common-lib built successfully"
cd ../../..

# Configure APISIX
echo ""
echo "🌐 Configuring API Gateway..."
cd gateway/apisix
chmod +x setup-routes.sh
./setup-routes.sh
cd ../..

echo ""
echo -e "${GREEN}✅ Development environment setup complete!${NC}"
echo ""
echo "📊 Service URLs:"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   🌐 API Gateway:          http://localhost:9080"
echo "   🔧 APISIX Admin:         http://localhost:9091"
echo "   🗄️  PostgreSQL:           localhost:5432"
echo "   📦 Redis:                localhost:6379"
echo "   🔍 Redis Commander:      http://localhost:8090"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔐 Default Credentials:"
echo "   Database: kado24_user / kado24_pass"
echo "   Redis:    kado24_redis_pass"
echo "   Admin:    admin@kado24.com / Admin@123456"
echo ""
echo "🚀 Next Steps:"
echo "   1. Start microservices:"
echo "      cd backend/services/auth-service && mvn spring-boot:run"
echo ""
echo "   2. View logs:"
echo "      docker-compose -f infrastructure/docker/docker-compose.yml logs -f"
echo ""
echo "   3. Stop services:"
echo "      docker-compose -f infrastructure/docker/docker-compose.yml down"
echo ""
echo "📚 Documentation: ./docs/"
echo ""











