# Troubleshooting — Imersão IA

Soluções pras travadas mais comuns no setup. Antes de tudo: **feche e reabra o Orca / o terminal** — resolve metade dos casos (carrega o `PATH` novo).

**Ambiente padrão = [Orca](https://www.onorca.dev/).** Guia: [ORCA.md](./ORCA.md). Ghostty no Mac é opcional.

## `command not found: brew` (ou `claude`, `node`, `gh`)

O terminal está com o `PATH` antigo. Feche e reabra o terminal. Se persistir:

```bash
# Apple Silicon (M1/M2/M3...)
eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

O instalador já adiciona isso ao `~/.zprofile` — reabrir o terminal deve bastar.

## As skills não aparecem no `/plugin`

1. Reinicie o Claude Code (feche e abra de novo) — skills carregam ao reiniciar.
2. Confira a instalação:
   ```text
   /plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
   /plugin install imersao@imersao-ia
   ```
3. Pelo terminal: `claude plugin list` deve mostrar `imersao@imersao-ia`.

## `claude` instalou mas dá erro de permissão / `EACCES` no `npm -g`

O instalador configura o npm pra instalar no seu usuário (`~/.npm-global`) justamente pra evitar isso. Se você instalou Node por fora antes, rode:

```bash
npm config set prefix "$HOME/.npm-global"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zprofile
# reabra o terminal, depois:
npm install -g @anthropic-ai/claude-code @openai/codex @tostudy-ai/cli
```

Nunca use `sudo npm install -g` — quebra atualizações futuras.

## A statusline não aparece (ou aparece com quadradinhos)

A statusline da ParisGroup é **core em Mac, WSL e Linux**. No Mac o one-shot instala no passo 10; nos outros SOs rode o instalador multi-OS. Ela fica em `~/.claude/settings.json` com **path absoluto** do binário.

1. **Reabra o Claude Code** — a statusline só carrega ao (re)iniciar (no Orca: feche e abra de novo).
2. **Instale / repare em um comando** (Mac, Ubuntu/WSL ou Linux):

   ```bash
   curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash
   ```

   Isso instala `jq` se faltar, baixa o script público `claude-statusline` e liga o `statusLine` no settings.  
   (O pacote npm `@parisgroup-ai/claude-statusline` no GitHub Packages exige token — **não** use `npm install -g`.)
3. **Confira:**

   ```bash
   command -v claude-statusline
   curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
   ```

4. **Ícones viram quadradinhos (▯)?** Falta Nerd Font (no Mac):

   ```bash
   brew install --cask font-meslo-lg-nerd-font
   ```

   No **Orca** e no **Ghostty** os ícones costumam funcionar. No WSL/Windows sem fonte, a barra ainda funciona; para forçar ASCII, no `~/.claude/settings.json` use um command com env, por exemplo:
   `env CC_STATUSLINE_NO_ICONS=1 /caminho/absoluto/claude-statusline`.

## Orca não instalou / não abre

No Mac:

```bash
brew install --cask stablyai/orca/orca
```

Ou baixe o DMG em https://www.onorca.dev/download.  
Confira se existe `/Applications/Orca.app`.

No Windows/Linux: use o instalador da página de download (não o `brew` do Mac).  
Detalhes e pair no celular: [ORCA.md](./ORCA.md).

## Um app (Orca / Ghostty / Docker / Obsidian / Claude Desktop) não instalou

O instalador mostra `[ERRO]` no app que falhou. Instale manualmente:

```bash
brew install --cask stablyai/orca/orca   # Orca (obrigatório na imersão)
brew install --cask ghostty              # opcional
# ou: docker-desktop / obsidian / claude
```

Se o `brew` reclamar que já existe, o app provavelmente já está instalado — confira em `/Applications`.

## Docker não funciona

Abra o **Docker Desktop** pelo menos uma vez (Launchpad → Docker) e espere o ícone da baleia ficar estável na barra. Só instalar pelo brew não inicia o serviço.

## `gh` pede login

```bash
gh auth login
```

Escolha **GitHub.com** → **HTTPS** → autenticar pelo navegador.

## Login do Claude não abre / não conclui

- Confirme que tem conta e plano **Max** em https://claude.ai/login
- Tente `claude` de novo num terminal novo.
- Abra o **Claude Desktop** uma vez e faça login por lá também.

## Não é Mac (Windows / Linux)

O instalador automático (`instalar_imersao.sh`) é **só para macOS**. Se você colar o `curl | bash` no Windows, o script **para na hora** e aponta para o guia certo.

| SO | O que fazer |
|---|---|
| **Windows 10/11** | Guia: **[WINDOWS.md](./WINDOWS.md)** (WSL2 + Docker + Claude Code + plugin + **Orca** + check) |
| **Linux** | Core (Node, Docker, `gh`, Claude Code, plugin) + **Orca** ([ORCA.md](./ORCA.md)); rode o `check.sh` |

Diagnóstico multi-OS (funciona em Mac, WSL e Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

No Mac o check **exige Orca**. Ghostty é opcional.  
**Statusline e `jq` são core em Mac, WSL e Linux.** Fora do Mac não exige Homebrew — mas exige o core (incl. statusline) + lembrete do Orca.  
Ainda travou? Mande o output do `check.sh` pro mentor.

---

Não achou seu caso? Rode `curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash` e mande o resultado pro mentor.
