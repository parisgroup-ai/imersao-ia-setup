# Fase 4 Pre-Publish Honesty Gate (SP4) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `/executing-plans` (sequential) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fase 4 gains a Step 0 honesty gate — before any push, the student sees the honest real/demo picture from `docs/o-que-e-real.md` (reconstructed by scanning when absent), the record is cross-checked against reality, and demo state requires informed consent (3 exits, never a block).

**Architecture:** Prompt rewrite only — deliverables are command Markdown files in `plugins/imersao/commands/`, guarded by a presence-only bash invariant script in CI (same TDD adaptation as SP1/SP3: "failing test" = `scripts/check-fase4.sh` red before the rewrite, green after). No code templates in this repo.

**Tech Stack:** Bash (guard, mirrors `scripts/check-fase3.sh` idiom), Markdown prompts (PT-BR student-facing), GitHub Actions (`validate.yml`).

**Spec:** `docs/superpowers/specs/2026-06-09-fase4-gate-honestidade-design.md`

**Commit trailer (verbatim, every commit):** `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` — harness instruction overrides any skill template that names another model.

**Workflow mode:** direct-to-main (commits land on `main`; GATE 2 of the /goal arc is the push decision + v1.9.0 release).

---

### Task 1: Invariant guard `scripts/check-fase4.sh` (Red)

**Files:**
- Create: `scripts/check-fase4.sh`

#### Test (Red)

- [ ] **Step 1: Write the guard** — mirror the `check-fase3.sh` idiom exactly (`set -uo pipefail`, repo-root cd, `ok/err` + `grep -qiE` helpers, `exit "$fail"`):

```bash
#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE4 — invariantes do gate de honestidade pré-publicar
#  (pg-imersao-publicar + toques em start/processo).
#  Garante que nada vai pro ar sem o aluno ver o quadro honesto
#  (real × demonstração) do docs/o-que-e-real.md.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

PUB="plugins/imersao/commands/pg-imersao-publicar.md"
START="plugins/imersao/commands/pg-imersao-start.md"
PROC="docs/PROCESSO-IMERSAO.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasu() { grep -qiE "$1" "$PUB"; }
hass() { grep -qiE "$1" "$START"; }
hasc() { grep -qiE "$1" "$PROC"; }

for f in "$PUB" "$START" "$PROC"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 4 ($PUB) =="
hasu 'o-que-e-real\.md'                     && ok "lê o registro o-que-e-real.md"      || err "não lê o registro o-que-e-real.md"
hasu 'passo 0'                              && ok "gate é o Passo 0 (antes do GitHub)" || err "sem Passo 0 antes do GitHub"
hasu 'reconstru|escanea'                    && ok "reconstrói registro ausente"        || err "não reconstrói registro ausente"
hasu 'diverg'                               && ok "verifica registro × realidade"      || err "sem verificação registro × realidade"
hasu 'publicar assim'                       && ok "saída 1: publicar assim mesmo"      || err "sem saída publicar-assim-mesmo"
hasu 'ativar a chave'                       && ok "saída 2: ativar a chave agora"      || err "sem saída ativar-a-chave"
hasu 'segurar'                              && ok "saída 3: segurar a publicação"      || err "sem saída segurar"
hasu 'nunca (mostre|ecoe).*(valor|chave)'   && ok "valor da chave nunca ecoado"        || err "não proíbe ecoar o valor da chave"
hasu 'herda'                                && ok "Variables herda a decisão do gate"  || err "Variables não herda a decisão do gate"
hasu 'atualiz[a-z]*.*registro'              && ok "registro atualizado pós-deploy"     || err "sem atualização pós-deploy do registro"
hasu 'selo'                                 && ok "demo no ar mantém o selo"           || err "sem linguagem do selo"

echo ""
echo "== Toque na bússola ($START) =="
hass 'antes de ir pro ar'                   && ok "bússola anuncia o gate"             || err "bússola não anuncia o gate"

echo "== Toque no guia do processo ($PROC) =="
hasc 'antes de publicar, a honestidade'     && ok "guia descreve o gate"               || err "guia não descreve o gate"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 4 OK"; else echo "✗ Fase 4 com problemas (veja acima)"; fi
exit "$fail"
```

- [ ] **Step 2: Run it — expect RED**

Run: `bash scripts/check-fase4.sh`
Expected: exit 1. PUB fails everything except `selo` (line exists in the current Variables step). START and PROC touches fail. If anything unexpectedly passes, confirm the match is a legitimate pre-existing anchor (like `selo`) before proceeding.

- [ ] **Step 3: Shellcheck**

Run: `shellcheck -S warning scripts/check-fase4.sh`
Expected: clean (exit 0).

#### Implement (Green)

No implementation in this task — the guard IS the failing test. Green comes from Tasks 2–3.

#### Verify

- [ ] **Step 4:** `bash scripts/check-fase4.sh; echo "exit=$?"` → prints `exit=1` with the expected ✗ lines (red for the right reason).

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase4-guard-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
test(fase4): invariant guard for the pre-publish honesty gate

Presence-only guard (idiom of check-fase1/3): the publish command must read
docs/o-que-e-real.md as a Step 0 gate before any push, reconstruct it when
absent, verify record vs reality, offer the 3 consent exits, never echo key
values, and update the record post-deploy. Red until the rewrite lands.
EOF
git add scripts/check-fase4.sh
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 2: Rewrite `pg-imersao-publicar.md` — the gate (Green for PUB)

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-publicar.md`

#### Test (Red)

Covered by Task 1 (guard is red on PUB invariants).

#### Implement (Green)

- [ ] **Step 1: Narração table** — add one row to the "Narração didática" table:

```markdown
| registro de honestidade | "É um arquivo no seu projeto (`docs/o-que-e-real.md`) que anota o que funciona de verdade e o que está em demonstração — a gente confere ele antes de publicar." |
```

- [ ] **Step 2: New Step 0 section** — insert between "## Pré-condições" and "## 1. Guardar o código no GitHub":

```markdown
## 0. Gate de honestidade — o que vai pro ar? (Passo 0, antes de qualquer push)

Antes de **qualquer coisa sair do computador**, mostre ao aluno o quadro honesto do app.

1. **Leia `docs/o-que-e-real.md`.** Se **não existir** (app construído por uma versão
   antiga da Fase 3, ou arquivo apagado), **reconstrua escaneando o app** — sem travar:
   - `.env` / `.env.example`: que chaves de serviço de fora existem (ex.: `ANTHROPIC_API_KEY`,
     chaves do Stripe)?
   - `package.json`: tem `@anthropic-ai/sdk` (ou SDK parecido)? Tem o módulo de IA (ex.: `lib/ai.ts`)?
   - código: tem marcador de **modo demonstração** (selo na tela / fallback de demonstração)?

   Escreva o registro na hora com o que encontrou e narre em 1 linha: "anotei o que está
   de verdade e o que está em demonstração". App sem nada de fora → registro de 1 linha
   ("tudo aqui é construído no próprio app — nada depende de serviço de fora").
2. **Verifique o registro contra a realidade** (checagens baratas;
   **nunca mostre nem ecoe o valor de nenhuma chave** — só presença):
   - linha diz **real** mas a chave não está no `.env` → na prática está em demonstração (ou
     quebrado): corrija a linha e avise o aluno;
   - linha diz **demonstração** mas a chave existe no `.env` → provavelmente já virou real:
     confirme com o aluno e corrija a linha.

   Divergência vira correção no registro + 1 frase em português simples — nunca log cru.
3. **Apresente e pergunte:**
   - **Tudo real** → 1 linha ("tudo que vai pro ar aqui é de verdade ✅") e siga direto pro
     GitHub — **zero pausa extra**.
   - **Tem demonstração** → mostre a tabela curta (funcionalidade → real/demonstração) e
     pergunte, com 3 saídas:
     1. **Publicar assim mesmo** — o app vai pro ar em demonstração, com o selo na tela.
        Totalmente legítimo.
     2. **Ativar a chave agora** — mesmo caminho da Fase 3: colar a que já tem no `.env`, ou
        criar guiado (~5 min em console.anthropic.com). Depois, atualize a linha pra real.
     3. **Segurar a publicação** — para aqui; nada foi enviado pra lugar nenhum.

> A decisão do aluno aqui **comanda o resto da fase**: o passo das Variables no Railway
> **herda** esse estado — não redescobre.
```

- [ ] **Step 3: Variables step inherits** — rewrite the current Railway step 5 opening so it references the gate. Replace the lead-in `**Se o app usa chave de IA (ou outro serviço de fora):**` with:

```markdown
5. **Chave de IA / serviço de fora — conforme decidido no Passo 0** (o gate de honestidade;
   este passo **herda** aquela decisão): se ficou **real**, "Ainda em **Variables**, clique
   em **New Variable** e crie **`ANTHROPIC_API_KEY`**, colando o **valor da sua chave**
   (aqui é o valor mesmo, não referência)." Narre o porquê: "o ar não lê o arquivo `.env`
   do seu computador — a chave precisa ser colocada lá também." Se ficou **modo
   demonstração**: diga com clareza que o app no ar fica em demonstração (com o selo) até
   ele colocar a chave — e tá tudo bem publicar assim.
```

- [ ] **Step 4: Post-deploy record update** — in "## 3. Confirmar no ar", after the victory line, add:

```markdown
- **Atualize o registro:** acrescente/ajuste 1 linha no `docs/o-que-e-real.md` com a URL
  pública, a data e o estado no ar (real ou demonstração) — e commite. O registro continua
  sendo a fonte da verdade depois de publicar.
```

#### Verify

- [ ] **Step 5:** `bash scripts/check-fase4.sh` → the "Invariantes da Fase 4" block is ALL green; START/PROC touches still red (planned partial green). Exit still 1.
- [ ] **Step 6:** `bash scripts/check-fase3.sh` → still green (the Variables rewrite must keep `ANTHROPIC_API_KEY` and `modo demonstração` anchors). Exit 0.

#### Commit

- [ ] **Step 7:**

```bash
MSG_FILE=/tmp/msg-fase4-gate-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
feat(fase4): pre-publish honesty gate as Step 0 of pg-imersao-publicar

Before anything leaves the machine, the student sees the honest real/demo
picture: the gate reads docs/o-que-e-real.md (reconstructing it by scanning
.env, package.json and demo markers when absent), cross-checks the record
against key presence (never the value), and asks for informed consent with
3 exits when something is in demo - publish as-is with the badge, activate
the key now (same contract as Fase 3), or hold. Fully-real apps pass with
zero new friction. The Railway Variables step now inherits the gate's
decision, and the record gets a post-deploy line (URL, date, live state).
EOF
git add plugins/imersao/commands/pg-imersao-publicar.md
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

- [ ] **Step 1: Bússola** — in the state table, the "Passo 4 — Publicar" row cell currently ends with `escolha **imersao:pg-imersao-publicar**."`. Extend the sentence inside the quotes:

```markdown
| sim | sim | sim | não | **Passo 4 — Publicar** | "Seu app já roda no seu computador ✅. Bora **colocar ele no ar**: digite `/` e escolha **imersao:pg-imersao-publicar**. E relaxa: **antes de ir pro ar**, ele te mostra o que é de verdade e o que está em demonstração — você dá o ok." |
```

- [ ] **Step 2: Guia do processo** — in `docs/PROCESSO-IMERSAO.md`, section "## Fase 4", after the intro paragraph ("Com o app rodando no seu computador…") add:

```markdown
**Antes de publicar, a honestidade:** nada sai do seu computador sem você ver o quadro
honesto do app — o Claude confere o `docs/o-que-e-real.md` (recria, se não existir),
checa se ele bate com a realidade e, se algo estiver em demonstração, pergunta: publicar
assim mesmo (com o selo), ativar a chave agora, ou segurar. App 100% real passa direto.
```

#### Verify

- [ ] **Step 3:** `bash scripts/check-fase4.sh` → ALL green, exit 0.
- [ ] **Step 4:** `bash scripts/check-fase1.sh && bash scripts/check-fase3.sh` → both still exit 0.

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase4-touches-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
docs(fase4): compass and process guide announce the honesty gate

The Passo 4 row of the compass tells the student the gate exists before
going live, and the process guide's Fase 4 section describes it in plain
language (read/reconstruct the record, verify, 3-exit consent).
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

`grep -q check-fase4 .github/workflows/validate.yml` → exit 1 (not wired).

#### Implement (Green)

- [ ] **Step 1:** add between the Fase 3 step and the Shellcheck step:

```yaml
      - name: Invariantes da Fase 4 (gate de honestidade pré-publicar)
        run: bash scripts/check-fase4.sh
```

#### Verify

- [ ] **Step 2:** `grep -q check-fase4 .github/workflows/validate.yml && echo wired` → prints `wired`. Shellcheck step's `scripts/*.sh` glob already covers the new guard.

#### Commit

- [ ] **Step 3:**

```bash
MSG_FILE=/tmp/msg-fase4-ci-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
ci(fase4): run the pre-publish honesty gate invariant guard
EOF
git add .github/workflows/validate.yml
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 5: Version bump 1.9.0 + acceptance desk-check + memory

**Files:**
- Modify: `plugins/imersao/.claude-plugin/plugin.json` (version `1.8.0` → `1.9.0`)
- Modify: `~/.claude/projects/-Users-gustavoparis-www-imersao-setup/memory/pipeline-4-fases.md` (not committed — outside repo)

#### Implement

- [ ] **Step 1:** bump `"version": "1.8.0"` → `"version": "1.9.0"` in `plugins/imersao/.claude-plugin/plugin.json`.
- [ ] **Step 2: Desk-check acceptance criteria** (spec §7) — grep each criterion's anchor in the shipped prompts and record the evidence in the session log: (a) "zero pausa extra"; (b) "antes de qualquer push" + 3 exits; (c) reconstruction; (d) "diverg"; (e) "nunca mostre nem ecoe"; (f) guard exit 0. Live student-session E2E is a carry-forward (same precedent as v1.7.0/v1.8.0).
- [ ] **Step 3: Memory** — add an SP4 bullet to `pipeline-4-fases.md` ("Fase 4 ganhou o gate de honestidade (1.9.0, SP4)…"), update the estado line to plugin 1.9.0, note SP2 as the only remaining E2E sub-project.

#### Verify

- [ ] **Step 4:** `bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh` → all exit 0.

#### Commit

- [ ] **Step 5:**

```bash
MSG_FILE=/tmp/msg-fase4-bump-$(date +%s).txt
cat > "$MSG_FILE" <<'EOF'
chore(release): imersao 1.9.0 - Fase 4 com gate de honestidade pre-publicar
EOF
git add plugins/imersao/.claude-plugin/plugin.json
git commit -F "$MSG_FILE" --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
rm -f "$MSG_FILE"
```

---

### Task 6 (final): GATE 2 — push + tag + release

Invoke `/finishing-a-development-branch` (direct-to-main mode). GATE 2 is the push decision.

- [ ] **Step 1:** full local gate: `bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && bash scripts/check-fase3.sh && bash scripts/check-fase4.sh && shellcheck -S warning instalar_imersao.sh scripts/*.sh` — all exit 0.
- [ ] **Step 2 (after operator approval):** `git push origin main`; monitor the `validate` workflow until green.
- [ ] **Step 3:** tag + release (repo convention since v1.6.1):

```bash
git tag v1.9.0 && git push origin v1.9.0
gh release create v1.9.0 --title "v1.9.0 — Fase 4 com gate de honestidade pré-publicar" --notes-file /tmp/release-notes-v1.9.0.md
```

Release notes (PT-BR) summarize: Step 0 gate, reconstruction, record × reality check, 3 exits, Variables inheritance, post-deploy record update, guard in CI. Closes 3 of 4 E2E feedback items; SP2 remains.

---

Before claiming the plan complete, run `/verification-before-completion` against the final commit.
