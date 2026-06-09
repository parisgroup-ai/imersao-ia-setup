# Fase 1 — Deeper Discovery + Real Market Research — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the imersão's Fase 1 command (`pg-imersao-prd`) so it researches the market for real, branches into 2-3 evidence-backed product directions, converges on the best, and handles both a fresh idea and an existing-context folder — without drowning the beginner.

**Architecture:** The deliverable is a **prompt** (a Claude Code command Markdown file), not classic code. There is no unit test for an LLM prompt, so TDD is adapted: the "failing test" is a **content-invariant guard script** (`scripts/check-fase1.sh`, in the repo's plain-bash idiom) that asserts the rewritten command contains every designed behavior. It fails against the current file (Red), passes after the rewrite (Green), and is wired into CI as a permanent regression guard. The ultimate proof is the **manual E2E checklist** (spec §12), run by invoking Fase 1 live.

**Tech Stack:** Markdown command files (`plugins/imersao/commands/`), plain Bash guard scripts (`scripts/*.sh`, no bats — repo has none), GitHub Actions (`.github/workflows/validate.yml`), `WebSearch`/`WebFetch` tools (used at runtime by the command, not at build time).

**Spec:** `docs/superpowers/specs/2026-06-09-fase1-profundidade-mercado-design.md`

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `scripts/check-fase1.sh` | Asserts the Fase 1 command contains the designed behaviors (research, directions, modes, artifacts, fallback). The regression guard. | **Create** |
| `plugins/imersao/commands/pg-imersao-prd.md` | The Fase 1 command itself — the rewrite. | **Rewrite** |
| `plugins/imersao/commands/pg-imersao-start.md` | Compass — wording for Fase 1. | **Modify** (small) |
| `docs/PROCESSO-IMERSAO.md` | Student-facing process guide — Fase 1 section + diagram label. | **Modify** (small) |
| `.github/workflows/validate.yml` | CI — wire in the new guard. | **Modify** (1 step) |
| `plugins/imersao/.claude-plugin/plugin.json` | Plugin version. | **Modify** (1.6.1 → 1.7.0) |
| Memory: `pipeline-4-fases.md`, `imersao-pedagogia.md` | Record the research stage + new artifact. | **Modify** (after E2E) |

`docs/PRIMEIROS-PASSOS.md` was checked — it only lists the 4 phase *names* (`definir → desenhar → construir → publicar`), with no Fase-1 detail to sync. No change needed.

---

## Task 1: Failing invariant guard for the new Fase 1

**Files:**
- Create: `scripts/check-fase1.sh`

- [ ] **Step 1: Write the guard script (the "failing test")**

Mirror the repo idiom of `scripts/validate-skills.sh` (`set -uo pipefail`, `err()`, exit code). Create `scripts/check-fase1.sh`:

````bash
#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE1 — invariantes do comando da Fase 1 (pg-imersao-prd)
#  Garante que o redesenho (pesquisa de mercado + direções + modos)
#  está presente e não regride. Só bash; roda em CI e localmente.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

F="plugins/imersao/commands/pg-imersao-prd.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
has() { grep -qiE "$1" "$F"; }

[ -f "$F" ] || { echo "✗ faltando: $F"; exit 1; }

echo "== Invariantes da Fase 1 ($F) =="
has 'pesquis[a-z]* (de )?mercado'            && ok "pesquisa de mercado"            || err "sem pesquisa de mercado"
has 'WebSearch'                              && ok "usa busca real (WebSearch)"     || err "sem WebSearch (busca real)"
has 'fonte'                                  && ok "cita fontes"                    || err "não cita fontes"
{ has 'vender' && has 'economiz|otimiz'; }   && ok "duas lentes de valor"           || err "falta lente vender/economizar"
{ has 'direç'  && has 'recomend'; }          && ok "direções + recomendação"        || err "sem direções/recomendação"
has 'refut|cétic'                            && ok "passo cético"                   || err "sem passo cético"
{ has 'ideia nova' && has 'analisar|construir ou melhorar'; } && ok "modos greenfield/brownfield" || err "sem detecção de contexto"
has 'pesquisa-de-mercado\.md'                && ok "artefato pesquisa-de-mercado.md" || err "sem artefato de pesquisa"
has 'plano-do-produto\.md'                   && ok "artefato plano-do-produto.md"   || err "sem plano-do-produto.md"
has 'Por que vale a pena'                    && ok "seção 'Por que vale a pena'"    || err "sem seção de valor no plano"
has 'chute|não consegui pesquisar'           && ok "fallback sem internet"          || err "sem fallback de pesquisa"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 1 OK"; else echo "✗ Fase 1 com problemas (veja acima)"; fi
exit "$fail"
````

- [ ] **Step 2: Make it executable**

Run: `chmod +x scripts/check-fase1.sh`

- [ ] **Step 3: Run it against the CURRENT command — verify it FAILS (Red)**

Run: `bash scripts/check-fase1.sh; echo "exit=$?"`
Expected: multiple `✗` lines (sem pesquisa de mercado, sem WebSearch, sem passo cético, sem detecção de contexto, sem seção de valor, sem fallback…) and `exit=1`.

- [ ] **Step 4: Shellcheck the new script (CI runs `shellcheck -S warning scripts/*.sh`)**

Run: `shellcheck -S warning scripts/check-fase1.sh; echo "exit=$?"`
Expected: no output, `exit=0`.

- [ ] **Step 5: Commit (guard not yet wired to CI — safe to commit a script that currently reports failures)**

```bash
git add scripts/check-fase1.sh
git commit -m "test(fase1): guarda de invariantes do comando pg-imersao-prd" \
  --trailer "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Rewrite the Fase 1 command

**Files:**
- Modify (full rewrite): `plugins/imersao/commands/pg-imersao-prd.md`
- Test: `scripts/check-fase1.sh` (from Task 1)

- [ ] **Step 1: Replace the entire file content**

Overwrite `plugins/imersao/commands/pg-imersao-prd.md` with exactly:

`````markdown
---
description: "Fase 1 · DEFINIR — conversa guiada que pesquisa o mercado, acha o ângulo mais forte e transforma sua ideia (ou o que você já tem) no plano do produto."
argument-hint: "<sua ideia em uma frase — ou rode numa pasta que já tem um projeto>"
---

# Fase 1 — sua ideia (ou o que você já tem) vira o plano do produto

Conduza uma **conversa curta e amigável** (NÃO um interrogatório técnico) pra transformar
a ideia do aluno num **plano do produto** claro — agora com dois superpoderes: você
**pesquisa o mercado de verdade** antes de desenhar, e oferece **alguns caminhos fortes**
pra convergir no melhor. O aluno é **iniciante, possivelmente não-programador** — fale
100% em **português coloquial, sem jargão**. A ideia inicial está em **$ARGUMENTS**.

O foco é entender **O QUÊ construir** (visão, quem usa, funcionalidades, fluxos, regras)
**e se vale a pena** (o mercado). **Nada de tecnologia** (stack, banco, código): isso é das
Fases 2 e 3.

## Regras de ouro (leia antes de começar)

- **NÃO invoque a skill `brainstorming` genérica.** Conduza você mesmo, com o roteiro abaixo.
- **Sem arquitetura, sem código.** Tudo no nível do **produto** e do **mercado**. A parte
  visual é a Fase 2.
- **A profundidade fica no SEU trabalho, não em mais perguntas pro aluno.** Pesquise,
  levante opções e **proponha** — o aluno responde pouco. NUNCA despeje uma lista de 20
  perguntas: isso afoga o iniciante.
- **Zero jargão.** Nunca diga ao aluno: "PRD", "spec", "MVP", "persona", "TAM", "willingness
  to pay", "moat", "PMF", "market sizing", "hard-gate", "commit", "branch". Traduza tudo
  pro dia a dia.
- **Verdade com caminho.** Se a pesquisa mostrar que a ideia é fraca, fale com tato — mas
  **sempre** junto com 2-3 caminhos mais fortes pra escolher. **Nunca** um "não" sem saída.
- Prefira opções (a/b/c) a perguntas abertas. Tom amigável, encorajador.

## Passo 1 — preparar a pasta (silencioso, sem falar de "git")

```bash
git rev-parse --git-dir >/dev/null 2>&1 || git init -q
git config user.name  >/dev/null 2>&1 || git config user.name  "Aluno Imersão"
git config user.email >/dev/null 2>&1 || git config user.email "aluno@imersao.local"
```

Para o aluno, no máximo: "Já preparei a pasta do seu projeto."

## Passo 2 — de onde a gente parte: ideia do zero, ou o que já existe?

Detecte se a pasta **já tem um projeto/conteúdo** (não conta `.git`, `.gitignore` nem
arquivos que a própria imersão gera):

```bash
HAS_CTX=nao
for sig in package.json pyproject.toml go.mod Cargo.toml composer.json pom.xml \
           src app lib index.html README.md data; do
  [ -e "$sig" ] && HAS_CTX=sim && break
done
echo "CONTEXTO=$HAS_CTX"
```

- **CONTEXTO=nao** → siga pro **Passo 3A** (ideia do zero).
- **CONTEXTO=sim** → **pergunte uma vez** (detecta e confirma):
  > "Vi que essa pasta **já tem coisa**. Quer que eu **olhe o que tem aqui e sugira o que
  > dá pra construir ou melhorar**, ou você tem uma **ideia nova do zero**?"
  - "ideia nova" → **Passo 3A** (ignore o que está na pasta como ponto de partida).
  - "o que tem" → **Passo 3B** (modo análise).

## Passo 3A — captar a ideia (modo "do zero")

Abra com: "Um plano do produto é só um resumo claro do que a gente vai construir, pra quem
e como funciona — e antes disso eu vou checar se a ideia tem mercado. Vamos montar juntos."

Pergunte (uma por vez; se já veio em `$ARGUMENTS`, só confirme):

1. "Em uma frase, o que você quer construir — e que **problema** isso resolve?"
2. **A lente de valor:** "Isso é mais pra você **vender** pra outras pessoas/empresas, ou
   pra **usar no seu próprio dia a dia / negócio** (resolver uma dor interna)?"
   - Se for interno: "Rapidinho — como você resolve isso hoje?"

Só isso por enquanto. As perguntas sobre telas, regras etc. vêm **depois** de escolher o
caminho (Passo 6) — agora você vai pesquisar.

## Passo 3B — analisar o que já existe (modo "em cima do que tem")

Explore a pasta (leia o código/docs/dados que houver) e entenda **o que é** e **que ativos
existem**. Narre em português simples, confirmando com o aluno:

> "Dei uma olhada aqui. Entendi que isso é **[o quê]**, que já tem **[ativos: telas, dados,
> integrações…]**. É isso mesmo?"

Depois, a mesma **lente de valor** — mas aqui você pode **propor** a partir do que viu e só
confirmar: "Pelo que vi, isso parece mais pra **[vender / uso interno]**, certo?"

## Passo 4 — pesquisar o mercado de verdade (você trabalha; o aluno espera)

Na **primeira vez**, narre o conceito em 1 linha:

> "Antes de desenhar, vou **pesquisar o mercado** de verdade — ver quem já faz parecido, se
> as pessoas pagam por isso, e quanto isso pode valer ou economizar. É barato descobrir
> agora se vende, antes de construir."

Pesquise **estruturado e cético**, usando **WebSearch + WebFetch** (abra páginas de verdade,
não só os trechos da busca; ~10-20 buscas focadas). Siga a **lente**:

- **Vender (mercado):** concorrentes diretos + substitutos (como resolvem hoje); preços e
  modelos de cobrança (lidos das páginas reais); **evidência de que pagam** (avaliações,
  reclamações, threads "alternativa ao X"); lacunas/diferenciação; riscos/barreiras.
- **Usar interno (economia):** como o processo é feito hoje (custo em tempo/dinheiro/erro);
  ferramentas existentes + impacto relatado; **benchmark de economia** (quanto operações
  parecidas economizaram); esforço de adoção × retorno; riscos.

**Passo cético (obrigatório):** depois de juntar, **tente refutar o sinal** — "qual o
argumento mais forte de que isso **não** vende / **não** economiza de verdade?" — e
incorpore o contra mais forte no veredito. (É o que separa pesquisa honesta de só procurar
o que confirma.)

**Sem internet/busca:** **não invente** número com cara de fonte. Diga que é um **chute
seu** e que o aluno deve confirmar depois.

**Escala opcional:** se o aluno quiser mais, ofereça — "quer que eu vá **ainda mais fundo**?
Posso fazer uma pesquisa bem mais detalhada, leva alguns minutos" — e aí sim use a skill
`deep-research`.

Escreva **`docs/pesquisa-de-mercado.md`** (PT simples, com as fontes): **Resumo** (o
veredito), **Lente** (vender/economia e por quê), **Panorama** (concorrentes / processo
atual; em modo análise, inclua "Análise do contexto existente"), **O sinal** (números +
fontes), **Direções consideradas**, **Checagem cética** (o contra mais forte + a resposta),
**Fontes** (links).

Então dê ao aluno o **veredito digerível** (zero jargão, verdade com caminho):
- **O panorama** — quem já faz / como se resolve hoje (2-3 bullets).
- **O sinal** — é vendável? / quanto dá pra economizar? — com **pelo menos 1 número real +
  a fonte**, honesto (inclua o contra mais forte). Emende direto nos caminhos (Passo 5).

## Passo 5 — os caminhos: dar possibilidades e escolher o melhor

Na **primeira vez**, narre: "**direção** é um jeito específico de recortar sua ideia —
público, foco, ângulo. Vou te mostrar os mais fortes."

Apresente **2-3 direções** lastreadas na pesquisa (em modo análise: "**o que dá pra fazer**
com o que você já tem"). Cada uma com: **o que é** (1 linha), **por que esse ângulo é mais
forte** (com base na pesquisa), e o **trade-off**. **Recomende uma, com o porquê.**

🛑 **Escolha (1º ponto de decisão):** o aluno escolhe um caminho (ou ajusta). É a decisão
central de **o que construir**. Espere a escolha.

## Passo 6 — aprofundar no caminho escolhido (o plano do produto)

Agora sim, aprofunde — **propondo rascunhos, não interrogando** (use a resposta anterior pra
puxar a próxima). Cubra, derivando e propondo onde der:

- **quem usa** (tipos de pessoa; o que cada um vê e faz);
- as **3 a 6 telas/áreas** principais;
- em cada área, o que a pessoa **faz** e que **regra** importa (ex.: só o dono edita);
- precisa de **conta/login**? depende de algo **de fora** (pagamento, e-mail, mapa)?
- o que **não** precisa entrar agora.

Onde faltar, **proponha um rascunho** e deixe o aluno **confirmar ou ajustar**. Seja
proativo com tela vazia, erro e permissão — sem afogar.

## Passo 7 — o resumo (2º e último ponto de decisão)

Mostre um resumo em bullets e pergunte fechado:

> "Esse é o resumo do seu produto: [bullets]. Tá tudo certo? Responde **sim** que eu escrevo
> o plano, ou me diz o que mudar."

Espere o "sim" (ou ajustes).

## Passo 8 — salvar (silencioso)

Escreva **`docs/plano-do-produto.md`** — comece com uma seção nova no topo:

- **Por que vale a pena** — 3-4 bullets: o caminho escolhido + o sinal de mercado (é
  vendável? / quanto economiza?) + a aposta de valor. (Em modo análise, diga **em cima de
  qual contexto existente** se constrói.)

Depois, as seções do plano (só as que fizerem sentido, com o **nome do produto** no topo):
**Visão**, **Quem usa**, **Funcionalidades** (essencial agora × depois), **Fluxos**
(incluindo tela vazia e erro), **Telas e navegação**, **Informações** (dados e relações),
**Conta e permissões**, **Conexões de fora**, **Regras**, **Entrega por fases**, **Em
aberto / futuro**.

> Não invente conteúdo que o aluno não validou — onde derivou, deixe claro que é rascunho.

Confirme que **`docs/pesquisa-de-mercado.md`** (Passo 4) está salvo. Guarde a primeira
versão por baixo dos panos (git add + commit, sem mostrar o comando). Para o aluno: "Salvei
o plano do seu produto e a pesquisa de mercado. ✅"

## Passo 9 — fechamento humano

> "Pronto! Sua ideia não é só um palpite — ela passou por uma **checagem de mercado de
> verdade**, e a gente escolheu o ângulo mais forte. Esse plano é o **mapa** do seu produto.
> Agora a gente transforma ele em **telas de verdade** que você vê e clica. Quando quiser,
> digite **`/`** e escolha **`imersao:pg-imersao-prototipo`** na lista."
`````

- [ ] **Step 2: Run the guard — verify it PASSES (Green)**

Run: `bash scripts/check-fase1.sh; echo "exit=$?"`
Expected: all `✓` lines, `✓ Fase 1 OK`, `exit=0`.

- [ ] **Step 3: Commit**

```bash
git add plugins/imersao/commands/pg-imersao-prd.md
git commit -m "feat(fase1): pesquisa de mercado real + direções + modo do-zero/análise" \
  --trailer "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Sync the compass and the process guide

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-start.md`
- Modify: `docs/PROCESSO-IMERSAO.md`

- [ ] **Step 1: Compass — enrich the Fase 1 explanation line**

In `pg-imersao-start.md`, find the "definir = decidir o que e pra quem" gloss (in the §3 Regras block) and replace:

```
  = decidir o que e pra quem; desenhar
```
with:
```
  = decidir o que, pra quem e se vale a pena (com pesquisa de mercado); desenhar
```

- [ ] **Step 2: Compass — enrich the "Passo 1 — Definir" state-table row**

In `pg-imersao-start.md`, replace the first state-table action cell:

```
"Bora começar definindo seu app. Digite `/` e escolha **imersao:pg-imersao-prd**, e me conta sua ideia em uma frase."
```
with:
```
"Bora começar: digite `/` e escolha **imersao:pg-imersao-prd** e me conta sua ideia em uma frase — ou, se essa pasta já tem um projeto, ele analisa o que tem e sugere caminhos. Ele ainda **pesquisa o mercado** pra ver se vale a pena."
```

- [ ] **Step 3: Process guide — update the Fase 1 diagram label**

In `docs/PROCESSO-IMERSAO.md`, replace:

```
    ▼   /imersao:pg-imersao-prd            (Fase 1 — conversa guiada)
```
with:
```
    ▼   /imersao:pg-imersao-prd            (Fase 1 — conversa + pesquisa de mercado)
```

- [ ] **Step 4: Process guide — replace the Fase 1 section body**

In `docs/PROCESSO-IMERSAO.md`, replace the whole Fase 1 section (heading `## Fase 1 — ...` through the gate line ending `a fonte da verdade do projeto.`) with:

````markdown
## Fase 1 — `/imersao:pg-imersao-prd` (ideia → plano do produto, com mercado)

Dentro de `meu-projeto/`, rode:

```
/imersao:pg-imersao-prd "um app pra agendar consultas do meu salão"
```

(Ou rode numa pasta que **já tem um projeto**: ele detecta, pergunta, e **analisa o que já
existe** pra sugerir o que dá pra construir ou melhorar.)

O Claude faz três coisas: **(1)** entende sua ideia com poucas perguntas; **(2)**
**pesquisa o mercado de verdade** — quem já faz parecido, se as pessoas pagam, e quanto dá
pra economizar — e te dá um veredito honesto; **(3)** te mostra **2-3 caminhos** (direções)
mais fortes e recomenda um, pra você escolher.

🛑 **Escolha o caminho** e, no fim, **aprove o resumo**. Aí ele escreve dois arquivos:
**`docs/plano-do-produto.md`** (a fonte da verdade) e **`docs/pesquisa-de-mercado.md`** (o
que ele descobriu, com as fontes).
````

- [ ] **Step 5: Verify nothing else broke and commit**

Run: `bash scripts/validate-skills.sh >/dev/null && bash scripts/check-fase1.sh >/dev/null && echo OK`
Expected: `OK`

```bash
git add plugins/imersao/commands/pg-imersao-start.md docs/PROCESSO-IMERSAO.md
git commit -m "docs(fase1): bússola e guia do processo refletem pesquisa de mercado + modos" \
  --trailer "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Wire the guard into CI

**Files:**
- Modify: `.github/workflows/validate.yml`

- [ ] **Step 1: Add a CI step that runs the guard**

In `.github/workflows/validate.yml`, after the `Validate marketplace...` step and before the `Shellcheck` step, insert:

```yaml
      - name: Invariantes da Fase 1 (pg-imersao-prd)
        run: bash scripts/check-fase1.sh
```

(The existing `shellcheck -S warning instalar_imersao.sh scripts/*.sh` step already covers `scripts/check-fase1.sh` — no extra shellcheck wiring needed.)

- [ ] **Step 2: Simulate the full CI locally**

Run:
```bash
bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && shellcheck -S warning instalar_imersao.sh scripts/*.sh && echo "CI-LOCAL OK"
```
Expected: ends with `CI-LOCAL OK` (exit 0).

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/validate.yml
git commit -m "ci(fase1): roda a guarda de invariantes do pg-imersao-prd" \
  --trailer "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Version bump, E2E acceptance, and memory

**Files:**
- Modify: `plugins/imersao/.claude-plugin/plugin.json`
- Modify (memory): `~/.claude/projects/-Users-gustavoparis-www-imersao-setup/memory/pipeline-4-fases.md`, `imersao-pedagogia.md`

- [ ] **Step 1: Bump the plugin version (minor — new feature)**

In `plugins/imersao/.claude-plugin/plugin.json`, change `"version": "1.6.1"` to `"version": "1.7.0"`.

- [ ] **Step 2: E2E acceptance — run Fase 1 live in a scratch folder**

This is the real proof (spec §12). In a throwaway dir, invoke the imersão Fase 1 on a sample idea (e.g. *"um app pra agendar consultas do meu salão"*) and confirm each:

- [ ] Asks **≤2 light questions** before researching (idea + value-lens).
- [ ] Performs **real web research** — `docs/pesquisa-de-mercado.md` cites **real, fetchable links**.
- [ ] Verdict is **digestible, zero jargon**, with **≥1 real number/range + source**.
- [ ] Value **lens detected correctly** (sell vs. internal) from the context answer.
- [ ] Presents **2-3 directions with a recommendation** and **waits** for the choice.
- [ ] A **skeptic/refutation** note is in the research file and reflected in the verdict.
- [ ] On an unfavorable idea → **truth with a path** (no dead-end "no").
- [ ] **Both artifacts** written; `plano-do-produto.md` has **"Por que vale a pena"**.
- [ ] **Brownfield:** in a folder with pre-existing content, it detects + asks once; on "analyze" it explains what's there and the directions become research-backed possibilities.
- [ ] All student-facing copy is **PT-BR, jargon-free**; each new concept narrated in 1 line.

If any criterion fails, fix `pg-imersao-prd.md` (and re-run `bash scripts/check-fase1.sh`) before continuing.

- [ ] **Step 3: Update memory to record the change**

In `pipeline-4-fases.md`, under "Decisões travadas", add a bullet:
```
- Fase 1 agora **pesquisa o mercado de verdade** (web, no começo, estruturada + cética), ramifica em 2-3 **direções** e converge na melhor; detecta **pasta com contexto** (modo análise) vs. ideia do zero. 2º artefato: `docs/pesquisa-de-mercado.md`; `plano-do-produto.md` ganha a seção "Por que vale a pena". Plugin 1.7.0.
```

In `imersao-pedagogia.md`, append to the principle paragraph:
```
A profundidade migra pra carga do AGENTE (pesquisa + opções), não pra mais perguntas ao aluno — leve pro aluno, fundo no que o agente faz. Ver `docs/superpowers/specs/2026-06-09-fase1-profundidade-mercado-design.md`.
```

- [ ] **Step 4: Commit the version bump (memory files live outside the repo — not staged)**

```bash
git add plugins/imersao/.claude-plugin/plugin.json
git commit -m "chore(release): imersao 1.7.0 — Fase 1 com pesquisa de mercado" \
  --trailer "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 5: Cut the release (separate ceremony)**

The repo uses git tags + GitHub releases (`v1.7.0`). Run the repo's release flow (`/release-maintenance` or `/project-release`) to tag `v1.7.0` and publish the release — **do not** hand-roll the tag here. This is left as an explicit, user-triggered step.

---

## Self-Review

**1. Spec coverage** — every spec section maps to a task:

| Spec | Task |
|---|---|
| §3 D1 research up front · §5 structured+skeptic | Task 2 (Passo 4) + guard assertions (Task 1) |
| §3 D2 directions → converge | Task 2 (Passo 5) |
| §3 D3 value lens detection | Task 2 (Passo 3A/3B) |
| §3 D4 truth with a path | Task 2 (Regras de ouro + Passo 4/5) |
| §3 D5 depth + opt-in deep-research | Task 2 (Passo 4) |
| §3 D6 / §4.1 greenfield vs brownfield | Task 2 (Passo 2/3A/3B) |
| §7 artifacts (pesquisa-de-mercado.md + "Por que vale a pena") | Task 2 (Passo 4/8) |
| §8 pedagogical guardrails | Task 2 (Regras de ouro) |
| §9 files (prd, start, docs, memory) | Tasks 2, 3, 5 |
| §10 error handling (no web, unfavorable, both lenses) | Task 2 (Passo 4/5) |
| §12 acceptance criteria | Task 5 (E2E checklist) |
| Regression guard (new — CI) | Tasks 1, 4 |

No gaps.

**2. Placeholder scan** — the command content is complete (no TBD/TODO). The `[o quê]`/`[ativos…]`/`[vender / uso interno]` brackets inside the command are **runtime fill-ins the agent speaks to the student** (intentional template slots in the prompt), not plan placeholders. All commands have exact expected output.

**3. Type/name consistency** — the guard script's anchors all match strings present in the Task 2 content: `pesquisa de mercado`, `WebSearch`, `fonte(s)`, `vender`+`economiz`, `direç`+`Recomende`, `refutar`/`cética`, `ideia nova`+`analisar`/`construir ou melhorar`, `pesquisa-de-mercado.md`, `plano-do-produto.md`, `Por que vale a pena`, `chute`. File paths consistent across tasks (`scripts/check-fase1.sh`, `plugins/imersao/commands/pg-imersao-prd.md`). Version bump 1.6.1 → 1.7.0 matches `plugin.json`.
