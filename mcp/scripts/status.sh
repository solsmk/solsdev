#!/usr/bin/env bash
# Check MCP Gateway status

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 SolsDev MCP Gateway Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo -e "${RED}❌ Gateway container not found${NC}"
    echo -e "${YELLOW}   Run: ./mcp/scripts/start-gateway.sh${NC}"
    exit 1
fi

# Get container status
STATUS=$(docker ps -a --filter "name=solsdev-mcp-gateway" --format '{{.Status}}')
HEALTH=$(docker ps --filter "name=solsdev-mcp-gateway" --format '{{.Status}}' | grep -oP '\(.*?\)' || echo "(unknown)")

if docker ps --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo -e "${GREEN}✅ Status:${NC} Running $HEALTH"

    # Get port mapping
    PORT=$(docker port solsdev-mcp-gateway 8811 2>/dev/null || echo "not exposed")
    echo -e "${BLUE}🌐 Port:${NC}   $PORT"

    # Test endpoint
    if curl -sf http://localhost:8811/health >/dev/null 2>&1; then
        echo -e "${GREEN}💚 Health:${NC} Healthy"
    else
        echo -e "${YELLOW}⚠️  Health:${NC} Unhealthy or not responding"
    fi

    # Get uptime
    CREATED=$(docker ps --filter "name=solsdev-mcp-gateway" --format '{{.RunningFor}}')
    echo -e "${BLUE}⏱️  Uptime:${NC} $CREATED"

else
    echo -e "${RED}❌ Status:${NC} $STATUS"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
