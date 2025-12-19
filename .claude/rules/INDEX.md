# SolsDev Rules Index

*Quick reference for AI agents - scan this first, read what's relevant*

## Core Stack Rules

| Rule | When to Read | Key Topics |
|------|--------------|------------|
| [stacks/medusa-v2.md](stacks/medusa-v2.md) | Working with `**/medusa/**`, `**/modules/**/*.ts`, `**/workflows/**` | 18 commerce modules, workflow pattern with rollback, container DI, event system, API routes |
| [stacks/strapi-5.md](stacks/strapi-5.md) | Working with `**/strapi/**`, `**/cms/**`, `**/content-types/**` | Document Service API, documentId (not numeric id), population syntax, lifecycle hooks |
| [stacks/nextjs-15.md](stacks/nextjs-15.md) | Working with `**/app/**`, `**/*.tsx`, `**/components/**` | Async APIs (await params/cookies), caching OFF by default, Server vs Client components |

## UI & Styling Rules

| Rule | When to Read | Key Topics |
|------|--------------|------------|
| [stacks/shadcn-ui.md](stacks/shadcn-ui.md) | Working with `**/components/ui/**`, `components.json` | Copy-paste components, CLI commands, theming with CSS variables, cn() utility |
| [stacks/heroui.md](stacks/heroui.md) | Working with `**/@heroui/**`, HeroUI components | Formerly NextUI, compound components, React Aria accessibility, Framer animations |
| [stacks/tailwind-v4.md](stacks/tailwind-v4.md) | Working with `**/*.css`, Tailwind classes | CSS-first config, v4 breaking changes, container queries, 3D transforms |

## Infrastructure Rules

| Rule | When to Read | Key Topics |
|------|--------------|------------|
| [stacks/meilisearch.md](stacks/meilisearch.md) | Working with `**/search/**`, search functionality | JS SDK, index configuration, filter syntax, faceting, Medusa/Strapi integration |
| [stacks/coolify.md](stacks/coolify.md) | Working with `docker-compose*.yml`, deployments | Self-hosted PaaS, build packs, environment variables, database provisioning |
| [stacks/docker.md](stacks/docker.md) | Working with `Dockerfile*`, `.dockerignore` | Multi-stage builds, npm ci, health checks, non-root user, Next.js standalone |

## Pattern Rules

| Rule | When to Read | Key Topics |
|------|--------------|------------|
| [patterns/architecture.md](patterns/architecture.md) | Building cross-stack services, adapters, middleware | Interface-driven dev, abstract classes, DI patterns, Adapter pattern, testing with mocks |
| [patterns/cart-checkout.md](patterns/cart-checkout.md) | Implementing cart, checkout, or payment flows | Cart state management, SSR hydration, payment sessions, order completion |
| [patterns/cms-integration.md](patterns/cms-integration.md) | Fetching content from Strapi for Next.js | Strapi client setup, media URL handling, caching strategies, revalidation |
| [patterns/gotchas.md](patterns/gotchas.md) | Debugging cross-stack issues, integration problems | Data ownership, cart hydration, CORS, caching conflicts, auth flow, webhooks |

## Quick Decision Trees

### Which Stack Owns What?

```
Product/pricing/inventory data? → Medusa
Marketing content/blog/SEO?     → Strapi
Rendering/routing/caching?      → Next.js
Search indexing?                → Meilisearch
Deployments?                    → Coolify + Docker
```

### Which UI Library?

```
Need full code ownership?       → shadcn/ui (copy-paste)
Need batteries-included?        → HeroUI (package)
Custom design system?           → Tailwind CSS directly
```

### Common Error → Which Rule?

| Error | Read |
|-------|------|
| `params.id undefined` | nextjs-15.md (async APIs) |
| `cookies is not a function` | nextjs-15.md (async APIs) |
| Relations not populated | strapi-5.md (population) or medusa-v2.md (relations) |
| Cart empty after refresh | gotchas.md (cart hydration) |
| Prices not updating | gotchas.md (caching) or nextjs-15.md (revalidation) |
| CORS errors | gotchas.md (API URLs) |
| Media URLs broken (404) | strapi-5.md (media handling) or gotchas.md |
| Workflow step failed | medusa-v2.md (workflows with compensation) |
| Styles not applying | tailwind-v4.md (purging, content paths) |
| Component hydration mismatch | shadcn-ui.md or heroui.md (client/server) |
| Search filter returns empty | meilisearch.md (filter type syntax) |
| Docker build fails | docker.md (multi-stage, cache order) |
| Deploy fails on Coolify | coolify.md (build packs, env vars) |

## Documentation Links (When Rules Are Outdated)

### Official Docs

| Stack | Primary Docs | API Reference |
|-------|--------------|---------------|
| **Medusa v2** | [docs.medusajs.com/v2](https://docs.medusajs.com/v2) | [Admin API](https://docs.medusajs.com/api/admin) / [Store API](https://docs.medusajs.com/api/store) |
| **Strapi 5** | [docs.strapi.io/dev-docs](https://docs.strapi.io/dev-docs) | [Document Service](https://docs.strapi.io/dev-docs/api/document-service) |
| **Next.js 15/16** | [nextjs.org/docs](https://nextjs.org/docs) | [App Router API](https://nextjs.org/docs/app/api-reference) |
| **shadcn/ui** | [ui.shadcn.com/docs](https://ui.shadcn.com/docs) | [CLI](https://ui.shadcn.com/docs/cli) / [Theming](https://ui.shadcn.com/docs/theming) |
| **HeroUI** | [heroui.com/docs](https://www.heroui.com/docs) | [Components](https://www.heroui.com/docs/components) |
| **Tailwind v4** | [tailwindcss.com/docs](https://tailwindcss.com/docs) | [Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide) |
| **Meilisearch** | [meilisearch.com/docs](https://www.meilisearch.com/docs) | [Settings API](https://www.meilisearch.com/docs/reference/api/settings) |
| **Coolify** | [coolify.io/docs](https://coolify.io/docs) | [Environment Variables](https://coolify.io/docs/knowledge-base/environment-variables) |
| **Docker** | [docs.docker.com](https://docs.docker.com) | [Node.js Guide](https://docs.docker.com/guides/nodejs) |

### MCP Servers (AI Integration)

| Stack | Recommended Server | Notes |
|-------|-------------------|-------|
| **Medusa** | [SGFGOV/medusa-mcp](https://github.com/SGFGOV/medusa-mcp) | Most mature, 48+ stars |
| **Strapi** | [misterboe/strapi-mcp-server](https://github.com/misterboe/strapi-mcp-server) | v4+v5 support |
| **Next.js** | Built-in DevTools MCP (v16) | Bundled with Next.js 16 |
| **shadcn** | Built-in MCP server | Component registry search |

## Reading Strategy

1. **Start here** - Scan this INDEX for relevant rules
2. **Read stack rule** - If working in that stack's files
3. **Read pattern rule** - If implementing that specific pattern
4. **Check gotchas.md** - When debugging integration issues
5. **Check official docs** - When rules seem outdated or you need latest API details

## Directory Structure

```
.claude/rules/
├── INDEX.md              ← You are here
├── README.md             ← How rules work
├── stacks/
│   ├── medusa-v2.md      # E-commerce engine
│   ├── strapi-5.md       # Headless CMS
│   ├── nextjs-15.md      # React framework
│   ├── shadcn-ui.md      # UI components (copy-paste)
│   ├── heroui.md         # UI components (package)
│   ├── tailwind-v4.md    # CSS framework
│   ├── meilisearch.md    # Search engine
│   ├── coolify.md        # Self-hosted PaaS
│   └── docker.md         # Containerization
└── patterns/
    ├── cart-checkout.md  # Commerce flows
    ├── cms-integration.md # Content patterns
    └── gotchas.md        # Integration issues
```

## For AI Agents: Improving These Rules

See [CONTRIBUTING.md](CONTRIBUTING.md) for standards when adding or updating rules.

Key principles:
- **Research first** - Web search for latest versions before writing
- **Tables over prose** - Scannable beats readable
- **Show code** - BAD/GOOD examples with explanations
- **Link to docs** - Rules get outdated, official docs don't
- **Update INDEX.md** - Every new rule gets indexed

*Last updated: 2025-12-14*
