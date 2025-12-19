# Claude Code Subagents - Complete Reference

*Research compiled: 2024-12-14*
*Sources: Official Claude Code docs, CHANGELOG, community repos*

## Overview

Claude Code supports specialized **subagents** - focused AI assistants that can be delegated specific tasks. They run in separate context windows with customizable tools, models, and permissions.

---

## How to Create Subagents

### Method 1: Interactive `/agents` Command (Recommended)
```bash
/agents
```
Opens interactive UI for creating, editing, and managing subagents.

### Method 2: Markdown Files with YAML Frontmatter

**Storage Locations (by priority):**
- **Project scope**: `.claude/agents/agent-name.md`
- **User scope**: `~/.claude/agents/agent-name.md`
- **Session**: `--agents` CLI flag

**File Structure:**
```markdown
---
name: code-reviewer
description: Expert code reviewer. Use proactively after significant code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
skills: security-patterns, best-practices
---

You are a senior code reviewer specializing in...
[System prompt content here]
```

### Method 3: CLI Flag (JSON)
```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

---

## Configuration Options

| Field | Required | Type | Options | Notes |
|-------|----------|------|---------|-------|
| `name` | Yes | string | lowercase + hyphens, max 64 chars | Unique identifier |
| `description` | Yes | string | max 1024 chars | **Critical** - determines when Claude auto-invokes |
| `tools` | No | comma-separated | Any tool names | Omit = inherit all |
| `model` | No | string | `sonnet`, `opus`, `haiku`, `inherit` | Default: sonnet |
| `permissionMode` | No | string | `default`, `acceptEdits`, `bypassPermissions`, `plan`, `ignore` | |
| `skills` | No | comma-separated | Registered skill names | Auto-loads specified skills |

**Key Insight:** The `description` field is critical - include both WHAT the agent does and WHEN to use it. Use "proactively" keyword to trigger automatic delegation.

---

## Async/Background Execution (v2.0.64+)

**Key Update:** v2.0.64 introduced TRUE async execution!

### TaskOutputTool (Unified Async)

Replaced `AgentOutputTool` and `BashOutputTool` with unified `TaskOutputTool`:

```
# Agent runs in background, returns immediately
> Use the code-analyzer subagent to analyze the codebase

# Main agent continues working...
# Background agent sends wake-up message when done
# TaskOutputTool retrieves results
```

### How Async Works

1. **Launch background task** - Agent or bash command starts async
2. **Main agent continues** - Not blocked waiting
3. **Wake-up message** - Background task notifies main agent
4. **Retrieve results** - `TaskOutputTool` gets output

### Resumable Sessions

```bash
# Name your session
/rename my-feature-work

# Resume later (REPL)
/resume my-feature-work

# Resume from terminal
claude --resume my-feature-work
```

### Background Execution Methods

| Method | How |
|--------|-----|
| Web | Prefix with `&` |
| CLI | Task tool with `run_in_background: true` |
| Bash | Long commands auto-background (don't kill) |

### Headless/Non-Interactive
```bash
claude -p "Run analysis" \
  --agents '{"analyzer": {...}}' \
  --output-format json \
  --max-turns 5
```

### What's Actually Possible Now

| Feature | Status |
|---------|--------|
| Fire-and-forget tasks | ✅ Yes |
| Wake-up notifications | ✅ Yes |
| Parallel bash commands | ✅ Yes |
| Named session resume | ✅ Yes |
| Agent spawning agents | ❌ Still no |
| Inter-agent messaging | ❌ Still no |

---

## Built-in Subagents

| Agent | Model | Tools | Use Case |
|-------|-------|-------|----------|
| **General-Purpose** | Sonnet | All | Complex multi-step tasks |
| **Plan** | Sonnet | Read, Glob, Grep, Bash (read-only) | Research during plan mode |
| **Explore** | Haiku | Glob, Grep, Read, Bash (read-only) | Fast codebase searching |

**Explore Agent Thoroughness:**
- `quick` - Basic searches
- `medium` - Moderate exploration
- `very thorough` - Comprehensive analysis

---

## Communication Patterns

### Supported
- **Sequential chaining**: One agent after another
- **Context sharing**: Via conversation history
- **Resumable state**: Continue with full history

### NOT Supported
- No inter-agent messaging
- No shared state/variables
- No agent-to-agent tool calls
- No parallel execution (agents run sequentially)
- No nested subagents (agents cannot spawn other agents)

---

## Limitations

| Limitation | Status (v2.0.64) | Workaround |
|-----------|------------------|------------|
| No nested subagents | Still applies | Design as independent units |
| Separate context windows | Still applies | Use resumable agents |
| No parallel execution | **FIXED** - async works | Use TaskOutputTool |
| Fresh context per execution | **FIXED** - named sessions | `/rename` + `/resume` |
| Latency overhead (~0.5-1s) | Still applies | Batch work to reduce invocations |
| No inter-agent messaging | Still applies | Pass via conversation context |

---

## Best Practices

1. **Single Responsibility**: One focused purpose per agent
2. **Specific Descriptions**: Include WHAT + WHEN for auto-delegation
3. **Minimal Tools**: Only grant necessary tools
4. **Version Control**: Check project agents into git
5. **Detailed Prompts**: Include instructions, examples, constraints
6. **Use Haiku for Speed**: Fast operational tasks
7. **Use Opus for Critical**: Architecture, security decisions

---

## Three-Tier Model Strategy (from wshobson/agents)

| Tier | Model | Use Case |
|------|-------|----------|
| **Tier 1** | Opus | Critical architecture, security, code review |
| **Tier 2** | Inherit | Complex tasks - user chooses model |
| **Tier 3** | Sonnet | Docs, testing, debugging, support |
| **Tier 4** | Haiku | Fast operational tasks (SEO, deployment) |

**Orchestration Pattern:**
```
Planning (Opus) → Execution (Sonnet/Haiku) → Review (Opus)
```

---

## Example: Code Reviewer Agent

```markdown
---
name: code-reviewer
description: Security-focused code reviewer. Use PROACTIVELY after code changes or when reviewing PRs. Identifies vulnerabilities, patterns violations, and security issues.
tools: Read, Grep, Glob, Bash
model: opus
permissionMode: default
skills: security-patterns
---

You are a security-focused senior code reviewer.

## Your Responsibilities
1. Review code for security vulnerabilities
2. Check for pattern violations
3. Identify performance issues
4. Verify test coverage
5. Suggest improvements

## Review Process
1. Read the changed files
2. Analyze for security issues (OWASP Top 10)
3. Check against project patterns
4. Provide actionable feedback

## Output Format
- Summary of findings
- Severity ratings (Critical, High, Medium, Low)
- Specific line references
- Suggested fixes
```

---

## Sources

- [Official Subagents Docs](https://code.claude.com/docs/en/sub-agents)
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [wshobson/agents](https://github.com/wshobson/agents) - 91 agents, 47 skills
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) - CLI components
