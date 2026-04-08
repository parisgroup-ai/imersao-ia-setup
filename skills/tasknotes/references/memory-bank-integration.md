# Memory-Bank Integration

Sync TaskNotes tasks with the project's memory-bank for sprint tracking and context preservation.

## Overview

The memory-bank system uses these files for project context:

| File | Purpose | TaskNotes Integration |
|------|---------|----------------------|
| `sprint.md` | Current sprint tasks | Primary sync target |
| `activeContext.md` | Session focus | Reference current tasks |
| `progress.md` | Milestones | Link completed epics |

## Sprint.md Sync Workflow

### Adding Tasks to Sprint

When creating a task for the current sprint:

1. **In task frontmatter:**
```yaml
sprint: "[[sprint.md|Sprint 5]]"
tags:
  - sprint-5
```

2. **In sprint.md, add task reference:**
```markdown
## Current Sprint: Sprint 5

### Objectives
- Complete user authentication epic
- Fix critical bugs from last release

### Tasks

#### In Progress
- [[TASK-042-implement-jwt]] - JWT auth (8h est) @cleiton

#### Todo
- [[TASK-043-protected-routes]] - Protected routes (4h) @cleiton
- [[TASK-044-user-profile]] - User profile endpoint (3h)

#### Done
- [[TASK-041-auth-schema]] - Auth DB schema (completed 2025-01-17)

### Blockers
- [[BUG-023-login-redirect]] blocked by external API issue
```

### Status Updates

When task status changes:

1. Move task to appropriate section in sprint.md
2. Update task frontmatter status
3. Add completion date if done

**Before (task moves from todo to in-progress):**

sprint.md:
```markdown
#### Todo
- [[TASK-042-implement-jwt]] - JWT auth (8h)

#### In Progress
```

**After:**

sprint.md:
```markdown
#### Todo

#### In Progress
- [[TASK-042-implement-jwt]] - JWT auth (8h) - started 2025-01-18
```

### Sprint Completion

When sprint ends:

1. Move remaining tasks to next sprint tag
2. Update completed tasks with actual time
3. Add sprint summary to progress.md

```markdown
## Sprint 5 Summary

**Velocity:** 24 story points
**Completion:** 85% (17/20 tasks)

### Completed
- [[EPIC-001-user-system]] - User authentication system
- [[TASK-041]] through [[TASK-048]]

### Carried Over
- [[TASK-049]] - Moved to Sprint 6
- [[BUG-023]] - Still blocked
```

## activeContext.md Integration

Reference current working tasks in activeContext.md:

```markdown
## Current Focus

### Active Tasks
- [[TASK-042-implement-jwt]] - Implementing JWT authentication
  - Working on token generation
  - Next: refresh token logic

### Context
- Following [[ADR-0053]] for security patterns
- Using existing auth schema from [[TASK-041]]

### Blockers
- None currently

### Next Up
- [[TASK-043-protected-routes]] once JWT complete
```

## progress.md Integration

Link completed epics and milestones:

```markdown
## Milestones

### 2025-01

#### Week 3 (Jan 15-21)
- Completed [[EPIC-001-user-system]]
  - Tasks: [[TASK-041]] - [[TASK-048]]
  - ADR: [[ADR-0053]]
  - PR: #234, #236, #238

#### Week 2 (Jan 8-14)
- Completed [[EPIC-000-project-setup]]
```

## Bidirectional Linking Rules

### From Task to Memory-Bank

Every task should link to:
- `sprint.md` (if in a sprint)
- Related ADRs
- Parent epic (if applicable)

```yaml
sprint: "[[sprint.md|Sprint 5]]"
parent: "[[EPIC-001-user-system]]"
related:
  - "[[ADR-0053-profile-photo-security]]"
```

### From Memory-Bank to Tasks

sprint.md should:
- List all sprint tasks with status
- Group by status (todo/in-progress/done/blocked)
- Include estimates and assignees

activeContext.md should:
- Reference currently active tasks
- Note blockers and context

progress.md should:
- Link completed epics
- Reference milestone tasks

## Automation Patterns

### Daily Standup Generator

Create a view that generates standup content:

```markdown
# Standup: {{date}}

## Yesterday
```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE status = "done" AND completed = date(yesterday)
```

## Today
```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE status = "in-progress" OR scheduled = date(today)
```

## Blockers
```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE status = "blocked"
```
```

### Sprint Report Generator

```markdown
# Sprint {{sprint}} Report

## Metrics

| Metric | Value |
|--------|-------|
| Planned | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5")).length` |
| Completed | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.status === "done").length` |
| Velocity | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.status === "done").map(p => p.estimate || 0).sum()` |

## Completed Tasks

```dataview
TABLE completed, actual
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "done"
SORT completed ASC
```
```

## Sync Checklist

### When Creating Tasks

- [ ] Add `sprint` frontmatter linking to sprint.md
- [ ] Add sprint tag (e.g., `sprint-5`)
- [ ] Update sprint.md with task reference
- [ ] Link related ADRs if applicable

### When Updating Status

- [ ] Update task frontmatter status
- [ ] Move task in sprint.md to correct section
- [ ] Update activeContext.md if task is current focus
- [ ] Add completion date when done

### When Completing Sprint

- [ ] Update all done tasks with actual time
- [ ] Add sprint summary to progress.md
- [ ] Move incomplete tasks to next sprint
- [ ] Update sprint tags on carried-over tasks

### Session Start

- [ ] Read sprint.md for current tasks
- [ ] Read activeContext.md for focus
- [ ] Check for blocked tasks
- [ ] Update status of any changed tasks
