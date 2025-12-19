# Claude Code Hooks System - Complete Reference

*Research compiled: 2024-12-14*
*Sources: Official Claude Code docs (hooks.md, hooks-guide.md)*

## Overview

Hooks are automation triggers that execute shell commands or LLM prompts at specific points in Claude Code's lifecycle.

---

## Available Hook Events

| Event | Trigger | Can Block | Use Case |
|-------|---------|-----------|----------|
| **PreToolUse** | Before tool executes | Yes | Validate/modify tool inputs |
| **PostToolUse** | After tool completes | Yes (feedback) | Validate output, format code |
| **PermissionRequest** | Permission dialog shows | Yes | Auto-allow/deny |
| **UserPromptSubmit** | User submits prompt | Yes | Validate, inject context |
| **Notification** | Claude sends notification | No | Desktop alerts |
| **Stop** | Main agent finishes | Yes | Prevent stopping |
| **SubagentStop** | Subagent finishes | Yes | Prevent subagent stopping |
| **PreCompact** | Before context compaction | No | Custom pre-compact logic |
| **SessionStart** | New/resumed session | No | Load context, set env vars |
| **SessionEnd** | Session terminates | No | Cleanup, logging |

---

## Configuration

**Settings Locations (priority order):**
1. Enterprise managed policy
2. `.claude/settings.local.json` (local, not committed)
3. `.claude/settings.json` (project)
4. `~/.claude/settings.json` (user)

### Basic Structure

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 validate.py",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### Matcher Syntax
- Exact match: `Write` matches only Write tool
- Regex: `Edit|Write`, `Notebook.*`
- All tools: `*` or `""`
- MCP tools: `mcp__memory__.*`

---

## Environment Variables

| Variable | Scope | Value |
|----------|-------|-------|
| `CLAUDE_PROJECT_DIR` | All | Project root path |
| `CLAUDE_ENV_FILE` | SessionStart only | File to persist env vars |
| `CLAUDE_CODE_REMOTE` | All | `"true"` if web, empty for CLI |

### Persisting Environment Variables

```bash
#!/bin/bash
# SessionStart hook
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export API_KEY=value' >> "$CLAUDE_ENV_FILE"
fi
exit 0
```

---

## Hook Input/Output

### Input (stdin JSON)

**Common fields:**
```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/dir",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse"
}
```

**PreToolUse/PostToolUse:**
```json
{
  "tool_name": "Write",
  "tool_input": { "file_path": "...", "content": "..." },
  "tool_use_id": "toolu_01ABC..."
}
```

### Output (stdout JSON)

**Exit Codes:**
- `0`: Success - process JSON output
- `2`: Block action - only stderr shown
- Other: Non-blocking error

**Output Format:**
```json
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Warning message",
  "stopReason": "Reason text",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "updatedInput": { "field": "new value" }
  }
}
```

---

## Common Hook Examples

### File Protection
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json, sys; data=json.load(sys.stdin); path=data.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(p in path for p in ['.env', 'package-lock.json', '.git/']) else 0)\""
          }
        ]
      }
    ]
  }
}
```

### Auto-Format TypeScript
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read f; [[ \"$f\" == *.ts ]] && npx prettier --write \"$f\"; }"
          }
        ]
      }
    ]
  }
}
```

### Log All Bash Commands
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/.claude/bash-log.txt"
          }
        ]
      }
    ]
  }
}
```

### Desktop Notifications
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Needs your attention'"
          }
        ]
      }
    ]
  }
}
```

### Intelligent Stop Decision (Prompt)
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if Claude should stop. Check if tasks complete. Respond with {\"decision\": \"approve\" or \"block\", \"reason\": \"...\"}",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Session Setup
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/setup.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Pre-Commit Documentation Check

```bash
#!/bin/bash
# .claude/hooks/pre-commit.sh

CHANGED_CODE=$(git diff --cached --name-only | grep -E '\.(ts|tsx)$')
CHANGED_DOCS=$(git diff --cached --name-only | grep -E '\.md$')

if [ -n "$CHANGED_CODE" ] && [ -z "$CHANGED_DOCS" ]; then
  echo "Code changed but no doc updates. Continue? (y/n)"
  read -r response
  [ "$response" != "y" ] && exit 1
fi
```

---

## Gotchas & Limitations

- Hooks snapshotted at session start (restart for changes)
- 60-second default timeout (configurable)
- Hooks run in parallel (not sequential)
- Matchers only for PreToolUse, PermissionRequest, PostToolUse
- Exit code 2 blocks but ignores JSON output
- Hooks run with your user permissions (security risk!)

---

## Testing & Debugging

```bash
# Interactive hook management
/hooks

# Debug mode - shows hook execution
claude --debug
```

---

## Sources

- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
