---
name: maestro-fix-cycle
description: Use when Maestro mobile failures should be handled by an automated one-flow-at-a-time repair loop.
---

# maestro-fix-cycle - Flow-by-Flow Test-Fix Loop with Memory

Processes Maestro flows **one at a time**, maintaining state across sessions. Analyzes failures, fixes YAML flows or app code, and re-runs until all pass.

## Usage

```bash
/maestro-fix-cycle                    # Start/continue cycle
/maestro-fix-cycle auth               # Only auth flows
/maestro-fix-cycle student            # Only student flows
/maestro-fix-cycle continue           # Resume from last position
/maestro-fix-cycle reset              # Clear memory and start fresh
/maestro-fix-cycle status             # Show current progress
/maestro-fix-cycle studio             # Debug current flow in Maestro Studio
```

## Memory System

State persisted in `apps/mobile/.maestro-cycle/`:

```
.maestro-cycle/
├── state.json           # Current position, queued flows
├── history.jsonl        # All fixes applied (append-only)
├── learnings.md         # Patterns discovered (human-readable)
└── failures/            # Detailed failure logs per flow
    └── {flow-name}.json
```

### state.json

```json
{
  "version": "1.0",
  "started_at": "2026-03-01T18:00:00Z",
  "updated_at": "2026-03-01T18:45:00Z",
  "current_flow": "flows/auth/login.yaml",
  "current_iteration": 1,
  "queue": [
    "flows/auth/token-refresh.yaml",
    "flows/student/courses-pagination.yaml"
  ],
  "completed": [
    "flows/smoke/smoke.yaml"
  ],
  "failed_permanently": [],
  "total_fixes": 3,
  "session_id": "abc123"
}
```

### learnings.md

```markdown
# Maestro Fix Learnings

> Auto-updated by maestro-fix-cycle. Manual edits welcome.

## Known Patterns

### Pattern: text-mismatch
- **Symptoms:** tapOn/assertVisible fails — element not found by text
- **Cause:** Button/label text in app differs from flow YAML
- **Solution:** Update text in YAML, or migrate to testID
- **How to find correct text:** Check component source or use `maestro studio`

### Pattern: locale-mismatch
- **Symptoms:** English text assertion fails on pt-BR simulator
- **Cause:** Simulator locale differs from flow expectations
- **Solution:** Use testID selectors (locale-independent)
- **Files seen:** All flows using text-based selectors

### Pattern: animation-timing
- **Symptoms:** Step fails intermittently after navigation
- **Cause:** waitForAnimationToEnd resolves before render completes
- **Solution:** Add explicit assertVisible for target element after wait
```

---

## Cycle Flow (Flow-by-Flow)

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: LOAD STATE                                         │
├─────────────────────────────────────────────────────────────┤
│  1. Read .maestro-cycle/state.json                          │
│     → If exists: Resume from current_flow                   │
│     → If not: Initialize new cycle                          │
│                                                             │
│  2. Check learnings.md for known patterns                   │
│     → Apply known fixes preemptively if recognized          │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: BUILD QUEUE (if new cycle)                         │
├─────────────────────────────────────────────────────────────┤
│  1. Run: cd apps/mobile && maestro test .maestro/flows      │
│     → Collect all failing flows                             │
│                                                             │
│  2. Sort by priority:                                       │
│     1. smoke/smoke.yaml (always first)                     │
│     2. shared/*.yaml (sub-flows affect many)               │
│     3. auth/*.yaml (login needed by all)                   │
│     4. Remaining flows alphabetically                       │
│                                                             │
│  3. Save queue to state.json                                │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: PROCESS CURRENT FLOW                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  3a. RUN SINGLE FLOW                                   │ │
│  │      cd apps/mobile                                    │ │
│  │      maestro test .maestro/{flow} 2>&1 | tee output   │ │
│  │      → Save result to failures/{flow-name}.json       │ │
│  └────────────────────────────────────────────────────────┘ │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  3b. ANALYZE FAILURE                                   │ │
│  │      → Parse Maestro output for failing step           │ │
│  │      → Identify selector type (text vs testID)         │ │
│  │      → Grep app source for correct selector            │ │
│  │      → Check i18n files for locale issues              │ │
│  │      → Check learnings.md for known pattern            │ │
│  └────────────────────────────────────────────────────────┘ │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  3c. APPLY FIX                                         │ │
│  │      → If known pattern: auto-apply                    │ │
│  │      → If text-mismatch: update YAML selector          │ │
│  │      → If missing-testid: add testID to component      │ │
│  │      → If app-bug: fix app code (NOT the flow)         │ │
│  │      → Record in history.jsonl                         │ │
│  └────────────────────────────────────────────────────────┘ │
│           │                                                 │
│           ▼                                                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  3d. VERIFY FIX                                        │ │
│  │      maestro test .maestro/{flow}                      │ │
│  │      → If PASS: Move to completed, next flow           │ │
│  │      → If FAIL: Increment iteration, retry (max 3)     │ │
│  │      → If MAX: Move to failed_permanently, next flow   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: UPDATE MEMORY                                      │
├─────────────────────────────────────────────────────────────┤
│  1. Update state.json with new position                     │
│  2. Append fix to history.jsonl                             │
│  3. If new pattern discovered → add to learnings.md         │
│  4. Save failure details to failures/{flow}.json            │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: CONTINUE OR COMPLETE                               │
├─────────────────────────────────────────────────────────────┤
│  If queue not empty:                                        │
│    → Pop next flow, go to STEP 3                           │
│                                                             │
│  If queue empty:                                            │
│    → Run full verification (all flows)                      │
│    → Generate summary report                                │
│    → Commit all fixes                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Fix Decision Tree

Understanding what to fix is critical. Maestro flows are YAML descriptions of expected app behavior. When a flow fails:

### Fix the Flow YAML when:
- **Text changed in app** — button renamed, label updated
- **Navigation structure changed** — tabs reordered, screen renamed
- **testID changed** — component refactored with new testID
- **Sub-flow path wrong** — runFlow reference to wrong file

### Fix the App Code when:
- **Missing testID** — component needs `testID` prop added
- **Bug in app** — feature doesn't work as expected
- **i18n key missing** — translation not available

### Fix the Shared Sub-flow when:
- **Login flow broken** — affects ALL flows that use `shared/login.yaml`
- **Tab navigation broken** — affects ALL flows using `shared/navigate-to-tab.yaml`
- **Logout broken** — affects flows that end with logout

Priority: **Fix shared sub-flows FIRST** because they cascade to all dependent flows.

---

## Commands

### /maestro-fix-cycle (default)

Start new cycle or continue existing one.

### /maestro-fix-cycle continue

Explicitly continue from last position.

### /maestro-fix-cycle reset

```
1. Archive .maestro-cycle/ to .maestro-cycle-archive/{timestamp}/
2. Keep learnings.md (valuable knowledge)
3. Create fresh state.json
4. Build new queue
```

### /maestro-fix-cycle status

```
═══════════════════════════════════════════════════════════
  MAESTRO FIX CYCLE - Status
═══════════════════════════════════════════════════════════

  Session: abc123 (started 30min ago)

  Progress: ████████░░░░░░░░ 8/16 flows (50%)

  Current: flows/student/course-detail.yaml
           Iteration 1/3, analyzing missing-element

  Completed (8):
    ✅ flows/smoke/smoke.yaml
    ✅ flows/auth/login.yaml
    ... (6 more)

  Queue (7):
    ⏳ flows/student/study-lesson.yaml
    ⏳ flows/student/progress.yaml
    ... (5 more)

  Failed Permanently (1):
    ❌ flows/ai/study-chat-interaction.yaml (needs API running)

  Fixes Applied: 10
  Patterns Learned: 3

═══════════════════════════════════════════════════════════
```

### /maestro-fix-cycle studio

Open Maestro Studio to visually debug the current failing flow:

```bash
cd apps/mobile && maestro studio
```

In Studio:
1. See simulator screen in real-time
2. Click elements to discover correct selectors
3. Test individual YAML steps interactively
4. View accessibility hierarchy (testIDs, labels, text)

---

## Memory Details

### history.jsonl (append-only log)

```jsonl
{"ts":"2026-03-01T18:30:00Z","flow":"auth/login.yaml","step":"tapOn: Sign In","fix_type":"text-mismatch","fix":"Changed 'Sign In' to 'Log In'","target":"flow"}
{"ts":"2026-03-01T18:35:00Z","flow":"smoke/smoke.yaml","step":"assertVisible: Continue Studying","fix_type":"missing-testid","fix":"Added testID='continue-studying' to DashboardScreen","target":"app"}
{"ts":"2026-03-01T18:40:00Z","flow":"student/courses-pagination.yaml","step":"tapOn: In Progress","fix_type":"locale-mismatch","fix":"Changed text selector to id: status-filter-in-progress","target":"both"}
```

### learnings.md grows over time

New patterns are appended as they're discovered. The cycle checks this file FIRST before investigating each failure — applying known fixes automatically saves time.

---

## Processing Single Flow

### 1. Run Flow

```bash
cd apps/mobile && maestro test .maestro/flows/auth/login.yaml 2>&1 | tee /tmp/maestro-flow-output.txt
```

### 2. Parse Output

Maestro output shows each step with pass/fail:
```
✅ launchApp
✅ waitForAnimationToEnd
✅ tapOn: "Email"
✅ inputText: test@example.com
❌ tapOn: "Sign In" — Element not found
```

Extract the failing step, error message, and context.

### 3. Check Known Patterns

```
For each failure:
  1. Read learnings.md
  2. Match error against known patterns
  3. If match found → apply known fix automatically
  4. If no match → investigate (grep source, check i18n)
```

### 4. Apply Fix

| Pattern | Fix Target | Action |
|---------|-----------|--------|
| text-mismatch | YAML flow | Update text in tapOn/assertVisible |
| missing-testid | App component | Add `testID` prop to React Native component |
| locale-mismatch | YAML flow | Replace text selector with `id:` selector |
| animation-timing | YAML flow | Add `assertVisible` after `waitForAnimationToEnd` |
| stale-navigation | YAML flow | Update tab name or navigation path |
| sub-flow-broken | Shared YAML | Fix the shared sub-flow (cascading fix) |
| app-bug | App code | Fix the React Native component/screen |
| mock-miss | YAML flow | Update `mockNetwork` path regex |

### 5. Verify

```bash
cd apps/mobile && maestro test .maestro/flows/auth/login.yaml
```

- **PASS:** Move to completed, record in history
- **FAIL:** Increment iteration, try different fix
- **MAX ITERATIONS (3):** Move to failed_permanently, continue next flow

---

## Configuration

```yaml
limits:
  max_iterations_per_flow: 3    # Max fix attempts per flow
  max_total_flows: 20           # Stop after N flows
  timeout_per_flow: 120000      # 2 min max per flow

behavior:
  auto_apply_known_patterns: true
  fix_shared_first: true          # Always prioritize shared/ sub-flows
  commit_after_each_flow: false
  commit_at_end: true

memory:
  keep_history_days: 30
  archive_on_reset: true
```

---

## Example Session

```
═══════════════════════════════════════════════════════════
  MAESTRO FIX CYCLE - Starting
═══════════════════════════════════════════════════════════

📂 Loading state...
   No previous state found — starting fresh cycle

🧪 Running all flows to build queue...
   Result: 12 passed, 4 failed

📋 Queue built (priority order):
   1. shared/login.yaml (sub-flow — affects 14 flows)
   2. flows/auth/login.yaml
   3. flows/student/course-detail.yaml
   4. flows/settings/theme-toggle.yaml

═══════════════════════════════════════════════════════════
  FLOW 1/4: shared/login.yaml
═══════════════════════════════════════════════════════════

🧪 Running flow...
   Result: FAILED at step "tapOn: Sign In"

🔍 Analyzing...
   Error: Element 'Sign In' not found
   Searching app source...
   Found: "Log In" in apps/mobile/app/(auth)/login.tsx:42
   Pattern: text-mismatch

🔧 Applying fix...
   → Edit .maestro/shared/login.yaml
   → Changed: tapOn: "Sign In" → tapOn: "Log In"

   ⚠️  This is a SHARED sub-flow — fix cascades to 14 dependent flows

✅ Verifying...
   Result: PASS ✅

📝 Updating memory...
   → Added to history.jsonl
   → Pattern already known in learnings.md

═══════════════════════════════════════════════════════════
  FLOW 2/4: flows/auth/login.yaml
═══════════════════════════════════════════════════════════

🧪 Running flow...
   Result: PASS ✅ (shared sub-flow fix resolved this too)

📝 Moving to completed (cascade fix)

... (continues)

═══════════════════════════════════════════════════════════
  MAESTRO FIX CYCLE - COMPLETE
═══════════════════════════════════════════════════════════

  Flows processed: 4
  Completed: 4 ✅
  Failed permanently: 0

  Fixes applied: 2
  Cascade fixes: 2 (resolved by shared sub-flow fix)
  New patterns learned: 0

  Ready to commit? (y/n)

═══════════════════════════════════════════════════════════
```

---

## Safeguards

1. **One flow at a time:** Prevents cascading confusion
2. **Shared flows first:** Fixes that cascade save time
3. **Max 3 iterations per flow:** Avoids infinite loops
4. **State persistence:** Can resume after crash/restart
5. **Known patterns first:** Applies proven fixes automatically
6. **History tracking:** Never loses fix information
7. **Learnings accumulate:** Gets smarter over time
8. **Fix app code, not just flows:** Maestro flows describe expected behavior — if the app is wrong, fix the app

## Philosophy

> **Falha no teste = bug no codigo ou flow desatualizado.**
> Entenda a causa raiz antes de mudar qualquer coisa.

### Decision Order
1. Is it a shared sub-flow issue? Fix shared first.
2. Is the app behavior correct? If yes, update the flow.
3. Is the app behavior wrong? Fix the app code.
4. Is it a selector issue? Prefer `testID` over text selectors.
