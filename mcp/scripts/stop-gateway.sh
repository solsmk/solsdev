#!/usr/bin/env bash
# Stop SolsDev MCP Gateway

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🛑 Stopping SolsDev MCP Gateway${NC}"

cd "$PROJECT_ROOT"

if ! docker ps --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo -e "${YELLOW}⚠️  Gateway is not running${NC}"
    exit 0
fi

docker compose -f docker-compose.mcp.yaml down

echo -e "${GREEN}✅ MCP Gateway stopped${NC}"
