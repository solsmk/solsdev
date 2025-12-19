---
paths: "**/app/**/*", "**/*.tsx", "**/*.jsx", "**/components/**/*", "**/lib/**/*", "**/next.config.*"
---

# Next.js 15/16 App Router Rules

*Applied when working with Next.js frontend files*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://nextjs.org/docs |
| **Blog/Releases** | https://nextjs.org/blog |
| **v15 Migration** | https://nextjs.org/docs/app/building-your-application/upgrading/version-15 |
| **Caching Docs** | https://nextjs.org/docs/app/building-your-application/caching |
| **GitHub Releases** | https://github.com/vercel/next.js/releases |
| **API Reference** | https://nextjs.org/docs/app/api-reference |

## Version Info

- **Current Stable**: Next.js 16.x
- **Minimum Node.js**: 20.9+ (18.x dropped in v16)
- **React Version**: 19+ required
- **TypeScript**: 5.1+ minimum

## Critical Breaking Changes (v14 → v15/16)

### 1. Async Request APIs (BREAKING)

**All dynamic APIs are now async - you MUST await them:**

```typescript
// OLD (v14) - These NO LONGER WORK
export default function Page({ params, searchParams }) {
  const id = params.id                    // ❌ ERROR
  const query = searchParams.q            // ❌ ERROR
  const cookieStore = cookies()           // ❌ ERROR
  const headersList = headers()           // ❌ ERROR
}

// NEW (v15/16) - Must await or use React.use()
export default async function Page({
  params,
  searchParams
}: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ q?: string }>
}) {
  const { id } = await params              // ✅ CORRECT
  const { q } = await searchParams         // ✅ CORRECT
  const cookieStore = await cookies()      // ✅ CORRECT
  const headersList = await headers()      // ✅ CORRECT
}

// Client Components - use React.use() hook
'use client'
import { use } from 'react'

export default function ClientPage({
  params
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = use(params)  // ✅ Unwrap promise in client component
}
```

### 2. Caching is OFF by Default (BREAKING)

**v14**: fetch() cached by default
**v15/16**: fetch() NOT cached by default - must opt-in explicitly

```typescript
// v15/16 - Default behavior is NO CACHE
const data = await fetch(url)  // ❌ Not cached, always fresh

// Explicit caching options:
await fetch(url, { cache: 'force-cache' })        // ✅ Cached indefinitely
await fetch(url, { cache: 'no-store' })           // ✅ Never cached (explicit)
await fetch(url, { next: { revalidate: 3600 } })  // ✅ ISR - revalidate hourly
await fetch(url, { next: { tags: ['products'] }}) // ✅ Tag-based revalidation
```

### 3. Route Handlers Not Cached by Default

```typescript
// v14: GET handlers cached by default
// v15/16: NOT cached - must opt-in

// To enable caching:
export const dynamic = 'force-static'

export async function GET() {
  // Now this is cached
}
```

### 4. Client Router Cache Changed

Page segments no longer cached during navigation. To restore old behavior:

```typescript
// next.config.ts
const nextConfig = {
  experimental: {
    staleTimes: {
      dynamic: 30,   // seconds
      static: 180,   // seconds
    },
  },
}
```

## Architecture Overview

```
app/
├── layout.tsx              # Root layout (Server Component)
├── page.tsx                # Home page
├── globals.css
├── (marketing)/            # Route group (no URL impact)
│   ├── layout.tsx
│   └── about/page.tsx
├── (shop)/                 # Another route group
│   ├── layout.tsx
│   ├── products/
│   │   ├── page.tsx
│   │   ├── [id]/
│   │   │   ├── page.tsx
│   │   │   └── loading.tsx
│   │   └── error.tsx
│   └── cart/page.tsx
├── api/                    # API routes
│   └── [...]/route.ts
└── @modal/                 # Parallel route (requires default.tsx!)
    └── default.tsx         # REQUIRED in v16

components/                 # Shared components
lib/                        # Utilities
```

## Server vs Client Components

### Decision Matrix

| Need | Component | Directive |
|------|-----------|-----------|
| Fetch data directly | Server | (none - default) |
| Access database/backend | Server | (none) |
| Use env secrets | Server | (none) |
| Reduce JS bundle | Server | (none) |
| Use hooks (useState, useEffect) | Client | `'use client'` |
| Event handlers (onClick) | Client | `'use client'` |
| Browser APIs (localStorage) | Client | `'use client'` |
| Use context providers | Client | `'use client'` |

### Pattern: Server Component with Client Islands

```tsx
// app/products/[id]/page.tsx (Server Component)
export default async function ProductPage({
  params
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)  // Server-side fetch

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      {/* Client island for interactivity */}
      <AddToCartButton productId={id} />
    </div>
  )
}

// components/AddToCartButton.tsx (Client Component)
'use client'

import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)

  return (
    <button
      onClick={() => handleAddToCart(productId)}
      disabled={loading}
    >
      Add to Cart
    </button>
  )
}
```

## Next.js 16: Cache Components

New `'use cache'` directive for fine-grained caching:

```typescript
// next.config.ts
const nextConfig = {
  cacheComponents: true,  // Enable cache components
  cacheLife: {
    blog: {
      stale: 3600,      // 1 hour client cache
      revalidate: 900,  // 15 min server revalidation
      expire: 86400,    // 1 day max stale
    },
    products: {
      stale: 300,
      revalidate: 60,
      expire: 3600,
    },
  },
}

// Usage in components/functions
export async function getCachedProducts() {
  'use cache'
  cacheLife('products')  // Use predefined profile

  const products = await fetch('/api/products')
  return products.json()
}
```

## Server Actions

```typescript
// app/actions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

export async function createProduct(formData: FormData) {
  const title = formData.get('title') as string

  // Direct database/API call
  await db.products.create({ title })

  // Revalidate cached data
  revalidatePath('/products')
  revalidateTag('products')
}

export async function updateProduct(id: string, formData: FormData) {
  await db.products.update(id, {
    title: formData.get('title'),
  })

  revalidatePath(`/products/${id}`)
}

// Usage with form
// app/products/new/page.tsx
import { createProduct } from '@/app/actions'

export default function NewProductPage() {
  return (
    <form action={createProduct}>
      <input name="title" required />
      <button type="submit">Create</button>
    </form>
  )
}
```

### useActionState (replaces useFormState)

```tsx
'use client'

import { useActionState } from 'react'
import { createProduct } from '@/app/actions'

export function ProductForm() {
  const [state, formAction, pending] = useActionState(createProduct, null)

  return (
    <form action={formAction}>
      <input name="title" />
      <button disabled={pending}>
        {pending ? 'Creating...' : 'Create'}
      </button>
      {state?.error && <p>{state.error}</p>}
    </form>
  )
}
```

## Next.js 16: proxy.ts (replaces middleware.ts)

```typescript
// proxy.ts (at project root)
import { NextRequest, NextResponse } from 'next/server'

export function proxy(request: NextRequest) {
  // Check authentication
  const token = request.cookies.get('token')

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
}
```

**Key differences from middleware.ts:**
- Renamed function: `middleware()` → `proxy()`
- Defaults to Node.js runtime (not Edge)
- Clearer naming for network boundary operations

## Dynamic Routes

```tsx
// app/products/[id]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>  // Now a Promise!
}) {
  const { id } = await params
  const product = await getProduct(id)

  return <ProductDetail product={product} />
}

// Generate static params at build time
export async function generateStaticParams() {
  const products = await getProducts()
  return products.map((product) => ({ id: product.id }))
}

// Dynamic metadata
export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  return {
    title: product.name,
    description: product.description,
  }
}
```

## Loading & Error States

```tsx
// app/products/loading.tsx
export default function Loading() {
  return <ProductsSkeleton />
}

// app/products/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}

// app/products/not-found.tsx
export default function NotFound() {
  return <h2>Product not found</h2>
}
```

## Parallel Routes (v16 requires default.tsx)

```tsx
// app/layout.tsx
export default function Layout({
  children,
  modal,  // Parallel route slot
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      {children}
      {modal}
    </>
  )
}

// app/@modal/default.tsx - REQUIRED in v16!
export default function Default() {
  return null
}

// app/@modal/[id]/page.tsx
export default async function ProductModal({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  return <Modal><ProductQuickView id={id} /></Modal>
}
```

## Turbopack (Now Default in v16)

```bash
# Development with Turbopack (default in v16)
next dev

# Production build with Turbopack
next build --turbopack

# Enable file system caching (beta)
next dev --experimental-turbo-cache
```

Performance improvements:
- 2-5× faster builds
- Up to 10× faster Fast Refresh
- Disk caching for faster restarts

## Integration with Medusa & Strapi

### Fetching Patterns

```typescript
// lib/medusa.ts
const MEDUSA_URL = process.env.MEDUSA_BACKEND_URL

export async function getProducts(regionId: string) {
  const res = await fetch(
    `${MEDUSA_URL}/store/products?region_id=${regionId}`,
    { next: { revalidate: 60, tags: ['products'] } }
  )
  return res.json()
}

export async function getCart(cartId: string) {
  // Carts should NOT be cached
  const res = await fetch(
    `${MEDUSA_URL}/store/carts/${cartId}`,
    { cache: 'no-store' }
  )
  return res.json()
}

// lib/strapi.ts
const STRAPI_URL = process.env.STRAPI_URL

export async function getArticles() {
  const res = await fetch(
    `${STRAPI_URL}/api/articles?populate=*`,
    { next: { revalidate: 60, tags: ['articles'] } }
  )
  return res.json()
}
```

### Server-Side Cart Access

```typescript
// lib/cart.ts
import { cookies } from 'next/headers'

export async function getServerCart() {
  const cookieStore = await cookies()  // Must await in v15/16!
  const cartId = cookieStore.get('cart_id')?.value

  if (!cartId) return null
  return getCart(cartId)
}
```

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `params.id is not defined` | Not awaiting params | `const { id } = await params` |
| `cookies is not a function` | Not awaiting cookies() | `const c = await cookies()` |
| `Hydration mismatch` | Server/client render differently | Ensure consistent initial state |
| `'use client' in server component` | Wrong directive placement | Move to top of file, before imports |
| `Cannot read property of undefined` | Data not populated | Check Strapi/Medusa populate params |
| `NEXT_NOT_FOUND` | Route not matching | Check file structure, dynamic segments |
| `fetch failed` | Wrong cache config | Check cache/revalidate options |

## Quick Reference

### Caching Decision

```
Is the data user-specific?
  → YES: cache: 'no-store' (carts, user data)
  → NO: Does it change frequently?
    → YES: next: { revalidate: 60 } (products, prices)
    → NO: cache: 'force-cache' or 'use cache' (static content)
```

### Component Decision

```
Does it need interactivity (clicks, state)?
  → YES: 'use client'
  → NO: Does it fetch data?
    → YES: Keep as Server Component (async)
    → NO: Can be either (prefer Server for smaller bundle)
```
