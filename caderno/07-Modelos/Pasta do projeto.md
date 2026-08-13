# Pasta do projeto

Cada participante trabalha numa estrutura pequena e previsível. Playbook, produto e Design OS ficam separados, na mesma pasta de trabalho.

## Nomes

Use um nome curto, minúsculas, sem espaço e sem acento.

```text
~/founders-ai/
├── playbook/          # rotina real
├── projeto/           # PRD, export, plano, app e provas
└── projeto-design/    # Design OS
```

No Windows, isso fica **dentro do Ubuntu/WSL**. Não criar em `/mnt/c`.

Um produto novo = pasta nova. Não acrescente um segundo negócio dentro de `founders-ai`. [[Outro projeto, outra pasta]].

## Árvore mínima

```text
founders-ai/
├── playbook/
│   └── playbook.md
├── projeto-design/
│   └── input/PRD.md
└── projeto/
    ├── .gitignore
    ├── AGENTS.md
    ├── CLAUDE.md
    ├── README.md
    ├── product-plan/
    └── docs/
        ├── diario-da-imersao.md
        ├── PRD.md
        ├── o-que-e-real.md
        └── superpowers/plans/
```

## Quando cada arquivo entra

| Arquivo | Quando |
|---|---|
| `playbook/playbook.md` | Dia 1, a partir do trabalho real |
| `projeto/docs/PRD.md` | Fim do Dia 1, com `/brainstorming` |
| `projeto/product-plan/` | Dia 2, export do Design OS |
| `docs/superpowers/plans/` | Dia 2 o plano do MVP; Dia 3 o plano curto |
| `docs/o-que-e-real.md` | Antes do checkpoint do MVP, conferido no Dia 3 |

Depois de `/executing-plans`, o `projeto/` contém a aplicação. Não crie outro subdiretório para o app.

## Convenções

1. **Uma fonte da verdade.** Mudança de escopo entra primeiro em `docs/PRD.md`.
2. **Design separado.** `projeto-design/` é protótipo; `projeto/` é o produto.
3. **Nome previsível.** Minúsculas, sem acento.
4. **Você decide.** O agente propõe. Você aprova direção, telas e o que é real ou demonstração.
5. **Mudança pequena.** Primeiro o fluxo principal. O resto fica em “depois”.
6. **Prova perto da entrega.** Arquivos, testes e links no próprio repositório.
7. **Sem segredo no Git.** `.env` nunca versionado.

Ver: [[AGENTS e CLAUDE]] · [[Modelo o-que-e-real]]
