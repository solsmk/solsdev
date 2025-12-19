# SolsDev Rules

*Path-scoped rules for AI agents working on Medusa v2 + Strapi 5 + Next.js 15/16 stacks*

**Start here:** [INDEX.md](INDEX.md) - Quick reference with links, descriptions, and decision trees.

## How Rules Work

Claude Code automatically loads rules from `.claude/rules/` when working with files that match the `paths:` pattern in the rule's frontmatter.

```markdown
---
paths: src/modules/**/*.ts, packages/medusa/**/*.ts
---

# Rule content applied when editing matching files
```

## Directory Structure

```
.claude/rules/
├── README.md              # This file
├── stacks/                # Technology-specific rules
│   ├── medusa-v2.md       # Medusa v2 e-commerce engine
│   ├── strapi-5.md        # Strapi 5 headless CMS
│   └── nextjs-15.md       # Next.js 15/16 App Router
└── patterns/              # Integration patterns
    ├── cart-checkout.md   # Cart and checkout flows
    ├── cms-integration.md # CMS content patterns
    └── gotchas.md         # Integration gotchas (cross-stack issues)
```

## Rule Activation

Rules activate automatically when Claude works with files matching the `paths:` pattern:

| Rule | Activates For |
|------|---------------|
| `medusa-v2.md` | `**/medusa/**/*`, `**/modules/**/*.ts`, `**/workflows/**/*` |
| `strapi-5.md` | `**/strapi/**/*`, `**/cms/**/*`, `**/content-types/**/*` |
| `nextjs-15.md` | `**/app/**/*`, `**/*.tsx`, `**/components/**/*` |
| `cart-checkout.md` | `**/cart/**/*`, `**/checkout/**/*` |
| `cms-integration.md` | `**/content/**/*`, `**/strapi/**/*` |
| `gotchas.md` | Always available (integration issues) |

## Quick Reference: What Each Stack Owns

| System | Owns | Does NOT Own |
|--------|------|--------------|
| **Medusa** | Products, variants, pricing, inventory, carts, orders, payments, customers | Marketing content, blog, SEO |
| **Strapi** | Marketing content, blog, pages, rich descriptions, SEO, editorial | Commerce data, pricing, orders |
| **Next.js** | Rendering, routing, SSR/SSG, client interactions, caching strategy | Business data (fetches from Medusa/Strapi) |

## Documentation Links (When Rules Change)

### Medusa v2
- Docs: https://docs.medusajs.com/v2
- API: https://docs.medusajs.com/api/admin | https://docs.medusajs.com/api/store
- GitHub: https://github.com/medusajs/medusa

### Strapi 5
- Docs: https://docs.strapi.io/dev-docs
- API: https://docs.strapi.io/dev-docs/api/document-service
- GitHub: https://github.com/strapi/strapi

### Next.js 15/16
- Docs: https://nextjs.org/docs
- Caching: https://nextjs.org/docs/app/building-your-application/caching
- GitHub: https://github.com/vercel/next.js/releases

## MCP Servers Available

| Stack | MCP Server | Purpose |
|-------|------------|---------|
| Medusa | `SGFGOV/medusa-mcp` | Commerce operations via AI |
| Strapi | `misterboe/strapi-mcp-server` | Content management via AI |
| Next.js | Built-in DevTools MCP (v16) | AI-assisted debugging |

## Adding Custom Rules

Create a new `.md` file in the appropriate directory:

```markdown
---
paths: src/custom/**/*.ts
---

# Your Rule Name

Rule content here...
```

## For AI Agents

These rules are optimized for AI consumption:
- **Tables** for quick scanning
- **Code examples** ready to copy/adapt
- **Decision trees** for common choices
- **Error → Fix** mappings
- **Documentation links** when things change

When in doubt, check the official docs (links in each rule file).
