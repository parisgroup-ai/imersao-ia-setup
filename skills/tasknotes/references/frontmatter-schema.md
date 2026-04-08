# TaskNotes Frontmatter Schema

Complete reference for task YAML frontmatter properties.

## Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique task identifier (TASK-001, BUG-042) |
| `title` | string | Brief task description |
| `type` | enum | Task category |
| `status` | enum | Current workflow state |
| `created` | date | Creation date (YYYY-MM-DD) |

## Optional Properties

### Classification

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `priority` | enum | `medium` | Task urgency level |
| `tags` | string[] | `[]` | Categorization tags |
| `assignee` | string | - | Person responsible (@username) |

**Priority values:** `critical` | `high` | `medium` | `low`

**Type values:** `feature` | `bug` | `chore` | `spike` | `epic`

### Dates

| Property | Type | Description |
|----------|------|-------------|
| `due` | date | Deadline |
| `scheduled` | date | Planned start date |
| `completed` | date | Completion date |
| `reminder` | datetime | Notification time (ISO 8601) |

### Time Tracking

| Property | Type | Description |
|----------|------|-------------|
| `estimate` | duration | Expected time (4h, 2d, 30m) |
| `actual` | duration | Actual time spent |

**Duration formats:**
- Minutes: `30m`, `45m`
- Hours: `2h`, `4h30m`
- Days: `1d`, `2d` (assumes 8h/day)

### Relationships

| Property | Type | Description |
|----------|------|-------------|
| `sprint` | wikilink | Link to sprint.md |
| `parent` | wikilink | Parent epic/task |
| `blocks` | wikilink[] | Tasks this blocks |
| `blocked-by` | wikilink[] | Tasks blocking this |
| `related` | wikilink[] | Related docs, ADRs, code |

### Code Context

| Property | Type | Description |
|----------|------|-------------|
| `source` | string | File:line where issue found |
| `pr` | string | Pull request reference |
| `commit` | string | Related commit hash |

### Automation

| Property | Type | Description |
|----------|------|-------------|
| `recurrence` | string | Repeat pattern |
| `webhook` | string | Automation endpoint |

**Recurrence patterns:**
- `daily`, `weekly`, `monthly`
- `every 2 weeks`, `every 3 days`
- `weekdays`, `weekends`

## Status Enum

| Status | Description | Next States |
|--------|-------------|-------------|
| `backlog` | Not prioritized | `todo` |
| `todo` | Ready to start | `in-progress` |
| `in-progress` | Currently working | `review`, `blocked` |
| `review` | Awaiting PR review | `done`, `in-progress` |
| `blocked` | Waiting on dependency | `in-progress` |
| `done` | Completed | - |

## Complete Example

```yaml
---
id: TASK-042
title: Implement user authentication with JWT
type: feature
status: in-progress
priority: high
created: 2025-01-15
due: 2025-01-25
scheduled: 2025-01-18
completed:
estimate: 8h
actual: 3h
tags:
  - auth
  - security
  - api
  - sprint-5
assignee: "@cleiton"
sprint: "[[sprint.md|Sprint 5]]"
parent: "[[EPIC-001-user-system]]"
blocks:
  - "[[TASK-043-protected-routes]]"
  - "[[TASK-044-user-profile]]"
blocked-by: []
related:
  - "[[ADR-0053-profile-photo-security]]"
  - "[[packages/api/src/modules/auth]]"
  - "[[docs/03-API/Authentication.md]]"
source: "packages/api/src/routers/auth.ts:45"
pr: "#234"
recurrence:
reminder: 2025-01-20T09:00
---
```

## ID Conventions

| Type | Prefix | Example |
|------|--------|---------|
| Feature | `TASK-` or `FEAT-` | TASK-001, FEAT-042 |
| Bug | `BUG-` | BUG-023 |
| Chore | `CHORE-` | CHORE-015 |
| Spike | `SPIKE-` | SPIKE-007 |
| Epic | `EPIC-` | EPIC-003 |

**ID format:** `PREFIX-###` where ### is zero-padded sequential number.

## Dataview Queries

### Filter by status

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE status = "in-progress"
```

### Filter by priority

```dataview
TABLE status, estimate, due
FROM "docs/TaskNotes/tasks"
WHERE priority = "high" OR priority = "critical"
SORT priority ASC
```

### Filter by tag

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5")
```

### Overdue tasks

```dataview
TABLE due, status, priority
FROM "docs/TaskNotes/tasks"
WHERE due < date(today) AND status != "done"
SORT due ASC
```

### Time tracking summary

```dataview
TABLE estimate, actual, (actual - estimate) as "Variance"
FROM "docs/TaskNotes/tasks"
WHERE actual != null
```
