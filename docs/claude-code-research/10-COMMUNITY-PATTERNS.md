# Community Patterns & Best Practices

*Research compiled: 2024-12-14*
*Sources: wshobson/agents, davila7/claude-code-templates*

---

## wshobson/agents - Granular Plugin Design

**Stats:** 65 plugins, 91 agents, 47 skills, 45 tools
**Philosophy:** Single responsibility, minimal token usage

### Three-Tier Model Strategy

| Tier | Model | Count | Use Case |
|------|-------|-------|----------|
| **1** | Opus | 42 | Critical: architecture, security, ALL code review |
| **2** | Inherit | 42 | Complex: user chooses (AI/ML, specialized) |
| **3** | Sonnet | 51 | Support: docs, testing, debugging, legacy |
| **4** | Haiku | 18 | Fast: SEO, deployment, simple docs |

**Orchestration Pattern:**
```
Planning (Opus) → Execution (Sonnet/Haiku) → Review (Opus)
```

### Granular Plugin Principles

1. **Single Responsibility**
   - Each plugin does ONE thing well
   - Average: 3.4 components per plugin
   - Clear, focused purposes

2. **Composability**
   - Mix and match plugins
   - Workflow orchestrators compose focused plugins
   - No forced bundling

3. **Context Efficiency**
   - Smaller = faster processing
   - Better fit in context windows
   - Install only what you need

### Plugin Structure Pattern

```
plugins/
├── python-development/
│   ├── agents/
│   │   ├── python-pro.md
│   │   ├── django-pro.md
│   │   └── fastapi-pro.md
│   ├── commands/
│   │   └── python-scaffold.md
│   └── skills/
│       ├── async-python-patterns/
│       ├── python-testing-patterns/
│       └── uv-package-manager/
```

### Skills Progressive Disclosure

```
skills/async-python-patterns/
├── SKILL.md           # Concise entry point
├── patterns.md        # Detailed patterns (loaded on demand)
├── examples.md        # Code examples (loaded on demand)
└── gotchas.md         # Common issues (loaded on demand)
```

### Category Organization

| Category | Plugins | Focus |
|----------|---------|-------|
| Languages | 7 | Python, JS/TS, Rust, Go, etc. |
| Infrastructure | 5 | K8s, Cloud, CI/CD, Deploy |
| Security | 4 | SAST, Compliance, API, Frontend |
| Operations | 4 | Incident, Diagnostics, Monitoring |
| AI/ML | 4 | LLM, Agents, MLOps, Context |
| Quality | 3 | Review, Performance, Testing |
| Documentation | 3 | Code docs, API, Diagrams |

---

## davila7/claude-code-templates - CLI Component System

**Stats:** 600+ agents, 200+ commands, extensive MCPs
**Focus:** CLI tool for component installation

### Component Types

| Type | Count | Example |
|------|-------|---------|
| Agents | 600+ | `security-auditor`, `frontend-developer` |
| Commands | 200+ | `/setup-ci-cd`, `/generate-tests` |
| MCPs | 50+ | `postgresql`, `github`, `stripe` |
| Settings | 30+ | `performance`, `security`, `statuslines` |
| Hooks | 20+ | `auto-git-add`, `lint-on-save` |

### Installation Pattern

```bash
# Individual components
npx claude-code-templates@latest --agent security-auditor
npx claude-code-templates@latest --command setup-testing
npx claude-code-templates@latest --mcp postgresql

# Batch installation
npx claude-code-templates@latest \
  --agent security-auditor \
  --command security-audit \
  --setting read-only-mode
```

### Statusline with Python Scripts

Unique pattern - statuslines can reference external scripts:

```javascript
// Files downloaded to .claude/scripts/
if (settingName.includes('statusline/')) {
  const pythonFileName = settingName.split('/')[1] + '.py';
  additionalFiles['.claude/scripts/' + pythonFileName] = {
    content: pythonContent,
    executable: true
  };
}
```

### Agent Structure

```markdown
---
name: security-auditor
description: Security specialist. Use PROACTIVELY after code changes.
model: opus
tools: Read, Grep, Glob, Bash
---

You are a security expert specializing in...

## Responsibilities
1. Review for vulnerabilities
2. Check OWASP Top 10
3. Validate input handling

## Process
...
```

---

## Patterns to Adopt

### From wshobson/agents

1. **Tiered model assignment** - Opus for critical, Haiku for fast
2. **Granular plugins** - 2-8 components each
3. **Progressive disclosure** - Separate files for details
4. **Clear categories** - Easy discovery

### From davila7/claude-code-templates

1. **Component CLI** - Easy installation
2. **Batch operations** - Multiple components at once
3. **Script bundling** - Include helper scripts
4. **Analytics tracking** - Usage metrics

---

## Recommended Plugin Size

| Size | Components | Use Case |
|------|------------|----------|
| **Micro** | 1-2 | Single focused tool |
| **Small** | 3-5 | Typical plugin |
| **Medium** | 6-8 | Domain coverage |
| **Large** | 9+ | Split into multiple plugins |

**Your thoughtful-dev:** 3 commands + 4 skills = **7 components** (good size)

---

## Sources

- [wshobson/agents](https://github.com/wshobson/agents)
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
