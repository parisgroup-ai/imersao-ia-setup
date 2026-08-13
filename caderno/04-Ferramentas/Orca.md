# Orca

O ambiente padrão da imersão. Não é o Terminal sozinho.

Site: [onorca.dev](https://www.onorca.dev)

Orca é um ADE — um ambiente para trabalhar com agentes. Roda o Claude Code (e outros) na pasta certa, com terminal, editor e navegador embutidos. Tem app no celular para acompanhar o computador ligado em casa.

## Por que Orca

| | Terminal sozinho | Orca |
|---|---|---|
| Onde roda o Claude Code | shell solto | ambiente da imersão |
| Vários agentes | manual | pastas isoladas |
| Ver o app que o agente sobe | browser à parte | browser embutido |
| Celular controlando o PC | não | sim |
| Mac / Windows / Linux | varia | os três |

## Como usar

1. Abra o app **Orca**.
2. Se o instalador acabou de rodar, feche e reabra — senão `claude` e `brew` podem “não existir”.
3. No Windows: o core (Node, Git, Claude) roda no Ubuntu/WSL; o app Orca fica no Windows.
4. No terminal **dentro** do Orca, confira:

```bash
claude --version
```

## Celular (recomendado)

1. Instale o Orca Mobile — [iOS](https://apps.apple.com/us/app/orca-ide/id6766130217) ou Android em [onorca.dev/download](https://www.onorca.dev/download).
2. No desktop, use **Pair Desktop**.
3. Escaneie o QR.
4. Deixe o PC ligado e o Orca aberto.

## Windows

Orca e navegador no Windows. Node, Git, Docker e Claude Code no Ubuntu/WSL. Projeto em `~/founders-ai`, **nunca** em `/mnt/c`.

Ver: [[Ambiente e instalacao]] · [[Windows]]
