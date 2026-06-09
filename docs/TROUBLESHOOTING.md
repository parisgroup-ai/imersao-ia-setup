# Troubleshooting — Imersão IA

Soluções pras travadas mais comuns no setup. Antes de tudo: **feche e reabra o terminal** — resolve metade dos casos (carrega o `PATH` novo).

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

A statusline da ParisGroup é instalada no passo 10 e ligada no seu `~/.claude/settings.json`. Se não aparecer:

1. **Reabra o Claude Code** — a statusline só carrega ao (re)iniciar.
2. **Não está instalada?** O comando `claude-statusline` deve existir. Se faltar, baixe o script direto (é um único bash autocontido):

   ```bash
   curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/claude-statusline/main/bin/cc-statusline.sh \
     -o ~/.npm-global/bin/claude-statusline && chmod +x ~/.npm-global/bin/claude-statusline
   ```

   O pacote npm `@parisgroup-ai/claude-statusline` vive no GitHub Packages (exige token), por isso o instalador baixa o script direto do **repo público** — funciona sem nenhuma credencial. (`npm install -g github:…` não serve: instala um bin quebrado.)
3. **Não está ligada no `settings.json`?** Adicione (ou rode o instalador de novo, que faz isso sozinho):

   ```json
   { "statusLine": { "type": "command", "command": "claude-statusline" } }
   ```
4. **Ícones viram quadradinhos (▯)?** Falta a Nerd Font:

   ```bash
   brew install --cask font-meslo-lg-nerd-font
   ```

   No **Ghostty** os ícones já funcionam; em outros terminais, selecione uma fonte **MesloLG Nerd Font** (ex.: "MesloLGS Nerd Font"). Sem fonte, use ASCII trocando o `command` por `CC_STATUSLINE_NO_ICONS=1 claude-statusline`.

## Um app (Ghostty / Docker / Obsidian / Claude Desktop) não instalou

O instalador mostra `[ERRO]` no app que falhou. Instale manualmente:

```bash
brew install --cask ghostty        # ou docker-desktop / obsidian / claude
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

O instalador automático é **só para macOS**. Em Windows/Linux, instale manualmente: Node.js, Claude Code (`npm install -g @anthropic-ai/claude-code`) e o plugin (`claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup` + `claude plugin install imersao@imersao-ia`). Fale com um mentor.

---

Não achou seu caso? Rode `curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash` e mande o resultado pro mentor.
