---
paths: "**/heroui/**/*", "**/@heroui/**/*", "**/nextui/**/*"
---

# HeroUI Development Rules

*Applied when working with HeroUI (formerly NextUI) components*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://www.heroui.com/docs |
| **Installation** | https://www.heroui.com/docs/guide/installation |
| **Components** | https://www.heroui.com/docs/components |
| **Theming** | https://www.heroui.com/docs/customization/theme |
| **GitHub** | https://github.com/heroui-inc/heroui |
| **v3 Docs (Beta)** | https://v3.heroui.com |

**Current Version**: v2.8.0 (stable), v3.0 (beta)

## Rebrand: NextUI → HeroUI

As of January 2025, NextUI was renamed to HeroUI:

```bash
# Old (deprecated)
npm install @nextui-org/react

# New
npm install @heroui/react
```

Package migration: `@nextui-org/*` → `@heroui/*`

## Installation & Setup

### Next.js 15 Setup

```bash
npm install @heroui/react @heroui/theme framer-motion
```

### Provider Setup

```tsx
// app/providers.tsx
'use client'
import { HeroUIProvider } from "@heroui/react"

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <HeroUIProvider>
      {children}
    </HeroUIProvider>
  )
}

// app/layout.tsx
import { Providers } from "./providers"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

### Tailwind Configuration

```typescript
// tailwind.config.ts
import { heroui } from "@heroui/react"

export default {
  content: [
    "./node_modules/@heroui/theme/dist/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {},
  },
  darkMode: "class",
  plugins: [heroui()],
}
```

### pnpm Users

```bash
# .npmrc
shamefully-hoist=true
```

## Component Patterns

### Compound Components

```tsx
// Standard pattern
<Modal>
  <ModalContent>
    <ModalHeader>Title</ModalHeader>
    <ModalBody>Content</ModalBody>
    <ModalFooter>Footer</ModalFooter>
  </ModalContent>
</Modal>

// v3 requires .Root (breaking change)
<Modal.Root>
  <Modal.Content>
    <Modal.Header>Title</Modal.Header>
  </Modal.Content>
</Modal.Root>
```

### Named Exports (Alternative)

```tsx
import { Modal, ModalContent, ModalHeader } from "@heroui/react"
```

### Server Component Support

All HeroUI components include `'use client'` directive internally:

```tsx
// Works in Server Components - just import
import { Button, Card } from "@heroui/react"

export default function Page() {
  return (
    <Card>
      <Button>Click me</Button>
    </Card>
  )
}
```

## Theming

### Color Convention

```css
--[color]              /* Background (no suffix) */
--[color]-foreground   /* Text color */

/* Example */
--primary              /* Primary background */
--primary-foreground   /* Text on primary */
```

### Plugin Configuration

```typescript
// tailwind.config.ts
export default {
  plugins: [
    heroui({
      themes: {
        light: {
          colors: {
            primary: "#0070f3",
            secondary: "#f50057",
          },
        },
        dark: {
          colors: {
            primary: "#0070f3",
            secondary: "#f50057",
          },
        },
      },
      layout: {
        borderRadius: 8,
        borderWidth: 1,
        disabledOpacity: 0.5,
      },
    }),
  ],
}
```

### Dark Mode

```tsx
// Toggle via class on <html>
document.documentElement.classList.toggle('dark')
```

## HeroUI vs shadcn/ui

| Feature | HeroUI | shadcn/ui |
|---------|--------|-----------|
| **Approach** | Pre-built package | Copy-paste code |
| **Customization** | Props + themes | Full code ownership |
| **Accessibility** | React Aria (WCAG) | Radix UI (WCAG) |
| **Animations** | Built-in (Framer) | None by default |
| **RSC Support** | Native (v3+) | Limited |
| **Bundle** | Tree-shakeable | Only what you copy |
| **Learning** | Learn HeroUI API | Control everything |

### When to Choose HeroUI

- Quick development speed needed
- Want batteries-included components
- Need strong accessibility guarantees
- Building AI-assisted applications
- Need multiple language support

### When to Choose shadcn/ui

- Want complete code ownership
- Prefer minimal dependencies
- Building highly customized designs
- Comfortable managing all components

## Critical Gotchas

### 1. Tailwind v4 Compatibility

```typescript
// Problem: Styles not applying with Tailwind v4
// Solution: Use HeroUI v2.8.0+, manually configure tailwind.config.ts
```

### 2. Modal Enter Key Issue

```tsx
// Problem: Enter key in form closes modal
// Solution: Prevent default form behavior
<Modal onClose={onClose}>
  <ModalContent>
    <Form onSubmit={(e) => {
      e.preventDefault()
      // Handle submission
    }}>
      {/* Form fields */}
    </Form>
  </ModalContent>
</Modal>
```

### 3. Mobile Performance

```tsx
// Problem: Multiple components slow on mobile
// Framer Motion animations tax mid-range phones

// Solution: Respect reduced motion
@media (prefers-reduced-motion: reduce) {
  * {
    animation: none !important;
    transition: none !important;
  }
}
```

### 4. Select Mobile Bug

```
Problem: Select doesn't close on second tap (mobile)
Status: Known issue - tracking on GitHub
```

### 5. Contrast Accessibility

```tsx
// Problem: Some links fail WCAG AA (2.6:1 vs required 4.5:1)
// Solution: Customize colors via theming
```

### 6. v3 Breaking Change

```tsx
// v2
<Modal>
  <ModalContent>

// v3 (breaking)
<Modal.Root>
  <Modal.Content>

// Fallback: Use named exports (works in both)
import { Modal, ModalContent } from "@heroui/react"
```

## Common Props

| Prop | Description |
|------|-------------|
| `className` | Tailwind classes (merged properly) |
| `size` | xs, sm, md, lg, xl |
| `variant` | primary, secondary, success, warning, danger |
| `isDisabled` | Disabled state |
| `isLoading` | Loading state |

## Component Categories

### Layout
Card, Container, Divider, Grid, Navbar, Spacer

### Forms
Form, Input, Textarea, Checkbox, Radio, Select, Switch, Button

### Data Display
Table, Avatar, Badge, Chip, Code, Image, Snippet, User

### Overlay
Modal, Dropdown, Popover, Tooltip, Drawer

### Feedback
Progress, Skeleton, Spinner, Toast, Kbd

### Navigation
Breadcrumbs, Link, Pagination, Tabs

## v3 New Components

- AlertDialog
- ComboBox (searchable select)
- InputOTP
- InputGroup
- NumberField
- Listbox
- Surface

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `HeroUIProvider not found` | Wrap app in HeroUIProvider |
| Styles not applying | Check Tailwind config includes heroui plugin |
| Dark mode not working | Add `darkMode: "class"` to Tailwind config |
| pnpm install fails | Add `shamefully-hoist=true` to .npmrc |
| Types missing | Install `@heroui/theme` |
