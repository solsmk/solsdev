# Claude Code Rules System - Complete Reference

*Research compiled: 2024-12-14*
*Sources: Official Claude Code docs (memory.md), community implementations*

## Overview

Claude Code supports **path-scoped rules** in `.claude/rules/` - markdown files that provide context-specific instructions. Rules automatically load when Claude works with matching files.

---

## Directory Structure

```
your-project/
├── .claude/
│   ├── CLAUDE.md           # Main project instructions
│   ├── CLAUDE.local.md     # Personal overrides (gitignored)
│   └── rules/
│       ├── code-style.md   # Always loaded (no paths: frontmatter)
│       ├── testing.md
│       ├── security.md
│       ├── frontend/       # Subdirectories supported
│       │   ├── react.md
│       │   └── styles.md
│       └── backend/
│           ├── api.md
│           └── database.md
```

**Key Features:**
- All `.md` files in `rules/` auto-discovered recursively
- Same priority as CLAUDE.md
- No manual imports needed
- Symlinks supported

---

## Path-Scoping with Frontmatter

**YES, this works!** Rules can be conditionally applied based on file patterns.

### Syntax
```markdown
---
paths: src/api/**/*.ts, src/modules/**/*.ts
---

# API Development Rules

- All endpoints must include input validation
- Use standard error response format
- Include OpenAPI documentation comments
```

### Glob Patterns Supported

| Pattern | Matches |
|---------|---------|
| `**/*.ts` | All TypeScript files anywhere |
| `src/**/*` | All files under src/ |
| `*.md` | Markdown files in root |
| `src/components/*.tsx` | React components in specific dir |
| `src/**/*.{ts,tsx}` | Multiple extensions |
| `{src,lib}/**/*.ts` | Multiple directories |

---

## User-Level Rules

Personal rules that apply to ALL your projects:

```
~/.claude/rules/
├── preferences.md    # Your coding preferences
└── workflows.md      # Your preferred workflows
```

**Priority Hierarchy:**
1. User rules (`~/.claude/rules/`) - loaded first
2. Project rules (`./.claude/rules/`) - loaded second (higher priority)

---

## @import Syntax in CLAUDE.md

Reference external files from CLAUDE.md:

```markdown
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal prefs: @~/.claude/my-project-instructions.md
```

**Features:**
- Relative and absolute paths
- Max import depth: 5 hops
- Not evaluated inside code blocks (backticks protect imports)

**Check loaded files:** Use `/memory` command

---

## Rule File Format

```markdown
---
paths: src/components/**/*.tsx
---

# Component Development Rules

## When to Apply
These rules apply when working with React components.

## Standards
- Use functional components only
- TypeScript interfaces for all props
- JSDoc comments for complex props

## Examples
\`\`\`tsx
interface ButtonProps {
  label: string;
  onClick: () => void;
}

export function Button({ label, onClick }: ButtonProps) {
  return <button onClick={onClick}>{label}</button>;
}
\`\`\`

## Anti-patterns
- Don't use class components
- Don't use `any` type
```

---

## Best Practices

### DO
- Keep rules focused (one topic per file)
- Use descriptive filenames
- Organize with subdirectories
- Use path-scoping for context-specific rules
- Review and update as project evolves

### DON'T
- Create massive monolithic rule files
- Duplicate rules across files
- Use path-scoping for universal rules
- Forget to commit rules to git

---

## Relationship: CLAUDE.md vs rules/

| Feature | CLAUDE.md | rules/ |
|---------|-----------|--------|
| Location | Root or .claude/ | .claude/rules/ |
| Purpose | Main instructions | Modular, topic-specific |
| Path-scoping | No | Yes (frontmatter) |
| Multiple files | Via @import | Native |
| Best for | Overview, workflows | Language-specific, testing |

---

## Example Rules Structure

```
.claude/rules/
├── always/              # No paths: = always loaded
│   ├── safety.md        # Security rules
│   └── code-style.md    # Style guide
├── stack/               # Path-scoped by technology
│   ├── nextjs.md        # paths: app/**/*.{ts,tsx}
│   ├── medusa.md        # paths: src/modules/**/*.ts
│   └── strapi.md        # paths: src/api/**/*.ts
├── patterns/            # Domain patterns
│   ├── cart-checkout.md # paths: **/cart/**, **/checkout/**
│   └── cms-integration.md
└── gotchas/             # Known issues
    ├── medusa-gotchas.md
    └── nextjs-gotchas.md
```

---

## Example: Stack-Specific Rule

```markdown
---
paths: app/**/*.{ts,tsx}, components/**/*.{ts,tsx}
---

# Next.js 14+ Development Rules

## Server vs Client Components

\`\`\`
Need interactivity (onClick, useState)?
├── YES → Client Component ('use client')
└── NO → Server Component (default)
\`\`\`

## Data Fetching
- Server Components: fetch directly (no useEffect)
- Always specify `revalidate` for ISR

## Common Gotchas
1. Don't use hooks in Server Components
2. Props must be serializable to Client Components
3. 'use client' affects entire subtree

## Caching
\`\`\`tsx
// Static (default)
const data = await fetch(url)

// ISR (60 seconds)
const data = await fetch(url, { next: { revalidate: 60 } })

// Dynamic
const data = await fetch(url, { cache: 'no-store' })
\`\`\`
```

---

## Sources

- [Memory Management Docs](https://code.claude.com/docs/en/memory)
- [Settings Documentation](https://code.claude.com/docs/en/settings)
- [thoughtful-dev plugin](https://github.com/Neno73/thoughtful-dev) - Your implementation
