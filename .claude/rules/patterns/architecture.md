---
paths: "**/lib/**/*", "**/utils/**/*", "**/services/**/*", "**/modules/**/*", "**/adapters/**/*"
---

# Architecture: Interface-Driven Development

*Applied when building cross-stack middleware, utilities, and service adapters*

## When to Read This

You're implementing:
- Services that integrate Medusa + Strapi + Next.js
- Adapters for external APIs (search, payments, notifications)
- Middleware used across multiple stacks
- Utilities with multiple potential implementations

## Core Pattern: The Adapter Interface

### TypeScript Runtime Constraint

**CRITICAL:** TypeScript interfaces don't exist at runtime. For dependency injection, you MUST use abstract classes.

```typescript
// BAD - Interface disappears after compilation
interface IEmailService {
  send(to: string, subject: string, body: string): Promise<void>
}

// Container can't use this as a token!
container.register('emailService', EmailServiceImpl) // ❌ What type?

// GOOD - Abstract class exists at runtime
abstract class EmailService {
  abstract send(to: string, subject: string, body: string): Promise<void>
}

// Container can use abstract class as token
container.register(EmailService, SendGridEmailService) // ✅ Type-safe!
```

### Decision Tree: Interface or Concrete Class?

```
Will this have multiple implementations?
  → YES: Does it cross stack boundaries (Medusa/Strapi/Next.js)?
    → YES: Abstract class + Adapter pattern
    → NO: Does it integrate external services?
      → YES: Abstract class + Adapter pattern
      → NO: Just a concrete class (YAGNI)

  → NO: Does it need mocking for tests?
    → YES: Abstract class for testability
    → NO: Concrete class (simplest)
```

## Stack-Specific Patterns

### Medusa v2: Leverage Awilix DI

Medusa already uses [Awilix dependency injection](https://docs.medusajs.com/v2/resources/references/architectural-modules/container). Don't fight it - extend it.

```typescript
// src/modules/email/service.ts
import { MedusaService } from "@medusajs/framework/utils"

// Define abstract class (contract)
export abstract class EmailService extends MedusaService({}) {
  abstract send(params: EmailParams): Promise<void>
  abstract sendTemplate(template: string, data: any): Promise<void>
}

// src/modules/email/sendgrid-service.ts
import { EmailService } from "./service"

export default class SendGridEmailService implements EmailService {
  constructor(
    private readonly container,
    private readonly config
  ) {}

  async send({ to, subject, body }: EmailParams) {
    // SendGrid implementation
  }

  async sendTemplate(template: string, data: any) {
    // SendGrid template logic
  }
}

// Medusa auto-registers based on file location
// Access via: container.resolve("emailModuleService")
```

**Medusa DI Gotchas:**

| Issue | Fix |
|-------|-----|
| Service not found | Check filename matches registration (test.ts → testService) |
| Circular dependencies | Use Awilix PROXY mode (default) |
| Service lifetime wrong | Set static `LIFE_TIME = Lifetime.SINGLETON` if needed |

**See also:** [stacks/medusa-v2.md](../stacks/medusa-v2.md) for complete Medusa container documentation.

### Strapi 5: Factory Pattern + Services

Strapi uses [factory functions for services](https://docs.strapi.io/dev-docs/backend-customization/services), not DI containers.

```typescript
// src/api/notification/services/notification.ts
import { factories } from '@strapi/strapi'

// Define contract
export abstract class NotificationService {
  abstract send(userId: string, message: string): Promise<void>
}

// Implementation via factory
export default factories.createCoreService(
  'api::notification.notification',
  ({ strapi }): NotificationService => ({
    async send(userId: string, message: string) {
      // Strapi-specific logic
      const user = await strapi.documents('plugin::users-permissions.user')
        .findOne({ documentId: userId })

      // Delegate to email service
      await strapi.service('api::email.email').sendEmail({
        to: user.email,
        subject: 'Notification',
        body: message,
      })
    },
  })
)

// Access: strapi.service('api::notification.notification').send(...)
```

**Strapi Pattern:**
- Abstract class defines contract
- Factory returns object implementing that contract
- Access via `strapi.service('api::name.name')`
- No external DI container needed

**See also:** [stacks/strapi-5.md](../stacks/strapi-5.md) for complete Strapi service documentation.

### Next.js 15/16: Manual Constructor Injection

Next.js has no built-in DI. Use manual constructor injection with factory functions.

```typescript
// lib/services/search.service.ts

// Contract
export abstract class SearchService {
  abstract index(id: string, data: any): Promise<void>
  abstract search(query: string): Promise<SearchResult[]>
}

// Meilisearch implementation
export class MeilisearchSearchService implements SearchService {
  constructor(
    private readonly apiUrl: string,
    private readonly apiKey: string
  ) {}

  async index(id: string, data: any) {
    const client = new MeiliSearch({
      host: this.apiUrl,
      apiKey: this.apiKey
    })
    await client.index('products').addDocuments([{ id, ...data }])
  }

  async search(query: string): Promise<SearchResult[]> {
    const client = new MeiliSearch({
      host: this.apiUrl,
      apiKey: this.apiKey
    })
    const { hits } = await client.index('products').search(query)
    return hits
  }
}

// Factory for Next.js (server-side only)
// lib/services/factory.ts
export function createSearchService(): SearchService {
  return new MeilisearchSearchService(
    process.env.MEILISEARCH_URL!,
    process.env.MEILISEARCH_API_KEY!
  )
}

// Usage in Server Component
// app/products/page.tsx
export default async function ProductsPage({
  searchParams
}: {
  searchParams: Promise<{ q?: string }>
}) {
  const { q } = await searchParams
  const searchService = createSearchService()
  const results = q ? await searchService.search(q) : []

  return <ProductList products={results} />
}

// Usage in Server Action
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function indexProduct(productId: string, data: any) {
  const searchService = createSearchService()
  await searchService.index(productId, data)
  revalidateTag('products')
}
```

**Next.js Patterns:**

| Scenario | Pattern |
|----------|---------|
| Server Components | Factory function → new instance per request |
| Server Actions | Factory function → new instance per invocation |
| API Routes | Factory function or singleton if expensive to create |
| Client Components | Context Provider + hooks (different pattern entirely) |

**See also:** [stacks/nextjs-15.md](../stacks/nextjs-15.md) for complete Next.js patterns.

### Cross-Stack Integration: The Adapter Pattern

When integrating Medusa + Strapi + Next.js:

```typescript
// Shared contract (in monorepo shared package or duplicated)
export abstract class ProductService {
  abstract getProduct(id: string): Promise<Product>
  abstract listProducts(filters: ProductFilter): Promise<Product[]>
}

// Medusa adapter
// medusa/src/modules/product-adapter/service.ts
export class MedusaProductAdapter extends ProductService {
  constructor(
    private readonly productModuleService,
    private readonly pricingModuleService
  ) {}

  async getProduct(id: string): Promise<Product> {
    const medusaProduct = await this.productModuleService.retrieveProduct(id, {
      relations: ['variants', 'options']
    })

    // Transform to shared Product type
    return this.toProduct(medusaProduct)
  }

  async listProducts(filters: ProductFilter): Promise<Product[]> {
    const { products } = await this.productModuleService.listProducts(
      this.toMedusaFilters(filters)
    )
    return products.map(p => this.toProduct(p))
  }

  private toProduct(medusaProduct: any): Product {
    // Adapter transformation logic
    return {
      id: medusaProduct.id,
      title: medusaProduct.title,
      handle: medusaProduct.handle,
      // ... map all fields
    }
  }

  private toMedusaFilters(filters: ProductFilter): any {
    // Transform generic filters to Medusa-specific format
    return {
      // ...
    }
  }
}

// Strapi adapter
// strapi/src/api/product-content/services/adapter.ts
export class StrapiProductAdapter extends ProductService {
  constructor(
    private readonly strapi
  ) {}

  async getProduct(id: string): Promise<Product> {
    const contents = await this.strapi.documents('api::product-content.product-content')
      .findMany({
        filters: { medusa_product_id: { $eq: id } },
        populate: ['seo', 'marketing_description', 'gallery']
      })

    if (!contents.length) {
      return null
    }

    // Transform to shared Product type
    return this.toProduct(contents[0])
  }

  async listProducts(filters: ProductFilter): Promise<Product[]> {
    const contents = await this.strapi.documents('api::product-content.product-content')
      .findMany({
        filters: this.toStrapiFilters(filters),
        populate: ['seo', 'marketing_description']
      })

    return contents.map(c => this.toProduct(c))
  }

  private toProduct(strapiContent: any): Product {
    // Adapter transformation logic
    return {
      id: strapiContent.medusa_product_id,
      marketingDescription: strapiContent.marketing_description,
      seo: strapiContent.seo,
      // ... map all fields
    }
  }

  private toStrapiFilters(filters: ProductFilter): any {
    // Transform generic filters to Strapi-specific format
    return {
      // ...
    }
  }
}

// Next.js: Composite service that uses both
// lib/services/enriched-product.service.ts
export class EnrichedProductService {
  constructor(
    private readonly medusaAdapter: ProductService,
    private readonly strapiAdapter: ProductService
  ) {}

  async getProduct(id: string): Promise<EnrichedProduct> {
    const [commerce, content] = await Promise.all([
      this.medusaAdapter.getProduct(id),
      this.strapiAdapter.getProduct(id)
    ])

    // Merge both sources
    return {
      ...commerce,
      ...content,
      // Combine specific fields intelligently
      description: content?.marketingDescription || commerce?.description,
    }
  }

  async listProducts(filters: ProductFilter): Promise<EnrichedProduct[]> {
    // Fetch from both, merge by ID
    const [commerceProducts, contentProducts] = await Promise.all([
      this.medusaAdapter.listProducts(filters),
      this.strapiAdapter.listProducts(filters)
    ])

    // Create lookup map
    const contentMap = new Map(
      contentProducts.map(p => [p.id, p])
    )

    // Merge
    return commerceProducts.map(commerce => ({
      ...commerce,
      ...(contentMap.get(commerce.id) || {}),
    }))
  }
}

// Factory
export function createEnrichedProductService(): EnrichedProductService {
  // Create Medusa adapter (assumes running in Medusa context or via API)
  const medusaAdapter = new MedusaProductAdapter(
    /* productModuleService */,
    /* pricingModuleService */
  )

  // Create Strapi adapter (via fetch to Strapi API)
  const strapiAdapter = new StrapiProductAdapter(
    /* strapi instance or HTTP client */
  )

  return new EnrichedProductService(medusaAdapter, strapiAdapter)
}
```

## Testing Patterns

### Mock Implementations for Tests

```typescript
// tests/mocks/email.service.mock.ts
export class MockEmailService implements EmailService {
  public sentEmails: EmailParams[] = []

  async send(params: EmailParams) {
    this.sentEmails.push(params)
  }

  async sendTemplate(template: string, data: any) {
    this.sentEmails.push({ template, data })
  }

  reset() {
    this.sentEmails = []
  }
}

// tests/workflows/order-placed.test.ts
import { MockEmailService } from '../mocks/email.service.mock'

describe('Order Placed Workflow', () => {
  let emailService: MockEmailService

  beforeEach(() => {
    emailService = new MockEmailService()
    // Inject mock into container (Medusa)
    container.register('emailService', emailService)
  })

  afterEach(() => {
    emailService.reset()
  })

  it('sends confirmation email', async () => {
    await orderPlacedWorkflow.run({ orderId: 'test-123' })

    expect(emailService.sentEmails).toHaveLength(1)
    expect(emailService.sentEmails[0].to).toBe('customer@example.com')
    expect(emailService.sentEmails[0].subject).toContain('Order Confirmation')
  })

  it('sends email with correct template', async () => {
    await orderPlacedWorkflow.run({ orderId: 'test-123' })

    const email = emailService.sentEmails[0]
    expect(email.template).toBe('order-confirmation')
    expect(email.data).toMatchObject({
      orderId: 'test-123',
      customerName: expect.any(String)
    })
  })
})
```

### Testing with Dependency Injection

```typescript
// lib/services/payment.service.ts
export abstract class PaymentProvider {
  abstract createIntent(amount: number, currency: string): Promise<PaymentIntent>
  abstract captureIntent(intentId: string): Promise<void>
}

// lib/services/stripe-payment.service.ts
export class StripePaymentProvider implements PaymentProvider {
  constructor(private readonly apiKey: string) {}

  async createIntent(amount: number, currency: string) {
    const stripe = new Stripe(this.apiKey)
    return await stripe.paymentIntents.create({ amount, currency })
  }

  async captureIntent(intentId: string) {
    const stripe = new Stripe(this.apiKey)
    await stripe.paymentIntents.capture(intentId)
  }
}

// tests/mocks/payment.service.mock.ts
export class MockPaymentProvider implements PaymentProvider {
  public intents: Map<string, PaymentIntent> = new Map()

  async createIntent(amount: number, currency: string): Promise<PaymentIntent> {
    const intent: PaymentIntent = {
      id: `pi_mock_${Date.now()}`,
      amount,
      currency,
      status: 'requires_capture',
    }
    this.intents.set(intent.id, intent)
    return intent
  }

  async captureIntent(intentId: string): Promise<void> {
    const intent = this.intents.get(intentId)
    if (!intent) throw new Error('Intent not found')
    intent.status = 'succeeded'
  }

  reset() {
    this.intents.clear()
  }
}

// tests/checkout.test.ts
import { MockPaymentProvider } from './mocks/payment.service.mock'

describe('Checkout Flow', () => {
  let paymentProvider: MockPaymentProvider

  beforeEach(() => {
    paymentProvider = new MockPaymentProvider()
  })

  it('creates payment intent with correct amount', async () => {
    const intent = await paymentProvider.createIntent(5000, 'usd')

    expect(intent.amount).toBe(5000)
    expect(intent.currency).toBe('usd')
    expect(intent.status).toBe('requires_capture')
  })

  it('captures payment successfully', async () => {
    const intent = await paymentProvider.createIntent(5000, 'usd')
    await paymentProvider.captureIntent(intent.id)

    const captured = paymentProvider.intents.get(intent.id)
    expect(captured.status).toBe('succeeded')
  })
})
```

## Common Patterns

### Pattern 1: External Service Adapter

```typescript
// Abstract the external service
export abstract class PaymentProvider {
  abstract createIntent(amount: number, currency: string): Promise<PaymentIntent>
  abstract captureIntent(intentId: string): Promise<void>
  abstract refund(intentId: string, amount: number): Promise<void>
}

// Stripe implementation
export class StripePaymentProvider implements PaymentProvider {
  constructor(private readonly apiKey: string) {}

  async createIntent(amount: number, currency: string) {
    const stripe = new Stripe(this.apiKey)
    return await stripe.paymentIntents.create({
      amount,
      currency,
      capture_method: 'manual'
    })
  }

  async captureIntent(intentId: string) {
    const stripe = new Stripe(this.apiKey)
    await stripe.paymentIntents.capture(intentId)
  }

  async refund(intentId: string, amount: number) {
    const stripe = new Stripe(this.apiKey)
    await stripe.refunds.create({
      payment_intent: intentId,
      amount
    })
  }
}

// PayPal implementation (future)
export class PayPalPaymentProvider implements PaymentProvider {
  constructor(
    private readonly clientId: string,
    private readonly secret: string
  ) {}

  async createIntent(amount: number, currency: string) {
    // PayPal SDK implementation
  }

  async captureIntent(intentId: string) {
    // PayPal SDK implementation
  }

  async refund(intentId: string, amount: number) {
    // PayPal SDK implementation
  }
}

// Factory to switch providers
export function createPaymentProvider(
  provider: 'stripe' | 'paypal'
): PaymentProvider {
  switch (provider) {
    case 'stripe':
      return new StripePaymentProvider(process.env.STRIPE_SECRET_KEY!)
    case 'paypal':
      return new PayPalPaymentProvider(
        process.env.PAYPAL_CLIENT_ID!,
        process.env.PAYPAL_SECRET!
      )
    default:
      throw new Error(`Unknown payment provider: ${provider}`)
  }
}
```

### Pattern 2: Multi-Step Middleware (Pipeline)

```typescript
// Define pipeline contract
export abstract class DataTransformer<TInput, TOutput> {
  abstract transform(input: TInput): Promise<TOutput>
}

// Compose transformers
export class TransformPipeline<T> {
  constructor(
    private readonly transformers: DataTransformer<T, T>[]
  ) {}

  async execute(input: T): Promise<T> {
    let result = input
    for (const transformer of this.transformers) {
      result = await transformer.transform(result)
    }
    return result
  }
}

// Concrete transformers
export class SanitizeHtmlTransformer implements DataTransformer<string, string> {
  async transform(input: string): Promise<string> {
    // Remove dangerous HTML
    return input.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
  }
}

export class MarkdownToHtmlTransformer implements DataTransformer<string, string> {
  async transform(input: string): Promise<string> {
    const { marked } = await import('marked')
    return marked(input)
  }
}

export class ImageOptimizationTransformer implements DataTransformer<string, string> {
  async transform(input: string): Promise<string> {
    // Replace image URLs with optimized versions
    return input.replace(
      /<img src="([^"]+)"/g,
      '<img src="$1?w=800&q=80"'
    )
  }
}

// Usage
const pipeline = new TransformPipeline([
  new SanitizeHtmlTransformer(),
  new MarkdownToHtmlTransformer(),
  new ImageOptimizationTransformer(),
])

const processed = await pipeline.execute(rawContent)
```

### Pattern 3: Repository Pattern (Data Access)

```typescript
// Generic repository contract
export abstract class Repository<T> {
  abstract findById(id: string): Promise<T | null>
  abstract findMany(filters: Filters): Promise<T[]>
  abstract create(data: Partial<T>): Promise<T>
  abstract update(id: string, data: Partial<T>): Promise<T>
  abstract delete(id: string): Promise<void>
}

// Medusa implementation
export class MedusaProductRepository implements Repository<Product> {
  constructor(private readonly productModuleService) {}

  async findById(id: string): Promise<Product | null> {
    try {
      return await this.productModuleService.retrieveProduct(id)
    } catch (error) {
      if (error.type === 'not_found') return null
      throw error
    }
  }

  async findMany(filters: Filters): Promise<Product[]> {
    const { products } = await this.productModuleService.listProducts(filters)
    return products
  }

  async create(data: Partial<Product>): Promise<Product> {
    return await this.productModuleService.createProducts(data)
  }

  async update(id: string, data: Partial<Product>): Promise<Product> {
    return await this.productModuleService.updateProducts(id, data)
  }

  async delete(id: string): Promise<void> {
    await this.productModuleService.deleteProducts(id)
  }
}

// Strapi implementation
export class StrapiContentRepository implements Repository<Content> {
  constructor(private readonly strapi) {}

  async findById(id: string): Promise<Content | null> {
    try {
      return await this.strapi.documents('api::content.content').findOne({
        documentId: id
      })
    } catch (error) {
      return null
    }
  }

  async findMany(filters: Filters): Promise<Content[]> {
    return await this.strapi.documents('api::content.content').findMany({
      filters
    })
  }

  async create(data: Partial<Content>): Promise<Content> {
    return await this.strapi.documents('api::content.content').create({
      data
    })
  }

  async update(id: string, data: Partial<Content>): Promise<Content> {
    return await this.strapi.documents('api::content.content').update({
      documentId: id,
      data
    })
  }

  async delete(id: string): Promise<void> {
    await this.strapi.documents('api::content.content').delete({
      documentId: id
    })
  }
}
```

## Critical Gotchas

### 1. Runtime Type Erasure

```typescript
// BAD - Interface doesn't exist at runtime
interface IService {}
container.register('service', ServiceImpl) // ❌ Lost type info

// GOOD - Abstract class exists at runtime
abstract class Service {}
container.register(Service, ServiceImpl) // ✅ Type-safe
```

**Why:** TypeScript interfaces are compile-time only. After transpilation to JavaScript, they completely disappear. DI containers need runtime types to work correctly.

### 2. Avoid Over-Abstraction

```typescript
// BAD - Unnecessary abstraction
abstract class StringUtils {
  abstract capitalize(str: string): string
}

class StringUtilsImpl implements StringUtils {
  capitalize(str: string) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }
}

// GOOD - Just a function
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1)
}
```

**Rule:** If it's a pure function with no external dependencies, don't wrap it in an interface. Use the decision tree above.

### 3. Stack-Specific DI Mechanisms

| Stack | DI Approach | Token Type | Access Pattern |
|-------|-------------|------------|----------------|
| Medusa v2 | Awilix container | String ('serviceName') or abstract class | `container.resolve('name')` |
| Strapi 5 | Factory pattern | Service locator | `strapi.service('api::name.name')` |
| Next.js 15/16 | Manual constructor injection | Factory functions | `createService()` |

Don't try to unify these - each stack has its idioms. Instead, create adapters that expose consistent contracts while respecting stack conventions internally.

### 4. Singleton vs Scoped vs Transient

Choose wisely based on your service characteristics:

```typescript
// SINGLETON - Expensive to create, stateless
export class MeilisearchClient {
  static LIFE_TIME = Lifetime.SINGLETON
  // Connection pool, reused across requests
  // No request-specific state
}

// SCOPED - Per-request state
export class CartService {
  static LIFE_TIME = Lifetime.SCOPED
  // May cache cart data during single request
  // Fresh instance per request
}

// TRANSIENT - Lightweight, short-lived
export class EmailValidator {
  static LIFE_TIME = Lifetime.TRANSIENT
  // Created new each time, no state
  // Cheap to instantiate
}
```

**Medusa default:** SINGLETON (unless specified otherwise)

### 5. Circular Dependency Hell

```typescript
// BAD - Circular dependency
class UserService {
  constructor(private orderService: OrderService) {}
}

class OrderService {
  constructor(private userService: UserService) {} // ❌ Circular!
}

// GOOD - Break the cycle with events or third service
class UserService {
  // No direct dependency on OrderService
}

class OrderService {
  constructor(private eventBus: EventBus) {}

  async createOrder(userId: string) {
    // ...
    this.eventBus.emit('order.created', { userId, orderId })
  }
}

class OrderNotificationHandler {
  constructor(
    private userService: UserService,
    private emailService: EmailService
  ) {}

  @Subscribe('order.created')
  async handleOrderCreated({ userId, orderId }) {
    const user = await this.userService.findById(userId)
    await this.emailService.send({
      to: user.email,
      subject: 'Order Created',
      // ...
    })
  }
}
```

**Medusa solution:** Awilix uses PROXY mode by default, which can handle some circular dependencies. But it's better to avoid them entirely using events.

## Integration with Existing SolsDev Rules

This architecture pattern complements existing stack rules:

- **[stacks/medusa-v2.md](../stacks/medusa-v2.md)**: Use abstract classes with Awilix DI (already documents container)
- **[stacks/strapi-5.md](../stacks/strapi-5.md)**: Factory pattern for services (already shows factories)
- **[stacks/nextjs-15.md](../stacks/nextjs-15.md)**: Manual DI via factory functions (already shows Server Components)

**When conflicts arise:** Stack idioms take precedence. If Medusa recommends a pattern, follow it within Medusa. Use adapters to bridge stacks.

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `Interface not found at runtime` | Use abstract class, not interface |
| `Service not injectable / undefined` | Check abstract class used as DI token |
| `Circular dependency detected` | Use event bus or extract third service |
| `Type 'X' is not assignable to parameter of type 'abstract new'` | Make sure class is abstract, not interface |
| `Cannot resolve service 'serviceName'` | Check Medusa filename matches convention (email.ts → emailService) |
| `strapi.service(...) returns undefined` | Check service factory is exported as default |
| `createService is not a function` | Factory function must be exported |

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Eskil Steenberg Black Box Architecture** | [GitHub - ai-architecture-prompts](https://github.com/Alexanderdunlop/ai-architecture-prompts) |
| **Awilix DI Container** | [GitHub - jeffijoe/awilix](https://github.com/jeffijoe/awilix) |
| **Awilix with TypeScript** | [xjavascript.com - Mastering Awilix](https://www.xjavascript.com/blog/awilix-typescript/) |
| **Medusa DI Docs** | [Medusa Container Reference](https://docs.medusajs.com/v2/resources/references/architectural-modules/container) |
| **Strapi Services** | [Strapi Services Documentation](https://docs.strapi.io/dev-docs/backend-customization/services) |
| **Next.js DI Pattern** | [Dependency Injection with Next.js](https://himynameistim.com/blog/dependency-injection-with-nextjs-and-typescript) |
| **Clean Architecture Next.js** | [DEV - Next.js at Scale with DI](https://dev.to/behnamrhp/how-we-fixed-nextjs-at-scale-di-clean-architecture-secrets-from-production-gnj) |
| **Top TypeScript DI Containers** | [LogRocket Blog](https://blog.logrocket.com/top-five-typescript-dependency-injection-containers/) |

---

*Last updated: 2025-12-19*
