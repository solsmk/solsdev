---
paths: "**/strapi/**/*", "**/cms/**/*", "**/content-types/**/*", "**/api/**/controllers/**/*", "**/api/**/services/**/*", "**/api/**/routes/**/*"
---

# Strapi 5 Development Rules

*Applied when working with Strapi CMS files*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Main Docs** | https://docs.strapi.io |
| **Dev Docs** | https://docs.strapi.io/dev-docs |
| **REST API** | https://docs.strapi.io/dev-docs/api/rest |
| **Document Service** | https://docs.strapi.io/dev-docs/api/document-service |
| **GitHub** | https://github.com/strapi/strapi |
| **v4→v5 Migration** | https://docs.strapi.io/dev-docs/migration/v4-to-v5 |

### MCP Servers (AI Integration)

| Server | URL | Notes |
|--------|-----|-------|
| **strapi-mcp-server** | https://github.com/misterboe/strapi-mcp-server | Recommended, v4+v5 support |
| **strapi-mcp** | https://github.com/l33tdawg/strapi-mcp | 20+ tools, granular ops |
| **Strapi MCP Plugin** | https://market.strapi.io/plugins/@sensinum-strapi-plugin-mcp | Plugin for v5 (dev only) |

**Current Version**: v5.32.x (check GitHub for latest)

## Critical Breaking Changes from v4

### 1. DocumentId Replaces Numeric ID

**Strapi 5 uses a persistent 24-character alphanumeric `documentId` instead of volatile numeric `id`.**

```typescript
// v4 - Numeric ID (DEPRECATED)
const article = await strapi.entityService.findOne('api::article.article', 1)

// v5 - DocumentId (CORRECT)
const article = await strapi.documents('api::article.article').findOne('abc123def456...')
```

The numeric `id` can change during duplication/import operations. Always use `documentId` as the canonical identifier.

### 2. Flattened Response Structure

```typescript
// v4 - Nested in data.attributes
{
  "data": {
    "id": 1,
    "attributes": {
      "title": "Hello",
      "content": "..."
    }
  }
}

// v5 - Flattened structure
{
  "data": {
    "id": 1,
    "documentId": "abc123...",
    "title": "Hello",
    "content": "..."
  }
}
```

### 3. Document Service API Replaces Entity Service

```typescript
// v4 - Entity Service (DEPRECATED)
await strapi.entityService.findMany('api::article.article', { ... })

// v5 - Document Service (CORRECT)
await strapi.documents('api::article.article').findMany({ ... })
```

## Architecture Overview

```
strapi/
├── src/
│   ├── api/
│   │   └── [content-type]/
│   │       ├── content-types/
│   │       │   └── [name]/
│   │       │       ├── schema.json      # Content type definition
│   │       │       └── lifecycles.ts    # Lifecycle hooks
│   │       ├── controllers/
│   │       │   └── [name].ts            # Request handlers
│   │       ├── services/
│   │       │   └── [name].ts            # Business logic
│   │       ├── routes/
│   │       │   └── [name].ts            # Route definitions
│   │       └── policies/
│   │           └── [name].ts            # Access control
│   ├── components/                      # Reusable content components
│   ├── plugins/                         # Custom plugins
│   ├── middlewares/                     # Custom middlewares
│   └── policies/                        # Global policies
├── config/
│   ├── database.ts
│   ├── server.ts
│   ├── admin.ts
│   └── plugins.ts
└── types/
    └── generated/                       # Auto-generated types
```

### Request Pipeline

```
Global Middlewares → Routes → Route Policies/Middlewares
  → Controllers → Services → Document Service → Database → Response
```

## Content Type Schema

```json
// src/api/restaurant/content-types/restaurant/schema.json
{
  "kind": "collectionType",
  "collectionName": "restaurants",
  "info": {
    "singularName": "restaurant",
    "pluralName": "restaurants",
    "displayName": "Restaurant"
  },
  "options": {
    "draftAndPublish": true
  },
  "attributes": {
    "name": {
      "type": "string",
      "required": true,
      "maxLength": 256
    },
    "slug": {
      "type": "uid",
      "targetField": "name"
    },
    "description": {
      "type": "richtext"
    },
    "image": {
      "type": "media",
      "allowedTypes": ["images"],
      "multiple": false
    },
    "gallery": {
      "type": "media",
      "allowedTypes": ["images", "videos"],
      "multiple": true
    },
    "categories": {
      "type": "relation",
      "relation": "manyToMany",
      "target": "api::category.category"
    },
    "owner": {
      "type": "relation",
      "relation": "manyToOne",
      "target": "plugin::users-permissions.user"
    },
    "seo": {
      "type": "component",
      "component": "shared.seo",
      "required": false
    },
    "content": {
      "type": "dynamiczone",
      "components": [
        "blocks.hero",
        "blocks.text",
        "blocks.cta"
      ]
    }
  }
}
```

### Supported Attribute Types

| Type | Description |
|------|-------------|
| `string` | Short text |
| `text` | Long text |
| `richtext` | HTML rich text |
| `email` | Email address |
| `password` | Hashed password |
| `integer` | Whole number |
| `biginteger` | Large whole number |
| `decimal` | Decimal number |
| `float` | Floating point |
| `date` | Date only |
| `datetime` | Date and time |
| `time` | Time only |
| `boolean` | True/false |
| `json` | JSON data |
| `uid` | URL-safe unique identifier |
| `media` | Files/images |
| `relation` | Links to other content |
| `component` | Reusable field groups |
| `dynamiczone` | Multiple component types |

### Relation Types

```json
// One-to-One
{ "type": "relation", "relation": "oneToOne", "target": "api::profile.profile" }

// One-to-Many
{ "type": "relation", "relation": "oneToMany", "target": "api::comment.comment" }

// Many-to-One
{ "type": "relation", "relation": "manyToOne", "target": "api::author.author" }

// Many-to-Many
{ "type": "relation", "relation": "manyToMany", "target": "api::tag.tag" }
```

## Document Service API (Primary API)

```typescript
// Access the document service
const documents = strapi.documents('api::article.article')

// Find one by documentId
const article = await documents.findOne(documentId, {
  populate: { author: true, categories: true },
  fields: ['title', 'content', 'publishedAt'],
})

// Find many with filters
const articles = await documents.findMany({
  filters: {
    status: 'published',
    categories: { slug: { $eq: 'tech' } },
  },
  populate: { author: { fields: ['name', 'avatar'] } },
  sort: { createdAt: 'desc' },
  limit: 10,
  offset: 0,
})

// Create
const newArticle = await documents.create({
  data: {
    title: 'New Article',
    content: 'Content here...',
    author: authorDocumentId,
  },
  locale: 'en',
})

// Update
const updated = await documents.update(documentId, {
  data: { title: 'Updated Title' },
})

// Delete
await documents.delete(documentId)

// Publishing (when draftAndPublish enabled)
await documents.publish(documentId)
await documents.unpublish(documentId)
await documents.discardDraft(documentId)
```

## Controllers

```typescript
// src/api/restaurant/controllers/restaurant.ts
import { factories } from '@strapi/strapi'

export default factories.createCoreController(
  'api::restaurant.restaurant',
  ({ strapi }) => ({
    // Override find with custom logic
    async find(ctx) {
      // ALWAYS sanitize query input
      const sanitizedQuery = await this.sanitizeQuery(ctx)

      const results = await strapi.documents('api::restaurant.restaurant').findMany({
        ...sanitizedQuery,
        populate: { image: true, categories: true },
      })

      // ALWAYS sanitize output before returning
      const sanitizedResults = await this.sanitizeOutput(results, ctx)

      return this.transformResponse(sanitizedResults)
    },

    // Custom action
    async findBySlug(ctx) {
      const { slug } = ctx.params

      const results = await strapi.documents('api::restaurant.restaurant').findMany({
        filters: { slug: { $eq: slug } },
        populate: { image: true, owner: { fields: ['username'] } },
      })

      if (!results.length) {
        return ctx.notFound('Restaurant not found')
      }

      const sanitizedResult = await this.sanitizeOutput(results[0], ctx)
      return this.transformResponse(sanitizedResult)
    },

    // Override create with sanitization
    async create(ctx) {
      // Sanitize input data
      const sanitizedData = await this.sanitizeInput(ctx.request.body.data, ctx)

      const result = await strapi.documents('api::restaurant.restaurant').create({
        data: sanitizedData,
      })

      const sanitizedResult = await this.sanitizeOutput(result, ctx)
      return this.transformResponse(sanitizedResult)
    },
  })
)
```

### Security: Always Sanitize

```typescript
// CRITICAL: Prevent security vulnerabilities

// Input sanitization - prevents injection attacks
const sanitizedData = await this.sanitizeInput(ctx.request.body, ctx)

// Query sanitization - prevents unauthorized field access
const sanitizedQuery = await this.sanitizeQuery(ctx)

// Output sanitization - prevents private field leaks
const sanitizedResult = await this.sanitizeOutput(result, ctx)

// Query validation - ensures valid query parameters
await this.validateQuery(ctx)
```

## Services

```typescript
// src/api/restaurant/services/restaurant.ts
import { factories } from '@strapi/strapi'

export default factories.createCoreService(
  'api::restaurant.restaurant',
  ({ strapi }) => ({
    // Custom method
    async findBySlug(slug: string) {
      const results = await strapi.documents('api::restaurant.restaurant').findMany({
        filters: { slug: { $eq: slug } },
        populate: { categories: true, image: true },
      })
      return results[0] || null
    },

    // Method with transaction
    async createWithOwner(data: any, ownerId: string) {
      return await strapi.db.transaction(async ({ trx }) => {
        const restaurant = await strapi.documents('api::restaurant.restaurant').create({
          data: { ...data, owner: ownerId },
        })

        await strapi.documents('api::activity.activity').create({
          data: {
            type: 'restaurant_created',
            target: restaurant.documentId,
            user: ownerId,
          },
        })

        return restaurant
      })
    },
  })
)

// Access service anywhere
const restaurant = await strapi.service('api::restaurant.restaurant').findBySlug('my-restaurant')
```

## Routes

```typescript
// src/api/restaurant/routes/restaurant.ts
// Default core routes
export default factories.createCoreRouter('api::restaurant.restaurant')

// src/api/restaurant/routes/custom.ts
// Custom routes
export default {
  routes: [
    {
      method: 'GET',
      path: '/restaurants/slug/:slug',
      handler: 'restaurant.findBySlug',
      config: {
        auth: false,  // Public route
        policies: [],
        middlewares: [],
      },
    },
    {
      method: 'GET',
      path: '/restaurants/featured',
      handler: 'restaurant.findFeatured',
      config: {
        auth: false,
        policies: ['api::restaurant.is-published'],
      },
    },
    {
      method: 'POST',
      path: '/restaurants/:id/claim',
      handler: 'restaurant.claim',
      config: {
        policies: ['global::is-authenticated'],
      },
    },
  ],
}
```

## Policies

```typescript
// src/policies/is-authenticated.ts (Global)
export default async (policyContext, config, { strapi }) => {
  if (!policyContext.state.user) {
    return false  // Block request
  }
  return true  // Allow request
}

// src/api/restaurant/policies/is-owner.ts (API-scoped)
export default async (policyContext, config, { strapi }) => {
  const { id } = policyContext.params
  const userId = policyContext.state.user?.documentId

  if (!userId) return false

  const restaurant = await strapi.documents('api::restaurant.restaurant').findOne(id, {
    populate: { owner: { fields: ['documentId'] } },
  })

  return restaurant?.owner?.documentId === userId
}

// Usage in route config
{
  method: 'PUT',
  path: '/restaurants/:id',
  handler: 'restaurant.update',
  config: {
    policies: ['global::is-authenticated', 'api::restaurant.is-owner'],
  },
}
```

## Population & Filtering (REST API)

### Population Syntax

```bash
# Single relation
GET /api/articles?populate=author

# Multiple relations
GET /api/articles?populate[0]=author&populate[1]=categories

# Nested population
GET /api/articles?populate[author][populate][0]=avatar

# Field selection in populated data
GET /api/articles?populate[author][fields][0]=name&populate[author][fields][1]=email

# Dynamic zone population
GET /api/pages?populate[content][populate]=*

# Populate all (use sparingly - performance impact)
GET /api/articles?populate=*
```

### Filter Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `$eq` | Equals | `?filters[title][$eq]=Hello` |
| `$eqi` | Equals (case insensitive) | `?filters[title][$eqi]=hello` |
| `$ne` | Not equals | `?filters[status][$ne]=draft` |
| `$lt` | Less than | `?filters[price][$lt]=100` |
| `$lte` | Less than or equal | `?filters[price][$lte]=100` |
| `$gt` | Greater than | `?filters[price][$gt]=50` |
| `$gte` | Greater than or equal | `?filters[price][$gte]=50` |
| `$in` | In array | `?filters[status][$in][0]=published&filters[status][$in][1]=featured` |
| `$notIn` | Not in array | `?filters[status][$notIn][0]=draft` |
| `$contains` | Contains (case sensitive) | `?filters[title][$contains]=strapi` |
| `$containsi` | Contains (case insensitive) | `?filters[title][$containsi]=strapi` |
| `$startsWith` | Starts with | `?filters[slug][$startsWith]=tech` |
| `$endsWith` | Ends with | `?filters[email][$endsWith]=@company.com` |
| `$null` | Is null | `?filters[deletedAt][$null]=true` |
| `$notNull` | Is not null | `?filters[publishedAt][$notNull]=true` |
| `$between` | Between values | `?filters[price][$between][0]=10&filters[price][$between][1]=100` |

### Logical Operators

```bash
# AND conditions
?filters[$and][0][status][$eq]=published&filters[$and][1][featured][$eq]=true

# OR conditions
?filters[$or][0][status][$eq]=published&filters[$or][1][featured][$eq]=true

# Nested filtering (on relations)
?filters[author][name][$eq]=John
?filters[categories][slug][$in][0]=tech&filters[categories][slug][$in][1]=news
```

### Sorting & Pagination

```bash
# Single sort
?sort=title:asc
?sort=createdAt:desc

# Multiple sort
?sort[0]=featured:desc&sort[1]=createdAt:desc

# Page-based pagination
?pagination[page]=1&pagination[pageSize]=25

# Offset-based pagination
?pagination[start]=0&pagination[limit]=25

# Response includes meta.pagination: { page, pageSize, pageCount, total }
```

### Publication State & Locale

```bash
# Published only (default)
?publicationState=live

# Include drafts (requires authentication)
?publicationState=preview

# Specific locale
?locale=en

# All locales
?locale=*
```

## Media Handling

```typescript
// Media URLs are RELATIVE - always prepend Strapi URL
function getMediaUrl(media: StrapiMedia | null): string | null {
  if (!media?.url) return null
  if (media.url.startsWith('http')) return media.url
  return `${process.env.STRAPI_URL}${media.url}`
}

// Upload files
const formData = new FormData()
formData.append('files', fileInput)
formData.append('ref', 'api::article.article')
formData.append('refId', documentId)
formData.append('field', 'image')

const response = await fetch(`${STRAPI_URL}/api/upload`, {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}` },
  body: formData,
})

// Media formats available
interface StrapiMedia {
  url: string
  alternativeText: string | null
  width: number
  height: number
  formats?: {
    thumbnail?: { url: string; width: number; height: number }
    small?: { url: string; width: number; height: number }
    medium?: { url: string; width: number; height: number }
    large?: { url: string; width: number; height: number }
  }
}
```

## Authentication

### JWT Authentication

```typescript
// Login
POST /api/auth/local
{ "identifier": "user@example.com", "password": "password123" }
// Returns: { jwt: "...", user: { ... } }

// Register
POST /api/auth/local/register
{ "username": "newuser", "email": "user@example.com", "password": "password123" }

// Get current user
GET /api/users/me
Authorization: Bearer <jwt_token>

// Password reset flow
POST /api/auth/forgot-password
{ "email": "user@example.com" }

POST /api/auth/reset-password
{ "code": "reset_code", "password": "newpassword", "passwordConfirmation": "newpassword" }
```

### API Tokens

```typescript
// Created in admin panel: Settings → API Tokens
// Use in requests:
Authorization: Bearer <api_token>

// Tokens have granular permissions per content-type
// Always use minimum required permissions
```

## Webhooks

### Configuration

```typescript
// config/server.ts
export default ({ env }) => ({
  webhooks: {
    defaultHeaders: {
      'Authorization': `Bearer ${env('WEBHOOK_SECRET')}`,
    },
  },
})
```

### Available Events

- `entry.create` - Content created
- `entry.update` - Content updated
- `entry.delete` - Content deleted
- `entry.publish` - Content published
- `entry.unpublish` - Content unpublished
- `media.create` - File uploaded
- `media.update` - File updated
- `media.delete` - File deleted

**Important:** Webhooks do NOT work for User content-type (privacy protection). Use lifecycle hooks instead.

### Webhook Security (CRITICAL)

```typescript
import crypto from 'crypto'

function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const hash = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex')

  // Use constant-time comparison to prevent timing attacks
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(hash)
  )
}

// Webhook handler
app.post('/webhooks/strapi', (req, res) => {
  const signature = req.headers['x-strapi-signature']
  const isValid = verifyWebhookSignature(
    JSON.stringify(req.body),
    signature,
    process.env.STRAPI_WEBHOOK_SECRET
  )

  if (!isValid) {
    return res.status(401).json({ error: 'Invalid signature' })
  }

  const { event, data } = req.body
  // Process webhook...
})
```

## Lifecycle Hooks

```typescript
// src/api/article/content-types/article/lifecycles.ts
export default {
  async beforeCreate(event) {
    const { data } = event.params
    // Modify data before creation
    if (!data.slug && data.title) {
      data.slug = slugify(data.title)
    }
  },

  async afterCreate(event) {
    const { result } = event
    // Send notification, sync to external system, etc.
    await strapi.service('api::notification.notification').sendNewArticle(result)
  },

  async beforeUpdate(event) {
    const { data, where } = event.params
    // Validate or transform data
  },

  async afterUpdate(event) {
    const { result } = event
    // Invalidate cache, trigger revalidation
  },

  async beforeDelete(event) {
    const { where } = event.params
    // Cleanup related data
  },

  async afterDelete(event) {
    const { result } = event
    // Post-deletion cleanup
  },

  // Query hooks
  async beforeFindOne(event) { },
  async afterFindOne(event) { },
  async beforeFindMany(event) { },
  async afterFindMany(event) { },
}
```

## TypeScript Support

```bash
# Create TypeScript project
npx create-strapi-app@latest my-project --typescript

# Generate types from schema
yarn strapi ts:generate-types
```

```typescript
// types/generated/contentTypes.d.ts (auto-generated)
export interface ApiArticleArticle {
  documentId: string
  title: string
  content: string
  slug: string
  publishedAt: string | null
  author?: ApiAuthorAuthor
  categories?: ApiCategoryCategory[]
}

// Use in code
import { ApiArticleArticle } from '../types/generated/contentTypes'

const article: ApiArticleArticle = await strapi
  .documents('api::article.article')
  .findOne(documentId)
```

## Critical Rules & Gotchas

### 1. Use DocumentId, Not Numeric ID

```typescript
// BAD - Numeric ID can change
const article = await strapi.documents('api::article.article').findOne(1)

// GOOD - DocumentId is persistent
const article = await strapi.documents('api::article.article').findOne('abc123...')
```

### 2. Relations Never Auto-Populate

```typescript
// BAD - author will be null/undefined
GET /api/articles/abc123

// GOOD - explicitly request relations
GET /api/articles/abc123?populate=author
GET /api/articles/abc123?populate[author][fields][0]=name
```

### 3. Media URLs Are Relative

```typescript
// Strapi returns: /uploads/image.jpg
// Browser needs: https://strapi.example.com/uploads/image.jpg

const fullUrl = media.url.startsWith('http')
  ? media.url
  : `${STRAPI_URL}${media.url}`
```

### 4. Drafts Hidden by Default

```typescript
// Only published content
GET /api/articles

// Include drafts (requires auth)
GET /api/articles?publicationState=preview
```

### 5. Always Sanitize in Controllers

```typescript
// ALWAYS do this in custom controllers
const sanitizedQuery = await this.sanitizeQuery(ctx)
const sanitizedInput = await this.sanitizeInput(ctx.request.body, ctx)
const sanitizedOutput = await this.sanitizeOutput(result, ctx)
```

### 6. Webhooks Don't Work for Users

```typescript
// User webhooks are blocked for privacy
// Use lifecycle hooks instead

// src/extensions/users-permissions/content-types/user/lifecycles.ts
export default {
  async afterCreate(event) {
    // Handle new user registration
  },
}
```

### 7. Use Transactions for Multi-Step Operations

```typescript
await strapi.db.transaction(async ({ trx }) => {
  const article = await strapi.documents('api::article.article').create({
    data: articleData,
  })

  await strapi.documents('api::activity.activity').create({
    data: { type: 'article_created', target: article.documentId },
  })

  // Both succeed or both rollback
})
```

### 8. Pagination Limits

```typescript
// Default pageSize: 25
// Max pageSize: 100

// Always handle pagination in frontend
const { data, meta } = await fetchStrapi('/articles', {
  pagination: { page: 1, pageSize: 25 }
})

// meta.pagination = { page, pageSize, pageCount, total }
```

### 9. Environment Variables for Secrets

```bash
# .env (NEVER commit)
STRAPI_ADMIN_JWT_SECRET=super_secret_key
JWT_SECRET=user_auth_secret
DATABASE_PASSWORD=db_password
WEBHOOK_SECRET=webhook_verification_key
```

```typescript
// config/server.ts
export default ({ env }) => ({
  admin: {
    auth: { secret: env('STRAPI_ADMIN_JWT_SECRET') },
  },
})
```

## Integration with Next.js

```typescript
// lib/strapi.ts
const STRAPI_URL = process.env.STRAPI_URL
const STRAPI_TOKEN = process.env.STRAPI_API_TOKEN

export async function fetchStrapi<T>(
  endpoint: string,
  options: {
    populate?: string | string[]
    filters?: Record<string, any>
    sort?: string[]
    pagination?: { page?: number; pageSize?: number }
  } = {},
  revalidate = 60
): Promise<{ data: T; meta: any }> {
  const params = new URLSearchParams()

  if (options.populate) {
    const pops = Array.isArray(options.populate) ? options.populate : [options.populate]
    pops.forEach((p, i) => params.append(`populate[${i}]`, p))
  }

  if (options.filters) {
    // Flatten filters to query string
    Object.entries(options.filters).forEach(([key, value]) => {
      if (typeof value === 'object') {
        Object.entries(value).forEach(([op, val]) => {
          params.set(`filters[${key}][${op}]`, String(val))
        })
      } else {
        params.set(`filters[${key}]`, String(value))
      }
    })
  }

  if (options.sort) {
    options.sort.forEach((s, i) => params.set(`sort[${i}]`, s))
  }

  if (options.pagination) {
    if (options.pagination.page) params.set('pagination[page]', String(options.pagination.page))
    if (options.pagination.pageSize) params.set('pagination[pageSize]', String(options.pagination.pageSize))
  }

  const response = await fetch(`${STRAPI_URL}/api${endpoint}?${params}`, {
    headers: STRAPI_TOKEN ? { Authorization: `Bearer ${STRAPI_TOKEN}` } : {},
    next: { revalidate },
  })

  if (!response.ok) {
    throw new Error(`Strapi fetch failed: ${response.status}`)
  }

  return response.json()
}

// Usage in Next.js page
const { data: articles } = await fetchStrapi<Article[]>('/articles', {
  populate: ['author', 'image', 'categories'],
  filters: { categories: { slug: { $eq: 'tech' } } },
  sort: ['publishedAt:desc'],
  pagination: { page: 1, pageSize: 10 },
})
```

## Data Ownership with Medusa

| System | Owns |
|--------|------|
| **Strapi** | Marketing content, blog, pages, rich descriptions, SEO, editorial |
| **Medusa** | Products, pricing, inventory, carts, orders, payments, customers |

```typescript
// Link via Medusa product ID in Strapi
// Strapi content-type: product-content
{
  "medusa_product_id": "prod_01H...",
  "marketing_description": "<rich content>",
  "seo": { "title": "...", "description": "..." }
}

// Query enriched product
const [medusaProduct, strapiContent] = await Promise.all([
  medusaClient.products.retrieve(productId),
  fetchStrapi(`/product-contents`, {
    filters: { medusa_product_id: { $eq: productId } }
  }),
])
```
