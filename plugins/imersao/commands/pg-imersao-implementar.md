---
description: Fase 3 da imersão — implementa o app de ponta a ponta a partir do export do Design OS + PRD.
---

# /imersao:pg-imersao-implementar — Fase 3: export + PRD → app completo

Você vai construir o **app de verdade**, de ponta a ponta, a partir do protótipo
exportado pelo Design OS e do `docs/PRD.md`, na stack pública da imersão.

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

1. Exija o **export do Design OS** em `../<projeto>-design/export/` e o **`docs/PRD.md`**.
   Se faltar o export, peça para rodar **`/imersao:pg-imersao-prototipo`** antes. Trabalhe a
   partir da pasta do **app** (`meu-projeto/`).

2. **Cheque o Docker ANTES de começar** — esta fase usa um banco Postgres em Docker. Rode
   `docker info` silenciosamente:
   - Respondeu OK → siga.
   - Falhou → **NÃO** mostre o erro técnico do daemon. Diga em português: "Pra essa parte
     eu preciso do **Docker** ligado. Abra o app **Docker Desktop** (Launchpad → ícone do
     Docker) e espere a baleia 🐳 na barra de cima parar de animar (~1 min); aí me avise."
     Só prossiga quando `docker info` responder OK.

## Disparar o motor

3. Acione o motor autônomo:

   ```
   /imersao:pg-imersao-goal "implementar o app conforme docs/PRD.md e o export do Design OS em ../<projeto>-design/export/"
   ```

## Como o plano DEVE começar (Task 1 — scaffold)

4. A **primeira tarefa** do plano gerado precisa montar o esqueleto **de forma não
   interativa** (use flags que evitem prompts), com **banco em Docker desde o dia 1**:

   - **Next.js** (App Router, TypeScript) — `create-next-app` não interativo
   - **Tailwind CSS** + **shadcn/ui**
   - **Drizzle ORM**
   - **`docker-compose.yml`** com **Postgres 16**
   - **`.env.example`** (com `DATABASE_URL`)
   - **primeira migration** do Drizzle
   - rota **`/api/health`** que faz um SELECT simples no banco

   E **suba o banco antes de qualquer feature**:

   ```bash
   docker compose up -d        # Postgres no ar
   npm run dev                 # app no ar
   ```

## Tarefas seguintes

5. Depois do scaffold, o plano segue tarefa a tarefa (TDD):
   - **portar os componentes** exportados (React + Tailwind), seção por seção;
   - **ligar os dados** com Drizzle (queries/migrations);
   - **route handlers / server actions** para as ações;
   - **testes** para cada comportamento.

6. Os **gates humanos** (aprovar plano e integração final) são conduzidos pelo
   `/imersao:pg-imersao-goal`. Ao final: `docker compose up -d && npm run dev` → **app
   funcionando de ponta a ponta**, fácil de mexer e ajustar.
