# Dia 2 — do playbook ao produto

No segundo dia, o documento ganha forma e o protótipo ganha motor. Por trás de cada tela da **onda 1** passa a existir funcionalidade de verdade.

## A frase antes do plano

O plano vai parecer menor do que o protótipo. Está certo. É a onda 1. O resto não foi jogado fora — está no fim do plano, com a data “depois”.

Se o plano “comeu” o produto: pare e abra [[O mapa de ondas]].

## O que você tem às 18h

- protótipo navegável, com selo `onda 1` / `depois`;
- plano aprovado **com a tabela de ondas no topo**;
- **onda 1 (MVP) funcionando** no seu computador;
- persistência real (o dado continua depois de atualizar a página);
- integrações obrigatórias testadas, ou marcadas como demonstração;
- `docs/o-que-e-real.md` escrito com honestidade.

Sem o produto funcionando no seu computador, não há o que publicar no Dia 3.

## Os cinco passos

1. **Protótipo com o Design OS** — telas navegáveis com a cara do produto, antes de escrever o sistema.
2. **Refinamento** — ajustar telas, textos e fluxos. Mais barato mudar a planta do que a parede.
3. **Export do front-end** — a fachada empacotada em `product-plan/`.
4. **Implementação** — o Claude pega o design e constrói o motor: dados, regras, persistência.
5. **Teste no navegador** — o Claude abre o produto, navega e corrige. Você confere.

## Grade (referência)

| Horário | Bloco | Prova |
|---|---|---|
| 09:00–09:15 | Retomada e corte | Escopo cabe no dia |
| 09:15–10:25 | Design OS — visão, tokens, shell | Navegação coerente |
| 10:25–10:40 | Pausa | — |
| 10:40–11:35 | Design OS — fluxo | Protótipo com estados essenciais |
| 11:35–12:00 | Teste e export | Outra pessoa executa a tarefa |
| 12:00–13:00 | Almoço | — |
| 13:00–13:45 | `/writing-plans` | Tabela de ondas confirmada + tarefas da onda 1 |
| 13:45–14:05 | Revisão do plano | Onda 1 cabe no dia; onda 2+ listada em “Como continuar depois” |
| 14:05–14:20 | Pausa | — |
| 14:20–16:30 | `/executing-plans` | App abre e o fluxo principal funciona |
| 16:30–17:20 | Persistência e integrações | Dado relido; integração testada |
| 17:20–17:45 | Regressão | Vazio, erro, testes, tipos, build |
| 17:45–18:00 | Checkpoint | Você opera, sem o mentor no teclado |

## Gate honesto

“Tela bonita”, “código gerado” ou “integração simulada” **não** são conclusão.

Se uma autorização externa impedir uma integração:

1. registrar bloqueio, responsável, ação e prova esperada;
2. a interface diz que ainda é demonstração;
3. nunca esconder a pendência.

Modelo: [[Modelo o-que-e-real]].

## O que não fazer hoje

- Não construir onda 2+.
- Não chamar onda 2+ de “fora do escopo”.
- Não redesenhar telas já aprovadas.
- Não usar `/goal` para construir o MVP — isso é do Dia 3, só para refinar.
- Não publicar, fazer push ou criar conta sem autorização.

O que falar hoje: **"vamos desenhar o protótipo"** e depois **"vamos construir a onda 1"**. Como: [[Como falar com o Claude]].

Laboratórios: [[Lab 4 - Prototipo]] · [[Lab 5 - MVP]]
