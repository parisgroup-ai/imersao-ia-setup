# Design OS

A skill que cria o protótipo visual das telas. A partir do seu PRD, gera telas navegáveis com a cara do produto final — ainda sem motor por trás.

Analogia: a planta da loja, antes de levantar a parede.

## Quando usar

Só no **Dia 2**, depois do PRD aprovado. Se você abrir o Design OS no Dia 1, está pulando o método.

## Sequência oficial

```text
/product-vision
/design-tokens
/design-shell
/shape-section
/design-screen
```

Repita `/shape-section` e `/design-screen` só para as áreas do fluxo principal.

No fim, com a revisão aprovada:

```text
/export-product
```

O pacote vai para `product-plan/`. Depois você copia para o projeto do app.

## Regras

- O PRD é a fonte da verdade.
- Não invente funcionalidade que não está no PRD.
- Não amplie o MVP sem aprovação.
- Uma jornada principal. No máximo três áreas.
- Outra pessoa precisa conseguir concluir a tarefa no protótipo.

O aluno fala **"vamos desenhar o protótipo"**. Laboratório: [[Lab 4 - Prototipo]]
