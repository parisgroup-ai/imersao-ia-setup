---
description: Orquestrador autônomo da imersão — encadeia brainstorming → writing-plans → executing-plans → finishing com 2 gates humanos.
argument-hint: "<objetivo do projeto>"
---

# /pg-imersao-goal — motor autônomo da imersão

Você é o orquestrador. O objetivo do aluno está em **$ARGUMENTS**. Conduza o projeto
do começo ao fim encadeando as skills da imersão, **avançando sozinho** entre as
etapas e parando em **exatamente 2 momentos** para o humano decidir.

Se `$ARGUMENTS` estiver vazio, pergunte ao aluno: "Qual é o objetivo? (uma frase)".

## As 4 etapas (auto-avanço)

1. **brainstorming** — invoque a skill `brainstorming`. Explore a ideia, proponha o
   design e escreva o spec.
   → 🛑 **GATE HUMANO 1 (aprovar design):** só avance quando o aluno aprovar o design
   e o spec estiver escrito/commitado.

2. **writing-plans** — invoque a skill `writing-plans`. Quebre o spec em tarefas
   pequenas e testáveis (TDD). Salve o plano.
   → **Avance automaticamente** assim que o plano estiver salvo. Não pergunte nada.

3. **executing-plans** — invoque a skill `executing-plans`. Execute tarefa por tarefa
   no ciclo Red → Green → Verify → Commit. Se um teste falhar, entre em
   `systematic-debugging` (no máximo 3 tentativas; se persistir, **pare e peça ajuda ao
   instrutor**).
   → **Avance automaticamente** quando todas as tarefas estiverem feitas e commitadas.

4. **finishing-a-development-branch** — invoque a skill `finishing-a-development-branch`.
   Rode os testes, e apresente o menu de integração.
   → 🛑 **GATE HUMANO 2 (integração final):** o aluno escolhe como integrar (merge /
   PR / segurar).

## Regras do motor

- **Só 2 gates humanos:** o de aprovar design (etapa 1) e o de integração (etapa 4).
  Entre as etapas, **não peça confirmação** — avance assim que a condição de término
  da etapa for atingida.
- Objetivo é **texto livre**. Não há roadmap, backlog ou persistência de tarefas além
  do plano em markdown.
- **Commits** são feitos com `git` puro, mensagens em Conventional Commits, staging
  explícito dos arquivos (`git add <arquivos>`), sem `--no-verify`.
- Use TDD de verdade: teste primeiro, veja falhar, implemente o mínimo, veja passar.
- Antes de declarar qualquer etapa "pronta", **mostre a evidência** (saída do teste,
  do build) — nunca afirme sucesso sem rodar.

> Dica: para a imersão, os comandos de fase (`/pg-imersao-prd`, `/pg-imersao-prototipo`,
> `/pg-imersao-implementar`) já chamam este motor no momento certo. Use `/pg-imersao-goal`
> diretamente quando quiser dirigir um objetivo livre do início ao fim.
