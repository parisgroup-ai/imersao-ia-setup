---
name: launch-audit
version: 1.0.0
description: >
  Run a comprehensive pre-launch quality audit on any web application.
  Explores the codebase first, then generates project-specific audit prompts
  that reference the actual files, routes, hooks, and functions found.
  Covers 7 areas: security, functionality, domain data coherence, visual
  consistency, performance, test coverage, and UX polish. Produces per-area
  audit reports and a final scorecard with 0-10 grades and launch readiness
  verdict. Use this skill whenever someone says "audit", "launch readiness",
  "pre-launch review", "quality check", "is this ready to ship", "review
  before launch", "pente fino", "revisão pré-lançamento", "está pronto pra
  lançar", "qa completa", "score the codebase", or any variation of checking
  whether a project is ready for production. Also triggers for deep-dive
  flow audits: "audita o wizard", "deep dive no checkout", "rastreia os
  dados do fluxo X", or any request to audit a specific multi-step flow
  in detail. Works with any web stack (React, Next.js, Vue, Svelte, etc
  + any backend).
---

# Pre-Launch Quality Audit

## How to Use

This skill activates automatically — no special commands needed. Just say what you want in natural language.

### Full Audit (reviews the entire app)

Say any of these:
- "faz um pente fino no projeto"
- "está pronto pra lançar?"
- "roda uma auditoria completa"
- "is this ready to ship?"
- "quality check before launch"
- "score the codebase"

What happens: explores the project → runs 7 audit phases (security, functional, domain data, visual, performance, tests, polish) → generates a scorecard with grades and a launch verdict.

### Deep Dive (audits one specific flow in detail)

Say any of these:
- "audita o wizard"
- "deep dive no fluxo de checkout"
- "rastreia os dados do onboarding"
- "revisa o fluxo de pagamento"
- "audita o fluxo de cadastro de paciente"

What happens: explores the project → maps every file in that specific flow → traces each data field step by step → audits every button and interaction → checks AI calls and external services → generates a focused report.

### Running both

You can run a Full Audit first, then ask for a Deep Dive on a specific flow that needs more attention. They complement each other.

---

## Mode Detection (for the AI)

Detect which mode to use based on the user's request:

**Full Audit** — user mentions the whole app or general quality:
- → Run Stage 1 (Discovery) → Stage 2 (7-Phase Audit) → Stage 3 (Scorecard)

**Deep Dive** — user mentions a specific flow, feature, or multi-step process:
- → Run Stage 1 (Discovery) → Stage 4 (Deep Dive) → produce a focused report

Both modes always start with Stage 1 (Discovery) because understanding the project is non-negotiable.

---

## Task Orchestration (How to Execute)

This audit is a long, multi-step process. To keep it organized and automated, you MUST use a task list (TodoWrite / TaskNotes) to orchestrate the execution. Create all tasks upfront, then work through them one by one — marking each as in_progress when you start it, and completed when the report is saved.

### Full Audit task list:

```
1. [Discovery] Map project stack, routes, flows, and domain data
2. [Security] Audit auth, authorization, sensitive data, inputs, compliance
3. [Functional] Trace and verify every core user flow
4. [Domain Coherence] Trace domain data end-to-end, check consistency
5. [Visual] Audit every page for layout, states, responsiveness, content
6. [Performance] Check bundle, rendering, data fetching, backend
7. [Tests] Run test suite, check coverage gaps, verify type safety
8. [Polish] Scan for TODOs, loading states, error handling, accessibility
9. [Scorecard] Read all reports, verify fixes, grade each area, give verdict
```

### Deep Dive task list:

```
1. [Discovery] Map project stack, routes, flows, and domain data
2. [Flow Map] Identify every file in the target flow
3. [Data Coherence] Trace each data field step-by-step through the flow
4. [Buttons & UI] Audit every interactive element in the flow
5. [AI/Services] Audit external calls, prompts, models, fallbacks
6. [Output] Verify the final result matches all upstream data
7. [Report] Generate deep dive report with summary and priority fixes
```

Create these tasks at the start. Update them as you go. This way the user can see progress and the process runs automatically from start to finish without needing manual intervention between phases.

---

## Stage 1: Deep Discovery (This is the most important stage)

Before writing a single audit finding, you MUST understand the project thoroughly. The quality of the entire audit depends on this step — a generic checklist is useless compared to prompts that reference the actual files.

### 1.1 — Detect the stack

Read the root of the project and identify:

- **Framework**: React? Next.js? Vue? Svelte? (check package.json)
- **Language**: TypeScript? JavaScript? (check tsconfig.json)
- **Styling**: Tailwind? CSS Modules? styled-components?
- **UI Library**: shadcn/ui? MUI? Chakra? Ant?
- **Backend**: Supabase? Firebase? Custom API? (check env vars, imports)
- **Auth**: Supabase Auth? NextAuth? Clerk? Custom?
- **Payments**: Stripe? Paddle? (check dependencies)
- **AI/ML**: Any AI integrations? (OpenAI, Anthropic, Google AI)
- **Testing**: Vitest? Jest? Playwright? Cypress?
- **Monorepo**: Turborepo? Nx? Simple workspace?

### 1.2 — Map every route, flow, and backend function

This is where you go deep. Read:

1. **The router** (App.tsx, pages directory, or router config) — list EVERY route
2. **Every page component** — understand what each screen does
3. **Backend functions / API routes** — list every endpoint and what it does
4. **Key hooks and contexts** — identify the state management layer
5. **Types / schemas** — understand the data model
6. **Database migrations** (if accessible) — understand the schema

### 1.3 — Identify the core user flows

From the routes and components, identify the 3-7 main flows users go through. For each flow, trace the full path:

```
User action → Page component → Hook → Data client / API call → Backend function → Database → Response → UI update
```

Write down the exact file paths for each step.

### 1.4 — Identify the domain-specific data

Every app has "the important stuff" — the data users pay for. In a medical app, that's clinical data. In a finance app, that's calculations. In an e-commerce app, that's pricing and inventory. Identify what that is and where it lives.

### 1.5 — Save the project map

Save your findings to `docs/reviews/00-project-map.md`. This document is the foundation for everything that follows. Include:

```markdown
# [Project Name] — Project Map

## Stack
[framework, backend, auth, payments, etc]

## Routes ([count] total)
| Route | Page Component | Type | Purpose |
|-------|---------------|------|---------|

## Core User Flows
### Flow 1: [Name]
- Page: [file path]
- Hook: [file path]
- API: [file path]
- Backend: [file path]
[repeat for each flow]

## Backend Functions ([count] total)
| Function | Purpose | Called by |
|----------|---------|----------|

## Domain Data
[what's the "important stuff" and where does it live]

## Key Files to Audit
[list of the most critical files, grouped by concern]
```

### 1.6 — Communicate to the user

Tell the user what you found, in plain language:

> "I've mapped your project: it's a [framework] app with [backend], [X pages], [Y API routes]. The main flows are [A, B, C]. The domain data is [description]. Now I'm going to run 7 audit phases — each one will produce a report in docs/reviews/."

---

## Stage 2: The 7-Phase Audit

Each phase generates a Markdown report. The key difference from a generic audit is that every finding MUST reference the actual file path, line number, and variable name from THIS project. No generic advice.

Run them in this order — security and functionality are launch blockers; visual polish is not.

### Phase 1: Security & Data Protection

**Report:** `docs/reviews/01-security-audit.md`

Using the project map from Stage 1, check these areas by reading the ACTUAL code. For each item, mark as OK / RISK / CRITICAL / N/A:

**Authentication** — read the auth files you identified in the project map:
- Protected routes verify session correctly
- Token refresh works (not just on page load)
- Password requirements exist and are reasonable
- OAuth/social login redirects are safe
- Session timeout exists

**Authorization** — read the database config and API routes:
- Database has row-level security or equivalent
- One user cannot access another user's data (trace a query to verify)
- Every API route validates caller identity
- Admin routes are protected

**Sensitive Data** — search across the entire codebase:
- No API keys in frontend code (search for `sk-`, `key_`, hardcoded tokens)
- .gitignore covers all .env files
- Logging doesn't leak personal data (search for console.log patterns)
- Error tracking scrubs PII (check Sentry/Datadog config if present)
- If health/financial/personal data exists, verify encryption

**Input Validation** — for each form and API endpoint found in the map:
- Frontend validation exists (Zod, yup, etc)
- Backend validation exists (not just trusting the frontend)
- File uploads check type AND size
- Free-text fields are sanitized

**Sharing & Public Access** — if the app has sharing features:
- Public links don't expose private data
- Tokens are random and expire
- Rate limiting exists on public endpoints

**Compliance** — based on the domain:
- If personal data: GDPR/LGPD data export and deletion work
- If consent required: consent tracking exists with timestamps
- Privacy policy and terms exist

Every finding must include: file path, line number, what's wrong, what to do about it.

### Phase 2: Functional Integrity

**Report:** `docs/reviews/02-functional-audit.md`

For EACH core user flow from the project map:

1. Read the full code path: page → hook → data client → API → database
2. Check that data flows correctly through every layer
3. Verify error handling exists at each step
4. Check state management (loading, error, empty, success states)

For each flow, document:
- **Status**: Functional / Partially Functional / Broken / Not Implemented
- **Issues found**: file path and line number for each
- **Missing error handling**: where the code assumes success without catching failures
- **Edge cases**: what happens with no data? special characters? concurrent requests?

For multi-step flows (wizards, multi-page forms): does data persist between steps? Can the user go back? Does cancel clean up properly?

### Phase 3: Domain Data Coherence

**Report:** `docs/reviews/03-domain-coherence-audit.md`

This is about the domain-specific data you identified in Stage 1. This is often where the most damaging bugs hide — not "the app crashed" but "the app showed the wrong number and the user made a bad decision."

For each piece of core domain data:

1. **Trace it end-to-end**: Where is it created? Where stored? Where transformed? Where displayed?
2. **Check internal consistency**: Does the same data appear the same way in every place it's used?
3. **Check enums/types**: Do frontend and backend agree on the valid values?
4. **Check calculations**: Can they produce wrong results?
5. **Check hardcoded values**: Do they match the database/API?

The report format for each data field:
```markdown
### [Field Name]
- **Created at:** [file:line] — [how]
- **Stored as:** [file:line] — [format]
- **Transformed at:** [file:line] — [how]
- **Displayed at:** [file:line] — [how]
- **Status:** ✅ Consistent | ⚠️ Risk | ❌ Inconsistent
- **Issue:** [if any]
- **Fix:** [suggested correction]
```

### Phase 4: Visual Consistency

**Report:** `docs/reviews/04-visual-audit.md`

For EVERY page/component found in the route map, check:

**Layout & Responsiveness:**
- Works at 375px (mobile), 768px (tablet), 1440px (desktop)
- No overflow, no broken layouts

**Component Consistency:**
- Cards, buttons, inputs look the same across pages
- Colors, fonts, spacing are consistent
- Icons are from the same family

**States (for every interactive element):**
- default, hover, focus, disabled, loading
- Empty states have messages
- Error states are helpful (not technical)

**Content:**
- Correct language throughout (no mixed languages)
- No placeholder text (Lorem, TODO, FIXME)
- No grammar errors in user-facing text

Each issue: severity (High/Medium/Low), file path, suggested fix.

### Phase 5: Performance

**Report:** `docs/reviews/05-performance-audit.md`

Rate each area 1-10:

**Bundle Size:** Lazy-loaded routes? Tree-shaking? Heavy libs in main bundle?
**Rendering:** Unnecessary re-renders? Missing memoization? Unvirtualized lists?
**Data Fetching:** Caching configured? Request waterfalls? Pagination?
**Backend:** Appropriate timeouts? Retry logic? Efficient queries?

### Phase 6: Test Coverage

**Report:** `docs/reviews/06-test-audit.md`

1. Run the test suite (try: `npm test`, `pnpm test`, `npx vitest run`)
2. Run TypeScript compiler: `npx tsc --noEmit`
3. Document: how many tests, how many pass/fail
4. Identify gaps: are the core flows tested? Is business logic tested? Are types synchronized between frontend and backend?

### Phase 7: UX Polish

**Report:** `docs/reviews/07-polish-audit.md`

**Text:** Search for TODO/FIXME/HACK/lorem. Check error messages are helpful.
**Feedback:** Every async action has loading state. Buttons disable during submission. Success/error feedback after every action.
**Error Recovery:** Network drop during form? Global error boundary? Can user recover without refresh?
**Accessibility:** Labels on inputs. Alt on images. Focus trap in modals. Color contrast 4.5:1.

---

## Stage 3: The Scorecard

After all 7 phases, generate the final verdict.

**Report:** `docs/reviews/LAUNCH-SCORECARD.md`

### 3.1 — Verify fixes

If any items in previous reports were marked "fixed" or "resolved":
- Open the actual file and line
- Confirm the fix exists in current code
- If NOT actually fixed, flag as **REGRESSION**

### 3.2 — Generate the scorecard

```markdown
# [Project Name] — Launch Readiness Scorecard
Date: [current date]

## Grades (0-10)

| Area | Grade | Summary |
|------|-------|---------|
| Security & Data Protection | X/10 | [1-2 sentences] |
| Functional Integrity | X/10 | [1-2 sentences] |
| Domain Data Coherence | X/10 | [1-2 sentences] |
| Visual Consistency | X/10 | [1-2 sentences] |
| Performance | X/10 | [1-2 sentences] |
| Test Coverage | X/10 | [1-2 sentences] |
| UX Polish | X/10 | [1-2 sentences] |

**OVERALL: X.X/10**

### Grading Scale
- 9-10: Excellent — ready for production at scale
- 7-8: Good — ready for early adopters / soft launch
- 5-6: Acceptable — can launch with known risks
- 3-4: Needs work — not ready for paying users
- 1-2: Critical — do not launch

## Launch Blockers

[MUST fix before launch. If none: "None identified."]

- **[BLQ-01]**: [Description]
  - Found in: [which report]
  - File: [path]
  - Effort: [hours]
  - Risk if ignored: [what happens to users]

## Post-Launch (fix within 2 weeks)

- **[POS-01]**: [Description] — Priority: High/Medium — Effort: [hours]

## Backlog

- **[BKL-01]**: [Brief description]

## Regressions

[Items marked "fixed" but NOT fixed. If none: "No regressions found."]

## Gaps

[What the 7 audits didn't cover but should have. Think: i18n, offline mode, PWA, email deliverability, monitoring, backups, CI/CD, env parity.]

## Verdict

### Ready to launch? [YES / YES WITH CAVEATS / NO]

[3-5 sentences. Be direct. A system that shows wrong data is worse than an ugly system.]

### Recommended Timeline
- If YES: Launch by [date]. Monitor [X, Y, Z] first week.
- If YES WITH CAVEATS: Fix [blockers] by [date]. Launch by [date].
- If NO: Return to fixing. Estimated time: [X days/weeks].
```

### 3.3 — Grading principles

Read `references/grading-rubric.md` for detailed criteria per grade level.

Core principles:
- **Domain data correctness > everything else.** Wrong data that users make decisions on is the worst kind of bug.
- **Security basics are non-negotiable.** Exposed keys, missing auth, cross-tenant data leaks = always blockers.
- **Functional > Visual.** A working ugly feature beats a beautiful broken one.
- **Don't inflate grades.** 7/10 = "good, ship it." 5/10 = "works but rough edges." Be honest.
- **Consider the user.** Someone is paying for this. Would you pay for it?

---

---

## Stage 4: Deep Dive (Single Flow Audit)

Use this stage when the user asks to audit a specific flow (e.g., "audita o wizard", "revisa o checkout", "deep dive no onboarding"). This is a surgical audit — instead of scanning the whole app broadly, you go extremely deep into one flow.

### 4.1 — Identify the flow

From the project map (Stage 1), identify all the files involved in the requested flow:
- The page(s) / route(s)
- Every component used in the flow
- Every hook and context
- Every API call / edge function / backend route
- Every type and schema involved
- The database tables touched

List every file path explicitly. Read ALL of them completely — not just headers.

### 4.2 — Data Coherence Trace

This is the most important part of a deep dive. For multi-step flows (wizards, checkout, onboarding), data passes through many layers and can become inconsistent.

For EACH important data field in the flow, trace it step by step:

```markdown
### [Field Name] (e.g., treatment_type, price, user_role)
- **Step 1 [page/component]:** [how it's created/set] → file:line
- **Step 2 [page/component]:** [how it's used/modified] → file:line
- **Step 3 [page/component]:** [how it's passed to next step] → file:line
- **Backend [function]:** [how it's received and used] → file:line
- **Database:** [how it's stored] → file:line
- **Output [page/component]:** [how it's displayed to user] → file:line
- **Status:** ✅ Coherent | ⚠️ Risk | ❌ Incoherent
- **Problem:** [if any — e.g., "user can change X in step 3 but backend still uses the original value from step 1"]
- **Fix:** [specific suggestion]
```

Key questions to answer for each field:
- If the user edits this field, does the edit propagate to ALL downstream consumers?
- If the AI suggests a value, can it be overridden? Does the override stick through all steps?
- Is there a single source of truth, or do multiple places hold copies that can drift?
- Do frontend types match backend types for this field?

### 4.3 — Button & Interaction Audit

For EVERY button, link, toggle, and interactive element in the flow:

```markdown
### [Step X] — [Button/Action Name]
- **File:** [path:line]
- **Default state:** ✅/❌ [has visible, styled default appearance]
- **Hover state:** ✅/❌
- **Loading state:** ✅/❌ [shows spinner/text change during async operation]
- **Disabled state:** ✅/❌ [disables when it should, e.g., form incomplete]
- **Disabled reason:** ✅/❌ [tooltip or message explaining WHY it's disabled]
- **Error recovery:** ✅/❌ [button returns to normal after failed action]
- **Double-click protection:** ✅/❌ [debounce or disable during async]
- **Mobile accessible:** ✅/❌ [reachable, not cut off, adequate touch target]
```

### 4.4 — AI/External Service Audit (if applicable)

If the flow calls AI models or external services, audit each call:

For each AI/service call:
- **What model/service is used?** (exact model ID, version)
- **What's the input?** Does it receive all the context it needs? Does it receive the user's edits or just the original data?
- **What's the prompt?** Is it specific enough? Does it instruct coherence with previous steps?
- **What's the output schema?** Does it match the TypeScript types that consume it?
- **Is there a fallback?** What happens if the call fails or times out?
- **Do multiple AI calls stay coherent?** If call A returns result X, does call B receive X as context? Or does each call independently "re-decide" things?
- **Temperature:** Is it appropriate? Low for deterministic outputs (protocols, calculations), higher for creative outputs (simulations, copy).

### 4.5 — Output/Result Audit

The final output of the flow — the thing the user sees and acts on:

- Does it include ALL the information from previous steps?
- Is the information accurate (matches what was set/edited in the flow)?
- Can it be exported (PDF, print, share)?
- If shared via link, does it show the same data? Are sensitive fields hidden?

### 4.6 — Generate the Deep Dive Report

Save to `docs/reviews/deep-dive-[flow-name].md`:

```markdown
# [Flow Name] — Deep Dive Audit
Date: [current date]

## Flow Map
[List every file involved, grouped by step]

## Data Coherence
[One section per traced field, using the format from 4.2]

## Buttons & Interactions
[One section per button, using the format from 4.3]

## AI/External Services
[One section per call, using the format from 4.4]

## Output Quality
[Findings from 4.5]

## Summary

| Category | Issues Found | Critical | Medium | Low |
|----------|-------------|----------|--------|-----|
| Data Coherence | X | X | X | X |
| Buttons & UI | X | X | X | X |
| AI/Services | X | X | X | X |
| Output | X | X | X | X |

## Top Priority Fixes
1. [Most critical issue — what, where, why it matters]
2. [Second most critical]
3. [Third]
...
```

---

## Communication Style

- Say what you're doing before you do it
- Explain WHY something matters, not just "this is wrong"
- Plain language: "this page breaks on phones" not "responsive viewport breakpoint failure"
- Be direct with the verdict — the user needs a clear answer, not diplomatic hedging
- If the user isn't technical, explain findings without jargon
