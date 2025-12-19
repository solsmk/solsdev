# Contributing to SolsDev

Thank you for considering contributing to the SolsDev plugin!

---

## Ways to Contribute

### 1. Report Bugs

[Open an issue](https://github.com/Neno73/solsdev/issues) with:
- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Claude Code version

### 2. Suggest Features

[Create a feature request](https://github.com/Neno73/solsdev/issues) with:
- Use case explanation
- Why it would be valuable
- Proposed implementation

### 3. Add Stack Rules

The most valuable contributions! See [Rules Contributing Guide](./.claude/rules/CONTRIBUTING.md) for:
- Rule file structure
- Research requirements
- Quality checklist

### 4. Submit Pull Requests

Fix bugs or add features by:
- Following the development setup below
- Writing clear commit messages
- Testing your changes thoroughly

---

## Development Setup

### Prerequisites

- Claude Code installed
- Git installed
- Basic understanding of Markdown

### Clone and Install

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/solsdev.git
cd solsdev

# Add as local marketplace
/plugin marketplace add ./solsdev

# Install for testing
/plugin install solsdev@solsdev
```

### Test Your Changes

```bash
# After changes, reload the plugin
/plugin reload solsdev

# Or reinstall
/plugin uninstall solsdev
/plugin install solsdev@solsdev
```

---

## Pull Request Process

### 1. Create Feature Branch

```bash
git checkout -b feature/my-feature
```

Branch naming:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `rules/` - Stack rules

### 2. Make Changes

**For Stack Rules:**
- Edit files in `.claude/rules/stacks/`
- Follow structure in [Rules CONTRIBUTING](./.claude/rules/CONTRIBUTING.md)
- Research latest versions before writing
- Include BAD/GOOD code examples

**For Skills:**
- Edit SKILL.md files in `skills/`
- Include practical examples
- Test with real scenarios

**For Patterns:**
- Edit files in `.claude/rules/patterns/`
- Focus on cross-stack integration
- Document common gotchas

### 3. Test Thoroughly

- [ ] Rules activate for matching paths
- [ ] Code examples are syntactically correct
- [ ] Documentation links work
- [ ] No markdown syntax errors

### 4. Commit

```bash
# Good examples
git commit -m "feat(rules): add meilisearch stack rule"
git commit -m "fix(rules): correct strapi populate syntax"
git commit -m "docs: update installation instructions"

# Conventional commits
# feat: New feature
# fix: Bug fix
# docs: Documentation
# rules: Stack rules
# refactor: Code improvement
```

### 5. Push and Create PR

```bash
git push origin feature/my-feature
```

Then:
1. Go to https://github.com/Neno73/solsdev
2. Click "Compare & pull request"
3. Fill in the template

---

## Pull Request Template

```markdown
## Description
[Brief description]

## Type of Change
- [ ] Bug fix
- [ ] New stack rule
- [ ] New pattern
- [ ] Documentation update
- [ ] Skill improvement

## Changes Made
- [List key changes]

## Testing Done
- [ ] Tested locally with Claude Code
- [ ] Verified rule activation
- [ ] Checked documentation links

## Related Issues
Fixes #[issue number]
```

---

## Code Style Guidelines

### Stack Rules

```markdown
---
paths: "**/pattern/**/*"
---

# Technology Rules

*One-line description*

## Documentation & Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://... |

**Current Version**: vX.Y.Z

## Core Concept

```typescript
// GOOD - Explanation
const right = doThing()
```

## Critical Gotchas

### 1. Gotcha Title

```typescript
// BAD
const wrong = ...

// GOOD
const right = ...
```

## Common Error → Fix

| Error | Fix |
|-------|-----|
| `error message` | Solution |
```

### Pattern Files

- Focus on cross-stack integration
- Document data ownership
- Include common error scenarios
- Show complete code examples

---

## Project Structure

```
solsdev/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── .claude/
│   └── rules/
│       ├── INDEX.md              # Quick reference
│       ├── CONTRIBUTING.md       # How to add rules
│       ├── stacks/               # Stack-specific rules
│       │   ├── medusa-v2.md
│       │   ├── strapi-5.md
│       │   ├── nextjs-15.md
│       │   ├── shadcn-ui.md
│       │   ├── heroui.md
│       │   ├── tailwind-v4.md
│       │   ├── meilisearch.md
│       │   ├── coolify.md
│       │   └── docker.md
│       └── patterns/             # Cross-stack patterns
│           ├── cart-checkout.md
│           ├── cms-integration.md
│           └── gotchas.md
├── skills/                       # Plugin skills
│   ├── requirements-clarifier/
│   ├── implementation-planner/
│   ├── breakthrough-generator/
│   └── doc-maintenance/
├── templates/                    # User templates
│   ├── personal-CLAUDE.md
│   └── project-claude/
├── commands/                     # Slash commands
│   ├── init-project.md
│   ├── init-personal.md
│   └── audit-docs.md
├── README.md
├── INSTALL.md
├── CONTRIBUTING.md (this file)
└── CHANGELOG.md
```

---

## Design Principles

### 1. Safety First
- Git workflow protection non-negotiable
- Database operations require confirmation
- Never commit secrets

### 2. Rules Over Prose
- Tables beat paragraphs
- Code examples beat descriptions
- Decision trees beat explanations

### 3. Research First
- Web search for latest versions
- Find official documentation
- Identify breaking changes

### 4. Stack Ownership
- Medusa owns: products, pricing, inventory, orders
- Strapi owns: marketing content, SEO, rich media
- Next.js owns: rendering, routing, caching

---

## Release Process

For maintainers:

1. **Version Bump**
   ```bash
   # Update in:
   # - .claude-plugin/plugin.json
   # - CHANGELOG.md
   # - README.md badges
   ```

2. **Update Changelog**
   ```markdown
   ## [2.1.0] - 2025-XX-XX
   ### Added
   - New stack rule: technology-name.md
   ### Fixed
   - Bug fix description
   ```

3. **Create Release**
   ```bash
   git tag v2.1.0
   git push origin v2.1.0
   ```

---

## Questions?

- **General:** [GitHub Discussions](https://github.com/Neno73/solsdev/discussions)
- **Bugs:** [GitHub Issues](https://github.com/Neno73/solsdev/issues)

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making SolsDev better!**
