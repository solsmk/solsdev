# Claude Code Research Documentation

*Compiled: 2024-12-14*
*Purpose: Verify capabilities before implementing thoughtful-dev enhancement spec*

---

## Quick Reference

| Document | What It Covers |
|----------|---------------|
| [01-SUBAGENTS](01-SUBAGENTS.md) | Creating agents, async execution, built-in agents, limitations |
| [02-RULES-SYSTEM](02-RULES-SYSTEM.md) | `.claude/rules/`, path-scoping, @import syntax |
| [03-HOOKS-SYSTEM](03-HOOKS-SYSTEM.md) | Event hooks, automation triggers, examples |
| [04-MCP-INTEGRATION](04-MCP-INTEGRATION.md) | MCP servers, configuration, common setups |
| [05-PLUGIN-SYSTEM](05-PLUGIN-SYSTEM.md) | Plugin structure, marketplaces, distribution |
| [06-SPEC-VS-REALITY](06-SPEC-VS-REALITY.md) | **START HERE** - Spec accuracy analysis |
| [07-SKILLS-OFFICIAL](07-SKILLS-OFFICIAL.md) | **IMPORTANT** - Official skills spec, `allowed-tools` |
| [08-MCP-GATEWAYS](08-MCP-GATEWAYS.md) | Docker MCP Gateway vs MetaMCP comparison |
| [09-CLAUDE-COOKBOOKS](09-CLAUDE-COOKBOOKS.md) | Anthropic examples - RAG, tools, agents |
| [10-COMMUNITY-PATTERNS](10-COMMUNITY-PATTERNS.md) | wshobson + davila7 best practices |
| [LINKS](LINKS.md) | All URLs in one place |

---

## Key Findings (Updated for v2.0.64)

### What Works (Go Ahead)
- `.claude/rules/` with path-scoping frontmatter
- Plugin marketplace system
- Skills with auto-invocation + `allowed-tools`
- Hooks for automation
- MCP for external tools
- **Async agents via TaskOutputTool** (NEW)
- **Named sessions** `/rename` + `/resume` (NEW)

### What Needs Adjustment
- No nested agents (agents can't spawn agents)
- No event-driven triggers (use hooks instead)
- No shared state between agents
- Custom builds needed for llms.txt, critique agent

---

## Reference Repositories

| Repo | What It Demonstrates |
|------|---------------------|
| [wshobson/agents](https://github.com/wshobson/agents) | 65 plugins, 91 agents, 47 skills - granular design |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | CLI tool, component system, analytics |

**Local Clones:**
- `/home/neno/Code/wshobson-agents/`
- `/home/neno/Code/claude-code-templates/`

---

## Official Documentation Links

- [Sub-Agents](https://code.claude.com/docs/en/sub-agents)
- [Memory/Rules](https://code.claude.com/docs/en/memory)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [MCP Integration](https://code.claude.com/docs/en/mcp)
- [Plugins](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)

---

## Implementation Recommendations

### Phase 1-2 (Do First)
1. Migrate skills → `.claude/rules/`
2. Add path-scoped stack rules (Medusa, Strapi, Next.js)

### Phase 3-4 (Next)
3. Create PATTERNS.md and GOTCHAS.md templates
4. Update plugin packaging

### Phase 5-6 (Later)
5. Implement doc-watcher via PostToolUse hooks
6. Add notification hooks

### Phase 7+ (Future)
7. Custom llms.txt generator
8. Consider critique agent pattern (complex)
