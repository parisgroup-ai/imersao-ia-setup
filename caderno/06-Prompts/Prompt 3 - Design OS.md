# Prompt 3 — PRD para protótipo no Design OS

Depois de copiar o PRD para `projeto-design/input/PRD.md`, rode `/product-vision`. Quando o Design OS pedir as ideias iniciais, cole:

```text
Leia `input/PRD.md` por completo antes de continuar, inclusive o mapa de ondas.

Esse PRD é a fonte da verdade do produto. Use-o para criar a visão, o roadmap e o formato dos dados do Design OS.

Regras:
- A visão (onda 0) pode aparecer no protótipo. Cada tela leva um selo: `onda 1` ou `depois`.
- Implementação de verdade, no Dia 2, é só a onda 1. Não trate “depois” como se fosse hoje.
- Não invente funcionalidades ausentes no PRD.
- Faça perguntas somente sobre lacunas que impeçam uma decisão visual.
- Uma jornada principal. No máximo três áreas na onda 1.
- Dê prioridade ao fluxo que produz o resultado principal da onda 1.
- Sugestão que não está no PRD vira “depois” ou “fora do escopo” — você pergunta antes de desenhar.
- Antes de criar os arquivos, explique como cada área se conecta aos critérios da onda 1 e o que fica marcado como depois.
```

## Sequência oficial

```text
/product-vision
/design-tokens
/design-shell
/shape-section
/design-screen
```

Desenhe primeiro as telas da **onda 1**. Telas `depois` só entram se sobrar tempo e estiverem com o selo visível.

## Revisão antes do export

```text
Compare o protótipo atual com `input/PRD.md`, inclusive o mapa de ondas.

Monte uma tabela com:
- requisito do PRD;
- onda (1 ou depois);
- tela ou componente correspondente;
- estado normal;
- estado vazio;
- estado de carregamento;
- estado de erro;
- situação: coberto, parcial ou ausente.

Não exporte enquanto um critério essencial da ONDA 1 estiver ausente.
Telas `depois` podem ficar só no mapa, com selo. Não bloqueie o export por causa delas.

Para cada lacuna da onda 1, proponha a menor correção e espere minha aprovação.
```

Com a revisão aprovada:

```text
/export-product
```

Próximo: copie `product-plan/` para o app e use o [[Prompt 4 - Plano]].
