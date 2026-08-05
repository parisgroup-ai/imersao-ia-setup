# Setup Windows — Imersão IA (ParisGroup)

**Política:** Mac é o caminho ouro. **Windows 10/11 com WSL2 é suportado.**  
Este guia cobre o **core** da imersão (Claude Code + Docker + plugin). Apps “de Mac” (Ghostty, statusline com Nerd Font via Homebrew) são opcionais.

> Mínimo: **16 GB de RAM**, **20 GB livres**, Windows 10/11 64-bit.  
> 8 GB de RAM: peça empréstimo de Mac ao time — Docker + Claude sofrem.

## O que você vai ter no final

| Obrigatório (D1) | Como no Windows |
|---|---|
| Git + Node.js | Dentro do **WSL2 Ubuntu** (recomendado) ou nativo |
| Claude Code logado (Max $200/mês) | npm global no WSL |
| Plugin `imersao@imersao-ia` | CLI do Claude Code |
| Docker **rodando** | Docker Desktop com backend WSL2 |
| `gh` autenticado | GitHub CLI no WSL |
| Conta Railway | Navegador |

## Passo 0 — Contas (antes de instalar)

1. [Claude Max $200/mês](https://claude.ai) — obrigatório  
2. [GitHub](https://github.com/signup) — grátis  
3. [Railway](https://railway.app) — Hobby ou Trial  

## Passo 1 — WSL2 + Ubuntu

No **PowerShell como Administrador**:

```powershell
wsl --install
```

Reinicie o PC se pedir. Depois abra **Ubuntu** no menu Iniciar e crie usuário/senha Linux.

Conferir:

```powershell
wsl -l -v
```

A distro Ubuntu deve aparecer com versão **2**.

Atualize o Ubuntu (dentro do terminal Ubuntu):

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl git ca-certificates
```

## Passo 2 — Docker Desktop (backend WSL)

1. Baixe: https://www.docker.com/products/docker-desktop/  
2. Instale e abra o Docker Desktop.  
3. Settings → **Resources → WSL Integration** → ligue a distro **Ubuntu**.  
4. Apply & Restart.  

No terminal **Ubuntu**:

```bash
docker info
```

Se listar info do daemon, está ok. Se falhar: abra o Docker Desktop no Windows e espere o motor iniciar.

## Passo 3 — Node.js (no Ubuntu/WSL)

Recomendado via nvm:

```bash
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# feche e reabra o Ubuntu, depois:
nvm install 22
node -v
npm -v
```

Configure npm global **sem sudo**:

```bash
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Passo 4 — GitHub CLI

```bash
# Opção simples: baixar .deb da release ou:
sudo apt install -y gh   # se disponível na sua distro
# se apt não tiver gh, veja: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

gh auth login
```

Escolha **GitHub.com → HTTPS → Login with a web browser**.

## Passo 5 — Claude Code + Codex + ToStudy

```bash
npm install -g @anthropic-ai/claude-code @openai/codex @tostudy-ai/cli
claude
```

Na primeira vez, faça login (plano Max).  
**Use o terminal Ubuntu (WSL)** para o dia a dia da imersão.

## Passo 6 — Plugin da imersão

Dentro do Claude Code (`claude`):

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

Ou pelo shell:

```bash
claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
claude plugin install imersao@imersao-ia
```

**Feche e reabra** o Claude Code. Confira:

```bash
claude plugin list
```

Deve aparecer `imersao@imersao-ia`.

## Passo 7 — Diagnóstico

No Ubuntu/WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

O check detecta Windows/WSL e **não** exige Homebrew/Ghostty.  
Itens **X** críticos: Git, Node, Claude, Docker rodando, plugin imersão, `gh`.

## Passo 8 — Primeiro projeto

```bash
mkdir -p ~/meu-app && cd ~/meu-app
claude
```

Depois:

```text
/imersao:pg-imersao-start
```

## Terminal no Windows

| Opção | Uso |
|---|---|
| **Ubuntu (WSL)** | **Principal** — Claude Code, git, docker CLI |
| Windows Terminal | Abra abas Ubuntu |
| PowerShell | Só para `wsl --install` e Docker Desktop |

Não rode o instalador Mac (`instalar_imersao.sh`) no PowerShell — ele **aborta de propósito** e aponta para este guia.

## Problemas comuns

### `docker: command not found` no Ubuntu

Docker Desktop aberto? WSL Integration ligada na distro Ubuntu?

### Claude não abre o browser de login

Tente login pelo Claude Desktop no Windows, ou copie a URL que o CLI mostrar.

### Plugins não aparecem

Reinicie o Claude Code. Confirme `claude plugin list`. Reinstale o marketplace (passo 6).

### Disco cheio / lento

WSL ocupa espaço no `C:`. Libere 20+ GB. Em máquinas com 8 GB de RAM, peça empréstimo de Mac ao mentor.

### “Não é Mac” no instalador

Esperado. Use **este** guia, não o `curl | bash` do README Mac.

## Linux nativo (sem Windows)

Sem instalador one-shot. Instale manualmente o core da tabela do topo (Node, Docker Engine, Claude Code, `gh`, plugin). Rode o `check.sh`. Fale com um mentor se algo falhar.

## Ajuda

- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)  
- [PRIMEIROS-PASSOS.md](./PRIMEIROS-PASSOS.md)  
- Mentor da imersão / grupo da turma  
