# Dia 3 — validar, refinar e (se fizer sentido) publicar

O último dia não começa o produto. Ele observa o uso, prioriza correções e apresenta o estado real.

Publicar no GitHub e no Railway é o fecho natural quando o app está honesto. Sem o link, o produto morre quando o notebook fecha. Por quê, em voz de dono: [[Por que publicar]]. Sem autorização humana, você apresenta localmente.

## O que você tem às 18h

- registro de uma pessoa usando o produto;
- lista `agora` / `depois` / `não fazer`;
- plano curto de refinamento executado com `/goal --plan`;
- regressão passando;
- `docs/o-que-e-real.md` batendo com o app;
- apresentação com problema, solução, fluxo, prova e próximo passo;
- se autorizado: repositório no GitHub e link no Railway.

## Os blocos

1. **Validação observada** — uma pessoa executa a tarefa. Você não ajuda no meio.
2. **Síntese** — separar fato, interpretação e ideia.
3. **Plano curto** — só o que muda o resultado principal.
4. **`/goal --plan`** — executa somente esse plano. Não reconstrói o MVP.
5. **Regressão** — o que funcionava no Dia 2 continua funcionando.
6. **Apresentação** — você opera o app. Sem exagerar o estado.

## Grade (referência)

| Horário | Bloco | Prova |
|---|---|---|
| 09:00–09:20 | Preparar validação | Tarefa, roteiro, regra de não ajudar |
| 09:20–10:20 | Uso observado | Fatos, falas e bloqueios registrados |
| 10:20–10:35 | Pausa | — |
| 10:35–11:15 | Síntese | Lista `agora` / `depois` / `não fazer` |
| 11:15–12:00 | Plano curto | Arquivo aprovado |
| 12:00–13:00 | Almoço | — |
| 13:00–14:45 | `/goal --plan` | Reajustes verificados |
| 14:45–15:00 | Pausa | — |
| 15:00–15:50 | Regressão | Fluxo, persistência, integrações |
| 15:50–16:25 | Estado real | Documento = interface |
| 16:25–17:10 | Ensaio | Roteiro no tempo |
| 17:10–18:00 | Apresentação | Solução com evidências |

## Antes de publicar

O produto fica acessível na internet. Nunca publique senhas, dados de clientes ou chaves.

Peça ao Claude:

> Liste o que neste projeto é sensível e não deveria ser publicado.

Depois compare `docs/o-que-e-real.md` com o app:

- tudo real → pode publicar;
- há demonstração → publique com selo, ative a chave, ou segure;
- suspeita de segredo exposto → pare e troque a chave.

Guia: [[Por que publicar]] · [[03 GitHub e Railway]] · [[Seguranca dos dados]].

No encerramento, diga em voz alta: este app **continua**. Semana que vem, mesma pasta, onda 2. [[Este projeto continua]]. Um produto novo? Pasta nova. [[Outro projeto, outra pasta]].

## Se o Goal tentar reconstruir o MVP

Pare. O plano do Dia 3 contém somente refinamentos. Volte ao arquivo curto e retire tarefas de construção inicial.

Laboratórios: [[Lab 6 - Validar]] · [[Lab 7 - Refinar e apresentar]]  
Prompt: [[Prompt 6 - Refinar]]
