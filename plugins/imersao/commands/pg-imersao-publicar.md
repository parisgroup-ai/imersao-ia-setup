---
description: "Fase 4 · PUBLICAR — sobe seu app pro GitHub e coloca no ar no Railway (link público)."
---

# /imersao:pg-imersao-publicar — Fase 4: colocar o app no ar

O app já roda no seu computador. Agora vamos **colocar ele no ar** — num link que
qualquer pessoa abre no navegador. São duas partes: **guardar o código no GitHub** e
**publicar no Railway** (que roda o app e o banco na nuvem, lendo do seu GitHub).

## Narração didática (Fase 4)

Automatize a mecânica, **narre o conceito em 1 linha** na primeira vez (nunca a sintaxe):

| Conceito | Diga assim |
|---|---|
| GitHub | "O GitHub é onde seu código fica guardado na nuvem, com histórico — tipo um Drive do programador." |
| deploy / no ar | "Publicar (deploy) é colocar seu app num link público, pra qualquer um abrir — não fica só no seu computador." |
| Railway | "O Railway é um serviço que roda seu app e seu banco na nuvem 24h, a partir do seu GitHub." |
| variável de ambiente | "Uma 'configuração secreta' (tipo o endereço do banco) que fica fora do código e muda em cada lugar." |
| registro de honestidade | "É um arquivo no seu projeto (`docs/o-que-e-real.md`) que anota o que funciona de verdade e o que está em demonstração — a gente confere ele antes de publicar." |

## Pré-condições

- Trabalhe na pasta do **app** (a mesma do `docs/plano-do-produto.md`), com o app já
  construído (tem `package.json` com `next`).
- O app precisa **buildar pra produção**. Rode silenciosamente; se falhar, conserte antes
  de seguir (narre em português, não mostre log cru):
  ```bash
  npm run build
  ```
- As **migrations do Drizzle** precisam estar **commitadas** (a Fase 3 já commita) — é o
  que cria as tabelas no banco da nuvem no deploy.
- O script `start` tem que ser o **`next start` padrão** (não fixe a porta com `-p 3000`) —
  o Railway injeta a porta sozinho e o `next start` a respeita.

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

## 1. Guardar o código no GitHub

1. Confirme que o aluno está autenticado; se não, conduza o login (narre: "Vou te conectar
   à sua conta do GitHub — siga as perguntas no terminal"):
   ```bash
   gh auth status >/dev/null 2>&1 || gh auth login
   ```
2. Crie o repositório e suba o código (privado por padrão), derivando o nome da pasta:
   ```bash
   APP="$(basename "$PWD")"
   git add -A && git commit -m "primeira versão do app" 2>/dev/null || true
   gh repo create "$APP" --private --source=. --remote=origin --push
   ```
   Narre: "Pronto, seu código está guardado no GitHub ✅."

## 2. Publicar no Railway (conectado ao GitHub)

O Railway lê do seu GitHub e faz o deploy sozinho. Esta parte tem **alguns cliques no
navegador**: o aluno clica, **você guia um passo de cada vez** (abra `open https://railway.app/new`).

1. **Criar o projeto a partir do repo:** "Em https://railway.app, faça login, clique em
   **New Project → Deploy from GitHub repo**, autorize o Railway a ver seu GitHub (uma vez)
   e escolha o repositório **`$APP`**."
2. **Adicionar o banco:** "Dentro do projeto, clique em **Create (ou + New) → Database →
   Add PostgreSQL** — isso cria seu banco na nuvem." (É um banco **novo, na nuvem** —
   diferente do Postgres em Docker do seu computador; o `docker-compose` era só pro local.)
3. **Ligar o app ao banco:** "No serviço do **app**, vá em **Variables → Add Reference**
   (variável de referência) → escolha o serviço **Postgres** → **DATABASE_URL**. O Railway
   insere `${{Postgres.DATABASE_URL}}` sozinho." (funciona porque o banco se chama `Postgres`
   por padrão — se você renomeou, use o novo nome). Narre o porquê (liga o app ao banco da nuvem).
4. **Criar as tabelas no deploy:** "No serviço do app, em **Settings → Deploy → Pre-deploy
   Command**, coloque `npx drizzle-kit migrate`." (roda as migrations no banco da nuvem
   antes do app subir — usa a mesma config do Drizzle da Fase 3, por isso elas precisam
   estar commitadas; se reclamar que não acha o `drizzle-kit`, crie um script
   `"db:migrate": "drizzle-kit migrate"` no `package.json` e use `npm run db:migrate`).
5. **Chave de IA / serviço de fora — conforme decidido no Passo 0** (o gate de honestidade;
   este passo **herda** aquela decisão): se ficou **real**, "Ainda em **Variables**, clique
   em **New Variable** e crie **`ANTHROPIC_API_KEY`**, colando o **valor da sua chave**
   (aqui é o valor mesmo, não referência)." Narre o porquê: "o ar não lê o arquivo `.env`
   do seu computador — a chave precisa ser colocada lá também." Se ficou **modo
   demonstração**: diga com clareza que o app no ar fica em demonstração (com o selo) até
   ele colocar a chave — e tá tudo bem publicar assim.
6. **Gerar o link público:** "Em **Settings → Networking**, clique em **Generate Domain**."
   O Railway te dá uma URL tipo `seu-app.up.railway.app`.

## 3. Confirmar no ar

- Abra a URL (`open <url>`) e confirme que o app carrega. Se der erro, veja os logs do
  deploy no Railway (**Deployments → View logs**) e **traduza** o problema pro aluno em
  português — nunca o log cru.
- Narre a vitória: "Seu app está **no ar** 🎉 — esse link funciona pra qualquer pessoa."
- **Atualize o registro:** acrescente/ajuste 1 linha no `docs/o-que-e-real.md` com a URL
  pública, a data e o estado no ar (real ou demonstração) — e commite. O registro continua
  sendo a fonte da verdade depois de publicar.

## 4. Atualizar depois (auto-deploy)

Explique o ciclo dali pra frente, simples: "Toda vez que você mudar algo e der `git push`,
o Railway publica a nova versão **sozinho**. Você programa, dá push, e o ar atualiza."

> O `/imersao:pg-imersao-implementar` (e o motor) já commitam as mudanças; pra publicar uma
> versão nova é só `git push`. O Railway faz o resto.
