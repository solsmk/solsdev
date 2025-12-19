# Architecture

> Directory structure, data flow, module boundaries

## Directory Map

```
app/                      # Next.js App Router
├── (marketing)/          # Public pages (home, about, blog)
├── (shop)/               # E-commerce (products, cart, checkout)
├── api/                  # API routes (webhooks, auth callbacks)
└── layout.tsx            # Root layout

components/
├── ui/                   # shadcn components (don't modify directly)
├── forms/                # Form components
└── [feature]/            # Feature-specific components

lib/
├── clients/
│   ├── strapi.ts         # Strapi client
│   └── medusa.ts         # Medusa client
├── utils.ts              # Shared utilities
└── constants.ts          # App constants

hooks/                    # Custom React hooks
types/                    # TypeScript types
```

## Data Ownership

| Data Type | Owner | Source of Truth |
|-----------|-------|-----------------|
| Products, pricing, inventory | Medusa | Medusa DB |
| Orders, carts, customers | Medusa | Medusa DB |
| Blog, pages, SEO content | Strapi | Strapi DB |
| Marketing content, media | Strapi | Strapi DB |
| User sessions | Next.js | Cookies |

## Data Flow

| Flow | Path |
|------|------|
| Content → UI | Strapi API → Server Component → render |
| Products → UI | Medusa Store API → Server Component → render |
| Cart actions | Client → Server Action → Medusa API |
| Forms | Client Component → Server Action → Strapi/Medusa |

## Module Boundaries

| Module | Responsibility | Depends On |
|--------|---------------|------------|
| `app/` | Routing, layouts | components, lib |
| `components/` | UI rendering | lib/utils, hooks |
| `lib/clients/` | API communication | types |
| `hooks/` | Shared logic | lib/clients |

## Key Files

| File | Purpose |
|------|---------|
| `lib/clients/strapi.ts` | All Strapi API calls |
| `lib/clients/medusa.ts` | All Medusa API calls |
| `app/api/webhooks/route.ts` | Webhook handlers |
| `middleware.ts` | Auth, redirects |

*Updated: YYYY-MM-DD*
