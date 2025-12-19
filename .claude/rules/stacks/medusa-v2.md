---
paths: "**/medusa/**/*", "**/modules/**/*.ts", "**/api/admin/**/*", "**/api/store/**/*", "**/workflows/**/*", "**/subscribers/**/*"
---

# Medusa v2 Development Rules

*Applied when working with Medusa e-commerce files*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **v2 Docs** | https://docs.medusajs.com/v2 |
| **Admin API** | https://docs.medusajs.com/api/admin |
| **Store API** | https://docs.medusajs.com/api/store |
| **GitHub** | https://github.com/medusajs/medusa |
| **Recipes** | https://docs.medusajs.com/v2/resources/recipes |
| **JS SDK** | https://docs.medusajs.com/v2/resources/js-sdk |

### MCP Servers (AI Integration)

| Server | URL | Notes |
|--------|-----|-------|
| **SGFGOV/medusa-mcp** | https://github.com/SGFGOV/medusa-mcp | Most mature, 48+ stars |
| **medusa-store-mcp** | https://github.com/KrzysztofMoch/medusa-store-mcp | Modular tools, Zod schemas |
| **medusa-mcp-adapter** | https://github.com/srindom/medusa-mcp-adapter | Add MCP to existing instance |

**Current Version**: v2.12.x (check GitHub for latest)

## Architecture Overview

Medusa v2 is a modular digital commerce platform built on three pillars:
1. **Commerce Modules** - 18 pre-built commerce packages
2. **Customization Framework** - Extensibility tools
3. **Admin Dashboard** - Merchant interface

```
medusa/
├── src/
│   ├── modules/           # Custom business logic modules
│   │   └── [module]/
│   │       ├── service.ts
│   │       ├── models/
│   │       └── migrations/
│   ├── api/
│   │   ├── admin/         # Admin API routes (protected)
│   │   └── store/         # Storefront API routes (public)
│   ├── workflows/         # Multi-step transactional operations
│   ├── subscribers/       # Event handlers (pub/sub)
│   ├── jobs/              # Scheduled background tasks
│   └── links/             # Module data connections
├── medusa-config.ts       # Platform configuration
└── package.json
```

## Core Concepts

### The Container Pattern

Medusa uses dependency injection via a central container:

```typescript
// Resolve services from container - NEVER instantiate directly
const productService = container.resolve("productService")
const cartService = container.resolve("cartModuleService")

// In API routes, use req.scope
export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const productService = req.scope.resolve("productModuleService")
}

// In workflow steps, use context.container
const myStep = createStep("my-step", async (input, { container }) => {
  const service = container.resolve("myService")
})
```

### 18 Commerce Modules

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **Product** | Product catalog | Variants, options, categories, bundled products |
| **Cart** | Shopping cart | Line items, addresses, promotions, taxes |
| **Order** | Order management | Draft orders, returns, exchanges, modifications |
| **Payment** | Payment processing | Collections, providers (Stripe), webhooks |
| **Inventory** | Stock tracking | Multi-location, reservations |
| **Fulfillment** | Order fulfillment | Multiple fulfillment forms |
| **Customer** | Customer data | Guest/registered, groups |
| **Pricing** | Price management | Multi-currency, tiered pricing, rules |
| **Promotion** | Discounts | Rules, campaigns, budgets |
| **Region** | Geographic regions | Currency/tax settings per region |
| **Sales Channel** | Multi-channel | Online/offline, per-channel inventory |
| **Tax** | Tax calculation | Regional settings, custom providers |
| **Currency** | Currency support | Multi-currency handling |
| **Stock Location** | Warehouse tracking | Location management |
| **Store** | Store config | Store-level settings |
| **User** | User accounts | Permissions, roles |
| **Auth** | Authentication | Email/password, OAuth, custom actors |
| **API Key** | API credentials | Key management |

### 7 Infrastructure Modules

| Module | Purpose | Providers |
|--------|---------|-----------|
| **Event** | Pub/sub system | Local, Redis |
| **Cache** | Data caching | Redis, Memcached |
| **File** | Asset storage | Local, AWS S3 |
| **Notification** | Message delivery | SendGrid, Resend |
| **Workflow Engine** | Transaction tracking | In-Memory, Redis |
| **Locking** | Resource locks | Redis, PostgreSQL |
| **Analytics** | Event tracking | Local, PostHog |

## Workflows (Critical Pattern)

Workflows are the **primary execution pattern** for multi-step operations. They guarantee data consistency with automatic rollback.

```typescript
import {
  createWorkflow,
  createStep,
  StepResponse,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"

// Define a step with compensation (rollback)
const reserveInventoryStep = createStep(
  "reserve-inventory",
  async (input: { items: LineItem[] }, { container }) => {
    const inventoryService = container.resolve("inventoryModuleService")

    const reservations = await inventoryService.createReservationItems(
      input.items.map(item => ({
        inventory_item_id: item.variant.inventory_item_id,
        quantity: item.quantity,
      }))
    )

    // Return data AND compensation data
    return new StepResponse(reservations, { reservationIds: reservations.map(r => r.id) })
  },
  // Compensation function - called on rollback
  async (compensationData, { container }) => {
    const inventoryService = container.resolve("inventoryModuleService")
    await inventoryService.deleteReservationItems(compensationData.reservationIds)
  }
)

// Compose workflow from steps
const createOrderWorkflow = createWorkflow(
  "create-order",
  function (input: CreateOrderInput) {
    // Steps execute in sequence
    const cart = validateCartStep(input.cartId)
    const payment = capturePaymentStep({ cartId: input.cartId })
    const inventory = reserveInventoryStep({ items: cart.items })
    const order = createOrderStep({ cart, payment, inventory })

    // If any step fails, previous steps' compensations run in reverse
    return new WorkflowResponse(order)
  }
)

// Execute workflow
const { result } = await createOrderWorkflow(container).run({
  input: { cartId: "cart_123" }
})
```

### Pre-built Workflows

Import from `@medusajs/medusa/core-flows`:

```typescript
import {
  createCartWorkflow,
  addToCartWorkflow,
  completeCartWorkflow,
  createOrderWorkflow,
  createPaymentSessionsWorkflow,
  createFulfillmentWorkflow,
} from "@medusajs/medusa/core-flows"
```

### When to Use Workflows

| Use Workflow | Don't Use Workflow |
|--------------|-------------------|
| Multi-step operations | Single database read |
| Operations needing rollback | Simple CRUD |
| Cross-module operations | Module-internal logic |
| Payment/inventory/orders | Read-only queries |

## Event System & Subscribers

Medusa uses pub/sub for loose coupling:

```typescript
// Emit events from workflow steps
const emitOrderPlacedStep = createStep(
  "emit-order-placed",
  async (input: { orderId: string }, { container }) => {
    const eventService = container.resolve("eventModuleService")

    await eventService.emit({
      name: "order.placed",
      data: { id: input.orderId }
    })

    return new StepResponse(null)
  }
)

// Subscribe to events
// src/subscribers/order-placed.ts
import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"

export default async function orderPlacedHandler({
  event,
  container,
}: SubscriberArgs<{ id: string }>) {
  const orderService = container.resolve("orderModuleService")
  const notificationService = container.resolve("notificationModuleService")

  const order = await orderService.retrieveOrder(event.data.id, {
    relations: ["customer", "items"]
  })

  await notificationService.send({
    to: order.customer.email,
    template: "order-confirmation",
    data: { order }
  })
}

export const config: SubscriberConfig = {
  event: "order.placed",
}
```

### Common Events

```typescript
// Order events
"order.placed"
"order.updated"
"order.canceled"
"order.fulfilled"
"order.refunded"

// Cart events
"cart.created"
"cart.updated"
"cart.completed"

// Product events
"product.created"
"product.updated"
"product.deleted"

// Customer events
"customer.created"
"customer.updated"

// Inventory events
"inventory-item.created"
"reservation-item.created"
```

## API Routes

### Store API (Customer-facing)

```typescript
// src/api/store/products/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const productService = req.scope.resolve("productModuleService")
  const pricingService = req.scope.resolve("pricingModuleService")

  const products = await productService.listProducts({
    // Filters
  }, {
    relations: ["variants", "options", "images"],
    take: req.query.limit || 20,
    skip: req.query.offset || 0,
  })

  // Add pricing based on region
  const pricedProducts = await pricingService.calculatePrices({
    products,
    region_id: req.query.region_id,
    currency_code: req.query.currency_code,
  })

  res.json({ products: pricedProducts })
}

// src/api/store/carts/route.ts
export const POST = async (req: MedusaRequest, res: MedusaResponse) => {
  const { result } = await createCartWorkflow(req.scope).run({
    input: {
      region_id: req.body.region_id, // REQUIRED for pricing
      currency_code: req.body.currency_code,
      sales_channel_id: req.body.sales_channel_id,
    }
  })

  res.json({ cart: result })
}
```

### Admin API (Protected)

```typescript
// src/api/admin/products/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { authenticate } from "@medusajs/framework/http"

// Protect route with authentication
export const GET = [
  authenticate("admin", ["user"]),
  async (req: MedusaRequest, res: MedusaResponse) => {
    const productService = req.scope.resolve("productModuleService")

    const products = await productService.listProducts({}, {
      relations: ["variants", "options"],
    })

    res.json({ products })
  }
]

export const POST = [
  authenticate("admin", ["user"]),
  async (req: MedusaRequest, res: MedusaResponse) => {
    const { result } = await createProductWorkflow(req.scope).run({
      input: req.body
    })

    res.json({ product: result })
  }
]
```

### Route Middleware

```typescript
// src/api/middlewares.ts
import { defineMiddlewares } from "@medusajs/framework/http"
import { authenticate, validateAndTransformBody } from "@medusajs/framework/http"

export default defineMiddlewares({
  routes: [
    {
      matcher: "/admin/*",
      middlewares: [authenticate("admin", ["user"])],
    },
    {
      matcher: "/store/carts",
      method: "POST",
      middlewares: [
        validateAndTransformBody(CreateCartSchema),
      ],
    },
  ],
})
```

## Module Links (Cross-Module Relations)

Connect data across modules:

```typescript
// src/links/product-cms.ts
import { defineLink } from "@medusajs/framework/utils"
import ProductModule from "@medusajs/medusa/product"
import { CMS_MODULE } from "../modules/cms"

export default defineLink(
  ProductModule.linkable.product,
  {
    linkable: CMS_MODULE.linkable.content,
    isList: true, // One product can have many CMS content items
  }
)

// Query linked data
const query = container.resolve("query")
const products = await query.graph({
  entity: "product",
  fields: ["id", "title", "cms_content.*"],
  filters: { id: productIds }
})
```

## Custom Module Development

```typescript
// src/modules/loyalty/index.ts
import { Module } from "@medusajs/framework/utils"
import LoyaltyService from "./service"

export const LOYALTY_MODULE = "loyaltyModuleService"

export default Module(LOYALTY_MODULE, {
  service: LoyaltyService,
})

// src/modules/loyalty/service.ts
import { MedusaService } from "@medusajs/framework/utils"
import { LoyaltyPoints } from "./models/loyalty-points"

class LoyaltyService extends MedusaService({
  LoyaltyPoints,
}) {
  async addPoints(customerId: string, points: number) {
    return await this.createLoyaltyPoints({
      customer_id: customerId,
      points,
      earned_at: new Date(),
    })
  }

  async getBalance(customerId: string) {
    const records = await this.listLoyaltyPoints({
      customer_id: customerId,
    })
    return records.reduce((sum, r) => sum + r.points, 0)
  }
}

export default LoyaltyService

// src/modules/loyalty/models/loyalty-points.ts
import { model } from "@medusajs/framework/utils"

const LoyaltyPoints = model.define("loyalty_points", {
  id: model.id().primaryKey(),
  customer_id: model.text(),
  points: model.number(),
  earned_at: model.dateTime(),
})

export default LoyaltyPoints
```

## Multi-Region & Multi-Channel

### Region-Aware Pricing

```typescript
// ALWAYS create carts with region for correct pricing
const { result: cart } = await createCartWorkflow(container).run({
  input: {
    region_id: "reg_europe",  // REQUIRED
    currency_code: "eur",
  }
})

// Query products with pricing context
const products = await pricingService.calculatePrices({
  products: productList,
  context: {
    region_id: "reg_europe",
    currency_code: "eur",
  }
})
```

### Sales Channel Scoping

```typescript
// Create channel-specific cart
const cart = await createCartWorkflow(container).run({
  input: {
    region_id: "reg_us",
    sales_channel_id: "sc_online_store",  // Scope to channel
  }
})

// Products linked to channels
await linkProductToChannelWorkflow(container).run({
  input: {
    product_id: "prod_123",
    sales_channel_id: "sc_online_store",
  }
})

// Query only channel products
const products = await productService.listProducts({
  sales_channel_id: "sc_online_store",
})
```

## Payment Integration

```typescript
// Create payment session
const { result } = await createPaymentSessionsWorkflow(container).run({
  input: {
    cart_id: cartId,
    provider_id: "stripe",  // Payment provider
  }
})

// Handle provider webhook
// src/api/webhooks/stripe/route.ts
export const POST = async (req: MedusaRequest, res: MedusaResponse) => {
  const paymentService = req.scope.resolve("paymentModuleService")

  // Verify webhook signature
  const event = verifyStripeWebhook(req)

  switch (event.type) {
    case "payment_intent.succeeded":
      await paymentService.capturePayment({
        payment_id: event.data.object.metadata.payment_id,
      })
      break
    case "payment_intent.payment_failed":
      await paymentService.cancelPayment({
        payment_id: event.data.object.metadata.payment_id,
      })
      break
  }

  res.json({ received: true })
}
```

## Critical Rules & Gotchas

### 1. Always Use Workflows for Multi-Step Operations

```typescript
// BAD - No rollback on failure
await inventoryService.reserve(items)
await paymentService.capture(paymentId)  // If this fails, inventory stuck
await orderService.create(orderData)

// GOOD - Automatic rollback
await createOrderWorkflow(container).run({
  input: { cartId }
})
```

### 2. Region Required for Pricing

```typescript
// BAD - No pricing data
const cart = await createCartWorkflow(container).run({
  input: {}  // Missing region!
})

// GOOD
const cart = await createCartWorkflow(container).run({
  input: { region_id: "reg_01H..." }
})
```

### 3. Relations Must Be Explicit

```typescript
// BAD - cart.items is empty/IDs only
const cart = await cartService.retrieveCart(cartId)

// GOOD - Full data included
const cart = await cartService.retrieveCart(cartId, {
  relations: [
    "items",
    "items.variant",
    "items.variant.product",
    "shipping_methods",
    "payment_collection",
  ]
})
```

### 4. Soft Deletes

```typescript
// Records have deleted_at timestamp
// Default queries exclude soft-deleted
// Raw queries may include them

// Filter in raw queries
const products = await db.products.find({
  where: { deleted_at: null }
})
```

### 5. Cart Status is Final

```typescript
// Cart lifecycle: created → awaiting → completed
// Completed carts become orders - CANNOT be modified

if (cart.status === "completed") {
  throw new Error("Cannot modify completed cart")
}
```

### 6. Store Cart ID in Cookies (SSR)

```typescript
// BAD - breaks server-side rendering
localStorage.setItem("cart_id", cartId)

// GOOD - works with SSR
Cookies.set("cart_id", cartId, { expires: 30 })
```

### 7. Use Container, Not Direct Instantiation

```typescript
// BAD
const service = new ProductService()

// GOOD
const service = container.resolve("productModuleService")
```

### 8. Emit Events for Side Effects

```typescript
// BAD - tight coupling
await orderService.create(order)
await notificationService.sendEmail(order)  // Direct call
await analyticsService.track(order)

// GOOD - loose coupling via events
await orderService.create(order)
await eventService.emit({ name: "order.placed", data: { id: order.id } })
// Subscribers handle notifications, analytics, etc.
```

## Testing

```typescript
import { createMedusaContainer } from "@medusajs/framework/utils"
import { ContainerLike } from "@medusajs/framework/types"

describe("ProductService", () => {
  let container: ContainerLike

  beforeAll(async () => {
    container = await createMedusaContainer({
      modulesConfig: {
        // Configure test modules
      }
    })
  })

  afterAll(async () => {
    await container.dispose()
  })

  it("creates product with variants", async () => {
    const productService = container.resolve("productModuleService")

    const product = await productService.createProducts({
      title: "Test Product",
      variants: [
        { title: "Small", sku: "TEST-SM" },
        { title: "Large", sku: "TEST-LG" },
      ]
    })

    expect(product.variants).toHaveLength(2)
  })
})
```

## Integration with Next.js & Strapi

### Data Ownership

| System | Owns |
|--------|------|
| **Medusa** | Products, variants, pricing, inventory, carts, orders, payments, customers |
| **Strapi** | Marketing content, rich descriptions, blog, SEO, editorial content |
| **Next.js** | Rendering, routing, SSR/SSG, client interactions |

### Linking Pattern

```typescript
// Store Medusa product_id in Strapi content
// Strapi content-type: product-content
{
  "medusa_product_id": "prod_01H...",
  "marketing_description": "Rich content...",
  "seo_data": { ... }
}

// Fetch enriched product
const [medusaProduct, strapiContent] = await Promise.all([
  medusaClient.products.retrieve(productId),
  strapiClient.get(`/product-contents?filters[medusa_product_id][$eq]=${productId}`)
])
```
