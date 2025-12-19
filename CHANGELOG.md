# Changelog

All notable changes to the SolsDev plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-12-15

### Major Release - Path-Scoped Stack Rules

Complete rewrite focused on **Medusa v2 + Strapi 5 + Next.js 15/16** teams with automatic path-scoped rule loading.

---

### Added

#### Path-Scoped Rules System

Rules now automatically activate when working with matching files:

**Core Stack Rules:**
| Rule | Paths | Topics |
|------|-------|--------|
| `medusa-v2.md` | `**/medusa/**`, `**/workflows/**` | 18 commerce modules, workflow compensation, container DI |
| `strapi-5.md` | `**/strapi/**`, `**/cms/**` | Document Service API, documentId, population syntax |
| `nextjs-15.md` | `**/app/**`, `**/*.tsx` | Async APIs, caching OFF by default, Server Components |

**UI & Styling Rules:**
| Rule | Paths | Topics |
|------|-------|--------|
| `shadcn-ui.md` | `**/components/ui/**` | Copy-paste components, CLI, CSS variables |
| `heroui.md` | `**/@heroui/**` | Compound components, React Aria, Framer Motion |
| `tailwind-v4.md` | `**/*.css` | CSS-first config, v4 breaking changes, container queries |

**Infrastructure Rules:**
| Rule | Paths | Topics |
|------|-------|--------|
| `meilisearch.md` | `**/search/**` | JS SDK, filter syntax, Medusa/Strapi integration |
| `coolify.md` | `**/docker-compose*.yml` | Self-hosted PaaS, build packs, env vars |
| `docker.md` | `**/Dockerfile*` | Multi-stage builds, npm ci, health checks |

**Cross-Stack Patterns:**
- `cart-checkout.md` - Cart state, payment sessions, order completion
- `cms-integration.md` - Strapi client, media URLs, caching
- `gotchas.md` - Integration issues, data ownership

#### Rules Documentation

- `INDEX.md` - Quick reference with decision trees and error mappings
- `CONTRIBUTING.md` - Instructions for AI agents adding/updating rules
- `README.md` - How rules system works

#### Key Features

Each rule file includes:
- **Documentation & Resources** table with official links
- **Current Version** number
- **BAD/GOOD code examples** with explanations
- **Critical Gotchas** section
- **Error → Fix** lookup tables
- **Integration patterns** for cross-stack usage

### Changed

- **Renamed from Thoughtful Dev to SolsDev**
- **Focus shifted** from generic plugin to Medusa/Strapi/Next.js stack
- **Plugin structure** updated to support path-scoped rules
- **Commands renamed** from `/thoughtful-dev:*` to `/solsdev:*`
- **Repository** moved from `Neno73/thoughtful-dev` to `Neno73/solsdev`

### Migration from v1.x

If upgrading from Thoughtful Dev v1.x:

```bash
# Uninstall old plugin
/plugin uninstall thoughtful-dev
/plugin marketplace remove thoughtful-dev-marketplace

# Install new plugin
/plugin marketplace add Neno73/solsdev
/plugin install solsdev
```

Update your project settings:
```json
{
  "extraKnownMarketplaces": {
    "solsdev-marketplace": {
      "source": { "source": "github", "repo": "Neno73/solsdev" }
    }
  },
  "enabledPlugins": ["solsdev"]
}
```

---

## [1.0.5] - 2025-10-26

### Documentation Maintenance System (Phase 1)

#### Added
- **doc-maintenance skill** - Auto-reminder after implementing features
- **`/thoughtful-dev:audit-docs` command** - Comprehensive drift detection
- Enhanced `/thoughtful-dev:init-project` with maintenance instructions

---

## [1.0.4] - 2025-10-26

### CLAUDE.md Memory Architecture

#### Changed
- Updated `/thoughtful-dev:init-project` command
- Creates optimal hierarchical memory structure
- Root CLAUDE.md now lean with `@import` statements
- Modular `.claude/` documentation

---

## [1.0.3] - 2025-10-26

### Intelligent Initialization Commands

#### Added
- `/thoughtful-dev:init-project [project-name]` - Analyzes codebase
- `/thoughtful-dev:init-personal` - Sets up `~/.claude/CLAUDE.md`

---

## [1.0.2] - 2025-10-26

### Plugin Structure Fix

#### Fixed
- Moved `plugin.json` to `.claude-plugin/` directory
- Simplified `plugin.json` to required fields only
- Removed incorrect "skills" array

---

## [1.0.1] - 2025-10-26

### Critical Bug Fixes

#### Fixed
- Added `plugin.json` with explicit skills registration
- Changed marketplace.json `strict` to `true`
- Removed incorrect `commands` array

---

## [1.0.0] - 2025-10-26

### Initial Release

#### Added

**Core Skills:**
- Requirements Clarifier (18KB)
- Implementation Planner (23KB)
- Breakthrough Generator (68KB)

**Templates:**
- Personal CLAUDE.md (7KB)
- Project documentation (7 files)

**Safety Features:**
- Git workflow protection
- Database operation safety
- Secrets protection

**Architecture Principles:**
- Black-box architecture (Eskil Steenberg)

---

## Version History Overview

| Version | Date | Description |
|---------|------|-------------|
| 2.0.0 | 2025-12-15 | Path-scoped rules, renamed to SolsDev |
| 1.0.5 | 2025-10-26 | Documentation maintenance system |
| 1.0.4 | 2025-10-26 | CLAUDE.md memory architecture |
| 1.0.3 | 2025-10-26 | Initialization commands |
| 1.0.2 | 2025-10-26 | Plugin structure fix |
| 1.0.1 | 2025-10-26 | Critical bug fixes |
| 1.0.0 | 2025-10-26 | Initial release |

---

## Breaking Changes

### v2.0.0

- Plugin renamed from `thoughtful-dev` to `solsdev`
- Repository moved from `Neno73/thoughtful-dev` to `Neno73/solsdev`
- Commands renamed from `/thoughtful-dev:*` to `/solsdev:*`
- Marketplace renamed from `thoughtful-dev-marketplace` to `solsdev-marketplace`

---

## Contributors

- [@Neno73](https://github.com/Neno73) - Creator and maintainer

---

## Links

- [GitHub Repository](https://github.com/Neno73/solsdev)
- [Installation Guide](./INSTALL.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [License](./LICENSE)
