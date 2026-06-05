---
name: ci-fix
description: Diagnose and fix CI failures from the latest workflow run
---

# CI Fix

Diagnose and fix CI failures from the latest workflow run.

## Workflow

### Step 1: Identify the failure

```bash
# Get the latest failed run
gh run list --limit 5 --json databaseId,status,conclusion,name,headSha
```

Pick the most recent failed run and get logs:
```bash
gh run view <run_id> --log-failed 2>&1 | tail -80
```

### Step 2: Classify the failure

| Error Pattern | Category | Fix Strategy |
|---------------|----------|-------------|
| `error TS2307: Cannot find module` in design-system check | **tsconfig exclusion** | Add path to `tsconfig.design-system.json` exclude |
| `Markup ownership check failed` | **baseline drift** | Update count in `scripts/architecture/markup-ownership-baseline.json` |
| `Design token catalog out of date` | **token sync** | Run `pnpm tokens:build` and commit |
| `error TS` in `type-check:src` | **type error** | Fix the TypeScript error in source |
| `ESLint found too many warnings` | **lint warning** | Fix the lint issue (often `no-explicit-any` or `react-hooks/exhaustive-deps`) |
| `Coverage threshold` failures | **coverage gap** | Add targeted tests for uncovered branches |
| `E409 Conflict` on npm publish | **tag misalignment** | Create missing git tag at correct commit |
| `changelog:validate` failure | **changelog format** | Fix Keep a Changelog structure |

### Step 3: Apply the fix

Fix the issue locally, then verify:

```bash
npm run type-check
npm run test:coverage
npm run lint
```

### Step 4: Commit and push

Use `fix(ci):` commit prefix for CI-only fixes:
```bash
git add <fixed-files>
git commit -m "fix(ci): <description of what was fixed>"
git push origin main
```

### Step 5: Monitor the new run

```bash
gh run list --limit 2 --json databaseId,status,conclusion,name
gh run watch <new_run_id>
```

If it fails again, re-run from Step 1 with the new failure logs.

## Common Multi-Fix Patterns

Sometimes a single push reveals multiple issues. Fix them all in one commit:

1. **tsconfig + markup baseline** — common when adding new demo pages with new components
2. **type errors + lint warnings** — common when adding `any` types to bridge props
3. **token sync + changelog** — common when theme changes happen

Always run the FULL verification suite locally before pushing the fix.
