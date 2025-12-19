# SolsDev Roadmap

*Strategic plan for evolving the Claude Code plugin for Medusa v2 + Strapi 5 + Next.js 15/16 teams*

---

## Current Release: v2.0.0 (December 2025)

### What's Included

**Path-Scoped Stack Rules (9 stacks):**
- Medusa v2 - Commerce engine patterns
- Strapi 5 - Headless CMS patterns
- Next.js 15 - App Router patterns
- shadcn/ui - Component library
- HeroUI - UI framework
- Tailwind CSS v4 - Styling
- Meilisearch - Search engine
- Coolify - Self-hosted PaaS
- Docker - Containerization

**Cross-Stack Patterns:**
- Cart & Checkout flows
- CMS integration patterns
- Integration gotchas

**Cognitive Skills:**
- Requirements Clarifier
- Implementation Planner
- Breakthrough Generator
- Documentation Maintenance

**Infrastructure:**
- Path-scoped rule system
- Documentation templates
- Background doc-watcher agent
- Auto-triggered hooks
- **Docker MCP Gateway** - Unified MCP server management
  - 15+ MCP servers (Medusa, Strapi, GitHub, PostgreSQL, etc.)
  - 6 workflow profiles (fullstack, frontend, backend, debugging, research, minimal)
  - Security features (rate limiting, secret blocking, signature verification)
  - One-command setup and Claude Code integration

---

## Version History

| Version | Date | Focus |
|---------|------|-------|
| **2.0.0** | 2025-12-15 | Path-scoped rules, rename to SolsDev, stack-specific focus |
| 1.0.5 | 2025-10-26 | Documentation maintenance system |
| 1.0.0 | 2025-10-26 | Initial release as Thoughtful Dev |

---

## Roadmap Overview

```
v2.0.0 (Current)    v2.1.0           v2.2.0           v3.0.0 (Future)
    │                  │                │                    │
    │                  │                │                    │
Foundation       Polish & Test    Community Growth    Advanced AI
    │                  │                │                    │
    ├─ 9 Stack Rules   ├─ llms.txt ✅    ├─ Example Repos    ├─ Critique Agent
    ├─ 3 Patterns      ├─ Full Hooks    ├─ Tutorials        ├─ GitHub Integration
    ├─ 4 Skills        ├─ Validation    ├─ Plugin Growth    ├─ Sentry Monitoring
    ├─ Doc-watcher     └─ Fixes         └─ Feedback Loop    └─ Browser Testing
    └─ MCP Gateway ✅
```

---

## v2.1.0 - Polish & Validation (Q1 2026)

**Goal:** Ensure v2.0 foundation is solid and complete core documentation features.

### High Priority

- [x] **Generate llms.txt** - AI-optimized documentation index ✅ **DONE in v2.0.0**
  - ~~Script: `scripts/generate-llms-txt.sh`~~ (manual for now)
  - Auto-regenerate on doc changes (future)
  - Include all rules, patterns, templates

- [ ] **Complete Hooks Suite**
  - Pre-commit documentation check
  - Session start guidance
  - Notification hooks (desktop alerts)
  - Pre-compact checkpoint saving

- [ ] **Test & Fix Doc-Watcher**
  - Validate hook triggers correctly
  - Verify documentation updates
  - Handle edge cases (rapid edits, large changes)
  - Performance tuning (Haiku vs Sonnet)

### Medium Priority

- [ ] **Plugin Installation Validation**
  - Test marketplace installation flow
  - Verify team auto-install works
  - Document common installation issues
  - Create installation video/guide

- [ ] **Documentation Review**
  - Proofread all 9 stack rules
  - Verify code examples are current
  - Update version numbers
  - Add missing gotchas from field usage

### Low Priority

- [ ] **Improved Error Messages**
  - Better rule loading errors
  - Hook failure guidance
  - Path-scoping debug mode

**Target Release:** January 2026

---

## v2.2.0 - Community Growth (Q2 2026)

**Goal:** Get SolsDev into hands of Medusa/Strapi/Next.js teams and iterate based on feedback.

### High Priority

- [ ] **Example Repositories**
  - Create `solsdev-examples` repo
  - Full e-commerce site using all 3 stacks
  - Documented with `.claude/` directory
  - Show best practices in action

- [ ] **Tutorial Content**
  - "Getting Started with SolsDev" guide
  - Video walkthrough of features
  - Blog post: "How SolsDev Saves Development Time"
  - Integration guides (Medusa + Strapi patterns)

- [ ] **User Feedback Loop**
  - Set up GitHub Discussions
  - Issue templates for rule improvements
  - Community gotchas submission
  - Usage analytics (if opt-in)

### Medium Priority

- [x] **Docker MCP Gateway** ✅ **DONE in v2.0.0**
  - 15+ MCP servers integrated
  - 6 workflow profiles
  - Security and rate limiting
  - One-command setup scripts

- [ ] **Expand Stack Coverage**
  - PostgreSQL patterns (database migrations, queries)
  - Redis patterns (caching, sessions)
  - Vercel deployment patterns
  - Testing frameworks (Vitest, Playwright)

- [ ] **Integration with github-push-pr Plugin**
  - Document combined usage
  - Create workflow examples
  - Consider bundling or keeping separate

### Low Priority

- [ ] **Community Contributions**
  - Accept community-submitted stack rules
  - Guest-written patterns
  - Translations (if demand exists)

**Target Release:** April 2026

---

## v2.3.0 - Developer Experience (Q3 2026)

**Goal:** Enhance productivity with better tooling and workflows.

### Planned Features

- [ ] **Commands Enhancement**
  - `/solsdev:diagnose` - Check plugin health
  - `/solsdev:sync` - Update all rules from marketplace
  - `/solsdev:profile` - Show which rules are loading

- [ ] **Rule Improvements**
  - Version-specific rules (Next.js 14 vs 15 vs 16)
  - Framework upgrade guides
  - Migration patterns

- [ ] **Performance Optimization**
  - Lazy-load rules (only when needed)
  - Rule caching
  - Faster path-scoping matching

**Target Release:** July 2026

---

## v3.0.0 - Advanced AI Features (Q4 2026+)

**Goal:** Leverage cutting-edge Claude Code capabilities for autonomous development workflows.

### Research Phase (Ongoing)

**1. Critique Agent Pattern** (Inspired by Jules)
- Architect agent creates implementation plans
- Critique agent challenges plans adversarially
- Iterative refinement loop
- Only proceed after both agents agree
- **Status:** Research phase - see `docs/claude-code-research/`

**2. GitHub Integration**
- Automated PR reviews
- Issue triage and analysis
- Code suggestions in comments
- Integration via GitHub MCP or official Claude GitHub App
- **Status:** Evaluating approaches

**3. Sentry Monitoring**
- Background agent monitors production errors
- Automatic root cause analysis
- Fix suggestions or GitHub issue creation
- Priority-based alerting
- **Status:** Waiting for Sentry MCP maturity

**4. Browser Testing**
- Visual regression testing
- Performance profiling (Lighthouse, Core Web Vitals)
- Network debugging
- Accessibility audits
- **Status:** Chrome DevTools MCP available, needs integration design

**5. Docker MCP Gateway Infrastructure**
- Unified MCP server management
- Security and secrets handling
- Container isolation
- On-demand server activation
- **Status:** Deprioritized - current MCP integration sufficient

### Implementation Criteria

These features will only be implemented if:
1. ✅ **User demand exists** - GitHub issues requesting the feature
2. ✅ **Technology is stable** - MCP servers are production-ready
3. ✅ **Clear value proposition** - Significant time savings demonstrated
4. ✅ **Maintainability** - Can be supported long-term

**Target Release:** TBD based on research outcomes

---

## Beyond v3.0 - Vision

### Long-term Ideas (Not Committed)

- **Multi-stack Support:** Expand beyond Medusa/Strapi/Next.js
  - Shopify + Contentful + Remix variant?
  - WooCommerce + WordPress + Laravel variant?

- **Team Collaboration Features:**
  - Shared rule libraries
  - Team-specific gotchas repositories
  - Collaborative documentation editing

- **AI Pair Programming Workflows:**
  - Live coding sessions with Claude
  - Real-time code review
  - Automated test generation

- **Enterprise Features:**
  - Custom rule authoring UI
  - Analytics dashboard
  - Compliance and security scanning

---

## Decision Framework

### How We Prioritize

Features are evaluated on:

| Criteria | Weight | Description |
|----------|--------|-------------|
| **User Impact** | 40% | How many users benefit? How much time saved? |
| **Effort** | 30% | Development + maintenance cost |
| **Strategic Fit** | 20% | Aligns with Medusa/Strapi/Next.js focus? |
| **Technical Risk** | 10% | Dependencies, Claude Code API stability |

### What We Won't Build

- Features unrelated to Medusa/Strapi/Next.js stack
- Generic development tools (other plugins do this better)
- Features requiring paid external services (unless high demand)
- Complex infrastructure requiring constant maintenance

---

## Contributing to the Roadmap

We welcome input! Here's how to influence direction:

1. **Request Features:** Open GitHub issue with use case
2. **Share Gotchas:** Submit integration issues you've encountered
3. **Write Rules:** Contribute stack rules or patterns
4. **Vote:** 👍 issues you want prioritized

**GitHub:** https://github.com/Neno73/solsdev

---

## Success Metrics

### v2.x Goals (2026)

- 📦 **500+ plugin installations** across Medusa/Strapi/Next.js teams
- ⭐ **100+ GitHub stars** indicating community interest
- 📝 **50+ community-submitted gotchas** enriching the knowledge base
- 🐛 **90%+ rule accuracy** - rules provide correct guidance
- ⚡ **30%+ faster onboarding** - new devs productive faster with SolsDev

### v3.x Goals (2027)

- 🤖 **Advanced AI workflows** proven valuable in production
- 🌍 **Community ecosystem** - third-party rules and integrations
- 🏢 **Enterprise adoption** - companies standardizing on SolsDev
- 📚 **Reference implementation** - the go-to resource for this stack

---

## Stay Updated

- **Changelog:** [CHANGELOG.md](./CHANGELOG.md)
- **Releases:** [GitHub Releases](https://github.com/Neno73/solsdev/releases)
- **Discussions:** [GitHub Discussions](https://github.com/Neno73/solsdev/discussions)

---

*Last updated: 2025-12-19*
*Next review: 2026-01-15*

**Roadmap Philosophy:** Ship iteratively. Validate with users. Build what's proven valuable.
