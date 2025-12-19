# Startup & Commands

> Setup, commands, environment, troubleshooting

## Quick Start

```bash
pnpm install              # Install deps
cp .env.example .env      # Create env file
pnpm dev                  # Start dev server → localhost:3000
```

## Commands

| Command | Purpose |
|---------|---------|
| `pnpm dev` | Development server |
| `pnpm build` | Production build |
| `pnpm start` | Run production build |
| `pnpm lint` | Check lint errors |
| `pnpm lint --fix` | Fix lint errors |
| `pnpm test` | Run tests |
| `pnpm test:watch` | Tests in watch mode |
| `pnpm typecheck` | TypeScript check |

## Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `NEXT_PUBLIC_SITE_URL` | Yes | Site URL for SEO |
| `STRAPI_URL` | Yes | Strapi API base URL |
| `STRAPI_TOKEN` | Yes | Strapi API token |
| `MEDUSA_URL` | Yes | Medusa backend URL |
| `MEDUSA_PUBLISHABLE_KEY` | Yes | Medusa public key |

Get values:
- Strapi token: Admin → Settings → API Tokens
- Medusa key: Admin → Settings → Publishable Keys

## Troubleshooting

| Error | Fix |
|-------|-----|
| `ECONNREFUSED` Strapi | Check Strapi is running, verify `STRAPI_URL` |
| `ECONNREFUSED` Medusa | Check Medusa is running, verify `MEDUSA_URL` |
| Env vars undefined | Restart dev server after .env changes |
| `NEXT_PUBLIC_` not working | Must restart, not hot-reload |
| Module not found | `rm -rf node_modules && pnpm install` |
| Type errors after update | `pnpm typecheck`, regenerate types |
| Port in use | `lsof -i :3000` then `kill -9 [PID]` |
| Hydration mismatch | Check Server/Client component boundary |

## Database (if applicable)

```bash
pnpm db:migrate           # Run migrations
pnpm db:seed              # Seed data
pnpm db:reset             # Reset (destructive!)
```

*Updated: YYYY-MM-DD*
