# Se travou

Antes de tudo: **feche e reabra o Orca** (ou o terminal). Isso resolve metade dos casos — o `PATH` novo entra.

## `command not found: brew` (ou `claude`, `node`, `gh`)

O terminal está com o caminho antigo. Reabra. Se persistir, no Mac Apple Silicon:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Intel:

```bash
eval "$(/usr/local/bin/brew shellenv)"
```

## As skills não aparecem

1. Feche e abra o Claude Code de novo.
2. Dentro do Claude:

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

3. No terminal: `claude plugin list` deve mostrar `imersao@imersao-ia`.

## Erro de permissão no `npm -g`

Não use `sudo npm install -g`. Isso quebra atualizações.

```bash
npm config set prefix "$HOME/.npm-global"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zprofile
```

Reabra o terminal.

## Statusline sumiu ou veio com quadradinhos

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash
```

Reabra o Claude Code.

## Check vermelho

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Corrija **um** item vermelho de cada vez. Não instale cinco alternativas ao mesmo tempo.

## Windows: projeto no lugar errado

```bash
pwd
```

Se começar com `/mnt/c`, você está no disco do Windows. Vá para `~/founders-ai` no Ubuntu. Ver [[Windows]].

## Claude “não lembra” do projeto

Confira se você abriu a pasta certa e se existem `CLAUDE.md` / `AGENTS.md`. Ver [[AGENTS e CLAUDE]].

## Mensagem estranha na tela

Não continue. Copie a mensagem (sem senha, sem chave) e mostre ao Claude ou à facilitação.

Guia longo do setup: [TROUBLESHOOTING](https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md)
