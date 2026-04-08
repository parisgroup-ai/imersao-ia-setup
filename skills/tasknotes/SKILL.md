---
name: tasknotes
description: "This skill should be used when the user asks to 'create a task', 'add a TODO', 'plan a sprint', 'organize tasks', 'track time', 'setup Kanban', 'create task from code', 'sync tasks with sprint', 'pomodoro session', 'start pomodoro', 'time estimate', or mentions TaskNotes, task management, or project planning in Obsidian. Provides task creation, sprint planning, Pomodoro time tracking, and memory-bank integration following TaskNotes plugin conventions."
version: 2.1.0
author: gustavo
tags: [tasks, planning, obsidian, workflow]
---

# TaskNotes Skill

This skill creates and manages tasks in Obsidian using the TaskNotes plugin methodology: one note per task with structured YAML frontmatter. Tasks integrate with the project's memory-bank for sprint tracking.

> **LLM-First Design:** The implementer is an LLM (Claude Code). Tasks serve as entry points that link to design docs containing implementation instructions.

## LLM Implementation Model

```
User: "Implement TASK-002"
         │
         ▼
┌─────────────────────────────────────┐
│ 1. Read Task File                   │
│    docs/TaskNotes/Tasks/TASK-002-*  │
│    → Get status, subtasks           │
│    → Find designDoc link            │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ 2. Read Design Doc                  │
│    docs/plans/2026-*-design.md      │
│    → Architecture, file paths       │
│    → Code patterns, API contracts   │
│    → Validation commands            │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ 3. Implement & Update               │
│    → Follow design doc steps        │
│    → Mark subtasks complete         │
│    → Update task status             │
└─────────────────────────────────────┘
```

## Core Concept

TaskNotes treats each task as a dedicated Markdown file with:
- **YAML frontmatter** for structured metadata (status, priority, dates, tags)
- **Body content** for description, subtasks, notes
- **Bidirectional links** to design docs, sprints, and related documentation
- **Design doc reference** via `designDoc` field for implementation context

## Task File Structure

### Location

```
docs/TaskNotes/
├── Tasks/                    # Plugin default folder
│   ├── TASK-001-implement-auth.md
│   ├── BUG-002-fix-login.md
│   └── CHORE-003-cleanup.md
├── Views/                    # Plugin .base files
│   ├── kanban-default.base
│   ├── tasks-default.base
│   ├── agenda-default.base
│   └── calendar-default.base
└── Archive/                  # Archived tasks
```

### Task Frontmatter Schema (Plugin Format)

```yaml
---
uid: task-001                 # Unique identifier
status: open | in-progress | done    # Plugin status values
priority: none | low | normal | high # Plugin priority values
due: 2026-01-25               # Due date
scheduled: 2026-01-20         # Scheduled start date
completed: 2026-01-18         # Completion date (auto-set)
timeEstimate: 480             # Minutes (8h = 480)
pomodoros: 0                  # Completed pomodoros (auto-tracked)
timeEntries: []               # Time log (auto-tracked by plugin)
designDoc: "[[2026-01-20-feature-design]]"  # Link to docs/plans design doc
projects:
  - "[[sprint.md|Sprint 5]]"
  - "[[LLM-Implementation-Analysis]]"
contexts:
  - llm
  - analytics
blockedBy: []                 # Tasks blocking this one
recurrence:                   # Recurring pattern
tags:
  - task                      # REQUIRED for plugin detection
  - feature
---
```

**Important**: Use `tags: [task]` for plugin detection!

See `references/frontmatter-schema.md` for complete property documentation.

## Pomodoro Integration

TaskNotes has **native Pomodoro timer** built-in. No separate plugin needed.

### Current Configuration

| Setting | Value |
|---------|-------|
| Work duration | 25 min |
| Short break | 5 min |
| Long break | 15 min |
| Long break interval | Every 4 pomodoros |
| Auto-start breaks | Yes |
| Notifications | Yes |

### Pomodoro Workflow

```
🍅 25min work → ☕ 5min break → 🍅 25min work → ☕ 5min break →
🍅 25min work → ☕ 5min break → 🍅 25min work → 🛋️ 15min break

1 cycle = 4 pomodoros = ~2h10min (1h40min work)
```

### Estimating with Pomodoros

| Estimate | Pomodoros | With Breaks |
|----------|-----------|-------------|
| 30min | 1-2 | ~35min |
| 1h | 2-3 | ~1h10min |
| 2h | 4-5 | ~2h15min |
| 4h | 8-10 | ~4h30min |
| 8h (1 day) | 16-19 | Full day |

### Time Fields

```yaml
timeEstimate: 480      # 8 hours in minutes
pomodoros: 12          # Completed pomodoros (plugin updates)
timeEntries:           # Auto-tracked by plugin
  - startTime: "2026-01-18T09:00:00"
    endTime: "2026-01-18T09:25:00"
    type: "pomodoro"
```

See `references/pomodoro-workflow.md` for detailed Pomodoro guide.

## Design Document Integration (LLM-First)

Tasks link to detailed design documents in `docs/plans/` via the `designDoc` field.

> **Important:** The implementer is an LLM (Claude). Design docs are the **primary context** for implementation, not just reference material.

### LLM Implementation Workflow

```
1. Read task file        → Get scope, status, subtasks
2. Read designDoc        → Get architecture, code patterns, decisions
3. Implement subtasks    → Follow design doc as guide
4. Update task status    → Mark subtasks done, update status
```

### Why Separate?

| TaskNotes | docs/plans |
|-----------|------------|
| Progress tracking | **Implementation context** |
| Subtasks checklist | Architecture & code patterns |
| Status for sprint sync | Detailed instructions for LLM |
| "What's left?" | "How to build it?" |

### Linking Pattern

**Task file (tracking + entry point):**
```yaml
---
uid: task-002
status: in-progress
designDoc: "[[2026-01-18-project-source-extraction-design]]"
# ...
---

# Task Title

Brief description.

## Subtasks

- [ ] Step 1 (see designDoc section X)
- [ ] Step 2 (see designDoc section Y)
```

**Design doc (implementation guide for LLM):**
```markdown
# Feature - Design Document

**Task:** [[TASK-002-project-source-extraction]]
**Status:** In Progress

## Architecture
[Diagrams the LLM needs to understand]

## Implementation Details
[Step-by-step with code examples]

## Files to Create/Modify
[Explicit file paths and changes]
```

### Design Doc Structure for LLM

Design docs should be **LLM-friendly**:

1. **Clear file paths** - Explicit paths, not vague references
2. **Code examples** - Show patterns to follow
3. **Sequential steps** - Numbered implementation order
4. **Decision rationale** - Why, not just what
5. **Validation criteria** - How to verify completion

### When to Create Design Docs

| Complexity | Design Doc? | Reason |
|------------|-------------|--------|
| Single file change | No | Task subtasks sufficient |
| 2-5 files, clear pattern | Optional | If pattern is non-obvious |
| Multi-component feature | **Yes** | LLM needs architecture context |
| New patterns/APIs | **Yes** | LLM needs examples to follow |

### Naming Convention

```
docs/plans/YYYY-MM-DD-{description}-design.md
```

Example: `2026-01-18-project-source-extraction-design.md`

See `references/plans-integration.md` for detailed workflow.

## Creating Tasks

### From Code Context

When finding TODOs, bugs, or features in code:

```yaml
---
uid: bug-042
status: open
priority: high
timeEstimate: 120           # 2 hours
tags:
  - task
  - bug
projects:
  - "[[sprint.md|Current Sprint]]"
contexts:
  - database
  - performance
---

# Fix N+1 query in course listing

## Context

Found at `packages/api/src/modules/courses/CourseRepository.ts:127`

## Solution

Use Drizzle's `with` clause for eager loading.

## Related

- [[ADR-0065]] - N+1 Batch Optimization
```

### Quick Task Creation

```yaml
---
uid: chore-043
status: open
priority: low
timeEstimate: 30
tags:
  - task
  - chore
---

# Update README with new setup steps

Add docker-compose instructions.
```

## Sprint Integration

### Memory-Bank Sync

Tasks link to `memory-bank/sprint.md` via projects:

**In task file:**
```yaml
projects:
  - "[[sprint.md|Sprint 5]]"
```

**In sprint.md:**
```markdown
## Current Sprint

### In Progress
- [[TASK-001-implement-auth]] - Auth system (8h / 16🍅)

### Todo
- [[TASK-002-fix-login-bug]] - Login fix (2h / 4🍅)

### Done
- [[TASK-000-setup-ci]] - CI pipeline ✅
```

See `references/memory-bank-integration.md` for sync workflow.

## Status Values (Plugin)

| Status | Value | Description |
|--------|-------|-------------|
| None | `none` | Not set |
| Open | `open` | Ready to work |
| In Progress | `in-progress` | Currently working |
| Done | `done` | Completed |

**Note**: Plugin uses `open` instead of `todo`/`backlog`.

## Priority Values (Plugin)

| Priority | Value | Color |
|----------|-------|-------|
| None | `none` | Gray |
| Low | `low` | Green |
| Normal | `normal` | Orange |
| High | `high` | Red |

## Task Types

| Type | Tag | ID Prefix |
|------|-----|-----------|
| Feature | `feature` | TASK- or FEAT- |
| Bug | `bug` | BUG- |
| Chore | `chore` | CHORE- |
| Spike | `spike` | SPIKE- |
| Epic | `epic` | EPIC- |

## Task Dependencies

```yaml
blockedBy:
  - uid: task-001           # Blocked by this task
```

## Plugin Views

| View | Command | File |
|------|---------|------|
| Task List | `Open Tasks View` | `tasks-default.base` |
| Kanban | `Open Kanban View` | `kanban-default.base` |
| Calendar | `Open Calendar View` | `calendar-default.base` |
| Agenda | `Open Agenda View` | `agenda-default.base` |
| Pomodoro | Sidebar tab | Built-in |

## Checklist

### Creating Tasks

- [ ] `uid` unique identifier assigned
- [ ] `tags: [task]` included (REQUIRED)
- [ ] `status` set (`open` for new tasks)
- [ ] `priority` set
- [ ] `timeEstimate` in minutes
- [ ] `projects` linked to sprint if applicable
- [ ] `contexts` added for filtering
- [ ] `designDoc` linked if task > 8h or complex

### Sprint Sync

- [ ] Task has `projects: [[sprint.md]]`
- [ ] sprint.md updated with task reference
- [ ] Status reflects actual progress
- [ ] `blockedBy` filled if blocked

### Design Doc Integration

- [ ] Design doc exists in `docs/plans/` for complex tasks
- [ ] Task has `designDoc: [[filename]]` link
- [ ] Design doc has `**Task:** [[TASK-XXX]]` backlink
- [ ] Design doc status updated when task completes

### Time Tracking

- [ ] `timeEstimate` set before starting
- [ ] Start Pomodoro timer from task
- [ ] `pomodoros` auto-updated by plugin
- [ ] Compare estimate vs actual on completion

## Additional Resources

### Reference Files

- **`references/frontmatter-schema.md`** - Complete property documentation
- **`references/views-config.md`** - Kanban, Calendar, Agenda setups
- **`references/memory-bank-integration.md`** - Sprint sync workflow
- **`references/pomodoro-workflow.md`** - Pomodoro time tracking guide
- **`references/plans-integration.md`** - Design document integration workflow

### Example Files

- **`examples/task-template.md`** - Standard task template
- **`examples/bug-template.md`** - Bug report template
