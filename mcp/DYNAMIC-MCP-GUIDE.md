# Dynamic MCP Guide

*Using Docker's Dynamic MCP for on-demand server discovery and activation*

---

## What is Dynamic MCP?

Dynamic MCP enables AI agents (like Claude Code) to **discover and add MCP servers during conversations** without manual configuration or restarts.

### Traditional vs Dynamic MCP

| Aspect | Traditional (Static) | Dynamic MCP |
|--------|---------------------|-------------|
| **Server Setup** | Edit config files manually | Search and add during conversation |
| **Restarts** | Required for every change | No restarts needed |
| **Context Usage** | All server tools loaded (bloats context) | Only active servers in context |
| **Discovery** | Browse docs/GitHub | Search 270+ servers with `mcp-find` |
| **Configuration** | Pre-configure everything | Configure on-demand as needed |

---

## Quick Start

### 1. Enable Dynamic Tools (One-time Setup)

```bash
# Enable the dynamic-tools feature
docker mcp feature enable dynamic-tools

# Verify it's enabled
docker mcp feature list | grep dynamic-tools
# Should show: dynamic-tools    enabled
```

### 2. Connect Claude Code

```bash
# Connect Claude Code to Docker MCP Gateway
docker mcp client connect claude-code --global

# Restart Claude Code
```

### 3. Start Using Dynamic MCP!

In Claude Code conversations, you can now:

```
"Find me the Slack MCP server"
→ I use mcp-find to search the catalog

"Add Slack to this session"
→ I use mcp-add to install it dynamically

"Send a message to #general"
→ I use Slack's tools (now available)
```

---

## Available Catalogs

You have access to **two catalogs**:

### 1. Docker Official Catalog (270+ servers)

Maintained by Docker, includes popular services:
- **Development**: github, gitlab, linear, sentry
- **Databases**: postgres, mysql, redis, mongodb
- **Cloud**: aws, azure, gcp, cloudflare
- **AI/ML**: openai, anthropic, huggingface
- **Communication**: slack, discord, notion
- **And 250+ more...**

### 2. SolsDev Custom Catalog (9 servers)

Your curated servers for this project:
- `github` - GitHub API integration
- `postgres` - PostgreSQL database
- `filesystem` - Local file access
- `fetch` - HTTP fetch for docs
- `brave` - Brave Search API
- `sequential-thinking` - Step-by-step reasoning
- `gitlab` - GitLab integration
- `linear` - Issue tracking
- `sentry` - Error monitoring

---

## Dynamic Tools Reference

### `mcp-find`

Search for MCP servers across all catalogs.

**Examples:**
```
"Find PostgreSQL servers"
→ Returns 3 matches: postgres, prisma-postgres, database-server

"Find Slack servers"
→ Returns 2 matches: slack, waystation

"Find GitHub servers"
→ Returns 6 matches: github, github-official, github-chat, etc.
```

**Parameters:**
- `query` (required) - Search term
- `limit` (optional) - Max results to return

**Returns:**
```json
{
  "query": "slack",
  "servers": [
    {
      "name": "slack",
      "description": "Interact with Slack Workspaces...",
      "required_secrets": ["slack.bot_token"],
      "config_schema": [...]
    }
  ],
  "total_matches": 2
}
```

### `mcp-add`

Add a server to the current session.

**Examples:**
```
"Add the fetch server"
→ Installs fetch MCP, tools become available immediately

"Add GitHub server"
→ Asks for required secrets (github.personal_access_token)

"Add sequential-thinking server"
→ No secrets needed, activates immediately
```

**Parameters:**
- `name` (required) - Exact server name from mcp-find

**Returns:**
- Success: List of newly available tools
- Error: Missing secrets/config with instructions

### `mcp-remove`

Remove a server from the current session.

**Examples:**
```
"Remove the Slack server"
→ Deactivates Slack, frees resources
```

**Parameters:**
- `name` (required) - Server name to remove

### `mcp-config-set`

Configure server settings on-the-fly.

**Examples:**
```
"Set Slack team_id to T12345"
→ Configures Slack server

"Set filesystem allowed paths"
→ Configures filesystem server
```

**Parameters:**
- `server` (required) - Server name
- `key` (required) - Config key
- `value` (required) - Config value

### `mcp-exec`

Execute a specific tool from any active server.

**Parameters:**
- `server` (required) - Server name
- `tool` (required) - Tool name
- `params` (required) - Tool parameters

### `code-mode` (Experimental)

Write JavaScript to compose multiple MCP tools.

**Example:**
```javascript
// Call GitHub + Markdownify in one operation
const issues = await github.listIssues({owner: "user", repo: "repo"})
const markdown = await markdownify.format(issues)
return markdown
```

---

## Typical Workflows

### Workflow 1: Discover and Use New Service

```
User: "I need to search for React documentation"

Claude: "Let me find web search servers for you"
→ Uses mcp-find(query: "search")
→ Finds: brave, duckduckgo, tavily

Claude: "I found 3 search servers. Adding Brave Search..."
→ Uses mcp-add(name: "brave")
→ Error: Requires brave.api_key

Claude: "Brave Search requires an API key. You can get one from..."
User provides API key via Docker Desktop or CLI

Claude: "Now searching for React documentation..."
→ Uses brave_web_search tool
→ Returns latest React docs
```

### Workflow 2: Project-Specific Discovery

```
User: "Analyze my project and suggest relevant MCP servers"

Claude: Uses /MCP_DOCKER:mcp-discover
→ Reads package.json
→ Finds: Next.js, PostgreSQL, Strapi, Redis

→ Uses mcp-find for each dependency
→ Finds relevant servers:
  - postgres (PostgreSQL)
  - strapi (CMS, if available)
  - redis (Redis)
  - vercel (Next.js deployment)

Claude: "Based on your project, I recommend:
- postgres (database queries)
- redis (caching)
- vercel (deployment)

Would you like me to add these?"

User: "Yes, add them"

Claude: Adds each server, handles auth/config
→ All tools now available for project work
```

### Workflow 3: Temporary Tool Usage

```
User: "Fetch the latest Medusa.js release notes"

Claude: "Adding fetch server temporarily..."
→ Uses mcp-add(name: "fetch")
→ Fetch tool now available

→ Uses fetch(url: "https://github.com/medusajs/medusa/releases")
→ Returns release notes

Claude: "Done! Here are the release notes..."

→ Uses mcp-remove(name: "fetch")
→ Cleans up resources
```

---

## Managing Secrets

### Using Docker Desktop (Recommended)

1. Open **Docker Desktop**
2. Go to **Settings → Resources → Secrets**
3. Add secrets:
   - `github.personal_access_token=ghp_...`
   - `slack.bot_token=xoxb-...`
   - `postgres.url=postgresql://...`

### Using CLI

```bash
# Set a secret
docker mcp secret set github.personal_access_token=ghp_your_token

# List secrets
docker mcp secret list

# Delete a secret
docker mcp secret delete github.personal_access_token
```

### Using Environment Variables

Create `.env.mcp` in project root:

```bash
GITHUB_TOKEN=ghp_your_token
SLACK_BOT_TOKEN=xoxb_your_token
POSTGRES_CONNECTION_STRING=postgresql://...
```

Docker MCP Gateway will automatically load these.

---

## Adding Custom Servers to Catalog

### Option 1: Add Docker Hub Servers

Most popular MCP servers are already in Docker's catalog:

```bash
# Search Docker catalog
docker mcp catalog show docker-mcp | grep server-name

# Add to your solsdev catalog
docker mcp catalog add solsdev server-name docker-mcp
```

### Option 2: Containerize Your Custom Servers

For servers like Medusa, Strapi, shadcn that aren't in Docker's catalog:

**Step 1: Create Dockerfile**

```dockerfile
# Example: Medusa MCP Server
FROM node:20-alpine
RUN npm install -g @medusajs/mcp-server
ENV MEDUSA_BACKEND_URL=""
ENV MEDUSA_PUBLISHABLE_KEY=""
ENTRYPOINT ["npx", "@medusajs/mcp-server"]
```

**Step 2: Build and Push**

```bash
# Build image
docker build -t your-registry/medusa-mcp:latest .

# Push to registry
docker push your-registry/medusa-mcp:latest
```

**Step 3: Add to Catalog**

Edit `~/.docker/mcp/catalogs/solsdev.yaml`:

```yaml
registry:
  medusa:
    description: "Medusa v2 commerce engine"
    title: "Medusa"
    type: server
    image: your-registry/medusa-mcp:latest
    secrets:
      - name: medusa.backend_url
        env: MEDUSA_BACKEND_URL
      - name: medusa.publishable_key
        env: MEDUSA_PUBLISHABLE_KEY
    tools:
      - name: list_products
      - name: create_cart
```

---

## Troubleshooting

### "mcp-find not available"

**Cause:** Dynamic-tools feature not enabled.

**Fix:**
```bash
docker mcp feature enable dynamic-tools
docker mcp client connect claude-code --global
# Restart Claude Code
```

### "Server X not found in catalog"

**Cause:** Server not in Docker or solsdev catalogs.

**Fix:**
```bash
# Search Docker catalog
docker mcp catalog show docker-mcp | grep "server-name"

# If not found, containerize it (see above)
```

### "Cannot add server - missing secrets"

**Cause:** Server requires authentication.

**Fix:**
```bash
# Using Docker Desktop
# Settings → Resources → Secrets → Add secret

# Or using CLI
docker mcp secret set server-name.secret-key=value
```

### "Connection closed" errors

**Cause:** Gateway crashed or not running.

**Fix:**
```bash
# Check if gateway is running
docker mcp server ls

# Reconnect Claude Code
docker mcp client connect claude-code --global

# Restart Claude Code
```

### Servers overlap warnings

**Cause:** Same server in multiple catalogs (Docker + solsdev).

**Fix:** This is normal. Docker catalog takes precedence. You can ignore the warnings or remove duplicates from solsdev catalog:

```bash
# Remove duplicate from solsdev
docker mcp catalog remove solsdev server-name
```

---

## Performance & Best Practices

### Context Efficiency

**Before Dynamic MCP:**
```
Context: 200,000 tokens
- All 15 server tool definitions: 50,000 tokens
- Remaining for actual work: 150,000 tokens
```

**After Dynamic MCP:**
```
Context: 200,000 tokens
- Management tools only: 5,000 tokens
- Dynamically added servers: ~10,000 tokens
- Remaining for actual work: 185,000 tokens
```

### Only Add What You Need

```
# BAD - Adding everything
"Add github, gitlab, linear, sentry, postgres, redis, slack..."

# GOOD - Add as needed
"Add github" → Use it → "Add postgres" → Use it
```

### Clean Up After Use

```
# Add for temporary task
"Add fetch server"
→ Fetch documentation
→ "Remove fetch server"  # Free resources
```

### Use Persistent Servers for Common Tasks

Enable frequently used servers permanently:

```bash
# Enable in Docker config (survives restarts)
docker mcp server enable github filesystem sequential-thinking
```

---

## Comparison: Manual vs Docker Desktop Management

### Manual Approach (What We Built)

**Pros:**
- Full control over gateway startup
- Can use custom catalogs easily
- Shell scripts for automation

**Cons:**
- Gateway doesn't auto-start
- Need to manage process manually
- stdio transport requires manual connection

### Docker Desktop Approach (Recommended)

**Pros:**
- ✅ Gateway auto-starts with Docker Desktop
- ✅ UI for managing servers/secrets
- ✅ One-click client connections
- ✅ Automatic restarts

**Cons:**
- Requires Docker Desktop running
- Less scriptable

**Recommendation:** Use Docker Desktop for daily work, manual approach for advanced customization.

---

## Next Steps

### For Daily Use

1. **Enable commonly used servers:**
   ```bash
   docker mcp server enable github filesystem sequential-thinking
   ```

2. **Configure secrets in Docker Desktop**
   - Settings → Resources → Secrets
   - Add GitHub token, database URLs, API keys

3. **Start working!**
   - Dynamic discovery will handle the rest
   - Add servers as you need them

### For Advanced Users

1. **Publish your solsdev catalog to Docker Hub**
   ```bash
   docker mcp catalog build -f ~/.docker/mcp/catalogs/solsdev.yaml -t yourname/solsdev:latest
   docker mcp catalog push yourname/solsdev:latest
   ```

2. **Create custom MCP servers**
   - Containerize Medusa, Strapi, shadcn
   - Add to your registry
   - Share with team

3. **Explore code-mode (experimental)**
   - Compose multiple tools in JavaScript
   - Build complex workflows

---

## Resources

### Documentation
- [Docker MCP Gateway](https://github.com/docker/mcp-gateway)
- [Dynamic MCP Docs](https://docs.docker.com/ai/mcp-catalog-and-toolkit/dynamic-mcp/)
- [MCP Specification](https://spec.modelcontextprotocol.io/)

### Your Setup
- **Catalogs:** `~/.docker/mcp/catalogs/`
- **Secrets:** Docker Desktop → Settings → Resources → Secrets
- **Logs:** Check Docker Desktop → Containers → mcp-gateway

### Getting Help
- [Docker MCP Issues](https://github.com/docker/mcp-gateway/issues)
- [SolsDev Issues](https://github.com/Neno73/solsdev/issues)

---

**Dynamic MCP: Stop hardcoding your agent's world!** 🚀
