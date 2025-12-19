---
paths: "**/components/ui/**/*", "**/components.json", "**/@/components/**/*"
---

# shadcn/ui Development Rules

*Applied when working with shadcn/ui components*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://ui.shadcn.com/docs |
| **CLI Reference** | https://ui.shadcn.com/docs/cli |
| **Theming Guide** | https://ui.shadcn.com/docs/theming |
| **Dark Mode** | https://ui.shadcn.com/docs/dark-mode |
| **Components** | https://ui.shadcn.com/docs/components |
| **Changelog** | https://ui.shadcn.com/docs/changelog |
| **GitHub** | https://github.com/shadcn-ui/ui |

**Current Version**: 0.9.5+ (npm package)

## Key Concept: Copy-Paste, Not Package

shadcn/ui is NOT a component library you install. Components are copied into YOUR codebase:

```bash
# Components copied to your project - you own the code
npx shadcn@latest add button
```

This means:
- Full customization control
- No version lock-in
- Components are YOUR code to modify

## CLI Commands

### Initialize Project

```bash
npx shadcn@latest init [options]
```

| Option | Description |
|--------|-------------|
| `-t, --template` | Template (next, next-monorepo) |
| `-b, --base-color` | Base color (neutral, gray, zinc, stone, slate) |
| `-y, --yes` | Skip confirmation |
| `-f, --force` | Force overwrite existing files |

### Add Components

```bash
# Single component
npx shadcn@latest add button

# Multiple components
npx shadcn@latest add button card input form

# All components
npx shadcn@latest add --all

# From remote registry
npx shadcn add https://acme.com/registry/navbar.json
```

### Peer Dependency Fix (React 19)

```bash
# Option 1: Force flag
npx --force shadcn@latest init

# Option 2: Legacy peer deps
npx --legacy-peer-deps shadcn@latest init

# Option 3: Pre-install deps
npm install tailwindcss-animate class-variance-authority clsx tailwind-merge
npx shadcn@latest init
```

## Directory Structure

```
components/
├── ui/                 # shadcn/ui components (auto-generated)
│   ├── button.tsx
│   ├── card.tsx
│   └── ...
├── layout/             # Custom layout components
├── forms/              # Custom form components
└── shared/             # Custom shared components
```

## Theming System

### CSS Variables Convention

shadcn uses background/foreground naming:

```css
/* Light theme */
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.15 0.04 264);

  --primary: oklch(0.56 0.16 257);
  --primary-foreground: oklch(0.98 0.01 264);

  --secondary: oklch(0.51 0.11 46);
  --secondary-foreground: oklch(0.98 0.01 264);

  --destructive: oklch(0.57 0.19 16);
  --destructive-foreground: oklch(0.98 0.01 264);

  --muted: oklch(0.95 0.01 264);
  --muted-foreground: oklch(0.45 0.02 264);

  --border: oklch(0.93 0.01 264);
  --input: oklch(0.93 0.01 264);
  --ring: oklch(0.56 0.16 257);
  --radius: 0.5rem;
}

/* Dark theme */
.dark {
  --background: oklch(0.15 0.04 264);
  --foreground: oklch(0.98 0.01 264);
  /* ... other dark values */
}
```

### Adding Custom Colors

```css
/* Define variable */
:root {
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
}

.dark {
  --warning: oklch(0.41 0.11 46);
  --warning-foreground: oklch(0.99 0.02 95);
}

/* Add to Tailwind theme */
@theme inline {
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
}
```

### Dark Mode Toggle

```typescript
// Class-based (recommended)
document.documentElement.classList.toggle('dark')

// Or with next-themes
import { useTheme } from 'next-themes'
const { setTheme } = useTheme()
setTheme('dark')
```

## Next.js 15/16 Integration

### Provider Setup

```tsx
// app/layout.tsx (Server Component)
import { ThemeProvider } from "@/components/theme-provider"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html suppressHydrationWarning>
      <body>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
```

### TypeScript Path Config

```json
// tsconfig.json - REQUIRED
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

## Component Patterns

### Server vs Client Components

```tsx
// Server Components (default) - no directive needed
// Card, Badge, Separator - no interactivity

// Client Components - add directive
'use client'
// Button, Dialog, Form - user interactions
```

### The cn() Utility

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Usage - merges Tailwind classes properly
<Button className={cn("w-full", isActive && "bg-primary")} />
```

### Customization Approaches

```tsx
// Option 1: Wrapper component (RECOMMENDED)
// components/custom-card.tsx
import { Card } from "@/components/ui/card"

export function CustomCard(props: React.ComponentProps<typeof Card>) {
  return <Card className="border-2 shadow-lg" {...props} />
}

// Option 2: Edit the copy directly (risky on updates)
// components/ui/card.tsx - modify directly

// Option 3: CSS variables (for theming)
:root {
  --card: oklch(0.98 0 0);
  --card-foreground: oklch(0.15 0.04 264);
}
```

## Critical Gotchas

### 1. 'use client' Propagation

```tsx
// BAD - Logo becomes client component too
'use client'
import { Logo } from './Logo'  // Now a client component!

// GOOD - Keep Logo separate as server component
// header.tsx
'use client'
export function Header() { ... }

// logo.tsx (no 'use client')
export function Logo() { ... }
```

### 2. Import Paths

```typescript
// CORRECT - uses @/ alias
import { Button } from "@/components/ui/button"

// WRONG - relative paths break
import { Button } from "../../components/ui/button"
```

### 3. Bundle Size

```typescript
// GOOD - only imports what you add
npx shadcn@latest add button  // Only button in bundle

// BAD - bloated bundle
npx shadcn@latest add --all  // Everything in bundle
```

### 4. Tailwind v4 Compatibility

```bash
# Default: Tailwind v4
npx shadcn@latest init

# For Tailwind v3 projects
npx shadcn@2.3.0 init
```

### 5. Accessibility Built-In

- shadcn uses Radix UI primitives
- ARIA attributes included
- Keyboard navigation works by default
- Still need to test with screen readers

## Component Checklist

When adding a new component:

1. Check if shadcn has it: `npx shadcn@latest add [name]`
2. If not, build using Radix primitives + Tailwind
3. Follow the cn() pattern for className merging
4. Use CSS variables for theming
5. Add 'use client' only if interactive
6. Test keyboard navigation
7. Document custom props

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `Cannot find module '@/components/ui/button'` | Check tsconfig.json paths, run `npx shadcn@latest init` |
| `Hydration mismatch` with theme | Add `suppressHydrationWarning` to `<html>` |
| Peer dependency warnings | Use `--force` or `--legacy-peer-deps` |
| Styles not applying | Ensure Tailwind content paths include components |
| Dark mode not working | Check ThemeProvider setup, `.dark` class on html |
