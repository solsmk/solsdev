# Claude Code MCP Integration - Complete Reference

*Research compiled: 2024-12-14*
*Sources: Official Claude Code docs, MCP specification*

## Overview

MCP (Model Context Protocol) is an open standard for AI-tool integrations. Claude Code can connect to MCP servers to access databases, APIs, and external tools.

---

## Configuration Files

| Scope | Location | Shared | Use Case |
|-------|----------|--------|----------|
| **User** | `~/.claude.json` | No | Personal utilities |
| **Project** | `.mcp.json` | Yes (git) | Team tools |
| **Local** | `.claude/settings.local.json` | No | Personal overrides |

---

## .mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http|sse|stdio",
      "url": "https://...",
      "command": "...",
      "args": ["..."],
      "env": {
        "KEY": "${ENVIRONMENT_VAR}",
        "KEY": "${VAR:-default}"
      },
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

**Environment Variable Expansion:**
- `${VAR}` - Expands to env var
- `${VAR:-default}` - With fallback

---

## Transport Types

### HTTP (Recommended)
```bash
claude mcp add --transport http stripe https://mcp.stripe.com

# With auth headers
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### SSE (Deprecated)
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

### Stdio (Local Process)
```bash
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server
```

**Important:** `--` separator is required - everything after goes to the server command.

---

## Managing MCP Servers

```bash
# List configured servers
claude mcp list

# Get server details
claude mcp get github

# Remove server
claude mcp remove github

# Check status within Claude Code
/mcp

# Toggle server
/mcp enable server-name
/mcp disable server-name

# Reset project approvals
claude mcp reset-project-choices

# Import from Claude Desktop
claude mcp add-from-claude-desktop

# Add from JSON
claude mcp add-json weather '{"type":"http","url":"..."}'
```

---

## Using MCP Tools

Tools appear as `mcp__<server>__<tool>`:

```bash
mcp__github__list_prs
mcp__sentry__get_issues
mcp__postgres__query
```

**Resources with @ mentions:**
```
Analyze @github:issue://123
Compare @postgres:schema://users with @docs:file://api/auth
```

---

## Common Server Configurations

### PostgreSQL Database
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@host:5432/db"
      }
    }
  }
}
```

### GitHub Integration
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Stripe API
```json
{
  "mcpServers": {
    "stripe": {
      "command": "npx",
      "args": ["-y", "stripe-mcp@latest"],
      "env": {
        "STRIPE_SECRET_KEY": "${STRIPE_SECRET_KEY}",
        "STRIPE_API_VERSION": "2023-10-16"
      }
    }
  }
}
```

### Sentry Monitoring
```json
{
  "mcpServers": {
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.dev/mcp"
    }
  }
}
```

### Filesystem Access
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "filesystem-mcp@latest"],
      "env": {
        "ALLOWED_PATHS": "/home/user/projects,/tmp",
        "MAX_FILE_SIZE": "10485760",
        "ENABLE_WRITE": "false"
      }
    }
  }
}
```

---

## Settings Integration

In `.claude/settings.json`:
```json
{
  "enabledMcpjsonServers": ["shadcn", "postgres"],
  "enableAllProjectMcpServers": true,
  "permissions": {
    "allow": ["mcp__*"]
  }
}
```

---

## Plugin-Provided MCP Servers

Plugins can bundle MCP servers:

```json
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

---

## Docker MCP Gateway

Docker provides a gateway to 270+ MCP servers (if configured):

```bash
# Search available servers
mcp__MCP_DOCKER__mcp-find "database"

# Add server dynamically
mcp__MCP_DOCKER__mcp-add postgres

# Configure
mcp__MCP_DOCKER__mcp-config-set '{"db_url":"..."}'

# Execute tools
mcp__MCP_DOCKER__mcp-exec '{"tool":"query","args":{...}}'
```

---

## Best Practices

### Security
- Use environment variables for credentials (never commit)
- Review third-party servers before installing
- Project-scoped servers require user approval

### Performance
- Default output limit: 25,000 tokens
- Set `MAX_MCP_OUTPUT_TOKENS=50000` for large datasets
- Set `MCP_TIMEOUT=10000` for startup timeout

### Scope Selection
- **Personal servers** → User scope (`~/.claude.json`)
- **Team tools** → Project scope (`.mcp.json`)
- **Sensitive local config** → Local scope (settings.local.json)

---

## Enterprise Configuration

Administrators can deploy `managed-mcp.json`:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "approved-package"] }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" }
  ]
}
```

---

## Sources

- [MCP Official Documentation](https://code.claude.com/docs/en/mcp)
- [MCP Servers Directory](https://github.com/modelcontextprotocol/servers)
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) - MCP examples
