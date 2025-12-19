---
paths: "**/Dockerfile*", "**/docker-compose*.yml", "**/docker-compose*.yaml", "**/.dockerignore"
---

# Docker Development Rules

*Applied when working with Docker containers*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Docker Docs** | https://docs.docker.com |
| **Node.js Guide** | https://docs.docker.com/guides/nodejs |
| **Compose Reference** | https://docs.docker.com/compose/compose-file |
| **Best Practices** | https://docs.docker.com/develop/develop-images/dockerfile_best-practices |
| **Node Best Practices** | https://github.com/goldbergyoni/nodebestpractices |

## Recommended Base Images

| Image | Size | Use Case |
|-------|------|----------|
| `node:24-alpine` | ~221MB | Latest LTS (2025) |
| `node:22-alpine` | ~180MB | Stable production |
| `node:20-alpine` | ~175MB | Extended support |

**Always pin specific versions:**

```dockerfile
# GOOD - Reproducible
FROM node:24.1.0-alpine

# BAD - Changes unexpectedly
FROM node:latest
FROM node:alpine
```

## Multi-Stage Build Pattern

### Next.js Production Build

```dockerfile
# Stage 1: Dependencies
FROM node:24-alpine AS dependencies
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --frozen-lockfile

# Stage 2: Builder
FROM dependencies AS builder
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# Stage 3: Production Runtime
FROM node:24-alpine AS production
WORKDIR /app

# Security: Non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy standalone build (requires output: 'standalone' in next.config)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### Key Benefits

- 50-70% smaller final image
- Separate build and runtime dependencies
- Layer caching for faster rebuilds
- Production-only dependencies

## Next.js Configuration

```javascript
// next.config.mjs - REQUIRED for standalone
const nextConfig = {
  output: 'standalone',  // Creates .next/standalone
}

export default nextConfig
```

## npm ci vs npm install

| Aspect | npm install | npm ci |
|--------|-------------|--------|
| Modifies lockfile | Yes | No |
| Requires lockfile | No | Yes |
| Deletes node_modules | No | Yes |
| Reproducible | No | Yes |
| Speed in CI | Slower | Faster |

**Always use `npm ci` in Dockerfile:**

```dockerfile
RUN npm ci --frozen-lockfile
```

## Docker Compose for Development

```yaml
# docker-compose.yml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
      - "9229:9229"  # Node debugger
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://user:pass@db:5432/dev
    volumes:
      - .:/app                    # Bind mount for live reload
      - /app/node_modules         # Named volume prevents override
    depends_on:
      db:
        condition: service_healthy
    command: npm run dev

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=dev
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

## Health Checks

### Dockerfile Health Check

```dockerfile
RUN apk add --no-cache curl

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### Next.js Health Endpoint

```typescript
// app/api/health/route.ts
export async function GET() {
  // Optionally check DB, cache, etc.
  return Response.json({ status: 'ok' })
}
```

### For Distroless Images (No curl)

```javascript
// healthcheck.js
import http from 'http'

http.get('http://localhost:3000/health', (res) => {
  process.exit(res.statusCode === 200 ? 0 : 1)
}).on('error', () => process.exit(1))
```

```dockerfile
HEALTHCHECK CMD ["node", "healthcheck.js"]
```

## .dockerignore (Critical!)

```
# Dependencies (prevent host override)
**/node_modules/
npm-debug.log
yarn-error.log

# Version Control
**/.git
**/.gitignore

# Development
**/.vscode
**/.idea
.DS_Store

# Testing
**/coverage
**/*.test.js
**/test

# Environment & Secrets (CRITICAL!)
**/.env
**/.env.*.local
**/.npmrc
**/.aws

# Build artifacts
**/dist
**/.next
**/out

# Documentation
**/README.md
**/*.md
**/docs
```

## Environment Variables

### Build-time vs Runtime

| Type | Available | Example |
|------|-----------|---------|
| ARG | Build only | `ARG BUILD_VERSION` |
| ENV | Build + Runtime | `ENV NODE_ENV=production` |
| Runtime | Container start | `docker run -e KEY=value` |

### Next.js Gotcha: NEXT_PUBLIC_ Variables

```dockerfile
# BAD - Baked into image at build time, can't change per environment
ENV NEXT_PUBLIC_API_URL=https://api.example.com

# The value is frozen in the JavaScript bundle!
```

**Solution: Keep image environment-agnostic:**

```dockerfile
# Don't set NEXT_PUBLIC_ in Dockerfile
# Pass at runtime or use API routes for dynamic config
```

```bash
# Pass at container start
docker run -e NEXT_PUBLIC_API_URL=https://prod.api.com myapp
```

## Security: Non-Root User

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set ownership
COPY --chown=nextjs:nodejs . .

# Switch to non-root
USER nextjs
```

## Critical Gotchas

### 1. node_modules from Host

```dockerfile
# BAD - Copies host node_modules
COPY . .

# GOOD - Install fresh in container
COPY package.json package-lock.json ./
RUN npm ci --frozen-lockfile
COPY . .
```

Also add to .dockerignore: `**/node_modules/`

### 2. Cache Invalidation Order

```dockerfile
# BAD - Any code change invalidates npm install
COPY . .
RUN npm ci

# GOOD - Dependencies cached until package.json changes
COPY package.json package-lock.json ./
RUN npm ci --frozen-lockfile
COPY . .  # Only this layer invalidated on code changes
```

### 3. Alpine Compatibility

```dockerfile
# Some native modules fail on Alpine
# Solution 1: Add libc6-compat
RUN apk add --no-cache libc6-compat

# Solution 2: Use -slim instead of Alpine
FROM node:24-slim
```

### 4. Missing HEALTHCHECK

```
Problem: Docker assumes healthy as long as process runs
Reality: Process may be stuck, accepting bad traffic

Solution: Always add HEALTHCHECK
```

### 5. Running as Root

```
Problem: Container breach = full system compromise
Solution: Always use non-root USER
```

### 6. Next.js Standalone Missing Files

```dockerfile
# Must copy ALL three:
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
```

## Image Size Optimization

```dockerfile
# 1. Use Alpine base
FROM node:24-alpine

# 2. Multi-stage build (don't include build deps)

# 3. Clean npm cache
RUN npm ci --frozen-lockfile && npm cache clean --force

# 4. Prune dev dependencies (if not using standalone)
RUN npm prune --production
```

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `EACCES permission denied` | Check USER directive, file ownership |
| `node_modules` conflicts | Add to .dockerignore, use named volume |
| Build slow (cache misses) | Order COPY statements correctly |
| Image too large | Multi-stage build, Alpine base, prune deps |
| Health check fails | Add curl to image, verify endpoint |
| `Cannot find module` | Check WORKDIR, COPY paths |
| Alpine native module errors | Add libc6-compat or use -slim |

## Development vs Production

```dockerfile
# Dockerfile.dev
FROM node:24-alpine
WORKDIR /app
RUN apk add --no-cache dumb-init
COPY package.json package-lock.json ./
RUN npm install  # Include dev deps
COPY . .
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]
CMD ["npm", "run", "dev"]

# Dockerfile (production)
# Use multi-stage pattern above
```

## Best Practices Summary

1. **Pin versions**: `node:24.1.0-alpine`
2. **Multi-stage builds**: Separate build and runtime
3. **npm ci**: Reproducible installs
4. **Non-root user**: Security requirement
5. **.dockerignore**: Exclude node_modules, .env, .git
6. **Health checks**: Always include
7. **Layer ordering**: Dependencies before source code
8. **Next.js standalone**: Use `output: 'standalone'`
9. **Environment vars**: Don't bake NEXT_PUBLIC_ into image
