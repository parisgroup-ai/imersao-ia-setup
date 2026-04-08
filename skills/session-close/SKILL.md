---
name: session-close
description: End-of-session cleanup that persists learnings, reviews work, closes tasks, and updates project memory. Use this skill at the end of any work session — when the user says "done", "terminei", "encerrar sessão", "session close", "wrap up", "finalizar", "fechar sessão", "vou parar", "that's it for today", or any indication they're finishing work. Also use when explicitly invoked as /session-close. This skill works on ANY project regardless of stack.
version: 1.1.0
author: Cleiton Paris
---

# Session Close

Structured end-of-session ritual that prevents knowledge loss by persisting everything
worth keeping before the conversation ends. Works on any project.

The goal: when the next session starts (possibly weeks later, possibly by a different
Claude instance), it should have full context of what happened, what was learned, and
what's left to do.

---

## Philosophy

Sessions are ephemeral — conversations get cleared, context gets lost. But the **work
product** of a session lives in three places:

1. **Git** — commits, diffs, branches (already persistent)
2. **Task system** — TaskNotes, issues, project boards (needs updating)
3. **Memory** — CLAUDE.md, auto-memory, session briefs (needs capturing)

This skill ensures #2 and #3 are up to date before the session ends.

---

## Session Journal (Continuous Memory)

Throughout the session, important information should be appended to
`.claude/session-journal.md` in the project root. This file acts as a scratch pad
that survives even if the user closes the terminal without running `/session-close`.

### What goes in the journal

Append a timestamped entry whenever:
- A significant decision is made
- A bug is found or fixed (with commit hash)
- A pattern or pitfall is discovered
- A task is completed or created
- An insight worth remembering emerges

### Format

```markdown
## Session [DATE]

- [HH:MM] Started: [goal]
- [HH:MM] Fixed BUG-XXXX: [description] (commit `abc1234`)
- [HH:MM] Learned: [insight]
- [HH:MM] Created TASK-YYYY: [description]
- [HH:MM] Decision: [what was decided and why]
```

This file is gitignored (it's working state, not deliverable). The `/session-close`
skill reads it and distributes the content to the right persistent locations.

---

## The Close Sequence

```
/session-close
     │
     ▼
┌─────────────────────┐
│ 1. Reconstruct      │  Read git log, session journal, task changes
│    Session           │  Build narrative of what happened
└──────────┬──────────┘
           │
     ▼
┌─────────────────────┐
│ 2. Review Work      │  Validate commits against quality standards
│    (/reviewer lite) │  Flag concerns, not block
└──────────┬──────────┘
           │
     ▼
┌─────────────────────┐
│ 3. Close Tasks &    │  Mark completed TaskNotes as done
│    Open Pending     │  TaskCreate for every pending/suggested item
└──────────┬──────────┘
           │
     ▼
┌─────────────────────┐
│ 4. Persist Memory   │  Update CLAUDE.md with learnings
│                     │  Update auto-memory topic files
│                     │  Write session brief for next session
└──────────┬──────────┘
           │
     ▼
┌─────────────────────┐
│ 5. Commit & Report  │  Auto-commit memory/task changes
│                     │  Print session summary
└─────────────────────┘
```

---

## Step 1: Reconstruct Session

Gather what happened this session automatically — no user input needed.

### Sources

```bash
# Commits this session (last few hours or since session-brief timestamp)
git log --since="8 hours ago" --oneline --no-merges

# Files changed (unstaged)
git status --short

# Session journal (if exists)
cat .claude/session-journal.md 2>/dev/null

# TaskNotes changed this session
git diff --name-only HEAD~10 -- docs/TaskNotes/ 2>/dev/null
```

### Detect project type

Check which systems exist in the project:
- `docs/TaskNotes/` → TaskNotes system available
- `CLAUDE.md` → CLAUDE.md management available
- `memory-bank/` → Memory bank available
- `.claude/session-brief.md` → Session was planned via /plan-today
- `~/.claude/projects/.../memory/MEMORY.md` → Auto-memory available

Adapt the close sequence to what's available — don't fail if a system doesn't exist.

### Build Session Narrative

Create a structured summary:

```markdown
## Session Summary

**Duration**: [estimated from git timestamps]
**Commits**: [count]
**Files changed**: [count]

### What was done
- [commit-based list of accomplishments]

### Decisions made
- [from session journal or conversation context]

### Bugs found/fixed
- [with IDs and commit hashes]

### Learnings
- [insights worth persisting]

### Open items
- [things started but not finished]
```

---

## Step 2: Review Work (Lite)

Run a lightweight review of the session's commits. This is NOT a full `/reviewer` —
it's a quick sanity check focused on:

1. **Commit hygiene**: Do commit messages follow conventions?
2. **Scope accuracy**: Do commits match their descriptions?
3. **Obvious issues**: Any debug code, console.logs, TODO comments left behind?
4. **Unstaged changes**: Are there changes that should have been committed?

Present a brief report. Don't block — just flag concerns.

If the project has a `/reviewer` skill, invoke it for structural changes.
For routine work, the lite review is sufficient.

---

## Step 3: Close Tasks & Open Pending

### 3a. Close completed tasks

#### TaskNotes projects

Scan `docs/TaskNotes/Tasks/` for tasks that were worked on this session:

1. **Completed tasks**: If all subtasks are `[x]` and work is verified, set `status: done`
   and `completed: [today's date]`
2. **In-progress tasks**: Leave as `status: in-progress`, ensure description reflects
   current state

#### GitHub Issues (if applicable)

If commits reference issue numbers (`#123`, `fixes #456`), note which issues
should be closed but don't close them automatically (that's the PR's job).

### 3b. Create tasks for pending items (MANDATORY)

This is critical — open items identified during the session MUST become real tasks,
not just notes in a brief. If items only live in the session brief, they get forgotten.

**Sources of pending items:**
- "Open items" from the session narrative (Step 1)
- Incomplete work flagged in the review (Step 2)
- TODOs mentioned in conversation but not acted on
- Suggested next steps that emerged during work
- Bugs discovered but not fixed
- Refactoring opportunities identified

**For each pending item, call `TaskCreate`:**

```
TaskCreate({
  description: "[clear, actionable description of what needs to be done]",
  status: "pending"
})
```

**Rules:**
- One task per actionable item — don't bundle unrelated things
- Description must be self-contained (readable without session context)
- Include relevant file paths, function names, or error messages
- If a task depends on another, note the dependency in the description
- Skip trivial items (typos, cosmetic nits) unless explicitly requested

**Additionally, for TaskNotes projects**, create a TaskNote file in `docs/TaskNotes/Tasks/`
for each item following the project's TaskNotes format.

**Report created tasks** — list all created tasks in the final session report (Step 5)
so the user can see exactly what was captured.

---

## Step 4: Persist Memory

This is the most important step — it's why the skill exists.

### 4a. Update CLAUDE.md

Invoke the `/claude-md-management:revise-claude-md` skill if available.
If not, manually check:

- Were new commands discovered? Add them.
- Were new gotchas found? Document them.
- Were conventions established? Record them.
- Were environment quirks hit? Note them.

Keep additions concise — one line per concept.

### 4b. Update Auto-Memory

Check if any `★ Insight` blocks were produced during the session.
Write them to the matching topic file per the project's memory rules.

For projects with `~/.claude/projects/.../memory/MEMORY.md`:
- Update existing topic files with new learnings
- Create new topic files if needed
- Keep MEMORY.md index updated

### 4c. Write Session Brief for Next Session

Create/update `.claude/session-brief.md` with context for the next session:

```markdown
# Session Brief — [DATE]

## Last Session Summary
[2-3 sentences about what was accomplished]

## Current State
- Branch: [branch name]
- Last commit: [hash + message]
- Pending changes: [unstaged files if any]

## Open Items (tasks created)
- [TASK-ID]: [description]
- [TASK-ID]: [description]

## Decisions Made (don't re-debate)
- [key decisions from this session with rationale]

## Suggested Next Steps
1. [highest priority — references TASK-ID if applicable]
2. [second priority]
3. [third priority]
```

---

## Step 5: Commit & Report

### Auto-commit memory changes

Stage and commit any changes to:
- `docs/TaskNotes/Tasks/*.md` (status updates)
- `CLAUDE.md` (if updated)
- `.claude/session-brief.md`
- `memory-bank/*.md` (if updated)
- Auto-memory files

Commit message: `chore(session): close session — [summary]`

### Final Report

Print a concise session report:

```markdown
## Session Closed

**Commits this session**: [N]
**Tasks completed**: [list]
**Tasks created**: [count + list with descriptions]
**Memory updated**: [which files]
**Next session**: [top priority from created tasks]

Session brief saved to `.claude/session-brief.md`
```

---

## Edge Cases

### No commits this session
Skip review step. Focus on memory persistence (the conversation itself
may have produced valuable context even without code changes).

### No TaskNotes system
Skip task closing. Still persist memory and write session brief.

### No CLAUDE.md
Skip CLAUDE.md update. Still write session brief and close tasks.

### Session journal doesn't exist
Reconstruct from git log and conversation context. The journal is
a nice-to-have, not a requirement.

### User closes without running /session-close
The session journal (if maintained during the session) preserves
key information. Next session's `/plan-today` or manual `/session-close`
can process the stale journal.

---

## Integration with /plan-today

These two skills form a session lifecycle:

```
/plan-today          → Start of session (reads session-brief, plans work)
     ↓
[work happens]       → Session journal accumulates (optional but recommended)
     ↓
/session-close       → End of session (persists learnings, writes brief)
     ↓
/plan-today          → Next session (reads the brief, continues from context)
```

The session brief is the handoff artifact between sessions.
