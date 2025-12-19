# SolsDev - Claude Code Plugin

Opinionated development workflow for **Medusa v2 + Strapi 5 + Next.js 15/16** teams.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-purple)

---

## What This Does

**Path-scoped stack rules** + **cognitive enhancement skills** for modern commerce stacks.

### Path-Scoped Rules (New in v2.0)

Rules automatically activate when working with matching files:

| Rule | Activates For | Key Topics |
|------|---------------|------------|
| `medusa-v2.md` | `**/medusa/**`, `**/workflows/**` | 18 commerce modules, workflow compensation, container DI |
| `strapi-5.md` | `**/strapi/**`, `**/cms/**` | Document Service API, documentId, population syntax |
| `nextjs-15.md` | `**/app/**`, `**/*.tsx` | Async APIs, caching OFF by default, Server Components |
| `shadcn-ui.md` | `**/components/ui/**` | Copy-paste components, CLI, CSS variables theming |
| `heroui.md` | `**/@heroui/**` | Compound components, React Aria, Framer animations |
| `tailwind-v4.md` | `**/*.css` | CSS-first config, v4 breaking changes, container queries |
| `meilisearch.md` | `**/search/**` | JS SDK, filter syntax, Medusa/Strapi integration |
| `coolify.md` | `**/docker-compose*.yml` | Self-hosted PaaS, build packs, env vars |
| `docker.md` | `**/Dockerfile*` | Multi-stage builds, npm ci, health checks |

Plus cross-stack **patterns**: `cart-checkout.md`, `cms-integration.md`, `gotchas.md`

### Cognitive Enhancement Skills

1. **Requirements Clarifier** - Surfaces ambiguity before coding starts
2. **Implementation Planner** - Analyzes approaches and risks before writing code
3. **Breakthrough Generator** - Systematic problem-solving when stuck
4. **Documentation Maintenance** - Keeps docs synchronized with code

---

## Quick Install

```bash
# Add marketplace
/plugin marketplace add Neno73/solsdev

# Install plugin
/plugin install solsdev
```

### Team Auto-Install

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "solsdev-marketplace": {
      "source": {
        "source": "github",
        "repo": "Neno73/solsdev"
      }
    }
  },
  "enabledPlugins": ["solsdev"]
}
```

---

## What's Included

### Stack Rules (`.claude/rules/stacks/`)

| Category | Rules |
|----------|-------|
| **Core Stack** | Medusa v2, Strapi 5, Next.js 15 |
| **UI & Styling** | shadcn/ui, HeroUI, Tailwind CSS v4 |
| **Infrastructure** | Meilisearch, Coolify, Docker |

### Pattern Rules (`.claude/rules/patterns/`)

- `cart-checkout.md` - Cart state, payment sessions, order completion
- `cms-integration.md` - Strapi client, media URLs, caching
- `gotchas.md` - Cross-stack integration issues

### Skills

| Skill | Size | Purpose |
|-------|------|---------|
| Requirements Clarifier | 18KB | Prevents coding before understanding |
| Implementation Planner | 23KB | Analyzes trade-offs before implementation |
| Breakthrough Generator | 68KB | Systematic problem-solving |
| Doc Maintenance | 8KB | Keeps documentation current |

### Commands

| Command | Purpose |
|---------|---------|
| `/solsdev:init-project` | Analyze codebase, create documentation |
| `/solsdev:init-personal` | Setup personal CLAUDE.md |
| `/solsdev:audit-docs` | Check documentation drift |

---

## Decision Trees

### Which Stack Owns What?

```
Product/pricing/inventory? → Medusa
Marketing content/blog/SEO? → Strapi
Rendering/routing/caching?  → Next.js
Search indexing?            → Meilisearch
Deployments?                → Coolify + Docker
```

### Which UI Library?

```
Need full code ownership?    → shadcn/ui (copy-paste)
Need batteries-included?     → HeroUI (package)
Custom design system?        → Tailwind CSS directly
```

---

## Example: Rules in Action

When you edit `apps/web/app/cart/page.tsx`:

```
Claude automatically loads:
  → nextjs-15.md (matches **/app/**)
  → cart-checkout.md (matches **/cart/**)
  → gotchas.md (always available)

Now Claude knows:
  - await params/cookies (Next.js 15 async APIs)
  - Cart hydration SSR issues
  - Medusa cart completion flow
```

---

## Safety Features

### Git Workflow Protection

```
User: "git push origin main"

Claude: [STOPS]
"Creating feature branch instead:
$ git checkout -b feature/your-feature
$ git push origin feature/your-feature"
```

### Database Safety

```
User: "Drop the users table"

Claude: [ASKS]
"DESTRUCTIVE OPERATION DETECTED
This will permanently delete all user data.
Are you absolutely sure? (yes/no)"
```

---

## Architecture Philosophy

Based on **Eskil Steenberg's Black-Box Architecture**:

1. **Constant Velocity** - Write 5 new lines vs. edit 1 line later
2. **Complete Ownership** - One module, one person
3. **Everything Replaceable** - Can't understand it? Rewrite it.
4. **Clean Interfaces** - Hide implementation details
5. **Single Responsibility** - One module, one purpose

---

## Documentation

- [Installation Guide](./INSTALL.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)
- [Roadmap](./ROADMAP.md)
- [License](./LICENSE)

### Rules Documentation

- [Rules Index](./.claude/rules/INDEX.md) - Quick reference for all rules
- [Contributing to Rules](./.claude/rules/CONTRIBUTING.md) - How to add/update rules

---

## Contributing

Contributions welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md).

**Ways to contribute:**
- Report bugs via [Issues](https://github.com/Neno73/solsdev/issues)
- Submit pull requests
- Add stack rules for new technologies
- Improve pattern documentation

---

## License

MIT License - see [LICENSE](./LICENSE) file.

---

## Acknowledgments

Built on Claude Code plugin system by Anthropic.

Inspired by:
- Eskil Steenberg's Black-Box Architecture
- Community best practices from Claude Code users
- Real-world Medusa + Strapi + Next.js projects

---

## Support

- **Issues:** [GitHub Issues](https://github.com/Neno73/solsdev/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Neno73/solsdev/discussions)

---

**Path-scoped rules for thoughtful development!**
