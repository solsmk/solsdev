# Gotchas

> Known issues, workarounds, quirks. Error → Fix format.

## Strapi

| Issue | Fix |
|-------|-----|
| Relations return `null` | Add `?populate=*` or `?populate=relation_name` |
| Media URLs are relative | Prepend `STRAPI_URL` to media paths |
| Draft content not showing | Use `?publicationState=preview` (requires auth) |
| Filters not working | Check syntax: `?filters[field][$eq]=value` |

## Medusa

| Issue | Fix |
|-------|-----|
| Cart empty after refresh | Cart ID must be in cookies, not localStorage |
| Prices showing $0 | Cart needs region: `createCart({ region_id })` |
| Relations not included | Add `?expand=items,items.variant` |
| Webhook not firing | Check Medusa admin → Settings → Webhooks |

## Next.js 15

| Issue | Fix |
|-------|-----|
| `params` is undefined | Must `await params` in page components |
| `cookies()` error | Must `await cookies()` (async in Next 15) |
| Caching unexpected | Default is NO cache. Add `revalidate` explicitly |
| Hydration mismatch | Check date/time rendering, use `suppressHydrationWarning` |

## Tailwind v4

| Issue | Fix |
|-------|-----|
| Classes not applying | Check `@import "tailwindcss"` in CSS |
| `@apply` not working | v4 uses CSS-native, check migration guide |
| Colors look wrong | v4 uses OKLCH, not hex |

## shadcn/ui

| Issue | Fix |
|-------|-----|
| Component not found | Run `npx shadcn@latest add [component]` |
| Styles not applying | Check `components.json` paths |
| Theme not working | Verify CSS variables in `globals.css` |

## TypeScript

| Issue | Fix |
|-------|-----|
| Type not exported | Check `types/index.ts` exports |
| Generic errors | Restart TS server: Cmd+Shift+P → Restart TS |

## Add New Gotchas

When you discover a gotcha:
1. Add to appropriate section above
2. Use `Issue | Fix` table format
3. Keep fixes actionable (what to do, not why)

*Updated: YYYY-MM-DD*
