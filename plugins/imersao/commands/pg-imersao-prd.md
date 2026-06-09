---
description: "Fase 1 · DEFINIR — conversa guiada que pesquisa o mercado, acha o ângulo mais forte e transforma sua ideia (ou o que você já tem) no plano do produto."
argument-hint: "<sua ideia em uma frase — ou rode numa pasta que já tem um projeto>"
---

# Fase 1 — sua ideia (ou o que você já tem) vira o plano do produto

Conduza uma **conversa curta e amigável** (NÃO um interrogatório técnico) pra transformar
a ideia do aluno num **plano do produto** claro — agora com dois superpoderes: você
**pesquisa o mercado de verdade** antes de desenhar, e oferece **alguns caminhos fortes**
pra convergir no melhor. O aluno é **iniciante, possivelmente não-programador** — fale
100% em **português coloquial, sem jargão**. A ideia inicial está em **$ARGUMENTS**.

O foco é entender **O QUÊ construir** (visão, quem usa, funcionalidades, fluxos, regras)
**e se vale a pena** (o mercado). **Nada de tecnologia** (stack, banco, código): isso é das
Fases 2 e 3.

## Regras de ouro (leia antes de começar)

- **NÃO invoque a skill `brainstorming` genérica.** Conduza você mesmo, com o roteiro abaixo.
- **Sem arquitetura, sem código.** Tudo no nível do **produto** e do **mercado**. A parte
  visual é a Fase 2.
- **A profundidade fica no SEU trabalho, não em mais perguntas pro aluno.** Pesquise,
  levante opções e **proponha** — o aluno responde pouco. NUNCA despeje uma lista de 20
  perguntas: isso afoga o iniciante.
- **Zero jargão.** Nunca diga ao aluno: "PRD", "spec", "MVP", "persona", "TAM", "willingness
  to pay", "moat", "PMF", "market sizing", "hard-gate", "commit", "branch". Traduza tudo
  pro dia a dia.
- **Verdade com caminho.** Se a pesquisa mostrar que a ideia é fraca, fale com tato — mas
  **sempre** junto com 2-3 caminhos mais fortes pra escolher. **Nunca** um "não" sem saída.
- Prefira opções (a/b/c) a perguntas abertas. Tom amigável, encorajador.

## Passo 1 — preparar a pasta (silencioso, sem falar de "git")

```bash
git rev-parse --git-dir >/dev/null 2>&1 || git init -q
git config user.name  >/dev/null 2>&1 || git config user.name  "Aluno Imersão"
git config user.email >/dev/null 2>&1 || git config user.email "aluno@imersao.local"
```

Para o aluno, no máximo: "Já preparei a pasta do seu projeto."

## Passo 2 — de onde a gente parte: ideia do zero, ou o que já existe?

Detecte se a pasta **já tem um projeto/conteúdo** (não conta `.git`, `.gitignore` nem
arquivos que a própria imersão gera):

```bash
HAS_CTX=nao
for sig in package.json pyproject.toml go.mod Cargo.toml composer.json pom.xml \
           src app lib index.html README.md data; do
  [ -e "$sig" ] && HAS_CTX=sim && break
done
echo "CONTEXTO=$HAS_CTX"
```

- **CONTEXTO=nao** → siga pro **Passo 3A** (ideia do zero).
- **CONTEXTO=sim** → **pergunte uma vez** (detecta e confirma):
  > "Vi que essa pasta **já tem coisa**. Quer que eu **olhe o que tem aqui e sugira o que
  > dá pra construir ou melhorar**, ou você tem uma **ideia nova do zero**?"
  - "ideia nova" → **Passo 3A** (ignore o que está na pasta como ponto de partida).
  - "o que tem" → **Passo 3B** (modo análise).

## Passo 3A — captar a ideia (modo "do zero")

Abra com: "Um plano do produto é só um resumo claro do que a gente vai construir, pra quem
e como funciona — e antes disso eu vou checar se a ideia tem mercado. Vamos montar juntos."

Pergunte (uma por vez; se já veio em `$ARGUMENTS`, só confirme):

1. "Em uma frase, o que você quer construir — e que **problema** isso resolve?"
2. **A lente de valor:** "Isso é mais pra você **vender** pra outras pessoas/empresas, ou
   pra **usar no seu próprio dia a dia / negócio** (resolver uma dor interna)?"
   - Se for interno: "Rapidinho — como você resolve isso hoje?"

Só isso por enquanto. As perguntas sobre telas, regras etc. vêm **depois** de escolher o
caminho (Passo 6) — agora você vai pesquisar.

## Passo 3B — analisar o que já existe (modo "em cima do que tem")

Explore a pasta (leia o código/docs/dados que houver) e entenda **o que é** e **que ativos
existem**. Narre em português simples, confirmando com o aluno:

> "Dei uma olhada aqui. Entendi que isso é **[o quê]**, que já tem **[ativos: telas, dados,
> integrações…]**. É isso mesmo?"

Depois, a mesma **lente de valor** — mas aqui você pode **propor** a partir do que viu e só
confirmar: "Pelo que vi, isso parece mais pra **[vender / uso interno]**, certo?"

## Passo 4 — pesquisar o mercado de verdade (você trabalha; o aluno espera)

Na **primeira vez**, narre o conceito em 1 linha:

> "Antes de desenhar, vou **pesquisar o mercado** de verdade — ver quem já faz parecido, se
> as pessoas pagam por isso, e quanto isso pode valer ou economizar. É barato descobrir
> agora se vende, antes de construir."

Pesquise **estruturado e cético**, usando **WebSearch + WebFetch** (abra páginas de verdade,
não só os trechos da busca; ~10-20 buscas focadas). Siga a **lente**:

- **Vender (mercado):** concorrentes diretos + substitutos (como resolvem hoje); preços e
  modelos de cobrança (lidos das páginas reais); **evidência de que pagam** (avaliações,
  reclamações, threads "alternativa ao X"); lacunas/diferenciação; riscos/barreiras.
- **Usar interno (economia):** como o processo é feito hoje (custo em tempo/dinheiro/erro);
  ferramentas existentes + impacto relatado; **benchmark de economia** (quanto operações
  parecidas economizaram); esforço de adoção × retorno; riscos.

**Passo cético (obrigatório):** depois de juntar, **tente refutar o sinal** — "qual o
argumento mais forte de que isso **não** vende / **não** economiza de verdade?" — e
incorpore o contra mais forte no veredito. (É o que separa pesquisa honesta de só procurar
o que confirma.)

**Sem internet/busca:** **não invente** número com cara de fonte. Diga que é um **chute
seu** e que o aluno deve confirmar depois.

**Escala opcional:** se o aluno quiser mais, ofereça — "quer que eu vá **ainda mais fundo**?
Posso fazer uma pesquisa bem mais detalhada, leva alguns minutos" — e aí sim use a skill
`deep-research`.

Escreva **`docs/pesquisa-de-mercado.md`** (PT simples, com as fontes): **Resumo** (o
veredito), **Lente** (vender/economia e por quê), **Panorama** (concorrentes / processo
atual; em modo análise, inclua "Análise do contexto existente"), **O sinal** (números +
fontes), **Direções consideradas**, **Checagem cética** (o contra mais forte + a resposta),
**Fontes** (links).

Então dê ao aluno o **veredito digerível** (zero jargão, verdade com caminho):
- **O panorama** — quem já faz / como se resolve hoje (2-3 bullets).
- **O sinal** — é vendável? / quanto dá pra economizar? — com **pelo menos 1 número real +
  a fonte**, honesto (inclua o contra mais forte). Emende direto nos caminhos (Passo 5).

## Passo 5 — os caminhos: dar possibilidades e escolher o melhor

Na **primeira vez**, narre: "**direção** é um jeito específico de recortar sua ideia —
público, foco, ângulo. Vou te mostrar os mais fortes."

Apresente **2-3 direções** lastreadas na pesquisa (em modo análise: "**o que dá pra fazer**
com o que você já tem"). Cada uma com: **o que é** (1 linha), **por que esse ângulo é mais
forte** (com base na pesquisa), e o **trade-off**. **Recomende uma, com o porquê.**

🛑 **Escolha (1º ponto de decisão):** o aluno escolhe um caminho (ou ajusta). É a decisão
central de **o que construir**. Espere a escolha.

## Passo 6 — aprofundar no caminho escolhido (o plano do produto)

Agora sim, aprofunde — **propondo rascunhos, não interrogando** (use a resposta anterior pra
puxar a próxima). Cubra, derivando e propondo onde der:

- **quem usa** (tipos de pessoa; o que cada um vê e faz);
- as **3 a 6 telas/áreas** principais;
- em cada área, o que a pessoa **faz** e que **regra** importa (ex.: só o dono edita);
- precisa de **conta/login**? depende de algo **de fora** (pagamento, e-mail, mapa)?
- o que **não** precisa entrar agora.

Onde faltar, **proponha um rascunho** e deixe o aluno **confirmar ou ajustar**. Seja
proativo com tela vazia, erro e permissão — sem afogar.

## Passo 7 — o resumo (2º e último ponto de decisão)

Mostre um resumo em bullets e pergunte fechado:

> "Esse é o resumo do seu produto: [bullets]. Tá tudo certo? Responde **sim** que eu escrevo
> o plano, ou me diz o que mudar."

Espere o "sim" (ou ajustes).

## Passo 8 — salvar (silencioso)

Escreva **`docs/plano-do-produto.md`** — comece com uma seção nova no topo:

- **Por que vale a pena** — 3-4 bullets: o caminho escolhido + o sinal de mercado (é
  vendável? / quanto economiza?) + a aposta de valor. (Em modo análise, diga **em cima de
  qual contexto existente** se constrói.)

Depois, as seções do plano (só as que fizerem sentido, com o **nome do produto** no topo):
**Visão**, **Quem usa**, **Funcionalidades** (essencial agora × depois), **Fluxos**
(incluindo tela vazia e erro), **Telas e navegação**, **Informações** (dados e relações),
**Conta e permissões**, **Conexões de fora**, **Regras**, **Entrega por fases**, **Em
aberto / futuro**.

> Não invente conteúdo que o aluno não validou — onde derivou, deixe claro que é rascunho.

Confirme que **`docs/pesquisa-de-mercado.md`** (Passo 4) está salvo. Guarde a primeira
versão por baixo dos panos (git add + commit, sem mostrar o comando). Para o aluno: "Salvei
o plano do seu produto e a pesquisa de mercado. ✅"

## Passo 9 — fechamento humano

> "Pronto! Sua ideia não é só um palpite — ela passou por uma **checagem de mercado de
> verdade**, e a gente escolheu o ângulo mais forte. Esse plano é o **mapa** do seu produto.
> Agora a gente transforma ele em **telas de verdade** que você vê e clica. Quando quiser,
> digite **`/`** e escolha **`imersao:pg-imersao-prototipo`** na lista."
