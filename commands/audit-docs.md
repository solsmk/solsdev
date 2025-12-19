---
description: Audit documentation for drift and generate concise report
---

# Documentation Audit

Generate a concise report comparing project documentation against actual codebase to detect drift.

## Your Task

Analyze the project's documentation files (CLAUDE.md and .claude/*.md) and compare them against the actual codebase to identify discrepancies.

### Step 1: Verify Documentation Exists

Check if the project has documentation:

```bash
ls CLAUDE.md .claude/
```

**If missing:**
```
⚠️ No documentation found

This project doesn't have solsdev documentation structure.

Run: /solsdev:init-project to set it up.
```

**If found, proceed to Step 2.**

### Step 2: Analyze Current Codebase

Use the Explore agent or Task tool to understand current state:

**Tech Stack (for STACK.md comparison):**
- Read package.json dependencies
- Note versions of key packages
- Identify framework (Next.js, React, etc.)
- Check for database, state management, testing tools

**Architecture (for ARCHITECTURE.md comparison):**
- Map directory structure
- Identify main modules/features
- Check API routes/endpoints
- Note data flow patterns

**Patterns (for PATTERNS.md comparison):**
- Scan component files for actual patterns used
- Check naming conventions in file names
- Identify testing patterns (if tests exist)
- Note import/export styles

**Commands (for STARTUP.md comparison):**
- Read package.json scripts
- Note development, build, test commands

**Issues (for GOTCHAS.md comparison):**
- Search for TODO/FIXME comments
- Look for workarounds in code comments

### Step 3: Read Documentation Files

Read each documentation file:

```bash
cat CLAUDE.md
cat .claude/STACK.md
cat .claude/ARCHITECTURE.md
cat .claude/PATTERNS.md
cat .claude/STARTUP.md
cat .claude/GOTCHAS.md
cat .claude/DECISIONS.md
```

### Step 4: Compare and Detect Drift

For each file, compare documented vs actual state:

**Priority drift to detect:**

1. **STACK.md - Highest Priority**
   - Missing dependencies (in package.json, not in docs)
   - Version mismatches (docs say v1.0, code uses v2.0)
   - Removed dependencies (in docs, not in package.json)
   - Wrong framework version

2. **PATTERNS.md - High Priority**
   - Documented pattern not used in code
   - Code uses pattern not documented
   - Pattern changed (docs say class components, code uses functional)

3. **ARCHITECTURE.md - Medium Priority**
   - Directory structure mismatch
   - Missing new major modules
   - API endpoints not documented

4. **STARTUP.md - Medium Priority**
   - package.json scripts changed
   - Missing new commands
   - Commands outdated

5. **GOTCHAS.md - Low Priority**
   - Documented issues resolved (TODO comments removed)
   - New workarounds not documented

### Step 5: Generate Concise Report

**Format: Keep it brief and actionable**

```markdown
# 📋 Documentation Audit Report
*Generated: YYYY-MM-DD HH:MM*

## 📊 Summary
✓ X files up to date
⚠️ Y files with minor drift
✗ Z files with major drift

---

## 📦 STACK.md
**Status:** ✗ Major Drift

**Missing:**
- @tanstack/react-query@5.0.0
- zod@3.22.0

**Version Mismatches:**
- React: docs say 18.2.0, actual is 18.3.1

**Fix:**
Add missing packages and update React version.

---

## 📝 PATTERNS.md
**Status:** ⚠️ Minor Drift

**Issues:**
- Docs mention Redux, but code uses Zustand (15 files)

**Fix:**
Update state management section to reflect Zustand.

---

## 🏗️ ARCHITECTURE.md
**Status:** ✓ Up to date

No drift detected.

---

## ⚙️ STARTUP.md
**Status:** ⚠️ Minor Drift

**Issues:**
- Missing new script: `npm run db:migrate`

**Fix:**
Add database migration command.

---

## ⚠️ GOTCHAS.md
**Status:** ✓ Up to date

No new issues found.

---

## 🎯 CLAUDE.md
**Status:** ✓ Up to date

Core commands and principles still accurate.

---

## 📝 Action Items

Priority fixes:
1. **HIGH:** Update STACK.md (2 missing deps, 1 version)
2. **MEDIUM:** Update PATTERNS.md (Zustand pattern)
3. **LOW:** Update STARTUP.md (1 new command)

---

## 💡 Recommendations

- Run this audit weekly during active development
- Update docs immediately after architecture changes
- Enable auto-updates: Add `Mode: auto` to CLAUDE.md
```

### Output Rules

**Keep it concise:**
- ✅ List specific issues, not general statements
- ✅ Show what to fix, not lengthy explanations
- ✅ Prioritize HIGH/MEDIUM/LOW
- ❌ No verbose analysis
- ❌ No redundant information

**Status levels:**
- ✓ **Up to date** - No drift detected
- ⚠️ **Minor Drift** - 1-2 small discrepancies, low impact
- ✗ **Major Drift** - Multiple issues or critical mismatch

**Prioritization:**
- **HIGH:** Wrong tech stack info, major pattern mismatches
- **MEDIUM:** Missing new features, outdated commands
- **LOW:** Cosmetic issues, minor omissions

### Step 6: Offer Next Steps

After showing the report:

```
Documentation audit complete!

Would you like me to:
1. Fix all HIGH priority items now
2. Fix specific items (tell me which)
3. Update all drift automatically
4. Just note the issues (you'll fix manually)

Or run: /solsdev:update-docs to update manually
```

## Important Principles

**DO:**
- Be specific about what's wrong
- Show exactly what to change
- Prioritize by impact
- Keep report scannable
- Offer to fix issues

**DON'T:**
- Generate wall of text
- List every minor detail
- Make assumptions about intent
- Update docs without asking
- Skip the summary

## Drift Detection Logic

### For STACK.md

**Major drift:**
- 3+ missing dependencies
- Wrong framework (docs say Vue, code is React)
- Critical version mismatch (major version off)

**Minor drift:**
- 1-2 missing dependencies
- Patch version mismatches
- Missing dev dependencies

**No drift:**
- All dependencies documented
- Versions accurate (or close enough for patch)

### For PATTERNS.md

**Major drift:**
- Documented pattern contradicts code (docs say Redux, code uses Zustand)
- Core pattern completely missing (no mention of primary state management)

**Minor drift:**
- Pattern used but not well documented
- Example code outdated

**No drift:**
- Patterns match actual usage
- Examples are current

### For ARCHITECTURE.md

**Major drift:**
- Wrong directory structure
- Missing major modules (new /api directory not documented)
- Data flow wrong (REST docs, GraphQL code)

**Minor drift:**
- Small structural changes
- New utility directory

**No drift:**
- Structure matches
- Modules documented

## Example Scenarios

### Scenario 1: Clean Project

```
# 📋 Documentation Audit Report
*Generated: 2025-10-26 14:30*

## 📊 Summary
✓ 7 files up to date
⚠️ 0 files with minor drift
✗ 0 files with major drift

---

All documentation is current and accurate! 🎉

No action items needed.

💡 Great job keeping docs updated!
```

### Scenario 2: Typical Drift

```
# 📋 Documentation Audit Report
*Generated: 2025-10-26 14:30*

## 📊 Summary
✓ 4 files up to date
⚠️ 2 files with minor drift
✗ 1 file with major drift

---

## 📦 STACK.md
**Status:** ✗ Major Drift

**Missing:** @tanstack/react-query@5.0.0, zod@3.22.0
**Fix:** Add to "State Management & Validation" section

---

## 📝 PATTERNS.md
**Status:** ⚠️ Minor Drift

**Issues:** No React Query pattern documented
**Fix:** Add query hooks section with example

---

## ⚙️ STARTUP.md
**Status:** ⚠️ Minor Drift

**Issues:** Missing `npm run db:migrate`
**Fix:** Add to development commands

---

## 📝 Action Items

1. **HIGH:** Update STACK.md (2 packages)
2. **MEDIUM:** Add React Query pattern to PATTERNS.md
3. **LOW:** Add migrate command to STARTUP.md

---

Would you like me to fix these now?
```

### Scenario 3: Significant Drift

```
# 📋 Documentation Audit Report
*Generated: 2025-10-26 14:30*

## 📊 Summary
✓ 2 files up to date
⚠️ 1 file with minor drift
✗ 4 files with major drift

---

⚠️ **Significant drift detected!**

This suggests documentation hasn't been updated in a while.

## 📦 STACK.md - ✗ Major Drift
- 5 missing dependencies
- 2 version mismatches

## 📝 PATTERNS.md - ✗ Major Drift
- Redux documented, Zustand used
- No TypeScript patterns (code is TS)

## 🏗️ ARCHITECTURE.md - ✗ Major Drift
- Missing /webhooks directory
- Data flow outdated

## ⚙️ STARTUP.md - ⚠️ Minor Drift
- 2 new scripts not documented

---

## 📝 Action Items

**CRITICAL:** Documentation is significantly out of sync.

Recommend:
1. Run /solsdev:init-project to regenerate docs
2. Or allow me to do comprehensive updates now

This level of drift suggests starting fresh might be faster.

Proceed with updates or regenerate?
```

## After Audit

**If drift found:**
```
I can help fix these issues. Would you like me to update the docs now?

Or you can:
- Edit files manually
- Enable auto-updates (add "Mode: auto" to CLAUDE.md)
- Run /solsdev:update-docs for guided updates
```

**If no drift:**
```
Documentation is current! 🎉

Keep it that way by:
- Using the doc-maintenance skill (it auto-reminds)
- Running this audit before releases
- Adding "Mode: auto" for automatic updates
```

## Error Handling

**If no documentation exists:**
```
This project has no documentation structure.

Run: /solsdev:init-project [project-name]

To create CLAUDE.md and .claude/ documentation.
```

**If only CLAUDE.md exists (no .claude/):**
```
Found CLAUDE.md but no .claude/ directory.

This looks like a basic setup. Would you like me to:
1. Create full .claude/ structure
2. Audit just CLAUDE.md
```

**If analysis fails:**
```
⚠️ Couldn't analyze [file/aspect]

Reason: [specific error]

Continuing with partial audit...
```

Remember: **Concise, actionable, helpful.** Users want to know what's wrong and how to fix it, not read a novel.
