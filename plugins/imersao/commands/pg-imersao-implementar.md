---
description: Fase 3 da imersão — implementa o app de ponta a ponta a partir do export do Design OS + PRD.
---

# /imersao:pg-imersao-implementar — Fase 3: export + PRD → app completo

Você vai construir o **app de verdade**, de ponta a ponta, a partir do protótipo
exportado pelo Design OS e do `docs/PRD.md`, na stack pública da imersão.

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
