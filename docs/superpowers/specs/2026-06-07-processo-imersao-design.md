# Design: Imersão Process — Idea → Full App, end to end

**Date:** 2026-06-07
**Status:** Approved 2026-06-07 · **Synced to shipped reality 2026-06-07** (plugin `1.2.1`) — see §0
**Repo:** `imersao-setup` (the `imersao` Claude Code plugin + docs)

## 0. Sync note (2026-06-07)

This spec was written as the *approved design* and then synced to what actually shipped
through plugin `1.2.1`. The body below now describes the **shipped** system; this section
records how it evolved from the original design so the provenance isn't lost.

| # | Originally designed | What shipped (and why) |
|---|---|---|
| 1 | **Four** commands (`prd`, `prototipo`, `implementar`, `goal`) | **Five** — added `pg-imersao-start`, a read-only **bússola** entry point ("👈 COMECE AQUI") that maps the 3 steps and points to the next one without executing any phase. Pedagogy: the student runs each phase by hand, on purpose. |
| 2 | Fase 1 **invokes the `brainstorming` skill** with a hard-gate | Fase 1 **forbids** the generic `brainstorming` skill (it's an engineering skill that proposes architecture and writes to a different path) and runs an **inline jargon-free dialogue** with a single "sim" confirmation. |
| 3 | Fase 2 implied a **two-session handoff** (student drives Design OS in its own surface) | Fase 2 **collapsed into one Claude session** — the app-session Claude reads the Design OS command files from `<design>/.claude/commands/` and executes them itself. The student never opens a 2nd Claude. |
| 4 | Fase 2 **prints setup commands and stops** | Fase 2 **auto-sets-up** Design OS (idempotent clone, install, detached `nohup` server, port discovery, HTTP health poll). The student pastes nothing. |
| 5 | No teaching layer described | **Narração didática** shipped as a cross-cutting layer: automate the plumbing, narrate the concept in one plain-PT-BR line, for a non-dev audience. |
| 6 | Docker check lived **only inside Task 1** (health route + `docker compose up -d`) | Fase 3 adds an **upfront `docker info` "blindado" pre-check** before the goal fires, with no raw daemon error and plain-PT "abra o Docker Desktop" guidance. |
| 7 | Skills inventory framed as **~49 baseline + 17 vendored** | The plugin actually ships **~74 skill directories**; the 17 are a process-backbone subset added on top of an already-broad curated library. |
| 8 | §10 promised a **PG-coupling grep-gate** and schema validation | Neither shipped — CI runs `validate-skills.sh` (frontmatter + folder-name parity only); `schema/skill-schema.yml` is unwired; standalone `railway-*`/`tasknotes` skills legitimately ship. |
| 9 | Installer **unchanged** | Installer **was** touched by the beginner-usability quick-wins (commit `76c99ff`). |
| 10 | Fase 1 = thin PRD (5 sections) via a short dialogue | Fase 1 folds in a deeper product-planning skill: ~6 essential questions (still jargon-free, derive-the-rest) producing a **richer 11-section product plan**, renamed to **`docs/plano-do-produto.md`** (also removes the "PRD" jargon leak the student used to see). |
| 11 | Finish line = app **local** (non-goal: no deploy) | Adds **Fase 4 `pg-imersao-publicar`**: push to GitHub + deploy to **Railway** (GitHub-connected, Postgres, migrate-on-deploy). Finish line is now a **live URL**. Onboarding updated: Claude Max **$200**, GitHub + Railway required, Codex/ChatGPT dropped from required steps. |

Version trail: `1.0.0` → `1.1.0` (pipeline ship) → `1.2.x` → `1.2.1` (bússola + narração + Fase-2 single-session collapse) → **`1.2.2`** (E2E hardening: real Design OS export path `product-plan/`, in-place scaffold, dev-server restart for new files, Fase-3 scaffold flags/`.env`/Postgres-readiness, start↔goal clarity) → `1.3.0` (Fase 1 upgraded to a richer product plan; artifact renamed `docs/plano-do-produto.md`) → **`1.4.0`** (Fase 4 deploy to Railway + onboarding for GitHub/Railway/Claude-$200). User-facing commands resolve under the plugin namespace as `/imersao:pg-imersao-*` (the bare `/pg-imersao-*` form does not resolve).

## 1. Problem

The imersão (bootcamp) needs a repeatable, student-facing pipeline that takes a raw
idea all the way to a working, end-to-end application, while teaching disciplined
AI-assisted development. The `imersao` plugin ships a broad curated skill library
(**~74 skills**, including the pre-existing `imersao-primeiros-passos` dia-1 onboarding
skill) but was **missing the methodology backbone** (brainstorming, plan-writing,
plan-execution, TDD, finishing) and had **no orchestration** that strings idea → PRD →
prototype → implementation together. Students also had no agnostic, public prototyping
layer.

> The new `pg-imersao-start` bússola (§5.0) and the older `imersao-primeiros-passos`
> skill are complementary entry points: the skill is a conversational dia-1 host
> triggered by natural language; the bússola is the explicit `/imersao:pg-imersao-start`
> 3-step compass.

## 2. Goals / Non-goals

**Goals**
- One guided pipeline, three explicit phases, driven by an autonomous `goal` engine
  with exactly two human gates.
- A non-executing **orientation/compass** entry-point command (the bússola) that maps
  the 3 steps without running them — the student runs each phase manually, by design.
- Fully **agnostic and public** — no private ParisGroup packages required by students.
- Prototyping via the **original public Design OS** (`buildermethods/design-os`).
- Implementation lands on a **public, full-stack default**: Next.js + Tailwind +
  shadcn/ui + Drizzle + **Postgres in Docker from day one**.
- A **narração didática** teaching layer cross-cutting every command: automate the
  plumbing, narrate the concept in one plain line (audience = non-dev product builders).
- Deliver both a **process playbook (doc)** and the **slash commands** that run it.
- Ship to production: a **Fase 4** deploys to **Railway** (GitHub-connected) so the finish
  line is a live URL, not just a local app.

**Non-goals**
- Not using the ParisGroup Design OS fork (PageShell-coupled, private).
- Not using pg-baseline `goal`/`new-product` (PG-coupled).
- ~~Not deploying to production~~ — **revised (1.4.0):** Fase 4 (`pg-imersao-publicar`)
  ships the app to Railway (GitHub-connected); a live URL is the finish line.

> Note: the original non-goal "not changing the installer" did **not** hold — the
> beginner-usability quick-wins (`76c99ff`) touched `instalar_imersao.sh`. Students
> still update the plugin via `claude plugin update imersao`.

## 3. Decisions (locked with the operator)

| Topic | Decision |
|---|---|
| Design OS source | **Original public** `buildermethods/design-os` (clone + `npm run dev` → :3000) |
| Output stack | **Public agnostic**: Next.js (App Router) + Tailwind + shadcn/ui + Drizzle + Postgres/Docker |
| Deliverable | **Both** — doc (`docs/PROCESSO-IMERSAO.md`) + commands in the plugin |
| Entry point | A non-executing **bússola** command (`pg-imersao-start`) is the documented "COMECE AQUI" |
| Fase 1 dialogue | **Inline guided dialogue**, NOT the `brainstorming` skill (deliberately suppressed) |
| Fase 2 session model | **Single Claude session** — the app-session Claude drives Design OS itself |
| Autonomy engine | **Agnostic `/imersao:pg-imersao-goal`** vendored in the plugin (chains the superpowers skills) |
| Repo layout | **Two repos**: `meu-projeto/` (app) and `<app-basename>-design/` (design-os clone) |
| Foundation skills | **Vendored clean** into the `imersao` plugin (17, on top of the existing library) |
| Command naming | `pg-imersao-*` prefix; resolves as `/imersao:pg-imersao-*` at runtime |
| Teaching layer | **Narração didática** — automate mechanics, narrate concept in 1 line; no extra gates |
| Scope of skills | must-have **+ the nice-to-have tier** (vendored clean) |

## 4. Architecture

### 4.1 The pipeline

```
        ░ bússola: /imersao:pg-imersao-start (read-only — maps the 3 steps, points to next, runs nothing) ░
                                   │
                                   ▼
FASE 1                 FASE 2                              FASE 3
/pg-imersao-prd   →     /pg-imersao-prototipo          →    /pg-imersao-implementar
inline dialogue        Design OS, SAME Claude session       implementation goal
(not the skill)        (Claude reads+runs its cmd files)        ↓
   ↓                       ↓                              working app
docs/plano-do-produto.md            export/  OR  design/product-plan*.zip
(in meu-projeto/)      (in <app>-design/)                (in meu-projeto/)

        ░░░ engine: /imersao:pg-imersao-goal (autonomous, exactly 2 human gates) ░░░
```

### 4.2 Two-repo layout on the student's machine

```
~/www/
  meu-projeto/            # the REAL app (Next.js). plano-do-produto.md lives here. Implementation happens here.
    docs/plano-do-produto.md
    docker-compose.yml    # Postgres 16 (added in Fase 3, Task 1)
    ...
  <app-basename>-design/  # clone of buildermethods/design-os. Prototype only. localhost:3000 (or next free port).
    export/               # handoff produced by Design OS /export …
    design/product-plan*.zip   # … OR a zipped product-plan archive (either form is a valid export)
```

The design clone dir is **derived from the app folder name** (`DESIGN_DIR="../$(basename "$PWD")-design"`),
not a literal `meu-projeto-design`. Commands keep cwd anchored in the app repo the whole
time (`git -C` / `npm --prefix`, never a bare `cd`), and the bússola guards against being
run from inside the `-design` folder. The export is **ported** from the design clone into
`meu-projeto/` during Fase 3. The two repos never share dependencies.

### 4.3 The engine: `/imersao:pg-imersao-goal`

An agnostic orchestrator (skill + command) that auto-advances through the superpowers
chain and stops at exactly two human gates, shipped as an explicit **4-etapas contract**
with per-step auto-advance termination conditions:

```
brainstorming ──[GATE 1: design approved]──▶ writing-plans ──▶ executing-plans ──[GATE 2: integration]──▶ finishing-a-development-branch
   (advance when plan saved)          (advance when all tasks done + committed)
```

- No pg-baseline coupling: **no** `gf`/graphify, `roadmap`, `tasknotes`/`tn`, or
  `commit-discipline` references (the only `roadmap` mention is an explicit *negation*:
  "Não há roadmap, backlog ou persistência"). Commit mechanics are inline and
  stack-generic (git puro, Conventional Commits, explicit staging, no `--no-verify`).
- Free-text objective only (no roadmap persistence).
- Per-task TDD failures chain into a 3-strike `systematic-debugging` pause.
- The phase commands below are **playbooks** layered on this engine.

### 4.4 Narração didática (cross-cutting teaching layer)

Every phase command automates the plumbing but **narrates the concept in one plain-PT-BR
line** the first time it appears — the audience is non-dev product builders. Concretely:

- Each command carries a small **concept glossary** (e.g. Fase 1: idea→documento; Fase 3:
  app = 3 partes, banco de dados, migration, Docker, rodar local; engine: commit, teste,
  frontend/backend) narrated once, not re-explained.
- A **banned-vocabulary** rule in user-facing copy (never say "PRD", "spec", "hard-gate",
  "JTBD", "MVP", "data shape", "commit", "branch" to the student; the PRD is called "o
  documento do projeto").
- Narration is **informational — it never adds a human gate**. The pipeline still has
  exactly **2** gates. TDD's red/green cycle runs behind the scenes ("o aluno não assiste
  ao ciclo vermelho-verde"); the student sees only narrated results.

## 5. Components (the six commands)

All live under `plugins/imersao/commands/`. Claude Code auto-discovers `commands/` and
namespaces them as `/imersao:pg-imersao-*`.

### 5.0 `/pg-imersao-start` — the bússola (entry point, read-only)

- **Role:** "Você é uma bússola, não um piloto automático." The documented starting
  command ("👈 COMECE AQUI"). It **never executes a phase** — it only orients.
- **Does:** (1) detects state via shell probes — `PRD` = `docs/plano-do-produto.md` exists; `EXPORT`
  = `$DESIGN_DIR/export` dir **or** `$DESIGN_DIR/design/product-plan*.zip`; `APP` =
  `package.json` contains `"next"`; (2) always prints the 3-step map (DEFINIR → DESENHAR
  → CONSTRUIR); (3) emits the next concrete step from a 4-row state table; (4) explains
  in one line *why* that order (reinforces the methodology).
- **Guards:** if run inside a `*-design` folder, tells the student to `cd` back to the app.
- **Resumable:** re-running it re-detects state and says where the student left off.
- **Does NOT:** invoke `/pg-imersao-prd|-prototipo|-implementar` itself — it points; the
  student types. This is deliberate pedagogy ("é assim que ele aprende a lógica").

### 5.1 `/pg-imersao-prd` — Fase 1 (idea → plano do produto)
- **Precondition:** student is inside the app repo `meu-projeto/`. The command silently
  runs `git init` *and* backfills a default git `user.name`/`user.email` if missing (so a
  later commit won't error), surfacing only a plain "pasta preparada" message — it
  auto-prepares, it does not "offer".
- **Does:** conducts a short, beginner-friendly **inline dialogue** — explicitly **NOT**
  the generic `brainstorming` skill (suppressed: it produces engineering/architecture
  output). Claude asks ~6 essential questions one at a time (idea+problem, who uses it/roles,
  3–6 core screens/areas, key actions + business rules, login/external deps, what to defer)
  and **derives/proposes** the rest (user flows, empty/error states, data relationships,
  success criteria). Runs jargon-free (banned-words list incl. "PRD", "MVP", "persona"; the
  artifact is "o plano do produto" to the student). Folds in a product-planning skill so the
  output is rich enough to seed Design OS (Fase 2) and the build (Fase 3).
- **Output:** `meu-projeto/docs/plano-do-produto.md` — a **richer 11-section product plan**
  (vision, users/roles, prioritized features, user flows incl. empty/error states, screen
  map, data, access, external deps, business rules, phased delivery, open questions). The
  single source of truth for Fases 2–3.
- **Gate:** a single inline plain-language confirmation (student replies "sim" to a bullet
  summary) — *not* a brainstorming hard-gate, and explicitly only one approval point
  ("Não crie um segundo ponto de revisão depois"). Then silently commits `docs/plano-do-produto.md`.
- **Handoff:** closes with a benefit-framed human handoff pointing the student to
  `/imersao:pg-imersao-prototipo` via the `/` picker (no command memorization).

### 5.2 `/pg-imersao-prototipo` — Fase 2 (PRD → prototype)
- **Precondition:** `meu-projeto/docs/plano-do-produto.md` exists.
- **Session model:** runs **entirely in the app's Claude session** — "Conduza o design —
  NESTA mesma sessão (NÃO abra um 2º Claude)". The app-session Claude drives Design OS by
  **reading the command files** under `$DESIGN_DIR/.claude/commands/` and executing their
  instructions itself, writing design artifacts into the design clone while keeping cwd in
  the app repo. The student never runs a Design OS slash command and never opens a second
  Claude; only the dev server runs as a separate process.
- **Auto-setup (the command runs it via Bash — the student pastes nothing):** derives
  `DESIGN_DIR="../$(basename "$PWD")-design"`; idempotent clone guard (handles
  already-cloned / partial-folder / absent → on a corrupt clone it aborts and tells the
  student to delete the folder); `npm --prefix` install only when `node_modules` is
  missing; copies the PRD in (`cp docs/plano-do-produto.md "$DESIGN_DIR/plano-do-produto.md"`); starts the server
  **detached** (`nohup … run dev > "$DESIGN_DIR/dev.log"`, PID at `$DESIGN_DIR/.dev-server.pid`);
  reads the **real port** from `dev.log` (3000 busy → 3001…); polls `curl` for HTTP 200
  (≈30 tries) and tails `dev.log` on failure. No `cd` is ever used.
- **Does (logical sequence, narrated one line each):** product vision (seeded by the PRD)
  → roadmap → data model → tokens → shell → screens (one per section) → sample data.
  Claude executes each step by reading the matching command file in the clone (resilient
  to upstream command-name drift) — not by invoking hardcoded slash-command names.
- **⚠ Blank-screen rule:** because Claude (not a separate Design OS session) authors the
  design files, it must follow the Design OS folder/section/manifest format **exactly** or
  the strict renderer shows a blank screen; mitigation is re-reading the corresponding
  command file in the clone before writing.
- **Gate (the only one here):** the student reviews and **adjusts in natural language,
  in-session** → the command re-runs only the affected screen. Never regenerate approved
  screens; loop until the student approves. (`localhost:<port>` remains the optional live
  preview.)
- **Output:** runs the Design OS `/export` → handoff bundle (real React+Tailwind
  components + specs). The command **verifies the actual path** — `$DESIGN_DIR/export/`
  **or** `$DESIGN_DIR/design/product-plan*.zip` — and reports it to the student.

### 5.3 `/pg-imersao-implementar` — Fase 3 (export + PRD → working app)
- **Precondition 1:** Design OS export exists (`export/` or `design/product-plan*.zip`) +
  `docs/plano-do-produto.md`. Works from `meu-projeto/` (the session never left it — there's no
  separate design session to "return" from).
- **Precondition 2 — Docker blindado:** runs `docker info` silently **before** firing the
  goal. OK → proceed. Fails → **never show the raw daemon error**; say in plain PT-BR "Pra
  essa parte eu preciso do Docker ligado. Abra o app Docker Desktop…" and only proceed once
  `docker info` responds OK. (This is distinct from, and earlier than, the in-plan Task 1
  health route + `docker compose up -d` step.)
- **Does:** fires
  `/imersao:pg-imersao-goal "implementar o app conforme docs/plano-do-produto.md e o export do Design OS em <path>"`.
- **The goal then:**
  1. **brainstorming** — already satisfied; the PRD is treated as the approved spec.
  2. **writing-plans** — decomposes into TDD tasks. **Task 1 = scaffold**:
     non-interactive `create-next-app` (App Router, TS) + Tailwind + shadcn/ui + Drizzle +
     `docker-compose.yml` (Postgres 16) + `.env.example` + first migration + a
     `/api/health` route. **DB up via `docker compose up -d` before any feature work.**
     Subsequent tasks: port exported components section by section, wire data with
     Drizzle, add route handlers / server actions, write tests.
  3. **executing-plans** — per-task TDD (Red → Green → Verify → Commit), chaining test
     failures into `systematic-debugging` (3-strike pause for instructor help).
  4. **finishing-a-development-branch** — run tests, commit / open PR.
- **Gates:** plan-implicit approval + final integration (delegated to the goal engine).
- **Output:** app running locally end to end (`docker compose up -d` + `npm run dev`),
  Postgres in Docker, easy to tweak.

### 5.4 `/pg-imersao-goal` — the engine
See §4.3 (4-etapas contract, exactly 2 gates, no PG coupling) and §4.4 (narração layer:
TDD runs behind the scenes; GATE 2 phrased as "salvar tudo no projeto / guardar pra
revisar depois" — never "merge / PR / discard").

### 5.5 `/pg-imersao-publicar` — Fase 4 (app local → live on Railway)
- **Precondition:** the app builds (`npm run build`); GitHub + Railway accounts exist.
- **Does:** (1) `gh auth login` if needed; (2) `gh repo create <app> --private --source=. --push`;
  (3) guides the student through the Railway dashboard (GitHub-connected): New Project →
  Deploy from GitHub repo → add a PostgreSQL service → set the app's `DATABASE_URL` to
  `${{Postgres.DATABASE_URL}}` → Pre-deploy Command `npx drizzle-kit migrate` → Generate
  Domain. Claude automates the git side; the Railway dashboard clicks are the student's,
  guided one at a time.
- **Output:** a public URL; every subsequent `git push` auto-redeploys.
- **Narração:** GitHub = code in the cloud; deploy = público; Railway = roda na nuvem;
  env var = config secreta.

## 6. Foundation skills vendored (clean) into `plugins/imersao/skills/`

The plugin already ships a **broad curated skill library (~74 skill directories)**. This
design **adds/cleans 17 process + nice-to-have skills on top of it** — it does not create
the directory from scratch.

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
  `pr-lifecycle`, `test-rigor-audit`, `prototype-first`), **strip PG coupling** in their
  *content* before vendoring: replace `gf`/graphify references with grep fallbacks, drop
  `/code-review`, `tn`/TaskNotes, `roadmap`, and `devkit` mentions; keep stack-generic
  guidance only.
- `prototype-first` is adapted to point at the **public** Design OS clone flow.

> The no-PG-coupling rule applies to the **content of the 17 vendored process skills**,
> not the directory at large: standalone curated skills named `railway-debug`,
> `railway-logs`, and `tasknotes` legitimately ship in the library and would trip a naive
> name-based grep.

## 7. Data flow

```
idea ──(inline dialogue)──▶ docs/plano-do-produto.md ──(copied into <app>-design/)──▶ Design OS commands (same session)
   ──▶ <app>-design/export/{components,specs,tokens,sample-data}   OR   <app>-design/design/product-plan*.zip
   ──(port + /imersao:pg-imersao-goal)──▶ meu-projeto/{app, drizzle, docker-compose}
   ──▶ docker compose up -d && npm run dev  ▶ working app
```

plano-do-produto.md is the durable contract across all phases; the Design OS export (directory **or**
zip) is the design contract; the goal turns both into code.

## 8. Error handling / failure modes

- **Design OS not installed / partial clone** → Fase 2 **auto-installs and starts** the
  server itself (idempotent clone guard, detached `nohup` server, dynamic port discovery
  from `dev.log`, `curl` HTTP-200 health loop). On a corrupt/partial clone it aborts and
  tells the student to delete the folder; on server failure it tails `dev.log`. It never
  asks the student to paste setup blocks.
- **Dev-server lifecycle** → the server is detached (survives the Claude window closing),
  its PID is at `<app>-design/.dev-server.pid` (stop via `kill $(cat …)`), and a busy 3000
  falls back to the next free port.
- **Blank screen (renderer format)** → because the app-session Claude authors the Design
  OS files directly, it must follow the folder/section/manifest format exactly or the
  strict renderer blanks; mitigation is re-reading the matching command file before writing.
- **Prototype mismatch** → student adjusts in natural language, in-session; the command
  re-runs only the affected screen. No silent regeneration of approved screens.
- **Docker/Postgres not running** → an upfront `docker info` blindado pre-check
  (§5.3 Precondition 2) gates Fase 3 with plain-PT "open Docker Desktop" guidance, before
  the goal fires; plus the in-plan Task 1 `/api/health` route + `docker compose up -d`.
- **Test failures in Fase 3** → `systematic-debugging` 3-strike loop, then pauses for the
  instructor (documented in the playbook so instructors are ready).
- **Vendored-skill drift** → playbook documents a manual re-sync step from upstream.

## 9. Files changed in this repo

```
plugins/imersao/commands/                       NEW (six command files)
  pg-imersao-start.md       (the bússola — entry point)
  pg-imersao-prd.md
  pg-imersao-prototipo.md
  pg-imersao-implementar.md
  pg-imersao-publicar.md    (the deploy phase — Fase 4)
  pg-imersao-goal.md
plugins/imersao/skills/                         NEW/UPDATED — adds 17 cleaned skills on top
  brainstorming/ writing-plans/ executing-plans/ finishing-a-development-branch/   of the existing
  test-driven-development/ systematic-debugging/ subagent-driven-development/      curated library
  verification-before-completion/                                                  (~74 dirs total)
  design-usabilidade/ design-auditoria/ impeccable/ test-rigor-audit/
  repo-cleanup/ find-skills/ pr-lifecycle/ spell-check-pt-en/ prototype-first/
docs/PROCESSO-IMERSAO.md                        NEW (PT-BR student/instructor playbook)
plugins/imersao/.claude-plugin/plugin.json      version 1.0.0 → 1.4.0
plugins/imersao/README.md, README.md            updated (5 commands, bússola-first flow)
instalar_imersao.sh                             CHANGED by beginner-usability quick-wins (76c99ff)
```

Students update via `claude plugin update imersao`.

## 10. Testing strategy

- `scripts/validate-skills.sh` must pass for every new/vendored skill. **What it actually
  checks:** manifest JSON validity + per-skill frontmatter (`name:`/`description:` present,
  `name:` == folder name). It does **not** validate against `schema/skill-schema.yml`
  (that file ships but is currently unwired into the validator and CI — TODO).
- Lint the new command markdown (shellcheck/markdown checks already in CI).
- Manual dry-run of each command's instructions against a throwaway `meu-projeto/`:
  bússola orients → PRD generated → Design OS auto-set-up and reachable in-session →
  prototype adjusted → goal scaffolds Next+Drizzle+Docker and `docker compose up -d`
  brings Postgres up with a green `/api/health`.
- **No-PG-coupling check:** a *manual* review that the 17 vendored process skills carry no
  PG-coupled references in their **content** (`gf `, `graphify`, `tasknotes`, `roadmap`,
  `pageshell`, `railway`). This is **not** an automated grep-gate, and must exclude the
  legitimately-named standalone `railway-*` / `tasknotes` library skills.

## 11. Open / resolved risks

- **Manual re-sync burden** for vendored skills — *open* (accepted; documented).
- **Upstream Design OS command-name drift** — *mitigated by design*: Fase 2 reads the
  command files in `<app>-design/.claude/commands/` at runtime rather than hardcoding
  names, so drift is absorbed every run.
- **`create-next-app` interactivity in an automated goal** — *resolved*: the implementar
  command already mandates non-interactive scaffold flags.
- **Schema not enforced** — *new/open*: `schema/skill-schema.yml` exists but
  `validate-skills.sh` doesn't reference it; either wire it in or drop the file.
