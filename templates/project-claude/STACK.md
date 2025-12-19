# Tech Stack

> Package → Version → Purpose (one line each)

## Core

| Package | Version | Purpose |
|---------|---------|---------|
| next | 15.x | React framework, App Router |
| react | 19.x | UI library |
| typescript | 5.x | Type safety |

## Backend Integration

| Package | Version | Purpose |
|---------|---------|---------|
| @medusajs/js-sdk | 2.x | Medusa Store API client |
| strapi | 5.x | Headless CMS |

## UI

| Package | Version | Purpose |
|---------|---------|---------|
| tailwindcss | 4.x | Utility CSS |
| @radix-ui/* | latest | Accessible primitives (via shadcn) |
| lucide-react | latest | Icons |

## Forms & Validation

| Package | Version | Purpose |
|---------|---------|---------|
| react-hook-form | 7.x | Form state |
| zod | 3.x | Schema validation |
| @hookform/resolvers | latest | Zod integration |

## Data Fetching

| Package | Version | Purpose |
|---------|---------|---------|
| @tanstack/react-query | 5.x | Server state, caching |

## Dev Tools

| Package | Version | Purpose |
|---------|---------|---------|
| eslint | 9.x | Linting |
| prettier | 3.x | Formatting |
| biome | 1.x | Fast lint + format (alternative) |

## Version Requirements

| Tool | Min Version |
|------|-------------|
| Node.js | 20.x |
| pnpm | 9.x |

## Adding Dependencies

Before adding: Check if shadcn/ui has a component. Check if existing package solves it.

```bash
pnpm add [package]        # Production
pnpm add -D [package]     # Dev only
```

After adding: Update this file.

*Updated: YYYY-MM-DD*
