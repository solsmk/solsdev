#!/usr/bin/env bash
# Start SolsDev MCP Gateway
# Usage: ./start-gateway.sh [profile]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Profile selection
PROFILE="${1:-fullstack}"

echo -e "${BLUE}🚀 Starting SolsDev MCP Gateway${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Load environment variables if .env exists
if [ -f "$PROJECT_ROOT/.env.mcp" ]; then
    echo -e "${GREEN}📋 Loading environment from .env.mcp${NC}"
    set -a
    source "$PROJECT_ROOT/.env.mcp"
    set +a
else
    echo -e "${YELLOW}⚠️  No .env.mcp file found. Using default configuration.${NC}"
    echo -e "${YELLOW}   Create .env.mcp from .env.mcp.example for custom settings.${NC}"
fi

# Set workspace
export MCP_WORKSPACE="${MCP_WORKSPACE:-$PROJECT_ROOT}"

# Check if gateway is already running
if docker ps --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo -e "${YELLOW}⚠️  MCP Gateway is already running${NC}"
    echo -e "${BLUE}   Use './stop-gateway.sh' to stop it first${NC}"
    exit 0
fi

# Start the gateway
echo -e "${GREEN}🔧 Starting MCP Gateway with profile: $PROFILE${NC}"
echo -e "${BLUE}   Workspace: $MCP_WORKSPACE${NC}"
echo -e "${BLUE}   Port: 8811${NC}"

cd "$PROJECT_ROOT"

docker compose -f docker-compose.mcp.yaml up -d

# Wait for gateway to be healthy
echo -e "${YELLOW}⏳ Waiting for gateway to be healthy...${NC}"
for i in {1..30}; do
    if docker ps --filter "name=solsdev-mcp-gateway" --filter "health=healthy" --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
        echo -e "${GREEN}✅ MCP Gateway is healthy and ready!${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Gateway failed to become healthy${NC}"
        echo -e "${YELLOW}   Check logs: docker logs solsdev-mcp-gateway${NC}"
        exit 1
    fi
    sleep 1
done

# Display status
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ MCP Gateway is running!${NC}"
echo -e ""
echo -e "${BLUE}Gateway URL:${NC}     http://localhost:8811"
echo -e "${BLUE}Profile:${NC}         $PROFILE"
echo -e "${BLUE}Workspace:${NC}       $MCP_WORKSPACE"
echo -e ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ./mcp/scripts/status.sh       - Check gateway status"
echo -e "  ./mcp/scripts/list-servers.sh - List available MCP servers"
echo -e "  ./mcp/scripts/logs.sh         - View gateway logs"
echo -e "  ./mcp/scripts/stop-gateway.sh - Stop the gateway"
echo -e ""
echo -e "${BLUE}Connect Claude Code:${NC}"
echo -e "  Run: ./mcp/scripts/connect-claude.sh"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
