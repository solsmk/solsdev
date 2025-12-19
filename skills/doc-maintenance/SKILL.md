---
name: doc-maintenance
description: Maintains project documentation currency. Activates after implementing features, adding dependencies (package.json changes), refactoring code, or modifying architecture. Detects when CLAUDE.md or .claude/*.md files are outdated by comparing documented patterns, tech stack, and architecture against actual code. Identifies which specific docs need updates and offers to update them. Ensures documentation stays synchronized with real codebase. Triggers after completing implementation work, not during exploration or bug fixes.
---

# Documentation Maintenance

## Purpose

Keep project documentation synchronized with the actual codebase by detecting drift and prompting updates after significant changes.

**Core principle:** Documentation that lies is worse than no documentation.

## When to Activate

**Activate AFTER these events:**
- ✅ Completed feature implementation (new components, routes, services)
- ✅ Added/removed dependencies (package.json changed)
- ✅ Refactored code structure (moved files, changed patterns)
- ✅ Modified architecture (new modules, changed data flow)
- ✅ Changed coding patterns (switched from Redux to Zustand, etc.)
- ✅ Updated build/dev commands (package.json scripts changed)

**DO NOT activate for:**
- ❌ Simple bug fixes that don't change patterns
- ❌ Content changes (updating text, fixing typos)
- ❌ Exploration or experimentation (not committed yet)
- ❌ Reading/analyzing code without changes
- ❌ Running tests or builds

## The Maintenance Workflow

### Step 1: Detect What Changed

After the user completes implementation work, analyze what was modified:

```
Changes detected in this session:
- Added dependency: @tanstack/react-query@5.0.0
- Created new pattern: React Query hooks in hooks/
- Modified: 5 component files to use new query pattern
```

### Step 2: Identify Affected Documentation

Map changes to specific documentation files:

```
Documentation files potentially outdated:

📦 STACK.md
   - Missing: @tanstack/react-query

🏗️ ARCHITECTURE.md
   - New data fetching pattern not documented

📝 PATTERNS.md
   - React Query usage pattern should be documented
```

### Step 3: Check Documentation Mode

Look for maintenance settings in CLAUDE.md or ask the user:

**If CLAUDE.md contains:**
```markdown
## Documentation Maintenance
Mode: auto
```

→ Proceed to Step 4 (Auto-update)

**If not specified or set to "ask":**

→ Ask the user:

```
I noticed these changes may have made documentation outdated:

📦 STACK.md - Missing new dependency (@tanstack/react-query)
📝 PATTERNS.md - New React Query pattern not documented

Would you like me to:
1. Update these docs now
2. Remind me later
3. Skip (I'll handle it manually)
4. Always auto-update (set mode: auto in CLAUDE.md)

What would you prefer?
```

### Step 4: Update Documentation (If Approved)

Based on user choice:

**Option 1: Update now**
```
Updating documentation...

✓ Updated STACK.md
  + Added @tanstack/react-query@5.0.0 to dependencies
  + Noted reason: Data fetching and caching

✓ Updated PATTERNS.md
  + Added "React Query Hooks" section
  + Documented query naming convention
  + Added example from hooks/useProducts.ts

Documentation is now up to date!
```

**Option 2: Remind later**
```
Okay! I'll remind you at the end of this session.

You can also run:
/solsdev:audit-docs - For comprehensive drift check
```

**Option 3: Skip**
```
Got it - you'll update manually.

Reminder: Run /solsdev:audit-docs before your next release
to catch any accumulated drift.
```

**Option 4: Auto-update**
```
Setting up auto-updates...

✓ Added to CLAUDE.md:
## Documentation Maintenance
Mode: auto

From now on, I'll automatically update documentation after changes.
You can change this back to "ask" anytime.

Updating docs now...
[proceeds with updates]
```

## What to Update (Drift Detection Rules)

### STACK.md Updates

**Trigger when:**
- package.json dependencies added/removed
- Major version upgrades (React 18 → 19)
- Framework changes (Next.js version bump)
- New categories of dependencies (added first database, first state management, etc.)

**What to update:**
```markdown
Add to appropriate section:
- **[Package Name]** (v[X.X.X]) - [Purpose/Why we use it]

Or update version:
- **React** (~~v18.2.0~~ → v19.0.0) - [Note about upgrade]
```

**Example:**
```
User added: pnpm add @tanstack/react-query

→ Update STACK.md:

## State Management & Data Fetching
- **Zustand** (v4.5.0) - Client state management
- **React Query** (v5.0.0) - Server state, data fetching, caching [NEW]
```

### ARCHITECTURE.md Updates

**Trigger when:**
- New directories created (new module/feature)
- New API routes/endpoints added
- Data flow changed (REST → GraphQL, etc.)
- New services/utilities created
- Component hierarchy changed significantly

**What to update:**
```markdown
Update directory structure:
src/
├── components/
├── hooks/          [NEW]
├── lib/
└── services/       [NEW]

Update data flow diagram/description:
"Data fetching now uses React Query hooks instead of direct API calls..."
```

### PATTERNS.md Updates

**Trigger when:**
- New coding patterns introduced (first use of a pattern)
- Pattern consistency changes (switched from one approach to another)
- New conventions adopted (file naming, component structure)
- Testing patterns changed

**What to update:**
```markdown
Add new pattern section:

## React Query Data Fetching

**Convention:**
- Query hooks in `hooks/use[Resource].ts`
- Naming: `use[Resource][Action]` (e.g., useProductsQuery, useProductMutation)
- Always include error and loading states

**Example:**
[Code example from actual implementation]
```

**Example:**
```
User created hooks/useProducts.ts with React Query pattern

→ Add to PATTERNS.md:

## Data Fetching Patterns

**React Query Hooks** (Added: 2025-10-26)

All server data fetching uses React Query hooks:

Location: `hooks/use[Resource].ts`

Naming convention:
- Queries: `use[Resource]Query` or `use[Resource]`
- Mutations: `use[Resource]Mutation`

Example:
[Copy the actual pattern from hooks/useProducts.ts]
```

### STARTUP.md Updates

**Trigger when:**
- package.json scripts added/changed
- New environment variables required
- Setup steps changed (database migration, new config)
- New development dependencies

**What to update:**
```markdown
## Development Commands

npm run dev          # Start dev server
npm run db:migrate   # [NEW] Run database migrations
npm test             # Run tests
```

### GOTCHAS.md Updates

**Trigger when:**
- TODO/FIXME comments added with workarounds
- Known issues discovered
- Configuration quirks documented in code comments

**What to update:**
```markdown
## [Component/Feature Name]

**Issue:** [Description]
**Workaround:** [What to do]
**Why:** [Root cause]
**Resolution:** [If known fix]
```

## Maintenance Best Practices

### Be Specific and Concrete

**Bad (vague):**
```
Updated architecture - added new features
```

**Good (specific):**
```
Added React Query for data fetching
- New hooks/ directory for query hooks
- See hooks/useProducts.ts for pattern
- Replaces direct API calls in components
```

### Document the "Why"

Don't just list what exists, explain why:

```
- **React Query** (v5.0.0) - Server state management and caching
  Why: Eliminates boilerplate, automatic refetching, built-in loading states
```

### Use Timestamps for Changes

When updating existing docs, add timestamps:

```
## State Management

**Updated: 2025-10-26**

Migrated from Redux to Zustand for simpler API and better TypeScript support.
```

### Link to Examples

Point to actual code:

```
See hooks/useProducts.ts for the standard React Query pattern.
```

### Keep It Current

Remove outdated information:

```
~~Redux~~ [Removed 2025-10-26]
**Zustand** (v4.5.0) - Current state management solution
```

## Auto-Update Rules

When mode is set to "auto", apply these rules:

**Auto-update immediately:**
- New dependencies in package.json → STACK.md
- New npm scripts → STARTUP.md
- Clear new patterns (first use of a library)

**Ask before updating:**
- Architecture changes (need human judgment on significance)
- Removing dependencies (might be intentional)
- Pattern changes (switching from one approach to another)

**Never auto-update:**
- DECISIONS.md (requires human context for "why")
- GOTCHAS.md (need verification of workaround)

## Integration with Audit Command

After making updates, remind user:

```
Documentation updated!

💡 Tip: Run /solsdev:audit-docs periodically to catch
any drift I might have missed.

Recommended:
- Weekly during active development
- Before releases/milestones
- After major refactoring
```

## Error Handling

**If documentation files don't exist:**
```
⚠ This project doesn't have .claude/ documentation yet.

Would you like me to:
1. Run /solsdev:init-project to set it up
2. Continue without documentation tracking
```

**If CLAUDE.md exists but no .claude/ directory:**
```
⚠ Found CLAUDE.md but no .claude/ directory.

This seems like a manual setup. Should I:
1. Create .claude/ structure alongside existing CLAUDE.md
2. Skip documentation maintenance for this project
```

**If conflicting information:**
```
⚠ Detected conflict:
- Code uses Zustand
- PATTERNS.md documents Redux

Should I:
1. Update docs to match code (Zustand)
2. Update code to match docs (Redux)
3. Ask you to review manually
```

## Example Session

```
[User completes feature implementation]

You: "I've added product filtering with React Query"

Me:
"Great! I noticed this introduces new patterns.

Documentation updates needed:

📦 STACK.md
   + @tanstack/react-query@5.0.0

📝 PATTERNS.md
   + React Query data fetching pattern
   + Query hook naming convention

Would you like me to update these now? (yes/no/auto)
"

You: "yes"

Me:
"Updating documentation...

✓ STACK.md updated
  + Added React Query to dependencies
  + Noted purpose: Server state and caching

✓ PATTERNS.md updated
  + Added 'React Query Hooks' section
  + Documented naming: use[Resource]Query
  + Added example from hooks/useProducts.ts

Documentation is current! 🎯
"
```

## Key Principles

1. **Timely:** Catch drift immediately, don't let it accumulate
2. **Specific:** Tell user exactly what's outdated and why
3. **Helpful:** Offer to fix it, don't just nag
4. **Respectful:** Always ask (unless auto mode), respect user's decision
5. **Honest:** If unsure, ask rather than guess

## When to Suggest Full Audit

If you detect multiple outdated files or significant drift:

```
I found several documentation updates needed (5+ files).

This might indicate accumulated drift. Consider running:
/solsdev:audit-docs

For a comprehensive check of all documentation.

**Note:** The `doc-watcher` background agent handles automatic incremental updates after file changes.
```

Remember: Your job is to **keep documentation alive**, not to burden the user with busywork. Make it easy, automatic when possible, and always helpful.
