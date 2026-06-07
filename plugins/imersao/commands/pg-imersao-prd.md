---
description: Fase 1 da imersão — transforma a ideia num PRD via brainstorming guiado.
argument-hint: "<ideia do projeto>"
---

# /pg-imersao-prd — Fase 1: ideia → PRD

Você vai conduzir o aluno da ideia bruta até um **PRD** (documento de produto) sólido,
usando a skill `brainstorming`. A ideia inicial está em **$ARGUMENTS** (se vazia,
comece perguntando "Em uma frase, o que você quer construir?").

## Passo a passo

1. **Garanta o repositório do app.** Confirme que estamos dentro da pasta do projeto
   (`meu-projeto/`). Se não houver repositório git aqui, ofereça `git init` antes de
   seguir. (O protótipo do Design OS vai morar numa pasta separada — isso é a Fase 2.)

2. **Invoque a skill `brainstorming`** num diálogo guiado, amigável para iniciante,
   **uma pergunta por vez**, cobrindo:
   - **Problema:** que dor o produto resolve?
   - **Usuário-alvo:** para quem é? (1 persona principal)
   - **Jobs-to-be-done:** o que a pessoa quer realizar?
   - **Escopo do MVP:** o que entra agora (in) e o que fica para depois (out)?
   - **Telas/seções principais:** as 3–6 áreas do produto.
   - **Data shape inicial:** as entidades principais e seus campos.
   - **Critérios de sucesso:** como saber que funcionou?

3. 🛑 **GATE HUMANO (aprovar design):** apresente o design resumido e **espere o aluno
   aprovar** antes de escrever o documento (hard-gate do brainstorming).

4. **Escreva `docs/PRD.md`** — a **fonte da verdade** do projeto — com as seções:
   `Problema`, `Usuário`, `Jobs-to-be-done`, `Escopo do MVP (in/out)`,
   `Telas/Seções`, `Data shape`, `Critérios de sucesso`.

5. **Commit** do PRD: `git add docs/PRD.md && git commit -m "docs: PRD do projeto"`.

6. **Próximo passo:** diga ao aluno para rodar **`/pg-imersao-prototipo`** para virar
   o PRD num protótipo funcional no Design OS.
