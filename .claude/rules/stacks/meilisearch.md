---
paths: "**/search/**/*", "**/meilisearch/**/*", "**/*search*.ts", "**/*search*.tsx"
---

# Meilisearch Development Rules

*Applied when working with Meilisearch search functionality*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://www.meilisearch.com/docs |
| **JS SDK** | https://github.com/meilisearch/meilisearch-js |
| **Settings API** | https://www.meilisearch.com/docs/reference/api/settings |
| **Filtering Guide** | https://www.meilisearch.com/docs/learn/filtering_and_sorting |
| **Faceted Search** | https://www.meilisearch.com/docs/learn/fine_tuning_results/faceted_search |
| **GitHub** | https://github.com/meilisearch/meilisearch |

**Current Version**: v1.16 (latest)

## JavaScript/TypeScript SDK

### Basic Setup

```typescript
import { Meilisearch } from 'meilisearch'

const client = new Meilisearch({
  host: 'http://127.0.0.1:7700',
  apiKey: 'masterKey',  // Use search key for frontend!
})

const index = client.index('products')
```

### Core Operations

```typescript
// Add documents (async - returns task UID immediately)
const task = await index.addDocuments(products)

// Wait for indexing to complete
await client.waitForTask(task.taskUid)

// Or use chained waitTask (v1.13+)
await index.addDocuments(products).waitTask()

// Batch add large datasets
const BATCH_SIZE = 100000
await index.addDocumentsInBatches(records, BATCH_SIZE)

// Search
const results = await index.search('query', {
  filter: ['price > 100', 'available = true'],
  facets: ['category', 'brand'],
  limit: 20,
})

// Placeholder search (facets without query)
const facets = await index.search('', {
  facets: ['category'],
})
```

## Index Configuration

### Searchable Attributes

```typescript
// Order matters for relevance ranking!
// Documents matching in earlier fields rank higher
await index.updateSearchableAttributes([
  'title',        // Most important
  'description',  // Second
  'tags',         // Third
])

// Reset to default (all fields)
await index.updateSearchableAttributes([])
```

### Filterable Attributes (REQUIRED for filtering)

```typescript
// Must configure BEFORE filtering/faceting works
await index.updateFilterableAttributes([
  'category',
  'price',
  'available',
  'brand',
])

// CRITICAL: Rebuilds entire index (slow on large datasets)
// Configure BEFORE bulk indexing!
```

### Displayed Attributes

```typescript
// Only return these fields in results
await index.updateDisplayedAttributes([
  'id',
  'title',
  'price',
  'image',
])
```

## Filter Syntax

### Type Rules (Critical!)

```typescript
// Numbers: UNQUOTED
filter: ['price > 100']        // ✅ Correct
filter: ['price > "100"']      // ❌ Returns empty!

// Strings: QUOTED
filter: ['category = "electronics"']  // ✅ Correct
filter: ['category = electronics']    // ❌ No results!

// Booleans: UNQUOTED
filter: ['available = true']   // ✅ Correct
```

### Operators

| Operator | Example |
|----------|---------|
| `=` | `category = "shoes"` |
| `!=` | `status != "draft"` |
| `>`, `>=`, `<`, `<=` | `price >= 50` |
| `TO` | `price 10 TO 100` |
| `EXISTS` | `brand EXISTS` |
| `IS NULL` | `description IS NULL` |
| `IS EMPTY` | `tags IS EMPTY` |
| `IN` | `category IN ["shoes", "boots"]` |

### Combining Filters

```typescript
// AND
filter: ['price > 50 AND available = true']

// OR
filter: ['category = "shoes" OR category = "boots"']

// Complex
filter: ['(category = "shoes" OR category = "boots") AND price < 100']
```

## Faceted Search

```typescript
// Request facets
const results = await index.search('running', {
  facets: ['category', 'brand', 'price_range'],
})

// Response includes facetDistribution
// {
//   hits: [...],
//   facetDistribution: {
//     category: { shoes: 120, apparel: 85 },
//     brand: { nike: 50, adidas: 45 },
//   }
// }

// Search facet values (typeahead)
const facetValues = await index.searchForFacetValues('brand', 'nik')
// Returns: nike, nikita, etc.
```

### Faceting Settings

```typescript
await index.updateFaceting({
  maxValuesPerFacet: 100,  // Default: 100
  sortFacetValuesBy: {
    '*': 'count',      // Sort all by occurrence
    'brand': 'alpha',  // Sort brand alphabetically
  },
})
```

## Next.js Integration

### Pattern 1: InstantSearch (UI)

```typescript
// app/search/page.tsx
'use client'
import { InstantSearch, SearchBox, Hits } from 'react-instantsearch'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'

const searchClient = instantMeiliSearch(
  process.env.NEXT_PUBLIC_MEILISEARCH_URL!,
  process.env.NEXT_PUBLIC_MEILISEARCH_API_KEY!  // Search key only!
)

export default function SearchPage() {
  return (
    <InstantSearch searchClient={searchClient} indexName="products">
      <SearchBox />
      <Hits hitComponent={Hit} />
    </InstantSearch>
  )
}
```

### Pattern 2: Server-Side (API Routes)

```typescript
// lib/meilisearch.ts
import { Meilisearch } from 'meilisearch'

export const searchClient = new Meilisearch({
  host: process.env.MEILISEARCH_HOST!,
  apiKey: process.env.MEILISEARCH_MASTER_KEY!,  // Server only!
})

export const productsIndex = searchClient.index('products')

// app/api/search/route.ts
import { productsIndex } from '@/lib/meilisearch'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const q = searchParams.get('q') || ''

  const results = await productsIndex.search(q, {
    filter: ['available = true'],
    facets: ['category'],
    limit: 20,
  })

  return Response.json(results)
}
```

## Medusa Integration

### Plugin Setup

```bash
npm install medusa-plugin-meilisearch
```

```javascript
// medusa-config.js
const plugins = [
  {
    resolve: `medusa-plugin-meilisearch`,
    options: {
      config: {
        host: process.env.MEILISEARCH_HOST,
        apiKey: process.env.MEILISEARCH_API_KEY,
      },
      settings: {
        products: {
          indexName: 'products',
          searchableAttributes: ['title', 'description', 'tags'],
          filterableAttributes: ['price', 'collection_id', 'type_id'],
        },
      },
    },
  },
]
```

Plugin auto-syncs:
- Creates index on startup
- Listens to product events
- Real-time create/update/delete

## Strapi Integration

### Plugin Setup

```bash
npm install strapi-plugin-meilisearch
```

```javascript
// config/plugins.js
module.exports = {
  meilisearch: {
    enabled: true,
    config: {
      host: process.env.MEILISEARCH_HOST,
      apiKey: process.env.MEILISEARCH_MASTER_KEY,
    },
  },
}
```

Enable indexing per content-type in Strapi admin panel.

## Multi-Index Search

```typescript
// Search across products and articles
const results = await searchClient.multiSearch({
  queries: [
    { indexUid: 'products', q: 'search term' },
    { indexUid: 'articles', q: 'search term' },
  ],
})
```

## Critical Gotchas

### 1. Filter Type Mismatches

```typescript
// WRONG - Quotes on numbers
filter: ['price > "100"']  // Returns empty!

// CORRECT
filter: ['price > 100']

// WRONG - No quotes on strings
filter: ['category = electronics']  // No results!

// CORRECT
filter: ['category = "electronics"']
```

### 2. Filterable Attributes Required

```typescript
// WRONG - Can't filter on unconfigured field
filter: ['brand = "nike"']  // Error if brand not filterable

// MUST configure first
await index.updateFilterableAttributes(['brand', ...])
```

### 3. New Attributes Not Auto-Added

```typescript
// After manually setting filterableAttributes...
await index.updateFilterableAttributes(['id', 'category'])

// New fields WON'T be auto-added!
// Must explicitly update:
await index.updateFilterableAttributes(['id', 'category', 'brand'])

// To restore auto-discovery:
await index.updateFilterableAttributes([])
```

### 4. Async Operation Awareness

```typescript
// WRONG - Documents not indexed yet!
const task = await index.addDocuments(data)
const results = await index.search('query')  // May return old data

// CORRECT - Wait for completion
await index.addDocuments(data).waitTask()
const results = await index.search('query')
```

### 5. Index Rebuild on Settings Changes

```typescript
// SLOW on large datasets!
await index.updateFilterableAttributes([...])  // Rebuilds entire index

// Best practice: Configure BEFORE bulk indexing
```

### 6. Numeric Facet Precision

```typescript
// Problem: Float precision issues (0.1 + 0.2 = 0.30000004)
// Solution: Store as strings for faceting
const data = {
  price: '99.99',  // String, not number
}
```

### 7. API Key Security

```bash
# NEVER expose master key to browser!
MEILISEARCH_MASTER_KEY=secret        # Server only
NEXT_PUBLIC_MEILISEARCH_API_KEY=search_key  # Limited, safe for frontend
```

## Environment Variables

```bash
# Server-only (no NEXT_PUBLIC_ prefix)
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_MASTER_KEY=masterKey

# Client-safe (with NEXT_PUBLIC_)
NEXT_PUBLIC_MEILISEARCH_URL=http://localhost:7700
NEXT_PUBLIC_MEILISEARCH_API_KEY=searchOnlyKey
```

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `Invalid filter` | Check type: numbers unquoted, strings quoted |
| `Attribute not filterable` | Add to filterableAttributes first |
| Empty results after indexing | Wait for task completion with `.waitTask()` |
| Facets returning empty | Configure facets in filterableAttributes |
| Slow indexing | Use `addDocumentsInBatches()` |
| Old data appearing | Revalidate cache, wait for task |

## Performance Tips

1. **Batch large imports**: Use `addDocumentsInBatches(data, 100000)`
2. **Configure before indexing**: Set searchable/filterable attrs first
3. **Use search keys**: Never expose master key
4. **Limit results**: Default is 20, max is 1000
5. **Index only needed fields**: Reduce payload size
