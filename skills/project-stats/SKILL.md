---
name: project-stats
description: Generate a comprehensive project statistics report with language breakdown, git activity, test coverage, dependencies, and infrastructure detection. Automatically compares with the previous report to show growth trends and deltas. Use this skill whenever the user asks for project statistics, project report, project health, codebase overview, how big is the project, project summary, project metrics, project status report, repo stats, repo report, monorepo stats, lines of code, LOC count, code metrics, health check report — even if they just say "stats", "relatorio", "relatório do projeto", "estatísticas", "como está o projeto", "tamanho do projeto", or "project overview". This skill works on ANY git project regardless of language or framework.
---

# Project Stats Report

Generate a comprehensive, comparable project statistics report. Works on any git project.

## How It Works

1. Run the bundled collection script to gather raw data
2. Save the JSON report to `.claude/reports/`
3. Find the most recent previous report (if any)
4. Compare and present a formatted markdown report with trend indicators

## Step 1: Collect Statistics

Run the bundled collection script from the project root:

```bash
bash <skill-path>/scripts/collect-stats.sh
```

Capture the JSON output. The script auto-detects:
- **Languages**: TypeScript, JavaScript, Python, Go, Rust, PHP, Java, Swift, Kotlin, CSS
- **Monorepo**: Turborepo, Lerna, Nx, pnpm workspaces
- **Frameworks**: Next.js, Vite, Nuxt, Angular, SvelteKit, Astro, Expo, FastAPI, Django, Rails
- **Tests**: `.spec.*`, `.test.*`, `test_*.py`, E2E files
- **Git**: commits, contributors, branches, tags, velocity, conventional commit types, AI collab ratio
- **Dependencies**: npm, pip, go modules
- **Quality**: TODOs, FIXMEs
- **i18n**: keys, locales

## Step 2: Save the Report

Save the JSON output to `.claude/reports/project-stats-YYYY-MM-DD.json` in the project root. Create the directory if it doesn't exist.

If a report for today already exists, overwrite it (same-day re-runs update rather than duplicate).

## Step 3: Find Previous Report

Look in `.claude/reports/` for the most recent `project-stats-*.json` file that is NOT today's report. Read it for comparison.

If the project has a custom metrics script (like `pnpm dev:metrics --save` or similar), also check those output directories for additional historical data.

## Step 4: Format the Report

Present the report in this structure. The comparison column only appears when a previous report exists.

### Report Template

```markdown
# 📊 Project Statistics Report

**Project:** {name}
**Date:** {date}
**Previous report:** {previous_date or "First report"}

---

## Overview

| Metric | Current | Previous | Delta |
|--------|---------|----------|-------|
| Source files | X | Y | ↑ +Z (+N%) |
| Lines of code | X | Y | ↓ -Z (-N%) |
| Test files | X | Y | → 0 |
| Git commits (total) | X | Y | ↑ +Z |
| Contributors | X | | |

## Language Breakdown

| Language | Files | LOC | % of Total |
|----------|-------|-----|------------|
| TypeScript | X | Y | Z% |
| ... | | | |

## Git Activity

| Metric | Value |
|--------|-------|
| Commits today | X |
| Commits this week | X |
| Commits this month | X |
| Branches | X |
| Tags | X |
| Dirty files | X |
| Unpushed commits | X |

### Commit Types (Last 30 days)

| Type | Count | Bar |
|------|-------|-----|
| feat | X | ████████ |
| fix | X | ██████ |
| ... | | |

### AI Collaboration

| Metric | Value |
|--------|-------|
| AI-assisted commits (30d) | X |
| AI collab ratio | X% |

## Weekly Velocity

| Metric | Current | Previous | Delta |
|--------|---------|----------|-------|
| Lines added | X | Y | |
| Lines removed | X | Y | |
| Net lines | X | Y | |

## Testing

| Metric | Current | Previous | Delta |
|--------|---------|----------|-------|
| Unit test files | X | Y | |
| E2E test files | X | Y | |
| Total test files | X | Y | |

## Dependencies

| Source | Production | Dev |
|--------|-----------|-----|
| npm | X | Y |
| Python | X | |
| Go | X | |

## Infrastructure

| Property | Value |
|----------|-------|
| Monorepo | Yes/No |
| Tool | Turborepo / Lerna / etc |
| Workspaces | X |
| Frameworks | Next.js, FastAPI, etc |
| Dockerfiles | X |
| Docker Compose | Yes/No |

## Code Quality

| Metric | Current | Previous | Delta |
|--------|---------|----------|-------|
| TODOs | X | Y | |
| FIXMEs/HACKs | X | Y | |

## i18n (if applicable)

| Metric | Value |
|--------|-------|
| Translation keys | X |
| Locales | pt-BR, en-US, ... |
```

### Formatting Rules

**Delta indicators:**
- `↑ +N (+X%)` — increase (green, generally good for code/tests, bad for TODOs)
- `↓ -N (-X%)` — decrease
- `→ 0` — no change
- Empty if no previous report

**Percentage calculation:** `((current - previous) / previous * 100).toFixed(1)`

**Bar charts for commit types:** Use `█` blocks proportional to count. Max bar = 20 chars for the highest value.

**Zero-value languages:** Omit languages with 0 files from the table. Only show languages that actually exist in the project.

**Monorepo extras:** If monorepo detected, add a "Workspaces" subsection listing apps and packages.

### Interpretation Notes

After the tables, add a brief "Key Observations" section with 3-5 bullet points about notable trends. For example:
- "Codebase grew by X% since last report — mainly in TypeScript (+Y files)"
- "Test coverage ratio improved: X test files per 100 source files (was Y)"
- "Fix-to-feat ratio is Z:1 — indicating active stabilization"
- "N new dependencies added since last report"
- "AI collaboration ratio: X% of commits in the last 30 days"

## Post-Report

After presenting the report, offer:
1. "Save this report to `docs/reports/` as a markdown file?"
2. "Run deeper analysis on any specific area?" (e.g., coverage, hotspots, complexity)

## Edge Cases

- **First run:** No comparison column. State "This is the first report — future runs will show trends."
- **Same-day re-run:** Overwrite today's JSON. Compare with the most recent non-today report.
- **Non-git project:** Skip git section entirely. Still collect file/LOC stats.
- **Empty project:** Show zeros. Don't error out.
- **Monorepo with project-specific metrics:** If `pnpm dev:metrics` or similar exists, mention it: "This project also has a custom metrics script at `pnpm dev:metrics`."
