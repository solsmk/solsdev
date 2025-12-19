# Managing MCP Servers

*How to add, remove, and customize MCP servers in your SolsDev registry*

---

## Quick Reference

```bash
# View all available servers
cat mcp/catalogs/solsdev.yaml

# Add a new server
nano mcp/catalogs/solsdev.yaml  # Add server definition

# Test specific server
./mcp/scripts/test-server.sh server-name

# Restart gateway to load changes
./mcp/scripts/stop-gateway.sh
./mcp/scripts/start-gateway.sh
```

---

## Adding MCP Servers

### Method 1: From Official MCP Registry

Most MCP servers are available as npm packages:

```yaml
# In mcp/catalogs/solsdev.yaml

servers:
  # Add this server definition
  my-new-server:
    description: "What this server does"
    command: npx
    args:
      - "-y"
      - "@modelcontextprotocol/server-package-name"
    transport: stdio
    capabilities: [tools, resources, prompts]
    documentation: "https://github.com/modelcontextprotocol/servers/tree/main/src/package-name"
    tags: [category, keywords]
```

**Example: Adding Slack MCP Server**

```yaml
servers:
  slack:
    description: "Slack - send messages and manage channels"
    command: npx
    args:
      - "-y"
      - "@modelcontextprotocol/server-slack"
    transport: stdio
    capabilities: [tools]
    env:
      SLACK_BOT_TOKEN: "${SLACK_BOT_TOKEN}"
      SLACK_TEAM_ID: "${SLACK_TEAM_ID}"
    secrets:
      - slack.bot_token
    documentation: "https://github.com/modelcontextprotocol/servers/tree/main/src/slack"
    tags: [communication, slack]
```

Then add to `.env.mcp`:
```bash
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_TEAM_ID=T1234567
```

### Method 2: From Community Packages

```yaml
servers:
  custom-server:
    description: "Community MCP server"
    command: npx
    args:
      - "-y"
      - "community-package-name"
    transport: stdio
    capabilities: [tools]
```

### Method 3: Local Custom Server

```yaml
servers:
  my-local-server:
    description: "My custom MCP server"
    command: node
    args:
      - "${MCP_WORKSPACE}/my-mcp-server/index.js"
    transport: stdio
    capabilities: [tools, resources]
    env:
      CUSTOM_API_KEY: "${CUSTOM_API_KEY}"
```

### Method 4: Docker Container Server

```yaml
servers:
  containerized-server:
    description: "MCP server in Docker container"
    image: "myregistry/my-mcp-server:latest"
    transport: stdio
    capabilities: [tools]
    volumes:
      - "${MCP_WORKSPACE}:/workspace:ro"
```

---

## Removing MCP Servers

### Remove from All Profiles

1. **Delete server definition:**
   ```bash
   # Edit catalog
   nano mcp/catalogs/solsdev.yaml

   # Remove the entire server block
   ```

2. **Remove from profiles:**
   ```yaml
   profiles:
     fullstack:
       servers:
         # Remove server-name from this list
   ```

3. **Restart gateway:**
   ```bash
   ./mcp/scripts/stop-gateway.sh
   ./mcp/scripts/start-gateway.sh
   ```

### Disable Without Removing

Comment out in catalog:

```yaml
# servers:
#   disabled-server:
#     description: "..."
#     # ... rest of config
```

Or remove from all profiles but keep definition.

---

## Server Configuration Options

### Full Server Definition

```yaml
server-name:
  # Basic Info
  description: "Human-readable description"

  # Execution (choose ONE)
  command: npx                    # Command to run
  args: ["-y", "package-name"]   # Command arguments
  # OR
  image: "docker-image:tag"      # Docker image

  # Transport
  transport: stdio                # stdio, http, sse

  # Capabilities
  capabilities: [tools, resources, prompts]

  # Environment Variables
  env:
    VAR_NAME: "${VAR_NAME}"
    STATIC_VAR: "static-value"

  # Secrets (protected from logging)
  secrets:
    - service.secret_key

  # Documentation
  documentation: "https://..."

  # Tags (for organization)
  tags: [category, keywords]

  # Resource Overrides (optional)
  memory: 1Gb
  cpus: 1.5
  timeout: 60s
```

### Environment Variable Patterns

```yaml
# From .env.mcp
env:
  API_KEY: "${API_KEY}"

# Static value
env:
  BASE_URL: "https://api.example.com"

# With default
env:
  TIMEOUT: "${TIMEOUT:-30}"

# Multiple variables
env:
  DB_HOST: "${DB_HOST}"
  DB_PORT: "${DB_PORT:-5432}"
  DB_NAME: "${DB_NAME}"
```

---

## Creating Custom Profiles

### Example: Testing Profile

```yaml
profiles:
  testing:
    description: "For running tests with mocked services"
    servers:
      - filesystem
      - fetch
      - postgres
      - github
```

### Example: Performance Profile

```yaml
profiles:
  performance:
    description: "Lightweight profile for fast startup"
    servers:
      - filesystem
      - fetch
      - sequentialthinking
```

### Example: Production Monitoring

```yaml
profiles:
  monitoring:
    description: "Production issue investigation"
    servers:
      - sentry
      - linear
      - github
      - postgres
      - fetch
      - sequentialthinking
```

---

## Testing New Servers

### Manual Test

```bash
# Start gateway with your profile
./mcp/scripts/start-gateway.sh fullstack

# In Claude Code, test the server
"Use [server-name] to [do something]"
```

### Test Script

Create `mcp/scripts/test-server.sh`:

```bash
#!/usr/bin/env bash
# Test a specific MCP server

SERVER_NAME="${1:-}"

if [ -z "$SERVER_NAME" ]; then
    echo "Usage: ./test-server.sh <server-name>"
    exit 1
fi

echo "Testing MCP server: $SERVER_NAME"

# Check if server is in catalog
if ! grep -q "^  $SERVER_NAME:" mcp/catalogs/solsdev.yaml; then
    echo "Error: Server '$SERVER_NAME' not found in catalog"
    exit 1
fi

# Start gateway if not running
if ! docker ps --format '{{.Names}}' | grep -q "solsdev-mcp-gateway"; then
    echo "Starting gateway..."
    ./mcp/scripts/start-gateway.sh
fi

echo "Server should be available in Claude Code now"
echo "Try: 'List tools from $SERVER_NAME MCP server'"
```

---

## Common MCP Servers to Add

### Communication

```yaml
slack:
  description: "Slack messaging and channels"
  command: npx
  args: ["-y", "@modelcontextprotocol/server-slack"]

discord:
  description: "Discord bot integration"
  command: npx
  args: ["-y", "discord-mcp"]
```

### Databases

```yaml
mysql:
  description: "MySQL database queries"
  command: npx
  args: ["-y", "@modelcontextprotocol/server-mysql"]

mongodb:
  description: "MongoDB document operations"
  command: npx
  args: ["-y", "mongodb-mcp"]

redis:
  description: "Redis caching and pub/sub"
  command: npx
  args: ["-y", "redis-mcp"]
```

### Cloud Services

```yaml
aws:
  description: "AWS services (S3, Lambda, etc)"
  command: npx
  args: ["-y", "aws-mcp"]

vercel:
  description: "Vercel deployments and projects"
  command: npx
  args: ["-y", "vercel-mcp"]

cloudflare:
  description: "Cloudflare DNS and Workers"
  command: npx
  args: ["-y", "cloudflare-mcp"]
```

### Development Tools

```yaml
docker:
  description: "Docker container management"
  command: npx
  args: ["-y", "docker-mcp"]

kubernetes:
  description: "Kubernetes cluster operations"
  command: npx
  args: ["-y", "kubernetes-mcp"]

npm:
  description: "NPM package registry"
  command: npx
  args: ["-y", "@modelcontextprotocol/server-npm"]
```

### AI & Data

```yaml
openai:
  description: "OpenAI API integration"
  command: npx
  args: ["-y", "openai-mcp"]

anthropic:
  description: "Anthropic API integration"
  command: npx
  args: ["-y", "anthropic-mcp"]

huggingface:
  description: "HuggingFace models and datasets"
  command: npx
  args: ["-y", "huggingface-mcp"]
```

---

## Troubleshooting

### Server Not Loading

```bash
# Check server definition syntax
yamllint mcp/catalogs/solsdev.yaml

# Check gateway logs
./mcp/scripts/logs.sh | grep server-name

# Verify environment variables
cat .env.mcp | grep SERVER_VAR
```

### Server Crashes

```bash
# Check specific server logs
docker logs solsdev-mcp-gateway | grep server-name

# Test server standalone
npx -y @modelcontextprotocol/server-package-name
```

### Authentication Errors

```bash
# Verify credentials in .env.mcp
cat .env.mcp

# Check if secrets are being blocked
./mcp/scripts/logs.sh | grep "blocked secret"
```

---

## Best Practices

### Naming Conventions

```yaml
# Use lowercase with hyphens
my-custom-server:

# NOT
MyCustomServer:
my_custom_server:
```

### Documentation

Always include:
- Clear description
- Link to official docs
- Required environment variables
- Example usage

### Resource Limits

Set appropriate limits for resource-heavy servers:

```yaml
heavy-server:
  # ... other config
  memory: 2Gb
  cpus: 2.0
  timeout: 120s
```

### Security

- Never commit `.env.mcp` (already in .gitignore)
- Use `secrets:` field for sensitive data
- Set minimal capabilities (don't add `prompts` if not needed)

---

## Examples

### Complete Example: Adding Notion MCP

1. **Add to catalog:**

```yaml
# mcp/catalogs/solsdev.yaml
servers:
  notion:
    description: "Notion - workspace and database operations"
    command: npx
    args:
      - "-y"
      - "@modelcontextprotocol/server-notion"
    transport: stdio
    capabilities: [tools, resources]
    env:
      NOTION_API_KEY: "${NOTION_API_KEY}"
    secrets:
      - notion.api_key
    documentation: "https://github.com/modelcontextprotocol/servers/tree/main/src/notion"
    tags: [productivity, notion, database]
```

2. **Add to profile:**

```yaml
profiles:
  fullstack:
    servers:
      # ... existing servers
      - notion
```

3. **Configure environment:**

```bash
# .env.mcp
NOTION_API_KEY=secret_your_notion_integration_token
```

4. **Restart gateway:**

```bash
./mcp/scripts/stop-gateway.sh
./mcp/scripts/start-gateway.sh fullstack
```

5. **Test in Claude Code:**

```
"List all pages in my Notion workspace"
```

---

## Reference Links

- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Community MCP Servers](https://mcp.so)
- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)

---

**Need help?** Open an issue at https://github.com/Neno73/solsdev/issues
