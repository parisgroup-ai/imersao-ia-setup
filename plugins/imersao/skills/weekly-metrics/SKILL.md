---
name: weekly-metrics
description: >
  Generate a weekly productivity metrics report for solo AI-assisted development.
  Analyzes git commits, TaskNotes, and collaboration patterns from the last 7 days,
  then proposes workflow optimizations. Use this skill whenever the user asks for a
  weekly report, productivity metrics, sprint retrospective, workflow analysis,
  development velocity, or wants to understand how their week went — even if they
  just say "how was my week" or "show me my metrics". Also trigger when the user
  mentions optimizing their dev workflow with AI or wants a retrospective.
version: 1.0.0
author: gustavo
tags: [metrics, productivity, reporting, workflow]
---

# Weekly Productivity Metrics

Generate a comprehensive weekly report analyzing development activity, task throughput,
and AI collaboration patterns — with actionable workflow optimization proposals.

## Data Collection

Run all git commands and task CLI commands from the project root. Collect data in parallel
where possible (git stats + task stats are independent).

### 1. Git Commit Analytics

```bash
# Total commits (last 7 days)
git log --oneline --since="7 days ago" | wc -l

# Commits with full metadata (hash, author, date, subject)
git log --format="%H|%an|%ai|%s" --since="7 days ago"

# Lines changed (insertions/deletions)
git diff --stat $(git log --since="7 days ago" --reverse --format="%H" | head -1)^..HEAD 2>/dev/null || git diff --stat --shortstat HEAD~50..HEAD

# Per-commit stats (files, insertions, deletions)
git log --since="7 days ago" --format="%H|%s" --numstat

# Files touched (unique)
git log --since="7 days ago" --name-only --format="" | sort -u | wc -l

# Commits by hour (for peak hours analysis)
git log --since="7 days ago" --format="%ai" | cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c | sort -rn

# Commits by day of week
git log --since="7 days ago" --format="%ad" --date=format:"%A" | sort | uniq -c | sort -rn

# Commits by conventional-commit type
git log --since="7 days ago" --format="%s" | grep -oE "^[a-z]+\(" | tr -d '(' | sort | uniq -c | sort -rn

# Commits by scope
git log --since="7 days ago" --format="%s" | grep -oE "\([^)]+\)" | tr -d '()' | sort | uniq -c | sort -rn

# AI co-authored commits (Claude collaboration indicator)
git log --since="7 days ago" --format="%H %s%n%b" | grep -c "Co-Authored-By.*Claude\|Co-Authored-By.*claude\|Co-authored-by.*Claude"
```

### 2. TaskNotes Analytics

```bash
# Sprint summary
pnpm task:sprint 2>/dev/null

# Full sprint task list (JSON for parsing)
pnpm task:list --sprint -f json 2>/dev/null

# All tasks (including non-sprint)
pnpm task:list -f json -a 2>/dev/null

# Time tracking for the week
pnpm task:time --week 2>/dev/null
```

From the task JSON, extract:
- **Done this week**: tasks where `status: done` and `completed` date is within last 7 days
- **In progress**: tasks where `status: in-progress`
- **Blocked**: tasks with non-empty `blockedBy` that are still open
- **Created this week**: tasks where filename date or `scheduled` is within last 7 days
- **Cycle time**: for done tasks, diff between `scheduled` (or creation date) and `completed`
- **Time invested**: sum of `timeSpent` from `timeEntries` dated this week
- **Pomodoros**: sum of `pomodoros` across active tasks

### 3. Codebase Impact

```bash
# Most changed directories (top 10)
git log --since="7 days ago" --name-only --format="" | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -10

# Largest commits (by lines changed)
git log --since="7 days ago" --format="%H %s" --shortstat | paste - - - | sort -t',' -k2 -rn | head -5
```

## Metric Calculations

Compute these from the raw data:

| Metric | Formula |
|--------|---------|
| Commits/day | total_commits / 7 |
| Lines/day | (insertions + deletions) / 7 |
| Task throughput | tasks_done / 7 |
| Completion rate | tasks_done / (tasks_done + tasks_in_progress + tasks_open) |
| Avg cycle time | mean(completed - scheduled) for done tasks |
| AI collab ratio | co_authored_commits / total_commits |
| Focus score | 1 - (unique_scopes / total_commits) — higher = more focused |
| Commit size avg | total_lines_changed / total_commits |

## Pattern Analysis

Look for these patterns and call them out:

**Productivity patterns:**
- Peak hours (top 3 hours by commit count)
- Most productive day of the week
- Burst vs steady pace (are commits clustered or evenly distributed?)

**Code patterns:**
- Hot spots (directories with >20% of changes)
- Scope concentration (which areas got the most attention)
- Commit type distribution (feat vs fix vs refactor vs test vs chore)

**Bottlenecks:**
- Tasks blocked for >3 days
- Tasks in-progress with no commits in that scope
- Scopes with high fix-to-feat ratio (instability signal)

**AI collaboration:**
- % of commits co-authored with Claude
- Which scopes used AI most
- Commit size difference: AI-assisted vs solo

## Report Template

Output the report in this exact structure:

```markdown
# Weekly Productivity Report

**Period:** [YYYY-MM-DD] to [YYYY-MM-DD]
**Author:** [git author name]
**Project:** [repo name from git remote or directory]

---

## Executive Summary

> [2-3 sentence overview: what was the main focus, what was achieved,
> overall velocity trend compared to the numbers]

| Metric | Value | Trend |
|--------|-------|-------|
| Commits | XX | [chart: daily breakdown as bar] |
| Lines changed | +XXX / -XXX | |
| Files touched | XX | |
| Tasks completed | XX/YY | |
| Avg cycle time | X.X days | |
| AI collab ratio | XX% | |
| Focus score | X.X/1.0 | |

---

## Commit Analytics

### Daily Distribution
[Table or inline bar chart showing commits per day]

### Peak Hours
[Top 3 productive hours with commit counts]

### By Type
[feat/fix/refactor/test/chore breakdown with counts and %]

### By Scope
[Top scopes with commit counts — identifies focus areas]

### Largest Commits
[Top 3-5 commits by lines changed — identifies major deliverables]

---

## Task Metrics

### Sprint Progress
[Progress bar visualization]
- Done: X tasks
- In Progress: X tasks
- Pending: X tasks
- Blocked: X tasks

### Completed This Week
[List of done tasks with cycle time for each]

### Blocked Tasks
[List with reason and days blocked — only if any exist]

### Time Investment
[Total hours logged, pomodoros completed, avg time per task]

---

## Productivity Patterns

### Strengths
[2-3 positive patterns observed — e.g., consistent daily output,
good test coverage ratio, fast cycle times]

### Bottlenecks
[2-3 areas of concern — e.g., too many context switches, blocked tasks,
fix-heavy scope indicating instability]

### Rhythm Analysis
[Burst vs steady, morning vs evening, weekday concentration]

---

## AI Collaboration Efficiency

### Overview
- Total AI-assisted commits: XX (YY% of total)
- AI-assisted scopes: [list]
- Avg commit size (AI): XX lines vs (solo): XX lines

### Effectiveness Assessment
[Analysis of where AI helped most — which types of tasks, which scopes,
whether AI-heavy days had higher output]

### Collaboration Quality
[Are AI commits well-scoped? Are they feat-heavy or fix-heavy?
This reveals whether AI is helping build or helping repair]

---

## Workflow Optimization Proposals

Based on this week's data, here are specific adjustments:

### 1. [Proposal Title]
**Problem:** [What the data shows]
**Proposal:** [Specific actionable change]
**Expected impact:** [What should improve]

### 2. [Proposal Title]
**Problem:** [What the data shows]
**Proposal:** [Specific actionable change]
**Expected impact:** [What should improve]

### 3. [Proposal Title]
**Problem:** [What the data shows]
**Proposal:** [Specific actionable change]
**Expected impact:** [What should improve]

---

## Action Items for Next Week

- [ ] [Specific, actionable item derived from the analysis]
- [ ] [Another item]
- [ ] [Another item]
- [ ] [Process improvement to try]
- [ ] [Skill or tool to experiment with]

---

*Generated by weekly-metrics skill — [timestamp]*
```

## Optimization Proposals — What to Look For

These are the types of workflow optimizations to propose based on data patterns.
Choose the 3-5 most relevant based on what the data actually shows:

**If focus score < 0.5 (too many scope switches):**
- Propose batching related work — group tasks by scope/domain before starting
- Suggest theme days (e.g., Monday = API, Tuesday = frontend)

**If peak hours are outside normal working hours:**
- Propose aligning high-complexity tasks with peak hours
- Suggest using off-peak hours for reviews and planning

**If AI collab ratio < 30%:**
- Propose using AI more for boilerplate, tests, and repetitive patterns
- Suggest pairing with AI on the scope that had most fixes

**If AI collab ratio > 80%:**
- Propose allocating solo deep-work blocks for architecture decisions
- AI is great for execution but solo thinking time matters for direction

**If fix-to-feat ratio > 0.5 in any scope:**
- That scope is unstable — propose a stabilization sprint
- Suggest adding test coverage before new features

**If avg cycle time > 5 days:**
- Tasks are too large — propose breaking into smaller deliverables
- Suggest WIP limits (max 3 in-progress tasks)

**If blocked tasks > 2:**
- Propose a "blocker-busting" session at start of week
- Identify if blockers are external (waiting on others) or internal (dependencies)

**If commit size avg > 200 lines:**
- Commits are too large — propose atomic commits
- Large commits = harder reviews and more merge conflicts

**If no tests in the week (test type = 0):**
- Propose TDD blocks — even 2 test commits/week improves confidence
- Suggest AI-assisted test generation for completed features

**If time tracking is sparse (< 3 entries/week):**
- Propose using pomodoro timer (`pnpm task:pomo`) for focus blocks
- Time data enables better estimation in future sprints

## Output Location

Save the report to: `docs/reports/weekly-metrics-[YYYY-MM-DD].md`

Create the `docs/reports/` directory if it doesn't exist.

Also display the full report in the conversation so the user can read it immediately.

## Notes

- All git commands use `--since="7 days ago"` for consistency
- If the repo has fewer than 7 days of history, adjust the period and note it
- If `pnpm task:*` commands fail, skip TaskNotes sections and note the limitation
- The report language should match the user's language (detect from conversation)
- Proposals must be data-driven — every proposal must reference a specific metric
- Keep the tone analytical but encouraging — celebrate wins, be constructive about improvements
