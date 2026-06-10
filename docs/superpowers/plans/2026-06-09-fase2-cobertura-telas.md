# Fase 2 Full Screen Coverage (SP2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `/executing-plans` (sequential) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fase 2 covers ALL screens from the product plan — a `mapa-de-telas.md` artifact threads from setup (derived from the plan) through a constrained roadmap and per-section specs to a pre-export coverage gate that never hard-blocks (explicit student waiver, recorded in the plan).

**Architecture:** Prompt rewrite only — deliverables are command Markdown files in `plugins/imersao/commands/`, guarded by a presence-only bash invariant script in CI (same TDD adaptation as SP1/SP3/SP4: "failing test" = `scripts/check-fase2.sh` red before the rewrite, green after). No code templates in this repo; the Design OS clone is never modified.

**Tech Stack:** Bash (guard, mirrors `scripts/check-fase4.sh` idiom), Markdown prompts (PT-BR student-facing), GitHub Actions (`validate.yml`).

**Spec:** `docs/superpowers/specs/2026-06-09-fase2-cobertura-telas-design.md`

**Commit trailer (verbatim, every commit):** `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` — harness instruction overrides any skill template that names another model.

**Workflow mode:** direct-to-main (commits land on `main`; GATE 2 of the /goal arc is the push decision + v1.10.0 release).

---

### Task 1: Invariant guard `scripts/check-fase2.sh` (Red)

**Files:**
- Create: `scripts/check-fase2.sh`

#### Test (Red)

- [ ] **Step 1: Write the guard** — mirror the `check-fase4.sh` idiom exactly (`set -uo pipefail`, repo-root cd, `ok/err` + `grep -qiE` helpers, accent-free patterns, `exit "$fail"`):

```bash
#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE2 — invariantes da cobertura de telas no protótipo
#  (pg-imersao-prototipo + toques em start/processo).
#  Garante que TODA tela do plano vira uma tela demonstrável no
#  protótipo, com o mapa-de-telas.md de fio condutor e gate
#  pré-export que nunca trava (dispensa explícita do aluno).
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

PROTO="plugins/imersao/commands/pg-imersao-prototipo.md"
START="plugins/imersao/commands/pg-imersao-start.md"
PROC="docs/PROCESSO-IMERSAO.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasp() { grep -qiE "$1" "$PROTO"; }
hass() { grep -qiE "$1" "$START"; }
hasc() { grep -qiE "$1" "$PROC"; }

for f in "$PROTO" "$START" "$PROC"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 2 ($PROTO) =="
hasp 'mapa-de-telas\.md'          && ok "artefato mapa-de-telas.md existe"          || err "sem artefato mapa-de-telas.md"
hasp 'telas e navega'             && ok "mapa derivado de 'Telas e navegação'"      || err "mapa não deriva de 'Telas e navegação'"
hasp 'mapa vazio'                 && ok "nunca segue com mapa vazio (edge Fluxos)"  || err "sem guarda de mapa vazio"
hasp 'toda tela do mapa'          && ok "roadmap: toda tela atribuída a uma seção"  || err "product-vision sem restrição de cobertura"
hasp 'sem pular'                  && ok "loop percorre todas as seções"             || err "loop não explicita todas as seções"
hasp 'demonstr'                   && ok "cada tela demonstrável no navegador"       || err "sem exigência de tela demonstrável"
hasp 'tela nova'                  && ok "mapa vivo (tela nova na revisão entra)"    || err "sem mapa vivo na revisão"
hasp 'passo 0'                    && ok "gate de cobertura é Passo 0 do export"     || err "sem gate pré-export"
hasp 'desenhar agora'             && ok "faltante: oferece desenhar agora"          || err "sem oferta de desenhar na hora"
hasp 'dispensad'                  && ok "faltante: dispensa explícita registrada"   || err "sem caminho de dispensa explícita"
hasp 'em aberto / futuro'         && ok "dispensa anotada no plano do produto"      || err "dispensa não volta pro plano"
hasp 'sem pausa extra'            && ok "100% coberto passa sem fricção"            || err "sem regra de zero fricção"

echo ""
echo "== Toque na bússola ($START) =="
hass 'todas as telas do plano'    && ok "bússola anuncia a cobertura"               || err "bússola não anuncia a cobertura"

echo "== Toque no guia do processo ($PROC) =="
hasc 'mapa de telas'              && ok "guia descreve o mapa de telas"             || err "guia não descreve o mapa de telas"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 2 OK"; else echo "✗ Fase 2 com problemas (veja acima)"; fi
exit "$fail"
```

- [ ] **Step 2: Run it — expect RED**

Run: `bash scripts/check-fase2.sh`
Expected: exit 1. Every PROTO invariant fails; START and PROC touches fail. If anything unexpectedly passes, confirm the match is a legitimate pre-existing anchor before proceeding (e.g., `demonstr` must NOT match the current file — verify with `grep -inE 'demonstr' plugins/imersao/commands/pg-imersao-prototipo.md`).

- [ ] **Step 3: Shellcheck**

Run: `shellcheck -S warning scripts/check-fase2.sh`
Expected: clean (exit 0).

#### Implement (Green)

No implementation in this task — the guard IS the failing test. Green comes from Tasks 2–3.

#### Verify

- [ ] **Step 4:** `bash scripts/check-fase2.sh; echo "exit=$?"` → prints `exit=1` with the expected ✗ lines (red for the right reason).

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase2-guard-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
test(fase2): invariant guard for full screen coverage

Presence-only guard (idiom of check-fase1/3/4): the prototype command must
derive a screen map from the plan's "Telas e navegação", constrain the
roadmap so every screen is assigned to a section, run the design loop over
all sections with each screen demonstrable, keep the map alive during
review, and gate the export on a coverage checklist with an explicit-waiver
path that writes back to the product plan. Red until the rewrite lands.
EOF
git add scripts/check-fase2.sh
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 2: Rewrite `pg-imersao-prototipo.md` — the screen map thread (Green for PROTO)

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-prototipo.md`

#### Test (Red)

Covered by Task 1 (guard is red on all PROTO invariants).

#### Implement (Green)

- [ ] **Step 1: Narração table** — add one row to the "Narração didática (Fase 2)" table, after the "Design OS" row:

```markdown
| mapa de telas | "O mapa de telas é a lista de tudo que você vai ver no protótipo — eu confiro no final que nenhuma tela do seu plano ficou de fora." |
```

- [ ] **Step 2: §1 Pré-condições — derive the map.** After the bullet `- Exija **\`docs/plano-do-produto.md\`**. Se faltar, peça \`/imersao:pg-imersao-prd\` antes e pare.`, insert a new bullet:

```markdown
- **Monte o mapa de telas** a partir da seção **"Telas e navegação"** do plano: uma linha
  por tela, status `pendente`. Plano **sem** essa seção? Derive um rascunho da seção
  "Fluxos" e confirme com o aluno em **uma** pergunta leve ("seu plano não listou as
  telas — pelo que entendi são essas: […]. Confere?"). **Nunca** siga com o mapa vazio.
  Narre o conceito em 1 linha na primeira vez (tabela acima).
```

- [ ] **Step 3: §2 — persist the map in the clone root.** After step 3 (`**Levar o PRD** pra dentro da pasta do design`), insert a new step 4 and renumber the old steps 4–6 to 5–7 (detached server → port discovery → open browser):

```markdown
4. **Gravar o mapa de telas** na **raiz do clone** — nunca dentro de `product/` ou `src/`
   (o renderizador não pode tropeçar nele). Escreva `$DESIGN_DIR/mapa-de-telas.md`:

   ```markdown
   # Mapa de telas — <nome do produto>

   | # | Tela (do plano) | Seção no protótipo | Status |
   |---|---|---|---|
   | 1 | <tela 1> | (a definir) | pendente |
   ```

   `Status`: `pendente` → `desenhada` → ou `dispensada (<motivo do aluno>)`. O arquivo
   sobrevive a queda de sessão — ao retomar, os status dizem onde o design parou.
```

- [ ] **Step 4: §3 — totality marker in the canonical sequence.** In the "Sequência canônica" paragraph, replace `**por seção:**` with:

```markdown
**por seção — TODAS as seções do roadmap, sem pular nenhuma:**
```

- [ ] **Step 5: §3 — roadmap coverage constraint + per-section views.** Immediately after the "Sequência canônica" paragraph (before the blockquote about the server falling), add:

```markdown
**Cobertura do roadmap (na hora do `product-vision`):** passe o mapa de telas como
restrição explícita — **toda tela do mapa fica atribuída a uma seção** do roadmap (uma
seção pode agrupar mais de uma tela; o texto da seção nomeia as telas que cobre). Depois
de gerar `product/product-roadmap.md`, **confira tela a tela**: ficou alguma de fora?
Ajuste o roadmap **antes** de seguir. Atualize a coluna "Seção no protótipo" do mapa e
narre: "suas N telas do plano viraram M áreas — todas mapeadas ✓".

**Em cada seção:** a spec do `shape-section` **lista as telas do mapa** que a seção
cobre (são views obrigatórias), e o `design-screen` deixa **cada uma demonstrável** — o
aluno consegue ver cada tela no navegador (o Design OS suporta múltiplas views por
seção: lista, detalhe, carregando, boas-vindas…). Terminou a seção? Marque as telas
dela como `desenhada` no mapa.
```

- [ ] **Step 6: §4 — living map.** At the end of the §4 paragraph ("Revisar e ajustar"), after `Loop até o aluno aprovar.`, add:

```markdown
Aluno pediu uma **tela nova** durante a revisão? Acrescente a linha no mapa de telas — o
gate do export confere contra o mapa **atual**, não contra o plano original.
```

- [ ] **Step 7: §5 — coverage gate as Passo 0 of export.** At the top of "## 5. Exportar e seguir", before the `- Aprovado? Execute o **export**…` bullet, insert:

```markdown
- **Passo 0 — confira o mapa de telas (antes do export):** mostre o checklist
  `tela do plano → onde está → ✓/✗`. Tem `✗`? Ofereça **desenhar agora**, ou o aluno
  **dispensa** explicitamente ("essa não precisa") — registre `dispensada (<motivo>)` no
  mapa **e** acrescente 1 linha em **"Em aberto / futuro"** do `docs/plano-do-produto.md`
  do app (a Fase 3 não constrói tela dispensada). Tudo `✓`/`dispensada` → siga: mapa
  100% coberto passa **sem pausa extra** (a tabela aparece numa tela só, e segue).
```

#### Verify

- [ ] **Step 8:** `bash scripts/check-fase2.sh` → the "Invariantes da Fase 2" block is ALL green; START/PROC touches still red (planned partial green). Exit still 1.
- [ ] **Step 9:** `bash scripts/check-fase1.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh` → all still exit 0 (no anchors of other phases were touched).

#### Commit

- [ ] **Step 10:**

```bash
MSG_FILE=/tmp/msg-fase2-map-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
feat(fase2): screen map threads coverage from plan to export gate

E2E feedback SP2: the prototype covered 3 of the plan's 5 screens because
Design OS product-vision compresses the roadmap unconstrained. The command
now derives mapa-de-telas.md from the plan's "Telas e navegação" at setup
(persisted in the clone root, outside the renderer's paths), constrains the
roadmap so every screen is assigned to a section, requires section specs to
name their screens with each one demonstrable in the browser, keeps the map
alive when the student asks for new screens mid-review, and gates the export
on a coverage checklist - missing screens are designed on the spot or
explicitly waived, with the waiver written back to the product plan. Fully
covered prototypes pass with zero extra friction.
EOF
git add plugins/imersao/commands/pg-imersao-prototipo.md
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 3: Touches — bússola + guia do processo (full Green)

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-start.md`
- Modify: `docs/PROCESSO-IMERSAO.md`

#### Test (Red)

Covered by Task 1 (START/PROC touch invariants red).

#### Implement (Green)

- [ ] **Step 1: Bússola** — in the state table, the "Passo 2 — Desenhar" row currently reads:

```markdown
| sim | não | não | — | **Passo 2 — Desenhar** | "Seu projeto já está definido (`docs/plano-do-produto.md` ✅). Agora vamos **desenhar** as telas: digite `/` e escolha **imersao:pg-imersao-prototipo**." |
```

Replace with (extends the sentence inside the quotes):

```markdown
| sim | não | não | — | **Passo 2 — Desenhar** | "Seu projeto já está definido (`docs/plano-do-produto.md` ✅). Agora vamos **desenhar** as telas: digite `/` e escolha **imersao:pg-imersao-prototipo**. Ele desenha **todas as telas do plano** — nenhuma fica de fora." |
```

- [ ] **Step 2: Guia do processo** — in `docs/PROCESSO-IMERSAO.md` section "## Fase 2", after the paragraph ending in `Você só vai conversando e pedindo o que quiser.`, add:

```markdown
**Nenhuma tela fica de fora:** o Claude monta um **mapa de telas** a partir do seu plano
e confere, antes de exportar, que **cada tela do plano virou uma tela de verdade no
protótipo** — se faltar alguma, ele desenha na hora (ou você diz que não precisa, e isso
fica anotado no plano).
```

#### Verify

- [ ] **Step 3:** `bash scripts/check-fase2.sh` → ALL green, exit 0.
- [ ] **Step 4:** `bash scripts/check-fase1.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh` → all still exit 0.

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase2-touches-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
docs(fase2): compass and process guide announce full screen coverage

The Passo 2 row of the compass tells the student every plan screen gets
drawn, and the process guide's Fase 2 section describes the screen map and
the pre-export coverage check in plain language.
EOF
git add plugins/imersao/commands/pg-imersao-start.md docs/PROCESSO-IMERSAO.md
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 4: CI wiring

**Files:**
- Modify: `.github/workflows/validate.yml`

#### Test (Red)

`grep -q check-fase2 .github/workflows/validate.yml` → exit 1 (not wired).

#### Implement (Green)

- [ ] **Step 1:** add between the Fase 1 step and the Fase 3 step (keeps phase order):

```yaml
      - name: Invariantes da Fase 2 (cobertura de telas no protótipo)
        run: bash scripts/check-fase2.sh
```

#### Verify

- [ ] **Step 2:** `grep -q check-fase2 .github/workflows/validate.yml && echo wired` → prints `wired`. Shellcheck step's `scripts/*.sh` glob already covers the new guard.

#### Commit

- [ ] **Step 3:**

```bash
MSG_FILE=/tmp/msg-fase2-ci-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
ci(fase2): run the screen coverage invariant guard
EOF
git add .github/workflows/validate.yml
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 5: Version bump 1.10.0 + acceptance desk-check + memory

**Files:**
- Modify: `plugins/imersao/.claude-plugin/plugin.json` (version `1.9.0` → `1.10.0`)
- Modify: `~/.claude/projects/-Users-gustavoparis-www-imersao-setup/memory/design-os-publico.md` and `pipeline-4-fases.md` (not committed — outside repo)

#### Implement

- [ ] **Step 1:** bump `"version": "1.9.0"` → `"version": "1.10.0"` in `plugins/imersao/.claude-plugin/plugin.json`.
- [ ] **Step 2: Desk-check acceptance criteria** (spec §8) — grep each criterion's anchor in the shipped prompts and record the evidence in the session log: (a) map derivation + empty-map guard; (b) roadmap 100% assignment; (c) per-section views demonstrable; (d) "sem pular nenhuma"; (e) gate checklist + waiver + "Em aberto / futuro" write-back; (f) Visagem replay reasoning (Boas-vindas/Analisando would map to sections); (g) `check-fase2.sh` exit 0. Live student-session E2E is a carry-forward (same precedent as v1.8.0/v1.9.0).
- [ ] **Step 3: Memory** — add an SP2 bullet to `design-os-publico.md` (mapa-de-telas artifact + coverage gate, 1.10.0) and update `pipeline-4-fases.md` (plugin 1.10.0; E2E feedback now resolved 4/4).

#### Verify

- [ ] **Step 4:** `bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && bash scripts/check-fase2.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh` → all exit 0.

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase2-bump-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
chore(release): imersao 1.10.0 - Fase 2 com cobertura total de telas
EOF
git add plugins/imersao/.claude-plugin/plugin.json
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 6 (final): GATE 2 — push + tag + release

Invoke `/finishing-a-development-branch` (direct-to-main mode). GATE 2 is the push decision.

- [ ] **Step 1:** full local gate: `bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && bash scripts/check-fase2.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh && shellcheck -S warning instalar_imersao.sh scripts/*.sh` — all exit 0.
- [ ] **Step 2 (after operator approval):** `git push origin main`; monitor the `validate` workflow until green.
- [ ] **Step 3:** tag + release (repo convention since v1.6.1):

```bash
git tag v1.10.0 && git push origin v1.10.0
gh release create v1.10.0 --title "v1.10.0 — Fase 2 com cobertura total de telas" --notes-file /tmp/release-notes-v1.10.0.md
```

Release notes (PT-BR) summarize: mapa de telas derived from the plan, constrained roadmap, all sections designed with every screen demonstrable, living map during review, pre-export coverage gate with explicit waiver, guard in CI. Closes the E2E feedback 4/4.

---

Before claiming the plan complete, run `/verification-before-completion` against the final commit.
