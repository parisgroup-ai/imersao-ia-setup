---
name: context-maintenance
description: Use when starting a session on a project with memory files or AGENTS.md after a gap, after changing backend services or API configurations, after adding features or packages, or when the user says "check maintenance", "atualizar contexto", "context fresh", "memory audit". Also trigger proactively when you notice a discrepancy between memory files and actual code.
version: 1.0.0
---

# Context Maintenance

Audits all Claude context sources (memory files, CLAUDE.md, AGENTS.md) against the actual codebase to find and fix stale information. Prevents wrong context from persisting across conversations.

## Problem This Solves

Claude loads memory files and AGENTS.md at session start. If these contain outdated information (wrong model IDs, missing services, stale counts), every conversation starts with incorrect assumptions — leading to wrong suggestions, wasted debugging, and repeated mistakes.

## When to Use

- Starting a session after >7 days away from the project
- After changing configurations, services, or infrastructure
- After adding/removing features, API routes, or packages
- User asks to check context freshness
- You notice memory says X but code says Y

## Checks

Run in parallel where possible. Adapt to the project's structure.

### 1. Memory Index Health

```
wc -l MEMORY.md → must be < 100 lines
```

MEMORY.md should be a **concise index** with links to topic files — not inline content. If over limit, extract content into topic files.

### 2. Memory vs Code Drift

For each memory topic file:
- **Identify claims about code** (model names, file counts, service lists, API configurations)
- **Verify against actual code** using Grep/Glob
- Flag discrepancies as DRIFT

Common drift sources:
- Service/function/endpoint counts and lists
- Model or library version references
- File paths that were moved or renamed
- Configuration values that changed

### 3. AGENTS.md Completeness

For each AGENTS.md in the project:
- Compare documented services/features against actual directory listings
- Check counts match reality (e.g., "15 functions" vs `ls | wc -l`)
- Verify listed tools/models match what code actually uses

### 4. Stale Topic Files

For each file in `memory/`:
- Check `description` field still matches content
- Flag files older than 30 days for review
- Verify no content duplicates what's already in AGENTS.md
- Check "Known Issues" — verify they still exist in code

### 5. Timestamp Consistency

Compare file modification dates against internal `*Atualizado:*` or `updated:` timestamps in CLAUDE.md and AGENTS.md files.

### 6. Structural Integrity

Run equivalent of `/agents-maintenance` checks:
- Every CLAUDE.md has `[[AGENTS.md]]` link
- Every child AGENTS.md links back to parent
- No broken wikilinks

## Report Format

```
## Context Maintenance Report

| Check | Status | Details |
|-------|--------|---------|
| Memory Index | OK / OVER LIMIT | 23 lines (limit: 100) |
| Memory vs Code | OK / DRIFT | [list discrepancies] |
| AGENTS.md | OK / STALE | [missing items] |
| Topic Files | OK / REVIEW | [stale files] |
| Timestamps | OK / STALE | [files to update] |
| Structure | OK / BROKEN | [issues] |

[Offer to fix all issues found]
```

## Fix Strategy

For each issue found, apply in this order:
1. **Delete** — remove resolved known issues, completed work, obsolete references
2. **Update** — fix counts, model IDs, service lists to match code
3. **Extract** — move inline MEMORY.md content to topic files
4. **Create** — add missing AGENTS.md entries for new services

Always update both memory AND AGENTS.md when they track the same information.

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Add changelogs to memory | Use `git log` — it's authoritative |
| Duplicate AGENTS.md rules in memory | Single source of truth in AGENTS.md |
| Store code patterns in memory | Read from code when needed |
| Keep memory about completed work | It's in git history |
| Let MEMORY.md grow past 100 lines | Keep it as index, extract to topic files |
| Store file paths or line numbers | They change — store concepts, not locations |
