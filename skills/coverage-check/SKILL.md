---
name: coverage-check
description: Use when validating coverage thresholds, PR gates, or critical low-coverage files.
---

# coverage-check

Validate coverage against configured thresholds and identify gaps in critical files.

## Commands

```bash
/coverage-check            # Validate last snapshot against config
/coverage-check --strict   # Fail on any critical gap
/coverage-check --pr       # Compare current branch vs main
```

## Execution Flow

### 1. Load Configuration

```bash
cat coverage-config.json
```

Extract:
- `thresholds.global` - Global minimums (lines, branches, functions)
- `thresholds.<module>` - Module-specific thresholds
- `criticalPaths` - Glob patterns for critical files
- `criticalFiles` - Explicit critical files list
- `criticalMinCoverage` - Minimum for critical files (default 90%)

### 2. Load Latest Snapshot

```bash
tail -1 .coverage-history/snapshots.jsonl
```

Parse JSON to get current coverage metrics for each stack.

If no snapshot exists, run `/coverage-run` first.

### 3. Validate Global Thresholds

For each metric in `thresholds.global`:

```yaml
global_check:
  lines:
    actual: <from vitest snapshot>
    threshold: <from config>
    status: PASS | FAIL
  branches:
    actual: <from vitest snapshot>
    threshold: <from config>
    status: PASS | FAIL
  functions:
    actual: <from vitest snapshot>
    threshold: <from config>
    status: PASS | FAIL
```

### 4. Validate Module Thresholds

For each module in `thresholds` (except "global"):

```bash
# Get module-specific coverage from detailed report
cat coverage/coverage-final.json | jq '[to_entries[] | select(.key | contains("packages/api"))] |
  map(.value.s | to_entries | map(if .value > 0 then 1 else 0 end) | add / length * 100) | add / length'
```

### 5. Identify Critical Gaps

**By Convention (criticalPaths):**

For each pattern in `criticalPaths`:
```bash
# Find matching files
find . -path "**/services/**" -name "*.ts" -not -path "**/node_modules/**" -not -path "**/*.test.ts"
```

**By Explicit List (criticalFiles):**

Check each file in the `criticalFiles` array.

**For each critical file found:**
1. Look up coverage in `coverage/coverage-final.json`
2. Calculate statement coverage percentage
3. Compare against `criticalMinCoverage` (90%)
4. If below threshold, extract uncovered line numbers
5. Add to gaps list with risk assessment

### 6. Calculate Risk Level

| Coverage | Risk |
|----------|------|
| < 50% | CRITICAL |
| 50-70% | HIGH |
| 70-90% | MEDIUM |
| >= 90% | OK |

### 7. Generate Diagnosis

Create `coverage-check-result.yaml`:

```yaml
status: PASS | WARN | FAIL
timestamp: "2026-02-04T15:35:00Z"
commit: "abc1234"

global_check:
  lines: { actual: 72.5, threshold: 70, status: PASS }
  branches: { actual: 68.2, threshold: 70, status: FAIL }
  functions: { actual: 75.1, threshold: 70, status: PASS }

module_checks:
  - module: "packages/api"
    lines: { actual: 78.5, threshold: 80, status: FAIL }
  - module: "apps/ana-service"
    lines: { actual: 87.2, threshold: 85, status: PASS }

critical_gaps:
  - file: "packages/api/src/services/auth.ts"
    coverage: 45.2
    required: 90
    uncovered_lines: [23-45, 78-92]
    risk: CRITICAL
  - file: "packages/api/src/routers/payments.ts"
    coverage: 62.1
    required: 90
    uncovered_lines: [55-70, 88-95]
    risk: HIGH

recommendations:
  - "Add tests for auth.ts:23-45 (authentication logic)"
  - "Increase packages/api coverage by 1.5% to meet threshold"
```

### 8. Log Critical Gaps to History

Append to `.coverage-history/critical-gaps.jsonl`:

```jsonl
{"ts":"2026-02-04T15:35:00Z","file":"packages/api/src/services/auth.ts","coverage":45.2,"required":90,"risk":"CRITICAL"}
```

### 9. Determine Status

| Condition | Status | Exit Code |
|-----------|--------|-----------|
| All global OK + no critical gaps | PASS | 0 |
| Global OK + some critical gaps (non-strict) | WARN | 0 |
| Any global threshold FAIL | FAIL | 1 |
| Any critical file < 50% | FAIL | 1 |
| `--strict` mode + any critical gap | FAIL | 1 |

### 10. Display Results

```
======================================================
  Coverage Check Results
======================================================

Status: WARN

Global Thresholds:
  [PASS] Lines:     72.5% (>= 70%)
  [FAIL] Branches:  68.2% (< 70%)
  [PASS] Functions: 75.1% (>= 70%)

Module Thresholds:
  [FAIL] packages/api:     78.5% (< 80%)
  [PASS] apps/ana-service: 87.2% (>= 85%)

Critical Gaps (2 files):
  [CRITICAL] auth.ts:        45.2% (need 90%)
             Uncovered: 23-45, 78-92
  [HIGH]     payments.ts:    62.1% (need 90%)
             Uncovered: 55-70, 88-95

Recommendations:
  1. Add tests for auth.ts:23-45 (priority: critical)
  2. Increase packages/api coverage by 1.5%
  3. Add tests for payments.ts:55-70

Run /coverage-report for detailed analysis
======================================================
```

## PR Comparison Mode (--pr)

When `--pr` flag is used:

```bash
# Save current coverage
CURRENT=$(tail -1 .coverage-history/snapshots.jsonl)

# Get main branch coverage
git stash
git checkout main --quiet
MAIN=$(tail -1 .coverage-history/snapshots.jsonl)
git checkout - --quiet
git stash pop --quiet 2>/dev/null || true
```

Compare and show delta:

```
======================================================
  Coverage Change: feature/auth vs main
======================================================

Metric      main      current    delta
------------------------------------------------------
Lines       70.2%     72.5%      +2.3%  [IMPROVED]
Branches    68.5%     68.2%      -0.3%  [REGRESSION]
Functions   74.0%     75.1%      +1.1%  [IMPROVED]

Overall: Coverage improved (+1.0% average)
======================================================
```

## Strict Mode (--strict)

In strict mode, ANY critical gap causes failure:

```
[FAIL] Strict mode: 2 critical gaps found

Files requiring coverage before merge:
  - auth.ts (45.2% < 90%)
  - payments.ts (62.1% < 90%)

Add tests for these files or use /coverage-check without --strict
```
