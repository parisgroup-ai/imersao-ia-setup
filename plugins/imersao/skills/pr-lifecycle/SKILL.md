---
name: pr-lifecycle
description: >-
  Full PR lifecycle management: list, analyze, validate, and merge pull
  requests. Auto-detects validation gates per package and integrates
  a code-review pass for code analysis. Use when: managing PRs, checking PR status,
  reviewing open PRs, merging PRs, triaging PRs, cleaning up stale PRs,
  validating PR readiness, or any PR maintenance task. Even if the user just
  says 'merge', 'PR status', 'open PRs', 'stale PRs', 'validate branch',
  'triage', or references a PR number — this skill applies.
version: 1.0.0
tags: [pr, merge, validation, maintenance, review, triage]
---

<!-- last-reviewed: 2026-05-17 -->

# PR Lifecycle

End-to-end PR management: **triage → analyze → validate → merge**.

This skill works from whatever package/repo directory you're in — `gh` commands resolve the repo automatically (single-repo or monorepo).

## Merge Strategy

**Always squash merge.** When a repo uses semantic-release on `main`, squash produces one clean conventional commit per PR. Feature branch WIP stays out of main. Rollback = revert one commit.

The squash commit message must follow conventional commits: `feat(scope): description`.

## Commands

Parse the user's intent to determine which command to run. If the user says "merge PR #42", run the full `merge` pipeline. If they say "what PRs are open", run `status`. If ambiguous, default to `status`.

---

### `status` — PR Dashboard

1. Detect repo: `gh repo view --json nameWithOwner -q .nameWithOwner`
2. List PRs:
   ```bash
   gh pr list --state open --json number,title,author,createdAt,updatedAt,labels,reviewDecision,statusCheckRollup,headRefName,isDraft
   ```
3. Present summary table:
   ```
   | #  | Title             | Author | Age | Reviews      | CI     | Draft |
   |----|-------------------|--------|-----|--------------|--------|-------|
   | 42 | feat(composites)… | user   | 3d  | APPROVED     | pass   | No    |
   | 38 | fix(theme):…      | user   | 7d  | CHANGES_REQ  | fail   | No    |
   ```
4. Flag issues:
   - **Stale**: no update > 7 days
   - **Blocked**: failing CI or changes requested
   - **Ready**: approved + CI passing → suggest merge

---

### `analyze <PR#>` — Deep Analysis

Understand what a PR does and whether it's safe.

1. Fetch PR metadata: `gh pr view <PR#> --json title,body,author,state,reviewDecision,statusCheckRollup,mergeable,baseRefName,headRefName,additions,deletions,changedFiles`
2. Fetch diff stats: `gh pr diff <PR#> --stat`
3. Identify affected package(s) from file paths
4. **Do a thorough code-review pass** on the PR for code analysis
5. Summarize:
   - Scope: files changed, lines +/-
   - Package(s) affected
   - Review verdict
   - Approval status
   - CI status

**After the review, decide next step:**

| Verdict             | Action                                                |
|---------------------|-------------------------------------------------------|
| CLEAN               | Proceed to validate                                   |
| NEEDS_ATTENTION     | Show findings, ask user to confirm before proceeding  |
| SIGNIFICANT_ISSUES  | Show findings, recommend fixing first                 |
| BLOCK               | Stop. List blocking issues. Do not proceed.           |

---

### `validate <PR#|branch>` — Run Quality Gates

Auto-detect and run validation gates based on what changed.

#### Step 1: Identify package

| Path contains        | Package            |
|----------------------|--------------------|
| `apps/web/`          | web app            |
| `packages/ui/`       | ui library         |
| `packages/api/`      | api                |

If running from within a package directory, use that package. Otherwise detect from changed files.

#### Step 2: Base gates (all packages)

These always run:
```bash
pnpm type-check
pnpm test
pnpm build
```

#### Step 3: Conditional gates (when the repo defines them)

Analyze changed files and enable gates accordingly:

| Trigger                                          | Gate             | Command                   |
|--------------------------------------------------|------------------|---------------------------|
| Security-sensitive change                        | Security lint    | `pnpm lint:security`      |
| Always                                           | Coverage         | `pnpm test:coverage:ci`   |
| Files in `src/theme/` changed                    | Theme contract   | `pnpm test:theme-contract`|
| `CHANGELOG.md` changed                           | Changelog        | `pnpm changelog:validate` |
| New exports, new deps, or significant additions  | Bundle perf      | `pnpm perf:check`         |
| `server.ts`/`client.ts` or RSC splits changed    | RSC check        | `pnpm rsc:check`          |

#### Step 4: Run and report

Run base gates first (in parallel where possible), then conditional gates. Report:

```
## Validation — PR #42

| Gate               | Status | Duration |
|--------------------|--------|----------|
| type-check         | PASS   | 12s      |
| test:coverage:ci   | PASS   | 45s      |
| lint:security      | PASS   | 8s       |
| build              | PASS   | 22s      |
| test:theme-contract| SKIP   | —        |
| perf:check         | FAIL   | 30s      |

Verdict: NOT READY — perf:check failed
```

If a gate command doesn't exist in the package (e.g., `lint:security` in domain-ordo), skip it and note the skip.

---

### `merge <PR#>` — Full Pipeline

The main command. Runs the complete pipeline:

1. **Analyze** — run `analyze` phase
2. **Gate check** — if the review verdict is BLOCK, stop
3. **Validate** — run `validate` phase
4. **Pre-merge checks**:
   - All gates pass
   - PR has at least 1 approval (or user explicitly overrides)
   - No merge conflicts
   - Branch is up-to-date with base
5. **If branch is behind base**: offer to update
   ```bash
   gh pr update-branch <PR#>
   ```
6. **Confirm with user**: "PR #42 passed all gates. Squash-merge into `main`?"
7. **On confirmation**:
   ```bash
   gh pr merge <PR#> --squash --delete-branch
   ```
8. Verify merge succeeded and report

---

### `triage` — Batch Review

Review all open PRs and prioritize.

1. Run `status` to fetch all PRs
2. Categorize:
   - **Ready to merge**: approved + CI passing
   - **Needs review**: no reviews yet
   - **Blocked**: failing CI or changes requested
   - **Stale**: no updates > 7 days
   - **Draft**: still in progress
3. For each category, recommend specific actions:
   - "PR #42 is ready — run merge"
   - "PR #38 has failing CI — investigate"
   - "PR #35 is stale (14d) — close or update"

---

## Safety Rules

- **Never force-merge** without explicit user confirmation
- **Never merge** PRs with BLOCK verdict from the code review
- **Never skip** failing validation gates silently — if the user wants to override, log the reason
- **Never auto-resolve** merge conflicts — report conflicting files and suggest approach
- **Always show** what will happen before executing the merge
- **Always confirm** before the final `gh pr merge` command

## Error Handling

| Error                    | Action                                        |
|--------------------------|-----------------------------------------------|
| `gh` not authenticated   | Tell user to run `gh auth login`              |
| PR not found             | Verify PR number and repo                     |
| Gate command missing      | Skip gate, warn (some gates are package-specific) |
| Merge conflicts          | Report files, suggest resolution, stop        |
| No approvals             | Warn user, allow explicit override            |

## Integration Map

```
reviewer (pre-implementation)
    │
    ▼ (ADR/PR template feeds into)
pr-lifecycle (post-implementation)
    │
    ├── code review (code analysis)
    │
    ▼ (after merge, semantic-release on main)
project-release (manual release if needed)
```
