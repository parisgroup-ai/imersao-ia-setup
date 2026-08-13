# Windows

A imersão roda no Windows. O caminho é **WSL2 + Ubuntu**, não o PowerShell como ambiente do projeto.

Guia completo do instalador: [docs/WINDOWS.md](https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md)

## O mapa

| O que | Onde |
|---|---|
| Orca e navegador | Windows |
| Node, Git, Docker, Claude Code | Ubuntu / WSL |
| Pasta do projeto | `~/founders-ai` **dentro do Linux** |
| PowerShell | Só para instalar ou administrar o WSL |

**Não trabalhe em `/mnt/c`.** Essa pasta é o disco do Windows visto de dentro do Linux. É lenta e quebra ferramenta.

## Conferir

No terminal **Ubuntu**:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Docker Desktop precisa ter **WSL Integration** ligada para o Ubuntu.

## Se o caminho estiver errado

```bash
pwd
```

Se começar com `/mnt/c`, saia. Vá para `~/founders-ai` no home do Ubuntu.

Ver: [[Ambiente e instalacao]] · [[Orca]] · [[Se travou]]
