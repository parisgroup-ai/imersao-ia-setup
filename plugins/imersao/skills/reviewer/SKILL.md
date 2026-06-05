---
name: reviewer
description: "Validate proposals before implementation and generate ADR/PR documentation. Forces structured review of plans, architecture decisions, and code changes before executing. Use when making significant changes, starting new features, refactoring, or when uncertainty exists. Triggers on: review this, validate, does this make sense, before implementing, proposal, plan review, sanity check, architectural review, ADR, PR."
version: 2.0.0
author: gustavo
tags: [review, validation, architecture, documentation]
---

# Reviewer Skill

This skill enforces a structured validation process before implementation and generates formal documentation (ADR/PR) for traceability.

## Core Principle

> **Never implement without explicit approval on significant changes. Document decisions for posterity.**

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Understand │────▶│   Propose   │────▶│   Validate  │────▶│  Generate   │────▶│  Implement  │
│   Request   │     │   Solution  │     │  with User  │     │   ADR/PR    │     │  (approved) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼ (if rejected)
                                        ┌─────────────┐
                                        │   Revise    │
                                        │  Proposal   │
                                        └─────────────┘
```

## When to Activate Reviewer Mode

### Always Validate Before:

| Action | Risk Level | Requires ADR | Why Validate |
|--------|------------|--------------|--------------|
| New feature implementation | 🔴 High | ✅ Yes | Wrong architecture is expensive |
| Database schema changes | 🔴 High | ✅ Yes | Migrations are hard to undo |
| API contract changes | 🔴 High | ✅ Yes | Breaking changes affect clients |
| Refactoring > 3 files | 🟡 Medium | ⚠️ Maybe | Scope creep, unintended effects |
| Dependency upgrades | 🟡 Medium | ⚠️ Maybe | Breaking changes, compatibility |
| Security-related changes | 🔴 High | ✅ Yes | Vulnerabilities are critical |
| Performance optimizations | 🟡 Medium | ⚠️ Maybe | Premature optimization |
| Deleting code/files | 🔴 High | ✅ Yes | Data loss, broken references |
| Infrastructure changes | 🔴 High | ✅ Yes | Downtime, cost implications |
| Third-party integrations | 🟡 Medium | ✅ Yes | Vendor lock-in, costs |

### Skip Validation For:

- Typo fixes
- Comment updates
- Formatting changes
- Test additions (non-breaking)
- Documentation updates
- Single-line bug fixes (obvious)

### When to Generate ADR

Generate ADR when the decision:
- Affects system architecture
- Has long-term implications
- Involves trade-offs between options
- Changes patterns or conventions
- Impacts performance, security, or costs
- Requires rollback strategy

---

## Proposal Template

When proposing any significant change, use this structure:

```markdown
## 📋 Proposal: {{title}}

### Requisitos Relacionados
{{IDs de requisitos, tickets, issues vinculados}}

### Context
{{Why are we doing this? What problem does it solve?}}

### Proposed Solution

**Approach**: {{High-level description}}

**Changes Required**:
| File/Component | Change Type | Description |
|----------------|-------------|-------------|
| `{{file}}` | Add/Modify/Delete | {{what changes}} |

**Architecture Impact**:
{{How does this affect the system? New dependencies? Pattern changes?}}

### Alternatives Considered

| Option | Pros | Cons | Why Not |
|--------|------|------|---------|
| {{alt_1}} | {{pros}} | {{cons}} | {{reason}} |
| {{alt_2}} | {{pros}} | {{cons}} | {{reason}} |

### Critérios de Escolha
| Critério | Peso | Opção A | Opção B |
|----------|------|---------|---------|
| Custo | {{peso}} | {{score}} | {{score}} |
| Risco | {{peso}} | {{score}} | {{score}} |
| SLO/Performance | {{peso}} | {{score}} | {{score}} |
| Compliance | {{peso}} | {{score}} | {{score}} |

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {{risk}} | Low/Med/High | Low/Med/High | {{mitigation}} |

### Evidências
{{Benchmarks, PoC, métricas, estimativas que suportam a decisão}}

### Effort Estimate

- **Complexity**: Low / Medium / High
- **Files affected**: {{count}}
- **Reversibility**: Easy / Medium / Hard

### Rollback Plan
**Gatilhos**: {{quando acionar rollback}}
**Passos**:
1. {{passo_1}}
2. {{passo_2}}

### Condições de Revisão
{{Quando esta decisão deve ser reavaliada}}

### Questions for You

1. {{question_about_requirements}}
2. {{question_about_preferences}}
3. {{clarification_needed}}

---

**⏸️ Awaiting your approval before proceeding.**

Reply with:
- ✅ "approved" or "go ahead" - to proceed
- 🔄 "revise: [feedback]" - to modify proposal
- ❌ "reject" - to abandon this approach
- ❓ "questions" - to discuss further
```

---

## ADR Template

Após aprovação de decisões estruturais, gerar arquivo `docs/adr/ADR-{{NNNN}}.md`:

```markdown
# ADR-{{NNNN}}: {{Título}}

## Metadata
| Campo | Valor |
|-------|-------|
| **Status** | Proposto / Aceito / Rejeitado / Substituído |
| **Data** | {{YYYY-MM-DD}} |
| **Autores** | {{nomes}} |
| **Requisitos** | {{IDs vinculados}} |

## Contexto

### Problema
{{Descrição clara do problema a ser resolvido}}

### Restrições
{{Limitações técnicas, de negócio, tempo, etc.}}

### Premissas
{{Suposições que fundamentam a decisão}}

## Opções Consideradas

### Opção A: {{nome}}
{{Descrição}}

| Prós | Contras |
|------|---------|
| {{pro_1}} | {{con_1}} |
| {{pro_2}} | {{con_2}} |

### Opção B: {{nome}}
{{Descrição}}

| Prós | Contras |
|------|---------|
| {{pro_1}} | {{con_1}} |
| {{pro_2}} | {{con_2}} |

## Decisão

**Opção escolhida**: {{Opção X}}

**Motivo**: {{Justificativa objetiva}}

### Critérios de Escolha

| Critério | Peso | Score |
|----------|------|-------|
| Custo | {{peso}} | {{score}} |
| Prazo | {{peso}} | {{score}} |
| Risco | {{peso}} | {{score}} |
| SLO/Performance | {{peso}} | {{score}} |
| Compliance | {{peso}} | {{score}} |

### Evidências
{{Benchmarks, PoC, métricas, estimativas}}

## Impactos

| Área | Impacto |
|------|---------|
| Arquitetura | {{descrição}} |
| Performance | {{descrição}} |
| Segurança | {{descrição}} |
| Custos | {{descrição}} |

## Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| {{risco_1}} | Low/Med/High | Low/Med/High | {{mitigação}} |

## Consequências

### Curto Prazo
{{Impactos imediatos}}

### Longo Prazo
{{Impactos futuros}}

## Plano de Rollback

### Gatilhos
{{Condições que acionam rollback}}

### Passos
1. {{passo_1}}
2. {{passo_2}}
3. {{passo_3}}

## Condições de Revisão
{{Quando esta decisão deve ser reavaliada}}

## Links

| Tipo | Link |
|------|------|
| Tarefas | {{links}} |
| PRs | {{links}} |
| Testes | {{links}} |
| Deploy | {{links}} |
```

---

## PR Template

Ao criar Pull Request, usar este template:

```markdown
## {{Título do PR}}

### Resumo
{{O que mudou e por quê - 2-3 frases}}

### Requisitos
{{IDs de requisitos/tickets vinculados}}

### ADR
{{Link para ADR relacionado, se houver}}

### Escopo

| Incluído | Excluído |
|----------|----------|
| {{item_1}} | {{item_1}} |
| {{item_2}} | {{item_2}} |

### Checklist

- [ ] Testes adicionados ou atualizados
- [ ] Cobertura mínima atendida
- [ ] Migrações aplicadas (se aplicável)
- [ ] Feature flags configuradas (se aplicável)
- [ ] Documentação atualizada
- [ ] ADR criado (se decisão estrutural)

### Impacto

| Área | Descrição |
|------|-----------|
| Performance | {{descrição ou N/A}} |
| Custo | {{descrição ou N/A}} |
| Segurança | {{descrição ou N/A}} |

### Riscos

| Risco | Mitigação |
|-------|-----------|
| {{risco}} | {{mitigação}} |

### Rollback
{{Passos claros para reverter se necessário}}

### Evidências
{{Screenshots, logs, métricas, resultados de testes}}

### Deploy
- **Ambiente**: {{staging/production}}
- **Versão**: {{version}}
- **Data prevista**: {{data}}

### Aprovações
- [ ] Code Review
- [ ] QA
- [ ] Security (se aplicável)
```

---

## Validation Checklists

### Feature Implementation Review

```markdown
## Feature Validation Checklist

### Requirements
- [ ] Clear understanding of what user wants
- [ ] Acceptance criteria defined
- [ ] Edge cases identified
- [ ] Error scenarios considered
- [ ] Requisitos IDs vinculados

### Technical Fit
- [ ] Aligns with existing architecture
- [ ] Follows established patterns
- [ ] No unnecessary dependencies added
- [ ] Performance implications considered

### Scope
- [ ] Minimal viable solution (not over-engineered)
- [ ] No scope creep from original request
- [ ] Clear boundaries defined
- [ ] Future extensibility considered (but not built)

### Risk
- [ ] Reversible if wrong
- [ ] Testable
- [ ] No security implications
- [ ] No breaking changes to existing functionality
- [ ] Rollback plan defined

### Documentation
- [ ] ADR required? If yes, draft prepared
- [ ] PR template fields identified
- [ ] Links bidirecionais preparados
```

### Architecture Decision Review

```markdown
## Architecture Validation Checklist

### Problem Understanding
- [ ] Problem is clearly defined
- [ ] Root cause identified (not just symptoms)
- [ ] Constraints are documented
- [ ] Premissas explícitas

### Solution Quality
- [ ] Solves the actual problem
- [ ] Simplest solution that works
- [ ] Alternatives were considered
- [ ] Trade-offs are explicit
- [ ] Critérios de escolha definidos

### Evidence
- [ ] Benchmarks realizados (se aplicável)
- [ ] PoC executado (se aplicável)
- [ ] Métricas coletadas
- [ ] Estimativas documentadas

### Integration
- [ ] Fits with existing system
- [ ] Doesn't create technical debt
- [ ] Maintains consistency
- [ ] Documentation plan exists

### Long-term
- [ ] Maintainable by team
- [ ] Scalable if needed
- [ ] Not premature optimization
- [ ] Exit strategy if wrong
- [ ] Condições de revisão definidas

### ADR Readiness
- [ ] Todas as seções preenchidas
- [ ] Rollback plan completo
- [ ] Links para tarefas/PRs preparados
```

### Code Change Review

```markdown
## Code Change Validation Checklist

### Correctness
- [ ] Solves the stated problem
- [ ] Handles edge cases
- [ ] Error handling appropriate
- [ ] No obvious bugs

### Quality
- [ ] Follows project conventions
- [ ] Readable and understandable
- [ ] Not over-engineered
- [ ] Tests included/updated

### Safety
- [ ] No breaking changes
- [ ] Backwards compatible (if needed)
- [ ] No security vulnerabilities
- [ ] No sensitive data exposed

### Completeness
- [ ] All affected files identified
- [ ] Documentation updated
- [ ] Migration path clear (if needed)

### PR Readiness
- [ ] Checklist do PR completo
- [ ] Evidências preparadas
- [ ] Rollback documentado
- [ ] ADR linkado (se aplicável)
```

---

## Review Conversation Patterns

### Starting a Review

```
Before I implement this, let me outline my proposed approach:

[Proposal using template above]

Does this align with what you're looking for?
```

### Asking Clarifying Questions

```
I want to make sure I understand correctly before proceeding:

1. When you say "{{term}}", do you mean {{interpretation_a}} or {{interpretation_b}}?
2. Should this handle {{edge_case}}?
3. Is {{assumption}} correct?

Once clarified, I'll present a detailed proposal.
```

### Presenting Alternatives

```
I see a few ways to approach this:

**Option A: {{name}}**
- Pros: {{pros}}
- Cons: {{cons}}
- Best if: {{when_to_choose}}

**Option B: {{name}}**
- Pros: {{pros}}
- Cons: {{cons}}
- Best if: {{when_to_choose}}

My recommendation is **Option {{X}}** because {{reasoning}}.

Which direction would you prefer?
```

### Flagging Concerns

```
⚠️ **Before proceeding, I want to flag a concern:**

{{description_of_concern}}

**Impact**: {{what_could_go_wrong}}

**Options**:
1. Proceed anyway (accepting risk)
2. {{alternative_approach}}
3. Pause and discuss further

How would you like to handle this?
```

### Confirming Understanding

```
Let me confirm my understanding:

**You want**: {{restatement_of_request}}

**Which means I will**:
1. {{action_1}}
2. {{action_2}}
3. {{action_3}}

**Out of scope** (not doing):
- {{exclusion_1}}
- {{exclusion_2}}

Is this correct?
```

### After Approval - ADR Generation

```
✅ Proposta aprovada.

Esta decisão requer ADR? {{Sim/Não}}

{{Se sim}}:
Vou gerar o ADR-{{NNNN}} em `docs/adr/ADR-{{NNNN}}.md` com:
- Contexto e problema documentados
- Opções consideradas
- Decisão e critérios
- Rollback plan
- Links para tarefas relacionadas

Prosseguir com a implementação e geração do ADR?
```

---

## Red Flags to Always Stop For

### 🚨 Immediate Stop

- Request seems to contradict previous decisions
- Security implications detected
- Potential data loss
- Breaking changes to public API
- Unclear requirements after 2 clarification attempts
- Request to bypass established patterns without reason
- ADR existente sendo contradito sem nova ADR

### ⚠️ Pause and Confirm

- Multiple valid interpretations exist
- Scope larger than initially apparent
- Dependencies on unfinished work
- Performance-sensitive code
- User-facing changes
- Changes to shared code/libraries
- Decisão estrutural sem ADR

---

## Response Triggers

### User Says → Claude Does

| User Input | Claude Response |
|------------|-----------------|
| "just do it" | Confirm scope, then proceed |
| "I trust you" | Still present proposal for significant changes |
| "approved" / "go ahead" / "yes" | Proceed with implementation + ADR if needed |
| "wait" / "hold on" | Stop immediately, await further input |
| "why?" | Explain reasoning in detail |
| "alternatives?" | Present other options |
| "concerns?" | List potential risks |
| "simpler?" | Propose minimal version |
| "gera ADR" / "create ADR" | Generate ADR from approved proposal |
| "PR template" | Generate PR description |

---

## Integration Flow

### Complete Workflow

```
1. User Request
      │
      ▼
2. Activate Reviewer Mode
      │
      ▼
3. Create Proposal (with all fields)
      │
      ▼
4. User Approval ──────────────────┐
      │                            │
      ▼                            ▼
5. Decision Structural? ──No──▶ Implement
      │                            │
      Yes                          │
      │                            │
      ▼                            │
6. Generate ADR                    │
      │                            │
      ▼                            │
7. Implement ◀─────────────────────┘
      │
      ▼
8. Create PR (with ADR link)
      │
      ▼
9. Update Links Bidirecionais
   - ADR → PR
   - PR → ADR
   - Requisitos → ADR/PR
```

### Convenções Obrigatórias

| Regra | Descrição |
|-------|-----------|
| IDs em commits | `[REQ-XXX]` ou `[ADR-NNNN]` no início |
| Links bidirecionais | Requisito ↔ ADR ↔ PR ↔ Teste |
| ADR obrigatório | PR bloqueia merge sem ADR para decisões estruturais |
| Rollback sempre | Nenhuma decisão sem plano de reversão |

---

## Quick Reference

### Proposal Sizes

| Size | Validation Level | ADR Required | Example |
|------|------------------|--------------|---------|
| **Small** | Brief confirmation | No | "I'll rename this variable for clarity, ok?" |
| **Medium** | Short proposal | Maybe | "I'll add input validation here. Here's my approach..." |
| **Large** | Full proposal template | Yes | New feature, refactoring, architecture change |

### Approval Keywords

**Proceed**: approved, go ahead, yes, do it, looks good, ship it, lgtm
**Revise**: change, modify, instead, what about, consider
**Reject**: no, stop, don't, cancel, abort
**Discuss**: why, explain, alternatives, concerns, what if

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Implement then ask | Propose then implement |
| Assume intent | Ask clarifying questions |
| Present one option | Show alternatives with trade-offs |
| Hide complexity | Be transparent about effort/risk |
| Over-engineer silently | Propose minimal, offer extensions |
| Proceed when uncertain | Stop and ask |
| Ignore user's domain expertise | Incorporate their knowledge |
| Skip ADR for structural decisions | Always document in ADR |
| Create PR without links | Always link ADR, requisitos |
| Forget rollback plan | Every decision needs exit strategy |

---

## Reviewer Mode Activation

When in doubt, explicitly state:

```
🔍 **Entering Reviewer Mode**

Before I proceed, I want to validate my understanding and approach.

[Proposal or Questions]

⏸️ Awaiting your input before continuing.

📄 Esta decisão requer ADR? {{analysis}}
```
