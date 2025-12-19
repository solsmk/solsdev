---
paths: "**/cart/**/*", "**/checkout/**/*", "**/order/**/*"
---

# Cart & Checkout Patterns

*Applied when working with e-commerce cart and checkout flows*

## Architecture Overview

```
Frontend (Next.js)           Backend (Medusa)
┌─────────────────┐         ┌─────────────────┐
│  Cart Context   │◄───────►│  Cart Service   │
│  (Client State) │         │  (Server State) │
└────────┬────────┘         └────────┬────────┘
         │                           │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│ Checkout Steps  │────────►│ Order Workflow  │
│ (Multi-page)    │         │ (Transactional) │
└─────────────────┘         └─────────────────┘
```

## Cart Management

### Cart Context Pattern

```tsx
// contexts/cart-context.tsx
'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import Cookies from 'js-cookie'

interface CartContextType {
  cart: Cart | null
  loading: boolean
  addItem: (variantId: string, quantity: number) => Promise<void>
  updateItem: (lineItemId: string, quantity: number) => Promise<void>
  removeItem: (lineItemId: string) => Promise<void>
}

const CartContext = createContext<CartContextType | null>(null)

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [cart, setCart] = useState<Cart | null>(null)
  const [loading, setLoading] = useState(true)

  // Initialize cart on mount
  useEffect(() => {
    initializeCart()
  }, [])

  async function initializeCart() {
    let cartId = Cookies.get('cart_id')

    if (!cartId) {
      // Create new cart
      const response = await fetch('/api/cart', { method: 'POST' })
      const newCart = await response.json()
      cartId = newCart.id
      Cookies.set('cart_id', cartId, { expires: 30 }) // 30 days
    }

    // Fetch cart
    const response = await fetch(`/api/cart/${cartId}`)
    const existingCart = await response.json()
    setCart(existingCart)
    setLoading(false)
  }

  async function addItem(variantId: string, quantity: number) {
    const response = await fetch(`/api/cart/${cart?.id}/items`, {
      method: 'POST',
      body: JSON.stringify({ variant_id: variantId, quantity }),
    })
    const updatedCart = await response.json()
    setCart(updatedCart)
  }

  // ... other methods

  return (
    <CartContext.Provider value={{ cart, loading, addItem, updateItem, removeItem }}>
      {children}
    </CartContext.Provider>
  )
}

export const useCart = () => {
  const context = useContext(CartContext)
  if (!context) throw new Error('useCart must be used within CartProvider')
  return context
}
```

### Cart API Route (Next.js)

```tsx
// app/api/cart/route.ts
import { NextResponse } from 'next/server'

const MEDUSA_URL = process.env.MEDUSA_BACKEND_URL

export async function POST() {
  // Create cart in Medusa
  const response = await fetch(`${MEDUSA_URL}/store/carts`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      region_id: process.env.DEFAULT_REGION_ID,
    }),
  })

  const { cart } = await response.json()
  return NextResponse.json(cart)
}

// app/api/cart/[cartId]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { cartId: string } }
) {
  const response = await fetch(`${MEDUSA_URL}/store/carts/${params.cartId}`)
  const { cart } = await response.json()
  return NextResponse.json(cart)
}
```

## Checkout Flow

### Multi-Step Checkout Pattern

```tsx
// app/checkout/layout.tsx
export default function CheckoutLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="checkout-container">
      <CheckoutSteps />
      <div className="checkout-content">{children}</div>
      <CheckoutSummary />
    </div>
  )
}

// components/checkout-steps.tsx
'use client'

import { usePathname } from 'next/navigation'

const STEPS = [
  { path: '/checkout/information', label: 'Information' },
  { path: '/checkout/shipping', label: 'Shipping' },
  { path: '/checkout/payment', label: 'Payment' },
]

export function CheckoutSteps() {
  const pathname = usePathname()
  const currentIndex = STEPS.findIndex((s) => s.path === pathname)

  return (
    <nav className="checkout-steps">
      {STEPS.map((step, index) => (
        <div
          key={step.path}
          className={cn(
            'step',
            index < currentIndex && 'completed',
            index === currentIndex && 'current'
          )}
        >
          {step.label}
        </div>
      ))}
    </nav>
  )
}
```

### Checkout Information Step

```tsx
// app/checkout/information/page.tsx
'use client'

import { useRouter } from 'next/navigation'
import { useCart } from '@/contexts/cart-context'
import { updateCartCustomer } from '@/lib/medusa'

export default function InformationStep() {
  const router = useRouter()
  const { cart } = useCart()

  async function handleSubmit(formData: FormData) {
    const email = formData.get('email') as string
    const shippingAddress = {
      first_name: formData.get('firstName') as string,
      last_name: formData.get('lastName') as string,
      address_1: formData.get('address') as string,
      city: formData.get('city') as string,
      postal_code: formData.get('postalCode') as string,
      country_code: formData.get('country') as string,
    }

    await updateCartCustomer(cart.id, {
      email,
      shipping_address: shippingAddress,
    })

    router.push('/checkout/shipping')
  }

  return (
    <form action={handleSubmit}>
      <h2>Contact Information</h2>
      <input name="email" type="email" required />

      <h2>Shipping Address</h2>
      {/* Address fields */}

      <button type="submit">Continue to Shipping</button>
    </form>
  )
}
```

### Shipping Step

```tsx
// app/checkout/shipping/page.tsx
'use client'

import { useEffect, useState } from 'react'
import { useCart } from '@/contexts/cart-context'
import { getShippingOptions, selectShippingOption } from '@/lib/medusa'

export default function ShippingStep() {
  const { cart, refresh } = useCart()
  const [options, setOptions] = useState([])

  useEffect(() => {
    async function fetchOptions() {
      const shippingOptions = await getShippingOptions(cart.id)
      setOptions(shippingOptions)
    }
    fetchOptions()
  }, [cart.id])

  async function handleSelect(optionId: string) {
    await selectShippingOption(cart.id, optionId)
    await refresh()
  }

  return (
    <div>
      <h2>Shipping Method</h2>
      {options.map((option) => (
        <div key={option.id}>
          <input
            type="radio"
            name="shipping"
            value={option.id}
            onChange={() => handleSelect(option.id)}
          />
          <label>
            {option.name} - {formatPrice(option.amount)}
          </label>
        </div>
      ))}
    </div>
  )
}
```

### Payment & Order Completion

```tsx
// app/checkout/payment/page.tsx
'use client'

import { useRouter } from 'next/navigation'
import { useCart } from '@/contexts/cart-context'
import { completeCart } from '@/lib/medusa'

export default function PaymentStep() {
  const router = useRouter()
  const { cart } = useCart()
  const [processing, setProcessing] = useState(false)

  async function handlePayment(paymentData: PaymentData) {
    setProcessing(true)

    try {
      // 1. Process payment with provider
      const paymentResult = await processPayment(paymentData)

      if (!paymentResult.success) {
        throw new Error('Payment failed')
      }

      // 2. Complete cart (creates order)
      const order = await completeCart(cart.id)

      // 3. Clear cart cookie
      Cookies.remove('cart_id')

      // 4. Redirect to confirmation
      router.push(`/checkout/confirmation/${order.id}`)
    } catch (error) {
      setProcessing(false)
      // Handle error
    }
  }

  return (
    <div>
      <h2>Payment</h2>
      <PaymentForm onSubmit={handlePayment} processing={processing} />
    </div>
  )
}
```

## Critical Patterns

### Cart ID Storage

```tsx
// ALWAYS use cookies for cart ID (SSR compatible)
// NEVER use localStorage (not available on server)

// Good
Cookies.set('cart_id', cartId, { expires: 30 })
const cartId = Cookies.get('cart_id')

// Bad - breaks SSR
localStorage.setItem('cart_id', cartId)
```

### Optimistic Updates

```tsx
// Show immediate feedback while API catches up
async function addItem(variantId: string) {
  // 1. Optimistically update UI
  setCart((prev) => ({
    ...prev,
    items: [
      ...prev.items,
      { id: 'temp', variant_id: variantId, quantity: 1 },
    ],
  }))

  // 2. Actually add item
  const updatedCart = await medusaAddItem(cart.id, variantId)

  // 3. Replace with real data
  setCart(updatedCart)
}
```

### Error Recovery

```tsx
// Always handle cart errors gracefully
async function getOrCreateCart() {
  const cartId = Cookies.get('cart_id')

  if (cartId) {
    try {
      return await fetchCart(cartId)
    } catch {
      // Cart might be expired or invalid
      Cookies.remove('cart_id')
    }
  }

  // Create fresh cart
  const newCart = await createCart()
  Cookies.set('cart_id', newCart.id)
  return newCart
}
```

## Common Gotchas

1. **Cart region**: Must set region when creating cart for correct pricing
2. **Shipping before payment**: Must add shipping method before checkout completion
3. **Cart completion is final**: Cannot modify order after cart completion
4. **Stock reservation**: Stock not reserved until order created
5. **Payment session**: Must create payment session before processing payment
