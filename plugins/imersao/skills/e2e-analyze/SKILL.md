---
name: e2e-analyze
description: "Analyze E2E test failures with timeline reconstruction, code correlation, and history lookup. Use after running tests: 'analyze e2e', 'e2e failures', 'diagnose tests'."
version: 1.0.0
author: gustavo
tags: [testing, e2e, analysis, debugging]
---

# e2e-analyze - Failure Analysis

Analyze E2E failures with rich context: timeline, code correlation, and history.

## Usage

```bash
/e2e-analyze                # Analyze last run (from e2e-run-result.yaml)
/e2e-analyze <test>         # Analyze specific test
```

## Analysis Steps

### Step 1: Load Last Run

```bash
cat apps/web/e2e-run-result.yaml
```

### Step 2: For Each Failure, Build Timeline

Read the error-context.md file and reconstruct:

```yaml
failure_timeline:
  test: "creator-detail.spec.ts:29"
  title: "should display creators list page"
  steps:
    - ts: "00:00.000"
      action: "goto('/admin/creators')"
      status: "ok"
    - ts: "00:00.850"
      action: "waitForLoadState('networkidle')"
      status: "ok"
    - ts: "00:01.200"
      action: "locator('h1').filter({hasText: /criadores/})"
      status: "timeout"
      error: "Timeout 5000ms exceeded"

  page_state:
    url: "/admin/creators"
    status_code: 404
    screenshot: "test-results/.../test-failed-1.png"
```

### Step 3: Code Correlation

For each failure, find related code:

```yaml
code_correlation:
  expected_route: "/admin/creators"

  search_results:
    - query: "glob: apps/web/src/app/**/admin/creators/**/page.tsx"
      found: false
    - query: "glob: apps/web/src/app/**/admin/**/creators/**/page.tsx"
      found: true
      path: "apps/web/src/app/(app)/admin/moderation/creators/page.tsx"

  suggestion:
    action: "test-update"
    description: "Route /admin/creators doesn't exist. Use /admin/moderation/creators instead."
    confidence: 0.95
```

### Step 4: History Lookup

Check `.e2e-history/failures.jsonl`:

```bash
grep "creator-detail.spec.ts:29" .e2e-history/failures.jsonl | tail -5
grep "creator-detail.spec.ts:29" .e2e-history/resolutions.jsonl | tail -1
```

```yaml
history:
  previous_failures: 2
  last_failure: "2026-01-15T10:30:00Z"
  last_resolution:
    date: "2026-01-15T11:00:00Z"
    type: "test-update"
    description: "Changed route from /admin/creators to /admin/moderation/creators"

  pattern_detected: "Recurring route mismatch - may indicate unstable route structure"
```

### Step 5: Generate Diagnosis

Create `apps/web/e2e-diagnosis.yaml`:

```yaml
analyzed_at: <ISO8601>
source: "e2e-run-result.yaml"
total_failures: 7

diagnoses:
  - test: "creator-detail.spec.ts:29"
    category: "wrong-route"
    confidence: 0.95
    batchable: true
    auto_approve: true

    timeline_summary: "Navigated to /admin/creators, got 404"

    code_correlation:
      expected: "/admin/creators"
      actual: null
      alternative: "/admin/moderation/creators"

    suggested_fix:
      type: "test-update"
      file: "apps/web/e2e/flows/admin/creator-detail.spec.ts"
      description: "Replace '/admin/creators' with '/admin/moderation/creators'"

    history:
      recurrence: true
      last_fix: "2026-01-15"

batches:
  - category: "wrong-route"
    count: 2
    auto_approve: true
    tests:
      - "creator-detail.spec.ts:29"
      - "creator-detail.spec.ts:40"

  - category: "timeout-403"
    count: 5
    auto_approve: true
    tests:
      - "permission-boundaries.spec.ts:119"
      - "permission-boundaries.spec.ts:130"
      - "permission-boundaries.spec.ts:141"
      - "permission-boundaries.spec.ts:152"
      - "permission-boundaries.spec.ts:163"
```

## Output

Present analysis in readable format:

```
═══════════════════════════════════════════════════════════
  E2E ANALYSIS COMPLETE

  7 failures analyzed, 2 batches identified

  BATCH 1: wrong-route (2 tests) ✅ auto-approve
    → Fix: Update test routes from /admin/creators to /admin/moderation/creators
    → Files: creator-detail.spec.ts
    ⚠️ History: Same issue occurred 2026-01-15

  BATCH 2: timeout-403 (5 tests) ✅ auto-approve
    → Fix: Replace waitForLoadState('networkidle') with domcontentloaded + element wait
    → Files: permission-boundaries.spec.ts

  Next: /e2e-fix-cycle to auto-fix, or fix manually
═══════════════════════════════════════════════════════════
```
