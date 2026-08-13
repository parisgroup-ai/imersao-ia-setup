# Processo da Imersão — o método da sala

Este é o mapa que vale na turma Founders AI. Você sai de uma **rotina real** e chega
num **app funcionando**, com o produto completo desenhado em ondas — a onda 1 hoje,
as outras na mesma pasta, depois.

Perdido? Abra o **Caderno Founders**: [`caderno/Comece aqui.md`](../caderno/Comece%20aqui.md).
No Claude, `/imersao:pg-imersao-start` aponta o próximo passo sem fazer por você.

---

## Visão geral (três dias)

```
Dia 1  curso ToStudy → playbook → /brainstorming → PRD com mapa de ondas
Dia 2  Design OS → /writing-plans → /executing-plans → onda 1 (MVP) funcionando
Dia 3  validar → plano curto → /goal --plan → apresentar → publicar (se fizer sentido)
```

A frase que segura o Dia 2: **a onda 1 é o primeiro andar. O prédio que você
imaginou continua no plano.**

Detalhe das ondas: [`caderno/01-O-metodo/O mapa de ondas.md`](../caderno/01-O-metodo/O%20mapa%20de%20ondas.md).

---

## Pasta de trabalho

```
~/founders-ai/
  playbook/          ← rotina real
  projeto/           ← PRD, plano, app, provas
  projeto-design/    ← Design OS (protótipo)
```

No Windows: essa árvore fica **dentro do Ubuntu/WSL**, nunca em `/mnt/c`.

Uma pasta = um projeto. Depois da imersão você continua **nesta** pasta (onda 2)
ou abre **outra** pasta para um produto novo. O método viaja.

---

## Dia 1 — contexto

Curso: [Playbook Executável de Operação](https://tostudy.ai/pt-BR/courses/playbook-executavel-de-operacao-do-contexto-a-automacao).

1. Ambiente ok (`scripts/check.sh`) e pasta aberta no Orca.
2. Percorra os três módulos do curso aplicando no **seu** processo.
3. Na pasta `playbook/`: **"vamos fazer o playbook"** (`/imersao:pg-imersao-playbook`).
   Valide com outra pessoa.
4. Na pasta `projeto/`: **"vamos escolher o produto e as ondas"**
   (`/imersao:pg-imersao-prd`). Três caminhos, **você** escolhe.
5. Aprove o plano com **mapa de ondas**. Fora do escopo é só o que nunca vamos fazer.

Não peça o protótipo ainda. Como falar: `caderno/Como falar com o Claude.md`.

---

## Dia 2 — geração (só a onda 1)

1. **"vamos desenhar o protótipo"** (`/imersao:pg-imersao-prototipo`). Telas com
   selo `onda 1` ou `depois`.
2. Monte o **mapa de telas**: toda tela da onda 1 vira tela demonstrável.
3. Outra pessoa executa a tarefa principal. Exporte.
4. **"vamos construir a onda 1"** (`/imersao:pg-imersao-implementar`). Primeiro a
   tabela de ondas. Sem tabela, o plano não vale. Só a onda 1 é construída.
5. Dado persiste. Integração real ou demonstração com selo. `docs/o-que-e-real.md`.

Não use Goal para construir o MVP. Goal é do Dia 3, só para refinar.

---

## Dia 3 — teste, entrega e (se fizer sentido) o ar

1. Uma pessoa usa o app. Você não ajuda no meio.
2. Liste `agora` / `depois` / `não fazer`.
3. Plano curto → `/goal --plan`. Não reconstrói o MVP.
4. Regressão. Documento = interface.
5. Apresentação honesta.

### Por que publicar

Sem o link, o produto morre quando o notebook fecha. Com o link: prova, uso real
e manutenção (onda 2 não pede “instala de novo”). GitHub é o cartório. Railway
é a loja. Push é a reposição.

Guia: [`caderno/05-Guias/Por que publicar.md`](../caderno/05-Guias/Por%20que%20publicar.md).

### Antes de publicar, a honestidade

Nada sai do seu computador sem o quadro honesto: o Claude confere
`docs/o-que-e-real.md`, checa se bate com o app e, se algo estiver em
demonstração, pergunta — publicar assim (com selo), ativar a chave, ou segurar.

Nunca publique senha, dado de cliente ou chave.

---

## Depois da sala

- **Este app continua.** Mesma pasta, próxima onda.
  [`caderno/08-Depois/Este projeto continua.md`](../caderno/08-Depois/Este%20projeto%20continua.md)
- **Outro produto, outra pasta.** Mesmo ciclo.
  [`caderno/08-Depois/Outro%20projeto,%20outra%20pasta.md`](../caderno/08-Depois/Outro%20projeto,%20outra%20pasta.md)
- **30 dias.** Uso, uma melhoria, evidência.
  [`caderno/08-Depois/Plano de 30 dias.md`](../caderno/08-Depois/Plano%20de%2030%20dias.md)

---

## Atalho — os 4 comandos `/imersao:pg-imersao-*`

Na sala o aluno **fala** ou escolhe no `/`. Os comandos carregam o método:
playbook → ondas → onda 1 → publicar. Goal **não** constrói o MVP.
Não fica colando bloco.

```
  IDEIA
    │
    ▼   /imersao:pg-imersao-prd
  docs/plano-do-produto.md     (equivale ao PRD; inclua o mapa de ondas)
    │
    ▼   /imersao:pg-imersao-prototipo
  protótipo vivo → export
    │
    ▼   /imersao:pg-imersao-implementar
  APP FUNCIONANDO  (onda 1)
    │
    ▼   /imersao:pg-imersao-publicar
  APP NO AR

        └── motor interno: /imersao:pg-imersao-goal
            (na sala, Goal só refina no Dia 3)
```

`/imersao:pg-imersao-start` é a bússola: mostra onde você está e o próximo passo.
Não executa sozinha.

Se o comando de protótipo falar em cobrir **todas as telas do plano**, leia
“todas as telas da **onda 1** + as `depois` com selo”. O mapa de telas continua
obrigatório. Tela futura vai para “Em aberto / futuro”, não some.

Stack do atalho: Next.js + Tailwind + shadcn/ui + Drizzle + Postgres em Docker.
Por que Next.js: frontend + backend + banco num repositório só.

### O que esperar nos gates (atalho)

| Gate | Quando | O que você faz |
|---|---|---|
| Aprovar o recorte | Fim do PRD | Confirma o mapa de ondas |
| Revisar protótipo | Durante o desenho | Olha o navegador, pede mudanças em português |
| Integração final | Fim da construção | Escolhe merge / PR / segurar |

### Quando um teste teima em falhar

O Claude tenta 3 vezes. Depois **para e pede ajuda**. Isso é proposital.

| Comando | Para quê |
|---|---|
| `/imersao:pg-imersao-start` | Bússola |
| `/imersao:pg-imersao-playbook` | Rotina → `playbook.md` |
| `/imersao:pg-imersao-prd` | Produto + mapa de ondas |
| `/imersao:pg-imersao-prototipo` | Plano → protótipo → export |
| `/imersao:pg-imersao-implementar` | Export + plano → app (onda 1) |
| `/imersao:pg-imersao-publicar` | App local → no ar |
| `/imersao:pg-imersao-goal` | Motor interno; na sala, só Dia 3 com `--plan` |

---

## Nota de manutenção (para a organização)

As skills-base (`brainstorming`, `writing-plans`, `executing-plans`,
`finishing-a-development-branch`, `test-driven-development`, `systematic-debugging`,
`subagent-driven-development`, `verification-before-completion`) são vendorizadas
no plugin `imersao`. Quando o upstream evoluir, re-sync e
`bash scripts/validate-skills.sh`.

O caderno do aluno é fonte da verdade pedagógica. Se o plugin e o caderno
divergirem, o caderno da sala ganha.
