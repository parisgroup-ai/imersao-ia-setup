# Design: Imersão Process — Idea → Full App, end to end

**Date:** 2026-06-07
**Status:** Approved (pending spec review)
**Repo:** `imersao-setup` (the `imersao` Claude Code plugin + docs)

## 1. Problem

The imersão (bootcamp) needs a repeatable, student-facing pipeline that takes a raw
idea all the way to a working, end-to-end application, while teaching disciplined
AI-assisted development. Today the `imersao` plugin ships ~49 skills but is **missing
the methodology backbone** (brainstorming, plan-writing, plan-execution, TDD,
finishing) and has **no orchestration** that strings idea → PRD → prototype →
implementation together. Students also have no agnostic, public prototyping layer.

## 2. Goals / Non-goals

**Goals**
- One guided pipeline, three explicit phases, driven by an autonomous `goal` engine
  with exactly two human gates.
- Fully **agnostic and public** — no private ParisGroup packages required by students.
- Prototyping via the **original public Design OS** (`buildermethods/design-os`).
- Implementation lands on a **public, full-stack default**: Next.js + Tailwind +
  shadcn/ui + Drizzle + **Postgres in Docker from day one**.
- Deliver both a **process playbook (doc)** and the **slash commands** that run it.

**Non-goals**
- Not using the ParisGroup Design OS fork (PageShell-coupled, private).
- Not using pg-baseline `goal`/`new-product` (PG-coupled).
- Not changing the installer (the plugin is already user-global; students update via
  `claude plugin update imersao`).
- Not deploying to production (local end-to-end is the finish line for the bootcamp).

## 3. Decisions (locked with the operator)

| Topic | Decision |
|---|---|
| Design OS source | **Original public** `buildermethods/design-os` (clone + `npm run dev` → :3000) |
| Output stack | **Public agnostic**: Next.js (App Router) + Tailwind + shadcn/ui + Drizzle + Postgres/Docker |
| Deliverable | **Both** — doc (`docs/PROCESSO-IMERSAO.md`) + commands in the plugin |
| Brainstorm ↔ PRD | brainstorming **produces** the PRD, which then feeds Design OS |
| Autonomy engine | **Agnostic `/pg-imersao-goal`** vendored in the plugin (chains the superpowers skills) |
| Repo layout | **Two repos**: `meu-projeto/` (app) and `meu-projeto-design/` (design-os clone) |
| Foundation skills | **Vendored clean** into the `imersao` plugin |
| Command naming | `pg-imersao-*` prefix |
| Scope of skills | must-have **+ the nice-to-have tier** (vendored clean) |

## 4. Architecture

### 4.1 The pipeline

```
FASE 1                 FASE 2                          FASE 3
/pg-imersao-prd   →     /pg-imersao-prototipo      →    /pg-imersao-implementar
brainstorming          Design OS (public clone)        implementation goal
   ↓                       ↓                              ↓
docs/PRD.md            export (React+Tailwind+specs)   working app
(in meu-projeto/)      (in meu-projeto-design/)        (in meu-projeto/)

        ░░░ engine: /pg-imersao-goal (autonomous, 2 human gates) ░░░
```

### 4.2 Two-repo layout on the student's machine

```
~/www/
  meu-projeto/            # the REAL app (Next.js). PRD.md lives here. Implementation happens here.
    docs/PRD.md
    docker-compose.yml    # Postgres 16 (added in Fase 3, Task 1)
    ...
  meu-projeto-design/     # clone of buildermethods/design-os. Prototype only. localhost:3000.
    export/               # handoff produced by Design OS /export
```

The export is **ported** from `meu-projeto-design/export/` into `meu-projeto/` during
Fase 3. The two repos never share dependencies.

### 4.3 The engine: `/pg-imersao-goal`

An agnostic orchestrator (skill + command) that auto-advances through the superpowers
chain and stops at exactly two human gates:

```
brainstorming ──[GATE 1: design approved]──▶ writing-plans ──▶ executing-plans ──[GATE 2: integration]──▶ finishing-a-development-branch
```

- No pg-baseline coupling: **no** `gf`/graphify, `roadmap`, `tasknotes`/`tn`, or
  `commit-discipline` references. Commit mechanics are inline and stack-generic.
- Free-text objective only (no roadmap persistence).
- The two phase commands below are **playbooks** layered on this engine.

## 5. Components (the four commands)

All live under `plugins/imersao/commands/`. Claude Code auto-discovers `commands/`.

### 5.1 `/pg-imersao-prd` — Fase 1 (idea → PRD)
- **Precondition:** student is inside the app repo `meu-projeto/` (command offers to
  `git init` one if absent).
- **Does:** invokes the vendored `brainstorming` skill in a guided, bootcamp-friendly
  dialogue (problem, target user, jobs-to-be-done, MVP scope in/out, core
  screens/sections, initial data shape, success criteria).
- **Output:** `meu-projeto/docs/PRD.md` — the single source of truth.
- **Gate:** design approval (brainstorming hard-gate). Commits the PRD.

### 5.2 `/pg-imersao-prototipo` — Fase 2 (PRD → prototype)
- **Precondition:** `meu-projeto/docs/PRD.md` exists.
- **Design OS bootstrap:** checks for `../meu-projeto-design`. If missing, prints the
  exact setup (verbatim from upstream):
  ```
  git clone https://github.com/buildermethods/design-os.git ../meu-projeto-design
  cd ../meu-projeto-design && git remote remove origin && npm install && npm run dev   # http://localhost:3000
  ```
- **Does:** loads the PRD and drives the Design OS slash commands autonomously, in
  order: `/product-vision` (seeded by the PRD) → `/product-roadmap` → data model →
  `/design-tokens` → `/design-shell` → `/design-screen` (per section) → `/sample-data`.
- **Gate (the only one here):** student opens `localhost:3000`, reviews the **live
  prototype**, and **adjusts** in natural language → command re-runs `/design-screen`
  for the affected screens. Loop until the student approves.
- **Output:** runs the Design OS `/export` → handoff bundle (real React+Tailwind
  components + specs) in `meu-projeto-design/export/`.

### 5.3 `/pg-imersao-implementar` — Fase 3 (export + PRD → working app)
- **Precondition:** Design OS export exists + `docs/PRD.md`.
- **Does:** returns to `meu-projeto/`, then fires
  `/pg-imersao-goal "implement the app per docs/PRD.md and the Design OS export at <path>"`.
- **The goal then:**
  1. **brainstorming** — already satisfied; the PRD is treated as the approved spec.
  2. **writing-plans** — decomposes into TDD tasks. **Task 1 = scaffold**:
     `create-next-app` (App Router, TS) + Tailwind + shadcn/ui + Drizzle +
     `docker-compose.yml` (Postgres 16) + `.env.example` + first migration + a
     `/api/health` route. **DB up via `docker compose up -d` before any feature work.**
     Subsequent tasks: port exported components section by section, wire data with
     Drizzle, add route handlers / server actions, write tests.
  3. **executing-plans** — per-task TDD (Red → Green → Verify → Commit), chaining test
     failures into `systematic-debugging` (3-strike pause for instructor help).
  4. **finishing-a-development-branch** — run tests, commit / open PR.
- **Gates:** plan-implicit approval + final integration.
- **Output:** app running locally end to end (`docker compose up -d` + `npm run dev`),
  Postgres in Docker, easy to tweak.

### 5.4 `/pg-imersao-goal` — the engine (see §4.3)

## 6. Foundation skills to vendor (clean) into `plugins/imersao/skills/`

**Must-have (process backbone, required by the pipeline):**
`brainstorming`, `writing-plans`, `executing-plans`, `finishing-a-development-branch`,
`test-driven-development`, `systematic-debugging`, `subagent-driven-development`,
`verification-before-completion`.

**Nice-to-have (included per operator request):**
`design-usabilidade`, `design-auditoria`, `impeccable`, `test-rigor-audit`,
`repo-cleanup`, `find-skills`, `pr-lifecycle`, `spell-check-pt-en`, `prototype-first`.

**Vendoring rules**
- Prefer the **superpowers upstream** for the must-have set (already agnostic).
- For pg-baseline-only skills (e.g. `impeccable`, `design-usabilidade`, `repo-cleanup`,
  `pr-lifecycle`, `test-rigor-audit`, `prototype-first`), **strip PG coupling** before
  vendoring: replace `gf`/graphify references with grep fallbacks, drop `/code-review`,
  `tn`/TaskNotes, `roadmap`, and `devkit` mentions; keep stack-generic guidance only.
- `prototype-first` is adapted to point at the **public** Design OS clone flow.

## 7. Data flow

```
idea ──(brainstorming)──▶ docs/PRD.md ──(seed)──▶ Design OS commands
   ──▶ meu-projeto-design/export/{components,specs,tokens,sample-data}
   ──(port + /pg-imersao-goal)──▶ meu-projeto/{app, drizzle, docker-compose}
   ──▶ docker compose up -d && npm run dev  ▶ working app
```

PRD.md is the durable contract across all phases; the Design OS export is the design
contract; the goal turns both into code.

## 8. Error handling / failure modes

- **Design OS not installed** → Fase 2 prints exact clone/`npm run dev` commands and
  stops; never assumes the dev server is up.
- **Prototype mismatch** → student adjusts in natural language; command re-runs only the
  affected `/design-screen`. No silent regeneration of approved screens.
- **Test failures in Fase 3** → `systematic-debugging` 3-strike loop, then pauses for
  the instructor (documented in the playbook so instructors are ready).
- **Docker/Postgres not running** → Task 1 health route + a `docker compose up -d`
  precheck surface this immediately, before feature work.
- **Vendored-skill drift** → playbook documents a manual re-sync step from upstream.

## 9. Files changed in this repo

```
plugins/imersao/commands/                       NEW
  pg-imersao-goal.md
  pg-imersao-prd.md
  pg-imersao-prototipo.md
  pg-imersao-implementar.md
plugins/imersao/skills/                         NEW (vendored, cleaned)
  brainstorming/ writing-plans/ executing-plans/ finishing-a-development-branch/
  test-driven-development/ systematic-debugging/ subagent-driven-development/
  verification-before-completion/
  design-usabilidade/ design-auditoria/ impeccable/ test-rigor-audit/
  repo-cleanup/ find-skills/ pr-lifecycle/ spell-check-pt-en/ prototype-first/
docs/PROCESSO-IMERSAO.md                        NEW (PT-BR student/instructor playbook)
plugins/imersao/.claude-plugin/plugin.json      version 1.0.0 → 1.1.0
plugins/imersao/README.md, README.md            updated (new commands + flow)
```

Installer (`instalar_imersao.sh`): **unchanged**. Students get everything via
`claude plugin update imersao`.

## 10. Testing strategy

- `scripts/validate-skills.sh` must pass for every new/vendored skill (frontmatter +
  schema in `schema/skill-schema.yml`).
- Lint the new command markdown (shellcheck/markdown checks already in CI).
- Manual dry-run of each command's instructions against a throwaway `meu-projeto/`:
  PRD generated → Design OS reachable → goal scaffolds Next+Drizzle+Docker and `docker
  compose up -d` brings Postgres up with a green `/api/health`.
- Validate that vendored skills carry **no** PG-coupled references (grep gate for `gf `,
  `graphify`, `tasknotes`, `roadmap`, `pageshell`, `railway`).

## 11. Open risks

- Manual re-sync burden for vendored skills (accepted; documented).
- Upstream Design OS command names may differ slightly from the PG fork; confirm the
  exact command set by inspecting the cloned repo's `.claude/commands/` during build.
- `create-next-app` interactivity in an automated goal — Task 1 must use the
  non-interactive flags so the scaffold runs unattended.
