---
description: "Fase 1 · DEFINIR — conversa guiada que transforma sua ideia no plano do produto."
argument-hint: "<sua ideia em uma frase>"
---

# Fase 1 — sua ideia vira o plano do produto

Conduza uma **conversa curta e amigável** (NÃO uma entrevista técnica, NÃO um
interrogatório) pra transformar a ideia do aluno num **plano do produto** claro. O aluno é
**iniciante, possivelmente não-programador** — fale 100% em **português coloquial, sem
jargão**. A ideia inicial está em **$ARGUMENTS**.

O foco é entender **O QUÊ construir** — a visão, quem usa, as funcionalidades, os fluxos e
as regras. **Nada de tecnologia** (stack, banco, arquitetura, código): isso é das Fases 2 e 3.

## Regras de ouro (leia antes de começar)

- **NÃO invoque a skill `brainstorming` genérica** nesta fase. Conduza você mesmo, com o
  roteiro abaixo. (Aquela skill é de engenharia: propõe arquitetura, salva em outro
  caminho e levaria pro plano técnico — não é o que queremos aqui.)
- **Sem arquitetura, sem "abordagens técnicas", sem código.** Tudo no nível do **produto**:
  o que o usuário faz, o que ele vê, o que o sistema decide. A parte visual é a Fase 2.
- **Poucas perguntas, uma por vez.** Faça só as **essenciais** (Passo 2) — todo o resto
  você **deriva e propõe** pro aluno só **confirmar**. NUNCA despeje uma lista de 20
  perguntas: isso afoga o iniciante.
- **Nunca diga ao aluno** estas palavras: "PRD", "spec", "MVP", "persona", "requisito
  funcional", "regra de negócio", "hard-gate", "commit", "branch". Traduza tudo pro dia a dia.
- Prefira opções (a/b/c) a perguntas abertas. Tom amigável, encorajador, colaborativo.

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

## Passo 2 — a conversa (poucas perguntas essenciais, uma por vez)

Abra com: "Um plano do produto é só um resumo claro do que a gente vai construir, pra quem
e como funciona — vamos montar isso juntos, conversando." Então pergunte, **uma por vez**
(use a resposta anterior pra puxar a próxima; se algo já veio em `$ARGUMENTS`, só confirme):

1. "Em uma frase, o que você quer construir — e que **problema** isso resolve?"
2. "Quem vai **usar**? Tem mais de um tipo de pessoa? (ex.: quem administra e quem só usa)"
3. "Quais as **3 a 6 telas ou áreas** principais? (ex.: entrar, lista de X, cadastro de Y)"
4. "Em cada área, o que a pessoa **faz** — e tem alguma **regra** importante? (ex.: só o
   dono pode editar; não dá pra agendar no passado)"
5. "Precisa de **conta/login**? Depende de algo **de fora** — pagamento, e-mail, mapa,
   notificação?"
6. "O que **não** precisa entrar agora — pode ficar pra depois?"

**Derive o resto sozinho** (o que cada pessoa quer alcançar; que informações o app guarda e
como se relacionam; o que aparece quando **não há nada ainda** ou quando **dá erro**; como
saber que deu certo) — **não pergunte item a item**. Onde faltar, **proponha um rascunho** e
deixe o aluno só **confirmar ou ajustar**. Seja proativo: se a ideia implica algo não dito
(uma tela vazia, um erro, uma permissão), levante de leve — sem afogar.

## Passo 3 — UM ponto de parada (o único momento de decisão)

Mostre um resumo em bullets simples e pergunte de forma fechada:

> "Esse é o resumo do seu produto: [bullets]. Tá tudo certo? Responde **sim** que eu já
> escrevo o plano, ou me diz o que mudar."

Espere o "sim" (ou ajustes). **Não** crie um segundo ponto de revisão depois.

## Passo 4 — salvar o plano do produto (silencioso)

Escreva **`docs/plano-do-produto.md`** — um plano **claro, focado no produto** (zero
tecnologia), em linguagem simples. Inclua só o que você de fato entendeu ou derivou — use
o **nome do produto** no topo e só as seções que fizerem sentido pra ideia:

1. **Visão** — o que é, que problema resolve, pra quem, e o valor principal.
2. **Quem usa** — os tipos de pessoa e o que cada uma pode **ver e fazer**.
3. **Funcionalidades** — a lista, marcando o que é **essencial agora** vs **fica pra depois**.
4. **Como o usuário usa (fluxos)** — o passo a passo das ações principais, incluindo o que
   aparece quando **não há nada ainda** e quando **dá erro**.
5. **Telas e navegação** — cada tela principal: pra que serve, o que mostra, o que dá pra
   fazer ali, e como se chega/sai dela.
6. **Informações** — que dados o app guarda (em linguagem do dia a dia) e como se
   relacionam; o que é privado ou sensível.
7. **Conta e permissões** — precisa entrar? quem vê e faz o quê.
8. **Conexões de fora** — do que depende (pagamento, e-mail, mapa…), quando aparece na
   jornada, e o que o usuário sente se aquilo falhar.
9. **Regras** — o que o sistema precisa garantir; limites, exceções, e o que dizer quando
   algo dá errado.
10. **Entrega por fases** — Fase 1 (o essencial pra já valer a pena), Fase 2 (expansão),
    Fase 3 (polimento).
11. **Em aberto / futuro** — dúvidas que ainda precisam ser decididas e ideias que ficaram
    pra depois.

> Não invente conteúdo que o aluno não validou — onde derivou algo, deixe claro que é um
> rascunho pra ele ajustar depois.

Salve e guarde a primeira versão por baixo dos panos (git add + commit, sem mostrar o
comando). Para o aluno: "Salvei o plano do seu produto. ✅"

## Passo 5 — fechamento humano

Conecte ao próximo **benefício concreto** (não a um "próximo comando"):

> "Pronto! Esse plano é o **mapa** do seu produto. Agora a gente transforma ele em **telas
> de verdade** que você vai poder ver e clicar. Quando quiser, é só pedir o próximo passo —
> digite **`/`** e escolha **`imersao:pg-imersao-prototipo`** na lista (não precisa decorar
> o nome)."
