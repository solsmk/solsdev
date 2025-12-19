# Contributing to SolsDev Rules

*Instructions for AI agents adding or updating rules in this repository*

## Philosophy

These rules exist for **AI agents** working on Medusa v2 + Strapi 5 + Next.js 15/16 stacks. Every rule should be:

1. **Scannable** - Tables, decision trees, not walls of text
2. **Actionable** - Code examples ready to copy/adapt
3. **Current** - Include version info and documentation links
4. **Honest about unknowns** - Link to official docs when things change

## Before Adding a New Rule

### Research First, Write Second

```
1. Search the web for latest version info (2024-2025)
2. Find official documentation URLs
3. Identify breaking changes from previous versions
4. Collect common gotchas from GitHub issues, Stack Overflow
5. THEN write the rule
```

Never write a rule from memory alone. Technologies change fast.

### Check If Rule Already Exists

```bash
# Search existing rules
grep -r "topic" .claude/rules/
```

Update existing rules rather than creating duplicates.

## Rule File Structure

### Frontmatter (Required)

```markdown
---
paths: "**/pattern/**/*", "**/*.extension"
---
```

- Use glob patterns that match files where the rule applies
- Multiple patterns separated by commas
- Be specific enough to avoid false activations

### Section Order

```markdown
# [Technology] Development Rules

*One-line description of when this applies*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://... |
| **API Reference** | https://... |
| **GitHub** | https://... |

**Current Version**: vX.Y.Z

## [Core Concept 1]

## [Core Concept 2]

## Critical Gotchas

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `error message` | Solution |
```

## Writing Style

### DO

```markdown
## Good: Table for Quick Scanning

| Scenario | Action |
|----------|--------|
| Need X | Do Y |
| Need Z | Do W |

## Good: Code Example with BAD/GOOD

```typescript
// BAD - This breaks because...
const wrong = doThingWrong()

// GOOD - This works because...
const right = doThingRight()
```

## Good: Decision Tree

```
Need to decide X?
  → If condition A: Choose option 1
  → If condition B: Choose option 2
  → Otherwise: Choose option 3
```
```

### DON'T

```markdown
## Bad: Wall of Text

Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed do eiusmod tempor incididunt ut labore et dolore magna
aliqua. Ut enim ad minim veniam, quis nostrud exercitation
ullamco laboris nisi ut aliquip ex ea commodo consequat...

(AI agents don't need prose. They need patterns.)

## Bad: Vague Advice

"Make sure to handle errors properly."

(What errors? How? Show code.)

## Bad: No Version Info

"Use the createCart function..."

(Which version? API may have changed.)
```

## Updating INDEX.md

When adding a new rule:

1. Add to appropriate section (Core Stack / UI & Styling / Infrastructure / Patterns)
2. Follow the existing table format
3. Add common errors to the "Error → Which Rule?" table
4. Add documentation links to the docs table
5. Update the directory structure at the bottom

## Version Information

### Always Include

- Current stable version number
- Release date if recent
- Minimum requirements (Node.js, React, etc.)
- Links to changelog/releases

### When Things Change

If a technology releases a new major version:

1. Research breaking changes thoroughly
2. Update the rule with new patterns
3. Keep old patterns marked as deprecated if still relevant
4. Update version number at top of file
5. Update the "Last updated" date in INDEX.md

## Testing Your Rule

Before committing:

1. **Read it as an AI agent would** - Is it scannable? Clear?
2. **Check code examples** - Are they syntactically correct?
3. **Verify links** - Do documentation URLs work?
4. **Check paths** - Does the frontmatter pattern make sense?

## Common Patterns to Follow

### Error → Fix Tables

```markdown
| Error | Fix |
|-------|-----|
| `Specific error message` | Specific solution with code if needed |
```

### Gotcha Sections

```markdown
### 1. Descriptive Gotcha Title

```typescript
// Problem
const broken = ...

// Solution
const fixed = ...
```

Brief explanation of WHY this happens.
```

### Integration Sections

When a technology integrates with others in our stack:

```markdown
## Integration with [Other Stack]

### [Specific Pattern]

```typescript
// Code showing integration
```

| This System Owns | That System Owns |
|------------------|------------------|
| X, Y, Z | A, B, C |
```

## File Naming

- Use lowercase with hyphens: `technology-name.md`
- Stack rules go in `stacks/`
- Cross-stack patterns go in `patterns/`
- Version numbers in filename only if multiple versions coexist

## Commit Messages

When updating rules:

```
docs(rules): add [technology] stack rules

- Added version X.Y support
- Documented breaking changes from vX
- Added integration patterns with [other stack]
```

## Quality Checklist

Before considering a rule complete:

- [ ] Frontmatter with accurate path patterns
- [ ] Documentation & Resources table with working links
- [ ] Current version number
- [ ] Code examples with BAD/GOOD annotations
- [ ] Critical Gotchas section
- [ ] Error → Fix table
- [ ] Integration section (if applicable)
- [ ] INDEX.md updated

## Example: Minimal Good Rule

```markdown
---
paths: "**/example/**/*"
---

# Example Technology Rules

*Applied when working with Example files*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://example.com/docs |
| **GitHub** | https://github.com/example/example |

**Current Version**: v1.0.0

## Core Concept

```typescript
// GOOD - Standard pattern
const result = await example.doThing()
```

## Critical Gotchas

### 1. Common Mistake

```typescript
// BAD
example.wrongWay()

// GOOD
await example.rightWay()
```

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `Example error` | Call `rightWay()` instead |
```

---

*Remember: These rules are for your fellow AI agents. Write what YOU would want to read when debugging at 2am.*
