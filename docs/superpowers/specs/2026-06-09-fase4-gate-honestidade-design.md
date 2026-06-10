# Fase 4 — Pre-Publish Honesty Gate (SP4) — Design

- **Date:** 2026-06-09
- **Status:** approved (GATE 1)
- **Objective:** free-text /goal — "Sub-projeto 4 — gate de honestidade pré-publicar"
- **Predecessor:** `2026-06-09-fase3-real-api-key-design.md` (SP3, v1.8.0) — produces the
  artifact this gate consumes (`docs/o-que-e-real.md` in the student's app).

## 1. Problem

SP3 made Fase 3 honest at **build time**: external capabilities are real or explicitly
demo (badge on screen), and the engine writes `docs/o-que-e-real.md` — a plain-PT-BR
table of "funcionalidade → real/demonstração → o que falta pra ativar".

Fase 4 (`pg-imersao-publicar`) does not consume that record. Today the demo state is only
mentioned in passing inside the Railway Variables step. A student can push to GitHub and
generate a public URL without ever seeing a consolidated, honest picture of what they are
about to publish. The owner's E2E feedback ("tá tudo mocado e não me avisou") is solved at
build time but not re-asserted at the moment that actually matters most: going public.

## 2. Decisions (locked at GATE 1)

| # | Decision | Choice |
|---|---|---|
| D1 | Gate position | **Step 0 of Fase 4, before the GitHub push.** Nothing leaves the machine before the student sees the honest picture and consents. The "warn BEFORE" principle stays absolute, not conditional on repo privacy. |
| D2 | Trust vs verify | **Light verification (record × reality).** The gate cross-checks the record against cheap signals; divergence → fix the record, tell the student. This is what makes it an honesty gate rather than a display step. |
| D3 | Missing record | **Reconstruct by scanning the app.** Apps built pre-1.8.0 (or with the file deleted) get the record written on the spot; Fase 4 never blocks on a missing file. |
| D4 | Demo semantics | **Informed consent, 3 exits.** Demo never blocks publishing (consistent with SP3's D4: badge'd demo is a legitimate, publishable state) — it only requires a conscious choice. |

## 3. The gate — Step 0 of `pg-imersao-publicar`

Three movements, before section "1. Guardar o código no GitHub":

### 3.1 Read (or reconstruct)

Read `docs/o-que-e-real.md` in the student's app. If absent, reconstruct it by scanning:

- `.env` / `.env.example` for external-service keys (e.g. `ANTHROPIC_API_KEY`, Stripe keys);
- `package.json` for `@anthropic-ai/sdk` (and analogous SDKs) + an AI module (e.g. `lib/ai.ts`);
- source markers of "modo demonstração" (the badge / `demo: true` fallback from SP3's pattern).

Write the reconstructed record immediately, narrate in 1 line ("anotei o que está de
verdade e o que está em demonstração"). An app with no external capabilities yields a
1-line record ("tudo aqui é construído no próprio app — nada depende de serviço de fora").

### 3.2 Verify (record × reality, cheap)

- Row says **real** but the key is missing from `.env` → in practice it's demo/broken:
  fix the row to demonstração (or "quebrado — falta a chave") and tell the student.
- Row says **demonstração** but the key exists in `.env` → likely already real: confirm
  with the student, fix the row.
- **Never echo the key's value** — presence checks only (same invariant as SP3).
- No API calls — Fase 3 already validated the key; the gate checks presence, not validity.

### 3.3 Present + consent

- **Everything real** → 1 confirmation line ("tudo que vai pro ar aqui é de verdade ✅")
  and proceed with **no extra pause** (SP3's "zero fricção nova" principle).
- **Something in demo** → short table (funcionalidade → estado) + one question, 3 exits:
  1. **Publicar assim mesmo** — demo goes live with the on-screen badge; legitimate.
  2. **Ativar a chave agora** — same contract as Fase 3 (paste existing key or guided
     creation ~5 min via console.anthropic.com); then the row flips to real.
  3. **Segurar a publicação** — stop cleanly; nothing was pushed.

## 4. Downstream effects inside Fase 4

- The Railway Variables step (current item 5 of section 2) **inherits the Step 0
  decision** instead of re-discovering state: real → key goes into Railway Variables;
  demo → narrate clearly that the live app stays in demonstração (with the badge) until
  the key is added there too.
- **Post-deploy record update:** after the public URL works, append/update one line in
  `docs/o-que-e-real.md` — live URL + date + the live state (real/demonstração no ar).
  The record stays the source of truth after publishing.

## 5. Mechanism

Same as SP1/SP3: prompt rewrite only — no code templates in this repo.

- `plugins/imersao/commands/pg-imersao-publicar.md`: new Step 0 section + narração row
  ("registro de honestidade" in 1 line) + Variables step inherits Step 0 + post-deploy
  record update.
- `plugins/imersao/commands/pg-imersao-start.md`: 1 small touch — Fase 4 description
  mentions the honest check before going live.
- `docs/PROCESSO-IMERSAO.md`: Fase 4 section gains the "antes de publicar, a
  honestidade" paragraph.

## 6. Guard + CI

`scripts/check-fase4.sh` — presence-only invariant guard, same idiom as
`check-fase1.sh` / `check-fase3.sh` (`set -uo pipefail`, `grep -qiE` helpers, exit count).

PUB (`pg-imersao-publicar.md`) invariants:

1. `o-que-e-real\.md` — the gate reads/writes the record
2. `[Pp]asso 0` — the gate exists as Step 0, before GitHub
3. `reconstr|escanea` — missing-record reconstruction
4. `diverg` — record × reality verification
5. `publicar assim` — exit 1
6. `ativar .*chave|colar .*chave` — exit 2
7. `segurar` — exit 3
8. `nunca .*(ecoad|mostrad|exibid)|sem mostrar o valor` — key value never echoed
9. `no ar` post-deploy record update reference (`atualiz[a-z]* o registro|registro .*no ar`)
10. `selo` — demo-on-air keeps the badge language

START touch: `antes de (ir pro ar|publicar)` honesty mention.
PROCESSO touch: `honestidade` in the Fase 4 section.

CI: new step in `.github/workflows/validate.yml` after the Fase 3 step.

## 7. Acceptance criteria

- (a) App 100% real publishes with **no new pause** (1 confirmation line only).
- (b) App with demo gets the table + 3-exit question **before any push**.
- (c) Missing record is reconstructed on the spot — Fase 4 never blocks on absence.
- (d) Record × reality divergence is fixed in the record and narrated in plain PT-BR.
- (e) Key values never echoed/logged anywhere in the gate.
- (f) `scripts/check-fase4.sh` green locally and in CI.
- (g) Plugin version 1.9.0 + git tag + GitHub release.

## 8. Out of scope

- SP2 (Fase 2 screen coverage) — separate sub-project.
- Any change to Fase 3 / `pg-imersao-implementar.md`.
- Key validation via API call inside the gate (presence only).
- Centralized telemetry of real/demo states across students.
