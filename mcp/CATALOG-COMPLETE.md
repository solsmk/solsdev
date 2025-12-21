# solsdev MCP Catalog - Complete Reference

**Status:** ✅ Production Ready
**Last Updated:** 2025-12-21
**Total Servers:** 16 (11 from Docker + 5 custom)

---

## Quick Access

- **Catalog File:** `~/.docker/mcp/catalogs/solsdev.yaml`
- **GitHub Packages:** https://github.com/orgs/solsmk/packages
- **Repository:** https://github.com/solsmk/solsdev

---

## What's in the Catalog

### From Docker Official Catalog (11 servers)

| Server | Description | Authentication |
|--------|-------------|----------------|
| **brave** | Brave Search API | API Key required |
| **context7** | Up-to-date code documentation | None |
| **curl** | Standard curl tool | None |
| **fetch** | Fetch URLs and extract markdown | None |
| **gemini-api-docs** | Google Gemini API documentation | None |
| **github** | GitHub API (Archived version) | Personal Access Token |
| **github-official** | Official GitHub MCP | Personal Access Token or OAuth |
| **next-devtools-mcp** | Next.js development tools | None |
| **playwright** | Browser automation | None |
| **postgres** | PostgreSQL read-only access | Connection URL |
| **sequential-thinking** | Step-by-step reasoning | None |

### Custom Servers (5 servers)

#### Containerized Servers (4 servers - We Built & Host)

| Server | Description | Image Location | Authentication |
|--------|-------------|----------------|----------------|
| **bugsink** | Bugsink error tracking | `ghcr.io/solsmk/bugsink-mcp` | API Token + URL |
| **chrome-devtools** | Chrome DevTools automation | `ghcr.io/solsmk/chrome-devtools-mcp` | None |
| **shadcn** | shadcn/ui component registry | `ghcr.io/solsmk/shadcn-mcp` | None |
| **strapi** | Strapi CMS integration | `ghcr.io/solsmk/strapi-mcp` | API URL + JWT Token |

#### Remote HTTP Servers (1 server - Medusa Hosts)

| Server | Description | Endpoint | Authentication |
|--------|-------------|----------|----------------|
| **medusa** | Medusa.js documentation | `https://docs.medusajs.com/mcp` | None (public) |

**Note:** Medusa is a remote HTTP server hosted by Medusa.js. No Docker image needed - it connects directly to their endpoint.

---

## Using the Catalog

### View All Servers

```bash
docker mcp catalog show solsdev
```

### In Claude Code Conversations

The catalog is available through Docker's Dynamic MCP system. Servers can be added on-demand during conversations using the management tools.

**Note:** After catalog updates, you may need to restart Claude Code for changes to be indexed by `mcp-find`.

---

## Required Secrets & Configuration

### Brave Search

```bash
docker mcp secret set brave.api_key=YOUR_BRAVE_API_KEY
```

Get API key: https://brave.com/search/api/

### Bugsink

```bash
docker mcp secret set bugsink.token=YOUR_BUGSINK_API_TOKEN
docker mcp secret set bugsink.url=https://bug.sols.mk:8000
```

**Default URL:** `https://bug.sols.mk:8000` (SolsDev instance)

### GitHub (Archived)

```bash
docker mcp secret set github.personal_access_token=ghp_YOUR_TOKEN
```

Create token: https://github.com/settings/tokens

**Required scopes:** `repo`, `read:org`

### GitHub Official

**Option 1: Personal Access Token**
```bash
docker mcp secret set github.personal_access_token=ghp_YOUR_TOKEN
```

**Option 2: OAuth** (Preferred)
- Run `mcp-add` for github-official
- Click OAuth link
- Authorize in browser

### PostgreSQL

```bash
docker mcp secret set postgres.url=postgresql://user:pass@host:5432/database
```

### Strapi

**Using Config File:** `~/.mcp/strapi-mcp-server.config.json`
```json
{
  "myserver": {
    "api_url": "http://localhost:1337",
    "api_key": "your-jwt-token-from-strapi-admin",
    "version": "5.*"
  }
}
```

**Or via mcp-config-set:**
```
mcp-config-set(
  server: "strapi",
  key: "strapi.api_url",
  value: "http://localhost:1337"
)
```

---

## Published Docker Images

**We host 4 containerized servers** on GitHub Container Registry:

```bash
# Pull images (public, no auth needed once made public)
docker pull ghcr.io/solsmk/bugsink-mcp:latest
docker pull ghcr.io/solsmk/chrome-devtools-mcp:latest
docker pull ghcr.io/solsmk/shadcn-mcp:latest
docker pull ghcr.io/solsmk/strapi-mcp:latest
```

**Image Details:**

| Image | Size | Base | SHA256 |
|-------|------|------|--------|
| bugsink-mcp | ~60MB | node:20-alpine | `9eae27a6...` |
| chrome-devtools-mcp | ~800MB | node:20-alpine + chromium | `12cbd5e5...` |
| shadcn-mcp | ~200MB | node:20-alpine | `8be63c32...` |
| strapi-mcp | ~180MB | node:20-alpine | `4322406b...` |

**Medusa** is not listed here because it's a remote HTTP server hosted by Medusa.js at `https://docs.medusajs.com/mcp`. No Docker image needed.

---

## For Team Members

### First-Time Setup

1. **Enable Dynamic MCP** (one-time):
   ```bash
   docker mcp feature enable dynamic-tools
   docker mcp client connect claude-code --global
   ```

2. **Restart Claude Code**

3. **Configure Required Secrets**:
   - See "Required Secrets & Configuration" section above
   - Only configure secrets for servers you'll use

4. **Use in Conversations**:
   - Servers are available via Docker's Dynamic MCP tools
   - Use `docker mcp catalog show solsdev` to see all available servers

### Accessing Custom Images

Our **4 containerized servers** (bugsink, chrome-devtools, shadcn, strapi) are hosted on GitHub Container Registry (ghcr.io) and linked to the `solsmk/solsdev` repository.

**If images are public:** No authentication needed - team can pull directly
**If images are private:** Team members need:
```bash
# Login to GHCR (one-time)
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

**To make images public:**
1. Go to https://github.com/orgs/solsmk/packages
2. Click on package name (bugsink-mcp, chrome-devtools-mcp, shadcn-mcp, strapi-mcp)
3. Package settings → Change visibility → Public

**Medusa server** doesn't require any image access - it connects directly to Medusa's hosted endpoint.

---

## Maintenance

### Updating a Server

1. **Rebuild Docker image:**
   ```bash
   cd /path/to/server
   docker build -t ghcr.io/solsmk/SERVER-NAME:latest .
   ```

2. **Push to GHCR:**
   ```bash
   docker push ghcr.io/solsmk/SERVER-NAME:latest
   ```

3. **Get new SHA256:**
   ```bash
   docker inspect ghcr.io/solsmk/SERVER-NAME:latest --format='{{index .RepoDigests 0}}'
   ```

4. **Update catalog:** Edit `~/.docker/mcp/catalogs/solsdev.yaml` with new SHA256

5. **Restart Claude Code** for changes to take effect

### Adding a New Server

1. **Build and push Docker image** (if containerized)
2. **Add entry to `solsdev.yaml`** following existing format
3. **Restart Claude Code**

---

## Troubleshooting

### Servers not showing in mcp-find

**Solution:** Restart Claude Code to refresh the catalog index.

Or use Docker CLI directly:
```bash
docker mcp catalog show solsdev | grep server-name
```

### Image pull fails

**If public images:**
- Check internet connection
- Verify image name: `ghcr.io/solsmk/SERVER-NAME:latest`

**If private images:**
```bash
docker login ghcr.io -u YOUR_GITHUB_USERNAME
# Enter Personal Access Token as password
```

### Secret not found

```bash
# List all secrets
docker mcp secret list

# Set missing secret
docker mcp secret set SERVER.SECRET_NAME=value
```

### Server fails to start

**Check logs:**
```bash
docker logs $(docker ps -a | grep SERVER-NAME | awk '{print $1}')
```

**Common issues:**
- Missing required secrets/config
- Invalid API keys
- Network connectivity
- Image not found (pull manually first)

---

## Architecture

```
┌─────────────────────────────────────────────┐
│           Claude Code                        │
└────────────────┬────────────────────────────┘
                 │ stdio (auto-managed)
                 ▼
┌─────────────────────────────────────────────┐
│   Docker MCP Gateway (Auto-started)          │
│                                              │
│  Catalogs:                                   │
│  • docker-mcp (270+ servers)                 │
│  • solsdev (16 servers)                      │
│                                              │
│  Containerized Servers from GHCR:            │
│  • ghcr.io/solsmk/bugsink-mcp                │
│  • ghcr.io/solsmk/chrome-devtools-mcp        │
│  • ghcr.io/solsmk/shadcn-mcp                 │
│  • ghcr.io/solsmk/strapi-mcp                 │
│                                              │
│  Remote HTTP Servers:                        │
│  • https://docs.medusajs.com/mcp (Medusa)    │
└─────────────────────────────────────────────┘
```

---

## Source Code Locations

| Component | Path |
|-----------|------|
| Catalog YAML | `~/.docker/mcp/catalogs/solsdev.yaml` |
| Bugsink Server | `/home/neno/Code/bugsink-mcp-server/` |
| Chrome DevTools Dockerfile | `/tmp/mcp-builds/chrome-devtools/Dockerfile` |
| shadcn Dockerfile | `/tmp/mcp-builds/shadcn/Dockerfile` |
| Strapi Dockerfile | `/tmp/mcp-builds/strapi/Dockerfile` |

---

## Next Steps

### Recommended

1. **Make images public** on GHCR so team doesn't need authentication
2. **Set up GitHub Actions** to auto-build and push images on commit
3. **Document team workflows** for common use cases
4. **Create onboarding guide** for new team members

### Optional

1. **Version tagging** - Tag images with git commits (e.g., `v1.0.0`, `sha-abc123`)
2. **CI/CD integration** - Auto-build on PR, auto-deploy on merge
3. **Monitoring** - Set up alerts for image vulnerabilities
4. **Documentation site** - Host catalog docs on GitHub Pages

---

**Questions?** Open an issue at https://github.com/solsmk/solsdev/issues
