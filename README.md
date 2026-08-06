# Imersão IA - ParisGroup AI

Repositório central da Imersão de IA. Contém o **instalador do ambiente** e um **plugin de skills de IA** curadas para turbinar seu desenvolvimento com Claude Code e Codex.

## Comece aqui — escolha sua máquina

**Antes de tudo (qualquer SO):**

1. Notebook com **≥ 16 GB de RAM** e **≥ 20 GB livres** (8 GB = peça empréstimo de Mac ao time)
2. Contas: [Claude Max $200/mês](https://claude.ai) · [GitHub](https://github.com/signup) · [Railway](https://railway.app)
3. Siga **só a coluna do seu SO** abaixo

| Passo | 🍎 macOS (caminho ouro) | 🪟 Windows 10/11 | 🐧 Linux |
|------:|---|---|---|
| **1. SO / ambiente** | Terminal p/ instalar; depois **Orca** | **WSL2 + Ubuntu** + **Orca** no Windows | Terminal + **Orca** |
| **2. Setup** | Cole o instalador (§1) | Siga **[docs/WINDOWS.md](docs/WINDOWS.md)** | Core manual (§ abaixo) |
| **3. Onde rodar o dia a dia** | **App Orca** (Claude Code dentro) | **Orca** + shell Ubuntu/WSL | **Orca** |
| **4. Conferir** | `check.sh` (§1) | `check.sh` **dentro do Ubuntu** | `check.sh` |
| **5. Depois** | [ORCA](docs/ORCA.md) · [PRIMEIROS-PASSOS](docs/PRIMEIROS-PASSOS.md) | Idem | Idem + mentor se travar |

**Ambiente padrão de trabalho = [Orca](https://www.onorca.dev/)** (ADE com app no celular). Ghostty no Mac é terminal **opcional**.

**Core obrigatório no D1 (todos os SOs):** Git · Node · Claude Code logado (Max) · plugin `imersao@imersao-ia` · Docker **rodando** · `gh auth login` · conta Railway · **Orca instalado** (desktop; mobile recomendado).

| SO | Status | Detalhe |
|---|---|---|
| **macOS** | Caminho ouro | 1 comando instala quase tudo |
| **Windows + WSL2** | Suportado | Passo a passo em **[docs/WINDOWS.md](docs/WINDOWS.md)** |
| **Linux nativo** | Parcial | Sem instalador one-shot — core à mão + mentor |

O instalador automático **só roda no macOS**. Se rodar em Windows/Linux, ele **para na hora** e aponta para o guia certo (não quebra no meio).

---

## 1. Instalação — macOS

No **Terminal** do Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

### O que o instalador coloca no Mac

- **Xcode Command Line Tools** — Git e compilador nativo
- **Homebrew** — gerenciador de pacotes
- **Node.js** — runtime JavaScript (Claude Code, Codex, ToStudy CLI, statusline)
- **GitHub CLI (`gh`)**
- **Orca** — **ambiente padrão** da imersão (agentes, worktrees, app no celular) — https://www.onorca.dev/
- **Ghostty** — terminal opcional (não é o meio principal)
- **Docker Desktop**
- **Obsidian** · **Claude Desktop**
- **Nerd Font (MesloLG)** · **jq**
- **Claude Code** · **Codex CLI** · **ToStudy CLI** (npm)
- **Plugin da Imersão** + **statusline ParisGroup**

O script pula o que já está instalado. No fim: **abra o Orca**, rode o Claude Code **dentro dele**, e reabra o Claude uma vez se os comandos `/imersao:*` não aparecerem. Pode pedir a senha do Mac.

> npm global vai para `~/.npm-global` (sem `sudo npm install -g`).

### Conferir (Mac, Windows/WSL ou Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

O check mostra o **perfil** (macOS / Windows/WSL / Linux). No Mac **exige Orca**. Ghostty e statusline: statusline continua core no Mac; Ghostty é opcional. Fora do Mac ele **não exige** Homebrew/statusline — só o core + lembrete do Orca.

Travou? [ORCA](docs/ORCA.md) · [PRIMEIROS-PASSOS](docs/PRIMEIROS-PASSOS.md) · [TROUBLESHOOTING](docs/TROUBLESHOOTING.md)

---

## 1b. Instalação — Windows (resumo; guia completo no link)

**Não** rode o `curl | bash` do Mac no PowerShell.

Roteiro (detalhe em **[docs/WINDOWS.md](docs/WINDOWS.md)**):

1. PowerShell **como Admin:** `wsl --install` → reinicie → abra **Ubuntu**
2. Instale **Docker Desktop** e ligue **WSL Integration** na distro Ubuntu
3. No **Ubuntu:** Node (nvm) · `gh` · `npm i -g @anthropic-ai/claude-code` · login `claude`
4. Plugin: `claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup` + `claude plugin install imersao@imersao-ia`
5. No **Windows:** instale o **Orca** (desktop) em https://www.onorca.dev/download — ambiente padrão
6. `check.sh` **dentro do Ubuntu**
7. Dia a dia = **Orca** + shell com o core (Ubuntu/WSL). Celular: Orca Mobile pareado (recomendado). Guia: [docs/ORCA.md](docs/ORCA.md)

---

## 1c. Instalação — Linux (parcial)

Sem instalador one-shot. Instale o **core** + **Orca**:

```bash
# exemplo Debian/Ubuntu — ajuste à sua distro
sudo apt update && sudo apt install -y git curl build-essential
# Node 22 (nvm recomendado), Docker Engine, gh
npm install -g @anthropic-ai/claude-code @openai/codex @tostudy-ai/cli
claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
claude plugin install imersao@imersao-ia
# Orca (ambiente padrão): AppImage/.deb em https://www.onorca.dev/download
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Fale com um mentor se Docker, Orca ou o plugin falharem. Guia do ambiente: [docs/ORCA.md](docs/ORCA.md).

---

## 2. Claude Code Setup (oficial) **antes** de plugins

> **Ordem correta:** (1) Claude Code instalado e logado → (2) **Claude Code Setup** (plugin oficial Anthropic, se disponível no seu ambiente) → (3) **só então** plugins curados da imersão.  
> Evite instalar dezenas de plugins aleatórios (“plugin soup”): o setup fica lento e você extrai pouco valor.

Dentro do Claude Code (marketplace oficial Anthropic):

```text
/plugin
```

- Aba **Discover** / marketplace `claude-plugins-official`
- Procure o plugin de **setup / configuração do projeto** (Claude Code Setup) e instale se aparecer na sua versão
- Docs: https://code.claude.com/docs/en/discover-plugins

Depois disso, instale **apenas** o plugin da imersão (abaixo). Lista curta recomendada na imersão:

| Plugin | Quando |
|--------|--------|
| `imersao@imersao-ia` (este repo) | Sempre — pipeline da imersão |
| GitHub (`github@claude-plugins-official`) | Se for usar Issues/PRs do terminal |
| **Não** instale “packs” genéricos de dezenas de skills | Só com indicação do instrutor |

## 3. Skills de IA (plugin da imersão)

As skills são distribuídas como um **plugin do Claude Code** via marketplace. Não é preciso copiar pastas à mão: o Claude Code descobre cada skill automaticamente, e você atualiza ou desinstala com um comando.

O instalador já faz isso por você. Se quiser instalar manualmente (ou em outra máquina), dentro do **Claude Code** rode:

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

Ou pelo terminal, com o CLI:

```bash
claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
claude plugin install imersao@imersao-ia
```

Reinicie o Claude Code para carregar as skills.

### Codex

Plugins são um recurso do **Claude Code**. Para usar as mesmas skills no **Codex**, rode o script de sincronização (copia as skills para `~/.codex/skills/`):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/sync-codex-skills.sh | bash
```

## 4. Processo da Imersão (do PRD ao app)

O plugin traz um **pipeline guiado** que leva da ideia a um app **no ar**, em 4 fases sobre um motor autônomo (`/imersao:pg-imersao-goal`, com 2 gates humanos).

**👉 Comece por `/imersao:pg-imersao-start`** — a bússola mostra os 4 passos e diz qual é o próximo (sem executar por você; quem roda cada fase é o aluno, de propósito):

| Comando | Fase | O que faz |
|---|---|---|
| `/imersao:pg-imersao-start` | 👈 | **Comece aqui** — bússola dos 4 passos |
| `/imersao:pg-imersao-prd` | 1 | Ideia → `docs/plano-do-produto.md` (conversa guiada) |
| `/imersao:pg-imersao-prototipo` | 2 | Plano → protótipo no **Design OS** público → export React + Tailwind |
| `/imersao:pg-imersao-implementar` | 3 | Export + plano → app **Next.js + Tailwind + shadcn/ui + Drizzle + Postgres (Docker)** |
| `/imersao:pg-imersao-publicar` | 4 | App → **no ar**: push pro GitHub + deploy no Railway |

> **Contas:** Claude Max **$200/mês** (obrigatório), **GitHub** (grátis) e **Railway** (Hobby **$5/mês**, exige cartão — dá pra testar o deploy no Trial grátis sem cartão) — crie antes de começar.

Passo a passo completo (aluno + instrutor): **[docs/PROCESSO-IMERSAO.md](docs/PROCESSO-IMERSAO.md)**.

## 5. Gerenciar skills

| Ação | Comando (dentro do Claude Code) | Comando (CLI) |
|------|----------------------------------|----------------|
| Listar instaladas | `/plugin` | `claude plugin list` |
| Ver detalhes | — | `claude plugin details imersao` |
| Atualizar | `/plugin` → update | `claude plugin update imersao` |
| Desinstalar | `/plugin` | `claude plugin uninstall imersao` |

`/plugin` sempre mostra a **lista completa e atualizada** das skills do plugin — não há tabela neste README para ficar desatualizada.

## 6. Skills disponíveis

Dezenas de skills curadas, organizadas por área. Use `/plugin` (ou veja `plugins/imersao/skills/`) para a lista completa e sempre atualizada. Um panorama:

- **Contexto & Documentação** — `agents-maintenance`, `context-maintenance`, `memory-bank`, `obsidian-docs`, `readme-maintenance`, `prompt-maintenance`
- **Arquitetura & Design** — `api-design`, `clean-architecture`, `database-design`, `redis-design`, `logger-design`, `github-design`, `security-practices`
- **Qualidade de Código** — `code-quality`, `code-consolidation`, `reviewer`
- **Testes & Cobertura** — `testing-strategy`, `coverage-run`, `coverage-report`, `coverage-check`
- **E2E (web) & Mobile** — `e2e-run`, `e2e-architect`, `e2e-chrome-devtools`, `maestro-run`, `maestro-capture`, `mobile-native-bestpractices`, `pwa-audit`, `qa-mobile`, `design-critic`
- **DevOps, Release & Logs** — `docker-devops`, `ci-fix`, `project-release`, `project-stats`, `tag-audit`, `log-audit`, `railway-debug`
- **i18n, SaaS & Lançamento** — `i18n-audit`, `i18n-maintenance`, `launch-audit`, `saas-bootstrap`, `saas-migration-audit`
- **Produtividade & Time** — `tasknotes`, `sprint-report`, `weekly-metrics`, `session-close`, `team-plan`, `team-execute`, `team-reviewer`

## 6. Formato das Skills

Cada skill é uma pasta `plugins/imersao/skills/<nome>/` com um `SKILL.md`. O frontmatter YAML precisa de **`name`** e **`description`** — é só isso que o Claude Code usa para descobrir e acionar a skill:

```yaml
---
name: minha-skill
description: "O que a skill faz e QUANDO usá-la (gatilhos em PT-BR e EN ajudam na descoberta)"
---

# Minha Skill

Conteúdo em Markdown: instruções passo a passo, exemplos de código,
padrões, boas práticas e checklist de validação.
```

Campos como `version`, `author` e `tags` são **opcionais e decorativos** — o runtime não depende deles. A versão oficial do plugin fica em `plugins/imersao/.claude-plugin/plugin.json`. Veja `schema/skill-schema.yml` para o contrato completo.

## 6. Contribuindo

Para adicionar ou melhorar uma skill:

1. Faça um fork ou crie um branch em `parisgroup-ai/imersao-ia-setup`.
2. Crie/edite `plugins/imersao/skills/<nome>/SKILL.md` com frontmatter `name` + `description` válido.
3. Rode a validação local: `bash scripts/validate-skills.sh`.
4. Abra um **Pull Request**. O CI valida os manifestos e o frontmatter automaticamente.

Depois do merge, quem já instalou o plugin recebe a novidade com `claude plugin update imersao` (ou `/plugin` → update). Sem cópia manual, sem tabela para manter.

---

**Dúvidas?** Explore os exemplos em `plugins/imersao/skills/`. Cada skill tem documentação completa.

**Nos vemos na imersão! 🚀**
