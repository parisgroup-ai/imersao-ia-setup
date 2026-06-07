# Processo da Imersão — da ideia ao app, de ponta a ponta

Este é o guia do fluxo que vamos usar na imersão: você sai de uma **ideia** e chega num
**app funcionando**, com banco de dados, passando por um **PRD** e por um **protótipo**
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
    ▼   /imersao:pg-imersao-prd            (Fase 1 — brainstorming guiado)
  docs/PRD.md
    │
    ▼   /imersao:pg-imersao-prototipo      (Fase 2 — Design OS público)
  protótipo vivo (localhost:3000)  →  export (React + Tailwind)
    │
    ▼   /imersao:pg-imersao-implementar    (Fase 3 — construir o app)
  APP FUNCIONANDO  (Next.js + Postgres em Docker)

        └── motor: /imersao:pg-imersao-goal (autônomo, 2 gates humanos) ──┘
```

São **3 comandos** (um por fase) rodando sobre **um motor** (`/imersao:pg-imersao-goal`) que
dirige o trabalho sozinho e só para 2 vezes para você decidir.

---

## Estrutura de pastas — DOIS repositórios

Você vai ter duas pastas lado a lado:

```
~/www/
  meu-projeto/            ← o APP de verdade. O PRD mora aqui. É aqui que o app é construído.
  meu-projeto-design/     ← clone do Design OS. SÓ para prototipar. Roda em localhost:3000.
```

Manter separado evita misturar as dependências do Design OS com as do seu app.

---

## Fase 1 — `/imersao:pg-imersao-prd` (ideia → PRD)

Dentro de `meu-projeto/`, rode:

```
/imersao:pg-imersao-prd "um app pra agendar consultas do meu salão"
```

O Claude vai te entrevistar (uma pergunta por vez): problema, usuário, escopo do MVP,
telas, dados, critérios de sucesso. No fim ele te mostra o design.

🛑 **Gate 1 — aprovar o design.** Você aprova (ou pede ajustes). Aí ele escreve o
**`docs/PRD.md`** — a fonte da verdade do projeto.

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

Depois do setup, vem a **única parte manual** (inerente ao Design OS — os comandos de
design pertencem a ele): abra **outro terminal** na pasta do design e abra o Claude lá:

```bash
cd ../meu-projeto-design && claude
```

Nessa sessão, rode os comandos **do Design OS**, começando por `/product-vision` (o
`PRD.md` já foi copiado pra pasta), seguindo: roadmap → dados → `/design-tokens` →
`/design-shell` → `/design-screen` (uma por seção) → `/sample-data`.

🛑 **Gate 2 — revisar e ajustar.** Na **aba do navegador que o Claude abriu pra você**,
veja o protótipo **vivo** e peça mudanças em **linguagem natural** ("aumenta o card",
"tira esse campo").
Ele re-desenha só as telas afetadas. Quando estiver bom, rode o **`/export`** do Design
OS → o pacote (componentes React + Tailwind + specs) vai para `../meu-projeto-design/export/`.

> 💡 O servidor do Design OS roda **destacado** — você pode fechar a janela do Claude do
> app à vontade que ele continua no ar. Pra parar depois:
> `kill $(cat ../meu-projeto-design/.dev-server.pid)`.

---

## Fase 3 — `/imersao:pg-imersao-implementar` (export → app completo)

De volta em `meu-projeto/`:

```
/imersao:pg-imersao-implementar
```

Isso dispara o motor `/imersao:pg-imersao-goal`, que monta o app a partir do protótipo + PRD. A
**primeira tarefa** já sobe a base com **banco em Docker**:

- **Next.js** (App Router, TypeScript) + **Tailwind** + **shadcn/ui**
- **Drizzle ORM** + **Postgres 16 em Docker** (`docker-compose.yml`) + `.env`
- primeira migration + rota `/api/health`

```bash
docker compose up -d     # sobe o Postgres
npm run dev              # sobe o app
```

Depois ele porta os componentes, liga os dados e escreve testes — tarefa por tarefa.

🛑 **Gate final — integração.** No fim, você escolhe como fechar o trabalho (merge, PR
ou segurar).

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
| `/imersao:pg-imersao-prd` | 1 | Ideia → `docs/PRD.md` |
| `/imersao:pg-imersao-prototipo` | 2 | PRD → protótipo no Design OS → export |
| `/imersao:pg-imersao-implementar` | 3 | Export + PRD → app funcionando |
| `/imersao:pg-imersao-goal` | — | Dirigir um objetivo livre do início ao fim |

---

## Nota de manutenção (para a organização)

As skills-base de método (`brainstorming`, `writing-plans`, `executing-plans`,
`finishing-a-development-branch`, `test-driven-development`, `systematic-debugging`,
`subagent-driven-development`, `verification-before-completion`) são **vendorizadas** no
plugin `imersao` (cópias limpas, sem acoplamento a ferramentas internas). Quando o
upstream (superpowers) evoluir, faça um **re-sync manual** dessas pastas e rode
`bash scripts/validate-skills.sh`.
