# MCP Server Authentication Guide

*How Dynamic MCP handles different authentication patterns*

---

## Overview

Dynamic MCP supports three authentication patterns, each handled automatically based on the server's requirements.

---

## Authentication Patterns

### 1. No Authentication Required

**Servers**: fetch, filesystem, sequential-thinking

**Flow:**
```
User: "Add the fetch server"
→ mcp-add(name: "fetch")
→ ✅ Success! 1 tool available immediately
```

**Use When:**
- Server doesn't access external APIs
- Server operates on local resources only
- No sensitive data involved

**Example:**
```json
{
  "name": "fetch",
  "description": "Fetches URLs and extracts content",
  "required_secrets": []  // No secrets needed
}
```

---

### 2. API Keys / Secrets

**Servers**: Neon, GitHub, Slack, PostgreSQL, Brave Search

**Flow:**
```
User: "Add the Neon server"
→ mcp-add(name: "neon")
→ ❌ Error: Missing required secrets (neon.api_key)

User: Configures secret via Docker Desktop or CLI
→ docker mcp secret set neon.api_key=napi_xxx

User: "Try adding Neon again"
→ mcp-add(name: "neon")
→ ✅ Success! Server configured and ready
```

**Characteristics:**
- **Manual configuration required**
- **Secrets stored securely** in Docker Desktop
- **More control** over credentials
- **Works offline** once configured

**How to Configure Secrets:**

**Option A: Docker Desktop UI**
```
1. Docker Desktop → Settings → Resources → Secrets
2. Click "Add Secret"
3. Name: server.secret_name (e.g., neon.api_key)
4. Value: your_api_key_here
5. Save
```

**Option B: CLI**
```bash
docker mcp secret set neon.api_key=napi_your_key_here
docker mcp secret set github.personal_access_token=ghp_your_token
docker mcp secret set slack.bot_token=xoxb_your_token
```

**Option C: Environment Variables**
```bash
# In .env.mcp
NEON_API_KEY=napi_your_key
GITHUB_TOKEN=ghp_your_token
SLACK_BOT_TOKEN=xoxb_your_token
```

**Secret Naming Convention:**
```
{server-name}.{secret-key}

Examples:
- neon.api_key
- github.personal_access_token
- postgres.url
- slack.bot_token
- brave.api_key
```

---

### 3. OAuth / SSO

**Servers**: Sentry, Linear, Notion, Google Drive

**Flow:**
```
User: "Add Sentry server"
→ mcp-add(name: "sentry-remote")
→ ✅ Server added! Click to authorize: [OAuth Link]

User: Clicks link → Signs in to Sentry → Grants permissions
→ Browser redirects to Docker MCP
→ Authorization complete!

User: "Add Sentry again" (or just use tools)
→ mcp-add(name: "sentry-remote")
→ ✅ Server is authorized. Tools available!
```

**Characteristics:**
- **Click-to-authorize** - simple user flow
- **Automatic token management** - Docker handles refresh tokens
- **Scoped permissions** - you control what access to grant
- **Revocable** - can revoke access from provider's dashboard

**What Happens Behind the Scenes:**
```
1. mcp-add initiates OAuth flow
2. Docker MCP generates authorization URL
3. You click link → Provider's OAuth page
4. You authorize → Provider redirects to Docker MCP
5. Docker MCP receives & stores access token
6. Future requests use stored token automatically
```

**OAuth Flow Example (Sentry):**
```
Authorization URL:
https://mcp.sentry.dev/oauth/authorize?
  client_id=ClNll1dUpzMTOmKn
  &code_challenge=...
  &redirect_uri=https://mcp.docker.com/oauth/callback
  &response_type=code
  &state=0357bab7-...

After authorization:
→ Access token stored securely
→ Refresh token stored for auto-renewal
→ Tools become available immediately
```

---

## Authentication Decision Tree

```
Need to add MCP server?
│
├─ Does mcp-find show "required_secrets"?
│  │
│  ├─ No → Add immediately with mcp-add ✅
│  │
│  └─ Yes → Check secret type
│     │
│     ├─ API key/token listed?
│     │  └─ Configure secret first:
│     │     - Docker Desktop UI, or
│     │     - CLI: docker mcp secret set
│     │     - Then: mcp-add
│     │
│     └─ OAuth mentioned or remote URL?
│        └─ Add server first: mcp-add
│           → Click OAuth link
│           → Authorize
│           → Done! ✅
```

---

## Real-World Examples

### Example 1: Neon (API Key)

**Server Info:**
```json
{
  "name": "neon",
  "description": "MCP server for Neon databases",
  "required_secrets": ["neon.api_key"]
}
```

**Setup Process:**
```bash
# 1. Get API key from Neon console
# Visit: console.neon.tech → Settings → API Keys → Generate

# 2. Configure secret
docker mcp secret set neon.api_key=napi_pm94xcn8m3q9zkq5...

# 3. Add server
# In Claude Code:
"Add the Neon server"
→ ✅ Success! Tools available
```

**Tools Available After Auth:**
```
- list_projects
- create_project
- list_databases
- create_database
- execute_query
```

---

### Example 2: Sentry (OAuth)

**Server Info:**
```json
{
  "name": "sentry-remote",
  "description": "Track errors and monitor performance",
  "auth": "oauth"
}
```

**Setup Process:**
```
1. In Claude Code: "Add Sentry server"
   → System returns OAuth link

2. Click the link
   → Opens Sentry OAuth page

3. Sign in to Sentry (if needed)
   → Already logged in? Skips to step 4

4. Grant permissions
   → "Allow Docker MCP to access your Sentry data?"
   → Click "Authorize"

5. Browser redirects to Docker MCP
   → "Authorization successful!"

6. Back in Claude Code: "Add Sentry again"
   → ✅ Server is authorized. Tools available!
```

**Tools Available After Auth:**
```
- list_issues
- get_issue_details
- search_issues
- get_stacktrace
- list_projects
```

---

### Example 3: GitHub (API Key)

**Server Info:**
```json
{
  "name": "github",
  "description": "GitHub API integration",
  "required_secrets": ["github.personal_access_token"]
}
```

**Setup Process:**
```bash
# 1. Generate Personal Access Token
# Visit: github.com → Settings → Developer settings →
#        Personal access tokens → Generate new token

# Scopes needed:
# - repo (for private repos)
# - public_repo (for public repos)
# - read:org (for organization data)

# 2. Configure secret
docker mcp secret set github.personal_access_token=ghp_xxxx

# 3. Add server
# In Claude Code: "Add GitHub server"
→ ✅ Success! 26 tools available
```

---

## Managing Secrets

### List Configured Secrets

```bash
docker mcp secret list
```

**Output:**
```
SECRET                              CONFIGURED
neon.api_key                        ✓
github.personal_access_token        ✓
slack.bot_token                     ✓
postgres.url                        ✓
```

### Update a Secret

```bash
# Overwrite existing secret
docker mcp secret set github.personal_access_token=ghp_new_token
```

### Delete a Secret

```bash
docker mcp secret delete github.personal_access_token
```

### Secrets Location

**Docker Desktop manages secrets securely:**
- Encrypted at rest
- Never exposed in logs
- Not visible in `docker inspect`
- Injected as environment variables to containers

**Storage Location:**
- macOS: `~/Library/Group Containers/group.com.docker/settings.json` (encrypted)
- Linux: `~/.docker/config.json` (encrypted)
- Windows: `%APPDATA%\Docker\settings.json` (encrypted)

---

## OAuth Management

### View OAuth Authorizations

```bash
# Check if server is authorized
docker mcp server inspect sentry-remote | grep -i auth
```

**Output:**
```
Authorized: true
OAuth Provider: sentry
Token Expiry: 2025-12-26T23:15:00Z
```

### Revoke OAuth Access

**Option 1: From Provider's Dashboard**
```
1. Log in to Sentry (or other OAuth provider)
2. Go to Settings → Applications → Authorized Applications
3. Find "Docker MCP"
4. Click "Revoke Access"
```

**Option 2: Remove Server**
```bash
# Removes server and clears OAuth tokens
docker mcp server disable sentry-remote
```

### Re-authorize After Revocation

```
# In Claude Code:
"Add Sentry server again"
→ New OAuth link provided
→ Click and re-authorize
→ Done!
```

---

## Security Best Practices

### For API Keys

✅ **DO:**
- Generate keys with minimal required scopes
- Rotate keys regularly (every 90 days)
- Use Docker Desktop for secret storage
- Delete keys when no longer needed

❌ **DON'T:**
- Share keys in chat/screenshots
- Commit keys to git repositories
- Use production keys for development
- Grant excessive permissions

### For OAuth

✅ **DO:**
- Review permissions before authorizing
- Use separate OAuth apps for dev/prod
- Revoke unused authorizations
- Monitor OAuth activity in provider dashboards

❌ **DON'T:**
- Authorize on untrusted devices
- Share OAuth redirect URLs
- Ignore permission requests
- Leave old authorizations active

---

## Troubleshooting

### "Missing required secrets" Error

**Cause:** Server needs API key/token but none configured.

**Fix:**
```bash
# Check what's needed
# Error message shows: docker mcp secret set <name>=<value>

# Configure the secret
docker mcp secret set neon.api_key=napi_your_key

# Retry adding server
# In Claude Code: "Add Neon server"
```

### OAuth Link Doesn't Work

**Cause:** Link expired or browser issues.

**Fix:**
```
1. Try adding server again to get fresh OAuth link
2. Copy URL and paste in different browser
3. Clear browser cookies for OAuth provider
4. Try incognito/private browsing mode
```

### "Server is not authorized" After OAuth

**Cause:** OAuth callback failed or was cancelled.

**Fix:**
```
1. Remove server: mcp-remove(name: "sentry-remote")
2. Add again: mcp-add(name: "sentry-remote")
3. Click new OAuth link
4. Complete authorization fully (don't close browser early)
5. Wait for "Authorization successful" message
```

### Secrets Not Persisting

**Cause:** Docker Desktop settings not saved.

**Fix:**
```bash
# Ensure Docker Desktop is running
docker info

# Re-add secret
docker mcp secret set github.personal_access_token=ghp_xxx

# Verify it's saved
docker mcp secret list | grep github
```

---

## Comparison: Static vs Dynamic Auth

### Static Configuration (Old Way)

**Setup:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_hardcoded_token_here"  // ❌ Visible in config
      }
    }
  }
}
```

**Problems:**
- Secrets in plaintext config files
- Manual config editing required
- Hard to rotate credentials
- All servers loaded always

### Dynamic Configuration (New Way)

**Setup:**
```bash
# One-time secret configuration
docker mcp secret set github.personal_access_token=ghp_xxx
```

**Usage:**
```
# In conversation:
"Add GitHub server"
→ Uses stored secret automatically
→ No config file editing
→ Secrets encrypted in Docker Desktop
→ Only loaded when needed
```

**Benefits:**
- Secrets encrypted and managed securely
- No config file changes
- Easy credential rotation
- Load servers on-demand

---

## Summary

| Auth Type | Setup Effort | Security | User Experience | Best For |
|-----------|--------------|----------|----------------|----------|
| **No Auth** | None | N/A | Instant | Local tools, public APIs |
| **API Key** | Medium | High (if managed properly) | One-time setup | Long-lived access, automation |
| **OAuth** | Low | Very High | Click to authorize | User-specific data, delegated access |

**Recommendation:**
- Use **OAuth** when available (easiest, most secure)
- Use **API Keys** for automation and long-running tasks
- **No Auth** for local/public tools

---

**Dynamic MCP makes authentication simple and secure!** 🔐
