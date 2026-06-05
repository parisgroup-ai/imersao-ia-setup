---
name: e2e-run
description: "Smart E2E test runner with auto-detection of Playwright project and wait strategies. Use when running E2E tests: 'run e2e', 'e2e admin', 'test admin-tests', 'run creator tests'."
version: 1.0.0
author: gustavo
tags: [testing, e2e, automation]
---

# e2e-run - Smart E2E Test Runner

Run E2E tests with automatic project detection and optimized wait strategies.

## Usage

```bash
/e2e-run <target>           # Run tests for target
/e2e-run admin-tests        # Exact project match
/e2e-run admin              # Fuzzy match → admin-tests
/e2e-run creator-detail     # File match → detects project from path
```

## Project Auto-Detection

Read `apps/web/e2e/e2e-projects.json` to detect the correct `--project` flag:

1. **Exact match:** Input matches project name → use directly
2. **Alias match:** Input matches an alias → resolve to project
3. **Path match:** Input is a file/folder → find project by testMatch pattern
4. **Default:** Use `chromium` for unknown inputs

## Execution Steps

### Step 1: Detect Project

```bash
# Read config
cat apps/web/e2e/e2e-projects.json
```

Determine `--project=<detected>` based on input.

### Step 2: Pre-flight Check

```bash
# Check DB connections (avoid pool exhaustion)
docker exec -i cursos-postgres psql -U postgres -c \
  "SELECT count(*) FROM pg_stat_activity WHERE datname = 'cursos';" 2>/dev/null || echo "0"
```

If count > 80: `docker restart cursos-postgres && sleep 5`

### Step 3: Execute Tests

```bash
pnpm test:e2e --project=<detected> --reporter=list 2>&1 | tee /tmp/e2e-run-output.txt
```

### Step 4: Generate Structured Output

After execution, create `apps/web/e2e-run-result.yaml`:

```yaml
executed_at: <ISO8601>
project: <detected>
target: <original-input>
duration_seconds: <time>
total: <count>
passed: <count>
failed: <count>
failures:
  - test: "<file>:<line>"
    title: "<test title>"
    error_summary: "<first line of error>"
    error_context: "<path to error-context.md>"
    category: "<auto-detected category>"
```

## Category Auto-Detection

Read `apps/web/e2e/e2e-categories.json` and match error patterns:

```
"page.goto: 404"       → missing-route
"locator.click: timeout" → missing-element
"networkidle" + "403"  → timeout-403
"response.toBeOK"      → api-error
```

## Output

Always end with a summary:

```
═══════════════════════════════════════════════════════════
  E2E RUN COMPLETE
  Project: admin-tests
  Result: 205 passed, 7 failed

  Failures by category:
    - wrong-route: 2 (batchable, auto-approve)
    - timeout-403: 5 (batchable, auto-approve)

  Next: /e2e-analyze to see detailed diagnosis
═══════════════════════════════════════════════════════════
```
