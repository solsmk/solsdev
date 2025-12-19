# Claude Code Plugin System - Complete Reference

*Research compiled: 2024-12-14*
*Sources: Official docs, plugin-marketplaces.md, wshobson/agents, davila7/claude-code-templates*

## Overview

Claude Code plugins are packages containing commands, skills, agents, hooks, and MCP servers. They're distributed via **marketplaces** (JSON catalogs on GitHub).

---

## Plugin Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Manifest (REQUIRED)
├── commands/              # Custom slash commands
│   └── *.md
├── agents/                # Subagents
│   └── *.md
├── skills/                # Model-invoked skills
│   └── skill-name/
│       └── SKILL.md
├── hooks/                 # Event handlers (optional)
│   └── hooks.json
├── .mcp.json              # MCP servers (optional)
└── README.md
```

**Critical:** `.claude-plugin/` contains ONLY `plugin.json`. Other directories go at plugin root.

---

## plugin.json Manifest

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],

  "commands": ["./custom/commands/"],
  "agents": "./custom/agents/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json"
}
```

---

## Plugin Components

### 1. Commands (Slash Commands)

**Location:** `commands/*.md`

```markdown
---
description: What this command does
argument-hint: [optional-arg]
---

# Command Title

Instructions for Claude when command is invoked...
```

**Usage:** `/plugin-name:command-name arg`

### 2. Skills (Model-Invoked)

**Location:** `skills/skill-name/SKILL.md`

```markdown
---
name: skill-name
description: What this does. Use when [trigger condition].
---

# Skill Content

Instructions that load when skill activates...
```

**Key:** Claude auto-invokes based on task context matching description.

### 3. Agents (Subagents)

**Location:** `agents/*.md`

```markdown
---
description: What this agent specializes in
capabilities: ["task1", "task2"]
---

# Agent Name

Agent system prompt...
```

### 4. Hooks (Event Handlers)

**Location:** `hooks/hooks.json` or inline in plugin.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  }
}
```

### 5. MCP Servers

**Location:** `.mcp.json` at plugin root

```json
{
  "mcpServers": {
    "plugin-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "env": { "DB_PATH": "${CLAUDE_PLUGIN_ROOT}/data" }
    }
  }
}
```

---

## Marketplace System

### marketplace.json Structure

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Team Name",
    "email": "team@example.com"
  },
  "metadata": {
    "description": "Marketplace description",
    "version": "1.0.0",
    "pluginRoot": "./"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/my-plugin",
      "description": "Plugin description",
      "version": "1.0.0",
      "author": { "name": "Author" },
      "license": "MIT",
      "keywords": ["tag1"],
      "category": "productivity",
      "strict": true
    }
  ]
}
```

### Plugin Sources

```json
// Local (same repo)
"source": "./plugins/my-plugin"

// GitHub repository
"source": {
  "source": "github",
  "repo": "owner/plugin-repo"
}

// Git URL
"source": {
  "source": "url",
  "url": "https://gitlab.com/team/plugin.git"
}
```

---

## Installation

### Add Marketplace
```bash
/plugin marketplace add owner/repo          # GitHub
/plugin marketplace add https://example.com  # URL
/plugin marketplace add ./local/path         # Local
```

### Install Plugin
```bash
/plugin                                    # Interactive
/plugin install plugin-name@marketplace
/plugin enable plugin-name@marketplace
/plugin disable plugin-name@marketplace
/plugin uninstall plugin-name@marketplace
```

### Team Auto-Install

In `.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/plugins"
      }
    }
  },
  "enabledPlugins": {
    "plugin-name@marketplace": true
  }
}
```

---

## Environment Variables

- `${CLAUDE_PLUGIN_ROOT}` - Absolute path to plugin directory

Use in hooks, MCP configs, scripts:
```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
}
```

---

## Example: Granular Plugin Design (wshobson/agents)

The wshobson/agents repo demonstrates best practices:

- **65 focused plugins** (single responsibility)
- **Average 3.4 components per plugin**
- **Progressive disclosure** for skills

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
├── kubernetes-operations/
│   ├── agents/
│   │   └── kubernetes-architect.md
│   └── skills/
│       ├── k8s-manifest-generator/
│       ├── helm-chart-scaffolding/
│       └── gitops-workflow/
└── security-scanning/
    ├── agents/
    │   └── security-auditor.md
    ├── commands/
    │   ├── security-hardening.md
    │   └── security-sast.md
    └── skills/
        └── sast-configuration/
```

---

## Skill Structure (Progressive Disclosure)

```markdown
---
name: async-python-patterns
description: Python async/await patterns. Use when implementing async code or troubleshooting concurrency.
---

# Async Python Patterns

## Core Concepts
[Always loaded - minimal context]

## Patterns
### Event Loop
...

### Concurrent Execution
...

## Examples
[Loaded on demand]
```

**Three-tier Architecture:**
1. **Metadata** (frontmatter) - Always loaded
2. **Instructions** - Loaded when activated
3. **Resources** - Loaded on demand

---

## Debugging

```bash
claude --debug
```

Shows:
- Plugin loading
- Manifest validation
- Component registration
- Hook execution

---

## Best Practices

### Plugin Design
- **Single responsibility** - One focused purpose
- **Minimal components** - 2-8 per plugin (Anthropic guideline)
- **Clear descriptions** - Include WHEN to use
- **Version control** - Commit plugins to git

### Skills vs Commands
- **Skills**: Model decides when to use (proactive)
- **Commands**: User explicitly invokes (`/command`)

### Organization
- Use subdirectories for large plugins
- Keep skill names hyphenated (`async-python-patterns`)
- Include examples in skills

---

## Sources

- [Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [wshobson/agents](https://github.com/wshobson/agents) - 65 plugins, 91 agents
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) - CLI tool
