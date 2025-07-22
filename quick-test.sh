#!/bin/bash

# Quick Saleor Services Test
# 快速检查构建后的服务状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick Saleor Services Test${NC}"
echo "================================"
echo ""

# 快速检查关键服务
echo -e "${BLUE}🔍 Quick Health Check:${NC}"

# 检查容器状态
containers_running=$(docker-compose ps --services --filter "status=running" | wc -l)
total_containers=$(docker-compose ps --services | wc -l)

echo -n "📦 Containers: "
if [ "$containers_running" -eq "$total_containers" ]; then
    echo -e "${GREEN}✅ All running ($containers_running/$total_containers)${NC}"
else
    echo -e "${RED}❌ Some stopped ($containers_running/$total_containers)${NC}"
    exit 1
fi

# 检查关键服务
echo -n "🌐 API: "
if curl -s --max-time 5 "http://localhost:8000/graphql/" > /dev/null; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    exit 1
fi

echo -n "🖥️  Dashboard: "
if curl -s --max-time 5 "http://localhost:9001" > /dev/null; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    exit 1
fi

echo -n "🛍️  Storefront: "
if curl -s --max-time 5 "http://localhost:3000" > /dev/null; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 All services are healthy!${NC}"
echo ""
echo -e "${BLUE}Quick Access:${NC}"
echo "• Storefront: http://localhost:3000"
echo "• Dashboard: http://localhost:9001"
echo "• API: http://localhost:8000/graphql/"
echo ""
echo -e "${YELLOW}Admin: admin@example.com / admin123${NC}" 