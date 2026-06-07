# Processo da Imersão — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Ship the imersão pipeline (`/pg-imersao-prd` → `/pg-imersao-prototipo` → `/pg-imersao-implementar` on the `/pg-imersao-goal` engine) as commands + vendored skills + a PT-BR playbook in the `imersao` plugin.

**Architecture:** Add `commands/` (4 files) and 16 vendored `skills/` to `plugins/imersao/`, plus `docs/PROCESSO-IMERSAO.md`. Must-have skills come clean from superpowers (strip `superpowers:` prefix); nice-to-have come from pg-baseline (strip PG coupling). `prototype-first` is rewritten for the public Design OS instead of copied.

**Tech stack (the app the pipeline produces):** Next.js (App Router) + Tailwind + shadcn/ui + Drizzle + Postgres in Docker.

**"Tests" for this content work** = `scripts/validate-skills.sh` (frontmatter + name=folder), a coupling grep-gate, and `bash -n`/markdown sanity. There is no unit test for prose; the validators are the gate.

**Coupling grep-gate (used by several tasks):**
```bash
# From repo root. MUST return nothing for a vendored skill dir.
grep -riE 'graphify|gf-[a-z]|\bgf \b|tasknotes|\btn\b|roadmap|pageshell|railway|/code-review|parisgroup|pg-baseline|devkit|designos|memory-bank' plugins/imersao/skills/<name>/
# NOTE: 'drizzle' is allowed (our stack). 'superpowers:' must also be gone from must-have skills.
```

---

### Task 1: Vendor the 8 must-have skills (clean from superpowers)

**Files:**
- Create: `plugins/imersao/skills/{brainstorming,writing-plans,executing-plans,finishing-a-development-branch,test-driven-development,systematic-debugging,subagent-driven-development,verification-before-completion}/`

- [ ] **Step 1: Copy the 8 dirs, dropping internal-only files**

```bash
SP=/Users/gustavoparis/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills
DST=plugins/imersao/skills
for s in brainstorming writing-plans executing-plans finishing-a-development-branch \
         test-driven-development systematic-debugging subagent-driven-development \
         verification-before-completion; do
  rm -rf "$DST/$s"; mkdir -p "$DST/$s"; cp -R "$SP/$s/." "$DST/$s/"
done
# Drop systematic-debugging internal noise (keep SKILL.md + the genuinely useful refs)
rm -f "$DST/systematic-debugging/CREATION-LOG.md" \
      "$DST/systematic-debugging/test-academic.md" \
      "$DST/systematic-debugging/test-pressure-"*.md
```

- [ ] **Step 2: Strip the `superpowers:` plugin prefix (refs become bare skill names)**

```bash
DST=plugins/imersao/skills
grep -rl 'superpowers:' "$DST" | while read -r f; do
  sed -i '' 's/superpowers://g' "$f"
done
```

- [ ] **Step 3: Soften references to skills we did NOT vendor**

In `writing-plans/SKILL.md`, `executing-plans/SKILL.md`, `subagent-driven-development/SKILL.md`: any remaining `using-git-worktrees` mention → reword to "an isolated git branch (or worktree)"; `requesting-code-review`/`receiving-code-review` → "review the work before integrating"; in `brainstorming/SKILL.md` the `elements-of-style:writing-clearly-and-concisely` line → "Write clearly and concisely." (Edit by hand; these are 1-2 lines each.)

- [ ] **Step 4: Verify frontmatter name == folder for all 8**

```bash
for s in brainstorming writing-plans executing-plans finishing-a-development-branch \
         test-driven-development systematic-debugging subagent-driven-development \
         verification-before-completion; do
  awk 'NR<8 && /^name:/' "plugins/imersao/skills/$s/SKILL.md"
done
```
Expected: prints `name: <s>` matching each folder. Fix any mismatch.

- [ ] **Step 5: Run validators**

```bash
bash scripts/validate-skills.sh
grep -rl 'superpowers:' plugins/imersao/skills && echo "LEAK" || echo "clean"
```
Expected: validate passes; second line prints `clean`.

- [ ] **Step 6: Commit**

```bash
git add plugins/imersao/skills
git commit -m "feat(imersao): vendor 8 must-have process skills (clean from superpowers)"
```

---

### Task 2: Vendor `impeccable` + `find-skills` (already clean)

**Files:** Create `plugins/imersao/skills/{impeccable,find-skills}/`

- [ ] **Step 1: Copy**

```bash
BASE=/Users/gustavoparis/.claude/plugins/marketplaces/parisgroup-ai/packages/plugin-baseline/skills
DST=plugins/imersao/skills
for s in impeccable find-skills; do
  rm -rf "$DST/$s"; mkdir -p "$DST/$s"; cp -R "$BASE/$s/." "$DST/$s/"
  rm -rf "$DST/$s/evals"   # drop pg eval harness if present
done
```

- [ ] **Step 2: Grep-gate (must be clean)**

```bash
for s in impeccable find-skills; do
  echo "== $s =="; grep -riE 'graphify|gf-[a-z]|tasknotes|\btn\b|roadmap|pageshell|railway|/code-review|parisgroup|pg-baseline|devkit|designos|memory-bank' "plugins/imersao/skills/$s/" || echo "clean"
done
```
Expected: both `clean`. If `find-skills` references a pg marketplace, reword to the generic skill-discovery flow.

- [ ] **Step 3: Validate + commit**

```bash
bash scripts/validate-skills.sh
git add plugins/imersao/skills && git commit -m "feat(imersao): vendor impeccable + find-skills"
```

---

### Task 3: Vendor + decouple the 6 coupled nice-to-have skills

Skills: `design-usabilidade`, `design-auditoria`, `impeccable`(done), `test-rigor-audit`, `repo-cleanup`, `pr-lifecycle`, `spell-check-pt-en`. (impeccable handled in Task 2.)

**Files:** Create `plugins/imersao/skills/{design-usabilidade,design-auditoria,test-rigor-audit,repo-cleanup,pr-lifecycle,spell-check-pt-en}/`

- [ ] **Step 1: Copy all 6, drop eval/pg-only refs dirs**

```bash
BASE=/Users/gustavoparis/.claude/plugins/marketplaces/parisgroup-ai/packages/plugin-baseline/skills
DST=plugins/imersao/skills
for s in design-usabilidade design-auditoria test-rigor-audit repo-cleanup pr-lifecycle spell-check-pt-en; do
  rm -rf "$DST/$s"; mkdir -p "$DST/$s"; cp -R "$BASE/$s/." "$DST/$s/"
  rm -rf "$DST/$s/evals"
done
```

- [ ] **Step 2: Decouple each (dispatch one cleaning agent per skill — see Execution)**

Per skill, rewrite so the grep-gate passes. Concrete substitutions:
  - `pageshell` / `@parisgroup-ai/*` examples → generic "your design system / component library" or "React + Tailwind + shadcn/ui".
  - `gf-investigate`/`gf-first`/`graphify`/`gf-analyze` (repo-cleanup) → "grep/ripgrep to find references (`grep -rn`)".
  - `/code-review` (pr-lifecycle) → "a code review pass".
  - `tasknotes`/`tn`/`roadmap`/`railway`/`devkit`/`pg-baseline` mentions → drop or replace with generic equivalent.
  - Keep `drizzle` (our stack).
  - Frontmatter `name:` must equal folder; keep `description` triggers (PT-BR + EN).

- [ ] **Step 3: Grep-gate each**

```bash
for s in design-usabilidade design-auditoria test-rigor-audit repo-cleanup pr-lifecycle spell-check-pt-en; do
  echo "== $s =="; grep -riE 'graphify|gf-[a-z]|tasknotes|\btn\b|roadmap|pageshell|railway|/code-review|parisgroup|pg-baseline|devkit|designos|memory-bank' "plugins/imersao/skills/$s/" || echo "clean"
done
```
Expected: all `clean`.

- [ ] **Step 4: Validate + commit**

```bash
bash scripts/validate-skills.sh
git add plugins/imersao/skills && git commit -m "feat(imersao): vendor + decouple 6 nice-to-have skills"
```

---

### Task 4: Author the agnostic `prototype-first` (public Design OS)

Instead of copying the 16×-designos-coupled pg version, write a fresh slim skill.

**Files:** Create `plugins/imersao/skills/prototype-first/SKILL.md`

- [ ] **Step 1:** Write `SKILL.md`: frontmatter `name: prototype-first`, description with PT-BR+EN triggers ("nova tela/página", "prototipar", "new screen/page", "redesign"). Body: before building UI production code, prototype first; route to the **public** Design OS (`git clone https://github.com/buildermethods/design-os.git ../<projeto>-design && npm install && npm run dev` → :3000) and the `/product-vision` flow, or to `frontend-design` for tiny UI. Self-skip on backend/CLI/library work. No PG references.
- [ ] **Step 2:** Grep-gate (allow `designos`? NO — use only the public `design-os` repo URL/name, not the `designos` CLI). Reword to avoid the `designos` token; reference the cloned `npm run dev` flow.
- [ ] **Step 3:** Validate + commit `feat(imersao): agnostic prototype-first for public Design OS`.

---

### Task 5: Author `/pg-imersao-goal` (the engine)

**Files:** Create `plugins/imersao/commands/pg-imersao-goal.md`

- [ ] **Step 1:** Frontmatter: `description: Orquestrador autônomo da imersão — encadeia brainstorming → writing-plans → executing-plans → finishing com 2 gates humanos.`, `argument-hint: "<objetivo>"`. Body instructs: take the free-text objective from `$ARGUMENTS`; drive the chain by invoking the vendored skills in order; auto-advance when each terminal condition is met (spec approved → plan written → all tasks committed); STOP at exactly 2 human gates (design approval inside brainstorming; final integration inside finishing). No gf/roadmap/tasknotes/commit-discipline. Commit mechanics inline, stack-generic.
- [ ] **Step 2:** Confirm command resolves: `ls plugins/imersao/commands/` and note expected invocation (verify whether Claude Code namespaces it as `/pg-imersao-goal` or `/imersao:pg-imersao-goal`; if namespaced and ugly, document the real invocation in the playbook).
- [ ] **Step 3:** Commit `feat(imersao): /pg-imersao-goal engine`.

---

### Task 6: Author the 3 phase commands

**Files:** Create `plugins/imersao/commands/{pg-imersao-prd,pg-imersao-prototipo,pg-imersao-implementar}.md`

- [ ] **Step 1: `pg-imersao-prd.md`** — description (PT-BR), body: ensure inside the app repo (`git init` if needed); invoke vendored `brainstorming`; guide dialogue (problema, usuário, JTBD, escopo MVP in/out, telas/seções, data shape inicial, critérios de sucesso); write `docs/PRD.md`; design-approval gate; commit the PRD.
- [ ] **Step 2: `pg-imersao-prototipo.md`** — body: require `docs/PRD.md`; check `../<projeto>-design`; if missing print the verbatim clone+`npm run dev` (:3000) setup; load PRD and drive Design OS commands in order (`/product-vision` seeded by PRD → roadmap → data → `/design-tokens` → `/design-shell` → `/design-screen` per section → `/sample-data`); single gate = student reviews live prototype and adjusts in natural language (re-run only affected `/design-screen`); finish with the Design OS `/export` → bundle in `../<projeto>-design/export/`.
- [ ] **Step 3: `pg-imersao-implementar.md`** — body: require export + `docs/PRD.md`; return to app repo; fire `/pg-imersao-goal "implement the app per docs/PRD.md and the Design OS export at <path>"`; specify Task 1 of the resulting plan = scaffold **Next.js (App Router, TS) + Tailwind + shadcn/ui + Drizzle + docker-compose Postgres 16 + .env.example + first migration + /api/health**, with `docker compose up -d` before feature work; subsequent tasks port exported components per section, wire Drizzle, add route handlers/server actions, tests.
- [ ] **Step 4:** Commit `feat(imersao): 3 phase commands (prd/prototipo/implementar)`.

---

### Task 7: PT-BR playbook `docs/PROCESSO-IMERSAO.md`

**Files:** Create `docs/PROCESSO-IMERSAO.md`

- [ ] **Step 1:** Write the student/instructor playbook (PT-BR): the 3 phases with exact commands, the two-repo layout, the Design OS clone+`npm run dev` steps, the Next+Drizzle+Docker Postgres scaffold, how to adjust the prototype, the 3-strike test-failure pause (instructor readiness), the manual vendored-skill re-sync note, and a "qual comando usar quando" quick map.
- [ ] **Step 2:** Commit `docs: playbook do processo da imersão (PT-BR)`.

---

### Task 8: Bump manifest + READMEs + final validation

**Files:** Modify `plugins/imersao/.claude-plugin/plugin.json`, `plugins/imersao/README.md`, `README.md`

- [ ] **Step 1:** `plugin.json` version `1.0.0` → `1.1.0`; refresh description to mention the pipeline.
- [ ] **Step 2:** Update both READMEs: new commands + the 3-phase flow + the new skills.
- [ ] **Step 3: Full validation**

```bash
bash scripts/validate-skills.sh
bash scripts/check.sh 2>/dev/null || true
ls plugins/imersao/commands plugins/imersao/skills
# coupling sweep across ALL vendored skills:
grep -riE 'graphify|gf-[a-z]|tasknotes|\btn\b|roadmap|pageshell|railway|/code-review|parisgroup-ai/(pageshell|pg-backend)|pg-baseline|devkit|designos' plugins/imersao/skills || echo "ALL CLEAN"
```
Expected: validate passes; `ALL CLEAN`.

- [ ] **Step 4:** Commit `chore(imersao): bump plugin 1.1.0 + docs for the pipeline`.

---

## Self-Review (spec coverage)

- Spec §5 commands → Tasks 4,5,6 ✅
- Spec §6 must-have skills → Task 1 ✅; nice-to-have → Tasks 2,3,4 ✅ (prototype-first rewritten, not copied — noted)
- Spec §5.3 Next+Drizzle+Docker scaffold → Task 6 Step 3 ✅
- Spec §9 files changed → Tasks 1-8 cover all ✅
- Spec §10 testing (validate-skills + coupling gate) → every task + Task 8 ✅
- Deviation logged: `prototype-first` is authored fresh (Task 4) rather than vendored, because the pg version is 16×-coupled to the private `designos` CLI and overlaps `/pg-imersao-prototipo`. Net skill count = 16 vendored + 1 authored = 17 as promised.
