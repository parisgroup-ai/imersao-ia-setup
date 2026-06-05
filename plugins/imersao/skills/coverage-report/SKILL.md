---
name: coverage-report
description: Use when analyzing coverage history, trends, or comparisons between snapshots and branches.
---

# coverage-report

Generate comprehensive coverage reports with historical data and trend analysis.

## Commands

```bash
/coverage-report              # Current + 7-day trend
/coverage-report --full       # Full report with all gaps
/coverage-report --compare    # Compare branch vs main
/coverage-report --trend 30   # 30-day trend analysis
```

## Execution Flow

### 1. Load History

```bash
cat .coverage-history/snapshots.jsonl
```

Parse all snapshots into array for analysis. Each line is a JSON object.

### 2. Calculate Current State

From latest snapshot (last line):
```bash
tail -1 .coverage-history/snapshots.jsonl | jq .
```

Extract:
- Vitest: lines, branches, functions
- Playwright: routes covered / total
- pytest: lines, branches

### 3. Calculate Trends

**7-day trend (default):**
```bash
# Get snapshot from 7 days ago
WEEK_AGO=$(date -v-7d +%Y-%m-%d)
grep "\"ts\":\"$WEEK_AGO" .coverage-history/snapshots.jsonl | tail -1
```

**30-day trend (with --trend 30):**
```bash
MONTH_AGO=$(date -v-30d +%Y-%m-%d)
grep "\"ts\":\"$MONTH_AGO" .coverage-history/snapshots.jsonl | tail -1
```

**Trend indicators:**
| Delta | Indicator |
|-------|-----------|
| > +0.5% | ↑ (improving) |
| -0.5% to +0.5% | → (stable) |
| < -0.5% | ↓ (declining) |

### 4. Load Critical Gaps History

```bash
cat .coverage-history/critical-gaps.jsonl
```

Track persistence:
- **New:** First seen in current snapshot
- **Persistent:** Seen in multiple snapshots (calculate days)
- **Resolved:** Was in history, now meets threshold

### 5. Cross-Reference E2E Plan

Load E2E coverage plan for progress tracking:
```bash
cat docs/plans/e2e-coverage-plan.md
```

Extract phase targets and compare with current Playwright coverage.

### 6. Generate ASCII Trend Chart

For the trend visualization:

```
Lines Coverage (7 days)
75% │           ╭──●
    │       ╭───╯
70% │   ╭───╯
    │ ──╯
65% │
    └─────────────────
      28  29  30  31  01  02  03  04
```

**Algorithm:**
1. Get all snapshots in date range
2. Find min/max coverage values
3. Scale to 5 rows (height)
4. Plot each day's value
5. Connect with box-drawing characters (─, │, ╭, ╯, ●)

### 7. Generate Report

Output formatted markdown report:

```markdown
# Coverage Report - 2026-02-04

## Summary

| Stack | Lines | Branches | Functions | Trend (7d) |
|-------|-------|----------|-----------|------------|
| Vitest | 72.5% | 68.2% | 75.1% | ↑ +2.3% |
| Playwright | 30.1% (65/216) | - | - | ↑ +5.0% |
| pytest | 85.2% | 78.4% | - | → 0.0% |

## Module Status

| Module | Current | Target | Delta | Status |
|--------|---------|--------|-------|--------|
| packages/api | 78.5% | 80% | -1.5% | ⚠️ Below |
| apps/ana-service | 87.2% | 85% | +2.2% | ✅ Above |
| packages/database | 71.0% | 70% | +1.0% | ✅ Met |

## Critical Gaps

| File | Coverage | Required | Age | Risk |
|------|----------|----------|-----|------|
| auth.ts | 45.2% | 90% | 15 days | 🔴 CRITICAL |
| payments.ts | 62.1% | 90% | 8 days | 🔴 HIGH |
| llm_service.py | 72.5% | 90% | New | 🟡 MEDIUM |

## Trend (7 days)

    Lines Coverage
    75% │           ╭──●
        │       ╭───╯
    70% │   ╭───╯
        │ ──╯
    65% │
        └─────────────────
          28  29  30  31  01  02  03  04

## E2E Progress

From docs/plans/e2e-coverage-plan.md:

| Phase | Target | Current | Status |
|-------|--------|---------|--------|
| Phase 1 | 46% (100 routes) | 30.1% (65 routes) | 🟡 In Progress |
| Phase 2 | 65% (140 routes) | - | ⬜ Pending |
| Phase 3 | 83% (180 routes) | - | ⬜ Pending |

## Recommendations

1. **Priority 1:** Add tests for `auth.ts` (45% → 90%)
   - Uncovered: lines 23-45, 78-92
   - Risk: Critical authentication logic exposed

2. **Priority 2:** Add tests for `payments.ts` (62% → 90%)
   - Uncovered: lines 55-70 (refund flow)

3. **Quick Win:** `packages/api` needs only +1.5% to meet threshold
   - Add 3-4 tests to any uncovered module

4. **E2E:** Focus on Phase 1 specs (Student Settings, Creator Projects)
```

### 8. Update Index

Update `.coverage-history/index.json`:

```json
{
  "lastRun": "2026-02-04T15:30:00Z",
  "lastCommit": "abc1234",
  "totalSnapshots": 45,
  "averages": {
    "vitest": { "lines": 71.2, "branches": 67.8 },
    "playwright": { "percentage": 28.5 },
    "pytest": { "lines": 84.1 }
  },
  "criticalFiles": {
    "packages/api/src/services/auth.ts": {
      "firstSeen": "2026-01-15",
      "currentCoverage": 45.2,
      "trend": "stable"
    }
  }
}
```

## Compare Mode (--compare)

When `--compare` flag is used:

```bash
# Get main branch snapshot
git stash
git checkout main --quiet
MAIN_SNAPSHOT=$(tail -1 .coverage-history/snapshots.jsonl)
git checkout - --quiet
git stash pop --quiet 2>/dev/null || true
```

Generate comparison:

```markdown
## Branch Comparison: feature/auth vs main

| Metric | main | feature/auth | Delta |
|--------|------|--------------|-------|
| Lines | 70.2% | 72.5% | +2.3% ✅ |
| Branches | 68.5% | 68.2% | -0.3% ⚠️ |
| Functions | 74.0% | 75.1% | +1.1% ✅ |

### New Coverage Added
- `auth.ts`: 0% → 45.2% (+45.2% new)
- `login.test.ts`: New test file

### Coverage Regression
- `user-service.ts`: 85% → 82% (-3.0%)
  Check if tests were removed or code added without tests
```

## Full Mode (--full)

Shows all gaps, not just critical:

```markdown
## All Coverage Gaps (below 70%)

| File | Coverage | Lines Missing |
|------|----------|---------------|
| auth.ts | 45.2% | 23-45, 78-92, 110-125 |
| payments.ts | 62.1% | 55-70, 88-95 |
| user-repo.ts | 68.5% | 42-48 |
| ... (15 more files) |

Total: 18 files below 70% threshold
```

## Display Summary

```
======================================================
  Coverage Report Generated
======================================================

Current Coverage:
  Vitest:     72.5% lines (↑ +2.3% from last week)
  Playwright: 30.1% routes (65/216)
  pytest:     85.2% lines (stable)

Critical Gaps: 3 files need attention
  - auth.ts (45% - CRITICAL)
  - payments.ts (62% - HIGH)
  - llm_service.py (72% - MEDIUM)

E2E Progress: Phase 1 at 65% completion

Full report: .coverage-history/report-2026-02-04.md

Next steps:
  1. Run /coverage-check --strict before PR
  2. Add tests for auth.ts (highest priority)
======================================================
```
