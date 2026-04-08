---
name: coverage-run
description: Use when running coverage across local test stacks such as Vitest, Playwright, or pytest.
---

# coverage-run

Execute tests with coverage collection across multiple stacks.

## Commands

```bash
/coverage-run              # Run all stacks
/coverage-run unit         # Vitest only
/coverage-run e2e          # Playwright only
/coverage-run python       # pytest only
/coverage-run api          # Vitest for packages/api only
/coverage-run web          # Vitest for apps/web only
```

## Execution Flow

### 1. Read Configuration

```bash
cat coverage-config.json
```

Extract stack commands and report paths from the config.

### 2. Auto-Detect Stack

| Input | Stack | Command |
|-------|-------|---------|
| `unit`, `vitest` | Vitest | `pnpm test -- --coverage` (turbo passthrough) |
| `e2e`, `playwright` | Playwright | `pnpm -C apps/web test:e2e` |
| `python`, `pytest` | pytest | `cd apps/ana-service && pytest --cov` |
| `api`, `database`, etc | Vitest (scoped) | `pnpm test --filter="@repo/{name}" -- --coverage` |
| (none) | All | Run sequentially |

**Important:** Use `-- --coverage` to pass args through Turborepo to Vitest.

### 3. Pre-flight Checks

Before running tests:

```bash
# Check if DB is accessible (for integration tests)
docker ps | grep postgres || echo "Warning: PostgreSQL not running"

# Check if Python venv exists for pytest
test -d apps/ana-service/.venv || echo "Warning: Python venv not found"
```

### 4. Execute Coverage

**Vitest (all packages):**
```bash
# Use -- to pass args through Turborepo
pnpm test -- --coverage --coverage.reporter=json-summary --coverage.reporter=json
```

**Vitest (filtered - recommended):**
```bash
# Filter to packages with working test scripts
pnpm test --filter="@repo/api" --filter="@repo/database" --filter="@repo/validators" --filter="@repo/logger" -- --coverage --coverage.reporter=json-summary --coverage.reporter=json
```

**Note:** Some packages (e.g., `@repo/test-utils`) have test scripts that don't accept coverage args. Use `--filter` to exclude them if needed.

**Playwright (route coverage - count specs):**
```bash
# Count specs and calculate route coverage
SPECS=$(find apps/web/e2e/flows -name "*.spec.ts" | wc -l)
TOTAL_ROUTES=216  # from e2e-coverage-plan.md
echo "E2E Coverage: $SPECS specs covering routes"
```

**pytest:**
```bash
cd apps/ana-service
source .venv/bin/activate
pytest --cov=src --cov-report=json --cov-report=term-missing
```

### 5. Parse Results

After execution, parse coverage reports:

**Vitest:** Read `coverage/coverage-summary.json`
```bash
cat coverage/coverage-summary.json | jq '.total'
```
Extract: lines.pct, branches.pct, functions.pct, statements.pct

**Playwright:** Count from spec files
```bash
find apps/web/e2e/flows -name "*.spec.ts" | wc -l
```

**pytest:** Read `apps/ana-service/coverage.json`
```bash
cat apps/ana-service/coverage.json | jq '.totals'
```

### 6. Generate Snapshot

Get current git info:
```bash
COMMIT=$(git rev-parse --short HEAD)
BRANCH=$(git branch --show-current)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

Append to `.coverage-history/snapshots.jsonl`:

```jsonl
{"ts":"$TIMESTAMP","commit":"$COMMIT","branch":"$BRANCH","vitest":{"lines":72.5,"branches":68.2,"functions":75.1},"playwright":{"covered":47,"total":216},"pytest":{"lines":85.2}}
```

### 7. Display Summary

```
======================================================
  Coverage Summary
======================================================

Stack        Lines     Branches   Functions
------------------------------------------------------
Vitest       72.5%     68.2%      75.1%
Playwright   21.8% (47/216 routes)
pytest       85.2%     78.4%      -

Duration: 45s
Commit: abc1234 (feature/auth)

Snapshot saved to .coverage-history/snapshots.jsonl

Next: Run /coverage-check to validate thresholds
======================================================
```

## Output Files

| File | Content |
|------|---------|
| `.coverage-history/snapshots.jsonl` | Appended snapshot |
| `coverage/` | Vitest HTML report |
| `coverage/coverage-summary.json` | Vitest JSON summary |
| `coverage/coverage-final.json` | Vitest detailed JSON |
| `apps/ana-service/htmlcov/` | pytest HTML report |
| `apps/ana-service/coverage.json` | pytest JSON |

## Error Handling

| Error | Action |
|-------|--------|
| Tests fail | Still collect coverage, note test failures in output |
| DB not running | Warn and continue (some tests may fail) |
| Stack not found | Skip with warning, continue with other stacks |
| No coverage report generated | Error with troubleshooting steps |
| Python venv missing | Warn and skip pytest stack |

## Examples

### Run all coverage
```bash
/coverage-run
# Runs: vitest → playwright count → pytest
# Generates unified snapshot
```

### Run only unit tests
```bash
/coverage-run unit
# Runs: pnpm test -- --coverage (turbo passthrough)
# Faster, no E2E or Python
```

### Run specific package
```bash
/coverage-run api
# Runs: pnpm test --filter="@repo/api" -- --coverage
# Scoped to @repo/api only
```

### Run filtered (exclude broken packages)
```bash
/coverage-run unit --filter
# Runs only packages with working test scripts:
# @repo/api, @repo/database, @repo/validators, @repo/logger
```
