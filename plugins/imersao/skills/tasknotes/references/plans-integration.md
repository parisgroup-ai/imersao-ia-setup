# Design Document Integration (LLM-First)

This reference explains how TaskNotes integrates with design documents for **LLM implementation**.

> **Context:** The implementer is an LLM (Claude Code), not a human developer. This changes how we structure and use documentation.

## LLM Implementation Model

```
┌─────────────────────────────────────────────────────────────────┐
│  USER REQUEST                                                    │
│  "Implement TASK-002"                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. READ TASK FILE (Entry Point)                                 │
│  docs/TaskNotes/Tasks/TASK-002-*.md                              │
│  ├── status: in-progress                                         │
│  ├── designDoc: [[2026-01-18-*-design]]  ◄── FOLLOW THIS LINK   │
│  └── subtasks: [ ] Step 1, [ ] Step 2...                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. READ DESIGN DOC (Implementation Context)                     │
│  docs/plans/2026-01-18-*-design.md                               │
│  ├── Architecture diagrams                                       │
│  ├── File paths to create/modify                                 │
│  ├── Code patterns to follow                                     │
│  ├── API contracts                                               │
│  └── Validation criteria                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. IMPLEMENT (Follow Design Doc)                                │
│  ├── Create files as specified                                   │
│  ├── Follow code patterns shown                                  │
│  ├── Mark subtasks complete in task file                         │
│  └── Run validation commands                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. UPDATE STATUS                                                │
│  ├── Task: status: done, completed: date                         │
│  └── Design doc: **Status:** Implementation Complete             │
└─────────────────────────────────────────────────────────────────┘
```

## Purpose: Task vs Design Doc

| Aspect | Task File | Design Document |
|--------|-----------|-----------------|
| **For LLM** | Entry point, progress tracking | Implementation instructions |
| **Content** | Status, subtasks checklist | Architecture, code, decisions |
| **Size** | 50-100 lines | 200-2000 lines |
| **Read When** | Start of implementation | During implementation |
| **Update When** | After each subtask | Rarely (planning phase only) |

## Design Doc Structure for LLM

Design docs must be **LLM-optimized**:

### Required Sections

```markdown
# Feature Name - Design Document

**Date:** YYYY-MM-DD
**Status:** Draft | Approved | In Progress | Complete
**Task:** [[TASK-XXX-description]]

---

## Overview

[1-2 paragraphs: What and why]

## Architecture

[ASCII diagram or description of components]

## Files to Create/Modify

### New Files

| Path | Purpose |
|------|---------|
| `apps/service/file.py` | Service implementation |
| `apps/web/component.tsx` | Frontend component |

### Modified Files

| Path | Changes |
|------|---------|
| `apps/service/main.py` | Register new router |

## Implementation Steps

### Step 1: [Component Name]

**File:** `exact/path/to/file.ext`

**Code:**
```language
// Example code the LLM should follow
function example() {
  // Pattern to replicate
}
```

**Validation:**
```bash
pnpm type-check
```

### Step 2: [Next Component]

...

## API Contracts

### Endpoint: POST /api/v1/resource

**Request:**
```json
{
  "field": "type"
}
```

**Response:**
```json
{
  "result": "type"
}
```

## Database Schema

```sql
-- Migration: XXXX_description.sql
ALTER TABLE ...
```

## Validation Checklist

- [ ] `pnpm type-check` passes
- [ ] `pnpm lint` passes
- [ ] New files created at correct paths
- [ ] API endpoints respond correctly
- [ ] Database migration applied

## Related

- [[ADR-XXXX]] - Relevant decision
- [[existing-pattern]] - Pattern to follow
```

### LLM-Friendly Principles

1. **Explicit file paths** - Never "in the service folder", always `apps/ana-service/app/services/name.py`

2. **Code examples** - Show the pattern, not just describe it
   ```python
   # Good: Show the code
   class MyService:
       def __init__(self, client: AnthropicClient):
           self.client = client

   # Bad: "Create a service class with dependency injection"
   ```

3. **Sequential steps** - Number them, the LLM will follow in order

4. **Validation commands** - Explicit commands to verify each step

5. **No ambiguity** - If there are choices, make the decision in the doc

## Task File Structure for LLM

```yaml
---
uid: task-002
status: in-progress
designDoc: "[[2026-01-18-project-source-extraction-design]]"
projects:
  - "[[sprint.md|Current Sprint]]"
tags:
  - task
  - feature
---

# Feature Name

[Brief 1-line description]

## Subtasks

- [ ] Step 1: Create service (designDoc §Implementation Step 1)
- [ ] Step 2: Create router (designDoc §Implementation Step 2)
- [ ] Step 3: Register router (designDoc §Implementation Step 3)
- [ ] Step 4: Run validation (designDoc §Validation Checklist)

## Notes

[Any context not in design doc, or learnings during implementation]
```

### Subtask Best Practices

1. **Reference design doc sections** - `(designDoc §Section Name)`
2. **Keep atomic** - One clear action per subtask
3. **Include validation** - Last subtask should be "Run validation"
4. **Update as you go** - Check off completed items

## When Design Doc is Required

| Scenario | Design Doc? | Reason |
|----------|-------------|--------|
| Bug fix in single file | No | Task subtasks sufficient |
| Add field to existing form | No | Pattern already established |
| New API endpoint | **Yes** | LLM needs contract definition |
| Multi-service feature | **Yes** | LLM needs architecture view |
| New integration | **Yes** | LLM needs API docs, patterns |
| Refactoring | **Yes** | LLM needs before/after clarity |

## Workflow Commands

### Starting Implementation

```
User: "Implement TASK-002"

LLM:
1. Read docs/TaskNotes/Tasks/TASK-002-*.md
2. Note designDoc field
3. Read docs/plans/2026-01-18-*-design.md
4. Follow Implementation Steps sequentially
5. Mark subtasks complete as you go
```

### Sprint Sync

```
User: "/tasknotes sprint sync"

LLM:
1. Read all task files in docs/TaskNotes/Tasks/
2. Compare status with sprint.md
3. Update sprint.md with current statuses
4. Report any designDoc status mismatches
```

## Context Window Considerations

Design docs should fit in context with room for implementation:

| Doc Type | Target Size | Max Size |
|----------|-------------|----------|
| Task file | 50-100 lines | 150 lines |
| Design doc | 200-500 lines | 1000 lines |
| Combined | 250-600 lines | 1150 lines |

**If design doc is too large:**
- Split into phases with separate docs
- Create task per phase
- Link phases: `**Previous:** [[phase-1-design]]`

## Sync Checklist

### Before Implementation

- [ ] Task file exists with `designDoc` link
- [ ] Design doc exists and is complete
- [ ] Design doc has `**Task:**` backlink
- [ ] All file paths in design doc are explicit
- [ ] Validation commands are specified

### After Implementation

- [ ] All subtasks checked in task file
- [ ] Task status updated to `done`
- [ ] Task has `completed` date
- [ ] Design doc status updated to "Implementation Complete"
- [ ] sprint.md reflects completion
