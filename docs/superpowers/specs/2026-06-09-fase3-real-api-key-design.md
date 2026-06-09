# Design: Fase 3 — Real Functionality + API-Key Honesty

**Date:** 2026-06-09
**Status:** Approved 2026-06-09 (brainstorming GATE 1) — pending writing-plans
**Repo:** `imersao-setup` (the `imersao` Claude Code plugin)
**Scope:** Sub-project 3 of 4 from the E2E test feedback (see Fase 1 spec §11). This spec covers **Fase 3** (`/imersao:pg-imersao-implementar`) plus small honesty touches in Fases 1 and 4.

## 1. Problem

The owner's E2E test verdict for Fase 3: **"tá tudo mocado e não me avisou da chave."** Mapped to causes:

| Symptom (owner, E2E test) | Cause in the current prompt |
|---|---|
| AI features shipped as silent mocks | `pg-imersao-implementar.md` never mentions external capabilities. The engine, lacking an API key, fakes the AI responses and never says so. |
| "não me avisou da chave" | Nothing in any phase warns that an AI feature needs an **API key** — a separate thing from the student's Claude Max subscription, with its own per-use cost. |
| Student discovers the fake late (or never) | There is no visible marker in the built app, no record of what is real vs. mocked. |

The cohort is **product builders shipping AI-powered apps** — the AI feature is usually the heart of the product, so a silently-mocked AI feature is a trust break, not a detail.

## 2. Guiding principle

**No silent mocks.** Every external capability promised in the product plan is either **real** or **explicit demo — the student decides, warned early.** Consistent with the locked pedagogy ([[imersao-pedagogia]]): the extra depth (detecting needs, warning, guiding key creation) is the **agent's** burden; the student only answers one light question per capability.

## 3. Decisions locked in brainstorming (2026-06-09)

| # | Decision | Choice |
|---|---|---|
| D1 | Student has no key at build time | **Ask early:** "create it now (guided, ~5 min)" or "demo mode" — demo is explicit and swapping the key in later is a 1-step documented action |
| D2 | Where the student first learns about the key | **Fase 1 warns, Fase 3 resolves** — the plan's "Conexões de fora" flags key+cost; Fase 3 collects the key as an interactive precondition (like the Docker check) |
| D3 | Scope of "real, not mocked" | **General rule for every external capability** (AI, payments, e-mail, maps…); **AI gets the VIP guided path** (key creation walkthrough, cost narration, test call) |
| D4 | How demo mode shows up in the built app | **Visible badge + 1-step swap** — real code path reads the key from `.env`; without it, falls back to demo and the UI shows a "modo demonstração" badge; pasting the key flips to real without code changes |
| D5 | Implementation mechanism | **Prompt rewrite + prescribed integration pattern** — the command prescribes the standard shape (env var, single AI module, demo fallback, badge) so builds are consistent and invariants are CI-checkable; no code templates in this repo |

## 4. The new Fase 3 flow (what the student lives)

`pg-imersao-implementar.md` gains a new stage between the existing preconditions and "Disparar o motor":

### 4.1 Detect external capabilities (agent work, silent)

Read the **"Conexões de fora"** section of `docs/plano-do-produto.md` (plus the rest of the plan as a safety net — a feature description like "gera resumo com IA" counts even if the section missed it). Classify each capability: AI/LLM, payments, e-mail, maps, other.

- **No external capabilities** → proceed exactly as today. **Zero new friction, zero new pauses.**

### 4.2 AI capability — the VIP path

Before the scaffold, narrate once, in plain PT-BR (concept in 1 line, per the pedagogy):

> "Seu app usa **IA de verdade**. Pra isso ele precisa de uma **chave de API** — ela é separada da sua assinatura do Claude e custa **centavos por uso** (você paga só o que o app consumir)."

Then ask ONE light question with three answers:

1. **"Já tenho uma chave"** → collect it (see 4.4) and build real.
2. **"Quero criar agora"** → guide step-by-step: `console.anthropic.com` → sign in → billing (explain the small credit purchase honestly) → create key → collect it (4.4). ~5 min, agent narrates each click.
3. **"Seguir em modo demonstração"** → build with the explicit demo fallback (§5); remind the student of the 1-step swap.

### 4.3 Other external capabilities — same contract, sensible defaults

Same warn-then-ask shape, with a per-type recommendation the student can just accept:

- **Payments** → recommend Stripe **test mode** (real integration, fake cards — narrate: "cartões de teste, sem dinheiro de verdade; ligar o modo real é trocar uma chave depois").
- **E-mail** → recommend explicit demo (log/preview) unless the student has a provider key.
- **Maps / other APIs with free tiers** → recommend creating the free key (guided) or demo.

Never silently mock any of them.

### 4.4 Key handling rules (security invariants)

- The student pastes the key in the chat; the agent writes it to **`.env`** and never echoes, logs, or commits it.
- **`.gitignore` must cover `.env`** — `create-next-app`'s default gitignore covers `.env*.local` but **NOT** `.env`; the scaffold task must append `.env` to `.gitignore` before the first commit.
- Validate the key with one minimal API call ("vou fazer um teste rapidinho pra confirmar que a chave funciona") — on failure, say so plainly and re-ask (typo is the common case).
- `.env.example` carries the variable name with an empty value, committed.

## 5. Prescribed integration pattern (scaffold Task 1 addition, when AI is detected)

The command prescribes the **shape**, not literal code (D5):

1. **Env:** `ANTHROPIC_API_KEY` in `.env.example` (empty) and `.env` (real or empty).
2. **Single AI module** (e.g. `lib/ai.ts`): the only place that talks to the AI.
   - Key present → real call via the official SDK (`@anthropic-ai/sdk`), **cheap model by default** (Haiku tier) so usage costs stay in centavos.
   - Key absent → return a clearly-marked demo response (`{ demo: true, ... }`) — plausible content so flows remain demonstrable, never pretending to be live.
3. **Demo badge:** any UI surface rendering a demo response shows a discreet **"modo demonstração"** badge. Real responses never show it.
4. **1-step swap:** paste the key into `.env`, restart `npm run dev` → real, zero code edits. Documented in plain PT in the generated app's README ("Como ativar a IA de verdade").
5. **Tests never call the real API** — the AI module is mocked at the test seam; TDD runs as today (student sees only the narrated result).

The same shape generalizes to other capabilities (one module per capability, env-driven, demo-marked fallback, badge).

## 6. Honesty record — `docs/o-que-e-real.md` (bridge to SP4)

At the end of Fase 3 (before the final gate), the engine writes **`docs/o-que-e-real.md`** in the student's app — plain PT-BR, jargon-free:

- A short table: **funcionalidade → real / demonstração → o que falta pra ativar** (e.g., "Resumo com IA → demonstração → colar sua chave no arquivo `.env`").
- One line stating data is local-only until Fase 4.

This is the artifact the future **SP4 publish-honesty gate** will read. Narrated to the student in one line ("deixei anotado o que está de verdade e o que está em demonstração").

## 7. Touches in the other phases (small)

| File | Change |
|---|---|
| `plugins/imersao/commands/pg-imersao-prd.md` (Fase 1) | **Small.** Passo 6's "depende de algo de fora?" gains: when an external capability is detected (esp. AI), narrate 1 line — "isso usa IA de verdade; lá na construção você vai precisar de uma **chave** (custa centavos por uso) — te aviso na hora". The plan's **"Conexões de fora"** records per connection: needs a key? approximate cost? resolved in Fase 3. |
| `plugins/imersao/commands/pg-imersao-publicar.md` (Fase 4) | **Small.** New step in the Railway section: if the app uses a key, add `ANTHROPIC_API_KEY` (raw value, not a reference) in **Variables** — narrate why ("o ar não lê o `.env` do seu computador"). If the app is in demo mode, say plainly that the public app stays in demo until a key is added. |
| `plugins/imersao/commands/pg-imersao-start.md` | **Check/sync.** Fase 3 wording reflects "construir de verdade (funcionalidade real)". |
| `docs/PROCESSO-IMERSAO.md`, `docs/PRIMEIROS-PASSOS.md` | **Check/sync** — mention the API key (what it is, that Fase 3 guides it, rough cost) wherever Fase 3 is described. |

The full pre-publish honesty gate remains **SP4** — out of scope here; only the artifact (§6) is born now.

## 8. Pedagogical guardrails (preserved)

- **Zero jargon** — "chave de API" is allowed (it's the real-world name, narrated on first use); never "env var" (say "configuração secreta", as Fase 4 already does), "SDK", "fallback", "mock" (say "demonstração").
- **Light on the student** — at most ONE question per external capability, with a recommended default; apps without external capabilities get zero new pauses.
- **Truth always** — cost stated honestly (including the billing/credit step at Anthropic); demo never disguised as real.
- **Gates unchanged** — Fase 3 keeps its single human gate (final delivery); the key question is an interactive precondition like the Docker check, not a new gate.

## 9. What changes (files)

| File | Change size |
|---|---|
| `plugins/imersao/commands/pg-imersao-implementar.md` | **Major** — new §4 stage (detect + warn + ask), §5 prescribed pattern in the scaffold task, §6 honesty record, key-handling invariants (§4.4) |
| `plugins/imersao/commands/pg-imersao-prd.md` | Small (§7) |
| `plugins/imersao/commands/pg-imersao-publicar.md` | Small (§7) |
| `plugins/imersao/commands/pg-imersao-start.md` | Tiny/check (§7) |
| `docs/PROCESSO-IMERSAO.md`, `docs/PRIMEIROS-PASSOS.md` | Check/sync (§7) |
| `scripts/check-fase3.sh` *(new)* | Presence-only invariant guard, style of `check-fase1.sh`: anchor terms in the commands (Conexões de fora read, `ANTHROPIC_API_KEY`, "modo demonstração", `o-que-e-real`, `.gitignore`/`.env` rule) |
| `.github/workflows/*` (CI) | Run `check-fase3.sh` next to `check-fase1.sh` |
| `plugins/imersao/.claude-plugin/plugin.json` | Version bump (minor) → **1.8.0** on release, per [[release-tags-convention]] |
| Memory (`pipeline-4-fases`) | Record SP3 shipped (after implementation) |

## 10. Error handling / edge cases

- **Plan has no "Conexões de fora" section** (older plans) → scan the whole plan for capability signals; if genuinely none, proceed without friction.
- **Invalid/typo key** → minimal test call fails → plain-PT retry, never a raw stack trace.
- **Student refuses both key and demo** → demo is the default with a gentle note; never block the class.
- **Key paste hesitation** → reassure: "a chave fica só no seu computador, num arquivo que nunca sobe pro GitHub" (and make that true — §4.4).
- **Port/Docker preconditions** → unchanged from today.
- **Demo app deployed (Fase 4)** → the public app honestly shows the demo badge; publicar narrates it (§7).

## 11. Out of scope

- **SP2** — Fase 2 screen coverage (own spec).
- **SP4** — full pre-publish honesty gate (own spec; consumes §6's artifact).
- Code templates shipped in this repo (D5 rejected option).
- Provider choice beyond Anthropic as the default AI provider (others may appear as the plan demands; the pattern is provider-agnostic).

## 12. Acceptance criteria (E2E manual — it's a prompt)

Re-run the imersão on an AI-feature idea and verify:

1. Fase 3 **detects external capabilities from the plan** and lists them before the scaffold.
2. The **API-key warning happens BEFORE building**, in plain PT-BR, stating it's separate from the Claude subscription and costs centavos per use.
3. The question offers **já tenho / criar agora / demonstração**; the guided path walks console.anthropic.com step by step.
4. The key lands in `.env`, **`.env` is gitignored** (verified — `create-next-app` does NOT cover it by default), the key is never echoed or committed, and a **minimal test call validates it**.
5. In demo mode, the UI shows the **"modo demonstração" badge** on demo responses; real responses never show it.
6. **1-step swap works:** pasting the key into `.env` + restart flips to real with zero code edits; the generated README documents it in PT.
7. **`docs/o-que-e-real.md`** is written with an honest real/demo table.
8. Fase 1's plan records key+cost in "Conexões de fora"; Fase 4 covers the Railway variable (or narrates demo status).
9. An app with **no external capabilities** gets **zero new pauses**.
10. All student-facing copy is **PT-BR, jargon-free**; each new concept narrated in 1 line on first use.
11. `scripts/check-fase3.sh` passes in CI on the new prompts and fails if an anchor term is removed.
