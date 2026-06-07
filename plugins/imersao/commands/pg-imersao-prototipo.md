---
description: Fase 2 da imersão — vira o PRD em protótipo funcional no Design OS público.
---

# /pg-imersao-prototipo — Fase 2: PRD → protótipo

Você vai transformar o `docs/PRD.md` num **protótipo funcional** usando o **Design OS
público** (Builder Methods), e deixar o aluno **ajustar** o resultado em linguagem
natural.

## Pré-condição

1. Exija **`docs/PRD.md`**. Se não existir, peça ao aluno para rodar **`/pg-imersao-prd`**
   primeiro e pare.

## Subir o Design OS (uma pasta separada do app)

2. Verifique se já existe o clone em **`../<projeto>-design`**. Se **não** existir,
   imprima e peça para o aluno rodar (substituindo `<projeto>` pelo nome do projeto):

   ```bash
   git clone https://github.com/buildermethods/design-os.git ../<projeto>-design
   cd ../<projeto>-design
   git remote remove origin
   npm install
   npm run dev          # abre em http://localhost:3000
   ```

   **Nunca assuma que o servidor está no ar** — confirme que `http://localhost:3000`
   está rodando antes de continuar.

## Dirigir o design (autônomo até o fim)

3. Carregue o conteúdo de `docs/PRD.md` e **dirija os slash commands do Design OS na
   ordem**, alimentados pelo PRD:

   1. `/product-vision`  (sementeado pelo PRD)
   2. `/product-roadmap`
   3. modelagem de dados (data model)
   4. `/design-tokens`   (cores, tipografia)
   5. `/design-shell`    (o "casco" do app)
   6. `/design-screen`   (uma vez por seção do roadmap)
   7. `/sample-data`     (dados de exemplo)

   Rode tudo **de ponta a ponta**, sem pedir confirmação a cada passo.

## O único gate humano desta fase

4. 🛑 **Revisar e ajustar:** o aluno abre `http://localhost:3000`, olha o **protótipo
   vivo** e pede mudanças em **linguagem natural** ("deixa o card maior", "tira esse
   campo"). Para cada pedido, **re-rode apenas o `/design-screen` da(s) tela(s)
   afetada(s)** — nunca regenere silenciosamente telas já aprovadas. Repita até o aluno
   aprovar.

## Exportar o handoff

5. Rode o **`/export`** do Design OS. O pacote (componentes React + Tailwind + specs)
   fica em **`../<projeto>-design/export/`**.

6. **Próximo passo:** diga ao aluno para rodar **`/pg-imersao-implementar`** para
   construir o app de verdade a partir desse export + o PRD.
