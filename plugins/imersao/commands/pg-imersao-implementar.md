---
description: "Fase 3 · CONSTRUIR — implementa o app de ponta a ponta a partir do export do Design OS + plano."
---

# /imersao:pg-imersao-implementar — Fase 3: export + PRD → app completo

Você vai construir o **app de verdade**, de ponta a ponta, a partir do protótipo
exportado pelo Design OS e do `docs/plano-do-produto.md`, na stack pública da imersão.

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

## Disparar o motor

O design **já foi aprovado** nas Fases 1 e 2 (plano + protótipo) — esta fase **não
re-aprova design**. O motor pula direto pro plano técnico e só pausa na **entrega final**.

3. Acione o motor autônomo:

   ```
   /imersao:pg-imersao-goal "implementar o app conforme docs/plano-do-produto.md e o export do Design OS em $DESIGN_DIR/product-plan/ — o design JÁ está aprovado (plano + protótipo), então PULE o brainstorming e vá direto pro plano técnico; só pause na entrega final. Monte o Next.js NA PRÓPRIA pasta do app (não num subdiretório novo)"
   ```

## Como o plano DEVE começar (Task 1 — scaffold)

4. A **primeira tarefa** do plano monta o esqueleto **de forma não interativa** (todo
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
      **não** `.env.example`).
   4. **Suba o banco e ESPERE ficar pronto** antes da migration (em máquina fria o Docker
      baixa a imagem e o Postgres leva alguns segundos pra aceitar conexão):
      ```bash
      docker compose up -d
      until docker compose exec -T db pg_isready -U app >/dev/null 2>&1; do sleep 1; done
      ```
   5. **primeira migration** do Drizzle (gerar + aplicar).
   6. rota **`/api/health`** que faz um SELECT simples no banco.

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

5. Depois do scaffold, o plano segue tarefa a tarefa (TDD):
   - **portar os componentes** exportados (React + Tailwind), seção por seção;
   - **ligar os dados** com Drizzle (queries/migrations);
   - **route handlers / server actions** para as ações;
   - **testes** para cada comportamento.

6. Os **gates humanos** (aprovar plano e integração final) são conduzidos pelo
   `/imersao:pg-imersao-goal`. Ao final: `docker compose up -d && npm run dev` → **app
   funcionando de ponta a ponta**, fácil de mexer e ajustar.
