---
description: Setup personal SolsDev methodology in ~/.claude/CLAUDE.md
---

# SolsDev - Initialize Personal Configuration

You are setting up the user's personal development methodology file at `~/.claude/CLAUDE.md`.

## What This Does

This command copies the SolsDev personal methodology template to `~/.claude/CLAUDE.md`, which Claude reads automatically at the start of every session across all projects.

## Your Task

### Step 1: Check Existing Configuration

First, check if `~/.claude/CLAUDE.md` already exists:

```bash
ls -la ~/.claude/CLAUDE.md
```

**If it exists:**
- Show the user the first 20 lines of their current CLAUDE.md
- **ASK** if they want to:
  - Replace it with the SolsDev template
  - Append the SolsDev sections to their existing file
  - Cancel and keep their current version

**DO NOT overwrite without explicit permission!**

### Step 2: Install the Template

Based on the user's choice:

**Option A: Replace (if they confirmed)**
```bash
mkdir -p ~/.claude
cp ${CLAUDE_PLUGIN_ROOT}/templates/personal-CLAUDE.md ~/.claude/CLAUDE.md
```

**Option B: Append (if they want to merge)**
- Add a separator to their existing file
- Append the Thoughtful Dev template sections they want
- Let them choose which sections to include

**Option C: Cancel**
- Don't make any changes
- Suggest they can manually review the template at `${CLAUDE_PLUGIN_ROOT}/templates/personal-CLAUDE.md`

### Step 3: Customize for the User

After installing, help the user customize these sections:

1. **MY TECH STACK** (lines ~188-206)
   - Ask what their primary stack is
   - Update the example stack to match their actual stack
   - Add any specific frameworks they use regularly

2. **Working relationship** (lines ~243-265)
   - This is already personalized for thoughtful collaboration
   - Ask if they want to adjust any guidelines

### Step 4: Explain What Was Installed

Tell the user:

**What's in the file:**
- ✅ Safety rules (git workflow, database operations, secrets)
- ✅ When to use requirements-clarifier and implementation-planner skills
- ✅ Black-box architecture principles
- ✅ Problem-solving with breakthrough-generator skill
- ✅ Project documentation protocol
- ✅ Session hygiene and workflow guidelines

**How it works:**
- Claude reads `~/.claude/CLAUDE.md` automatically in EVERY session
- It becomes Claude's "operating manual" for working with you
- You can edit it anytime: `code ~/.claude/CLAUDE.md`
- Changes take effect in the next Claude session

**Next steps:**
1. Customize the TECH STACK section for your stack
2. Review the CORE PRINCIPLES and adjust if needed
3. Start a new Claude session to activate it
4. Use `/solsdev:init-project` in your projects to add project-specific docs

## Important Notes

- This is a PERSONAL configuration (applies to all your projects)
- Different from project-specific `.claude/` documentation
- You can update it anytime as your preferences evolve
- The template is opinionated - customize it to match your style

## After Installation

The user can verify it worked:

```bash
# Check it was created
ls -lh ~/.claude/CLAUDE.md

# View the file
head -30 ~/.claude/CLAUDE.md

# Edit anytime
code ~/.claude/CLAUDE.md
```

On their next Claude session, these guidelines will be active automatically!
