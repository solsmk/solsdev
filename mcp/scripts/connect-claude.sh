#!/usr/bin/env bash
# Connect Claude Code to SolsDev MCP Gateway

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔌 Connecting Claude Code to SolsDev MCP Gateway${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if gateway is running
if ! docker ps --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo -e "${YELLOW}⚠️  Gateway is not running${NC}"
    echo -e "${YELLOW}   Run: ./mcp/scripts/start-gateway.sh${NC}"
    exit 1
fi

# Get Claude Code config directory
CLAUDE_CONFIG="${HOME}/.claude"
mkdir -p "$CLAUDE_CONFIG"

# Check if claude.json exists
if [ ! -f "$CLAUDE_CONFIG/claude.json" ]; then
    echo -e "${GREEN}📝 Creating claude.json${NC}"
    cat > "$CLAUDE_CONFIG/claude.json" <<'EOF'
{
  "mcpServers": {
    "solsdev-gateway": {
      "type": "sse",
      "url": "http://localhost:8811/sse"
    }
  }
}
EOF
else
    # Update existing claude.json
    echo -e "${GREEN}📝 Updating existing claude.json${NC}"

    # Backup existing file
    cp "$CLAUDE_CONFIG/claude.json" "$CLAUDE_CONFIG/claude.json.backup"

    # Use jq if available, otherwise manual edit
    if command -v jq >/dev/null 2>&1; then
        jq '.mcpServers["solsdev-gateway"] = {"type": "sse", "url": "http://localhost:8811/sse"}' \
            "$CLAUDE_CONFIG/claude.json" > "$CLAUDE_CONFIG/claude.json.tmp"
        mv "$CLAUDE_CONFIG/claude.json.tmp" "$CLAUDE_CONFIG/claude.json"
    else
        echo -e "${YELLOW}⚠️  jq not found. Please manually add this to $CLAUDE_CONFIG/claude.json:${NC}"
        echo ''
        echo '  "mcpServers": {'
        echo '    "solsdev-gateway": {'
        echo '      "type": "sse",'
        echo '      "url": "http://localhost:8811/sse"'
        echo '    }'
        echo '  }'
        echo ''
    fi
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Claude Code configured!${NC}"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Restart Claude Code if it's running"
echo -e "  2. MCP servers will be available automatically"
echo -e "  3. Use /mcp-status command to check connection"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
