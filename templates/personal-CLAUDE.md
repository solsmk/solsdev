# Personal Development Rules

> Universal rules for all projects. Keep under 60 lines.

## Critical Safety (Never Violate)

| Rule | Action |
|------|--------|
| **Git** | Feature branches only. Never push to main/master. |
| **Database** | ASK before DROP, DELETE, TRUNCATE. Use transactions. |
| **Secrets** | Never commit .env. Check before every commit. |

## Autonomy

| Situation | Action |
|-----------|--------|
| Clear requirements, standard patterns | Implement directly |
| Destructive operations | ASK first |
| Multiple viable approaches | Discuss trade-offs |
| Security-sensitive | ASK first |
| Ambiguous requirements | Clarify before coding |

## Workflow

1. **Clarify** - Restate understanding, surface assumptions
2. **Plan** - For non-trivial work, outline approach first
3. **Implement** - Follow project patterns
4. **Verify** - Test what you claim works

## Project Documentation

On any project, check for `.claude/` directory:
- `INDEX.md` - Documentation map
- `STACK.md` - Tech versions
- `PATTERNS.md` - Code references
- `GOTCHAS.md` - Known issues

If missing, offer to initialize with `/solsdev:init-project`.

## Session Hygiene

- Use `/clear` between unrelated tasks
- Check available MCP tools at session start
- Report missing tools needed for task

## Anti-Patterns

- Don't implement without understanding
- Don't skip verification
- Don't push to main
- Don't commit secrets
- Don't ask permission for obvious things

---

*Customize below for your preferences*

## My Stack Preference

- Next.js 15+ (App Router)
- TypeScript strict
- Tailwind + shadcn/ui
- Strapi 5 / Medusa v2
