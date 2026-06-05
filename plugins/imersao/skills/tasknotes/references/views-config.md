# TaskNotes Views Configuration

Configure Kanban boards, calendars, agendas, and other views for task visualization.

## Kanban Board

### Basic Kanban

Create `docs/TaskNotes/views/kanban.md`:

```markdown
---
title: Kanban Board
type: view
---

# Kanban Board

## Backlog

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  assignee
FROM "docs/TaskNotes/tasks"
WHERE status = "backlog"
SORT priority ASC
```

## Todo

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  assignee
FROM "docs/TaskNotes/tasks"
WHERE status = "todo"
SORT priority ASC
```

## In Progress

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  assignee
FROM "docs/TaskNotes/tasks"
WHERE status = "in-progress"
SORT priority ASC
```

## Review

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  pr,
  assignee
FROM "docs/TaskNotes/tasks"
WHERE status = "review"
```

## Blocked

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  blocked-by as "Blocked By",
  priority
FROM "docs/TaskNotes/tasks"
WHERE status = "blocked"
```

## Done (This Sprint)

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  completed,
  actual
FROM "docs/TaskNotes/tasks"
WHERE status = "done" AND contains(tags, "sprint-5")
SORT completed DESC
LIMIT 10
```
```

### Sprint-Filtered Kanban

Filter by sprint tag:

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  status,
  priority
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5")
GROUP BY status
```

## Agenda View

### Daily Agenda

Create `docs/TaskNotes/views/today.md`:

```markdown
---
title: Today's Agenda
type: view
---

# Today's Agenda

## Scheduled for Today

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  estimate,
  status
FROM "docs/TaskNotes/tasks"
WHERE scheduled = date(today)
SORT priority ASC
```

## Due Today

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  priority,
  status
FROM "docs/TaskNotes/tasks"
WHERE due = date(today) AND status != "done"
SORT priority ASC
```

## In Progress

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  estimate,
  actual
FROM "docs/TaskNotes/tasks"
WHERE status = "in-progress"
```

## Overdue

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  due,
  priority
FROM "docs/TaskNotes/tasks"
WHERE due < date(today) AND status != "done"
SORT due ASC
```
```

### Weekly Agenda

```markdown
# Week of {{date:gggg-[W]ww}}

## This Week's Tasks

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  scheduled,
  due,
  status
FROM "docs/TaskNotes/tasks"
WHERE scheduled >= date(sow) AND scheduled <= date(eow)
SORT scheduled ASC
```
```

## Calendar View

### Monthly Calendar Data

```markdown
# Calendar: {{date:MMMM YYYY}}

```dataview
CALENDAR due
FROM "docs/TaskNotes/tasks"
WHERE due != null AND status != "done"
```
```

### Due Date Summary

```dataview
TABLE WITHOUT ID
  due as "Date",
  length(rows) as "Tasks Due",
  join(map(rows, (r) => r.title), ", ") as "Tasks"
FROM "docs/TaskNotes/tasks"
WHERE due != null AND status != "done"
GROUP BY due
SORT due ASC
```

## Sprint Board

### Current Sprint Overview

Create `docs/TaskNotes/views/sprint-board.md`:

```markdown
---
title: Sprint Board
type: view
sprint: sprint-5
---

# Sprint 5 Board

## Sprint Stats

| Metric | Value |
|--------|-------|
| Total Tasks | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5")).length` |
| Done | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.status === "done").length` |
| In Progress | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.status === "in-progress").length` |
| Blocked | `$= dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.status === "blocked").length` |

## By Assignee

```dataview
TABLE WITHOUT ID
  assignee as "Person",
  length(filter(rows, (r) => r.status = "done")) as "Done",
  length(filter(rows, (r) => r.status = "in-progress")) as "WIP",
  length(rows) as "Total"
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5")
GROUP BY assignee
```

## Time Summary

```dataview
TABLE WITHOUT ID
  sum(map(rows, (r) => r.estimate)) as "Estimated",
  sum(map(rows, (r) => r.actual)) as "Actual"
FROM "docs/TaskNotes/tasks"
WHERE contains(tags, "sprint-5") AND status = "done"
```
```

## Priority Matrix

### Eisenhower Matrix

```markdown
# Priority Matrix

## Urgent & Important (Do First)

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE (priority = "critical" OR priority = "high") AND due <= date(today) + dur(3 days)
```

## Important, Not Urgent (Schedule)

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE (priority = "critical" OR priority = "high") AND (due > date(today) + dur(3 days) OR due = null)
```

## Urgent, Not Important (Delegate)

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE (priority = "medium" OR priority = "low") AND due <= date(today) + dur(3 days)
```

## Neither (Consider Dropping)

```dataview
LIST
FROM "docs/TaskNotes/tasks"
WHERE priority = "low" AND status = "backlog"
```
```

## Dependency Graph

### Blocked Tasks View

```markdown
# Dependency View

## Tasks Blocking Others

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  status,
  blocks as "Blocks"
FROM "docs/TaskNotes/tasks"
WHERE blocks != empty
```

## Blocked Tasks

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  status,
  blocked-by as "Waiting On"
FROM "docs/TaskNotes/tasks"
WHERE blocked-by != empty
```
```

## Time Tracking Dashboard

```markdown
# Time Tracking

## Estimates vs Actuals

```dataview
TABLE WITHOUT ID
  link(file.path, title) as "Task",
  estimate,
  actual,
  choice(actual > estimate, "Over", choice(actual < estimate, "Under", "On Track")) as "Status"
FROM "docs/TaskNotes/tasks"
WHERE actual != null
SORT completed DESC
LIMIT 20
```

## Total Time This Sprint

| Metric | Hours |
|--------|-------|
| Estimated | `$= Math.round(dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5")).map(p => p.estimate || 0).sum())` |
| Actual | `$= Math.round(dv.pages('"docs/TaskNotes/tasks"').where(p => p.tags?.includes("sprint-5") && p.actual).map(p => p.actual).sum())` |
```

## TaskNotes Plugin Native Views

If using the TaskNotes plugin, these views are available natively:

| View | Access | Description |
|------|--------|-------------|
| Task List | Command palette | Filterable task list |
| Kanban | Sidebar | Drag-and-drop board |
| Agenda | Sidebar | Date-based view |
| Calendar | Sidebar | Monthly calendar |
| Pomodoro | Sidebar | Timer with task focus |

Configure in plugin settings for custom columns, filters, and groupings.
