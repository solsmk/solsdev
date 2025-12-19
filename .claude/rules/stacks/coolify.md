---
paths: "**/coolify/**/*", "**/docker-compose*.yml", "**/docker-compose*.yaml", "**/.coolify/**/*"
---

# Coolify Development Rules

*Applied when working with Coolify deployments*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://coolify.io/docs |
| **Installation** | https://coolify.io/docs/get-started |
| **Environment Variables** | https://coolify.io/docs/knowledge-base/environment-variables |
| **Troubleshooting** | https://coolify.io/docs/troubleshoot/overview |
| **GitHub** | https://github.com/coollabsio/coolify |
| **Releases** | https://github.com/coollabsio/coolify/releases |

**Current Version**: v4.0.0 (beta), v5.x in development

## What is Coolify?

Self-hosted PaaS (Platform-as-a-Service):
- Alternative to Heroku, Vercel, Netlify
- Manage servers, apps, databases via UI
- 280+ one-click services
- Only requires SSH connection to servers

## Installation

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Recommended setup:
- One server for Coolify management
- One or more servers for deployments
- Typical cost: $4-5/month per server

## Build Packs

### Nixpacks (Default)

```
Automatically detects and generates Dockerfile
- Git-based deployments only
- Good for quick setup
- Supports static sites and dynamic apps
```

### Dockerfile (Custom)

```dockerfile
# Full control over build
# Auto-injects build ARGs
FROM node:20-alpine
WORKDIR /app
# ...
```

### Docker Compose (Multi-Service)

```yaml
# Compose file is single source of truth
# UI reflects compose configuration
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
```

## Environment Variables

### Scoping Levels

| Level | Syntax | Use Case |
|-------|--------|----------|
| Team | `{{team.VAR_NAME}}` | Shared across projects |
| Project | `{{project.VAR_NAME}}` | Shared within project |
| Environment | `{{environment.VAR_NAME}}` | Per environment |

### Docker Compose Variables

```yaml
services:
  app:
    environment:
      # Hardcoded (not visible in UI)
      HARDCODED_VALUE: hello

      # Editable in Coolify UI (initially empty)
      DATABASE_URL: ${DATABASE_URL}

      # Editable with default
      NODE_ENV: ${NODE_ENV:-production}
```

### Predefined (Magic) Variables

| Variable | Contains |
|----------|----------|
| `SOURCE_COMMIT` | Git commit hash (disabled by default) |
| `COOLIFY_FQDN` | Domain name(s) |
| `COOLIFY_URL` | Application URL(s) |
| `COOLIFY_BRANCH` | Git branch name |
| `COOLIFY_CONTAINER_NAME` | Generated container name |

**Warning**: Enabling `SOURCE_COMMIT` breaks Docker layer caching.

## Database Provisioning

### Supported Databases (One-Click)

- PostgreSQL
- MySQL / MariaDB
- MongoDB
- Redis / KeyDB / DragonFly
- ClickHouse

### PostgreSQL Setup

```
1. Create new resource → PostgreSQL
2. Configure credentials
3. Enable SSL if needed
4. Set backup schedule (cron)
5. Configure S3 backup storage
```

### Network Connectivity

```
Same network: Use internal URL (Coolify provides)
Different network: Use public URL + firewall rules
```

## Deployment Workflow

```
1. Install Coolify on management server
   ↓
2. Connect target servers via SSH
   ↓
3. Create project → environment
   ↓
4. Connect Git repository
   ↓
5. Select build pack (Nixpacks/Dockerfile/Compose)
   ↓
6. Configure environment variables
   ↓
7. Set up database (if needed)
   ↓
8. Configure domains
   ↓
9. Deploy → Auto SSL provisioning
```

## Critical Gotchas

### 1. Traefik Proxy Issues

```
Symptom: "No Available Server" error
Cause: Container health check failing

Check:
docker ps  # Look for (unhealthy) status

Solution:
- Traefik v2.11.31+ auto-negotiates Docker API
- Check container logs
```

### 2. Connection Instability

```
Symptom: Unreliable deployment/access
Cause: 90% of cases = firewall issues

Check:
- UFW/iptables rules
- Port 22 LIMIT rules blocking SSH
- Ports 80/443 accessible
```

### 3. SSL Certificate Failures

```
Symptom: Browser cert warnings
Cause: DNS misconfiguration or port accessibility

Solution:
- Ensure DNS points to server
- Ports 80/443 must be open
- Check Let's Encrypt rate limits
```

### 4. Preview Deployment Variables

```
Issue: Magic variables not applied in preview deployments
Status: Known v4 bug
Workaround: Manually set in preview environment
```

### 5. Build Cache Invalidation

```
Problem: SOURCE_COMMIT changes every commit
Result: Docker layer cache invalidated

Solution: Keep SOURCE_COMMIT disabled unless required
```

### 6. Monorepo Base Directory

```
Problem: Build fails in monorepo

Solution: Set base directory in Coolify UI
Example: /apps/web or /packages/api
```

### 7. Static Site Mode

```
Problem: SPA routing broken (404 on refresh)

Solution: Enable "Static Site" mode in Nixpacks
- Serves via Nginx
- Handles client-side routing
```

## SSL/TLS Management

- Automatic Let's Encrypt provisioning
- Auto-renewal before expiration
- Custom domain support
- No manual cert management needed

## Health Checks

```yaml
# docker-compose.yml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Backup Configuration

### Database Backups

```
1. Go to database resource
2. Configure backup schedule (cron)
3. Set S3-compatible storage
4. Test backup/restore
```

### Cron Expression Examples

| Schedule | Cron |
|----------|------|
| Daily at midnight | `0 0 * * *` |
| Every 6 hours | `0 */6 * * *` |
| Weekly Sunday | `0 0 * * 0` |

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `No Available Server` | Check container health, Traefik config |
| SSL cert failure | Verify DNS, check ports 80/443 |
| Build fails | Check base directory for monorepos |
| Container keeps restarting | Add health check, check logs |
| 504 Gateway Timeout | Check Docker network isolation, increase timeout |
| Can't access dashboard | Verify port 8000 open |
| Install script fails | Run with `bash -x install.sh` for debug |

## Git Integration

### Supported Providers

- GitHub (hosted/self-hosted)
- GitLab (hosted/self-hosted)
- Bitbucket
- Gitea

### Auto-Deploy

```
1. Connect repository
2. Enable "Auto Deploy" in settings
3. Coolify triggers on push to configured branch
```

## Resource Limits

```yaml
# docker-compose.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

## Logs & Monitoring

```
1. Click on resource in dashboard
2. View "Logs" tab for container output
3. "Events" tab for deployment history
4. Use external monitoring (optional)
```

## Best Practices

1. **Separate concerns**: Coolify server vs. app servers
2. **Use environment scoping**: Team → Project → Environment
3. **Configure before deploy**: Set env vars, domains first
4. **Test locally**: Docker Compose works same way
5. **Enable backups**: Especially for databases
6. **Monitor health**: Add health checks to containers
7. **Version pin**: Use specific image tags, not `latest`
