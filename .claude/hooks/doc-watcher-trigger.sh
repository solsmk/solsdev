#!/bin/bash
# Doc Watcher Trigger Hook
# Triggers after Write/Edit operations to spawn doc-watcher agent
#
# This hook:
# 1. Reads the tool input from stdin
# 2. Checks if the changed file is documentation-relevant
# 3. Outputs a system message to trigger doc-watcher agent
#
# Install: Add to .claude/settings.json PostToolUse hooks

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path (shouldn't happen for Write/Edit)
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip documentation files themselves (prevent loops)
if [[ "$FILE_PATH" == *".claude/"* ]] || [[ "$FILE_PATH" == *"CLAUDE.md" ]]; then
    exit 0
fi

# Skip common non-documentation-relevant files
if [[ "$FILE_PATH" == *".lock" ]] || \
   [[ "$FILE_PATH" == *".log" ]] || \
   [[ "$FILE_PATH" == *"node_modules/"* ]] || \
   [[ "$FILE_PATH" == *".git/"* ]]; then
    exit 0
fi

# Determine if this change is documentation-relevant
DOC_RELEVANT=false

# package.json changes → STACK.md
if [[ "$FILE_PATH" == *"package.json" ]]; then
    DOC_RELEVANT=true
fi

# Source files → PATTERNS.md, ARCHITECTURE.md
if [[ "$FILE_PATH" == *.ts ]] || \
   [[ "$FILE_PATH" == *.tsx ]] || \
   [[ "$FILE_PATH" == *.js ]] || \
   [[ "$FILE_PATH" == *.jsx ]]; then
    DOC_RELEVANT=true
fi

# Config files → STACK.md
if [[ "$FILE_PATH" == *"config."* ]] || \
   [[ "$FILE_PATH" == *"tsconfig"* ]] || \
   [[ "$FILE_PATH" == *".config."* ]]; then
    DOC_RELEVANT=true
fi

# Docker/deployment → STARTUP.md
if [[ "$FILE_PATH" == *"Dockerfile"* ]] || \
   [[ "$FILE_PATH" == *"docker-compose"* ]]; then
    DOC_RELEVANT=true
fi

# If relevant, suggest doc-watcher activation
if [ "$DOC_RELEVANT" = true ]; then
    # Output JSON that suggests running doc-watcher
    # The systemMessage prompts Claude to consider documentation
    cat << EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "[doc-watcher] File changed: $FILE_PATH - Consider running doc-watcher agent to check documentation drift."
}
EOF
else
    # No action needed
    echo '{"continue": true}'
fi
