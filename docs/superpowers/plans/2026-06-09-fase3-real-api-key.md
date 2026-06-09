# Fase 3 — Real Functionality + API-Key Honesty — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the imersão's Fase 3 command (`pg-imersao-implementar`) so every external capability (AI first) is built **real or as explicit demo — student decides, warned early** — plus small honesty touches in Fases 1 and 4 and an honesty record (`docs/o-que-e-real.md`) for the future SP4 gate.

**Architecture:** The deliverable is a set of **prompts** (Claude Code command Markdown files), not classic code. TDD is adapted as in the Fase 1 plan: the "failing test" is a **content-invariant guard script** (`scripts/check-fase3.sh`, plain-bash idiom of `check-fase1.sh`) asserting the rewritten commands contain every designed behavior. It fails against the current files (Red), passes after the rewrite (Green), and is wired into CI. The ultimate proof is the **manual E2E checklist** (spec §12).

**Tech Stack:** Markdown command files (`plugins/imersao/commands/`), plain Bash guard scripts (`scripts/*.sh`, no bats — repo has none), GitHub Actions (`.github/workflows/validate.yml`).

**Spec:** `docs/superpowers/specs/2026-06-09-fase3-real-api-key-design.md`

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `scripts/check-fase3.sh` | Asserts the honesty contract (real-or-explicit-demo, API-key path, badge, o-que-e-real record) across the three touched commands. The regression guard. | **Create** |
| `plugins/imersao/commands/pg-imersao-implementar.md` | The Fase 3 command — the major rewrite. | **Rewrite** |
| `plugins/imersao/commands/pg-imersao-prd.md` | Fase 1 — key+cost flag in "Conexões de fora". | **Modify** (small) |
| `plugins/imersao/commands/pg-imersao-publicar.md` | Fase 4 — Railway variable step + demo status narration. | **Modify** (small) |
| `plugins/imersao/commands/pg-imersao-start.md` | Compass — Fase 3 wording. | **Modify** (small) |
| `docs/PROCESSO-IMERSAO.md` | Student-facing guide — Fase 3 section. | **Modify** (small) |
| `.github/workflows/validate.yml` | CI — wire in the new guard. | **Modify** (1 step) |
| `plugins/imersao/.claude-plugin/plugin.json` | Plugin version. | **Modify** (1.7.0 → 1.8.0) |
| Memory: `pipeline-4-fases.md` | Record SP3 shipped. | **Modify** (after E2E) |

`docs/PRIMEIROS-PASSOS.md` was checked — it only lists the 4 phase *names* with no Fase-3 detail to sync. No change needed.

---

## Task 1: Failing invariant guard for the new Fase 3

**Files:**
- Create: `scripts/check-fase3.sh`

- [ ] **Step 1: Write the guard script (the "failing test")**

Mirror the idiom of `scripts/check-fase1.sh` (`set -uo pipefail`, `err()`/`ok()`, exit code). Create `scripts/check-fase3.sh`:

````bash
#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE3 — invariantes da honestidade de funcionalidade
#  (pg-imersao-implementar + toques em prd/publicar).
#  Garante que o contrato "real ou demonstração explícita" e o
#  caminho da chave de API estão presentes e não regridem.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

IMPL="plugins/imersao/commands/pg-imersao-implementar.md"
PRD="plugins/imersao/commands/pg-imersao-prd.md"
PUB="plugins/imersao/commands/pg-imersao-publicar.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasi() { grep -qiE "$1" "$IMPL"; }
hasp() { grep -qiE "$1" "$PRD"; }
hasu() { grep -qiE "$1" "$PUB"; }

for f in "$IMPL" "$PRD" "$PUB"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 3 ($IMPL) =="
hasi 'Conexões de fora'                    && ok "lê Conexões de fora do plano"     || err "não lê Conexões de fora"
hasi 'chave de API'                        && ok "explica a chave de API"           || err "sem chave de API"
hasi 'separad[a-z]* da (sua )?assinatura'  && ok "chave ≠ assinatura do Claude"     || err "não separa chave de assinatura"
hasi 'centavos'                            && ok "custo honesto (centavos por uso)" || err "sem custo honesto"
hasi 'criar agora|console\.anthropic\.com' && ok "caminho guiado de criar a chave"  || err "sem caminho guiado da chave"
hasi 'modo demonstração'                   && ok "modo demonstração explícito"      || err "sem modo demonstração"
hasi 'selo'                                && ok "selo de demonstração na tela"     || err "sem selo de demonstração"
hasi 'silencios'                           && ok "proíbe simulação silenciosa"      || err "não proíbe simulação silenciosa"
hasi 'ANTHROPIC_API_KEY'                   && ok "variável ANTHROPIC_API_KEY"       || err "sem ANTHROPIC_API_KEY"
hasi '\.gitignore'                         && ok "garante .env no .gitignore"       || err "sem regra .env/.gitignore"
hasi '@anthropic-ai/sdk'                   && ok "SDK oficial"                      || err "sem SDK oficial"
hasi 'haiku'                               && ok "modelo barato por padrão"         || err "sem modelo barato padrão"
hasi 'o-que-e-real\.md'                    && ok "registro o-que-e-real.md"         || err "sem registro o-que-e-real.md"
hasi 'stripe'                              && ok "pagamento via Stripe modo teste"  || err "sem padrão de pagamento"

echo ""
echo "== Toques na Fase 1 ($PRD) =="
hasp 'chave'                               && ok "plano avisa da chave"             || err "Fase 1 não avisa da chave"
hasp 'centavos'                            && ok "plano menciona o custo"           || err "Fase 1 sem custo aproximado"

echo "== Toques na Fase 4 ($PUB) =="
hasu 'ANTHROPIC_API_KEY'                   && ok "variável no Railway"              || err "Fase 4 sem ANTHROPIC_API_KEY"
hasu 'modo demonstração'                   && ok "narra status demonstração"        || err "Fase 4 sem status demonstração"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 3 OK"; else echo "✗ Fase 3 com problemas (veja acima)"; fi
exit "$fail"
````

- [ ] **Step 2: Make it executable**

Run: `chmod +x scripts/check-fase3.sh`

- [ ] **Step 3: Run it against the CURRENT commands — verify it FAILS (Red)**

Run: `bash scripts/check-fase3.sh; echo "exit=$?"`
Expected: many `✗` lines (sem chave de API, sem modo demonstração, sem ANTHROPIC_API_KEY, sem o-que-e-real.md…) and `exit=1`.

- [ ] **Step 4: Shellcheck the new script (CI runs `shellcheck -S warning scripts/*.sh`)**

Run: `shellcheck -S warning scripts/check-fase3.sh; echo "exit=$?"`
Expected: no output, `exit=0`.

- [ ] **Step 5: Commit (guard not yet wired to CI — safe to commit a script that currently reports failures)**

```bash
git add scripts/check-fase3.sh
git commit -m "test(fase3): guarda de invariantes da honestidade real-ou-demonstracao" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 2: Rewrite the Fase 3 command

**Files:**
- Modify (full rewrite): `plugins/imersao/commands/pg-imersao-implementar.md`
- Test: `scripts/check-fase3.sh` (from Task 1)

- [ ] **Step 1: Replace the entire file content**

Overwrite `plugins/imersao/commands/pg-imersao-implementar.md` with exactly:

`````markdown
---
description: "Fase 3 · CONSTRUIR — implementa o app de ponta a ponta a partir do export do Design OS + plano, com funcionalidade de verdade (real ou demonstração explícita — você decide)."
---

# /imersao:pg-imersao-implementar — Fase 3: export + PRD → app completo

Você vai construir o **app de verdade**, de ponta a ponta, a partir do protótipo
exportado pelo Design OS e do `docs/plano-do-produto.md`, na stack pública da imersão.
**E "de verdade" quer dizer de verdade:** nada de funcionalidade fingida sem avisar. O que
depender de serviço de fora (IA, pagamento, e-mail…) é **real ou demonstração explícita**
— e o aluno decide isso ANTES de você construir (item 3).

## Narração didática (construir, mas o aluno entende a lógica)

Esta fase tem a mecânica mais técnica (banco, migration, testes). Siga a regra da
imersão: **automatize a mecânica, narre o conceito em 1 linha**. O `/imersao:pg-imersao-goal`
já carrega o glossário base; aqui vão os conceitos específicos da Fase 3 — explique cada
um **na primeira vez** que aparecer, em português simples (nunca narre a sintaxe/flags,
só o **o quê** e o **porquê**):

| Conceito | Diga assim (1 linha) |
|---|---|
| app = 3 partes | "Todo app tem 3 partes: a tela (o que você vê), o cérebro (a lógica) e o banco (onde guarda os dados). Vou montar as três." |
| banco de dados | "O banco é onde as informações do app ficam guardadas — tipo uma planilha gigante que o app lê e escreve." |
| migration | "Uma migration é como o app cria as 'gavetas' do banco (as tabelas). Toda mudança no formato dos dados vira uma migration." |
| Docker | "O Docker é uma caixinha que roda o banco no seu computador sem você instalar nada à mão." |
| rodar local | "Seu app está rodando só no seu computador (localhost) por enquanto — depois dá pra colocar no ar pra outros acessarem." |
| chave de API | "A chave de API é a 'senha' que deixa seu app usar a IA — ela é separada da sua assinatura do Claude e custa centavos por uso (você só paga o que o app consumir)." |
| modo demonstração | "No modo demonstração o app mostra respostas de exemplo, claramente marcadas com um selo, até você colocar a chave de verdade — aí vira real sozinho." |

## Pré-condições

1. Trabalhe **a partir da pasta do app** (a mesma do `docs/plano-do-produto.md`). Derive a pasta do
   design e exija o **export** + o **`docs/plano-do-produto.md`**:

   ```bash
   APP="$(basename "$PWD")"; DESIGN_DIR="../${APP}-design"
   [ -f docs/plano-do-produto.md ] || { echo "Falta docs/plano-do-produto.md — rode /imersao:pg-imersao-prd antes."; exit 1; }
   { [ -f "$DESIGN_DIR/product-plan.zip" ] || [ -d "$DESIGN_DIR/product-plan" ]; } \
     || { echo "Falta o export — rode /imersao:pg-imersao-prototipo antes."; exit 1; }
   ```

   Se o servidor do Design OS (Fase 2) ainda estiver no ar, **desligue-o** pra liberar a
   porta do app (narre: "vou desligar o servidor do desenho que ficou aberto"):

   ```bash
   [ -f "$DESIGN_DIR/.dev-server.pid" ] && kill "$(cat "$DESIGN_DIR/.dev-server.pid")" 2>/dev/null; rm -f "$DESIGN_DIR/.dev-server.pid"
   ```

2. **Cheque o Docker ANTES de começar** — esta fase usa um banco Postgres em Docker. Rode
   `docker info` silenciosamente:
   - Respondeu OK → siga.
   - Falhou → **NÃO** mostre o erro técnico do daemon. Diga em português: "Pra essa parte
     eu preciso do **Docker** ligado. Abra o app **Docker Desktop** (Launchpad → ícone do
     Docker) e espere a baleia 🐳 na barra de cima parar de animar (~1 min); aí me avise."
     Só prossiga quando `docker info` responder OK.

## Conexões de fora — real ou demonstração explícita (sem surpresa)

3. Antes de construir, leia a seção **"Conexões de fora"** do `docs/plano-do-produto.md`
   — e o resto do plano como rede de segurança: uma funcionalidade tipo "gera resumo com
   IA" conta mesmo se a seção não listou. Classifique o que o app precisa de fora:
   **IA**, **pagamento**, **e-mail**, **mapa**, outro.

   - **Nada de fora** → pule direto pro item 4. **Zero fricção nova, zero pausa extra.**

   **Regra de honestidade (vale pro projeto inteiro):** NUNCA construa uma funcionalidade
   prometida no plano como simulação **silenciosa**. Tudo que depende de serviço de fora
   nasce **real** ou **demonstração explícita** — o aluno decide, avisado ANTES de você
   construir.

   ### Se o app usa IA (o caso mais comum) — caminho completo

   Narre o conceito em 1 linha (primeira vez — tabela acima):

   > "Seu app usa **IA de verdade**. Pra isso ele precisa de uma **chave de API** — ela é
   > **separada da sua assinatura do Claude** e custa **centavos por uso** (você só paga o
   > que o app consumir)."

   E pergunte **UMA vez**, com 3 saídas:

   1. **"Já tenho uma chave"** → receba e guarde (regras abaixo).
   2. **"Quero criar agora"** (~5 min, você guia, um passo de cada vez): abra
      `https://console.anthropic.com` → entrar com e-mail → em **Billing**, adicionar um
      crédito pequeno (uns 5 dólares já dão MUITO uso — seja honesto que essa parte é
      paga) → **API Keys → Create Key** → copiar a chave. Aí o aluno **cola a chave aqui
      no chat** e você guarda no lugar certo.
   3. **"Seguir em modo demonstração"** → construa com a demonstração explícita (selo na
      tela, item 5.7) — e diga desde já que **trocar pela chave depois é 1 passo**, sem
      mexer em código.

   **Regras da chave (invariantes — siga TODAS):**
   - A chave vai pro arquivo **`.env`** (`ANTHROPIC_API_KEY=...`). **NUNCA** ecoe, logue
     ou repita a chave de volta no chat; **NUNCA** commite o `.env`.
   - Garanta **`.env` no `.gitignore`** — o Next só ignora `.env*.local` por padrão, então
     **adicione a linha `.env`** antes do primeiro commit. Narre: "a chave fica só no seu
     computador, num arquivo que nunca sobe pro GitHub."
   - **Valide com um teste mínimo** (uma chamada curtinha) — "vou fazer um teste rapidinho
     pra confirmar que a chave funciona". Se falhar, diga em português simples (erro de
     digitação é o caso comum) e peça de novo. Nunca mostre stack trace.

   ### Outros serviços de fora — mesmo contrato, com um padrão recomendado

   Mesmo aviso-e-pergunta (real ou demonstração), com uma recomendação que o aluno pode
   só aceitar:

   - **Pagamento** → **Stripe em modo teste** (integração real, cartões de teste, sem
     dinheiro de verdade; ligar o modo real depois é trocar uma chave).
   - **E-mail** → demonstração explícita (a tela mostra o e-mail que SERIA enviado), a
     menos que o aluno já tenha chave de um provedor.
   - **Mapa / APIs com camada grátis** → criar a chave grátis (guiado) ou demonstração.

## Disparar o motor

O design **já foi aprovado** nas Fases 1 e 2 (plano + protótipo) — esta fase **não
re-aprova design**. O motor pula direto pro plano técnico e só pausa na **entrega final**.

4. Acione o motor autônomo:

   ```
   /imersao:pg-imersao-goal "implementar o app conforme docs/plano-do-produto.md e o export do Design OS em $DESIGN_DIR/product-plan/ — o design JÁ está aprovado (plano + protótipo), então PULE o brainstorming e vá direto pro plano técnico; só pause na entrega final. Monte o Next.js NA PRÓPRIA pasta do app (não num subdiretório novo). Capacidades externas (IA etc.) seguem o contrato já decidido com o aluno: REAL com a chave no .env, ou demonstração explícita com selo na tela — NUNCA simulação silenciosa"
   ```

## Como o plano DEVE começar (Task 1 — scaffold)

5. A **primeira tarefa** do plano monta o esqueleto **de forma não interativa** (todo
   comando fecha o stdin com `< /dev/null` pra um prompt inesperado falhar rápido em vez
   de travar), com **banco em Docker desde o dia 1**. Ordem que funciona:

   1. **Next.js NA PRÓPRIA pasta do app** (App Router, TS) — alvo `.`, nunca um
      subdiretório novo (senão a bússola não acha o app). O nome da pasta precisa ser
      **minúsculo e sem espaços** (regra do npm); se não for, avise em português e peça pra
      renomear antes de criar:
      ```bash
      npx --yes create-next-app@latest . --ts --tailwind --app --eslint \
        --no-src-dir --import-alias "@/*" --use-npm --yes --disable-git < /dev/null
      ```
   2. **shadcn/ui** (depois do Next — precisa do Tailwind e da pasta prontos):
      ```bash
      npx --yes shadcn@latest init --yes --defaults < /dev/null   # NÃO use --base-color (removido)
      ```
   3. **Drizzle ORM** + **`docker-compose.yml`** (Postgres 16, porta de host **5455** pra
      fugir do 5432 ocupado) + **`.env.example`** E **`.env` de verdade** (`cp .env.example .env`,
      com `DATABASE_URL` apontando pro Postgres do compose — o Drizzle e o Next leem `.env`,
      **não** `.env.example`). **Adicione a linha `.env` ao `.gitignore`** (o padrão do Next
      não cobre — e a chave de API vai morar aí).
   4. **Suba o banco e ESPERE ficar pronto** antes da migration (em máquina fria o Docker
      baixa a imagem e o Postgres leva alguns segundos pra aceitar conexão):
      ```bash
      docker compose up -d
      until docker compose exec -T db pg_isready -U app >/dev/null 2>&1; do sleep 1; done
      ```
   5. **primeira migration** do Drizzle (gerar + aplicar).
   6. rota **`/api/health`** que faz um SELECT simples no banco.
   7. **Se o app usa IA** (decidido no item 3), a integração já nasce no formato padrão:
      - `ANTHROPIC_API_KEY` no **`.env.example`** (vazio, commitado) e no **`.env`** (com a
        chave real, ou vazio em modo demonstração — nunca commitado);
      - **um módulo único de IA** (ex.: `lib/ai.ts`) — o ÚNICO lugar do app que fala com a
        IA: com chave → chamada real com o SDK oficial (`npm install @anthropic-ai/sdk`),
        usando um **modelo barato por padrão** (família **Haiku** — mantém o custo em
        centavos); sem chave → resposta de demonstração **marcada** (`demo: true`), com
        conteúdo plausível (o fluxo continua demonstrável), nunca fingindo ser real;
      - **selo "modo demonstração"** — toda tela que mostrar uma resposta `demo: true`
        exibe um selo discreto "modo demonstração"; resposta real NUNCA mostra o selo;
      - **troca de 1 passo** — colar a chave no `.env` e reiniciar (`npm run dev`) vira
        real, sem mexer em código. Documente em português no README do app, numa seção
        **"Como ativar a IA de verdade"**;
      - **testes nunca chamam a API real** — nos testes o módulo de IA é substituído por
        uma versão falsa (mock de teste é normal e invisível pro aluno — diferente de mock
        no app, que é proibido sem aviso).

      O mesmo formato vale pros outros serviços (um módulo por serviço, configuração no
      `.env`, demonstração marcada + selo).

   Se `docker compose up -d` reclamar de **porta ocupada** ("port is already allocated"),
   **não** mostre o erro cru: troque a porta de host (5455 → 5456…), atualize o
   `DATABASE_URL` e avise o aluno em português que a porta padrão estava em uso.

   App no ar: `npm run dev`.

   **Deixe o app pronto pra publicar (Fase 4):** o `npm run build` precisa passar; o `start`
   é `next start` (respeita a porta `PORT` que o Railway define — não force 3000); **rotas que
   falam com o banco** levam `export const dynamic = 'force-dynamic'` (senão o `build` tenta
   abrir o banco e quebra no Railway, onde o banco não existe na hora do build); **commite as
   migrations geradas** (vão pro GitHub e rodam no Railway no deploy); o `docker-compose.yml`
   é **só pro banco local** — no Railway o Postgres é um serviço à parte.

## Tarefas seguintes

6. Depois do scaffold, o plano segue tarefa a tarefa (TDD):
   - **portar os componentes** exportados (React + Tailwind), seção por seção;
   - **ligar os dados** com Drizzle (queries/migrations);
   - **route handlers / server actions** para as ações;
   - **testes** para cada comportamento;
   - **regra de honestidade em TODA tarefa:** funcionalidade prometida no plano nasce
     **real** (com a conexão de verdade) ou **demonstração marcada com o selo** — nunca
     uma simulação calada que parece real.

## Antes da entrega: o registro do que é real

7. Antes do gate final, escreva **`docs/o-que-e-real.md`** no projeto do aluno (português
   simples, sem jargão):
   - uma tabela: **funcionalidade → real / demonstração → o que falta pra ativar** (ex.:
     "Resumo com IA → demonstração → colar sua chave no arquivo `.env`");
   - uma linha lembrando que os dados estão só no seu computador até a Fase 4.

   Narre em 1 linha: "deixei anotado o que está funcionando de verdade e o que está em
   demonstração — fica em `docs/o-que-e-real.md`."

8. Os **gates humanos** (aprovar plano e integração final) são conduzidos pelo
   `/imersao:pg-imersao-goal`. Ao final: `docker compose up -d && npm run dev` → **app
   funcionando de ponta a ponta**, fácil de mexer e ajustar.
`````

- [ ] **Step 2: Run the guard — verify the IMPL section is green (PRD/PUB anchors still red — expected until Task 3)**

Run: `bash scripts/check-fase3.sh; echo "exit=$?"`
Expected: all `✓` under "Invariantes da Fase 3"; `✗` lines remain under "Toques na Fase 1/4"; `exit=1`.

- [ ] **Step 3: Commit**

```bash
git add plugins/imersao/commands/pg-imersao-implementar.md
git commit -m "feat(fase3): conexoes de fora reais ou demo explicita + caminho da chave de API" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 3: Honesty touches in Fase 1 and Fase 4

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-prd.md`
- Modify: `plugins/imersao/commands/pg-imersao-publicar.md`
- Test: `scripts/check-fase3.sh`

- [ ] **Step 1: Fase 1 — flag the key+cost when an external dependency is detected (Passo 6)**

In `plugins/imersao/commands/pg-imersao-prd.md`, replace:

```
- precisa de **conta/login**? depende de algo **de fora** (pagamento, e-mail, mapa)?
```

with:

```
- precisa de **conta/login**? depende de algo **de fora** (IA, pagamento, e-mail, mapa)?
  Se depender — principalmente de **IA** — narre 1 linha, sem assustar: "isso vai usar
  **IA de verdade**; lá na construção você vai precisar de uma **chave** (custa centavos
  por uso, separada da assinatura do Claude) — te aviso na hora certa, é rapidinho."
```

- [ ] **Step 2: Fase 1 — record key+cost per connection in the plan (Passo 8)**

In `plugins/imersao/commands/pg-imersao-prd.md`, immediately BEFORE the line:

```
> Não invente conteúdo que o aluno não validou — onde derivou, deixe claro que é rascunho.
```

insert:

```
> Em **Conexões de fora**, registre cada conexão com: o que é, se **precisa de chave**, o
> **custo aproximado** (ex.: "IA: centavos por uso") e uma nota de que a **Fase 3 resolve
> isso com você** (criar a chave ou seguir em modo demonstração).

```

- [ ] **Step 3: Fase 4 — Railway variable step + demo status narration**

In `plugins/imersao/commands/pg-imersao-publicar.md`, replace:

```
5. **Gerar o link público:** "Em **Settings → Networking**, clique em **Generate Domain**."
   O Railway te dá uma URL tipo `seu-app.up.railway.app`.
```

with:

```
5. **Se o app usa chave de IA (ou outro serviço de fora):** "Ainda em **Variables**, clique
   em **New Variable** e crie **`ANTHROPIC_API_KEY`**, colando o **valor da sua chave**
   (aqui é o valor mesmo, não referência)." Narre o porquê: "o ar não lê o arquivo `.env`
   do seu computador — a chave precisa ser colocada lá também." Se o aluno seguiu em
   **modo demonstração**: diga com clareza que o app no ar fica em demonstração (com o
   selo) até ele colocar a chave — e tá tudo bem publicar assim.
6. **Gerar o link público:** "Em **Settings → Networking**, clique em **Generate Domain**."
   O Railway te dá uma URL tipo `seu-app.up.railway.app`.
```

- [ ] **Step 4: Run the guard — verify it PASSES fully (Green)**

Run: `bash scripts/check-fase3.sh; echo "exit=$?"`
Expected: all `✓` lines, `✓ Fase 3 OK`, `exit=0`.

Also confirm the Fase 1 guard still passes: `bash scripts/check-fase1.sh >/dev/null && echo F1-OK`
Expected: `F1-OK`

- [ ] **Step 5: Commit**

```bash
git add plugins/imersao/commands/pg-imersao-prd.md plugins/imersao/commands/pg-imersao-publicar.md
git commit -m "feat(fase3): fase 1 avisa da chave cedo e fase 4 cobre a variavel no Railway" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 4: Sync the compass and the process guide

**Files:**
- Modify: `plugins/imersao/commands/pg-imersao-start.md`
- Modify: `docs/PROCESSO-IMERSAO.md`

- [ ] **Step 1: Compass — enrich the "Passo 3 — Construir" state-table cell**

In `plugins/imersao/commands/pg-imersao-start.md`, replace:

```
"Telas desenhadas e exportadas ✅. Hora de **construir o app de verdade**: digite `/` e escolha **imersao:pg-imersao-implementar**."
```

with:

```
"Telas desenhadas e exportadas ✅. Hora de **construir o app de verdade**: digite `/` e escolha **imersao:pg-imersao-implementar**. Se seu app usa **IA**, ele já te ajuda com a **chave** nessa hora (de verdade ou modo demonstração — você escolhe)."
```

- [ ] **Step 2: Compass — enrich the "o que é cada passo" gloss**

In `plugins/imersao/commands/pg-imersao-start.md`, replace:

```
construir = o
  app funcionando com banco de dados).
```

with:

```
construir = o
  app funcionando de verdade, com banco de dados — e com a chave de IA, se o app usar).
```

- [ ] **Step 3: Process guide — replace the Fase 3 section body**

In `docs/PROCESSO-IMERSAO.md`, replace the block starting at:

```
Isso dispara o motor `/imersao:pg-imersao-goal`, que monta o app a partir do protótipo + plano. A
**primeira tarefa** já sobe a base com **banco em Docker**:

- **Next.js** (App Router, TypeScript) + **Tailwind** + **shadcn/ui**
- **Drizzle ORM** + **Postgres 16 em Docker** (`docker-compose.yml`) + `.env`
- primeira migration + rota `/api/health`
```

with:

```
Isso dispara o motor `/imersao:pg-imersao-goal`, que monta o app a partir do protótipo + plano.

**Antes de construir, a honestidade:** se o seu plano usa algo **de fora** (IA, pagamento,
e-mail…), o Claude te avisa **antes** — pra IA, ele explica que precisa de uma **chave de
API** (separada da assinatura do Claude; custa centavos por uso) e te dá a escolha: **criar
a chave agora** (ele guia, ~5 min) ou seguir em **modo demonstração** (respostas de exemplo
com um selo na tela; colar a chave depois vira real, sem mexer em código). Nada de
funcionalidade fingida sem avisar.

A **primeira tarefa** já sobe a base com **banco em Docker**:

- **Next.js** (App Router, TypeScript) + **Tailwind** + **shadcn/ui**
- **Drizzle ORM** + **Postgres 16 em Docker** (`docker-compose.yml`) + `.env`
- primeira migration + rota `/api/health`
- se o app usa **IA**: a integração real (ou a demonstração marcada) já nasce no formato certo
```

- [ ] **Step 4: Process guide — mention the honesty record before the final gate**

In `docs/PROCESSO-IMERSAO.md`, replace:

```
Depois ele porta os componentes, liga os dados e escreve testes — tarefa por tarefa.
```

with:

```
Depois ele porta os componentes, liga os dados e escreve testes — tarefa por tarefa. No
fim, ele deixa um **`docs/o-que-e-real.md`** no projeto: o registro honesto do que está
funcionando de verdade e do que está em demonstração (e o que falta pra ativar).
```

- [ ] **Step 5: Verify nothing broke and commit**

Run: `bash scripts/validate-skills.sh >/dev/null && bash scripts/check-fase1.sh >/dev/null && bash scripts/check-fase3.sh >/dev/null && echo OK`
Expected: `OK`

```bash
git add plugins/imersao/commands/pg-imersao-start.md docs/PROCESSO-IMERSAO.md
git commit -m "docs(fase3): bussola e guia do processo refletem chave de API + modo demonstracao" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 5: Wire the guard into CI

**Files:**
- Modify: `.github/workflows/validate.yml`

- [ ] **Step 1: Add a CI step that runs the guard**

In `.github/workflows/validate.yml`, after the `Invariantes da Fase 1 (pg-imersao-prd)` step and before the `Shellcheck` step, insert:

```yaml
      - name: Invariantes da Fase 3 (implementar + toques prd/publicar)
        run: bash scripts/check-fase3.sh
```

(The existing `shellcheck -S warning instalar_imersao.sh scripts/*.sh` step already covers `scripts/check-fase3.sh` — no extra shellcheck wiring needed.)

- [ ] **Step 2: Simulate the full CI locally**

Run:
```bash
bash scripts/validate-skills.sh && bash scripts/check-fase1.sh && bash scripts/check-fase3.sh && shellcheck -S warning instalar_imersao.sh scripts/*.sh && echo "CI-LOCAL OK"
```
Expected: ends with `CI-LOCAL OK` (exit 0).

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/validate.yml
git commit -m "ci(fase3): roda a guarda de invariantes da honestidade real-ou-demonstracao" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 6: Version bump, E2E acceptance, and memory

**Files:**
- Modify: `plugins/imersao/.claude-plugin/plugin.json`
- Modify (memory): `~/.claude/projects/-Users-gustavoparis-www-imersao-setup/memory/pipeline-4-fases.md`

- [ ] **Step 1: Bump the plugin version (minor — new feature)**

In `plugins/imersao/.claude-plugin/plugin.json`, change `"version": "1.7.0"` to `"version": "1.8.0"`.

- [ ] **Step 2: E2E acceptance — run Fase 3 live on an AI-feature plan**

This is the real proof (spec §12). In a throwaway project whose `plano-do-produto.md` includes an AI feature, invoke Fase 3 and confirm each:

- [ ] Detects external capabilities **from the plan** and surfaces them before the scaffold.
- [ ] API-key warning happens **BEFORE building**, in plain PT-BR: separate from the Claude subscription, centavos per use.
- [ ] Question offers **já tenho / criar agora / demonstração**; guided path walks console.anthropic.com step by step.
- [ ] Key lands in `.env`; **`.env` is in `.gitignore`** (verify with `git check-ignore .env`); key never echoed or committed; minimal test call validates it.
- [ ] In demo mode, the UI shows the **"modo demonstração" badge** on demo responses; real responses never show it.
- [ ] **1-step swap works:** paste key into `.env` + restart → real, zero code edits; README documents it in PT ("Como ativar a IA de verdade").
- [ ] **`docs/o-que-e-real.md`** written with an honest real/demo table.
- [ ] Fase 1 plan (re-run on a fresh idea) records key+cost in "Conexões de fora".
- [ ] An app with **no external capabilities** gets **zero new pauses**.
- [ ] All student-facing copy is **PT-BR, jargon-free**; each new concept narrated in 1 line on first use.

If any criterion fails, fix the command file (and re-run `bash scripts/check-fase3.sh`) before continuing.

- [ ] **Step 3: Update memory to record the change**

In `~/.claude/projects/-Users-gustavoparis-www-imersao-setup/memory/pipeline-4-fases.md`, under "Decisões travadas", add a bullet:

```
- **Fase 3 redesenhada (1.8.0, SP3):** capacidades externas (IA primeiro) são **reais ou demonstração explícita** — aluno decide, avisado ANTES de construir. Chave de API = pré-condição interativa (criar guiado via console.anthropic.com ou demo com selo "modo demonstração" + troca de 1 passo via `.env`). Padrão prescrito: módulo único de IA, SDK oficial, Haiku por padrão, `.env` no `.gitignore` (Next não cobre!). Registro `docs/o-que-e-real.md` no app do aluno (insumo do futuro SP4). Fase 1 avisa chave+custo nas "Conexões de fora"; Fase 4 cobre `ANTHROPIC_API_KEY` nas Variables do Railway. Guarda `scripts/check-fase3.sh` no CI. Spec/plano em `docs/superpowers/{specs,plans}/2026-06-09-fase3-real-api-key*`.
```

- [ ] **Step 4: Commit the version bump (memory files live outside the repo — not staged)**

```bash
git add plugins/imersao/.claude-plugin/plugin.json
git commit -m "chore(release): imersao 1.8.0 - Fase 3 com funcionalidade real + chave de API" \
  --trailer "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

- [ ] **Step 5: Cut the release (separate ceremony)**

The repo uses git tags + GitHub releases (`v1.8.0`). Run the repo's release flow (`/release-maintenance` or `/project-release`) to tag `v1.8.0` and publish the release — **do not** hand-roll the tag here. This is left as an explicit, user-triggered step (it is also GATE 2 of the /goal arc — the push decision).

---

## Self-Review

**1. Spec coverage** — every spec section maps to a task:

| Spec | Task |
|---|---|
| §4.1 detect external capabilities (+ no-capability zero friction) | Task 2 (item 3) |
| §4.2 AI VIP path (warn, 3-way ask, guided creation) | Task 2 (item 3) |
| §4.3 other capabilities (Stripe test mode, e-mail demo, maps) | Task 2 (item 3) |
| §4.4 key handling invariants (.env, .gitignore, no echo, validation) | Task 2 (items 3 + 5.3 + 5.7) |
| §5 prescribed integration pattern (module, Haiku, badge, 1-step swap, tests) | Task 2 (item 5.7) |
| §6 honesty record `docs/o-que-e-real.md` | Task 2 (item 7) |
| §7 Fase 1 touch (key+cost in plan) | Task 3 (Steps 1-2) |
| §7 Fase 4 touch (Railway variable + demo narration) | Task 3 (Step 3) |
| §7 compass + process guide sync | Task 4 |
| §8 pedagogical guardrails | Task 2 (narration table + plain-PT copy throughout) |
| §9 guard + CI + version bump | Tasks 1, 5, 6 |
| §10 error handling (no section, invalid key, refuses both, demo deployed) | Task 2 (item 3) + Task 3 (Step 3) |
| §12 acceptance criteria | Task 6 (E2E checklist) |

No gaps. (§11 out-of-scope items — SP2, SP4 — intentionally absent.)

**2. Placeholder scan** — command content is complete (no TBD/TODO). Bracketed fragments inside the command are runtime fill-ins the agent speaks to the student, not plan placeholders. All Verify commands have exact expected output. Commit HEREDOC-free messages are runnable as-is (repo convention is `-m` + `--trailer`, per the Fase 1 plan).

**3. Name consistency** — guard anchors all match strings present in Task 2/3 content: `Conexões de fora`, `chave de API`, `separada da sua assinatura`, `centavos`, `criar agora`/`console.anthropic.com`, `modo demonstração`, `selo`, `silenciosa` (matches `silencios`), `ANTHROPIC_API_KEY`, `.gitignore`, `@anthropic-ai/sdk`, `Haiku` (matches `haiku` case-insensitive), `o-que-e-real.md`, `Stripe`. PRD anchors: `chave`, `centavos` (both in Task 3 Step 1 text). PUB anchors: `ANTHROPIC_API_KEY`, `modo demonstração` (both in Task 3 Step 3 text). Version bump 1.7.0 → 1.8.0 matches `plugin.json`.

**4. Trailer** — every commit uses the canonical trailer for this environment: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

**5. Verify-command stack match** — all tasks touch Markdown/Bash/YAML; Verify uses the repo's own guards (`check-fase1.sh`, `check-fase3.sh`, `validate-skills.sh`, `shellcheck`) — correct stack (no pnpm/vitest in this repo).

**6. Workflow-policy task** — mode is direct-to-main; per-task commits land on local `main`; the push/release is the /goal arc's GATE 2 (Task 6 Step 5), matching the Fase 1 precedent.
