---
description: "Fase 1 · DEFINIR — conversa rápida pra transformar sua ideia no documento do projeto."
argument-hint: "<sua ideia em uma frase>"
---

# Fase 1 — sua ideia vira o documento do projeto

Conduza uma **conversa curta e amigável** (NÃO uma entrevista técnica) pra transformar a
ideia do aluno num documento simples do projeto. O aluno é **iniciante, possivelmente
não-programador** — fale 100% em **português coloquial, sem jargão**. A ideia inicial
está em **$ARGUMENTS**.

## Regras de ouro (leia antes de começar)

- **NÃO invoque a skill `brainstorming` genérica** nesta fase. Conduza você mesmo, com o
  roteiro abaixo. (Aquela skill é de engenharia: propõe arquitetura, salva em outro
  caminho e levaria pro plano técnico — não é o que queremos aqui.)
- **Sem "visual companion", sem propor "abordagens técnicas", sem falar de arquitetura.**
  A parte visual é a Fase 2.
- **Nunca diga ao aluno** estas palavras: "PRD", "spec", "hard-gate", "JTBD", "MVP",
  "data shape", "repositório", "commit", "branch". Traduza tudo pro dia a dia.
- **Uma pergunta por vez.** Prefira opções (a/b/c) a perguntas abertas.

## Passo 1 — preparar a pasta (silencioso, sem falar de "git")

Garanta que a pasta do projeto está pronta: se não houver repositório, rode `git init`
por baixo dos panos. Em seguida, **só se** estiverem vazios, defina uma identidade git
**local** (nunca `--global` — é só pra esta pasta, não mexa na identidade global do aluno):

```bash
git rev-parse --git-dir >/dev/null 2>&1 || git init -q
git config user.name  >/dev/null 2>&1 || git config user.name  "Aluno Imersão"
git config user.email >/dev/null 2>&1 || git config user.email "aluno@imersao.local"
```

Para o aluno, no máximo: "Já preparei a pasta do seu projeto."

## Passo 2 — a conversa (3 a 4 perguntas, uma por vez)

Abra com: "Um documento de projeto é só um resumo do que a gente vai construir e pra
quem — vamos montar isso juntos, conversando." Então pergunte, **uma por vez**:

1. "Em uma frase, o que você quer construir?" (se já veio em `$ARGUMENTS`, só confirme)
2. "Pra quem é? Quem vai usar?"
3. "Quais as **3 a 5 telas ou áreas** principais? (ex.: tela de entrar, lista de X, cadastro de Y)"
4. "O que **não** precisa entrar agora — pode ficar pra depois?"

**Derive o resto sozinho** (o que cada pessoa quer fazer, que informações o app guarda,
como saber que deu certo) a partir das respostas — **não pergunte isso diretamente**.
Onde faltar algo, proponha um rascunho e deixe o aluno só **confirmar ou ajustar**.

## Passo 3 — UM ponto de parada (o único momento de decisão)

Mostre um resumo em bullets simples e pergunte de forma fechada:

> "Esse é o resumo do seu projeto: [bullets]. Tá tudo certo? Responde **sim** que eu já
> escrevo o documento, ou me diz o que mudar."

Espere o "sim" (ou ajustes). **Não** crie um segundo ponto de revisão depois.

## Passo 4 — salvar (silencioso)

Escreva `docs/PRD.md` com seções claras: **Visão** (o que é, pra quem), **Telas/Áreas**,
**O que o app guarda** (informações/entidades), **Fica pra depois**, **Como saber que deu
certo**. Salve e guarde a primeira versão por baixo dos panos (git add + commit, sem
mostrar o comando). Para o aluno: "Salvei e guardei a primeira versão do seu projeto. ✅"

## Passo 5 — fechamento humano

Conecte ao próximo **benefício concreto** (não a um "próximo comando"):

> "Pronto! Esse documento é o **mapa** do seu projeto. Agora a gente transforma ele numa
> **tela de verdade** que você vai poder ver e clicar. Quando quiser, é só pedir o próximo
> passo — digite **`/`** e escolha **`imersao:pg-imersao-prototipo`** na lista (não precisa
> decorar o nome)."
