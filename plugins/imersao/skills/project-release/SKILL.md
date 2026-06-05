---
name: project-release
description: Use when releasing or deploying a project, creating versions or tags, or preparing a production publish flow.
---

# Project Release

Release workflow for monorepo projects that deploy via push-to-main (Railway, Vercel, Render, Fly.io, etc). Handles quality gates, version bump, changelog generation, git tagging, and push.

Unlike `/release-maintenance` (which publishes npm packages to a registry), this skill deploys **apps** — web frontends, API servers, background workers, mobile OTA updates.

## Usage

```bash
/project-release                     # Full release (auto-detect changes)
/project-release patch               # Force patch bump
/project-release minor               # Force minor bump
/project-release major               # Force major bump (requires confirmation)
/project-release --dry-run           # Show what would happen without executing
/project-release --hotfix "desc"     # Minimal release: skip changelog, fast-track
```

## Parse Arguments

Extract from: `{{ARGUMENTS}}`

```
If ARGS is empty            → MODE = auto (detect bump from commits)
If ARGS is patch|minor|major → MODE = forced bump
If ARGS has --dry-run       → MODE = dry-run
If ARGS has --hotfix        → MODE = hotfix
```

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  1. PRE-FLIGHT          Gather state, detect changes            │
│  2. QUALITY GATES       type-check, lint, tests                 │
│  3. VERSION BUMP        Determine + apply new version           │
│  4. CHANGELOG           Generate from conventional commits      │
│  5. COMMIT + TAG        Atomic release commit with tag          │
│  6. PUSH                Triggers deployment automatically       │
│  7. VERIFY              Monitor deployment health               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step 1: PRE-FLIGHT — Gather State

Run these in parallel to build a complete picture:

```bash
# Current version
cat package.json | grep '"version"'

# Last release tag
git tag -l 'v*' --sort=-version:refname | head -1

# Commits since last tag (or all if no tags)
git log $(git tag -l 'v*' --sort=-version:refname | head -1)..HEAD --oneline 2>/dev/null \
  || git log --oneline -30

# Working tree status
git status --short

# Branch check
git branch --show-current
```

### Pre-flight checks

| Check | Action |
|-------|--------|
| Dirty working tree | STOP — commit or stash changes first |
| Not on main/master | WARN — releases should come from main. Ask user to confirm |
| No commits since last tag | STOP — nothing to release |
| Unpushed commits exist | WARN — these will be included in the release |

### Detect apps with changes

Compare files changed since last tag against app directories:

```bash
# Files changed since last tag
git diff --name-only $(git tag -l 'v*' --sort=-version:refname | head -1)..HEAD 2>/dev/null
```

Map changed files to apps:
- `apps/web/**` → web app changed
- `apps/api/**` → API changed
- `apps/ana-service/**` → AI service changed
- `apps/mobile/**` → mobile changed
- `packages/**` → shared packages changed (affects all apps)

Show the user which apps have changes and will be deployed.

---

## Step 2: QUALITY GATES

Quality gates are the non-negotiable checkpoint. A release with broken types or lint errors can take down production.

### Auto-detect available gates

Check `package.json` scripts to determine what gates are available:

```bash
# Parse available scripts
node -e "const p=require('./package.json'); console.log(Object.keys(p.scripts||{}).join('\n'))"
```

### Run gates in parallel where possible

| Gate | Command (detect from scripts) | Blocking? |
|------|-------------------------------|-----------|
| Type-check | `pnpm type-check` or `pnpm tsc --noEmit` | YES — always blocks |
| Lint | `pnpm lint` | YES — always blocks |
| Tests | `pnpm test` | YES — blocks if tests exist |
| Build | `pnpm build` | Only if deployment needs pre-built artifacts |

```bash
# Run type-check and lint in parallel
pnpm type-check & pnpm lint & wait
```

**If any blocking gate fails:** STOP. Show the errors. Do NOT proceed with the release. The user must fix the issues first.

**Hotfix mode exception:** In `--hotfix` mode, only type-check is required. Lint warnings are allowed (not errors). Tests are skipped with a warning.

---

## Step 3: VERSION BUMP

### Determine bump type

**Auto mode** (no argument): Analyze commits since last tag using conventional commit prefixes.

```
feat:, feat!:          → minor (or major if breaking)
fix:, perf:            → patch
BREAKING CHANGE footer → major
chore:, docs:, test:   → patch (still triggers release for deployment)
```

Pick the highest bump level found. If only `chore:`/`docs:`/`test:` commits exist, default to `patch`.

**Forced mode** (explicit argument): Use the specified bump level.

**Major bump:** Always ask user to confirm before proceeding — major versions signal breaking changes.

### Apply the bump

```bash
# Read current version
CURRENT=$(node -e "console.log(require('./package.json').version)")

# Calculate new version (use node for semver math)
NEW=$(node -e "
  const [major, minor, patch] = '$CURRENT'.split('.').map(Number);
  const bump = '$BUMP_TYPE';
  if (bump === 'major') console.log(\`\${major+1}.0.0\`);
  else if (bump === 'minor') console.log(\`\${major}.\${minor+1}.0\`);
  else console.log(\`\${major}.\${minor}.\${patch+1}\`);
")
```

Update `package.json` version field using Edit tool (not sed — preserves formatting).

If workspace apps have their own `package.json` versions, update those too for consistency:
```bash
# Check if apps have independent versions
for app in apps/*/package.json; do
  grep '"version"' "$app" 2>/dev/null
done
```

---

## Step 4: CHANGELOG

Generate a changelog entry from conventional commits since the last tag. The changelog makes releases traceable — someone looking at `v1.5.0` can immediately see what shipped.

### Format: Keep a Changelog

```markdown
## [1.5.0] - 2026-03-02

### Added
- feat(mobile): implement sessions and session detail screens
- feat(mobile): implement challenges screen with join and progress tracking

### Fixed
- fix(variant-workshop): unique variant IDs prevent cross-batch mutation

### Changed
- refactor(api): split v3 router into sub-routers

### Other
- chore(deps): update dependencies
- test(mobile): add Maestro E2E flows
```

### Generate from git log

```bash
# Commits since last tag, grouped by type
git log $(git tag -l 'v*' --sort=-version:refname | head -1)..HEAD \
  --pretty=format:"%s" 2>/dev/null
```

Parse each commit message:
- `feat(...):`  → **Added**
- `fix(...):`   → **Fixed**
- `refactor(...):`/`perf(...):`  → **Changed**
- Everything else → **Other**

### Where to write

Check if `CHANGELOG.md` exists at repo root:
- **Exists:** Prepend new entry after the first `# Changelog` heading (or at top if no heading)
- **Doesn't exist:** Create it with a `# Changelog` heading + the first entry

### Hotfix mode

Skip changelog generation. Add a note in the commit message instead: `hotfix: <description>`.

---

## Step 5: COMMIT + TAG

Create a single atomic release commit containing the version bump + changelog.

```bash
# Stage changes
git add package.json CHANGELOG.md
# Also stage any app package.json files that were bumped
git add apps/*/package.json 2>/dev/null

# Commit — use chore(project) type, NOT "release:" (commitlint rejects non-standard types)
git commit -m "$(cat <<'EOF'
chore(project): bump version to v{NEW_VERSION} and add CHANGELOG

{CHANGELOG_SUMMARY — first 5 lines of the new entry}

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

# Tag
git tag v{NEW_VERSION}
```

**Tag format:** `v{VERSION}` (e.g., `v1.5.0`). Always prefix with `v` for consistency.

**Commit type:** Use `chore(project):` — NOT `release:`. Most commitlint configs only allow standard types (`feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`). Also ensure the scope is not empty if commitlint enforces `scope-empty`.

**Never amend** a previous release commit. Always create a new one.

---

## Step 6: PUSH

Push triggers automatic deployment for services connected to the main branch (Railway, Vercel, etc).

```bash
git push origin main --tags
```

**Before pushing:** Show the user exactly what will be pushed:
```
Release v1.5.0 ready to push:
  - 1 release commit (version bump + changelog)
  - 1 tag (v1.5.0)
  - 15 feature/fix commits since v1.4.0
  - Apps affected: web, api, ana-service

Push to main? This will trigger Railway deployment.
```

**Wait for user confirmation** before pushing. This is the point of no return.

---

## Step 7: VERIFY (Post-Push)

After push, help the user monitor deployment.

### Railway projects

```bash
# Check if Railway CLI is available
which railway 2>/dev/null

# If gh CLI available, check GitHub Actions
gh run list --limit 3 --json databaseId,status,conclusion,name,headSha
```

### Health checks

If the project has health check URLs (from `railway.toml` or known endpoints), offer to verify:

```bash
# Example health check
curl -s https://app.example.com/api/health | head -20
```

### Report

```
Release v1.5.0 deployed:
  - Commit: abc1234
  - Tag: v1.5.0
  - Push: ✓
  - CI: (check gh run list)
  - Apps: web, api, ana-service (Railway auto-deploy from main)
```

---

## Dry Run Mode

When `--dry-run` is passed, execute Steps 1-3 (pre-flight, quality gates check, version calculation) but don't modify any files. Show what would happen:

```
Dry Run: project-release
═══════════════════════════════════════════════════════

Current version: 1.4.0
Bump type: minor (detected from commits)
New version: 1.5.0

Commits since v1.4.0: 15
  feat: 8  |  fix: 3  |  chore: 4

Apps with changes:
  ✓ web (12 files)
  ✓ api (5 files)
  ✓ ana-service (3 files)
  - mobile (0 files)

Quality gates: type-check ✓ | lint ✓ | tests ✓

Would create:
  - Version bump: 1.4.0 → 1.5.0
  - CHANGELOG.md entry
  - Git tag: v1.5.0
  - Push to main (triggers Railway deploy)

Run without --dry-run to execute.
```

---

## First Release (No Existing Tags)

When no `v*` tags exist, this is the first release:

1. Use ALL commits on main for the changelog
2. Start at the version already in `package.json` (or `0.1.0` if it's `1.0.0` placeholder)
3. Ask user: "This is the first release. What version should this be?" with options:
   - `0.1.0` (pre-production, recommended for early projects)
   - `1.0.0` (production-ready)
   - Current version from package.json

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Dirty working tree | Ask user to commit or stash |
| Quality gate fails | Show errors, stop release |
| Tag already exists | Show existing tag, ask to bump further or delete old tag |
| Push rejected | Pull first, resolve conflicts, retry |
| No conventional commits | Default to patch bump with generic changelog |
| Major bump without confirmation | Always re-ask |

---

## Quick Reference

| What | Command |
|------|---------|
| Full release (auto) | `/project-release` |
| Specific bump | `/project-release minor` |
| Preview only | `/project-release --dry-run` |
| Emergency fix | `/project-release --hotfix "fix payment crash"` |
| Force major | `/project-release major` (asks confirmation) |
