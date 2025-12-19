# SolsDev MCP Gateway

**Unified Model Context Protocol server management for Medusa v2 + Strapi 5 + Next.js 15/16 development.**

---

## What This Provides

The SolsDev MCP Gateway gives Claude Code access to:

- **Medusa v2** - Commerce API and documentation
- **Strapi 5** - CMS content management
- **Database Access** - PostgreSQL queries and schema
- **Search** - Meilisearch indexing and search
- **GitHub/GitLab** - Repository management
- **Monitoring** - Sentry error tracking
- **And more...** - 15+ MCP servers ready to use

All through a **single secure gateway** with authentication, rate limiting, and secret protection.

---

## Quick Start

### 1. Start the Gateway

```bash
# From project root
./mcp/scripts/start-gateway.sh

# Or with specific profile
./mcp/scripts/start-gateway.sh backend
```

### 2. Configure Environment

```bash
# Copy example config
cp .env.mcp.example .env.mcp

# Edit with your credentials
nano .env.mcp
```

### 3. Connect Claude Code

```bash
./mcp/scripts/connect-claude.sh
```

### 4. Verify Connection

```bash
# In Claude Code
/mcp-status
```

---

## Available MCP Servers

### Core Stack

| Server | Description | Tools |
|--------|-------------|-------|
| **medusa** | Medusa v2 commerce engine | Product queries, order management, customer data |
| **strapi** | Strapi 5 headless CMS | Content queries, media management, relations |
| **shadcn** | shadcn/ui component registry | Component search, installation |
| **meilisearch** | Search engine | Index management, search queries, faceting |

### Development Tools

| Server | Description | Tools |
|--------|-------------|-------|
| **github** | GitHub integration | Repos, issues, PRs, commits |
| **gitlab** | GitLab integration | Repos, CI/CD, merge requests |
| **filesystem** | Safe file system access | Read/write files in workspace |
| **fetch** | HTTP requests | Fetch external docs and APIs |

### Database & Search

| Server | Description | Tools |
|--------|-------------|-------|
| **postgres** | PostgreSQL database | Query execution, schema inspection |
| **brave-search** | Web search | Documentation research |

### AI & Reasoning

| Server | Description | Tools |
|--------|-------------|-------|
| **sequentialthinking** | Step-by-step reasoning | Complex problem solving |

### Monitoring

| Server | Description | Tools |
|--------|-------------|-------|
| **sentry** | Error tracking | Issue queries, root cause analysis |
| **linear** | Project management | Issue tracking, project queries |

---

## Profiles

Profiles enable/disable specific MCP servers for different workflows:

### Available Profiles

```bash
# Full-stack development (default)
./mcp/scripts/start-gateway.sh fullstack

# Frontend-only (Next.js + Strapi)
./mcp/scripts/start-gateway.sh frontend

# Backend-only (Medusa + PostgreSQL)
./mcp/scripts/start-gateway.sh backend

# Production debugging
./mcp/scripts/start-gateway.sh debugging

# Documentation research
./mcp/scripts/start-gateway.sh research

# Minimal (filesystem, fetch, github only)
./mcp/scripts/start-gateway.sh minimal
```

### Profile Contents

| Profile | Servers Enabled |
|---------|----------------|
| **fullstack** | medusa, strapi, shadcn, meilisearch, github, filesystem, fetch, postgres, sequentialthinking |
| **frontend** | strapi, shadcn, github, filesystem, fetch, sequentialthinking |
| **backend** | medusa, postgres, meilisearch, github, filesystem, fetch, sequentialthinking |
| **debugging** | medusa, strapi, postgres, sentry, github, fetch, sequentialthinking |
| **research** | brave-search, fetch, filesystem, sequentialthinking |
| **minimal** | filesystem, fetch, github |

---

## Management Commands

### Gateway Control

```bash
# Start gateway
./mcp/scripts/start-gateway.sh [profile]

# Stop gateway
./mcp/scripts/stop-gateway.sh

# Check status
./mcp/scripts/status.sh

# View logs
./mcp/scripts/logs.sh

# Follow logs
./mcp/scripts/logs.sh -f
```

### Claude Code Connection

```bash
# Connect Claude Code to gateway
./mcp/scripts/connect-claude.sh

# Verify connection (in Claude Code)
/mcp-status
```

---

## Configuration

### Environment Variables

Required variables in `.env.mcp`:

```bash
# Medusa (if using medusa MCP server)
MEDUSA_BACKEND_URL=http://localhost:9000
MEDUSA_PUBLISHABLE_KEY=pk_...

# Strapi (if using strapi MCP server)
STRAPI_URL=http://localhost:1337
STRAPI_API_TOKEN=...

# GitHub (if using github MCP server)
GITHUB_TOKEN=ghp_...

# PostgreSQL (if using postgres MCP server)
POSTGRES_CONNECTION_STRING=postgresql://...
```

See [.env.mcp.example](.env.mcp.example) for all available variables.

### Gateway Configuration

Edit `mcp/config.yaml` to customize:

- **Security:** Rate limiting, secret blocking, CORS
- **Resources:** Memory limits, CPU allocation, timeouts
- **Lifecycle:** Auto-start, auto-stop, restart policies
- **Logging:** Log levels, output formats
- **Cache:** Response caching, TTLs

---

## Security Features

### Built-in Protection

| Feature | Description |
|---------|-------------|
| **Signature Verification** | Ensures MCP servers are from trusted sources |
| **Secret Blocking** | Prevents API keys, tokens from appearing in logs/responses |
| **Rate Limiting** | 60 requests/minute per server |
| **CORS** | Only localhost origins allowed |
| **Resource Limits** | CPU/memory caps per server |
| **Network Isolation** | Containers run in isolated network |

### Secret Patterns Blocked

The gateway automatically blocks:
- API keys (`sk-...`, `pk-...`)
- GitHub tokens (`ghp_...`)
- Private keys (PEM format)
- Credit card numbers
- OAuth tokens

---

## Usage Examples

### Query Medusa Products

```typescript
// Claude Code can now use Medusa MCP server
"List all products in Medusa with their variants"

// Gateway routes to medusa MCP server
// Returns product data directly
```

### Search Strapi Content

```typescript
"Find all published blog posts in Strapi about Next.js"

// Gateway routes to strapi MCP server
// Returns articles with populated relations
```

### Database Queries

```typescript
"Show me the schema for the orders table"

// Gateway routes to postgres MCP server
// Returns table structure
```

### GitHub Operations

```typescript
"Create an issue about the cart bug we just found"

// Gateway routes to github MCP server
// Creates issue in repository
```

---

## Troubleshooting

### Gateway Won't Start

```bash
# Check Docker is running
docker info

# Check for port conflicts
lsof -i :8811

# Check logs
docker logs solsdev-mcp-gateway
```

### Server Not Available

```bash
# Check which profile is active
./mcp/scripts/status.sh

# Restart with correct profile
./mcp/scripts/stop-gateway.sh
./mcp/scripts/start-gateway.sh fullstack
```

### Claude Code Not Connecting

```bash
# Re-run connection script
./mcp/scripts/connect-claude.sh

# Restart Claude Code

# Verify gateway is healthy
./mcp/scripts/status.sh
```

### Missing Credentials

```bash
# Check environment variables
cat .env.mcp

# Add missing variables
nano .env.mcp

# Restart gateway
./mcp/scripts/stop-gateway.sh
./mcp/scripts/start-gateway.sh
```

---

## Architecture

```
┌─────────────────────────────────────────────┐
│           Claude Code                        │
└────────────────┬────────────────────────────┘
                 │ SSE (http://localhost:8811)
                 ▼
┌─────────────────────────────────────────────┐
│        SolsDev MCP Gateway                   │
│                                              │
│  • Authentication & Authorization            │
│  • Rate Limiting                             │
│  • Secret Protection                         │
│  • Request Routing                           │
│  • Response Caching                          │
└────────────────┬────────────────────────────┘
                 │
    ┌────────────┼───────────────┐
    │            │               │
    ▼            ▼               ▼
┌────────┐  ┌────────┐      ┌────────┐
│ Medusa │  │ Strapi │  ... │ GitHub │
│  MCP   │  │  MCP   │      │  MCP   │
└────────┘  └────────┘      └────────┘
```

---

## Extending

### Add New MCP Server

1. Edit `mcp/catalogs/solsdev.yaml`
2. Add server definition
3. Restart gateway
4. Server is available immediately

### Create Custom Profile

```yaml
# In mcp/catalogs/solsdev.yaml
profiles:
  my-profile:
    description: "My custom workflow"
    servers:
      - server1
      - server2
```

---

## Performance

### Resource Usage

| Profile | Memory | CPU | Servers |
|---------|--------|-----|---------|
| minimal | ~512MB | ~0.5 | 3 |
| frontend | ~1.5GB | ~1.5 | 7 |
| backend | ~2GB | ~1.5 | 8 |
| fullstack | ~3GB | ~2.0 | 11 |

### Optimization

The gateway:
- **Lazy loads** servers (only starts when first used)
- **Auto-stops** idle servers after 10 minutes
- **Caches** responses for 5 minutes
- **Rate limits** to prevent abuse

---

## Links

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)
- [SolsDev Documentation](../README.md)

---

**Questions?** Open an issue at https://github.com/Neno73/solsdev/issues
