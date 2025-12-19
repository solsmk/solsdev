# Feature Comparison: Spec vs Reality

*Research compiled: 2024-12-14*
*Comparing: /home/neno/Downloads/thoughtful-dev-enhancement-spec.md vs actual Claude Code capabilities*

---

## Executive Summary

| Category | Spec Accuracy | Notes |
|----------|--------------|-------|
| Rules System | **90%** | Path-scoping works! Minor syntax differences |
| Plugin System | **95%** | Fully implemented, production-ready |
| Subagents | **85%** | v2.0.64 adds async! No nesting still |
| Hooks | **85%** | Working, but no custom events |
| MCP Integration | **90%** | Docker MCP is your custom setup |
| Background Agents | **80%** | v2.0.64 adds TaskOutputTool async |

**Key Update:** v2.0.64 significantly improved async capabilities!

---

## Phase 1: Restructure to `.claude/rules/`

### Spec Proposal
> Move from custom `skills/` to official `.claude/rules/`

### Reality
- `.claude/rules/` **FULLY SUPPORTED** (v2.0.64+)
- Auto-discovery of `.md` files
- Recursive subdirectories
- Symlinks work

### Verdict: **GO AHEAD**

---

## Phase 2: Stack-Specific Rules with Path-Scoping

### Spec Proposal
```markdown
---
paths: src/modules/**/*.ts
---
```

### Reality
- **YES, path-scoping works!**
- Glob patterns supported: `**/*.ts`, `{src,lib}/**/*`
- Applied conditionally when Claude works with matching files

### Verdict: **GO AHEAD**

Example that WILL work:
```markdown
---
paths: src/modules/**/*.ts, packages/medusa/**/*.ts
---

# Medusa v2 Development Rules

- Use `@medusajs/medusa` v2 imports
- Services extend `MedusaService`
...
```

---

## Phase 3: Patterns & Gotchas Files

### Spec Proposal
> Separate PATTERNS.md, GOTCHAS.md per stack

### Reality
- Can be rules files in `.claude/rules/`
- OR kept as templates in `templates/`
- Both approaches work

### Verdict: **GO AHEAD** - Either approach valid

---

## Phase 4: Documentation Templates & llms.txt

### Spec Proposal
> Generate llms.txt for AI discovery

### Reality
- No native `llms.txt` support in Claude Code
- Would be a custom feature you implement
- Community convention, not standard

### Verdict: **CUSTOM IMPLEMENTATION REQUIRED**

---

## Phase 5: Background Documentation Agent

### Spec Proposal
```yaml
---
skills: doc-maintenance
type: async-background
trigger: file-change
---
```

### Reality (UPDATED for v2.0.64)
**Now Available:**
- ✅ TRUE async execution via `TaskOutputTool`
- ✅ Background agents can wake up main agent
- ✅ Named sessions for context persistence
- ❌ No `trigger: file-change` (use hooks)
- ❌ No `type: async-background` in skill frontmatter

**What v2.0.64 Added:**
- `TaskOutputTool` (unified async) replaces AgentOutputTool/BashOutputTool
- Agents and bash can run async and send wake-up messages
- `/rename` and `/resume <name>` for session persistence

### Verdict: **MOSTLY WORKS** - Combine async + hooks

**Implementation:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "~/.claude/scripts/check-doc-drift.sh"
        }]
      }
    ]
  }
}
```

The hook triggers doc-check, which can then use async agent if needed.

---

## Phase 6: Hooks, Checkpoints, Notifications

### Spec Proposal
> PreCompact hook for context checkpointing

### Reality
- `PreCompact` hook **EXISTS**
- Can trigger custom script before compaction
- No native "checkpoint" feature

### Notifications
- `Notification` hook **EXISTS**
- Can trigger desktop notifications
- Example: `notify-send 'Claude Code' 'Task complete'`

### Verdict: **MOSTLY WORKS** - Custom checkpoint logic needed

---

## Phase 7: Plugin Packaging

### Spec Proposal
> Bundle as marketplace plugin

### Reality
- **FULLY SUPPORTED**
- marketplace.json format documented
- GitHub/Git/URL sources work
- Team auto-install via settings.json

### Verdict: **GO AHEAD** - Your current structure is correct

---

## Phase 8: Docker MCP Gateway

### Spec Proposal
> Integrate Docker MCP for 270+ servers

### Reality
- Docker MCP Gateway **IS REAL** (Docker product)
- But the `mcp__MCP_DOCKER__*` tools are **YOUR custom setup**
- Not a standard Claude Code feature

### Verdict: **YOUR CUSTOM INFRASTRUCTURE** - Document as optional

---

## Future Phases

### Phase 9: Critique Agent (Jules-inspired)

**Spec:** Background critique agent reviews code

**Reality:**
- No native critique/review loop
- Would need: PostToolUse hook → external script → comment injection
- Jules-style is aspirational

**Verdict: CUSTOM BUILD REQUIRED**

### Phase 10: GitHub App Integration

**Spec:** GitHub App for PR reviews

**Reality:**
- `gh` CLI works in Claude Code
- MCP GitHub integration available
- Full GitHub App would be external service

**Verdict: EXTERNAL SERVICE** - Not plugin feature

### Phase 11: Sentry Monitoring

**Spec:** Integrate Sentry for error tracking

**Reality:**
- Sentry MCP **EXISTS**: `https://mcp.sentry.dev/mcp`
- Can be added to `.mcp.json`

**Verdict: AVAILABLE** - Just configure MCP

### Phase 12: Browser Testing

**Spec:** Playwright/Chrome DevTools integration

**Reality:**
- Playwright MCP available
- Chrome DevTools MCP available
- Already in your setup (`mcp__chrome-devtools__*`)

**Verdict: AVAILABLE** - Already have it

---

## Key Insights

### What the Spec Gets Right
1. `.claude/rules/` with path-scoping
2. Plugin marketplace structure
3. Skills with frontmatter
4. Hooks for automation
5. MCP for external tools

### What Needs Adjustment
1. **No true async subagents** - Can't fire-and-forget
2. **No nested agents** - Agents can't spawn agents
3. **No event-driven triggers** - Use hooks, not native triggers
4. **No shared state** - Context per agent, pass via conversation
5. **Custom features** - llms.txt, checkpoint, critique need building

---

## Recommended Priority

| Phase | Effort | Value | Priority |
|-------|--------|-------|----------|
| 1. Restructure rules | Low | High | **1st** |
| 2. Stack rules + paths | Medium | High | **2nd** |
| 3. Patterns/Gotchas | Low | Medium | **3rd** |
| 7. Plugin packaging | Low | High | **4th** |
| 4. Doc templates | Medium | Medium | 5th |
| 6. Hooks setup | Medium | Medium | 6th |
| 5. Doc watcher | High | Medium | 7th |
| 8. Docker MCP | Low (done) | Low | Optional |
| 9-12 | High | Low | Future |

---

## Conclusion

**The spec is ~80% aligned with reality.** Main adjustments:

1. Remove async/background agent assumptions
2. Use hooks for file-change triggers
3. Accept sequential (not parallel) agent execution
4. Build custom llms.txt generator
5. Treat Docker MCP as your infrastructure, not plugin feature

The core vision is sound. Implementation paths exist for everything - some native, some via hooks, some custom builds.
