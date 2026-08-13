# AGENTS.md, CLAUDE.md e /init

O Claude Code trabalha **dentro da pasta** que você abriu. Os arquivos de instrução dizem a ele como essa pasta funciona.

## Analogia

É a memória do projeto. Sem ela, o agente chega como um funcionário novo, todo dia, sem handbook. Com ela, ele lê as regras da casa antes de começar.

## Os dois arquivos

| Arquivo | Papel |
|---|---|
| `CLAUDE.md` | Instruções que o Claude Code carrega ao abrir o projeto |
| `AGENTS.md` | Instruções para qualquer agente que trabalhar ali |

Os dois guardam o jeito da casa: stack, pastas, o que não fazer, como testar.

## `/init`

Comando do Claude Code que lê um projeto existente e prepara o arquivo de instruções inicial.

Use com a facilitação. **Não rode** se o projeto já tem instruções canônicas — você pode sobrescrever o que já estava certo.

## Na imersão

1. Abra `~/founders-ai` no Orca.
2. Localize `CLAUDE.md` e `AGENTS.md`.
3. Só use `/init` se eles não existirem.
4. Quando o agente “esquecer” uma regra, a regra precisa estar num desses arquivos — não só na conversa.

Isso é engenharia de contexto na prática: informação certa, na medida certa, no lugar certo.

Ver: [[Claude e Claude Code]] · [[Pasta do projeto]]
