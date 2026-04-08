---
name: team-reviewer
description: Use when reviewing a PR or local diff with a parallel team of specialized review agents.
---

# Team Reviewer

Scatter-gather code review team. Spawns specialized review agents in parallel, aggregates findings, and outputs a scored report.

## Usage

```bash
/team-reviewer                    # Auto-detect (PR or local diff), deep mode
/team-reviewer --quick            # Auto-detect, quick mode (3 agents)
/team-reviewer 142                # Review PR #142, deep mode
/team-reviewer 142 --quick        # Review PR #142, quick mode
```

## Parse Arguments

Extract from: `{{ARGUMENTS}}`

```
PR_NUMBER = first numeric argument (e.g., 142) or empty
QUICK_MODE = true if --quick flag present
```

If no arguments: auto-detect scope, deep mode.

---

## Phase 1: DETECT Scope

Determine what code to review. Run these commands:

```bash
# 1. If PR_NUMBER provided:
gh pr diff {PR_NUMBER} --name-only    # files list
gh pr diff {PR_NUMBER}                 # full diff
gh pr view {PR_NUMBER} --json title,body,commits  # PR metadata

# 2. If NO PR_NUMBER, check if branch has a PR:
gh pr list --head $(git branch --show-current) --json number,title --limit 1

# 2a. If PR found → use that PR number, run commands from step 1
# 2b. If NO PR found → local diff:
git diff HEAD --name-only              # files list
git diff HEAD                          # full diff (staged + unstaged)
git log --oneline -10                  # recent commits for context
```

Store:
- `DIFF` — the full diff content
- `FILES` — list of changed files
- `SCOPE_LABEL` — "PR #N (title)" or "Local diff (branch-name)"
- `STATS` — file count, lines added/removed

If diff is empty, report "No changes to review" and stop.

---

## Phase 2: SCATTER (Spawn Agents)

### Agent Selection

```
If QUICK_MODE:
  agents = [code-quality, security, silent-failure]          # 3 agents
Else:
  agents = [code-quality, security, silent-failure,
            type-design, test-coverage, commit-hygiene]      # 6 agents
```

### Create Team and Spawn

1. **TeamCreate** with name `team-reviewer`
2. **TaskCreate** one task per agent
3. **Spawn ALL agents in parallel** using Task tool with:
   - `team_name: "team-reviewer"`
   - `subagent_type: "team-reviewer-{agent-name}"`
   - `run_in_background: true`
   - `model: "sonnet"` (cost-efficient for review tasks)

### Agent Prompt Template

Each agent receives this prompt:

```markdown
## Review Scope

{SCOPE_LABEL}

## Changed Files

{FILES}

## Diff

{DIFF}

## Instructions

Review the code changes above according to your specialization.

For EACH finding, output exactly this format (one per line):

[SEVERITY] path/to/file.ts:LINE — Description of the issue

Severity levels: CRITICAL, HIGH, MEDIUM, LOW

After all findings, output a single line:

DIMENSION_SCORE: N/10

Where N is your assessment (0=terrible, 10=perfect).

If you find NO issues, output:

NO_FINDINGS
DIMENSION_SCORE: 10/10

## Project Rules (apply to all dimensions)

- Use structured logging instead of `console.log`
- Use semantic design tokens not hardcoded colors
- Use shared UI composites when available
- Never put mutation hooks in useEffect dependency arrays
- Validate at system boundaries with Zod schemas
```

---

## Phase 3: GATHER and SCORE

### Wait for All Agents

Use TaskOutput to collect results from each background agent. Wait for all to complete.

### Parse Findings

For each agent output:
1. Extract lines matching `[SEVERITY] path:line — description`
2. Extract `DIMENSION_SCORE: N/10`
3. If parsing fails, score dimension as 5/10 and note "agent output unparseable"

### Compute Final Score

```
Weights:
  security:       1.5
  code-quality:   1.2
  silent-failure: 1.0
  type-design:    1.0
  test-coverage:  1.0
  commit-hygiene: 1.0

final_score = sum(dimension_score × weight) / sum(weights)
```

### Determine Verdict

```
9-10  → CLEAN
7-8.9 → NEEDS_ATTENTION
5-6.9 → SIGNIFICANT_ISSUES
< 5   → BLOCK
```

---

## Phase 4: FORMAT Report

Output this report:

```
═══════════════════════════════════════════════════════════
  TEAM REVIEW: {final_score}/10 [{verdict}]
  Scope: {SCOPE_LABEL} ({file_count} files, +{added} -{removed})
  Mode: {deep|quick} ({agent_count} agents)
═══════════════════════════════════════════════════════════

  Dimension Scores:
  {for each dimension: name score_bar score}

  Findings: {CRITICAL_count} CRITICAL · {HIGH_count} HIGH · {MEDIUM_count} MEDIUM · {LOW_count} LOW

  Top Findings (sorted by severity):
  {numbered list of top 10 findings across all dimensions}

  Full Details:
  {for each dimension with findings:}
  ── {dimension} ({score}/10) ──────────────────────
    {count} findings ({severity breakdown})
    {list all findings for this dimension}

═══════════════════════════════════════════════════════════
```

For the score bar, use: `█` for filled, `░` for empty, 10 chars total.

---

## Phase 5: CLEANUP

1. **TeamDelete** to remove team resources
2. Report is complete — no further action needed

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Empty diff | Report "No changes to review" and stop |
| gh CLI not authenticated | Report error, suggest `gh auth login` |
| Agent times out | Score dimension as 5/10, note "timed out" |
| Agent output unparseable | Score dimension as 5/10, include raw output in details |
| PR not found | Fall back to local diff |

---

## What This Skill Does NOT Do

- Does NOT edit code or apply fixes
- Does NOT commit, push, or create PRs
- Does NOT run tests or linters (that's quality-gate)
- Does NOT block — only reports and recommends
