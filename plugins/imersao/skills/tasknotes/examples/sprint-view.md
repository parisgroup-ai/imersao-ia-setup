---
title: Sprint 5 Board
type: view
sprint: sprint-5
created: 2025-01-15
---

# Sprint 5: User Authentication

**Duration:** 2025-01-15 → 2025-01-29
**Goal:** Complete user authentication system with JWT

## Sprint Stats

| Metric | Value |
|--------|-------|
| Total Tasks | 8 |
| Story Points | 24 |
| Team | @cleiton |

## Progress

```
[████████░░] 80% Complete
```

---

## Backlog

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "backlog"
SORT priority ASC
```

---

## Todo

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  blocked-by as "Blocked By"
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "todo"
SORT priority ASC
```

---

## In Progress

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  assignee
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "in-progress"
```

---

## Review

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  pr as "PR",
  assignee
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "review"
```

---

## Blocked

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  blocked-by as "Waiting On",
  priority
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "blocked"
```

---

## Done

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  completed,
  actual as "Time"
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "done"
SORT completed DESC
```

---

## Time Summary

| Category | Hours |
|----------|-------|
| Estimated | 24h |
| Actual (completed) | 18h |
| Remaining | 6h |

## Risks & Blockers

- [ ] External API dependency for OAuth
- [ ] Security review pending

## Notes

- JWT implementation following [[ADR-0053]]
- Using bcrypt for password hashing
- Refresh tokens stored in Redis

## Links

- [[sprint.md]] - Sprint tracking
- [[EPIC-001-user-system]] - Parent epic
- [[ADR-0053-profile-photo-security]] - Security decisions
