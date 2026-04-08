---
name: obsidian-docs
description: "Create comprehensive technical documentation following Obsidian conventions with bidirectional linking, proper folder structure, templates, and developer-focused content. Use when creating documentation, READMEs, wikis, knowledge bases, ADRs, runbooks, or any technical writing. Triggers on: documentation, docs, README, wiki, knowledge base, ADR, runbook, technical writing, Obsidian."
version: 1.0.0
author: gustavo
tags: [documentation, obsidian, knowledge-base]
---

# Obsidian Documentation Skill

This skill creates comprehensive, well-structured technical documentation optimized for Obsidian's knowledge management features. Documentation should be discoverable, maintainable, and interconnected.

## Vault Structure

### Recommended Folder Organization

```
docs/
├── 00-Index/
│   ├── 🏠 Home.md                    # Main entry point
│   ├── 📚 Documentation Map.md       # MOC (Map of Content)
│   └── 🔍 Quick Reference.md         # Common commands/links
│
├── 01-Getting-Started/
│   ├── Installation.md
│   ├── Configuration.md
│   ├── First Steps.md
│   └── Troubleshooting.md
│
├── 02-Architecture/
│   ├── System Overview.md
│   ├── Data Flow.md
│   ├── Component Diagram.md
│   └── Tech Stack.md
│
├── 03-API/
│   ├── API Overview.md
│   ├── Authentication.md
│   ├── Endpoints/
│   │   ├── Users.md
│   │   ├── Orders.md
│   │   └── Products.md
│   └── Error Codes.md
│
├── 04-Development/
│   ├── Setup Guide.md
│   ├── Code Style.md
│   ├── Git Workflow.md
│   ├── Testing Guide.md
│   └── CI-CD.md
│
├── 05-Operations/
│   ├── Deployment.md
│   ├── Monitoring.md
│   ├── Runbooks/
│   │   ├── Incident Response.md
│   │   ├── Database Recovery.md
│   │   └── Scaling.md
│   └── On-Call Guide.md
│
├── 06-ADRs/
│   ├── ADR-000 Template.md
│   ├── ADR-001 Use PostgreSQL.md
│   ├── ADR-002 JWT Authentication.md
│   └── ADR-Index.md
│
├── 07-Meeting-Notes/
│   └── YYYY-MM-DD Topic.md
│
├── 08-Glossary/
│   └── Terms.md
│
├── Templates/
│   ├── ADR Template.md
│   ├── Runbook Template.md
│   ├── Meeting Notes Template.md
│   ├── API Endpoint Template.md
│   └── Component Doc Template.md
│
└── Assets/
    ├── diagrams/
    ├── images/
    └── attachments/
```

## Obsidian Conventions

### Linking

```markdown
<!-- Internal links (wikilinks) -->
[[Installation]]                      <!-- Link to page -->
[[Installation|Setup Guide]]          <!-- Link with alias -->
[[Installation#Prerequisites]]        <!-- Link to heading -->
[[API/Users]]                         <!-- Link to nested page -->

<!-- Embeds -->
![[Architecture Diagram.png]]         <!-- Embed image -->
![[Component Doc#Overview]]           <!-- Embed section -->

<!-- External links -->
[GitHub Repo](https://github.com/org/repo)
```

### Tags

```markdown
<!-- Use tags for cross-cutting concerns -->
#status/draft
#status/review
#status/published

#type/adr
#type/runbook
#type/api
#type/guide

#team/backend
#team/frontend
#team/devops

#priority/high
#priority/medium
#priority/low
```

### Frontmatter (YAML)

```yaml
---
title: User Authentication API
created: 2024-01-15
updated: 2024-01-20
author: Team Backend
status: published
tags:
  - api
  - authentication
  - security
related:
  - "[[JWT Implementation]]"
  - "[[Security Practices]]"
---
```

### Callouts

```markdown
> [!info] Information
> General information or context.

> [!tip] Pro Tip
> Helpful suggestions or best practices.

> [!warning] Warning
> Important cautions or potential issues.

> [!danger] Critical
> Breaking changes or security concerns.

> [!example] Example
> Code examples or demonstrations.

> [!question] FAQ
> Common questions and answers.

> [!todo] Action Required
> Tasks that need to be completed.

> [!quote] Reference
> Citations or external references.
```

## Document Templates

### Home Page (🏠 Home.md)

```markdown
---
title: Project Documentation
created: {{date}}
updated: {{date}}
---

# 🏠 Project Name Documentation

Welcome to the documentation hub for **Project Name**.

## 🚀 Quick Start

1. [[Installation|Install the project]]
2. [[Configuration|Configure your environment]]
3. [[First Steps|Build your first feature]]

## 📖 Documentation Sections

| Section | Description |
|---------|-------------|
| [[01-Getting-Started/\|Getting Started]] | Installation and setup guides |
| [[02-Architecture/\|Architecture]] | System design and diagrams |
| [[03-API/\|API Reference]] | Endpoint documentation |
| [[04-Development/\|Development]] | Contributing guidelines |
| [[05-Operations/\|Operations]] | Deployment and monitoring |
| [[06-ADRs/\|ADRs]] | Architecture decisions |

## 🔗 Quick Links

- [[🔍 Quick Reference]]
- [[Glossary/Terms\|Glossary]]
- [GitHub Repository](https://github.com/org/repo)
- [Issue Tracker](https://github.com/org/repo/issues)

## 📊 Project Status

> [!info] Current Version
> **v1.2.3** - Released {{date}}

## 🆘 Need Help?

- Check [[Troubleshooting]] for common issues
- Search the [[Glossary/Terms|Glossary]] for definitions
- Ask in #team-channel on Slack
```

### ADR Template (ADR-000 Template.md)

```markdown
---
title: "ADR-{{number}}: {{title}}"
created: {{date}}
status: proposed | accepted | rejected | superseded
deciders:
  - Name 1
  - Name 2
requirements:
  - "REQ-###"
tags:
  - type/adr
  - status/{{status}}
supersedes:
superseded_by:
---

# ADR-{{number}}: {{title}}

## Status

**{{status}}** — {{date}}

## Contexto

<!-- Problema a ser resolvido, restrições, premissas -->

Descreva o contexto e o problema. Quais forças estão em jogo?

## Decisão

**Opção escolhida:** {{opção}} porque {{justificativa objetiva}}.

## Consequências

### Positivas

- Benefício 1
- Benefício 2

### Negativas

- Desvantagem 1
- Desvantagem 2

## Opções Consideradas

| Opção | Descrição | Prós | Contras |
|-------|-----------|------|---------|
| A | {{descrição}} | {{prós}} | {{contras}} |
| B | {{descrição}} | {{prós}} | {{contras}} |

---

<!-- SEÇÕES OPCIONAIS - Incluir se aplicável -->

## [Se aplicável] Critérios de Escolha

<!-- Custo, prazo, risco, SLO, compliance -->

| Critério | Peso | Opção A | Opção B |
|----------|------|---------|---------|
| Custo | Alto | ✓ | |
| Risco | Médio | | ✓ |

## [Se aplicável] Evidências

<!-- Benchmarks, PoC, métricas, estimativas -->

- Benchmark: {{resultado}}
- PoC: [[link para PoC]]

## [Se aplicável] Impactos

| Área | Impacto | Descrição |
|------|---------|-----------|
| Arquitetura | Alto/Médio/Baixo | |
| Performance | Alto/Médio/Baixo | |
| Segurança | Alto/Médio/Baixo | |
| Custos | Alto/Médio/Baixo | |

## [Se aplicável] Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| {{risco}} | Alta/Média/Baixa | Alto/Médio/Baixo | {{mitigação}} |

## [Se aplicável] Plano de Rollback

**Gatilhos:** {{quando reverter — métricas, erros, tempo}}

**Passos:**
1. {{passo 1}}
2. {{passo 2}}

**Validação:** {{como confirmar que reverteu}}

## [Se aplicável] Condições de Revisão

<!-- Quando reavaliar esta decisão -->

- Reavaliar em {{data}} ou quando {{condição}}

---

## Links

- Requisitos: [[REQ-###]]
- PRs: [[PR #123]]
- Testes: [[TEST-###]]
- ADRs relacionados: [[ADR-###]]

## Referências

- [Link externo 1](url)
- [Link externo 2](url)
```

### PR Template (Pull Request)

```markdown
---
title: "PR: {{título}}"
created: {{date}}
author: {{name}}
status: draft | ready | merged
adr:
  - "ADR-###"
requirements:
  - "REQ-###"
tags:
  - type/pr
---

# {{título}}

## Resumo

<!-- O que mudou e por quê (2-3 frases) -->

## Requisitos

- [[REQ-###]] — {{descrição breve}}

## ADR Vinculado

<!-- OBRIGATÓRIO para mudanças estruturais -->

- [[ADR-###]] — {{título da decisão}}

> [!warning] Sem ADR?
> Se esta PR envolve decisão arquitetural, crie o ADR primeiro.

## Escopo

| Incluído | Excluído |
|----------|----------|
| {{item}} | {{item}} |

## Checklist de Qualidade

- [ ] Testes adicionados/atualizados
- [ ] Cobertura mínima atendida
- [ ] Lint/type-check passando
- [ ] Migrações aplicadas (se houver)
- [ ] Feature flags configuradas (se houver)

---

<!-- SEÇÕES OPCIONAIS -->

## [Se aplicável] Impacto

| Área | Descrição |
|------|-----------|
| Performance | |
| Custo | |
| Segurança | |

## [Se aplicável] Riscos

| Risco | Mitigação |
|-------|-----------|
| {{risco}} | {{mitigação}} |

## [Se aplicável] Rollback

**Passos:**
1. {{passo 1}}
2. {{passo 2}}

---

## Evidências

<!-- Screenshots, logs, métricas, antes/depois -->

## Deploy

| Campo | Valor |
|-------|-------|
| Ambiente | staging / production |
| Versão | {{versão}} |
| Data | {{data}} |

## Aprovações

- [ ] Code review: @{{reviewer}}
- [ ] QA: @{{qa}} (se aplicável)
```

### Runbook Template

```markdown
---
title: "Runbook: {{title}}"
created: {{date}}
updated: {{date}}
owner: Team/Person
severity: P1 | P2 | P3 | P4
tags:
  - type/runbook
  - team/{{team}}
---

# 🔧 Runbook: {{title}}

> [!warning] Severity Level
> **{{severity}}** - Response time: {{response_time}}

## Overview

Brief description of when to use this runbook.

## Symptoms

- [ ] Symptom 1 (how to identify)
- [ ] Symptom 2
- [ ] Symptom 3

## Prerequisites

- Access to [system/tool]
- Permissions: [required permissions]
- Tools: [required CLI tools]

## Diagnosis Steps

### 1. Check System Status

\`\`\`bash
# Command to check status
kubectl get pods -n production
\`\`\`

**Expected output**: Description of healthy state

### 2. Review Logs

\`\`\`bash
# Command to view logs
kubectl logs -f deployment/app -n production
\`\`\`

**Look for**: Error patterns, stack traces

## Resolution Steps

### Scenario A: [Description]

1. **Step 1**: Action description
   \`\`\`bash
   command here
   \`\`\`

2. **Step 2**: Action description
   \`\`\`bash
   command here
   \`\`\`

3. **Verify**: How to confirm resolution
   \`\`\`bash
   command here
   \`\`\`

### Scenario B: [Description]

1. **Step 1**: Action description

## Rollback Procedure

> [!danger] Use with caution
> Only proceed if resolution steps fail.

\`\`\`bash
# Rollback command
kubectl rollout undo deployment/app -n production
\`\`\`

## Post-Incident

- [ ] Update incident ticket
- [ ] Notify stakeholders
- [ ] Schedule post-mortem if P1/P2
- [ ] Update this runbook if needed

## Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | On-call engineer | First response |
| L2 | Team Lead | After 30 min |
| L3 | Engineering Manager | After 1 hour |

## Related

- [[Monitoring|Monitoring Dashboard]]
- [[Incident Response]]
- [[Architecture Overview]]

## History

| Date | Author | Change |
|------|--------|--------|
| {{date}} | {{author}} | Initial version |
```

### API Endpoint Template

```markdown
---
title: "API: {{endpoint_name}}"
created: {{date}}
updated: {{date}}
version: v1
tags:
  - type/api
  - api/{{resource}}
---

# {{HTTP_METHOD}} {{endpoint_path}}

{{brief_description}}

## Overview

| Property | Value |
|----------|-------|
| **Method** | `{{HTTP_METHOD}}` |
| **Path** | `{{endpoint_path}}` |
| **Auth** | Required / Optional / None |
| **Rate Limit** | 100 req/min |

## Request

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token |
| `Content-Type` | Yes | `application/json` |

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string (UUID) | Resource identifier |

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page |

### Request Body

\`\`\`json
{
  "name": "string",
  "email": "string",
  "role": "user | admin"
}
\`\`\`

## Response

### Success (200 OK)

\`\`\`json
{
  "data": {
    "id": "usr_abc123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "requestId": "req_xyz789"
  }
}
\`\`\`

### Errors

| Code | Error | Description |
|------|-------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 404 | `NOT_FOUND` | Resource not found |
| 422 | `UNPROCESSABLE` | Business rule violation |

> [!example] Error Response
> \`\`\`json
> {
>   "error": {
>     "code": "VALIDATION_ERROR",
>     "message": "Invalid input",
>     "details": [
>       { "field": "email", "message": "Invalid format" }
>     ]
>   }
> }
> \`\`\`

## Examples

### cURL

\`\`\`bash
curl -X {{HTTP_METHOD}} \
  '{{base_url}}{{endpoint_path}}' \
  -H 'Authorization: Bearer {{token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "John Doe",
    "email": "john@example.com"
  }'
\`\`\`

### JavaScript (fetch)

\`\`\`javascript
const response = await fetch('{{base_url}}{{endpoint_path}}', {
  method: '{{HTTP_METHOD}}',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
  }),
});

const data = await response.json();
\`\`\`

## Related

- [[Authentication]]
- [[Error Codes]]
- [[Rate Limiting]]
```

### Component Documentation Template

```markdown
---
title: "Component: {{name}}"
created: {{date}}
updated: {{date}}
owner: {{team}}
status: active | deprecated | experimental
tags:
  - type/component
  - team/{{team}}
---

# {{name}}

{{brief_description}}

## Overview

| Property | Value |
|----------|-------|
| **Owner** | {{team}} |
| **Language** | TypeScript |
| **Repository** | [Link](url) |
| **Status** | {{status}} |

## Purpose

What problem does this component solve? Why does it exist?

## Architecture

\`\`\`mermaid
graph TD
    A[Client] --> B[{{name}}]
    B --> C[Database]
    B --> D[External API]
\`\`\`

![[component-diagram.png]]

## Dependencies

### Upstream (depends on)

- [[Database Service]] - Data persistence
- [[Auth Service]] - Token validation

### Downstream (depended by)

- [[API Gateway]] - Routes requests here
- [[Admin Dashboard]] - Consumes data

## Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | - | PostgreSQL connection |
| `LOG_LEVEL` | No | `info` | Logging verbosity |

## API

### Public Methods

#### `createUser(data: CreateUserInput): Promise<User>`

Creates a new user.

\`\`\`typescript
const user = await userService.createUser({
  name: 'John',
  email: 'john@example.com',
});
\`\`\`

### Events Emitted

| Event | Payload | When |
|-------|---------|------|
| `user.created` | `{ userId, email }` | After user creation |
| `user.deleted` | `{ userId }` | After user deletion |

## Development

### Local Setup

\`\`\`bash
# Install dependencies
npm install

# Run locally
npm run dev

# Run tests
npm run test
\`\`\`

### Testing

\`\`\`bash
# Unit tests
npm run test:unit

# Integration tests
npm run test:integration
\`\`\`

## Deployment

See [[Deployment Guide]] for full instructions.

\`\`\`bash
# Deploy to staging
npm run deploy:staging

# Deploy to production
npm run deploy:prod
\`\`\`

## Monitoring

- **Dashboard**: [Grafana Link](url)
- **Logs**: [Datadog Link](url)
- **Alerts**: [[Runbooks/{{name}} Alerts]]

## Troubleshooting

### Common Issues

#### Issue 1: Connection timeout

**Symptoms**: Requests fail with timeout error

**Solution**: Check database connectivity
\`\`\`bash
pg_isready -h localhost -p 5432
\`\`\`

## Related

- [[Architecture Overview]]
- [[API Reference]]
- [[ADR-001 Tech Stack Decision]]

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | {{date}} | Initial release |
```

## Governance Rules

Regras de rastreabilidade para manter consistência entre artefatos de documentação.

### Regra 1: IDs Obrigatórios

Todo artefato rastreável deve ter ID único:

| Artefato | Formato | Exemplo |
|----------|---------|---------|
| Requisito | `REQ-###` | REQ-042 |
| ADR | `ADR-###` | ADR-007 |
| PR | `PR #####` | PR #123 |
| Teste | `TEST-###` | TEST-101 |

**Commits devem referenciar IDs:**

```bash
feat(users): add password reset [REQ-042]
fix(auth): token expiry [ADR-007, PR #120]
```

### Regra 2: Links Bidirecionais

Toda referência deve existir nos dois sentidos:

```text
REQ-042 ←→ ADR-007 ←→ PR #123 ←→ TEST-101
```

| Se você cria... | Deve linkar em... |
|-----------------|-------------------|
| ADR | Requisitos que motivaram |
| PR | ADR que fundamenta (se estrutural) |
| Teste | Requisito ou PR que valida |

### Regra 3: ADR Obrigatório para Decisões Estruturais

**Requer ADR antes do PR:**

- Mudança de arquitetura
- Nova dependência externa
- Alteração de schema/API pública
- Mudança de infraestrutura
- Trade-off de performance/custo

**Não requer ADR:**

- Bug fixes
- Refactoring interno
- Atualizações de dependência (patch/minor)
- Documentação

> [!danger] Bloqueio
> PR sem ADR vinculado para decisão estrutural = não pode mergear.

### Regra 4: Rollback Sempre Definido

Todo ADR e PR estrutural deve responder:

1. **Gatilhos:** Quando reverter? (métricas, erros, tempo)
2. **Passos:** Como reverter? (comandos, ordem)
3. **Validação:** Como confirmar que reverteu?

```markdown
## Plano de Rollback

**Gatilhos:** Error rate > 5% ou latência p99 > 500ms

**Passos:**
1. `kubectl rollout undo deployment/api`
2. Verificar métricas no Grafana

**Validação:** Health check verde + error rate < 1%
```

## Writing Guidelines

### Tone & Style

1. **Be concise** - Developers skim documentation
2. **Use active voice** - "Run the command" not "The command should be run"
3. **Show, don't tell** - Code examples over lengthy explanations
4. **Keep it current** - Outdated docs are worse than no docs

### Structure Rules

1. **Start with why** - Context before instructions
2. **Progressive disclosure** - Overview → Details → Deep dive
3. **One topic per page** - Makes linking effective
4. **Use headings liberally** - Enable quick scanning

### Code Examples

```markdown
<!-- Always include language for syntax highlighting -->
\`\`\`typescript
const example = 'highlighted';
\`\`\`

<!-- Show both command and expected output -->
\`\`\`bash
$ npm run build
> Building for production...
> ✓ Build complete
\`\`\`

<!-- Use comments to explain non-obvious parts -->
\`\`\`typescript
// This timeout is required due to rate limiting
await sleep(1000);
\`\`\`
```

### Visual Elements

```markdown
<!-- Use tables for structured data -->
| Column 1 | Column 2 |
|----------|----------|
| Data     | Data     |

<!-- Use Mermaid for diagrams -->
\`\`\`mermaid
flowchart LR
    A --> B --> C
\`\`\`

<!-- Use callouts for important info -->
> [!warning] Breaking Change
> This affects all users upgrading from v1.x
```

## Checklist

### Documentação Geral

Antes de publicar qualquer documentação:

- [ ] Frontmatter completo (title, date, tags, status)
- [ ] Links internos usam formato `[[wikilink]]`
- [ ] Exemplos de código testados e funcionando
- [ ] Callouts usados para warnings/tips
- [ ] Páginas relacionadas linkadas
- [ ] Sem links quebrados
- [ ] Imagens na pasta Assets
- [ ] Tags seguem convenções
- [ ] Índice/sumário lógico
- [ ] Revisado para erros de digitação

### Governance: ADR

Antes de finalizar um ADR:

- [ ] ID único atribuído (`ADR-###`)
- [ ] Status definido (proposed/accepted/rejected/superseded)
- [ ] Requisitos vinculados no frontmatter (`requirements:`)
- [ ] Seções obrigatórias preenchidas:
  - [ ] Contexto (problema e forças em jogo)
  - [ ] Decisão (opção escolhida + justificativa objetiva)
  - [ ] Consequências (positivas e negativas)
  - [ ] Opções consideradas (mínimo 2 alternativas)
- [ ] Rollback definido (se decisão estrutural)
- [ ] Links bidirecionais criados (REQ ↔ ADR)

### Governance: PR

Antes de abrir um PR:

- [ ] Requisitos vinculados (`REQ-###`)
- [ ] ADR vinculado (se decisão estrutural)
- [ ] Escopo claro (incluído/excluído definidos)
- [ ] Checklist de qualidade completo:
  - [ ] Testes adicionados/atualizados
  - [ ] Cobertura mínima atendida
  - [ ] Lint/type-check passando
  - [ ] Migrações aplicadas (se houver)
  - [ ] Feature flags configuradas (se houver)
- [ ] Rollback definido (se mudança estrutural)
- [ ] Evidências anexadas (screenshots/logs/métricas)
- [ ] Links bidirecionais criados (ADR ↔ PR ↔ TEST)

### Validação Final de Governance

Antes de mergear:

- [ ] Nenhum PR estrutural sem ADR vinculado
- [ ] Todos os links bidirecionais verificados
- [ ] IDs únicos (sem duplicatas no projeto)
- [ ] Rollback testável (passos claros e executáveis)
