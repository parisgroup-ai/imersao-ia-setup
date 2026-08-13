# Modelo — o-que-e-real.md

Copie para `projeto/docs/o-que-e-real.md`. Atualize no checkpoint do Dia 2 e de novo no Dia 3.

O documento e a interface precisam dizer a **mesma** coisa.

## Cabeçalho

- Projeto:
- Data:
- Quem preencheu:
- Onde os dados ficam (computador local ou Postgres no Railway):

## Funcionalidades

| Funcionalidade | Estado | Prova (sem mostrar segredo) | O que falta para ativar |
|---|---|---|---|
| Fluxo principal | real / demonstração / não entregue | | nada / passo concreto |
| Persistência | | | |
| Integração 1 | | | |
| Integração 2 | | | |

Estados possíveis: **real**, **demonstração**, **não entregue**, **não se aplica**.

Definições: [[Entregas e provas]].

## Gate antes de implementar uma conexão de fora

1. Nomear o serviço e a funcionalidade que depende dele.
2. Escolher: real agora ou demonstração explícita.
3. Se for real: chave só no `.env`, `.env` no `.gitignore`, teste mínimo.
4. Se for demonstração: selo na tela e passo de ativação.
5. Não copiar o valor da chave para evidência, documento, captura ou Git.

Se a decisão não estiver clara, essa funcionalidade não começa.

## Gate antes de publicar

1. Abrir este arquivo.
2. Comparar cada linha com a interface e com a presença das configurações — sem exibir valores.
3. Corrigir divergências.
4. Tudo real → publicar.
5. Há demonstração → publicar com selo, ativar a chave, ou segurar.
6. Suspeita de segredo → parar e trocar a chave.

Uma simulação silenciosa bloqueia a conclusão.
