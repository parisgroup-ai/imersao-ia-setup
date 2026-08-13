---
description: "Dia 3 · REFINAR — só o plano curto depois da validação. Não constrói o MVP. Não redesenha o produto."
argument-hint: "--plan <arquivo-do-plano-curto>  ou  <objetivo livre, fora da sala>"
---

# /imersao:pg-imersao-goal — na sala, só refina

Na turma Founders AI este comando **não constrói o app**.

| Quando | O que fazer |
|---|---|
| Dia 2, montar o MVP | **Pare.** Mande `/imersao:pg-imersao-implementar` ou o Prompt 5 (`/executing-plans`). |
| Dia 3, depois da validação, com plano curto | Execute **somente** esse plano. Não refaça playbook, PRD, Design OS nem a onda 1. |
| Objetivo livre, fora da sala | Aí sim o motor completo (abaixo), com mapa de ondas. |

O caderno: `caderno/Comece aqui.md`. Prompt oficial do Dia 3: `caderno/06-Prompts/Prompt 6 - Refinar.md`.

Se `$ARGUMENTS` estiver vazio, pergunte: "Qual o plano curto de hoje — ou é um objetivo novo, fora da imersão?"

## Se o argumento tem `--plan` ou um arquivo em `docs/superpowers/plans/`

Trate como **refinamento da onda 1 já pronta**:

1. Leia o plano curto. Se ele pedir reconstruir MVP, brainstorming, PRD ou Design OS — **pare** e corte essas tarefas.
2. Invoque `executing-plans` só no que está no plano curto.
3. Regressão: fluxo principal, persistência, conexões, testes, tipos, build.
4. Atualize `docs/o-que-e-real.md`.
5. Resumo + roteiro de apresentação. **Espere** autorização antes de publicar.

Não invente onda 2 no meio. Onda 2 é depois, na mesma pasta, com o Guia 2.

## Narração didática (turma de construtores de produto, não-devs)

- **Automatize o encanamento** (git, deps, comandos). O aluno **não digita** isso.
- **Narre o CONCEITO em UMA linha**, em português, na primeira vez.
- **Nunca** despeje jargão ou log cru sem traduzir.

| Conceito | Diga assim (1 linha, simples) |
|---|---|
| salvar versão (commit) | "Salvei um ponto do projeto que dá pra voltar depois, tipo um save de jogo." |
| teste | "Fiz um cheque automático que confirma que essa parte funciona — pra não quebrar sem você notar." |
| frontend / backend | "Frontend é o que você vê e clica; backend é o cérebro que processa e fala com o banco." |
| onda | "Onda 1 já está pronta. Agora a gente só corrige o que o uso mostrou — não começa o produto de novo." |

## Motor completo — SÓ objetivo livre (fora do trilho da sala)

Se o aluno pediu um produto **novo**, em pasta **nova**, sem imersão no meio:

1. **brainstorming** — *só se o design ainda NÃO estiver aprovado.*
   - **Se já existe um design aprovado** (um `docs/PRD.md` ou `docs/plano-do-produto.md` +
     um protótipo exportado): **NÃO refaça o brainstorming.** Vá ao mapa de ondas e ao plano.
   - **Senão:** invoque `brainstorming`, proponha o design, escreva o spec **com mapa de
     ondas** (visão, onda 1, ondas 2+, fora do escopo).
     → 🛑 **GATE HUMANO 1 (aprovar design + ondas):** só avance quando o aluno confirmar
     a tabela. “A onda 1 é o primeiro andar. O resto continua no plano.”

2. **writing-plans** — invoque `writing-plans`. Primeiro a tabela de ondas; tarefas só da
   onda 1; seção “Como continuar depois” para o resto. Salve o plano.
   → Avance automaticamente.

3. **executing-plans** — invoque `executing-plans` **só na onda 1**. Se um teste falhar,
   `systematic-debugging` (no máximo 3 tentativas; se persistir, **pare e peça ajuda ao
   instrutor**).
   → Avance quando a onda 1 estiver feita e commitada.

4. **finishing-a-development-branch** — testes + menu de integração.
   → 🛑 **GATE HUMANO 2 (entrega):** "salvar tudo no projeto" / "guardar pra revisar
   depois" — **nunca** "merge / PR / discard".

## Regras

- Na sala: **zero gates de construção**. Só executa o plano curto.
- Fora da sala: no máximo 2 gates (ondas + entrega).
- Commits com `git` puro, Conventional Commits, staging explícito, sem `--no-verify`.
- TDD nos bastidores. Traduza o resultado.
- Nunca simulação silenciosa. Real ou demonstração com selo.

> Dica: `/imersao:pg-imersao-prd` → `prototipo` → `implementar` → `publicar` já encadeiam
> a sala. Este comando, na turma, é o **refino do Dia 3**.
