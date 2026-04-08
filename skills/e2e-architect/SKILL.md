---
name: e2e-architect
description: Use when planning, auditing, or debugging E2E test coverage, flows, or fixture strategy.
---

# E2E Architect Skill

Design and strategy for E2E tests. Complements `e2e-run`, `e2e-analyze`, and `e2e-fix-cycle` which focus on execution and fixing.

## Project Memory

This skill reads and writes memory in the **project's** auto-memory directory to track architecture decisions across sessions.

### On Start — Read Memory

Before executing, read `<project-memory-dir>/e2e-architect.md` if it exists. Use it to:
- Know which areas have test plans already created
- Recall audit findings from previous sessions
- Reference fixture suggestions already made

### On Completion — Write Memory

After execution, update `<project-memory-dir>/e2e-architect.md`:

```markdown
# E2E Architect Memory

## Test Plans Created
| Date | Feature | Spec File | Status |
|------|---------|-----------|--------|
| <date> | <feature> | <file> | planned/implemented |

## Audit Findings
- **Last audit:** <date> — scope: <scope>
- **Coverage gaps:** <list of uncovered routes/features>
- **Anti-patterns found:** <count>

## Fixture Suggestions
- <fixture name> — <purpose> — <status: suggested/implemented>

## Debug History
| Date | Spec | Root Cause | Resolution |
|------|------|------------|------------|
| <date> | <file> | <cause> | <fix> |
```

The memory directory is the project's auto-memory path (e.g., `~/.claude/projects/<project-path>/memory/`). Create the file if it doesn't exist; merge with existing content if it does.

---

## Usage

```bash
/e2e-architect <subcommand> [args]
```

| Subcommand | Purpose | Example |
|------------|---------|---------|
| `plan` | Design tests for feature/flow | `/e2e-architect plan checkout` |
| `audit` | Coverage and quality analysis | `/e2e-architect audit --scope admin` |
| `debug` | Structured failure investigation | `/e2e-architect debug payments.spec.ts` |
| `fixtures` | Analyze/suggest fixtures | `/e2e-architect fixtures --area creator` |

---

## Parse Arguments

Extract subcommand and arguments from: `{{ARGUMENTS}}`

```
SUBCOMMAND = first word (plan|audit|debug|fixtures)
ARGS = remaining words
```

If no subcommand provided, show help:

```
/e2e-architect - E2E Test Architecture

Subcommands:
  plan <feature>     Design tests for a feature
  audit              Analyze coverage and quality
  debug <spec>       Investigate test failure
  fixtures           Review fixtures and helpers

Examples:
  /e2e-architect plan checkout flow
  /e2e-architect audit --scope admin
  /e2e-architect debug flows/payments/checkout.spec.ts
  /e2e-architect fixtures --suggest helpers
```

---

## SUBCOMMAND: plan

### Trigger
When `SUBCOMMAND` = `plan`

### Process

1. **Parse feature from ARGS**
   - Extract feature name/description

2. **Analyze context**
   - Find related routes in `apps/web/src/app/`
   - Find related components
   - Find existing tests for the area
   - Check fixtures available

3. **Identify user flows**
   - Happy path (main success scenario)
   - Edge cases (boundary conditions)
   - Error scenarios (what can fail)
   - Permissions (different user roles)

4. **Map dependencies**
   - Which fixtures needed
   - Which auth states (admin, creator, student)
   - What seed data required

5. **Generate test plan**

### Output Template

```markdown
## E2E Test Plan: {{FEATURE}}

### Prerequisites
- **Fixtures:** {{list fixtures needed}}
- **Auth state:** {{which .auth/*.json}}
- **Seed data:** {{what data must exist}}

### Scenarios

#### 1. Happy Path: {{main success flow}}
- Steps: {{step by step}}
- Assertions: {{what to verify}}
- Priority: HIGH

#### 2. Edge Case: {{boundary condition}}
- Steps: {{step by step}}
- Assertions: {{what to verify}}
- Priority: MEDIUM

#### 3. Error: {{failure scenario}}
- Steps: {{step by step}}
- Assertions: {{error handling verification}}
- Priority: MEDIUM

### Suggested Structure
- File: `flows/{{area}}/{{feature}}.spec.ts`
- Project: `{{playwright project name}}`

### Fixtures to Create (if needed)
{{list new fixtures or modifications}}

### Notes
- {{any special considerations}}
```

### Principles
- Test BEHAVIOR, not implementation
- Prioritize by user impact
- Follow existing structure (`flows/`, projects)
- Consider the AGENTS.md philosophy: test failures = code bugs

---

## SUBCOMMAND: audit

### Trigger
When `SUBCOMMAND` = `audit`

### Parse Options
- `--scope <area>`: Filter to specific area (admin, creator, student, payments, marketing)
- `--focus gaps`: Only show coverage gaps
- `--focus quality`: Only show anti-patterns

### Process

1. **Scan all specs**
   ```
   apps/web/e2e/**/*.spec.ts
   ```

2. **Map coverage by area**
   - Count specs per area
   - Count test cases (it/test blocks)
   - Compare with routes in `apps/web/src/app/`

3. **Detect anti-patterns**
   - `waitForTimeout()` with fixed values
   - Generic assertions (`toBeVisible()` without context)
   - Files > 500 lines
   - Hardcoded test data (no factories)
   - `test.skip` or `test.fixme` without issue link

4. **Identify gaps**
   - Routes without tests
   - Features without E2E coverage
   - Missing error scenarios

5. **Generate report**

### Output Template

```markdown
## E2E Audit Report

### Coverage by Area
| Area | Specs | Scenarios | Coverage |
|------|-------|-----------|----------|
| Admin | {{n}} | {{n}} | {{bar}} {{%}} |
| Creator | {{n}} | {{n}} | {{bar}} {{%}} |
| Student | {{n}} | {{n}} | {{bar}} {{%}} |
| Payments | {{n}} | {{n}} | {{bar}} {{%}} |
| Marketing | {{n}} | {{n}} | {{bar}} {{%}} |

### Critical Gaps (no coverage)
{{list routes/features without tests}}

### Anti-Patterns Detected
| File:Line | Issue | Suggestion |
|-----------|-------|------------|
| {{location}} | {{problem}} | {{fix}} |

### Recommendations
1. **High Priority:** {{critical gaps}}
2. **Medium Priority:** {{quality issues}}
3. **Quick Wins:** {{easy fixes}}

### Skipped/Fixme Tests
{{list tests marked skip/fixme with reasons}}
```

### Coverage Calculation
- Map routes from `apps/web/src/app/(admin|creator|student|marketing)/**`
- Check if corresponding spec exists in `e2e/flows/`
- Calculate percentage

---

## SUBCOMMAND: debug

### Trigger
When `SUBCOMMAND` = `debug`

### Parse Arguments
- First arg: spec file path
- `--test <name>`: specific test name (optional)

### Process

1. **Read the test file**
   - Extract test structure
   - Identify the failing test (if specified)
   - Map expected flow

2. **Analyze test expectations**
   - What does the test expect to happen?
   - What assertions are being made?
   - What state is assumed?

3. **Map production code**
   - Find related routes
   - Find related components
   - Find related API endpoints

4. **Check for recent changes**
   - `git log` on related files
   - Any recent modifications?

5. **Generate investigation guide**

### Output Template

```markdown
## Debug Investigation: {{SPEC_FILE}}

### Test: "{{test name}}"

### Expected Flow
1. {{step 1}}
2. {{step 2}}
3. {{step N}} ← (mark failure point if known)

### Investigation Checklist

#### Reproduce Manually
- [ ] Run with `--debug`: `npx playwright test {{spec}} --debug`
- [ ] Does the flow work manually in browser?
- [ ] At which step does it diverge?

#### Check Application State
- [ ] Is the expected data seeded?
- [ ] Is the user authenticated correctly?
- [ ] Are API responses as expected? (Network tab)

#### Check Code Changes
- [ ] Any recent changes to related files?
- [ ] Did a dependency update?
- [ ] Is there a race condition?

### Related Files
| Type | File | Purpose |
|------|------|---------|
| Route | {{path}} | {{description}} |
| Component | {{path}} | {{description}} |
| API | {{path}} | {{description}} |
| Fixture | {{path}} | {{description}} |

### Recent Changes
```
{{git log output for related files}}
```

### Common Root Causes
- [ ] Timing issue (element not ready)
- [ ] Data issue (seed data missing/wrong)
- [ ] Auth issue (wrong user state)
- [ ] API change (response format changed)
- [ ] Component change (selector changed)
- [ ] State issue (React state not updated)

### Commands
```bash
# Debug mode
npx playwright test {{spec}} --debug

# With trace
npx playwright test {{spec}} --trace on

# Specific test
npx playwright test {{spec}} -g "{{test name}}"

# Show report
npx playwright show-report
```

### Remember
> **Falha no teste = bug no código, não no teste.**
> Não ajuste o teste para passar. Encontre e corrija a causa raiz.
```

---

## SUBCOMMAND: fixtures

### Trigger
When `SUBCOMMAND` = `fixtures`

### Parse Options
- `--area <area>`: Focus on specific area
- `--suggest helpers`: Suggest new helpers based on patterns
- `--suggest page-objects`: Suggest page objects for complex flows

### Process

1. **Scan fixtures directory**
   ```
   apps/web/e2e/fixtures/
   apps/web/e2e/helpers/
   apps/web/e2e/pages/
   ```

2. **Catalog each file**
   - Functions exported
   - Usage across specs (grep references)
   - Pattern used (functions vs classes)

3. **Detect issues**
   - Unused exports
   - Duplicated logic across fixtures
   - Inconsistent patterns
   - Missing factories for common entities

4. **Suggest improvements**
   - New helpers for repeated patterns
   - Refactoring opportunities
   - Page objects for complex pages

### Output Template

```markdown
## Fixtures Analysis{{#if area}}: {{area}}{{/if}}

### Inventory
| File | Type | Exports | Used By |
|------|------|---------|---------|
| {{file}} | {{type}} | {{count}} | {{specs count}} |

### Issues Detected

#### Duplication
{{list duplicated logic with locations}}

#### Unused Code
{{list exports with 0 references}}

#### Inconsistencies
{{list pattern inconsistencies}}

### Suggested Helpers

```typescript
// {{filename}} - {{purpose}}
{{code suggestion}}
```

### Suggested Page Objects

```typescript
// pages/{{PageName}}.ts
{{code suggestion}}
```

### Refactoring Opportunities
| Current | Suggested | Benefit |
|---------|-----------|---------|
| {{current approach}} | {{suggested}} | {{why}} |
```

---

## Project Context

### Test Structure
```
apps/web/e2e/
├── flows/           # Tests by domain
│   ├── admin/
│   ├── creator/
│   ├── student/
│   ├── payments/
│   ├── marketing/
│   ├── auth/
│   ├── onboarding/
│   └── performance/
├── fixtures/        # Data factories
├── helpers/         # Shared utilities
├── pages/           # Page objects
└── *.spec.ts        # Legacy (root level)
```

### Playwright Projects (Tiers)
| Tier | Project | Purpose |
|------|---------|---------|
| 1 | `smoke` | Critical paths (~30s) |
| 2 | `admin:*`, `creator:*`, `student:*`, `payments`, `public` | Features |
| 3 | `creator-complete-flows` | Serial integration |

### Auth States
- `e2e/.auth/admin.json`
- `e2e/.auth/creator.json`
- `e2e/.auth/student.json`
- `e2e/.auth/onboarding-student.json`
- `e2e/.auth/onboarding-creator.json`

### Anti-Patterns to Flag
| Pattern | Problem | Solution |
|---------|---------|----------|
| `waitForTimeout(N)` | Flaky, hides async issues | Use `waitFor` with condition |
| Increased timeout | Hides performance issues | Fix root cause |
| Changed selector without understanding | Masks breaking change | Investigate component |
| Generic `toBeVisible()` | Doesn't validate behavior | Assert specific content |
| File > 500 lines | Hard to maintain | Split by scenario |
| `test.skip` without link | Lost context | Add issue reference |

---

## Integration with Other Skills

```
┌──────────────────────────────────────────────────────────────┐
│  COMPLETE WORKFLOW                                           │
├──────────────────────────────────────────────────────────────┤
│  1. /e2e-architect plan   → Design tests                     │
│  2. Implement tests                                          │
│  3. /e2e-run              → Execute                          │
│  4. /e2e-analyze          → Analyze failures                 │
│  5. /e2e-architect debug  → Deep investigation (if needed)   │
│  6. /e2e-fix-cycle        → Automated fix                    │
└──────────────────────────────────────────────────────────────┘
```

---

## Philosophy (from AGENTS.md)

> **Testes E2E falhando NÃO são problemas dos testes. São sintomas de problemas no código.**

### Never Do
- Adjust selectors without understanding why
- Increase timeouts to make tests pass
- Add fixed `waitForTimeout()`
- Remove assertions
- Mark tests as `.skip` without investigation

### Always Do
- Reproduce manually first (`--debug`)
- Find the divergence between expected and actual
- Fix the production code, not the test
- Document learnings in test comments
