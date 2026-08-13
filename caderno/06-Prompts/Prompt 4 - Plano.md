# Prompt 4 — export para plano executável

Use na pasta `projeto/`, depois de copiar o `product-plan/` exportado pelo Design OS.

Este é o prompt que evita o BO da turma: o plano parece menor que o produto imaginado. **Primeiro o mapa de ondas. Depois as tarefas da onda 1.**

Cole o bloco inteiro.

```text
/writing-plans

Crie um plano de implementação usando estas fontes, nesta ordem:

1. `docs/PRD.md` — requisitos, limites e MAPA DE ONDAS;
2. `product-plan/product-overview.md` — visão consolidada;
3. `product-plan/instructions/` — instruções do Design OS;
4. `product-plan/design-system/` — identidade visual;
5. `product-plan/shell/` — estrutura de navegação;
6. `product-plan/sections/` — componentes, tipos, dados de exemplo e testes.

PASSO ZERO — MAPA DE ONDAS (antes de qualquer tarefa)
Escreva e me mostre esta tabela. Não comece o plano técnico enquanto eu não confirmar.

| Onda | O que entra | Quando | Onde |
| 1 — hoje (MVP) | fluxo principal + dado que persiste + integrações obrigatórias | Dia 2 | esta pasta |
| 2 | [cada item do PRD que ficou fora da onda 1] | depois da imersão | a mesma pasta |
| 3 | […] | depois | a mesma pasta |

Regras do mapa:
- Onda 1 cabe em um dia. Não negociável.
- Nada da visão some: o que não é onda 1 vira linha na tabela, com nome e resultado.
- Não chame onda 2+ de “fora do escopo”. Fora do escopo é só o que nunca vamos fazer.
- Depois da tabela, diga em uma frase: “Hoje construímos a onda 1. O produto que você imaginou continua no plano; a próxima onda é na mesma pasta.”
- Se a skill writing-plans pedir cobertura de toda a spec: as ondas 2+ NÃO viram tarefa. Elas vão para a seção final “Como continuar depois”.

Só depois da minha confirmação da tabela, escreva as tarefas da ONDA 1.

Regras das tarefas (só onda 1):
- Inspecione todos os arquivos antes de planejar.
- Não redesenhe os componentes exportados.
- Integre o design e construa o comportamento real da onda 1.
- Divida em tarefas pequenas, verificáveis, em ordem.
- Para cada tarefa: arquivos exatos, teste que deve falhar primeiro, implementação mínima, comando de verificação, resultado esperado.
- Inclua carregamento, vazio, erro, persistência real e responsividade.
- Inclua verificação explícita contra dado simulado apresentado como real.
- Identifique cada integração obrigatória, a credencial, o teste real e a contingência honesta.
- A última tarefa da onda 1 faz a regressão do fluxo principal e registra as evidências.

Seção final obrigatória — “Como continuar depois”:
- Liste as ondas 2+ com o resultado de cada uma.
- Diga: abra ESTA mesma pasta, rode o Claude, peça a próxima onda.
- Aponte o Guia 2 (manutenção) e “Este projeto continua”.
- Não execute essas ondas agora.

- Salve em `docs/superpowers/plans/`.
- Não execute o plano.
- Pare depois de salvar e revisar. Ainda no Dia 2, a execução da onda 1 começa com `/executing-plans`.
```

Você confirma o mapa de ondas. Só então o [[Prompt 5 - Construir o MVP]].

Se o plano “comeu” o produto: [[O mapa de ondas]].
