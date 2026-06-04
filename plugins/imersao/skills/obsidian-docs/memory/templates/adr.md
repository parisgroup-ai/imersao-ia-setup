# ADR Template

Copy this template for new Architecture Decision Records.

---

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
