# Claude Code Skills - Official Specification

*Research compiled: 2024-12-14*
*Source: https://code.claude.com/docs/en/skills (OFFICIAL)*

---

## Overview

Skills are **model-invoked** capabilities that Claude automatically activates based on task context. Unlike slash commands (user-invoked), Skills are discovered and triggered by Claude reading the `description` field.

---

## SKILL.md Format (Official)

```yaml
---
name: your-skill-name
description: Brief description + WHEN to use it
allowed-tools: Read, Grep, Glob
---

# Your Skill Name

## Instructions
Step-by-step guidance...

## Examples
Concrete usage examples...
```

### Frontmatter Fields

| Field | Required | Format | Notes |
|-------|----------|--------|-------|
| `name` | Yes | lowercase, numbers, hyphens (max 64) | Unique identifier |
| `description` | Yes | max 1024 chars | **Critical for discovery** |
| `allowed-tools` | No | comma-separated | Restricts tool access |

---

## Skills vs Agents vs Commands

| Aspect | Skills | Agents | Commands |
|--------|--------|--------|----------|
| **Invocation** | Model-invoked (automatic) | Model-invoked | User-invoked (`/cmd`) |
| **Discovery** | Claude reads description | Claude reads description | User types |
| **Use Case** | Extend capabilities contextually | Separate task delegation | Quick shortcuts |
| **Composition** | Multiple can activate | One at a time | Single action |

**Key Insight:** Skills don't require explicit invocation - Claude recognizes when they're relevant.

---

## Storage Locations

| Scope | Path | Shared | Use Case |
|-------|------|--------|----------|
| **Personal** | `~/.claude/skills/skill-name/SKILL.md` | No | Individual workflows |
| **Project** | `.claude/skills/skill-name/SKILL.md` | Yes (git) | Team conventions |
| **Plugin** | Bundled in plugin | Via plugin | Distributed capabilities |

---

## Progressive Disclosure Pattern

**Directory Structure:**
```
my-skill/
├── SKILL.md              # Required - keep concise
├── reference.md          # Optional - loaded on demand
├── examples.md           # Optional - detailed examples
├── scripts/
│   └── helper.py         # Optional utilities
└── templates/
    └── template.txt      # Optional templates
```

**Cross-references in SKILL.md:**
```markdown
For form filling details, see [FORMS.md](FORMS.md).
For API reference, see [REFERENCE.md](REFERENCE.md).
```

Claude loads additional files **only when referenced**, keeping context efficient.

---

## The `allowed-tools` Field

**NEW - Not in previous research!**

Restricts Claude to specific tools without permission requests:

```yaml
---
name: code-analyzer
description: Analyze code quality without making changes. Use for audits and reviews.
allowed-tools: Read, Grep, Glob
---
```

**Use Cases:**
- Read-only analysis skills
- Security-sensitive workflows
- Scoped operations (no file writing)

---

## Description Best Practices

**Discovery depends on description quality!**

### Bad (too vague)
```yaml
description: For data analysis
```

### Good (specific + triggers)
```yaml
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when working with Excel files, spreadsheets, or analyzing tabular data in .xlsx format.
```

**Include:**
- Specific capabilities (what it does)
- Trigger terms (when to use)
- File types/contexts

---

## Troubleshooting

### Claude doesn't use my Skill?
1. Make description **specific** - include WHAT + WHEN
2. Add **trigger terms** users would mention
3. Verify **YAML syntax** - proper `---` delimiters, no tabs
4. Check **file path** - `.claude/skills/name/SKILL.md`

### Multiple Skills conflict?
Use **distinct trigger terms**:
- Instead of: "for data analysis" (both)
- Use: "for sales data in Excel" vs "for log files and system metrics"

---

## Example: Complete Skill

```
requirements-clarifier/
├── SKILL.md
├── examples.md
└── templates/
    └── questions-template.md
```

**SKILL.md:**
```yaml
---
name: requirements-clarifier
description: Prevents premature implementation by ensuring genuine understanding. Use when user requests new features or changes with ambiguous requirements. Asks clarifying questions before coding.
allowed-tools: Read, Glob, Grep
---

# Requirements Clarifier

## Purpose
Ensure full understanding before any implementation begins.

## When to Activate
- User requests new feature with vague description
- Requirements have multiple interpretations
- Technical approach is unclear

## Protocol
1. **Restate Understanding** - Prove comprehension
2. **Identify Ambiguities** - Ask specific questions with options
3. **Surface Assumptions** - State explicitly for validation
4. **Get Agreement** - Explicit confirmation before coding

## Examples
See [examples.md](examples.md) for detailed scenarios.
```

---

## Impact on Your Plugin

Your `thoughtful-dev` plugin uses Skills correctly, but consider:

1. **Add `allowed-tools`** - For read-only skills like `requirements-clarifier`
2. **Progressive disclosure** - Move detailed content to separate files
3. **Refine descriptions** - Add more trigger terms

Example improvement:
```yaml
---
name: requirements-clarifier
description: Prevents premature implementation by ensuring genuine understanding. Use when user requests new features, asks for changes with ambiguous requirements, says "build", "implement", "create", or "add feature". Activates for vague requests that need clarification before coding.
allowed-tools: Read, Glob, Grep, AskUserQuestion
---
```

---

## Sources

- [Official Skills Documentation](https://code.claude.com/docs/en/skills)
