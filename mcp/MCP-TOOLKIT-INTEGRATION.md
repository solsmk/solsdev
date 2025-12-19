# MCP Toolkit Integration

*Using Docker's MCP Toolkit CLI with your SolsDev registry*

---

## Overview

**MCP Toolkit** is Docker's official CLI for managing MCP servers. You can use it alongside (or instead of) our custom scripts to manage the SolsDev MCP Gateway.

---

## Installation

### Install MCP Toolkit

```bash
# Using Docker Desktop extension (recommended)
# Docker Desktop → Extensions → Install "MCP Toolkit"

# Or using Docker CLI
docker mcp version
```

### Verify Installation

```bash
docker mcp --help
```

Output:
```
MCP Toolkit - Model Context Protocol management

Commands:
  docker mcp catalog     Manage MCP server catalogs
  docker mcp server      Manage MCP servers
  docker mcp gateway     Manage MCP gateway
  docker mcp client      Manage MCP clients
```

---

## Using Your SolsDev Registry

### 1. Register Your Catalog

```bash
# Point MCP Toolkit to your catalog
docker mcp catalog add solsdev \
  --file ./mcp/catalogs/solsdev.yaml

# Verify
docker mcp catalog list
```

Output:
```
NAME        PATH                             SERVERS
solsdev     ./mcp/catalogs/solsdev.yaml     15
```

### 2. View Available Servers

```bash
# List all servers in catalog
docker mcp catalog show solsdev
```

Output:
```
SERVER              DESCRIPTION
medusa              Medusa v2 commerce engine
strapi              Strapi 5 headless CMS
shadcn              shadcn/ui component registry
github              GitHub integration
postgres            PostgreSQL database
sequentialthinking  Step-by-step reasoning
... (15 total)
```

### 3. Start Gateway with Profile

```bash
# Start with specific profile
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --config ./mcp/config.yaml \
  --profile fullstack \
  --port 8811 \
  --transport sse

# Or use our script (wrapper around this)
./mcp/scripts/start-gateway.sh fullstack
```

---

## MCP Toolkit Commands

### Catalog Management

```bash
# List catalogs
docker mcp catalog list

# Show catalog details
docker mcp catalog show solsdev

# Validate catalog syntax
docker mcp catalog validate ./mcp/catalogs/solsdev.yaml

# Initialize new catalog
docker mcp catalog init my-catalog.yaml
```

### Server Management

```bash
# List enabled servers
docker mcp server list

# Enable specific server
docker mcp server enable medusa strapi

# Disable server
docker mcp server disable brave-search

# Show server details
docker mcp server inspect medusa

# Test server connection
docker mcp server test medusa
```

### Gateway Operations

```bash
# Start gateway
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --config ./mcp/config.yaml

# Check gateway status
docker mcp gateway status

# View gateway logs
docker mcp gateway logs

# Stop gateway
docker mcp gateway stop
```

### Client Configuration

```bash
# Connect Claude Code
docker mcp client connect claude-code --global

# Connect Cursor
docker mcp client connect cursor --global

# List connected clients
docker mcp client list

# Show client config
docker mcp client show claude-code
```

---

## Profile Management with Toolkit

### Switch Profiles

```bash
# Stop current gateway
docker mcp gateway stop

# Start with different profile
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --config ./mcp/config.yaml \
  --profile backend
```

### List Available Profiles

```bash
# View all profiles in catalog
docker mcp catalog show solsdev --profiles
```

Output:
```
PROFILE      SERVERS
fullstack    11 servers
frontend     7 servers
backend      8 servers
debugging    7 servers
research     4 servers
minimal      3 servers
```

---

## Integration with Your Scripts

### Our Scripts Use MCP Toolkit Under the Hood

Your custom scripts are thin wrappers:

```bash
# ./mcp/scripts/start-gateway.sh
# Internally calls:
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --config ./mcp/config.yaml \
  --profile ${PROFILE}

# With additional:
# - Environment loading from .env.mcp
# - Health check waiting
# - Pretty output formatting
```

### When to Use Which

| Task | Use Script | Use Toolkit |
|------|------------|-------------|
| **Daily use** | `./mcp/scripts/start-gateway.sh` | ✓ Scripts are simpler |
| **Profile switching** | `./mcp/scripts/start-gateway.sh backend` | ✓ Built-in |
| **Debugging** | `./mcp/scripts/logs.sh` | `docker mcp gateway logs` |
| **Server inspection** | - | `docker mcp server inspect` |
| **Catalog validation** | - | `docker mcp catalog validate` |
| **Testing servers** | - | `docker mcp server test` |

**Recommendation:** Use scripts for common tasks, toolkit for advanced operations.

---

## Advanced Toolkit Features

### Server Testing

Test individual server before enabling:

```bash
# Test Medusa server
docker mcp server test medusa

# With custom credentials
docker mcp server test medusa \
  --env MEDUSA_BACKEND_URL=http://localhost:9000 \
  --env MEDUSA_PUBLISHABLE_KEY=pk_...
```

### Catalog Composition

Combine multiple catalogs:

```bash
# Add second catalog (e.g., company-wide servers)
docker mcp catalog add company \
  --file ~/company-mcp-catalog.yaml

# Run gateway with both
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --catalog ~/company-mcp-catalog.yaml
```

### Resource Profiling

```bash
# Show resource usage per server
docker mcp server stats

# Output:
# SERVER     CPU    MEMORY    REQUESTS
# medusa     5%     128MB     45
# strapi     3%     96MB      23
# postgres   2%     64MB      12
```

### Call Tracing

```bash
# Enable detailed call logging
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --trace \
  --trace-output ./mcp-trace.log

# Analyze traces
docker mcp trace analyze ./mcp-trace.log
```

---

## Creating Custom Commands

### Wrapper Script Example

Create `mcp/scripts/toolkit-wrapper.sh`:

```bash
#!/usr/bin/env bash
# Wrapper for MCP Toolkit with SolsDev defaults

CATALOG="./mcp/catalogs/solsdev.yaml"
CONFIG="./mcp/config.yaml"

case "$1" in
  start)
    docker mcp gateway run \
      --catalog "$CATALOG" \
      --config "$CONFIG" \
      --profile "${2:-fullstack}"
    ;;

  stop)
    docker mcp gateway stop
    ;;

  status)
    docker mcp gateway status
    ;;

  servers)
    docker mcp server list
    ;;

  test)
    docker mcp server test "$2"
    ;;

  validate)
    docker mcp catalog validate "$CATALOG"
    ;;

  *)
    echo "Usage: $0 {start|stop|status|servers|test|validate} [args]"
    exit 1
    ;;
esac
```

Make executable:
```bash
chmod +x mcp/scripts/toolkit-wrapper.sh
```

Usage:
```bash
./mcp/scripts/toolkit-wrapper.sh start backend
./mcp/scripts/toolkit-wrapper.sh test medusa
./mcp/scripts/toolkit-wrapper.sh validate
```

---

## Catalog Sync with Docker Hub

### Publish Your Catalog

```bash
# Tag catalog
docker mcp catalog tag solsdev yourname/solsdev-catalog:1.0

# Push to Docker Hub
docker mcp catalog push yourname/solsdev-catalog:1.0
```

### Use Published Catalog

```bash
# Pull catalog
docker mcp catalog pull yourname/solsdev-catalog:1.0

# Use in gateway
docker mcp gateway run \
  --catalog yourname/solsdev-catalog:1.0 \
  --profile fullstack
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test MCP Catalog

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install MCP Toolkit
        run: |
          curl -fsSL https://get.docker.com/mcp | sh

      - name: Validate Catalog
        run: |
          docker mcp catalog validate ./mcp/catalogs/solsdev.yaml

      - name: Test Servers
        run: |
          docker mcp server test filesystem
          docker mcp server test fetch
```

---

## Comparison: Scripts vs Toolkit

### Our Custom Scripts

**Pros:**
- Tailored to SolsDev workflow
- Loads `.env.mcp` automatically
- Pretty output with colors
- Health check waiting
- Profile defaults

**Cons:**
- Limited to predefined operations
- No advanced features

### Docker MCP Toolkit

**Pros:**
- Official Docker tool
- Advanced features (tracing, profiling)
- Server testing
- Catalog validation
- Multi-catalog support

**Cons:**
- More verbose commands
- Requires manual environment setup
- Less user-friendly output

---

## Recommended Workflow

### For Development

```bash
# Morning: Start gateway
./mcp/scripts/start-gateway.sh fullstack

# During day: Use normally in Claude Code

# If issues: Use toolkit for debugging
docker mcp server inspect medusa
docker mcp gateway logs

# Evening: Stop gateway
./mcp/scripts/stop-gateway.sh
```

### For Production

```bash
# Use toolkit for precise control
docker mcp gateway run \
  --catalog ./mcp/catalogs/solsdev.yaml \
  --config ./mcp/config.prod.yaml \
  --profile production \
  --log-level info \
  --metrics-port 9090
```

---

## Troubleshooting

### Toolkit Not Found

```bash
# Verify installation
docker --version
docker mcp version

# If not installed
# Docker Desktop → Extensions → Install MCP Toolkit
```

### Catalog Not Recognized

```bash
# Re-add catalog
docker mcp catalog remove solsdev
docker mcp catalog add solsdev \
  --file ./mcp/catalogs/solsdev.yaml

# Validate syntax
docker mcp catalog validate ./mcp/catalogs/solsdev.yaml
```

### Server Won't Start

```bash
# Test server independently
docker mcp server test server-name

# Check logs
docker mcp gateway logs | grep server-name

# Inspect configuration
docker mcp server inspect server-name
```

---

## Best Practices

### 1. Always Validate Before Deploy

```bash
docker mcp catalog validate ./mcp/catalogs/solsdev.yaml
```

### 2. Test New Servers

```bash
docker mcp server test new-server
```

### 3. Use Profiles Appropriately

Don't enable all servers if you only need a few:

```bash
# Good: Specific profile
docker mcp gateway run --profile backend

# Bad: All servers when you only need one
docker mcp gateway run --profile fullstack
```

### 4. Monitor Resource Usage

```bash
docker mcp server stats
```

### 5. Keep Catalogs in Version Control

```bash
git add mcp/catalogs/solsdev.yaml
git commit -m "feat: add slack MCP server"
```

---

## Reference

### Official Documentation

- [MCP Toolkit Docs](https://docs.docker.com/mcp/toolkit)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)

### SolsDev Documentation

- [README](README.md) - Gateway overview
- [MANAGING-SERVERS](MANAGING-SERVERS.md) - Add/remove servers
- [DOCKER-DESKTOP-INTEGRATION](DOCKER-DESKTOP-INTEGRATION.md) - GUI management

---

**MCP Toolkit + Your Custom Scripts = Powerful and Flexible!** 🛠️
