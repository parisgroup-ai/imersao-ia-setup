# Processo da Imersão — da ideia ao app, de ponta a ponta

Este é o guia do fluxo que vamos usar na imersão: você sai de uma **ideia** e chega num
**app funcionando**, com banco de dados, passando por um **plano do produto** e por um **protótipo**
de design. Tudo guiado pelo Claude Code.

> Pré-requisito: ter rodado o instalador da imersão e as skills carregadas
> (`claude plugin update imersao` e reabrir o Claude Code).

> **👉 Perdido? Rode `/imersao:pg-imersao-start`** a qualquer momento — a bússola te diz
> em que passo você está e qual o próximo (sem fazer por você). É retomável: fechou tudo,
> rodou de novo, ela reorienta.

---

## Visão geral

```
  IDEIA
    │
    ▼   /imersao:pg-imersao-prd            (Fase 1 — conversa + pesquisa de mercado)
  docs/plano-do-produto.md
    │
    ▼   /imersao:pg-imersao-prototipo      (Fase 2 — Design OS público)
  protótipo vivo (localhost:3000)  →  export (React + Tailwind)
    │
    ▼   /imersao:pg-imersao-implementar    (Fase 3 — construir o app)
  APP FUNCIONANDO  (Next.js + Postgres em Docker)
    │
    ▼   /imersao:pg-imersao-publicar       (Fase 4 — colocar no ar)
  APP NO AR  (GitHub + Railway, link público)

        └── motor: /imersao:pg-imersao-goal (autônomo, 2 gates humanos) ──┘
```

São **4 comandos** (um por fase) rodando sobre **um motor** (`/imersao:pg-imersao-goal`) que
dirige o trabalho sozinho e só para 2 vezes para você decidir.

---

## Estrutura de pastas — DOIS repositórios

Você vai ter duas pastas lado a lado:

```
~/www/
  meu-projeto/            ← o APP de verdade. O plano do produto mora aqui. É aqui que o app é construído.
  meu-projeto-design/     ← clone do Design OS. SÓ para prototipar. Roda em localhost:3000.
```

Manter separado evita misturar as dependências do Design OS com as do seu app.

---

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

---

## Fase 2 — `/imersao:pg-imersao-prototipo` (PRD → protótipo)

Dentro do Claude do app, rode:

```
/imersao:pg-imersao-prototipo
```

O comando **faz o setup do Design OS sozinho** — clona o repositório público numa
pasta irmã, instala as dependências, sobe o servidor em `http://localhost:3000` e abre
no navegador. **Você não cola nenhum bloco de comandos.** (Se a porta 3000 estiver
ocupada, ele te avisa e usa outra.)

Depois do setup, **tudo acontece nesta mesma conversa** — você **não** abre um segundo
Claude. O próprio Claude do app conduz o Design OS (desenha as telas na ordem: visão →
roadmap → dados → tokens → shell → telas → dados de exemplo) e o navegador atualiza ao
vivo. Você só vai conversando e pedindo o que quiser.

🛑 **Gate 2 — revisar e ajustar.** Na **aba do navegador que o Claude abriu pra você**,
veja o protótipo **vivo** e peça mudanças em **linguagem natural** ("aumenta o card",
"tira esse campo").
Ele re-desenha só as telas afetadas, ali na conversa. Quando estiver bom, peça pra
**exportar** → o pacote (componentes React + Tailwind + specs) vai para
`../meu-projeto-design/product-plan/` (e o zip `product-plan.zip`).

> 💡 O **servidor** do Design OS roda destacado (não cai sozinho). O **design** acontece
> nesta conversa do Claude do app — é com ele que você fala. Pra parar o servidor depois:
> `kill $(cat ../meu-projeto-design/.dev-server.pid)`.

---

## Fase 3 — `/imersao:pg-imersao-implementar` (export → app completo)

De volta em `meu-projeto/`:

```
/imersao:pg-imersao-implementar
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

```bash
docker compose up -d     # sobe o Postgres
npm run dev              # sobe o app
```

Depois ele porta os componentes, liga os dados e escreve testes — tarefa por tarefa. No
fim, ele deixa um **`docs/o-que-e-real.md`** no projeto: o registro honesto do que está
funcionando de verdade e do que está em demonstração (e o que falta pra ativar).

🛑 **Gate final — integração.** No fim, você escolhe como fechar o trabalho (merge, PR
ou segurar).

---

## Fase 4 — `/imersao:pg-imersao-publicar` (app local → no ar)

Com o app rodando no seu computador, é hora de **colocar no ar**:

```
/imersao:pg-imersao-publicar
```

Duas partes: o Claude **guarda seu código no GitHub** (cria o repositório e dá push) e
depois te **guia no Railway** (alguns cliques no navegador) — criar o projeto a partir do
seu GitHub, adicionar um **Postgres na nuvem**, ligar o app ao banco (`DATABASE_URL`),
rodar as migrations no deploy e **gerar o link público**.

No fim você tem uma **URL** que qualquer pessoa abre. E daí pra frente é só `git push`: o
Railway **republica sozinho** a cada mudança.

> Pré-requisitos: conta no **GitHub** (autenticada com `gh auth login`) e no **Railway**
> (Hobby **$5/mês**, exige cartão; Trial grátis sem cartão pra testar). O app precisa
> **buildar** (`npm run build`).

---

## Por que Next.js (e não Vite + React)?

Porque o app tem **banco de dados**. O Next.js entrega **frontend + backend + acesso ao
Postgres num repositório só** — o aluno mantém um modelo mental e um projeto. Vite +
React é só frontend; para falar com o banco você teria que montar um backend separado,
o que adiciona complexidade que não ajuda no objetivo da imersão.

---

## O que esperar nos gates humanos

| Gate | Quando | O que você faz |
|---|---|---|
| Aprovar design | Fim da Fase 1 | Lê o resumo, aprova ou ajusta |
| Revisar protótipo | Durante a Fase 2 | Olha a aba do navegador que abriu, pede mudanças em linguagem natural |
| Integração final | Fim da Fase 3 | Escolhe merge / PR / segurar |

---

## Quando um teste teima em falhar

Na Fase 3, se um teste falhar, o Claude tenta corrigir sozinho (método de depuração
sistemática). Depois de **3 tentativas** sem sucesso, ele **para e pede ajuda ao
instrutor** — isso é proposital, para não entrar em loop. Instrutores: fiquem atentos a
esse ponto de pausa.

---

## Qual comando usar quando

| Comando | Fase | Para quê |
|---|---|---|
| `/imersao:pg-imersao-prd` | 1 | Ideia → `docs/plano-do-produto.md` |
| `/imersao:pg-imersao-prototipo` | 2 | Plano → protótipo no Design OS → export |
| `/imersao:pg-imersao-implementar` | 3 | Export + plano → app funcionando |
| `/imersao:pg-imersao-publicar` | 4 | App local → no ar (GitHub + Railway) |
| `/imersao:pg-imersao-goal` | — | Dirigir um objetivo livre do início ao fim |

---

## Nota de manutenção (para a organização)

As skills-base de método (`brainstorming`, `writing-plans`, `executing-plans`,
`finishing-a-development-branch`, `test-driven-development`, `systematic-debugging`,
`subagent-driven-development`, `verification-before-completion`) são **vendorizadas** no
plugin `imersao` (cópias limpas, sem acoplamento a ferramentas internas). Quando o
upstream (superpowers) evoluir, faça um **re-sync manual** dessas pastas e rode
`bash scripts/validate-skills.sh`.
