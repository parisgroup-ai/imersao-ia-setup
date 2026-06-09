# Design: Fase 1 — Deeper Discovery + Real Market Research

**Date:** 2026-06-09
**Status:** Approved 2026-06-09 (brainstorming) — pending spec review → writing-plans
**Repo:** `imersao-setup` (the `imersao` Claude Code plugin)
**Scope:** Sub-project 1 of 4 from the E2E test feedback (see §11). This spec covers **only Fase 1** (`/imersao:pg-imersao-prd`).

## 1. Problem

A full end-to-end test of the imersão skills surfaced one verdict: **the process works, but it's shallow.** The owner's words, mapped to the place in the prompts that causes each defect:

| Symptom (owner, E2E test) | Cause in the current prompt |
|---|---|
| "fez um brainstorming raso" | `pg-imersao-prd.md` Passo 2 = **~6 questions then "derive the rest"**. No depth, no options, no convergence. |
| "a ideia tem que ter pesquisa de mercado pra entender se é vendável, ou quanto economiza/otimiza na operação" | **There is no market research at all.** The plan is built purely from what the student asserts. |
| "tem que dar possibilidades, entender o contexto passado e se aprofundar até chegar na melhor opção" | The flow never branches into alternatives — it takes the first framing and runs. |
| "ficou bem fácil de usar, até demais" | Lightness was implemented as *shallowness*. |

This sub-project rewrites Fase 1 to be **deeper and grounded in real market evidence**, without violating the locked pedagogy.

## 2. Root cause and guiding principle

The pedagogy ([[imersao-pedagogia]]) correctly says: *few questions, don't drown the beginner, hide the plumbing.* That was read as **"keep everything light AND shallow."** But lightness-for-the-student ≠ shallowness.

> **Guiding principle:** depth migrates from the **student's input burden** to the **agent's reasoning burden.** The student still answers very little. The agent now does real research, explores real alternatives, and pressure-tests the idea — then hands the student a small number of **rich, evidence-backed choices** ("dar possibilidades") to react to.

This reconciles the feedback ("be deeper") with the locked pedagogy ("don't drown"). The deep research output stays in a file for whoever wants it; what the student *sees* in chat stays digestible.

## 3. Decisions locked in brainstorming (2026-06-09)

| # | Decision | Choice |
|---|---|---|
| D1 | When/how real is the market research | **Real web research, up front** (before designing the product) |
| D2 | How the agent "gives possibilities and converges" | **Branch into 2-3 product directions**, recommend one with the why, student picks/adjusts, then deepen only the chosen one |
| D3 | Value lens (sellable vs. operational savings) | **Detect which applies** from a light context read; research the dominant lens |
| D4 | What to do when research is unfavorable | **Truth with a path** — say it honestly, but always paired with the 2-3 most defensible directions; never a dead-end "no" |
| D5 | How deep the research goes | **Structured + skeptical** — dimension-by-dimension sweep reading real pages (~10-20 searches), cited sources, **plus an adversarial refutation pass** before the verdict. `deep-research` harness offered only as an opt-in "go even deeper" escalation, not the default |
| D6 | Existing-context directories (brownfield) | **Detect & confirm** — when the folder already has content, ask once whether to *analyze what's there and recommend what to build/improve* or *start a new idea*. The analysis-mode possibilities reuse the same directions + research machinery (§4.1) |

## 4. The new Fase 1 flow (what the student lives)

| # | Stage | Student does | Agent does (deep, behind the scenes) |
|---|---|---|---|
| 0 | Prepare folder | nothing | silent `git init` (unchanged) |
| 1 | **Capture idea + context** | 1-sentence idea (or from `$ARGUMENTS`) + answers **one light question**: "é pra **vender** pra outras pessoas/empresas, ou pra **usar no seu dia a dia / negócio**?" (+ if internal: "como funciona isso hoje?") | detects the **value lens** (D3) and the student's operational context |
| 2 | **Real market research** | **waits** (narrated: "antes de desenhar, vou pesquisar o mercado de verdade…") | structured + skeptical web research (§5). Writes `docs/pesquisa-de-mercado.md`. Returns a **digestible, jargon-free verdict** (truth with a path, D4) |
| 3 | **Directions** | **picks 1** of 2-3 angles (or adjusts) | presents 2-3 evidence-backed directions with pros/cons + **a recommendation and why** (D2). This is the core "what to build" decision |
| 4 | **Deepen the chosen direction** | confirms/adjusts drafts | derives screens, flows, rules, login, external deps — **proposing, not interrogating** (today's ~6 questions become drafts, now anchored to the chosen direction) |
| 5 | **Confirm + save** | one "sim" | writes both artifacts (§7), commits silently |
| 6 | Human close | — | connects to the prototype (Fase 2) with a benefit, not a command name |

**Decision points:** two, by design — the **direction choice** (Stage 3) and the **final summary** (Stage 5). This intentionally relaxes the old command's "UM ponto de parada" rule, because the direction choice *is* the "dar possibilidades" the owner asked for. Both are light and closed-ended.

### 4.1 Two entry modes (greenfield vs. brownfield)

Right after Stage 0, the command **detects whether the directory already holds pre-existing context** — source files, docs, or data not produced by the imersão itself (a bare folder, or one containing only `.git` / prior imersão outputs like `docs/plano-do-produto.md`, counts as empty).

- **Empty / fresh → greenfield:** proceed with Stage 1 as above (capture a one-sentence idea).
- **Has context → confirm once (D6):** ask, in plain PT-BR — *"vi que essa pasta já tem coisa — quer que eu **analise o que tem aqui e sugira o que dá pra construir/melhorar**, ou você tem uma **ideia nova do zero**?"*
  - Student picks **"ideia nova"** → greenfield (the existing files are ignored as the seed).
  - Student picks **"analisa o que tem"** → **brownfield:** Stage 1 is replaced by a **context-analysis stage** — the agent explores the directory and explains, in plain PT, what it is and what assets it holds ("isso aqui é um X que faz Y, com os ativos Z"). It still asks the light value-lens question (§5.1).

From Stage 2 on, **both modes share the same machinery.** In brownfield, the research (§5) is framed as *"given this existing asset, what's valuable/sellable to build or improve?"*, and the directions (§6) become **possibilities of what to do with the context** (build on top / extend / pivot / optimize) — each research-backed, with a recommendation. The directions mechanism *is* the recommendation engine the owner asked for ("analisa o contexto e dá recomendações").

That's the elegant reuse: the **seed** differs (idea vs. existing context), the rest is identical.

## 5. Market research design (Stage 2)

### 5.1 Value lens (D3)
The light context question in Stage 1 picks the lens:
- **Sellable (market):** the idea is a product to sell to others.
- **Savings/optimization (operational):** the idea is an internal tool for the student's own operation.
- If genuinely both, pick the dominant lens and mention the other in one line. Never force the irrelevant lens (a fabricated number is worse than none — D5 rationale).

### 5.2 Structured sweep (dimension-by-dimension, reading real pages)
The agent runs **WebSearch + WebFetch** (not snippets-only — it opens real pages) across the lens's dimensions:

**Sellable lens:**
1. Direct competitors — who already does exactly this; name + what + price.
2. Indirect substitutes — how people solve it today without this product.
3. Pricing & billing models — read from real pricing pages.
4. Willingness-to-pay / demand evidence — reviews, complaints, "alternative to X" threads.
5. Gaps / differentiation — what competitors lack (= the opening).
6. Risks / barriers — incumbents, acquisition cost, regulation.

**Savings/optimization lens:**
1. How the process is done today — cost in time / money / error rate.
2. Existing tools/approaches for it + reported impact.
3. Savings benchmark — how much similar operations saved/optimized.
4. Adoption effort vs. return — is it worth the switch?
5. Risks — why it hasn't been done already.

Target effort: **~10-20 targeted searches/fetches**, inline in the main session (no subagents/workflow — keep it simple and inside the student-facing flow). Narrated as a single "estou pesquisando o mercado…" moment.

### 5.3 Skeptical pass (D5)
After gathering, the agent runs **one adversarial refutation**: *"Try to refute that this is sellable / that this saves meaningful value. What's the strongest case this is a bad idea?"* The strongest counter-evidence is folded into the verdict honestly — this is what makes it "estruturada + cética" rather than confirmation-seeking.

### 5.4 The verdict (output to the student)
Digestible, zero jargon, **truth with a path** (D4):
- **O panorama** — who already does it / how it's solved today (2-3 bullets).
- **O sinal** — is it sellable? / how much can it save? — with at least one **real number or range + its source**, stated honestly (including the skeptic's strongest counter).
- Flows straight into the directions (Stage 3) — the verdict never dead-ends.

### 5.5 Fallback (no live web)
If web tools are unavailable, **degrade to a reasoned estimate clearly flagged as not-researched** ("não consegui pesquisar ao vivo, então isso é um chute meu — confirme depois"). Never fabricate a sourced-looking number.

### 5.6 Optional escalation
If the student wants more, offer the `deep-research` skill as a "quer que eu vá ainda mais fundo?" escalation. Not the default (too slow/expensive per idea).

## 6. Directions design (Stage 3)

From the research, present **2-3 distinct product directions** — different recorte / público / ângulo of the same underlying idea. Each carries:
- **O que é** (one line).
- **Por que esse ângulo** — why it's more defensible / sellable / valuable, backed by the research.
- **O trade-off** (honest).

The agent **recommends one with the reason**, then the student picks or adjusts. When the research is unfavorable to the original framing, the directions *are* the constructive pivot (D4) — no separate "your idea is bad" wall.

Presentation stays digestible: a clear recommendation + why, not a flat data dump.

## 7. Artifacts

1. **`docs/pesquisa-de-mercado.md`** *(new)* — the deep research, in plain PT-BR with a sources list:
   - **Resumo** (the verdict the student saw).
   - **Lente** (sellable / savings — and why).
   - **Panorama** (competitors / current process).
   - **O sinal** (numbers + sources).
   - **Direções consideradas** (the 2-3, the chosen one, and why it won).
   - **Checagem cética** (the strongest counter-argument + the response).
   - **Fontes** (real links).
2. **`docs/plano-do-produto.md`** — unchanged structure (the 11 sections), **plus a new top section "Por que vale a pena"** (3-4 bullets: chosen direction + the market signal + the value bet). This carries the validation forward into every downstream phase.

> **Brownfield (§4.1):** `pesquisa-de-mercado.md` also opens with an **"Análise do contexto existente"** section (what the agent found in the folder), and the chosen possibility in `plano-do-produto.md` notes **which existing context it builds on**.

## 8. Pedagogical guardrails (preserved)

- **Zero jargon** — "vendável", "economia", "ângulo/direção" in everyday PT-BR; never "TAM/SAM", "willingness to pay", "moat", "PMF", "market sizing".
- **Light on the student** — ~2 answers + 1 direction pick + 1 "sim". The added work is all the agent's.
- **Narrate the concept in 1 line** on first use (pesquisa de mercado, direção, vendável, economia) — never the mechanics.
- **Truth with a path** (D4) on every unfavorable signal.
- Still **no technology** in Fase 1 (stack/architecture stay in Fases 2-3). Market research is product-level, so it fits the rule.

## 9. What changes (files)

| File | Change |
|---|---|
| `plugins/imersao/commands/pg-imersao-prd.md` | **Major rewrite.** Add the **mode detection + confirm** (§4.1, greenfield vs. brownfield). Split Passo 2: light context question first; defer the deep product questions to after the direction is chosen. Insert the research stage (§5) and the directions stage (§6). Add the new artifact + "Por que vale a pena" section. |
| `plugins/imersao/commands/pg-imersao-start.md` | **Small.** Compass wording: Fase 1 becomes "DEFINIR **e checar se vale a pena**"; state-table line reflects the validated plan. |
| `docs/PROCESSO-IMERSAO.md`, `docs/PRIMEIROS-PASSOS.md` | **Check/sync** — update any description of Fase 1 to mention the research step. |
| Memory (`pipeline-4-fases`, `imersao-pedagogia`) | Record the new `pesquisa-de-mercado.md` artifact and the research stage (after implementation). |

Plugin version: bump (minor) on release, per the repo's tag/release convention ([[release-tags-convention]]).

## 10. Error handling / edge cases

- **No live web** → §5.5 flagged estimate.
- **Unfavorable research** → §6 directions as the path; never a dead-end.
- **Idea is both sellable and operational** → §5.1 dominant lens + one-line mention of the other.
- **Student insists on the original framing** after an honest verdict → respect it; record the signal in `pesquisa-de-mercado.md` so it's not lost, and proceed to deepen that direction.
- **Research takes long** → narrate progress; keep it bounded (~10-20 queries), don't spiral into a `deep-research` marathon unless the student opts in (§5.6).

## 11. Out of scope (the other 3 sub-projects)

This spec is Fase 1 only. Tracked as follow-ups, each its own spec → plan → implementation:
- **SP2 — Fase 2 screen coverage:** prototype must cover all main screens from the plan, not 3.
- **SP3 — Fase 3 real-not-mocked + API key honesty:** detect external-capability needs (AI, payments), surface the API-key requirement early and honestly, wire real functionality, don't rush to deploy.
- **SP4 — Publish honesty gate:** before deploy, an honest "what's real vs. mocked / what keys are needed" status.

A richer Fase 1 plan (more screens, clearer value thesis) directly feeds SP2 and SP3.

## 12. Acceptance criteria (E2E manual — it's a prompt)

Re-run the imersão Fase 1 on a fresh idea and verify:
1. Fase 1 asks **≤2 light questions** before researching (idea + value-lens context).
2. The agent performs **real web research** — `docs/pesquisa-de-mercado.md` cites **real, fetchable source links**.
3. The verdict is **digestible, zero jargon**, with **≥1 real number/range + source**.
4. The value **lens is detected correctly** (sell vs. internal) from the context answer.
5. The agent presents **2-3 directions with a recommendation** and **waits** for the student's choice.
6. A **skeptic/refutation note** is present in the research file and reflected in the verdict.
7. On an unfavorable idea, the response is **truth with a path** (no dead-end "no").
8. **Both artifacts** are written; `plano-do-produto.md` has **"Por que vale a pena"**.
9. **Web-unavailable** → a flagged estimate, **not** a fabricated source.
10. All student-facing copy is **PT-BR, jargon-free**; each new concept narrated in 1 line on first use.
11. **Brownfield (§4.1):** in a folder with pre-existing content, the agent **detects it and asks once** whether to analyze-and-recommend or start fresh. On "analisa o que tem", it explains what's there in plain PT, and the directions become **research-backed possibilities** for that context. On "ideia nova", it ignores the existing files and runs greenfield.
