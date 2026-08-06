# Orca — ambiente padrão da Imersão IA

Na Imersão, o **meio de trabalho padrão é o [Orca](https://www.onorca.dev/)** — não o Terminal sozinho e não o Ghostty.

Orca é um **ADE** (Agent Development Environment): roda Claude Code, Codex e outros agentes lado a lado, em pastas isoladas (worktrees), com terminal, editor e browser embutidos. Tem **app no celular** (iOS e Android) para você acompanhar e mandar o agente **com o computador ligado em casa**.

> Site: https://www.onorca.dev/  
> Download: https://www.onorca.dev/download  
> Código aberto: https://github.com/stablyai/orca

## Por que Orca (e não só Ghostty)?

| | Ghostty / Terminal | **Orca (padrão)** |
|---|---|---|
| Onde roda o Claude Code | num shell solto | no ambiente da imersão |
| Vários agentes / tarefas | manual | worktrees isolados |
| Ver o app que o agente sobe | browser à parte | browser embutido |
| **Celular controlando o PC** | não | **sim (companion)** |
| Mac / Windows / Linux | Ghostty só Mac | **os três** |

O instalador do **Mac** ainda pode instalar o **Ghostty** (terminal opcional). O dia a dia da imersão e o que ensinamos em sala é **abrir o Orca**.

## Instalação

### macOS (caminho ouro)

O `instalar_imersao.sh` já instala o Orca:

```bash
brew install --cask stablyai/orca/orca
```

Ou baixe o DMG em https://www.onorca.dev/download (Apple Silicon ou Intel).

Confira: app **Orca** em Aplicativos.

### Windows 10/11

1. Faça o **core** no WSL2 (Node, Claude Code, plugin) — ver [WINDOWS.md](./WINDOWS.md).  
2. No **Windows** (não no Ubuntu), baixe e instale o Orca:  
   https://www.onorca.dev/download → **Windows** (`orca-windows-setup.exe`).  
3. No Orca, use um terminal apontando para o ambiente onde o `claude` está no PATH  
   (na prática: abra o projeto no Orca e rode o Claude no shell que já tem o setup — WSL ou o path que o mentor indicar na mesa).

### Linux

Baixe o AppImage ou o `.deb` / `.rpm` em https://www.onorca.dev/download (ou releases: https://github.com/stablyai/orca/releases).

## Dia a dia na imersão (roteiro curto)

1. **Abra o Orca** no computador (deixe-o aberto enquanto trabalhar).  
2. Abra ou crie o **projeto** da imersão (pasta do app).  
3. No terminal do Orca, rode:

   ```bash
   claude
   ```

4. Faça login na 1ª vez (Claude Max).  
5. Use o pipeline da imersão: `/imersao:pg-imersao-start` e as fases.  
6. **Opcional e recomendado:** pareie o **celular** (abaixo) para continuar de fora da mesa.

Não precisa decorar atalhos do Orca no D1 — o mentor mostra em sala. O mínimo é: **Orca aberto + `claude` rodando + login feito**.

## App no celular (companion)

Com o Orca desktop ligado e pareado, o app no telefone deixa você:

- ver agentes rodando  
- acompanhar status / uso  
- mandar comandos / seguir o terminal  
- continuar o trabalho **com o PC em casa** (e você no celular)

### iOS

- **App Store (estável):** https://apps.apple.com/us/app/orca-ide/id6766130217  
- **TestFlight (beta):** https://testflight.apple.com/join/YjeGMQBA  

### Android

- APK nas releases / página de download: https://www.onorca.dev/download  

### Parear (ideia geral)

1. Desktop Orca aberto e logado na conta Orca (se pedir).  
2. No celular, abra Orca Mobile → **Pair Desktop** / emparelhar.  
3. Escaneie o QR ou use o código que o desktop mostra.  
4. Deixe o **computador ligado e o Orca aberto** (no Mac, se for fechar a tampa, o mentor mostra o modo “PC acordado” na edição — o importante é o desktop não dormir no meio do agente).

Detalhes da UI mudam com a versão do app; se o botão tiver outro nome, use o fluxo de **pair / connect desktop** da tela inicial do mobile.

## O que NÃO muda

- Contas e core: Claude Max, GitHub, Railway, Docker, plugin `imersao@imersao-ia`.  
- Windows ainda precisa do **WSL2 + Ubuntu** para o core (Node, `claude`, Docker integration).  
- Ghostty no Mac é **bônus** (terminal bonito), não o padrão da sala.

## Conferir

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

No Mac, **Orca** deve aparecer como OK. Ghostty ausente gera só aviso.

## Ajuda

- [PRIMEIROS-PASSOS.md](./PRIMEIROS-PASSOS.md)  
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)  
- Site: https://www.onorca.dev/  
- Discord da Orca (comunidade do produto): link no site  

Travou no pair ou no install? Chame o mentor na mesa de setup.
