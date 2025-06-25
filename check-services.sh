#!/bin/bash

# Service Health Check Script
echo "🔍 Checking ITDel Chatbot Services..."
echo "========================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
    local url=$1
    local name=$2
    local timeout=5
    
    if curl -s --max-time $timeout "$url" > /dev/null 2>&1; then
        echo -e "✅ ${GREEN}$name${NC} - OK"
        return 0
    else
        echo -e "❌ ${RED}$name${NC} - FAIL"
        return 1
    fi
}

echo ""
echo "🏥 Health Checks:"
check_service "http://localhost:35432" "PostgreSQL (port check)"
check_service "http://localhost:33530" "Milvus"  
check_service "http://localhost:34000/minio/health/live" "MinIO"
check_service "http://localhost:33315/health" "VLLM"
check_service "http://localhost:33325/health" "Infinity Embed"
check_service "http://localhost:35430/health" "API"
check_service "http://localhost:33332" "UI"
check_service "http://localhost:33991" "Attu GUI"

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🌐 Service URLs:"
echo "  Frontend UI: http://localhost:33332"
echo "  Backend API: http://localhost:35430"
echo "  API Docs: http://localhost:35430/docs"
echo "  Milvus Attu: http://localhost:33991"
echo "  MinIO Console: http://localhost:34001"
echo "  VLLM API: http://localhost:33315"
echo "  Infinity API: http://localhost:33325"
