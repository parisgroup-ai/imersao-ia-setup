---
name: tag-audit
description: "Audit git tags vs npm versions vs package.json for misalignment. Use when: pre-release (both /release-maintenance and /project-release), after failed releases, investigating E409 conflicts, deploy version drift, or periodic health checks."
---

# Tag Audit

Detects tag/version misalignment that causes E409 conflicts, failed releases, and deploy version drift. Works for both **npm package releases** and **app deploys**.

## When to Use

- Before any release (`/release-maintenance` or `/project-release`)
- After a failed Release workflow (E409 Conflict)
- After a failed deploy (version mismatch)
- When `package.json` version doesn't match latest tag
- Periodic health check on version state

## Step 0: Detect Release Type

```bash
# Check if this is an npm package or an app
if grep -q '"publishConfig"' package.json 2>/dev/null || grep -q 'npm.pkg.github.com' package.json 2>/dev/null; then
  echo "TYPE: npm-package"
else
  echo "TYPE: app-deploy"
fi

# Check if semantic-release is configured
if [ -f ".releaserc.json" ] || [ -f ".releaserc.js" ] || grep -q 'semantic-release' package.json 2>/dev/null; then
  echo "RELEASE: semantic-release (tags are authoritative)"
else
  echo "RELEASE: manual (package.json + tag must match)"
fi
```

## Audit Procedure

### Step 1: Gather State (run in parallel)

```bash
# Current package.json version
grep '"version"' package.json | head -1

# Local tags
git tag -l 'v*' | sort -V | tail -10

# Remote tags
git ls-remote --tags origin | grep -E 'refs/tags/v[0-9]' | sort -t '/' -k 3 -V | tail -10

# npm published version (npm packages only)
npm view $(grep '"name"' package.json | head -1 | sed 's/.*": *"//;s/".*//' ) version --registry https://npm.pkg.github.com 2>/dev/null || echo "NOT PUBLISHED or APP"

# Check if local tags match remote
git fetch --tags --dry-run origin 2>&1

# For app deploys: check deployed version if available
# Railway: railway status
# Vercel: vercel ls --limit 1
```

### Step 2: Alignment Check

Build a comparison table:

**For npm packages:**

| Source | Version | Status |
|--------|---------|--------|
| `package.json` | X.Y.Z | - |
| Latest local tag | vX.Y.Z | match/mismatch |
| Latest remote tag | vX.Y.Z | match/mismatch |
| npm registry | X.Y.Z | match/mismatch |

**For app deploys:**

| Source | Version | Status |
|--------|---------|--------|
| `package.json` | X.Y.Z | - |
| Latest local tag | vX.Y.Z | match/mismatch |
| Latest remote tag | vX.Y.Z | match/mismatch |
| Deployed version | X.Y.Z | match/mismatch (if detectable) |

### Step 3: Detect Issues

| Issue | Detection | Fix |
|-------|-----------|-----|
| **Missing tag for npm version** | npm has X.Y.Z but no `vX.Y.Z` tag | Find the release commit, create tag there |
| **Tag at wrong commit** | Local and remote tags point to different SHAs | Fetch tags, reconcile |
| **Version gap** | Tags skip versions (v3.3.0 → v3.3.2) | Check if intermediate version was published to npm |
| **package.json ahead of tags** | Version bumped manually without tag | For semantic-release: tags are authoritative, package.json is informational |
| **Orphaned tags** | Tag exists but no npm version | Usually ok for semantic-release (tag created before publish failed) |

### Step 4: Report

```markdown
## Tag Audit Report

**Package**: <package-name>
**Release type**: semantic-release | manual

### Alignment
| Source | Version | SHA | Status |
|--------|---------|-----|--------|
| package.json | ... | HEAD | ... |
| latest tag | ... | ... | ... |
| npm registry | ... | n/a | ... |

### Issues Found
- [ ] Issue 1: description + fix command
- [ ] Issue 2: description + fix command

### Recommended Actions
1. `git tag vX.Y.Z <sha>` — create missing tag
2. `git push origin vX.Y.Z` — push tag
3. etc.
```

### Step 5: Fix (with user approval)

For each issue found, present the fix command and wait for approval before executing.

**Critical rules:**
- NEVER force-delete a tag that has a published npm version without understanding the impact
- For semantic-release packages: tags drive version calculation. Missing/wrong tags cause cascading issues
- For manual npm packages: tag and package.json MUST match exactly
- For app deploys: tags mark deploy points — missing tags mean no rollback reference
- Always verify with `npm view` (packages) or deploy dashboard (apps) after fixing tags

## Common Scenarios

### E409 Conflict Recovery

```bash
# 1. Find what version npm has
npm view <package-name> version

# 2. Find the commit that published it (check previous Release workflow)
gh run list --limit 5 --workflow Release --json conclusion,headSha,status

# 3. Create tag at the correct commit
git tag v<npm-version> <sha>
git push origin v<npm-version>

# 4. Re-run release (will calculate next version correctly)
gh run rerun <workflow-id>
```

### Tag Gap Detection

```bash
# List all versions in order
git tag -l 'v*' | sort -V

# Compare with npm versions
npm view <package-name> versions --json
```
