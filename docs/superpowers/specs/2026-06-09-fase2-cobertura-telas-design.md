# Design: Fase 2 — Full Screen Coverage (mapa de telas)

**Date:** 2026-06-09
**Status:** Approved 2026-06-09 (brainstorming GATE 1) — proceeding to writing-plans
**Repo:** `imersao-setup` (the `imersao` Claude Code plugin)
**Scope:** Sub-project 2 of 4 from the E2E test feedback. This spec covers **only Fase 2** (`/imersao:pg-imersao-prototipo`). Closes the E2E feedback 4/4.

## 1. Problem

In the owner's E2E test (`~/www/imersao-teste`), `docs/plano-do-produto.md` §"Telas e
navegação" listed **5 screens** (Boas-vindas, Tirar/enviar foto, Analisando, Recomendação,
Ver em mim). The Design OS `product-vision` command compressed them into **3 roadmap
sections** (Capturar Foto, Recomendação, Provador Virtual) — "Boas-vindas" was swallowed
and "Analisando" dropped entirely. Owner verdict: *the prototype must cover ALL screens
from the plan, not 3.*

Three causes in the current `pg-imersao-prototipo.md` prompt:

1. `product-vision` generates the roadmap **unconstrained** — the plan's screen list is
   raw-notes input, not a coverage requirement.
2. No section spec declares **which plan screens it covers** — there is no screen→view
   mapping anywhere.
3. There is **no coverage verification before export** — §5 exports whatever exists.

## 2. Decisions locked in brainstorming (2026-06-09)

| # | Decision | Choice |
|---|---|---|
| D1 | Coverage criterion | **Every plan screen is a visible, demonstrable view** in the prototype — including transient states like "Analisando" (loading) and "Boas-vindas" (welcome). Screens MAY be grouped inside a Design OS section (sections support multiple views by design), but the student can SEE each one. 1:1 section-per-screen rejected (fights Design OS grain). |
| D2 | Pre-export gate behavior | **Show the map; the student may waive a screen.** Missing screen → design it now, OR the student explicitly says it's not needed; the waiver is recorded. The gate NEVER hard-blocks — same philosophy as the Fase 4 honesty gate. |
| D3 | Where coverage is enforced | **Thread-through (fio-a-fio):** the screen map is derived at setup, constrains the roadmap, is named in every section spec, and the pre-export gate is only the safety net. Gate-only auditing rejected (gaps discovered after visual approval = rework). |

## 3. The mechanism: mapa de telas

Four changes to `plugins/imersao/commands/pg-imersao-prototipo.md`:

### 3.1 §1 Pré-condições — derive the map
After requiring `docs/plano-do-produto.md`, extract the numbered screen list from
§"Telas e navegação" and write it to **`$DESIGN_DIR/mapa-de-telas.md`** (root of the
design clone, outside `product/` so the renderer never sees it). Persisting it means the
map survives session drops and the gate reads from disk, not conversation memory.

Format (one row per screen):

```markdown
# Mapa de telas — <produto>

| # | Tela (do plano) | Seção no protótipo | Status |
|---|---|---|---|
| 1 | Boas-vindas | (a definir) | pendente |
```

`Status` values: `pendente` → `desenhada` → (or) `dispensada (<motivo do aluno>)`.

**Edge — plan has no "Telas e navegação" section:** derive a draft list from §"Fluxos"
and confirm with the student in ONE light question ("seu plano não listou telas — pelo
que entendi são essas: […]. Confere?"). Never proceed with an empty map.

### 3.2 §3 — product-vision constrained by the map
When executing the Design OS `product-vision` command, pass the screen map as an explicit
constraint: **every screen in the map must be assigned to a roadmap section** (sections
may group screens; each section's roadmap description names the screens it covers).

After the roadmap is generated, **verify the mapping before proceeding**: any unassigned
screen → fix the roadmap now (edit `product/product-roadmap.md`), then update the map's
"Seção no protótipo" column. Narrate to the student in one line: *"suas N telas do plano
viraram M áreas — todas mapeadas ✓"*.

### 3.3 §3 — per-section loop covers ALL sections, each screen demonstrable
- The canonical per-section sequence (`shape-section` → `design-screen`) explicitly runs
  for **every section in the roadmap** (today the loop's totality is implicit).
- Each section's `spec.md` (via `shape-section`) **names the plan screens it covers** and
  treats them as required views.
- `design-screen` must make **each mapped screen demonstrable**: the student can see it in
  the browser (Design OS screens already support multiple views/states per section — e.g.
  a loading state and a welcome state are views the component can present and the section
  preview can show).
- After each section is designed, update `mapa-de-telas.md` statuses to `desenhada`.

### 3.4 §5 — coverage gate as Step 0 of export
Before running `export-product`, render the checklist from `mapa-de-telas.md`:

```
| Tela do plano | Onde está | Status |
| Boas-vindas | seção capturar-foto | ✓ |
| Analisando | — | ✗ faltando |
```

- Any `✗` → offer to design it now, OR the student explicitly waives it ("essa não
  precisa"). A waiver updates the map row to `dispensada (<motivo>)` AND appends one line
  to the app's `docs/plano-do-produto.md` §"Em aberto / futuro" (so Fase 3 doesn't build a
  screen the student dropped — the plan stays honest).
- All rows `✓`/`dispensada` → export proceeds. A prototype with 100% coverage passes
  **with zero extra friction** (the checklist is shown as a one-screen confirmation, not a
  pause) — same "zero friction when honest" rule as Fases 3-4.

**Living map:** when the student requests a new screen during the §4 review loop, the
agent adds a row to `mapa-de-telas.md`. The gate compares against the CURRENT map, not the
original plan snapshot.

## 4. Pedagogical guardrails (preserved)

- **Narrate the concept once, 1 line:** *"o mapa de telas é a lista do que você vai ver no
  protótipo — eu confiro no final que nenhuma ficou de fora."*
- The student sees the map **twice** (after the roadmap; at the gate) — digestible table,
  zero jargon. Plumbing (file paths, slugs, restarts) stays invisible.
- The student's burden does not grow: no new questions in the happy path; one light
  question only in the no-screens-section edge case; one consent only when a screen is
  missing at the gate.

## 5. CI invariant guard

**`scripts/check-fase2.sh`** — same pattern as `check-fase1.sh` / `check-fase3.sh` /
`check-fase4.sh`: greps `plugins/imersao/commands/pg-imersao-prototipo.md` for the
load-bearing invariants:

1. screen map derivation in §1 (mentions `mapa-de-telas.md` + "Telas e navegação");
2. product-vision coverage constraint (every screen assigned to a section);
3. explicit "all sections" totality in the per-section loop;
4. pre-export coverage gate with the explicit-waiver path (never hard-blocks);
5. waiver write-back to `plano-do-produto.md`.

Wire into the `validate` workflow next to the existing guards.

## 6. What changes (files)

| File | Change |
|---|---|
| `plugins/imersao/commands/pg-imersao-prototipo.md` | **Main rewrite** — §3.1-§3.4 above. |
| `scripts/check-fase2.sh` | **New** invariant guard (§5). |
| `.github/workflows/validate.yml` (or equivalent) | Run `check-fase2.sh`. |
| `docs/PROCESSO-IMERSAO.md` | Fase 2 description mentions the screen map + coverage gate. |
| `plugins/imersao/commands/pg-imersao-start.md` | Compass wording: Fase 2 = "DESENHAR — todas as telas do plano". |
| Memory (`design-os-publico`, `pipeline-4-fases`) | Record the map artifact + gate (after implementation). |

Plugin version: **minor bump → 1.10.0** + git tag + GitHub release, per repo convention.

## 7. Error handling / edge cases

- **Plan without "Telas e navegação"** → §3.1 edge: derive from Fluxos + one confirmation.
- **Roadmap generation drops a screen** → §3.2 verification fixes it before any design work.
- **Student waives a screen** → recorded in map + plan §"Em aberto / futuro"; never blocks.
- **Student adds a screen mid-review** → living map (§3.4); gate uses the current map.
- **Session drops mid-Fase 2** → map persists in `$DESIGN_DIR/mapa-de-telas.md`; on resume
  the statuses tell the agent where it stopped.
- **Design OS renderer quirks** (blank-screen gotcha) → unchanged §3 rules still apply;
  the map adds no files under `product/` or `src/`, so it cannot trigger the renderer.

## 8. Acceptance criteria (E2E manual — it's a prompt)

1. The map is derived from the plan at setup and written to `$DESIGN_DIR/mapa-de-telas.md`;
   a plan without "Telas e navegação" gets a derived list + one confirmation question.
2. The generated roadmap covers **100% of mapped screens** (every screen assigned).
3. Each section spec names its screens; **every screen is visible/demonstrable** in the
   prototype, including loading/welcome states.
4. The design loop runs through **all roadmap sections**.
5. The pre-export gate shows the checklist; a missing screen is designed on the spot or
   explicitly waived, and the waiver lands in the plan's "Em aberto / futuro".
6. Replay of the Visagem case: "Boas-vindas" and "Analisando" appear in the prototype.
7. `check-fase2.sh` passes in CI; a prompt edit that removes any §5 invariant fails it.
8. Student-facing copy stays PT-BR, jargon-free; "mapa de telas" narrated once in 1 line.

## 9. Out of scope

- Fase 3 changes — it consumes the export generically; waived screens simply aren't in it.
- Fase 1 changes — the plan's "Telas e navegação" section already exists (SP1 shipped).
- Any Design OS (buildermethods) source changes — all behavior lives in the imersão prompt
  that drives it.
