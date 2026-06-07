---
name: prototype-first
description: Use ANTES de implementar qualquer feature de UI — prototipe e valide o design primeiro em vez de construir duas vezes. Roteia frontend web para o Design OS público (clone + npm run dev) e UI pequena para frontend-design; auto-pula em trabalho de backend, CLI ou biblioteca. Triggers — "nova tela", "nova página", "prototipar", "new screen", "new page", "redesign", "mockup".
---

# Prototype First

**Princípio:** nunca construa código de UI de produção duas vezes. Antes de escrever a
tela "pra valer", prototipe e valide o design — é mais barato mudar um protótipo do que
refatorar código já integrado.

## Quando esta skill se aplica

- ✅ Vai criar/redesenhar **tela, página ou fluxo** de uma aplicação web.
- ❌ **Auto-pule** (não use) quando o trabalho for **backend**, **CLI**, **script** ou
  **biblioteca** sem interface — vá direto implementar.

## Roteamento

### Frontend web completo → Design OS (público)

Para um app ou conjunto de telas, prototipe no **Design OS** da Builder Methods. Ele
roda localmente e é open-source — sem dependências privadas:

```bash
git clone https://github.com/buildermethods/design-os.git ../<projeto>-design
cd ../<projeto>-design
git remote remove origin
npm install
npm run dev          # http://localhost:3000
```

Depois, dentro dessa pasta com o Claude Code aberto, conduza o fluxo de design:

1. `/product-vision` — define visão, roadmap e formato dos dados
2. `/design-tokens` e `/design-shell` — sistema visual e casco do app
3. `/design-screen` — uma tela por seção (preview vivo em `localhost:3000`)
4. `/export` — gera o handoff (componentes React + Tailwind + specs)

Revise o **protótipo vivo** e ajuste em linguagem natural antes de exportar. Só então
parta para a implementação.

> Na imersão, os comandos `/pg-imersao-prototipo` (prototipar) e
> `/pg-imersao-implementar` (construir) já encadeiam esse fluxo de ponta a ponta.

### UI pequena / um componente isolado → frontend-design

Para um único componente ou uma tela simples que não justifica subir o Design OS, use a
skill `frontend-design` para gerar a UI direto, com qualidade visual.

## Regra de ouro

Saiu do protótipo aprovado? **Só aí** escreva o código de produção — portando o que foi
validado, não inventando de novo.
