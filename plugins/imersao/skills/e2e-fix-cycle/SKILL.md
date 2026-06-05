---
name: e2e-fix-cycle
description: "Automated E2E test-fix cycle. Runs tests, analyzes failures, applies fixes in batches, re-runs until pass. Use for full automation: 'fix e2e', 'e2e cycle', 'auto-fix tests'."
version: 1.0.0
author: gustavo
tags: [testing, e2e, automation, debugging]
---

# e2e-fix-cycle - Automated Test-Fix Loop

Orchestrates e2e-run → e2e-analyze → fix → repeat until all tests pass.

## Usage

```bash
/e2e-fix-cycle <target>     # Full cycle for target
/e2e-fix-cycle admin-tests  # Fix all admin test failures
```

## Configuration

```yaml
limits:
  max_iterations: 5
  max_auto_fixes_per_batch: 10

require_approval:
  - code-create      # Creating new files
  - schema-change    # Database changes
  - seed-update      # Test data changes

auto_approve:
  - test-update      # Updating test code
  - wait-strategy    # Changing wait patterns
```

## Cycle Flow

```
┌─────────────────────────────────────────────────────────────┐
│  ITERATION 1                                                │
├─────────────────────────────────────────────────────────────┤
│  1. /e2e-run admin-tests                                    │
│     → 7 failures                                            │
│                                                             │
│  2. /e2e-analyze                                            │
│     → 2 batches: wrong-route(2), timeout-403(5)            │
│                                                             │
│  3. FIX BATCH 1: wrong-route (auto-approve)                │
│     → Edit creator-detail.spec.ts                          │
│     → Replace /admin/creators with /admin/moderation/creators│
│                                                             │
│  4. VERIFY BATCH 1                                          │
│     /e2e-run -g "creator-detail" --project=admin-tests     │
│     → 2 tests now pass                                      │
│                                                             │
│  5. FIX BATCH 2: timeout-403 (auto-approve)                │
│     → Edit permission-boundaries.spec.ts                    │
│     → Replace networkidle with domcontentloaded            │
│                                                             │
│  6. VERIFY BATCH 2                                          │
│     /e2e-run -g "permission-boundaries" --project=admin-tests│
│     → 5 tests now pass                                      │
│                                                             │
│  7. FULL VERIFICATION                                       │
│     /e2e-run admin-tests                                    │
│     → 212 passed, 0 failed ✅                               │
│                                                             │
│  8. LOG RESOLUTIONS                                         │
│     → Append to .e2e-history/resolutions.jsonl             │
│                                                             │
│  9. COMMIT                                                  │
│     git commit -m "fix(e2e): resolve admin test failures"  │
└─────────────────────────────────────────────────────────────┘
```

## Batch Processing

### Auto-Approve Batches

For `test-update` and `wait-strategy`:

1. Apply all fixes in batch
2. Run affected tests only: `--grep="pattern1|pattern2"`
3. If pass → continue
4. If fail → revert, switch to one-by-one mode

### Require-Approval Batches

For `code-create`, `schema-change`, `seed-update`:

1. Present the fix plan to user
2. Wait for explicit approval
3. Apply fix
4. Verify
5. Ask before continuing to next

## Fix Templates

### wrong-route

```typescript
// BEFORE
await page.goto('/admin/creators');

// AFTER
await page.goto('/admin/moderation/creators');
```

### timeout-403

```typescript
// BEFORE
await page.goto('/admin');
await page.waitForLoadState('networkidle');

// AFTER
await page.goto('/admin');
await page.waitForLoadState('domcontentloaded');
await page.locator('main, [data-testid="access-denied"], body').first().waitFor({ timeout: 10000 }).catch(() => {});
```

### missing-element

```typescript
// Requires investigation - present options to user:
// 1. Element selector changed → update test
// 2. Component not rendering → fix component
// 3. Feature removed → remove test
```

## History Logging

After successful fix, append to `.e2e-history/resolutions.jsonl`:

```jsonl
{"ts":"2026-02-04T10:45:00Z","test":"creator-detail.spec.ts:29","fix_type":"test-update","fix_commit":"abc1234","resolution":"Changed route from /admin/creators to /admin/moderation/creators"}
```

## Output

After each iteration:

```
═══════════════════════════════════════════════════════════
  E2E FIX CYCLE - ITERATION 1 COMPLETE

  Started: 7 failures
  Fixed: 7 (2 batches)
  Remaining: 0

  Fixes applied:
    ✅ wrong-route: 2 tests (auto-approved)
    ✅ timeout-403: 5 tests (auto-approved)

  Status: ALL TESTS PASSING ✅

  Committed: fix(e2e): resolve admin test failures
═══════════════════════════════════════════════════════════
```

## Safeguards

1. **Max iterations:** Stop after 5 cycles to prevent infinite loops
2. **Revert on failure:** If batch fix makes things worse, revert
3. **One-by-one fallback:** If batch fails, try fixes individually
4. **Manual escalation:** Complex fixes require user approval
5. **History check:** Warn if same test keeps failing
