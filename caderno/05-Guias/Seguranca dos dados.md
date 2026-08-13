# Segurança dos dados

Nunca cole no agente, no terminal, no playbook, no plano, numa captura ou no Git:

- senhas;
- tokens ou chaves de acesso;
- documento ou dado pessoal;
- dados de cliente que não estejam anonimizados;
- contratos ou informações confidenciais.

Use exemplos fictícios ou anonimizados. Se uma atividade parecer depender de um dado sensível, pare e chame a facilitação. Não tente esconder o dado só mudando o nome do arquivo.

## Onde mora o segredo

- Valores reais: arquivo `.env`, **fora** do Git.
- Nomes das variáveis: `.env.example`, sem valores.
- `.gitignore` precisa listar `.env`.

## Antes de publicar

Peça ao Claude:

> Liste o que neste projeto é sensível e não deveria ser publicado.

Compare `docs/o-que-e-real.md` com o app. Se houver suspeita de segredo no GitHub: pare, avise, troque a chave.

## No playbook e no caderno

Pessoas pelo **papel** (“responsável financeiro”, “atendente”), não pelo nome completo. Sem telefone, sem documento, sem valor contratual.

Este Caderno Founders foi montado com a mesma regra: método e prompts, sem lista de alunos, sem pagamento, sem operação interna.

Ver: [[Modelo o-que-e-real]] · [[03 GitHub e Railway]]
