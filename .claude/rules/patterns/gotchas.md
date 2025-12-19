# Integration Gotchas

*Cross-stack issues when Medusa v2 + Strapi 5 + Next.js 15/16 work together*

**Note:** Stack-specific gotchas are in the respective stack files. This file covers issues that arise from **integration between systems**.

## Data Ownership Conflicts

### Problem: Duplicate Product Data

**Symptom:** Product info in both Medusa and Strapi, getting out of sync.

**Rule:** Single source of truth per data type.

| Data Type | Owner | Reason |
|-----------|-------|--------|
| Product variants, SKUs | Medusa | Needs inventory tracking |
| Pricing, discounts | Medusa | Needs cart calculations |
| Inventory levels | Medusa | Real-time stock management |
| Marketing descriptions | Strapi | Rich text, SEO, editorial control |
| Product images (gallery) | Strapi | Media library, transformations |
| Blog/editorial content | Strapi | CMS workflow, drafts |

**Solution:** Link via Medusa product ID stored in Strapi:

```typescript
// Strapi content-type: product-content
{
  "medusa_product_id": "prod_01H...",  // Link to Medusa
  "marketing_description": "<rich HTML>",
  "seo": { ... },
  "gallery": [...]  // Additional marketing images
}

// Fetch combined data
const [product, content] = await Promise.all([
  medusa.products.retrieve(productId),
  strapi.get(`/product-contents?filters[medusa_product_id][$eq]=${productId}`)
])
```

## Cart State Hydration

### Problem: SSR Cart Mismatch

**Symptom:** Cart shows wrong items on initial page load, then "flickers" to correct state.

**Cause:** Server renders with stale/no cart data, client hydrates with fresh data.

```tsx
// BAD - Server and client see different data
export default async function Layout({ children }) {
  // Server fetches cart (might be stale or missing)
  const cart = await getServerCart()
  return <CartProvider>{children}</CartProvider>  // Client re-fetches
}
```

**Solution:** Consistent cart fetching with initial state:

```tsx
// GOOD - Pass server cart as initial state
import { cookies } from 'next/headers'

export default async function Layout({ children }) {
  const cookieStore = await cookies()
  const cartId = cookieStore.get('cart_id')?.value
  const initialCart = cartId ? await getCart(cartId) : null

  return (
    <CartProvider initialCart={initialCart}>
      {children}
    </CartProvider>
  )
}

// CartProvider uses initialCart, doesn't re-fetch on mount
```

### Problem: Cart ID Storage

**Symptom:** Cart works in browser, breaks in SSR/Server Components.

**Cause:** Using localStorage (client-only) instead of cookies.

```typescript
// BAD - localStorage not available on server
localStorage.setItem('cart_id', cartId)

// GOOD - Cookies work on both server and client
import Cookies from 'js-cookie'
Cookies.set('cart_id', cartId, { expires: 30 })

// In Server Components
import { cookies } from 'next/headers'
const cartId = (await cookies()).get('cart_id')?.value
```

## API URL Mismatches

### Problem: Strapi Media URLs Broken

**Symptom:** Images show broken icon, URL is `/uploads/image.jpg` without domain.

**Cause:** Strapi returns relative URLs, browser needs absolute URLs.

```typescript
// BAD - Using Strapi response directly
<img src={article.image.url} />  // /uploads/image.jpg - 404!

// GOOD - Prepend Strapi URL
const getMediaUrl = (url: string | null) => {
  if (!url) return null
  if (url.startsWith('http')) return url
  return `${process.env.NEXT_PUBLIC_STRAPI_URL}${url}`
}

<img src={getMediaUrl(article.image?.url)} />
```

### Problem: CORS Errors Between Services

**Symptom:** `Access-Control-Allow-Origin` errors in browser console.

**Cause:** Frontend calling Medusa/Strapi directly without proper CORS config.

**Solutions:**

1. **Configure CORS on backends:**

```typescript
// medusa-config.ts
module.exports = {
  projectConfig: {
    store_cors: process.env.STORE_CORS || "http://localhost:3000",
    admin_cors: process.env.ADMIN_CORS || "http://localhost:3000",
  },
}

// strapi/config/middlewares.ts
module.exports = [
  {
    name: 'strapi::cors',
    config: {
      origin: ['http://localhost:3000', 'https://yoursite.com'],
    },
  },
]
```

2. **Or proxy through Next.js API routes:**

```typescript
// app/api/products/route.ts
export async function GET() {
  // Server-to-server call (no CORS)
  const res = await fetch(`${MEDUSA_URL}/store/products`)
  return Response.json(await res.json())
}
```

## Caching Conflicts

### Problem: Stale Prices After Medusa Update

**Symptom:** Prices in Next.js don't match Medusa admin after update.

**Cause:** Next.js caching fetch results, not revalidating.

**Solution:** Use appropriate cache strategy + tags:

```typescript
// Fetch with revalidation and tags
const products = await fetch(`${MEDUSA_URL}/store/products`, {
  next: {
    revalidate: 60,  // Revalidate every minute
    tags: ['products']
  }
})

// When Medusa updates (via webhook or Server Action):
import { revalidateTag } from 'next/cache'
revalidateTag('products')
```

### Problem: Draft Content Appearing in Production

**Symptom:** Unpublished Strapi content shows on live site.

**Cause:** Using `publicationState=preview` or not filtering properly.

```typescript
// BAD - Shows drafts
const articles = await fetch(`${STRAPI_URL}/api/articles?publicationState=preview`)

// GOOD - Published only (default behavior)
const articles = await fetch(`${STRAPI_URL}/api/articles`)

// Or explicitly:
const articles = await fetch(`${STRAPI_URL}/api/articles?publicationState=live`)
```

## Authentication Flow Issues

### Problem: Auth Token Not Shared Between Systems

**Symptom:** User logged into Strapi but Medusa doesn't recognize them.

**Reality:** Medusa and Strapi have **separate auth systems**. They don't share sessions.

**Solution:** Either:

1. **Separate logins** (simplest) - User has Medusa account for shopping, Strapi account for CMS
2. **Unified auth** - Use external provider (Auth0, Clerk) for both:

```typescript
// Both systems verify same JWT
// Medusa: Custom auth module
// Strapi: Custom auth provider
// Next.js: Stores token, sends to both
```

3. **Medusa as source of truth** - Strapi trusts Medusa JWT (custom middleware)

## Webhook Coordination

### Problem: Inventory Updated, Strapi Content Stale

**Symptom:** Product marked out-of-stock in Medusa, but Strapi still shows it.

**Solution:** Webhook from Medusa → Next.js revalidation:

```typescript
// app/api/webhooks/medusa/route.ts
export async function POST(req: Request) {
  const event = await req.json()

  if (event.type === 'product.updated') {
    revalidateTag('products')
  }

  if (event.type === 'inventory-item.updated') {
    revalidateTag('inventory')
  }

  return Response.json({ received: true })
}
```

### Problem: Strapi Content Updated, Next.js Still Cached

**Solution:** Webhook from Strapi → Next.js revalidation:

```typescript
// app/api/webhooks/strapi/route.ts
import crypto from 'crypto'

export async function POST(req: Request) {
  // Verify signature first!
  const signature = req.headers.get('x-strapi-signature')
  const body = await req.text()

  const hash = crypto
    .createHmac('sha256', process.env.STRAPI_WEBHOOK_SECRET!)
    .update(body)
    .digest('hex')

  if (signature !== hash) {
    return Response.json({ error: 'Invalid signature' }, { status: 401 })
  }

  const event = JSON.parse(body)

  if (event.model === 'article') {
    revalidateTag('articles')
  }

  return Response.json({ received: true })
}
```

## Environment Variable Confusion

### Problem: Wrong ENV Vars in Wrong Places

**Common mistakes:**

```bash
# WRONG - Exposing secrets to browser
NEXT_PUBLIC_STRAPI_TOKEN=secret123  # ❌ Visible in client bundle!
NEXT_PUBLIC_MEDUSA_SECRET=key456    # ❌ Anyone can see this!

# CORRECT - Server-only secrets (no NEXT_PUBLIC_ prefix)
STRAPI_API_TOKEN=secret123          # ✅ Server only
MEDUSA_BACKEND_URL=http://...       # ✅ Server only

# CORRECT - Public URLs (safe to expose)
NEXT_PUBLIC_STRAPI_URL=https://cms.example.com  # ✅ Just the URL
NEXT_PUBLIC_MEDUSA_URL=https://api.example.com  # ✅ Just the URL
```

**Rule:**
- `NEXT_PUBLIC_*` = Safe to expose (URLs, public keys)
- No prefix = Server-only (tokens, secrets, internal URLs)

## Common Error → Fix Reference

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `CORS error` on fetch | Direct browser→backend call | Add CORS config or proxy via Next.js API |
| `404` on Strapi image | Relative URL used directly | Prepend `STRAPI_URL` to media paths |
| Cart empty after refresh | Using localStorage for cart ID | Use cookies instead |
| Prices don't update | Next.js caching | Add `revalidate` or use `revalidateTag()` |
| Draft content showing | Using `publicationState=preview` | Remove or set to `live` |
| `params.id undefined` | Next.js 15+ async params | `const { id } = await params` |
| `cookies is not a function` | Next.js 15+ async cookies | `const c = await cookies()` |
| Hydration mismatch | Server/client render different data | Pass server data as initial props |
| Auth not working across systems | Medusa/Strapi have separate auth | Use unified auth provider or accept separate logins |
