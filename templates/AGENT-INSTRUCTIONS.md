# Instructions for AI Agents: Documentation Maintenance

> How to maintain project documentation in `.claude/` directories

## Core Principles (2025 Best Practices)

| Principle | Implementation |
|-----------|----------------|
| **Concise** | Root CLAUDE.md < 60 lines |
| **Tables over prose** | Use `\| Column \| Column \|` format |
| **File references** | Point to `file:function` not code blocks |
| **Progressive disclosure** | Don't read everything upfront |
| **No style guides** | Linters handle formatting, not docs |

## Documentation Structure

```
project/
├── CLAUDE.md              # Lean manifest (< 60 lines)
└── .claude/
    ├── INDEX.md           # What to read when
    ├── STACK.md           # Package → Version → Purpose
    ├── ARCHITECTURE.md    # Directory map, data flow
    ├── PATTERNS.md        # File references to patterns
    ├── STARTUP.md         # Commands, env vars, troubleshooting
    ├── GOTCHAS.md         # Issue → Fix tables
    └── DECISIONS.md       # Append-only decision log
```

## Format Rules

### Tables, Not Prose

```markdown
# BAD - Prose
Next.js is a React framework that provides server-side rendering,
static site generation, and many other features. We use version 15
because it has the new App Router which enables...

# GOOD - Table
| Package | Version | Purpose |
|---------|---------|---------|
| next | 15.x | React framework, App Router |
```

### File References, Not Code Blocks

```markdown
# BAD - Embedded code
## Strapi Fetch Pattern
\`\`\`typescript
export async function getArticles() {
  const res = await fetch(`${STRAPI_URL}/api/articles?populate=*`)
  // ... 20 more lines
}
\`\`\`

# GOOD - File reference
| Pattern | Reference | Notes |
|---------|-----------|-------|
| Strapi fetch | `lib/clients/strapi.ts:getArticles` | ISR, error handling |
```

### Error → Fix Format

```markdown
# BAD - Explanation
When you try to access params in a Next.js 15 page component,
you might get undefined. This is because in Next.js 15, the
params object is now a Promise and needs to be awaited...

# GOOD - Table
| Issue | Fix |
|-------|-----|
| `params` is undefined | Must `await params` in page components |
```

## When to Update Each File

| File | Update When |
|------|-------------|
| STACK.md | Package added/removed/updated |
| ARCHITECTURE.md | New directory, module, or data flow change |
| PATTERNS.md | New pattern introduced (add file reference) |
| STARTUP.md | Commands change, new env var, new error discovered |
| GOTCHAS.md | New issue discovered with workaround |
| DECISIONS.md | Architectural decision made (append only) |

## Update Format

Always include timestamp:

```markdown
*Updated: 2025-12-15*
```

For DECISIONS.md, add new entries at TOP:

```markdown
## 2025-12-15: [Decision Title]

**Context:** [Problem]
**Decision:** [What was decided]
**Alternatives:** [What else was considered]
**Consequences:** [Trade-offs]

---

[Previous entries below]
```

## What NOT to Do

| Don't | Why |
|-------|-----|
| Embed large code blocks | Wastes tokens, gets outdated |
| Write explanatory prose | AI agents need patterns, not essays |
| Duplicate information | Single source of truth |
| Add style/formatting rules | Linters handle this |
| Make CLAUDE.md verbose | It's loaded EVERY session |
| Modify DECISIONS.md entries | Append-only log |

## Automatic Maintenance (doc-watcher)

The `doc-watcher` agent runs automatically after file changes:

1. PostToolUse hook detects Write/Edit
2. Hook triggers doc-watcher agent (background, Haiku)
3. Agent compares changes vs documentation
4. Agent updates relevant `.claude/*.md` files

**Files doc-watcher updates:**
- STACK.md (package.json changes)
- PATTERNS.md (new patterns)
- ARCHITECTURE.md (structural changes)
- STARTUP.md (script changes)

**Files doc-watcher does NOT update:**
- DECISIONS.md (requires human context)
- CLAUDE.md (core config, rarely changes)

## Manual Commands

| Command | Purpose |
|---------|---------|
| `/solsdev:init-project` | Create documentation from scratch |
| `/solsdev:audit-docs` | Comprehensive drift check |

## Quality Checklist

Before considering documentation complete:

- [ ] CLAUDE.md under 60 lines
- [ ] All docs use table format
- [ ] PATTERNS.md uses file references (not code blocks)
- [ ] GOTCHAS.md uses Issue → Fix tables
- [ ] Timestamps on all files
- [ ] INDEX.md lists all docs with "read when"

## Example: Good vs Bad Updates

### Adding a New Dependency

**BAD:**
```markdown
## React Query

We've added React Query (TanStack Query) to handle server state
management. This library provides automatic caching, background
refetching, and optimistic updates. Here's how to use it:

\`\`\`typescript
// 50 lines of example code
\`\`\`
```

**GOOD:**
```markdown
# In STACK.md, add row:
| @tanstack/react-query | 5.x | Server state, caching |

# In PATTERNS.md, add row:
| React Query hook | `hooks/useProducts.ts` | Query + mutation pattern |
```

### Documenting a Gotcha

**BAD:**
```markdown
## Cart Persistence Issue

When users refresh the page, sometimes the cart appears empty
even though items were added. This happens because we were
storing the cart ID in localStorage, but Server Components
can't access localStorage during SSR, so the cart ID isn't
available when the page first renders on the server...
```

**GOOD:**
```markdown
# In GOTCHAS.md, add row:
| Cart empty after refresh | Cart ID must be in cookies, not localStorage |
```

---

*These instructions ensure consistent, AI-optimized documentation across all projects using SolsDev.*
