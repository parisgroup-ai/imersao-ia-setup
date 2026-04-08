# Pull Request Template

Copy this template for PR documentation.

---

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
