---
name: team-plan
description: Use when turning a feature request into an implementation plan with parallel research agents.
---

# Team Plan

Scatter-gather planning team. Spawns research agents in parallel, gathers codebase context and requirements analysis, consolidates into an implementation plan compatible with `/team-execute` and `/plan-to-tasks`.

## Usage

```bash
/team-plan "Add badge system for students"              # Default scope (medium)
/team-plan "Add badge system" --scope large             # Full research (3 agents)
/team-plan "Fix login redirect" --scope small           # Quick plan (1 agent)
/team-plan "Add badge system" --output my-badges        # Custom output filename
```

## Parse Arguments

Extract from: `{{ARGUMENTS}}`

```
FEATURE = quoted string or remaining text after flags
SCOPE   = small | medium | large (default: medium)
OUTPUT  = --output value or auto-generated from FEATURE
```

If no arguments or FEATURE is empty, show help and stop:

```
/team-plan - Create implementation plans with parallel research agents

Usage:
  /team-plan "Add user badges"                    Medium scope (2 agents)
  /team-plan "Add badges" --scope large           Full research (3 agents)
  /team-plan "Fix redirect" --scope small         Quick plan (1 agent)
  /team-plan "Add badges" --output badge-plan     Custom filename

Pipeline: RESEARCH (parallel) → CONSOLIDATE → OUTPUT
Agents:   researcher + analyst [+ ux-mapper]
Output:   .claude/plans/{date}-{slug}.md

Next steps after plan:
  /team-execute <plan>           Execute with agent team
  /plan-to-tasks import <plan>   Import to TaskNotes
```

---

## Phase 1: PREPARE

### Generate Plan Metadata

```
SLUG      = slugify(FEATURE)        # e.g., "add-badge-system"
DATE      = YYYY-MM-DD              # today
PLAN_PATH = .claude/plans/{DATE}-{OUTPUT or SLUG}.md
```

Verify `.claude/plans/` directory exists (create if not).

---

## Phase 2: SCATTER (Spawn Research Agents)

### Agent Selection

```
If SCOPE = small:
  agents = [researcher]                           # 1 agent
If SCOPE = medium:
  agents = [researcher, analyst]                  # 2 agents
If SCOPE = large:
  agents = [researcher, analyst, ux-mapper]       # 3 agents
```

### Create Team and Spawn

1. **TeamCreate** with name `team-plan`
2. **TaskCreate** one task per agent
3. **Spawn ALL agents in parallel** using Task tool with:
   - `team_name: "team-plan"`
   - `subagent_type: "Explore"` (universal research agent)
   - `run_in_background: true`
   - `model: "sonnet"` (cost-efficient for research)

### Agent Prompt: Researcher

```markdown
## Task: Codebase Research for Feature Planning

**Feature:** {FEATURE}

You are a codebase researcher preparing context for an implementation plan. Deep-dive the codebase to find everything relevant to implementing this feature.

### Research Targets

1. **Existing patterns**: Find the closest existing implementation to what this feature needs
   - Similar pages, modules, schemas
   - Reference implementations that devs can follow

2. **File map**: Map exactly which files need to be created or modified
   - Database schemas
   - API modules (routers, repositories, use cases)
   - Frontend pages and components
   - Translation/i18n files

3. **Conventions**: Document the patterns that must be followed
   - How are routers structured and registered?
   - What repository pattern is used?
   - What UI composite/framework is standard for this type of page?
   - Where does shared code go?

4. **Dependencies**: What existing code does this feature depend on?
   - Shared types, validators, utilities
   - Related architectural decisions (ADRs, docs)
   - External packages involved

5. **Risks**: Flag anything that could cause problems
   - Files touched by recent changes (check git log)
   - Complex patterns that need special handling
   - Missing reference implementations

### Output Format

```
RESEARCH COMPLETE

## Reference Implementations
- [closest page]: {path} — uses {pattern}, {why relevant}
- [closest module]: {path} — {pattern description}
- [closest schema]: {path} — {conventions}

## File Map

### Create (new files)
- {path}: {purpose}

### Modify (existing files)
- {path}: {what to change and why}

## Conventions
- Router: {pattern + reference file path}
- Repository: {pattern + reference file path}
- Page composite: {which to use + why + reference}
- Shared code location: {convention}

## Dependencies
- Types: {relevant shared types}
- Validators: {relevant shared schemas}
- ADRs/Docs: {relevant architectural decisions}

## Risks
- {risk description + suggested mitigation}
```

### Critical Rules
- READ-ONLY. Do not create or modify any files.
- Provide CONCRETE file paths, not vague references.
- Find the CLOSEST matching reference (same domain, same pattern type).
- If no reference exists, flag as `NO_REFERENCE: {what's missing}`.
- Max 2 exploration passes. Do not spiral.
```

### Agent Prompt: Analyst

```markdown
## Task: Requirements Analysis for Feature Planning

**Feature:** {FEATURE}

You are a requirements analyst preparing acceptance criteria and impact analysis for an implementation plan.

### Analysis Targets

1. **Functional Requirements**: What must this feature do?
   - Break into discrete, testable requirements
   - Each: ID, description, priority (must/should/could), acceptance criteria

2. **Non-Functional Requirements**
   - Authentication/authorization needs
   - Performance expectations
   - Accessibility requirements

3. **Gap Analysis**: What's missing or ambiguous?
   - Does similar functionality already exist?
   - Implicit requirements from existing patterns
   - Contradictions or ambiguities in the request

4. **Impact Analysis**: Which modules/packages are affected?
   - Database schema changes
   - New API endpoints
   - UI pages/components + which portal(s)
   - i18n/translation needs

5. **Task Breakdown**: Suggest implementable tasks
   - Group by layer: DB → API → Frontend → Tests
   - Estimate complexity: S (<50 lines), M (50-150), L (>150)
   - Mark dependencies between tasks

### Output Format

```
ANALYSIS COMPLETE

## Requirements

### Must Have
- [REQ-001] {description} — Acceptance: {testable criteria}

### Should Have
- [REQ-003] {description} — Acceptance: {testable criteria}

### Could Have
- [REQ-005] {description} — Acceptance: {testable criteria}

## Gaps & Ambiguities
- {ambiguity + suggested resolution}

## Impact Map
- Database: {changes needed}
- API: {new/modified endpoints}
- UI: {pages + composites + portal}
- i18n: {approximate key count}

## Suggested Task Breakdown

### Phase 1: {layer name}
1. [{S|M|L}] {task description} — Files: {paths}

### Phase 2: {layer name}
2. [{S|M|L}] {task description} — Files: {paths}
   depends on: 1

## Complexity Estimate
Overall: {small | medium | large}
Estimated tasks: {N}
```

### Critical Rules
- READ-ONLY analysis. Do not create or modify any files.
- Requirements must be TESTABLE — reject vague criteria.
- Check if similar functionality already exists before proposing new work.
- Map to existing patterns and conventions whenever possible.
```

### Agent Prompt: UX Mapper (large scope only)

```markdown
## Task: User Journey Mapping for Feature Planning

**Feature:** {FEATURE}

You are a UX mapper tracing the user flows that this feature affects.

### Mapping Targets

1. **Affected Flows**: Which user journeys does this feature touch?
   - Map complete flows from entry to completion
   - Identify which portal(s) and persona(s)
   - Trace actual routes in the codebase

2. **Touchpoints**: What pages/components are involved?
   - Actual route paths
   - UI composites used
   - API endpoints called

3. **Cross-Portal Handoffs**: Does the flow span multiple portals?
   - Where does one persona's action trigger another's view?

4. **Friction Points**: Where could the UX break?
   - Too many steps, missing feedback, dead ends

5. **Recommendations**: How to optimize the journey

### Output Format

```
UX MAPPING COMPLETE

## User Flows

### Flow 1: {flow name}
Persona: {role/persona}
1. [Page] /route → Composite: {type} → Action: {user action}
2. [Page] /route → Composite: {type} → Action: {next step}

### Flow 2: {flow name}
...

## Cross-Portal Handoffs
- {from} → {to} at step {N}: {description}

## Friction Points
- Step {N}: {description} — Impact: {high|medium|low}

## UX Recommendations
- {recommendation + which step it improves}
```

### Critical Rules
- READ-ONLY. Do not modify any files.
- Trace ACTUAL routes in the codebase, not assumptions.
- Map existing flows + the new flow this feature creates.
- Flag where the journey breaks or has gaps.
```

---

## Phase 3: GATHER and CONSOLIDATE

### Wait for All Agents

Use TaskOutput to collect results from each background agent. Wait for all to complete.

### Consolidate into Plan

Using the gathered research, write the implementation plan following the standard plan format (compatible with `/plan-to-tasks`):

```markdown
# {Plan Title derived from FEATURE}

## Context

{Brief description synthesized from feature request + agent findings}

**Goal:** {One-sentence goal}
**Scope:** {What's included/excluded — from analyst output}
**Dependencies:** {From researcher output}

---

## Phase 1: {Phase Name — e.g., Database Schema}

### Task 1.1: {Task Title}
- **Type:** {FEAT | BUG | TASK | CHORE | DOC}
- **Priority:** {high | normal | low}
- **Estimate:** {Nh | Nm}
- **Files:** {from researcher file map}

{Task description with specific implementation details from researcher patterns}

Steps:
1. {concrete step from researcher conventions}
2. {validation step from analyst acceptance criteria}

### Task 1.2: ...

---

## Phase 2: {Next Phase}

### Task 2.1: ...

---

## API Contracts

{tRPC procedure signatures, DB schemas, component interfaces — from researcher}

## Acceptance Criteria

{Testable pass/fail criteria — from analyst requirements}

## Risks

{Combined risk flags from researcher + analyst}
```

### Consolidation Rules

1. **Phases follow the standard layer order**: Database → API → Frontend → Tests → Docs
2. **Tasks are numbered sequentially**: 1.1, 1.2, 2.1, 2.2, etc.
3. **Each task has**: Type, Priority, Estimate, Files metadata
4. **Dependencies** between tasks are explicit
5. **API Contracts** section includes concrete TypeScript signatures (tRPC, Zod, component props)
6. **Acceptance Criteria** are testable (from analyst's REQ-* items)
7. **File paths are concrete** (from researcher's file map)

### Write Plan File

Write the consolidated plan to `PLAN_PATH` using the Write tool.

---

## Phase 4: CLEANUP and REPORT

1. **TeamDelete** to remove team resources
2. Report plan summary:

```
═══════════════════════════════════════════════════════════
  TEAM PLAN: {FEATURE}
  Scope: {small|medium|large} ({agent_count} agents)
  Output: {PLAN_PATH}
═══════════════════════════════════════════════════════════

  Summary:
  - Phases: {count}
  - Tasks: {total} ({S_count} S · {M_count} M · {L_count} L)
  - Backend: {count} · Frontend: {count} · Tests: {count}

  Key Decisions:
  - {composite/framework choice}
  - {API module structure}
  - {DB schema approach}

  Next Steps:
  ├─ /team-execute {PLAN_PATH}            Execute with agent team
  ├─ /plan-to-tasks import {PLAN_PATH}    Import to TaskNotes
  └─ Review the plan manually first

═══════════════════════════════════════════════════════════
```

---

## Error Handling

| Error                     | Resolution                                               |
| ------------------------- | -------------------------------------------------------- |
| No feature description    | Show help and stop                                       |
| Agent times out           | Use partial results, flag gaps in plan                   |
| Agent output unparseable  | Include raw output, consolidate best-effort              |
| Feature too vague         | Ask user to clarify before spawning agents               |
| Plans dir doesn't exist   | Create `.claude/plans/` directory                        |
| Similar feature exists    | Report existing implementation, ask extend or replace    |

---

## Integration with Other Skills

```
┌──────────────────────────────────────────────────────────┐
│  COMPLETE WORKFLOW                                        │
├──────────────────────────────────────────────────────────┤
│  1. /team-plan "feature"       → Research + plan   ← YOU │
│  2. /plan-to-tasks import      → Create TaskNotes        │
│  3. /team-execute <plan>       → Execute with agents     │
│  4. /team-reviewer             → Review changes          │
│                                                          │
│  Alternative (skip planning):                            │
│  1. /team-execute --feature    → Full pipeline, no plan  │
└──────────────────────────────────────────────────────────┘
```

---

## What This Skill Does NOT Do

- Does NOT write code or modify existing files (only creates the plan file)
- Does NOT execute the plan (that's `/team-execute`)
- Does NOT create TaskNotes tasks (that's `/plan-to-tasks`)
- Does NOT commit, push, or create PRs
- Does NOT block — produces a plan for human review
