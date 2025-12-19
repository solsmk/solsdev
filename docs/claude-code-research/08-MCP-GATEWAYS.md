# MCP Gateways: Docker vs MetaMCP

*Research compiled: 2024-12-14*
*Purpose: Compare options for MCP server management*

---

## Overview

Both solutions aggregate multiple MCP servers into a unified endpoint. Choose based on your infrastructure needs.

---

## Docker MCP Gateway

**Repository:** https://github.com/docker/mcp-gateway
**License:** MIT
**Stars:** 1.1k

### What It Is
Docker CLI plugin that manages MCP infrastructure using Docker containers.

### Key Features
- Container-based isolation for each MCP server
- Unified interface across AI clients
- Docker Desktop secrets management
- OAuth flow support
- Dynamic tool discovery
- Server catalog management

### Installation
```bash
git clone https://github.com/docker/mcp-gateway.git
cd mcp-gateway
mkdir -p "$HOME/.docker/cli-plugins/"
make docker-mcp
```

### Claude Code Integration
```bash
# Connect to Claude Code globally
docker mcp client connect claude-code --global
```

### Configuration Files
Located in `~/.docker/mcp/`:
- `docker-mcp.yaml` - Server catalog
- `registry.yaml` - Enabled servers
- `config.yaml` - Per-server settings
- `tools.yaml` - Per-server tool enablement

### Pros
- Official Docker product
- Native container isolation
- Integrated secrets management
- Works with Docker Desktop

### Cons
- Requires Docker Desktop
- More complex setup
- Heavier resource usage

---

## MetaMCP

**Documentation:** https://docs.metamcp.com
**Type:** Self-hostable aggregator

### What It Is
MCP Aggregator/Orchestrator/Middleware/Gateway in one Docker container.

### Key Features
- Single Docker container deployment
- Multi-tenancy with Better Auth
- SSE and Streamable HTTP transports
- OpenAPI endpoints
- OIDC for enterprise SSO
- Pre-allocated idle sessions (reduced cold-start)

### Self-Hosting Requirements
- 2GB-4GB memory minimum
- Docker or similar container runtime
- Works on: DigitalOcean, Coolify, any VPS

### Transport Options
| Transport | Use Case |
|-----------|----------|
| SSE | Traditional MCP compatibility |
| Streamable HTTP | Modern MCP connections |
| OpenAPI | Tools like Open WebUI |
| STDIO | Via proxy for legacy tools |

### Integration Support
- Cursor IDE
- Claude Desktop (via mcp-proxy)
- Open WebUI
- Custom clients

### Pros
- Self-hostable (Coolify compatible!)
- Lighter than Docker MCP Gateway
- Multi-tenant support
- OpenAPI exposure

### Cons
- Less mature than Docker's solution
- Requires self-hosting infrastructure
- No native Claude Code docs (needs mcp-proxy)

---

## Comparison Matrix

| Feature | Docker MCP Gateway | MetaMCP |
|---------|-------------------|---------|
| **Hosting** | Docker Desktop | Self-hosted |
| **Container Isolation** | Per-server | Single container |
| **Memory** | Higher | 2-4GB |
| **Auth** | Docker secrets | Better Auth / OIDC |
| **Claude Code** | Native support | Via proxy |
| **Multi-tenant** | No | Yes |
| **OpenAPI** | No | Yes |
| **Coolify** | Possible | Native |

---

## Recommendation for Your Setup

Since you have **Coolify** infrastructure:

### Option A: MetaMCP on Coolify
```yaml
# docker-compose for Coolify
services:
  metamcp:
    image: metamcp/metamcp:latest
    ports:
      - "3000:3000"
    environment:
      - AUTH_SECRET=your-secret
    volumes:
      - metamcp-data:/data
```

**Pros:** Self-hosted, matches your infra, multi-tenant ready

### Option B: Docker MCP Gateway (Local Dev)
Use Docker MCP Gateway locally, MetaMCP in production/shared environments.

### Option C: Hybrid
- **Local dev:** Direct MCP configs in `.mcp.json`
- **Team/shared:** MetaMCP on Coolify
- **Production:** MetaMCP with OIDC

---

## Integration with thoughtful-dev Plugin

For your plugin, you could:

1. **Document both options** in installation guide
2. **Provide example configs** for each gateway
3. **Default to simple** `.mcp.json` for basic users
4. **Advanced section** for gateway setups

Example in docs:
```markdown
## MCP Configuration

### Simple (Recommended for individuals)
Add to `.mcp.json`:
\`\`\`json
{
  "mcpServers": {
    "postgres": { ... }
  }
}
\`\`\`

### Team/Self-Hosted (MetaMCP)
If you have MetaMCP running:
\`\`\`json
{
  "mcpServers": {
    "metamcp": {
      "type": "http",
      "url": "https://mcp.your-domain.com/sse"
    }
  }
}
\`\`\`
```

---

## Sources

- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)
- [MetaMCP Docs](https://docs.metamcp.com)
- [MCP Specification](https://modelcontextprotocol.io)
