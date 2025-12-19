---
paths: "**/content/**/*", "**/strapi/**/*", "**/blog/**/*", "**/pages/**/*"
---

# CMS Integration Patterns

*Applied when working with Strapi content in Next.js*

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js App   │◄───│  Strapi CMS     │    │   Medusa        │
│   (Frontend)    │    │  (Content)      │    │   (Commerce)    │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │  Content + Commerce   │
                    │  Product descriptions │
                    │  Marketing content    │
                    │  Blog + SEO pages     │
                    └───────────────────────┘
```

## Strapi Client

```typescript
// lib/strapi.ts
const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337'
const STRAPI_TOKEN = process.env.STRAPI_API_TOKEN

interface StrapiResponse<T> {
  data: T
  meta: {
    pagination?: {
      page: number
      pageSize: number
      pageCount: number
      total: number
    }
  }
}

interface StrapiEntity<T> {
  id: number
  attributes: T
}

async function fetchStrapi<T>(
  endpoint: string,
  options: {
    populate?: string | string[] | object
    filters?: object
    sort?: string[]
    pagination?: { page?: number; pageSize?: number }
    revalidate?: number
  } = {}
): Promise<StrapiResponse<T>> {
  const searchParams = new URLSearchParams()

  // Handle populate
  if (options.populate) {
    if (typeof options.populate === 'string') {
      searchParams.set('populate', options.populate)
    } else if (Array.isArray(options.populate)) {
      options.populate.forEach((p) => searchParams.append('populate', p))
    } else {
      searchParams.set('populate', JSON.stringify(options.populate))
    }
  }

  // Handle filters
  if (options.filters) {
    Object.entries(flattenFilters(options.filters)).forEach(([key, value]) => {
      searchParams.set(key, String(value))
    })
  }

  // Handle sort
  if (options.sort) {
    options.sort.forEach((s) => searchParams.append('sort', s))
  }

  // Handle pagination
  if (options.pagination) {
    if (options.pagination.page) {
      searchParams.set('pagination[page]', String(options.pagination.page))
    }
    if (options.pagination.pageSize) {
      searchParams.set('pagination[pageSize]', String(options.pagination.pageSize))
    }
  }

  const url = `${STRAPI_URL}/api${endpoint}?${searchParams}`

  const response = await fetch(url, {
    headers: STRAPI_TOKEN
      ? { Authorization: `Bearer ${STRAPI_TOKEN}` }
      : {},
    next: { revalidate: options.revalidate ?? 60 },
  })

  if (!response.ok) {
    throw new Error(`Strapi fetch failed: ${response.statusText}`)
  }

  return response.json()
}

// Helper to flatten nested filter objects
function flattenFilters(obj: object, prefix = 'filters'): Record<string, string> {
  const result: Record<string, string> = {}

  for (const [key, value] of Object.entries(obj)) {
    const newKey = `${prefix}[${key}]`
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      Object.assign(result, flattenFilters(value, newKey))
    } else {
      result[newKey] = String(value)
    }
  }

  return result
}
```

## Content Types

### Articles/Blog

```typescript
// types/strapi.ts
interface Article {
  title: string
  slug: string
  content: string // Rich text
  excerpt: string
  publishedAt: string
  image: StrapiMedia
  author: StrapiRelation<Author>
  categories: StrapiRelation<Category[]>
  seo: SEOComponent
}

interface Author {
  name: string
  bio: string
  avatar: StrapiMedia
}

interface Category {
  name: string
  slug: string
}

interface SEOComponent {
  metaTitle: string
  metaDescription: string
  keywords: string
  canonicalURL: string
  ogImage: StrapiMedia
}

// lib/strapi.ts
export async function getArticles(options?: {
  page?: number
  pageSize?: number
  category?: string
}) {
  return fetchStrapi<StrapiEntity<Article>[]>('/articles', {
    populate: ['image', 'author.avatar', 'categories', 'seo.ogImage'],
    filters: options?.category
      ? { categories: { slug: { $eq: options.category } } }
      : undefined,
    pagination: { page: options?.page, pageSize: options?.pageSize },
    sort: ['publishedAt:desc'],
    revalidate: 60, // ISR: 1 minute
  })
}

export async function getArticleBySlug(slug: string) {
  const response = await fetchStrapi<StrapiEntity<Article>[]>('/articles', {
    filters: { slug: { $eq: slug } },
    populate: ['image', 'author.avatar', 'categories', 'seo.ogImage'],
    revalidate: 60,
  })

  return response.data[0] ?? null
}
```

### Pages (Dynamic)

```typescript
// types/strapi.ts
interface Page {
  title: string
  slug: string
  content: DynamicZone[]
  seo: SEOComponent
}

type DynamicZone =
  | { __component: 'blocks.hero'; title: string; subtitle: string; image: StrapiMedia }
  | { __component: 'blocks.text'; content: string }
  | { __component: 'blocks.cta'; text: string; link: string; variant: 'primary' | 'secondary' }
  | { __component: 'blocks.products'; title: string; productIds: string[] }

// lib/strapi.ts
export async function getPage(slug: string) {
  const response = await fetchStrapi<StrapiEntity<Page>[]>('/pages', {
    filters: { slug: { $eq: slug } },
    populate: {
      content: {
        populate: '*',
      },
      seo: {
        populate: ['ogImage'],
      },
    },
    revalidate: 300, // 5 minutes for pages
  })

  return response.data[0] ?? null
}
```

## Rendering Patterns

### Dynamic Zone Renderer

```tsx
// components/dynamic-zone.tsx
import { Hero, TextBlock, CTA, ProductGrid } from './blocks'

const BLOCK_COMPONENTS = {
  'blocks.hero': Hero,
  'blocks.text': TextBlock,
  'blocks.cta': CTA,
  'blocks.products': ProductGrid,
}

export function DynamicZone({ content }: { content: DynamicZone[] }) {
  return (
    <>
      {content.map((block, index) => {
        const Component = BLOCK_COMPONENTS[block.__component]
        if (!Component) {
          console.warn(`Unknown block type: ${block.__component}`)
          return null
        }
        return <Component key={index} {...block} />
      })}
    </>
  )
}
```

### Page with Dynamic Content

```tsx
// app/[...slug]/page.tsx
import { getPage } from '@/lib/strapi'
import { DynamicZone } from '@/components/dynamic-zone'
import { notFound } from 'next/navigation'

export default async function DynamicPage({
  params,
}: {
  params: { slug: string[] }
}) {
  const slug = params.slug.join('/')
  const page = await getPage(slug)

  if (!page) {
    notFound()
  }

  return (
    <main>
      <h1>{page.attributes.title}</h1>
      <DynamicZone content={page.attributes.content} />
    </main>
  )
}

export async function generateMetadata({ params }) {
  const slug = params.slug.join('/')
  const page = await getPage(slug)

  if (!page) return {}

  const seo = page.attributes.seo
  return {
    title: seo?.metaTitle || page.attributes.title,
    description: seo?.metaDescription,
    openGraph: seo?.ogImage && {
      images: [getStrapiMedia(seo.ogImage)],
    },
  }
}
```

## Media Handling

```typescript
// lib/strapi.ts
interface StrapiMedia {
  data: {
    id: number
    attributes: {
      url: string
      alternativeText: string | null
      width: number
      height: number
      formats?: {
        thumbnail?: MediaFormat
        small?: MediaFormat
        medium?: MediaFormat
        large?: MediaFormat
      }
    }
  } | null
}

interface MediaFormat {
  url: string
  width: number
  height: number
}

export function getStrapiMedia(
  media: StrapiMedia,
  format?: 'thumbnail' | 'small' | 'medium' | 'large'
): string | null {
  if (!media?.data) return null

  const { attributes } = media.data
  let url = attributes.url

  // Use specific format if requested and available
  if (format && attributes.formats?.[format]) {
    url = attributes.formats[format].url
  }

  // Handle relative URLs
  if (url.startsWith('/')) {
    return `${process.env.STRAPI_URL}${url}`
  }

  return url
}

// components/strapi-image.tsx
import Image from 'next/image'
import { getStrapiMedia } from '@/lib/strapi'

export function StrapiImage({
  media,
  format,
  ...props
}: {
  media: StrapiMedia
  format?: 'thumbnail' | 'small' | 'medium' | 'large'
} & Omit<React.ComponentProps<typeof Image>, 'src'>) {
  const url = getStrapiMedia(media, format)
  if (!url) return null

  const { attributes } = media.data!
  return (
    <Image
      src={url}
      alt={attributes.alternativeText || ''}
      width={attributes.width}
      height={attributes.height}
      {...props}
    />
  )
}
```

## Medusa + Strapi Integration

### Product Enrichment Pattern

```typescript
// Strapi content type: product-content
interface ProductContent {
  medusa_id: string // Link to Medusa product
  long_description: string // Rich marketing content
  features: { title: string; description: string }[]
  gallery: StrapiMedia[]
  videos: { title: string; url: string }[]
  related_articles: StrapiRelation<Article[]>
}

// lib/products.ts
import { getMedusaProduct } from './medusa'
import { getProductContent } from './strapi'

export async function getEnrichedProduct(productId: string) {
  // Fetch in parallel
  const [medusaProduct, strapiContent] = await Promise.all([
    getMedusaProduct(productId),
    getProductContent(productId),
  ])

  return {
    ...medusaProduct,
    content: strapiContent,
  }
}

// lib/strapi.ts
export async function getProductContent(medusaId: string) {
  const response = await fetchStrapi<StrapiEntity<ProductContent>[]>(
    '/product-contents',
    {
      filters: { medusa_id: { $eq: medusaId } },
      populate: ['gallery', 'videos', 'related_articles.image'],
    }
  )

  return response.data[0]?.attributes ?? null
}
```

### Product Page Integration

```tsx
// app/products/[id]/page.tsx
import { getEnrichedProduct } from '@/lib/products'
import { StrapiImage } from '@/components/strapi-image'

export default async function ProductPage({
  params,
}: {
  params: { id: string }
}) {
  const product = await getEnrichedProduct(params.id)

  return (
    <main>
      {/* Medusa data */}
      <h1>{product.title}</h1>
      <p>{formatPrice(product.variants[0].prices[0])}</p>

      {/* Strapi content */}
      {product.content && (
        <>
          <div
            dangerouslySetInnerHTML={{ __html: product.content.long_description }}
          />

          <section>
            <h2>Features</h2>
            {product.content.features.map((feature, i) => (
              <div key={i}>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
              </div>
            ))}
          </section>

          <section>
            <h2>Gallery</h2>
            {product.content.gallery.map((img, i) => (
              <StrapiImage key={i} media={img} format="medium" />
            ))}
          </section>
        </>
      )}
    </main>
  )
}
```

## Caching Strategy

| Content Type | Revalidation | Reason |
|--------------|--------------|--------|
| Static pages | 300s (5min) | Rarely changes |
| Blog articles | 60s (1min) | Moderate changes |
| Product content | 60s (1min) | Updates with inventory |
| Navigation | 3600s (1hr) | Rarely changes |
| Homepage | 300s (5min) | Balance freshness/performance |

## Common Gotchas

1. **Populate required**: Relations never auto-populate - always specify
2. **Media URLs**: Always prepend Strapi URL for relative paths
3. **Draft content**: Hidden by default - use `publicationState=preview`
4. **Pagination limits**: Max pageSize is 100
5. **Deep relations**: Use nested populate syntax for 2+ levels
6. **Rich text**: Returns HTML - use `dangerouslySetInnerHTML` or parser
