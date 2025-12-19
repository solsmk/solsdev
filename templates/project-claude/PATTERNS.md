# Code Patterns

> Reference existing code. Don't embed examples here.

## Pattern Index

| Pattern | Reference File | Notes |
|---------|---------------|-------|
| Strapi fetch | `lib/clients/strapi.ts:getArticles` | ISR, error handling |
| Medusa cart | `lib/clients/medusa.ts:addToCart` | Cookie-based cart ID |
| Server Component | `app/(shop)/products/page.tsx` | Async data fetch |
| Client Component | `components/cart/AddToCartButton.tsx` | 'use client', hooks |
| Form with Zod | `components/forms/ContactForm.tsx` | react-hook-form + zod |
| Server Action | `app/actions/cart.ts` | 'use server' mutations |

## Conventions

| Area | Convention |
|------|------------|
| File naming | kebab-case (`product-card.tsx`) |
| Component naming | PascalCase (`ProductCard`) |
| Hook naming | `use` prefix (`useCart`) |
| Type files | `types/[domain].ts` |
| Client file | `components/[feature]/client.tsx` for client-only |

## Server vs Client

| Use Server Component | Use Client Component |
|---------------------|---------------------|
| Data fetching | useState, useEffect |
| No interactivity | Event handlers (onClick) |
| Access secrets | Browser APIs |
| SEO content | Forms with validation |

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Fetch in Client Component | Fetch in Server Component, pass props |
| `localStorage` for cart | Cookies (SSR compatible) |
| Inline Strapi URL | `lib/clients/strapi.ts` |
| Raw `<button>` | `<Button>` from shadcn |
| Direct style overrides | Tailwind variants, cn() |

## Adding New Patterns

When introducing a new pattern:
1. Implement in one place first
2. Add reference to this file
3. Point to `file:function` or `file:line`

*Updated: YYYY-MM-DD*
