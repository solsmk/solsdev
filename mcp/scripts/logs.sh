#!/usr/bin/env bash
# View MCP Gateway logs

set -euo pipefail

FOLLOW="${1:-}"

if [ "$FOLLOW" = "-f" ] || [ "$FOLLOW" = "--follow" ]; then
    docker logs -f solsdev-mcp-gateway
else
    docker logs --tail 100 solsdev-mcp-gateway
fi
