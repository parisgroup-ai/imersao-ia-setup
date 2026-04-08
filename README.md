# Imersao IA - ParisGroup AI

Repositorio central para a imersao de IA. Contem o instalador do ambiente e um conjunto de skills de IA compartilhadas para potencializar seu desenvolvimento com Claude Code e Codex.

## 1. Instalacao do Ambiente

Para configurar rapidamente seu Mac com todas as ferramentas necessarias, execute o comando abaixo no Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

### O que sera instalado:

- **Xcode Command Line Tools** - Git e compilador nativo
- **Homebrew** - Gerenciador de pacotes
- **Node.js** - Runtime JavaScript (necessario para Claude Code e Codex)
- **Ghostty** - Terminal moderno e otimizado
- **Docker Desktop** - Containerizacao e orquestracao
- **Obsidian** - Ferramenta de notas e conhecimento
- **Claude Desktop** - Aplicativo desktop do Claude
- **Claude Code** - CLI para automacao com Claude (npm)
- **Codex CLI** - CLI para OpenAI Codex (npm)

O script verificara cada ferramenta e pulara aquelas ja instaladas. Pode levar alguns minutos. Siga as instrucoes na tela e forneça sua senha quando solicitado.

## 2. Instalar Skills de IA

Para acessar as 20 skills de IA compartilhadas, voce precisa copiar os meta-skills para seu ambiente Claude Code:

```bash
git clone https://github.com/parisgroup-ai/imersao-ia-setup.git ~/.ai-skills-cache && cp -r ~/.ai-skills-cache/meta/sync-skills ~/.claude/skills/ && cp -r ~/.ai-skills-cache/meta/share-skill ~/.claude/skills/
```

Apos executar este comando:

1. Abra **Claude Code**
2. Execute o comando `/sync-skills` para sincronizar todas as skills do repositorio

Pronto! As 20 skills estao disponiveis para uso.

## Comandos

Use os seguintes comandos em Claude Code para gerenciar skills:

| Comando | Descricao |
|---------|-----------|
| `/sync-skills` | Sincroniza todas as skills do repositorio para seu ambiente local |
| `/sync-skills api-design clean-architecture` | Sincroniza apenas skills especificas (separadas por espaco) |
| `/share-skill api-design` | Compartilha uma skill local com o repositorio da comunidade |
| `/share-skill api-design --pr` | Compartilha uma skill e cria um PR automaticamente no repositorio |

## Skills Disponiveis

Aqui estao as 20 skills de IA disponibilizadas:

| Skill | Descricao |
|-------|-----------|
| **api-design** | Design de APIs REST consistentes, versionadas com documentacao OpenAPI |
| **clean-architecture** | Estruturacao com clean architecture e principios SOLID |
| **code-consolidation** | Consolidacao e remocao de codigo duplicado |
| **code-quality** | Auditoria e analise de qualidade de codigo |
| **database-design** | Design de schemas de banco de dados e otimizacao de queries |
| **design-critic** | Auditoria de qualidade visual, acessibilidade e UI/UX |
| **docker-devops** | Containerizacao com Docker, CI/CD e automacao |
| **e2e-analyze** | Diagnostico e analise de falhas em testes E2E |
| **e2e-fix-cycle** | Loop automatizado de identificacao e correcao de falhas E2E |
| **e2e-run** | Execucao de testes E2E com relatorio detalhado |
| **github-design** | Design de workflows, padroes e estrutura do repositorio GitHub |
| **i18n-audit** | Auditoria de internacionalizacao e traducoes |
| **i18n-maintenance** | Manutencao e sincronizacao de arquivos de traducao |
| **logger-design** | Design de sistema de logging estruturado |
| **mobile-pwa-usability** | Auditoria de usabilidade mobile, PWA e performance |
| **readme-maintenance** | Padronizacao e atualizacao de arquivos README |
| **redis-design** | Design de cache com Redis e estrategias de armazenamento |
| **saas-bootstrap** | Bootstrap de monorepo SaaS com estrutura profissional |
| **security-practices** | Auditoria e implementacao de praticas de seguranca |
| **testing-strategy** | Estrategia de testes unitarios, integracao e coverage |

## Formato das Skills

Cada skill e um arquivo Markdown com frontmatter YAML que define metadados. Aqui esta a estrutura:

```yaml
---
name: api-design
description: "Descricao clara da skill e quando usa-la"
version: 1.0.0
author: gustavo
tags: [categoria1, categoria2]
---

# Nome da Skill

Conteudo detalhado em Markdown com:
- Instrucoes passo a passo
- Exemplos de codigo
- Padroes e boas praticas
- Checklist de validacao
```

### Exemplo de Frontmatter Valido:

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

Para criar e compartilhar sua propria skill:

### 1. Criar a estrutura da skill

```bash
mkdir -p ~/.claude/skills/minha-skill
touch ~/.claude/skills/minha-skill/SKILL.md
```

### 2. Adicionar conteudo SKILL.md

Crie o arquivo com frontmatter valido (confira o formato acima) e seu conteudo educacional.

### 3. Compartilhar com `/share-skill`

```bash
/share-skill minha-skill
/share-skill minha-skill --pr
```

O comando `/share-skill` valida a skill, verifica conflitos de autoria e cria um PR no repositorio da comunidade para revisao.

---

**Duvidas?** Verifique os exemplos em `/skills/` neste repositorio. Cada skill possui documentacao completa com instrucoes de uso.

**Nos vemos na imersao! 🚀**
