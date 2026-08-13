---
description: "Dia 2 · CONSTRUIR — onda 1 (MVP) com writing-plans + executing-plans. O resto do produto fica no plano, na mesma pasta."
---

# /imersao:pg-imersao-implementar — Dia 2: export + plano → onda 1 funcionando

Você vai construir a **onda 1** (o MVP de hoje), a partir do protótipo exportado e do
plano (`docs/PRD.md` ou `docs/plano-do-produto.md`), na stack pública da imersão.

**Não use `/imersao:pg-imersao-goal` para construir.** Goal na sala é só no Dia 3, para
**refinar**. Aqui: tabela de ondas → `/writing-plans` → `/executing-plans` só da onda 1.
**E "de verdade" quer dizer de verdade:** nada de funcionalidade fingida sem avisar. O que
depender de serviço de fora (IA, pagamento, e-mail…) é **real ou demonstração explícita**
— e o aluno decide isso ANTES de você construir (item 3).

## Narração didática (construir, mas o aluno entende a lógica)

Esta fase tem a mecânica mais técnica (banco, migration, testes). Siga a regra da
imersão: **automatize a mecânica, narre o conceito em 1 linha**. Aqui vão os conceitos
específicos desta fase — explique cada
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

1. Trabalhe **a partir da pasta do app** (a mesma do plano). Na sala: `~/founders-ai/projeto`.
   Derive o plano e a pasta do design:

   ```bash
   APP="$(basename "$PWD")"
   if [ -f docs/PRD.md ]; then PLAN=docs/PRD.md
   elif [ -f docs/plano-do-produto.md ]; then PLAN=docs/plano-do-produto.md
   else echo "Falta docs/PRD.md ou docs/plano-do-produto.md — rode o Prompt 2 ou /imersao:pg-imersao-prd."; exit 1; fi
   if [ -d ../projeto-design ]; then DESIGN_DIR="../projeto-design"
   else DESIGN_DIR="../${APP}-design"; fi
   { [ -f "$DESIGN_DIR/product-plan.zip" ] || [ -d "$DESIGN_DIR/product-plan" ] || [ -d product-plan ]; } \
     || { echo "Falta o export — rode o Prompt 3 ou /imersao:pg-imersao-prototipo."; exit 1; }
   echo "PLAN=$PLAN DESIGN=$DESIGN_DIR"
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

3. Antes de construir, leia o **mapa de ondas** e a seção **"Conexões de fora"** do `$PLAN`
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

## Plano técnico — mapa de ondas, depois writing-plans

O design **já foi aprovado** (plano + protótipo) — esta fase **não re-aprova design**.
**Não** chame `/imersao:pg-imersao-goal` aqui.

4. **Passo zero — tabela de ondas.** Antes de qualquer tarefa, mostre e espere o aluno
   confirmar:

   | Onda | O que entra | Quando | Onde |
   | 1 — hoje (MVP) | fluxo principal + dado que persiste + conexões obrigatórias | hoje | esta pasta |
   | 2+ | cada item do plano que ficou fora | depois da imersão | a mesma pasta |

   Diga: “Hoje construímos a **onda 1**. O produto que você imaginou continua no plano.”
   Sem essa confirmação, o plano não vale. Nada da visão some. Não chame onda 2+ de
   “fora do escopo”.

5. Invoque a skill **`writing-plans`**. Fontes, nesta ordem: `$PLAN` (com mapa de ondas),
   `$DESIGN_DIR/product-plan/` (ou `product-plan/` se já copiado). Tarefas **somente da
   onda 1**. Se a skill pedir cobertura de toda a spec, as ondas 2+ vão para a seção
   final **“Como continuar depois”** — não viram tarefa. Salve em
   `docs/superpowers/plans/`. **Não execute ainda.**

6. Invoque a skill **`executing-plans`** no plano aprovado. Só a onda 1. Se o plano
   misturar onda 2 no meio, **pare**, separe e peça confirmação.

## Como o plano DEVE começar (Task 1 — scaffold)

7. A **primeira tarefa** do plano monta o esqueleto **de forma não interativa** (todo
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

## Tarefas seguintes (ainda onda 1)

8. Depois do scaffold, o plano segue tarefa a tarefa (TDD), **só o que é onda 1**:
   - **portar os componentes** exportados (React + Tailwind), seção por seção;
   - **ligar os dados** com Drizzle (queries/migrations);
   - **route handlers / server actions** para as ações;
   - **testes** para cada comportamento;
   - **regra de honestidade em TODA tarefa:** funcionalidade prometida no plano nasce
     **real** (com a conexão de verdade) ou **demonstração marcada com o selo** — nunca
     uma simulação calada que parece real.

## Antes da entrega: o registro do que é real

9. Antes do gate final, escreva **`docs/o-que-e-real.md`** no projeto do aluno (português
   simples, sem jargão):
   - uma tabela: **funcionalidade → real / demonstração → o que falta pra ativar** (ex.:
     "Resumo com IA → demonstração → colar sua chave no arquivo `.env`");
   - uma linha lembrando que os dados estão só no seu computador até a Fase 4.

   Narre em 1 linha: "deixei anotado o que está funcionando de verdade e o que está em
   demonstração — fica em `docs/o-que-e-real.md`."

10. Gate humano da entrega: mostre o app rodando e o mapa de ondas de novo. A onda 1
    funciona; as ondas 2+ estão em “Como continuar depois”. Ao final:
    `docker compose up -d && npm run dev` → **onda 1 de ponta a ponta**.

    Diga: “Esta pasta continua sendo o produto. Semana que vem você pede a onda 2.
    Outro produto = outra pasta.”
