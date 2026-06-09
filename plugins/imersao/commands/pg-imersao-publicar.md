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
5. **Se o app usa chave de IA (ou outro serviço de fora):** "Ainda em **Variables**, clique
   em **New Variable** e crie **`ANTHROPIC_API_KEY`**, colando o **valor da sua chave**
   (aqui é o valor mesmo, não referência)." Narre o porquê: "o ar não lê o arquivo `.env`
   do seu computador — a chave precisa ser colocada lá também." Se o aluno seguiu em
   **modo demonstração**: diga com clareza que o app no ar fica em demonstração (com o
   selo) até ele colocar a chave — e tá tudo bem publicar assim.
6. **Gerar o link público:** "Em **Settings → Networking**, clique em **Generate Domain**."
   O Railway te dá uma URL tipo `seu-app.up.railway.app`.

## 3. Confirmar no ar

- Abra a URL (`open <url>`) e confirme que o app carrega. Se der erro, veja os logs do
  deploy no Railway (**Deployments → View logs**) e **traduza** o problema pro aluno em
  português — nunca o log cru.
- Narre a vitória: "Seu app está **no ar** 🎉 — esse link funciona pra qualquer pessoa."

## 4. Atualizar depois (auto-deploy)

Explique o ciclo dali pra frente, simples: "Toda vez que você mudar algo e der `git push`,
o Railway publica a nova versão **sozinho**. Você programa, dá push, e o ar atualiza."

> O `/imersao:pg-imersao-implementar` (e o motor) já commitam as mudanças; pra publicar uma
> versão nova é só `git push`. O Railway faz o resto.
