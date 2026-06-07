# Imersão IA - ParisGroup AI

Repositório central da Imersão de IA. Contém o **instalador do ambiente** e um **plugin de skills de IA** curadas para turbinar seu desenvolvimento com Claude Code e Codex.

## 1. Instalação do Ambiente

Para configurar seu Mac com todas as ferramentas necessárias, cole o comando abaixo no Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

### O que será instalado:

- **Xcode Command Line Tools** — Git e compilador nativo
- **Homebrew** — gerenciador de pacotes
- **Node.js** — runtime JavaScript (necessário para Claude Code e Codex)
- **GitHub CLI (`gh`)** — autenticação e operações no GitHub pelo terminal
- **Ghostty** — terminal moderno e otimizado
- **Docker Desktop** — containerização e orquestração
- **Obsidian** — notas e base de conhecimento
- **Claude Desktop** — app desktop do Claude
- **Claude Code** — CLI do Claude (npm)
- **Codex CLI** — CLI do OpenAI Codex (npm)
- **Skills da Imersão** — instaladas automaticamente como plugin do Claude Code (passo 8 do instalador)

O script verifica cada item e pula os que já estão instalados. Ao final, **feche e reabra o terminal** (ou o Claude Code) para carregar tudo. Pode levar alguns minutos — siga as instruções na tela e forneça sua senha quando pedida.

> O instalador configura o npm para instalar pacotes globais no seu usuário (`~/.npm-global`), evitando `sudo npm install -g` — que costuma quebrar atualizações futuras.

**Instalou e travou em algo?** Veja [docs/PRIMEIROS-PASSOS.md](docs/PRIMEIROS-PASSOS.md) (o que fazer depois do setup) e [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) (erros comuns). Para re-checar o ambiente a qualquer momento:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

## 2. Skills de IA (plugin)

As skills são distribuídas como um **plugin do Claude Code** via marketplace. Não é preciso copiar pastas à mão: o Claude Code descobre cada skill automaticamente, e você atualiza ou desinstala com um comando.

O instalador já faz isso por você. Se quiser instalar manualmente (ou em outra máquina), dentro do **Claude Code** rode:

```text
/plugin marketplace add parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

Ou pelo terminal, com o CLI:

```bash
claude plugin marketplace add parisgroup-ai/imersao-ia-setup
claude plugin install imersao@imersao-ia
```

Reinicie o Claude Code para carregar as skills.

### Codex

Plugins são um recurso do **Claude Code**. Para usar as mesmas skills no **Codex**, rode o script de sincronização (copia as skills para `~/.codex/skills/`):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/sync-codex-skills.sh | bash
```

## 3. Processo da Imersão (do PRD ao app)

O plugin traz um **pipeline guiado** que leva da ideia a um app funcionando, em 3 fases sobre um motor autônomo (`/imersao:pg-imersao-goal`, com 2 gates humanos):

| Comando | Fase | O que faz |
|---|---|---|
| `/imersao:pg-imersao-prd` | 1 | Ideia → `docs/PRD.md` (brainstorming guiado) |
| `/imersao:pg-imersao-prototipo` | 2 | PRD → protótipo no **Design OS** público → export React + Tailwind |
| `/imersao:pg-imersao-implementar` | 3 | Export + PRD → app **Next.js + Tailwind + shadcn/ui + Drizzle + Postgres (Docker)** |

Passo a passo completo (aluno + instrutor): **[docs/PROCESSO-IMERSAO.md](docs/PROCESSO-IMERSAO.md)**.

## 4. Gerenciar skills

| Ação | Comando (dentro do Claude Code) | Comando (CLI) |
|------|----------------------------------|----------------|
| Listar instaladas | `/plugin` | `claude plugin list` |
| Ver detalhes | — | `claude plugin details imersao` |
| Atualizar | `/plugin` → update | `claude plugin update imersao` |
| Desinstalar | `/plugin` | `claude plugin uninstall imersao` |

`/plugin` sempre mostra a **lista completa e atualizada** das skills do plugin — não há tabela neste README para ficar desatualizada.

## 5. Skills disponíveis

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
