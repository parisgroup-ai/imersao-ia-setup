# Output Template — Test Rigor Audit Report

Use este esqueleto exato. Substitua `<placeholders>`. Salve em `docs/reports/test-rigor-audit-<YYYY-MM-DD>-<scope>.md` quando o usuário concordar.

```markdown
# Test Rigor Audit — <target description>

> **Run:** <YYYY-MM-DD HH:MM>
> **Framework(s):** <list>
> **Scope:** <e.g., apps/web/src/app/(app)/(creator)/**/*.test.tsx>
> **Files scanned:** N
> **Tests scanned:** N
> **Auditor:** test-rigor-audit skill

## TL;DR

<1-3 sentences. State the bottom line. Examples:

- "Suite verde mas frágil: 18 testes não pegariam regressão. 2 CRITICAL bloqueiam CI; 12 HIGH são candidatos a fortalecer antes do refactor de X."
- "Suite saudável: 0 CRITICAL, 3 HIGH (todos snapshot tests sem behavior assertion). Recomendação: completar com 1 assertion behavioral cada."
- "Suite enganosa: 67% dos testes em apps/web/.../checkout/* só verificam mock interactions. Refactor do checkout nesse estado é arriscado.">

## Summary

| Severidade | Count | Top categoria | Top arquivo |
|---|---|---|---|
| 🔴 CRITICAL | N | <e.g., it.only em commit> | <path> |
| 🟠 HIGH | N | <e.g., tautological assertion> | <path> |
| 🟡 MEDIUM | N | <e.g., snapshot sem behavior> | <path> |
| 🟢 LOW | N | <e.g., console.log clutter> | <path> |
| **Total** | **N** | | |

### Categoria breakdown

| Categoria | Count | Severidade típica |
|---|---|---|
| Tautological assertion | N | HIGH |
| No assertion in body | N | HIGH |
| .only em commit | N | CRITICAL |
| .skip sem tracker | N | HIGH |
| Mock-everything (SUT mocked) | N | CRITICAL |
| Swallowed exception + always-pass | N | CRITICAL |
| Snapshot sem behavior | N | MEDIUM |
| (...) | N | (...) |

## Findings (grouped by file)

<Para cada arquivo, ordenar findings por severidade (CRITICAL > HIGH > MEDIUM > LOW). Limitar a 5 findings por arquivo no relatório principal — o resto vai pra anexo.>

### `<relative/path/to/file.test.ts>` — N findings

#### 🔴 [CRITICAL] `<categoria>` — line `<N>`

```<lang>
<snippet exato do teste, 3-7 linhas, com ← marcador no problema>
```

**Por que importa:** <1-2 sentences. "Esse teste passa mesmo se o SUT retornar undefined — a assertion compara o mock contra ele mesmo.">

**Fix sugerido:** <1-2 sentences. "Substituir por assertion contra valor esperado real (ex: UUID do usuário criado no setup)." Ou "Deletar — outro teste no arquivo Y já cobre esse comportamento.">

---

#### 🟠 [HIGH] `<categoria>` — line `<N>`

(...)

---

### `<another-file>` — N findings

(...)

## TaskNote bodies (HIGH+)

<Para findings agrupados que totalizam > 30min de trabalho, gerar body de TaskNote. NÃO criar a task — só fornecer o body. Usuário decide se vira task formal ou rodado inline.>

### TaskNote 1 — fortalecer `<arquivo ou cluster>`

```markdown
## Context

`<file path>` tem `<N>` testes com anti-pattern `<categoria>` que não pegam regressão. Detectado pelo `test-rigor-audit` em `<date>`.

Achados:
- line N: <one-line summary>
- line N: <one-line summary>
(...)

## Acceptance Criteria

- [ ] Para cada teste flagged, decidir: FORTALECER | DELETAR | SKIP-EXPLICIT
- [ ] FORTALECER: assertion ataca output real do SUT (não mock return value, não literal idêntico)
- [ ] DELETAR: confirmar que outro teste cobre o comportamento (grep pelo símbolo)
- [ ] SKIP-EXPLICIT: comentário `// SKIP — <reason> — <tracker>` (convenção ADR-0150 ou equivalente)
- [ ] `<framework run command, e.g., pnpm -C apps/web test>` exits 0
- [ ] Audit rerun no mesmo arquivo retorna 0 findings da categoria

## Source

Detectado por `test-rigor-audit` em `<date>`. Refs: `<audit-report-path>`.
```

### TaskNote 2 — (...)

(...)

## Next steps

1. **Triar CRITICALs primeiro** (~ N min). <Recomendação concreta. Ex: "Remover 2 `.only` antes do próximo push.">
2. **Pra HIGH em arquivos sob refactor planejado** (mencione o refactor se conhecido), fortalecer ANTES do refactor.
3. **MEDIUM/LOW** podem ir pra backlog técnico ou serem batched numa CHORE de cleanup.
4. **Mutation testing** — se a suite cobre código crítico (pagamentos, auth), considerar Stryker (TS) ou mutmut (Py) pra confirmar empiricamente quais testes pegam regressão. Audit é heurístico; mutation é definitivo.

## Counter-examples noted (não flagged)

<Listar 3-5 patterns que pareciam suspeitos mas foram explicitamente OK. Documenta por que pra evitar reflag em runs futuros e pra calibrar o usuário sobre falsos positivos comuns. Ex:

- `apps/web/src/.../*Copy.test.tsx`: i18n contract tests com `expect(text).toBe("string literal")` parecem tautológicos mas o LHS resolve via `useTranslations` — assertion legítima de pinning de string shipped.
- `apps/ana-service/.../test_llm_provider.py`: mocks de `AnthropicProvider.send` são legítimos — provedor é dependency, não SUT do serviço.>

## Limitações deste run

- <Liste limitações reais. Ex:
  - "Não rodei mutation testing — heurística baseada em leitura."
  - "Apps com TypeScript declaration files dispersos não tiveram AST scan completo."
  - "Bats suite pequena demais (3 arquivos) — confiabilidade do sample limitada.">
```
