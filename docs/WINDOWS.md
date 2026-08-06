# Setup Windows — Imersão IA (ParisGroup)

**Política:** Mac é o caminho ouro. **Windows 10/11 com WSL2 é suportado.**  
Este guia cobre o **core** da imersão (Claude Code + Docker + plugin) e o **ambiente padrão de trabalho: [Orca](https://www.onorca.dev/)**.  
Ghostty / statusline com Nerd Font via Homebrew são coisas de Mac e **não** entram aqui.

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
| **Orca** (ambiente padrão) | App **Windows** em https://www.onorca.dev/download |
| Orca Mobile (recomendado) | iOS / Android — pair com o desktop |

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
O **shell** do core continua sendo o **Ubuntu (WSL)**; o **app onde você trabalha** na imersão é o **Orca** (passo 6b).

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

## Passo 6b — Orca (ambiente padrão) + celular

1. No **Windows** (não no Ubuntu), baixe e instale o Orca:  
   https://www.onorca.dev/download → instalador Windows.  
2. Abra o **Orca** e use-o como “escritório” da imersão (projeto + terminal + Claude).  
3. No terminal do projeto, o PATH deve achar o `claude` instalado no WSL (o mentor ajuda na mesa se a integração de shell for a primeira vez).  
4. **Celular (recomendado):** instale Orca Mobile (iOS App Store / TestFlight ou Android APK) e **pareie** com este PC — assim você acompanha e manda o agente com o computador em casa.  

Guia completo: **[ORCA.md](./ORCA.md)**.

## Passo 7 — Diagnóstico

No Ubuntu/WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

O check detecta Windows/WSL e **não** exige Homebrew/Ghostty/statusline.  
Lembra de instalar o **Orca** no host Windows.  
Itens **X** críticos: Git, Node, Claude, Docker rodando, plugin imersão, `gh`.

## Passo 8 — Primeiro projeto

No Orca (ou no Ubuntu, se ainda estiver no shell puro):

```bash
mkdir -p ~/meu-app && cd ~/meu-app
claude
```

Depois:

```text
/imersao:pg-imersao-start
```

## Onde trabalhar no Windows

| Opção | Uso |
|---|---|
| **Orca (desktop)** | **Padrão da imersão** — projeto, agentes, pair com celular |
| **Ubuntu (WSL)** | Shell do **core** — Claude Code, git, docker CLI (pode ser aberto dentro do Orca) |
| Windows Terminal | Abas Ubuntu se precisar fora do Orca |
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

Sem instalador one-shot. Instale manualmente o core da tabela do topo (Node, Docker Engine, Claude Code, `gh`, plugin) **e o Orca** (AppImage/`.deb` em https://www.onorca.dev/download). Rode o `check.sh`. Fale com um mentor se algo falhar. Ver [ORCA.md](./ORCA.md).

## Ajuda

- [ORCA.md](./ORCA.md)  
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)  
- [PRIMEIROS-PASSOS.md](./PRIMEIROS-PASSOS.md)  
- Mentor da imersão / grupo da turma  
