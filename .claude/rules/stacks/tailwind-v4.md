---
paths: "**/*.css", "**/tailwind.config.*", "**/postcss.config.*", "**/*.tsx", "**/*.jsx"
---

# Tailwind CSS v4 Development Rules

*Applied when working with Tailwind CSS styles*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://tailwindcss.com/docs |
| **v4 Announcement** | https://tailwindcss.com/blog/tailwindcss-v4 |
| **Upgrade Guide** | https://tailwindcss.com/docs/upgrade-guide |
| **Next.js Integration** | https://tailwindcss.com/docs/guides/nextjs |
| **GitHub** | https://github.com/tailwindlabs/tailwindcss |

**Current Version**: v4.0 (stable, released January 2025)

## Breaking Changes: v3 → v4

### Configuration Architecture

```css
/* v3: JavaScript config file */
/* tailwind.config.js */

/* v4: CSS-first configuration */
@import 'tailwindcss';

@theme {
  --color-primary: #3b82f6;
  --color-secondary: #10b981;
}
```

### Browser Support

v4 requires modern browsers:
- Safari 16.4+
- Chrome 111+
- Firefox 128+

Uses: `@property`, `color-mix()`, cascade layers

### Utility Changes

| Feature | v3 Default | v4 Default |
|---------|-----------|-----------|
| Border/Divide color | gray-200 | No default (explicit required) |
| Placeholder text | gray-400 | 50% current text opacity |
| Button cursor | pointer | default (browser native) |
| Ring width | 3px | 1px |
| Shadow naming | shadow-sm | shadow-xs |

### Import Syntax

```css
/* v3 */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* v4 */
@import 'tailwindcss';
```

## CSS-First Configuration

### Theme Definition

```css
/* app.css */
@import 'tailwindcss';

@theme {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-foreground: #ffffff;
  --color-secondary: #10b981;

  /* Spacing */
  --spacing-18: 4.5rem;

  /* Border radius */
  --radius-lg: 0.75rem;
}

/* Custom utilities */
@utility button-primary {
  @apply px-4 py-2 bg-primary text-primary-foreground rounded-lg;
}
```

### Zero-Config with Next.js 15.3+

Next.js 15.3+ works without `tailwind.config.js`:

```bash
npm install tailwindcss @tailwindcss/postcss postcss
```

Create manually only if customization needed.

## New Features (v4)

### Container Queries (Built-in)

```html
<!-- No plugin needed -->
<div class="@container">
  <div class="@sm:grid-cols-2 @lg:grid-cols-3">
    <!-- Responsive to container, not viewport -->
  </div>
</div>
```

Variants: `@sm:`, `@md:`, `@lg:`, `@xl:`, `@max-*:`

### 3D Transforms (Built-in)

```html
<div class="perspective-distant">
  <article class="rotate-x-45 rotate-z-30 transform-3d">
    <!-- 3D transformed content -->
  </article>
</div>
```

New utilities:
- `rotate-x-*`, `rotate-y-*`, `rotate-z-*`
- `scale-z-*`, `translate-z-*`
- `perspective-*`, `perspective-origin-*`
- `backface-visible`, `backface-hidden`

### Performance

- **Full builds**: 5x faster than v3
- **Incremental builds**: 100x+ faster (microseconds)
- Oxide engine (Rust-based)
- Lightning CSS integration

## Critical Gotchas

### 1. Dynamic Classes Are Purged

```typescript
// BAD - Purged in production (Tailwind can't see it)
const bgColor = `bg-${color}-500`
<div className={bgColor}>...</div>

// GOOD - Explicit class names
<div className={color === 'blue' ? 'bg-blue-500' : 'bg-red-500'}>...</div>

// GOOD - Safelist if truly dynamic
@theme {
  --safelist: bg-blue-500, bg-red-500, bg-green-500;
}
```

### 2. Border/Divide Require Color

```html
<!-- v3: worked (default gray-200) -->
<div class="border">

<!-- v4: no default, explicit required -->
<div class="border border-gray-200">
```

### 3. Content Paths Critical

```typescript
// tailwind.config.ts
export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
    // Missing paths = missing styles in production!
  ],
}
```

### 4. Specificity with Other CSS

```css
/* Import Tailwind LAST to avoid conflicts */
@import 'other-framework.css';
@import 'tailwindcss';  /* Must be last */
```

### 5. @apply in Components

```css
/* Still works but use sparingly */
@utility card {
  @apply rounded-lg border bg-white p-4 shadow-sm;
}

/* Better: use CSS variables for theming */
.card {
  background: var(--color-card);
  border-radius: var(--radius-lg);
}
```

## Dark Mode

### Class-Based (Recommended)

```css
/* Base */
:root {
  --color-background: #ffffff;
  --color-foreground: #1a1a1a;
}

/* Dark */
.dark {
  --color-background: #1a1a1a;
  --color-foreground: #ffffff;
}
```

```html
<html class="dark">
  <body class="bg-background text-foreground">
```

### System Preference

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #1a1a1a;
  }
}
```

## Next.js 15 Integration

### Setup

```bash
npm install tailwindcss @tailwindcss/postcss postcss
```

```javascript
// postcss.config.mjs
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
```

### App Router Compatibility

- Tailwind classes work in both Server and Client Components
- Classes are static strings (no JavaScript execution)
- RSC renders on server → Tailwind classes in static HTML

### globals.css

```css
@import 'tailwindcss';

@theme {
  /* Your design tokens */
}

/* Global styles */
body {
  @apply bg-background text-foreground;
}
```

## Bracket Syntax (Arbitrary Values)

```html
<!-- Custom values -->
<div class="w-[320px] h-[calc(100vh-4rem)]">
<div class="bg-[#1da1f2] text-[14px]">
<div class="grid-cols-[1fr_2fr_1fr]">
<div class="bg-gradient-to-[20deg]">
```

## Responsive Breakpoints

```html
<!-- Mobile-first -->
<div class="text-sm md:text-base lg:text-lg xl:text-xl">

<!-- Container queries (v4) -->
<div class="@container">
  <div class="@md:flex @lg:grid">
```

Default breakpoints:
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

## Plugins & Extensions

### Official Plugins

```bash
npm install @tailwindcss/typography @tailwindcss/forms
```

### v4: Many Plugins Now Built-in

- Container queries: built-in
- 3D transforms: built-in
- ~40% of plugins no longer needed

## Common Error → Fix

| Error | Fix |
|-------|-----|
| Styles missing in production | Check content paths, avoid dynamic class names |
| Border not showing | Add explicit color: `border border-gray-200` |
| Dark mode not working | Add `dark` class to `<html>`, check theme vars |
| Conflicting styles | Import Tailwind last in CSS |
| `@apply` not working | Use `@utility` directive in v4 |
| Container queries not working | Ensure v4 installed, add `@container` class |

## Best Practices

1. **Pin version**: `tailwindcss@4.0.0` not `tailwindcss@latest`
2. **Use CSS variables**: For theming and consistency
3. **Avoid dynamic classes**: Tailwind can't detect them
4. **Content paths**: Must be accurate
5. **Mobile-first**: Start with base, add breakpoints
6. **Extract components**: When repeating 3+ times
7. **Use Prettier plugin**: `prettier-plugin-tailwindcss` for class sorting
