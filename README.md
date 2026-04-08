# Imersão IA - ParisGroup AI

Repositório central para a Imersão de IA. Contém o instalador do ambiente e um conjunto de skills de IA compartilhadas para potencializar seu desenvolvimento com Claude Code e Codex.

## 1. Instalação do Ambiente

Para configurar rapidamente seu Mac com todas as ferramentas necessárias, execute o comando abaixo no Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

### O que será instalado:

- **Xcode Command Line Tools** - Git e compilador nativo
- **Homebrew** - Gerenciador de pacotes
- **Node.js** - Runtime JavaScript (necessário para Claude Code e Codex)
- **Ghostty** - Terminal moderno e otimizado
- **Docker Desktop** - Containerização e orquestração
- **Obsidian** - Ferramenta de notas e conhecimento
- **Claude Desktop** - Aplicativo desktop do Claude
- **Claude Code** - CLI para automação com Claude (npm)
- **Codex CLI** - CLI para OpenAI Codex (npm)

O script verificará cada ferramenta e pulará aquelas já instaladas. Pode levar alguns minutos. Siga as instruções na tela e forneça sua senha quando solicitado.

## 2. Instalar Skills de IA

Para acessar as 28 skills de IA compartilhadas, você precisa copiar os meta-skills para seu ambiente Claude Code:

```bash
git clone https://github.com/parisgroup-ai/imersao-ia-setup.git ~/.ai-skills-cache && cp -r ~/.ai-skills-cache/meta/sync-skills ~/.claude/skills/ && cp -r ~/.ai-skills-cache/meta/share-skill ~/.claude/skills/
```

Após executar este comando:

1. Abra **Claude Code**
2. Execute o comando `/sync-skills` para sincronizar todas as skills do repositório

Pronto! As 28 skills estão disponíveis para uso.

## Comandos

Use os seguintes comandos em Claude Code para gerenciar skills:

| Comando | Descrição |
|---------|-----------|
| `/sync-skills` | Sincroniza todas as skills do repositório para seu ambiente local |
| `/sync-skills api-design clean-architecture` | Sincroniza apenas skills específicas (separadas por espaço) |
| `/share-skill api-design` | Compartilha uma skill local com o repositório da comunidade |
| `/share-skill api-design --pr` | Compartilha uma skill e cria um PR automaticamente no repositório |

## Skills Disponíveis

Aqui estão as 28 skills de IA disponibilizadas:

| Skill | Descrição |
|-------|-----------|
| **agents-maintenance** | Validação e manutenção de CLAUDE.md e AGENTS.md em monorepos |
| **api-design** | Design de APIs REST consistentes, versionadas com documentação OpenAPI |
| **clean-architecture** | Estruturação com clean architecture e princípios SOLID |
| **code-consolidation** | Consolidação e remoção de código duplicado |
| **code-quality** | Auditoria e análise de qualidade de código |
| **database-design** | Design de schemas de banco de dados e otimização de queries |
| **design-critic** | Auditoria de qualidade visual, acessibilidade e UI/UX |
| **docker-devops** | Containerização com Docker, CI/CD e automação |
| **e2e-analyze** | Diagnóstico e análise de falhas em testes E2E |
| **e2e-fix-cycle** | Loop automatizado de identificação e correção de falhas E2E |
| **e2e-run** | Execução de testes E2E com relatório detalhado |
| **github-design** | Design de workflows, padrões e estrutura do repositório GitHub |
| **i18n-audit** | Auditoria de internacionalização e traduções |
| **i18n-maintenance** | Manutenção e sincronização de arquivos de tradução |
| **logger-design** | Design de sistema de logging estruturado |
| **memory-bank** | Gerenciamento de memória persistente entre sessões para contexto contínuo |
| **mobile-pwa-usability** | Auditoria de usabilidade mobile, PWA e performance |
| **obsidian-docs** | Documentação técnica com convenções Obsidian (ADRs, runbooks, templates) |
| **prompt-maintenance** | Manutenção de templates de prompt com validação e rastreamento de dependências |
| **readme-maintenance** | Padronização e atualização de arquivos README |
| **redis-design** | Design de cache com Redis e estratégias de armazenamento |
| **reviewer** | Validação estruturada de propostas e planos antes da implementação |
| **saas-bootstrap** | Bootstrap de monorepo SaaS com estrutura profissional |
| **saas-migration-audit** | Análise de viabilidade de migração para stack SaaS canônica |
| **security-practices** | Auditoria e implementação de práticas de segurança |
| **tasknotes** | Gestão de tarefas no Obsidian com TaskNotes, Pomodoro e sprints |
| **testing-strategy** | Estratégia de testes unitários, integração e coverage |
| **weekly-metrics** | Relatório semanal de produtividade a partir de git e tarefas |

## Formato das Skills

Cada skill é um arquivo Markdown com frontmatter YAML que define metadados. Aqui está a estrutura:

```yaml
---
name: api-design
description: "Descrição clara da skill e quando usá-la"
version: 1.0.0
author: gustavo
tags: [categoria1, categoria2]
---

# Nome da Skill

Conteúdo detalhado em Markdown com:
- Instruções passo a passo
- Exemplos de código
- Padrões e boas práticas
- Checklist de validação
```

### Exemplo de Frontmatter Válido:

```yaml
---
name: minha-skill
description: "Faz tal coisa de forma legal"
version: 1.0.0
author: seu_nome
tags: [backend, api, design]
---
```

## Contribuindo

Para criar e compartilhar sua própria skill:

### 1. Criar a estrutura da skill

```bash
mkdir -p ~/.claude/skills/minha-skill
touch ~/.claude/skills/minha-skill/SKILL.md
```

### 2. Adicionar conteúdo ao SKILL.md

Crie o arquivo com frontmatter válido (confira o formato acima) e seu conteúdo educacional.

### 3. Compartilhar com `/share-skill`

```bash
/share-skill minha-skill
/share-skill minha-skill --pr
```

O comando `/share-skill` valida a skill, verifica conflitos de autoria e cria um PR no repositório da comunidade para revisão.

---

**Dúvidas?** Verifique os exemplos em `/skills/` neste repositório. Cada skill possui documentação completa com instruções de uso.

**Nos vemos na imersão! 🚀**
