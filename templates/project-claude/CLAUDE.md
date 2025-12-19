# [PROJECT_NAME]

> [One-line description of what this project does]

## Commands

```bash
dev:   pnpm dev          # Start development server
test:  pnpm test         # Run tests
build: pnpm build        # Production build
lint:  pnpm lint --fix   # Fix lint issues
```

## Critical Rules

- **Git:** Feature branches only. Never push to main.
- **DB:** Ask before destructive operations (DROP, DELETE, TRUNCATE)
- **Secrets:** Never commit .env files

## Stack Quick Ref

| Layer | Tech | Docs |
|-------|------|------|
| Frontend | Next.js 15 | nextjs.org/docs |
| CMS | Strapi 5 | docs.strapi.io |
| Commerce | Medusa v2 | docs.medusajs.com |
| UI | shadcn/ui | ui.shadcn.com |
| Styling | Tailwind v4 | tailwindcss.com |

## Documentation

Read on-demand from `.claude/`:

| File | When to Read |
|------|--------------|
| STACK.md | Checking versions, adding dependencies |
| ARCHITECTURE.md | Understanding structure, adding features |
| PATTERNS.md | Writing new code, reviewing patterns |
| STARTUP.md | Setup issues, running commands |
| GOTCHAS.md | Debugging, unexpected behavior |
| DECISIONS.md | Understanding past choices |

## Entry Points

| Path | Purpose |
|------|---------|
| `app/` | Next.js routes |
| `components/ui/` | shadcn components |
| `lib/` | Utilities, clients |
| `types/` | TypeScript types |
