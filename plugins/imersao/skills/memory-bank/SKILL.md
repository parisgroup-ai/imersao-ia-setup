---
name: memory-bank
description: "Maintain and update project memory-bank files for persistent context across Claude Code sessions. Use when starting a new session, completing features, making architectural changes, or when context needs to be preserved. Triggers on: memory bank, project context, session start, context update, CLAUDE.md, project status, handoff, continue work."
version: 1.1.0
author: gustavo
tags: [context, documentation, workflow]
---

# Memory Bank Skill

This skill manages the project's memory-bank system - a structured set of files that preserve context between Claude Code sessions. The memory-bank ensures continuity, reduces repetitive explanations, and maintains project intelligence.

## Core Philosophy

Claude's memory resets between sessions. The memory-bank serves as persistent project memory:

1. **Read** memory-bank files at session start
2. **Use** context throughout the session
3. **Update** files before session ends or after significant changes

## Memory Bank Structure

```
project-root/
├── CLAUDE.md                    # Primary entry point (required)
├── memory-bank/
│   ├── projectbrief.md          # Foundation document
│   ├── productContext.md        # Why and how
│   ├── activeContext.md         # Current focus (update frequently)
│   ├── systemPatterns.md        # Architecture patterns
│   ├── techContext.md           # Technical details
│   ├── progress.md              # What's done, what's next (keep slim!)
│   ├── errors.md                # Known issues and solutions
│   └── archive/                 # (Optional) Historical details
│       ├── index.md             # Quick lookup for archived items
│       └── YYYY-MM.md           # Monthly archives (e.g., 2025-12.md)
```

### When to Archive

When `progress.md` exceeds ~500 lines, split it:

1. **Keep in progress.md**: Current sprint, next up, milestone summary table, known issues
2. **Move to archive/**: Detailed session logs, files created/modified, commits, lessons learned

This keeps progress.md scannable (<100 lines) while preserving full history.

### File Hierarchy

```
┌─────────────────────────────────────────┐
│            CLAUDE.md                     │  ← Start here ALWAYS
│         (Entry Point)                    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         projectbrief.md                  │  ← Foundation
│      (Project Foundation)                │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
┌───────────────┐   ┌───────────────┐
│ productContext│   │  techContext  │  ← Core Context
│   (Why/How)   │   │  (Stack/Tech) │
└───────┬───────┘   └───────┬───────┘
        │                   │
        └─────────┬─────────┘
                  ▼
┌─────────────────────────────────────────┐
│         systemPatterns.md                │  ← Patterns
│     (Architecture Decisions)             │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│          activeContext.md                │  ← Current State
│       (Now + Next Actions)               │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           progress.md                    │  ← History
│      (Done + Remaining Work)             │
└─────────────────────────────────────────┘
```

## File Templates

### CLAUDE.md (Entry Point)

```markdown
# Project: {{project_name}}

> **Read this file first at every session start.**

## Quick Context

- **What**: {{one_line_description}}
- **Stack**: {{primary_technologies}}
- **Status**: {{current_phase}} - {{current_focus}}

## Memory Bank

Read these files in order for full context:

1. [[memory-bank/projectbrief.md]] - Project foundation
2. [[memory-bank/productContext.md]] - Why we're building this
3. [[memory-bank/techContext.md]] - Technical decisions
4. [[memory-bank/systemPatterns.md]] - Architecture patterns
5. [[memory-bank/activeContext.md]] - Current work focus
6. [[memory-bank/progress.md]] - What's done and what's next

## Current Priority

{{current_task_or_priority}}

## Quick Commands

\`\`\`bash
# Development
{{dev_command}}

# Tests
{{test_command}}

# Build
{{build_command}}
\`\`\`

## Session Protocol

### At Session Start
1. Read this file completely
2. Read activeContext.md for current state
3. Check progress.md for pending tasks

### Before Session End
1. Update activeContext.md with current state
2. Update progress.md if tasks completed
3. Note any blockers or decisions made

---
*Last updated: {{date}} by {{author}}*
```

### projectbrief.md (Foundation)

```markdown
# Project Brief: {{project_name}}

## Overview

{{2-3_paragraph_project_description}}

## Core Requirements

### Must Have (P0)
- [ ] {{requirement_1}}
- [ ] {{requirement_2}}
- [ ] {{requirement_3}}

### Should Have (P1)
- [ ] {{requirement_4}}
- [ ] {{requirement_5}}

### Nice to Have (P2)
- [ ] {{requirement_6}}

## Target Users

| User Type | Needs | Pain Points |
|-----------|-------|-------------|
| {{user_1}} | {{needs}} | {{pain_points}} |
| {{user_2}} | {{needs}} | {{pain_points}} |

## Success Metrics

- {{metric_1}}
- {{metric_2}}
- {{metric_3}}

## Constraints

- **Timeline**: {{timeline}}
- **Budget**: {{budget_constraints}}
- **Technical**: {{technical_constraints}}

## Stakeholders

| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | {{name}} | {{responsibility}} |
| Tech Lead | {{name}} | {{responsibility}} |

---
*Created: {{date}} | Status: {{status}}*
```

### productContext.md (Why & How)

```markdown
# Product Context

## Why This Project Exists

{{problem_statement}}

## Problems We're Solving

1. **{{problem_1}}**
   - Current situation: {{situation}}
   - Impact: {{impact}}
   - Our solution: {{solution}}

2. **{{problem_2}}**
   - Current situation: {{situation}}
   - Impact: {{impact}}
   - Our solution: {{solution}}

## How It Should Work

### User Journey

\`\`\`
{{user}} → {{action_1}} → {{action_2}} → {{outcome}}
\`\`\`

### Core Workflows

#### Workflow 1: {{name}}
1. User does X
2. System responds with Y
3. Result is Z

#### Workflow 2: {{name}}
1. ...

## User Experience Goals

- **Fast**: {{performance_goal}}
- **Simple**: {{simplicity_goal}}
- **Reliable**: {{reliability_goal}}

## What Success Looks Like

When this project is complete, users will be able to:
- {{outcome_1}}
- {{outcome_2}}
- {{outcome_3}}

---
*Last updated: {{date}}*
```

### techContext.md (Technical Details)

```markdown
# Technical Context

## Tech Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| Frontend | {{tech}} | {{version}} | {{purpose}} |
| Backend | {{tech}} | {{version}} | {{purpose}} |
| Database | {{tech}} | {{version}} | {{purpose}} |
| Cache | {{tech}} | {{version}} | {{purpose}} |
| Infra | {{tech}} | {{version}} | {{purpose}} |

## Project Structure

\`\`\`
{{project_name}}/
├── src/
│   ├── {{folder_1}}/     # {{description}}
│   ├── {{folder_2}}/     # {{description}}
│   └── {{folder_3}}/     # {{description}}
├── tests/
├── docs/
└── {{other_folders}}
\`\`\`

## Key Dependencies

| Package | Version | Purpose | Notes |
|---------|---------|---------|-------|
| {{package}} | {{version}} | {{purpose}} | {{notes}} |

## Development Setup

\`\`\`bash
# Prerequisites
{{prerequisites}}

# Installation
{{install_commands}}

# Environment
cp .env.example .env
# Configure: {{env_vars_to_set}}

# Run
{{run_command}}
\`\`\`

## Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | Yes | PostgreSQL connection | `postgresql://...` |
| `JWT_SECRET` | Yes | Auth token signing | `random-32-chars` |

## External Services

| Service | Purpose | Docs | Credentials |
|---------|---------|------|-------------|
| {{service}} | {{purpose}} | [Link](url) | In 1Password |

## Technical Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| {{decision}} | {{why}} | {{date}} |

See [[systemPatterns.md]] for architecture patterns.

---
*Last updated: {{date}}*
```

### systemPatterns.md (Architecture)

```markdown
# System Patterns

## Architecture Overview

\`\`\`
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│     API     │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    Cache    │
                    └─────────────┘
\`\`\`

## Design Patterns in Use

### Pattern 1: {{name}}

**Where**: {{where_used}}
**Why**: {{rationale}}

\`\`\`typescript
// Example
{{code_example}}
\`\`\`

### Pattern 2: {{name}}

**Where**: {{where_used}}
**Why**: {{rationale}}

## Code Conventions

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-service.ts` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase | `createUser` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |

### File Organization

\`\`\`typescript
// 1. Imports (external)
import { Injectable } from '@nestjs/common';

// 2. Imports (internal)
import { UserRepository } from './user.repository';

// 3. Types/Interfaces
interface CreateUserDto { }

// 4. Implementation
export class UserService { }
\`\`\`

## API Patterns

### Request/Response Format

\`\`\`typescript
// Success
{ data: T, meta: { requestId, timestamp } }

// Error
{ error: { code, message, details }, meta: { requestId } }
\`\`\`

### Error Handling

\`\`\`typescript
// Domain errors → 4xx with specific code
// Infrastructure errors → 5xx with generic message
// Always log full error, return safe message
\`\`\`

## Database Patterns

### Naming
- Tables: plural, snake_case (`users`, `order_items`)
- Columns: snake_case (`created_at`, `user_id`)

### Required Columns
Every table has: `id`, `created_at`, `updated_at`

## Testing Patterns

\`\`\`typescript
describe('{{Unit}}', () => {
  describe('{{method}}', () => {
    it('should {{expected_behavior}} when {{condition}}', () => {
      // Arrange
      // Act  
      // Assert
    });
  });
});
\`\`\`

## Anti-Patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| {{anti_pattern}} | {{correct_approach}} |

---
*Last updated: {{date}}*
```

### activeContext.md (Current State) ⚡

```markdown
# Active Context

> ⚡ **This file changes frequently. Update before ending each session.**

## Current Session

**Date**: {{date}}
**Focus**: {{current_focus}}

## Working On Now

### {{current_task}}

**Status**: 🟡 In Progress | 🟢 Complete | 🔴 Blocked

**What I'm doing**:
{{description_of_current_work}}

**Files being modified**:
- `{{file_1}}` - {{what_changing}}
- `{{file_2}}` - {{what_changing}}

**Decisions made this session**:
- {{decision_1}}
- {{decision_2}}

## Recent Changes

| Date | Change | Files |
|------|--------|-------|
| {{date}} | {{change}} | {{files}} |

## Current Blockers

- [ ] {{blocker_1}} - {{who_can_help}}
- [ ] {{blocker_2}}

## Next Actions

1. [ ] {{next_action_1}}
2. [ ] {{next_action_2}}
3. [ ] {{next_action_3}}

## Context for Next Session

{{important_context_to_remember}}

### Open Questions

- {{question_1}}
- {{question_2}}

### Notes

{{any_other_notes}}

---
*Last updated: {{timestamp}}*
```

### progress.md (Slim Format - Keep Under 100 Lines)

```markdown
# Progress

**Last Updated:** {{date}}

## Current Sprint

**{{sprint_name}}** {{status}}
- {{brief_description}}
- Plan: `docs/plans/{{plan_file}}`

## Next Up

1. **{{priority_1}}** - {{brief_description}}
2. **{{priority_2}}** - {{brief_description}}
3. **{{priority_3}}** - {{brief_description}}

## Completed Milestones

| Milestone | Date | Archive |
|-----------|------|---------|
| {{milestone_1}} | {{date}} | [YYYY-MM](archive/YYYY-MM.md#anchor) |
| {{milestone_2}} | {{date}} | [YYYY-MM](archive/YYYY-MM.md#anchor) |

## Known Issues

- **{{issue_1}}** - {{context}}
- **{{issue_2}}** - {{context}}

## Quick Stats

| Metric | Value |
|--------|-------|
| {{metric_1}} | {{value}} |
| {{metric_2}} | {{value}} |

---
*For detailed history, see [archive/index.md](archive/index.md)*
```

### archive/index.md (Quick Lookup)

```markdown
# Progress Archive Index

Quick reference to past work. Click month links for full details.

| Item | Month | Key Decisions |
|------|-------|---------------|
| {{feature_1}} | [{{Mon YYYY}}](YYYY-MM.md#anchor) | {{one_liner}} |
| {{feature_2}} | [{{Mon YYYY}}](YYYY-MM.md#anchor) | {{one_liner}} |
```

### archive/YYYY-MM.md (Monthly Archive)

```markdown
# {{Month Year}}

Detailed implementation history for {{Month Year}}.

---

## {{Feature Name}} {#anchor-id}

**Date:** {{Mon DD}}, Session {{N}}
**Plan:** `docs/plans/{{plan_file}}`

**Scope:** {{description}}

**Tasks Completed:**

| Task | Description | Status |
|------|-------------|--------|
| 1 | {{task_1}} | ✅ |
| 2 | {{task_2}} | ✅ |

**Files Created:**
- `{{path/to/file.ts}}` - {{purpose}}

**Files Modified:**
- `{{path/to/file.ts}}` - {{changes}}

**Commits:**
- `{{hash}}` {{message}}

**Lessons Learned:**
1. {{lesson_1}}
2. {{lesson_2}}

---

## {{Next Feature}} {#next-anchor}
...
```

### errors.md (Known Issues & Solutions)

```markdown
# Errors & Solutions

> Reference for known issues and their solutions.

## Common Errors

### Error: {{error_name}}

**Message**:
\`\`\`
{{error_message}}
\`\`\`

**Cause**: {{why_this_happens}}

**Solution**:
\`\`\`bash
{{solution_command_or_code}}
\`\`\`

**Prevention**: {{how_to_prevent}}

---

### Error: {{error_name_2}}

**Message**:
\`\`\`
{{error_message}}
\`\`\`

**Cause**: {{why_this_happens}}

**Solution**: {{solution}}

---

## Environment Issues

### Issue: {{issue_name}}

**Symptoms**: {{what_you_see}}

**Fix**:
1. {{step_1}}
2. {{step_2}}

---

## Build/Deploy Issues

### {{issue}}

**When**: {{when_it_happens}}
**Fix**: {{solution}}

---

## Gotchas

Things that commonly trip people up:

1. **{{gotcha_1}}**: {{explanation}}
2. **{{gotcha_2}}**: {{explanation}}

---
*Add new errors as they're encountered and solved.*
```

## Update Protocols

### When to Update Memory Bank

| Event | Files to Update |
|-------|-----------------|
| Session start | Read all, verify activeContext |
| Feature complete | progress.md, activeContext.md |
| Bug fixed | errors.md (add solution) |
| Architecture change | systemPatterns.md, techContext.md |
| New decision | systemPatterns.md or techContext.md |
| Session end | activeContext.md (always) |
| Blocker hit | activeContext.md |
| New team member | Verify all files current |
| progress.md > 500 lines | Create archive/, move details |
| Month changes | Start new archive/YYYY-MM.md |

### Update Checklist

Before ending a session:

- [ ] activeContext.md reflects current state
- [ ] Any completed work logged in progress.md
- [ ] New errors/solutions added to errors.md
- [ ] Decisions documented in appropriate file
- [ ] Next actions are clear for next session

## Commands

### Initialize Memory Bank

```bash
mkdir -p memory-bank
touch CLAUDE.md
touch memory-bank/{projectbrief,productContext,activeContext,systemPatterns,techContext,progress,errors}.md
```

### Initialize Archive (when progress.md gets large)

```bash
mkdir -p memory-bank/archive
touch memory-bank/archive/index.md
touch memory-bank/archive/$(date +%Y-%m).md
```

### Quick Status Check

At session start, ask Claude:
```
Read CLAUDE.md and memory-bank/activeContext.md. 
Summarize current project state and next actions.
```

### Full Context Load

```
Read all memory-bank files and provide a complete project summary.
```

### Update Request

```
Update memory-bank/activeContext.md with:
- Current work: [description]
- Decisions made: [list]
- Next actions: [list]
```

## Best Practices

1. **Keep activeContext.md current** - Most important file
2. **Keep progress.md slim** - Under 100 lines; archive details monthly
3. **Be specific** - "Working on auth" → "Implementing JWT refresh token rotation"
4. **Include file paths** - Makes context actionable
5. **Note decisions with rationale** - Future you will thank you
6. **Update incrementally** - Small updates > big rewrites
7. **Link between files** - Use `[[filename]]` references
8. **Date everything** - Context ages, timestamps help
9. **Archive when bloated** - If progress.md > 500 lines, time to archive

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Let files get stale | Update at session end |
| Write novels | Keep it scannable |
| Duplicate info | Link between files |
| Skip updates "just this once" | Always update activeContext |
| Store secrets | Use .env, reference in techContext |
| Let progress.md grow forever | Archive monthly when > 500 lines |
