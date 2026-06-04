---
name: sprint-report
description: Use when generating a weekly sprint summary from TaskNotes or preparing a standup-style progress report.
---

# Sprint Report Skill

Generate a concise, formatted sprint summary from the current TaskNotes sprint.

## Steps

1. Run `pnpm task:sprint` to get the sprint overview and progress bar.
2. Run `pnpm task:list --sprint -f json` to get full task details.
3. Organize tasks into sections:
   - ✅ **Done** — status: done
   - 🔄 **In Progress** — status: in-progress
   - ⏳ **Pending** — status: open, not blocked
   - 🚧 **Blocked** — open tasks with dependencies not resolved
4. Calculate velocity: `done / total` tasks as a percentage.
5. Identify the top 1-3 high-priority items still open.
6. Suggest recommended focus for the next session based on priorities and blockers.

## Output Format

```markdown
## Sprint Report — [Sprint Name]
**Period:** [start] → [end]  |  **Velocity:** X/Y tasks (Z%)

### ✅ Done (X)
- TASK-001: Description
- TASK-002: Description

### 🔄 In Progress (X)
- TASK-003: Description

### ⏳ Pending (X)
- TASK-004: Description

### 🚧 Blocked (X)
- TASK-005: Waiting on TASK-003

### Recommended Focus
1. [highest priority pending task]
2. [unblock TASK-005 by completing TASK-003]
```

## Notes

- Run from the project root where `pnpm` is available
- If `pnpm task:list --sprint -f json` fails, fall back to `pnpm task:list --sprint`
- High-priority items (priority: high) always appear first within each section
