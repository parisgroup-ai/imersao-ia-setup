---
name: test-rigor-audit
version: 0.1.0
description: >-
  Use when auditing tests that may not verify real behavior: tautological assertions, missing assertions, skipped
  tests without a tracker, mock-everything tests, swallowed exceptions, snapshot churn, and framework traps in
  vitest/jest, pytest, Playwright, and bats. Trigger on requests such as "audit testes fracos", "tests que não pegam
  regressão", "test rigor audit", "weak test audit", "no-op tests", or "antes de refatorar X auditar testes primeiro".
  Especially useful before refactoring a SUT, after a large PR, or during legacy onboarding. Produces a markdown
  report grouped by file with severity, evidence, and suggested fixes; high-severity findings include TaskNote bodies.
---

<!-- last-reviewed: 2026-05-17 -->

# Test Rigor Audit

Audita uma suite de testes pra encontrar testes que **não fazem trabalho real** — testes que passam (ou poderiam passar) independentemente do código sob teste estar correto. Cobre vitest/jest, pytest, Playwright e bats.

## Core Principle

> **Um teste faz trabalho real se, e somente se, ele FALHA quando o código sob teste quebra de forma significativa.**

Tudo o que esta skill detecta é uma violação dessa regra: assertion tautológica, ausência de assertion, mock que cobre o próprio SUT, exception silenciosamente engolida, skip sem tracker. O sintoma comum é: "o teste estava verde, mas não pegou a regressão". Esta skill encontra esses testes **antes** da regressão.

A skill é **audit-only**. Não aplica fix automático — cada anti-pattern tem decisão humana (deletar vs fortalecer vs investigar SUT). Pra os achados graves, gera body de TaskNote pronto pra criar via `pnpm task:new`.

## Quando usar

- **Antes de refatorar um SUT.** Os testes precisam pegar regressão pro refactor ser seguro. Audit primeiro, refactor depois.
- **Pós-merge de PR grande.** Cluster de testes novos é o momento de pegar weak tests com contexto fresco.
- **Onboarding em codebase legado.** Suite verde é informação enganosa se 30% dos testes não asseguram nada.
- **Quando uma regressão escapou.** Se o teste devia ter pego e não pegou, a suite tem um padrão sistêmico — audit acha os parentes do teste falho.
- **Periodicamente em projetos com >1k testes.** Drift de rigor acumula silenciosamente.

Não é o caso de uso pra **Quality Gate diário** — isto é uma skill de *deep audit*, lenta e meticulosa. Pra gates contínuos, use `coverage-check` + lint rules específicas (ex: eslint-plugin-vitest `expect-expect`).

## Workflow

```
┌──────────────────────────────────────────────────────────────────────┐
│ 1. ESCOPO   — file/dir/pattern do alvo + framework detection         │
│ 2. GREP     — mechanical sweep (grep recipes por framework)          │
│ 3. READ     — leitura dos arquivos sinalizados pra análise contextual│
│ 4. CLASSIFY — categorize por anti-pattern + severidade               │
│ 5. REPORT   — markdown report agrupado por arquivo                   │
│ 6. TASKNOTE — bodies prontos pros achados HIGH severity              │
└──────────────────────────────────────────────────────────────────────┘
```

Cada step tem fallback gracioso. Sem framework reconhecido → relatório vazio com nota explícita. Sem achados → reporte ainda assim (silêncio esconde "auditei mas não vi nada").

## Step 1: Escopo + framework detection

Pergunte (ou infira do prompt) o **alvo**:

- Path único: `apps/web/src/i18n/__tests__/`
- Pattern: `apps/web/**/*.test.tsx`
- Pacote inteiro: `apps/ana-service/`
- "tudo": monorepo todo (caro — confirme antes de rodar)

Detecção de framework por extensão + presença:

| Arquivo | Framework | Reference |
|---|---|---|
| `*.test.ts(x)` / `*.spec.ts(x)` em pkg com `vitest`/`jest` em deps | vitest/jest | `references/vitest-jest.md` |
| `test_*.py` / `*_test.py` com `pytest` em deps | pytest | `references/pytest.md` |
| `*.spec.ts` em pasta `e2e/` ou `playwright.config.ts` próximo | Playwright | `references/playwright.md` |
| `*.bats` ou `tests/**/*.bats` | bats | `references/bats.md` |

Mixed scope (monorepo): rode framework-by-framework, agregue no relatório final.

## Step 2: Mechanical grep sweep

Cada reference file lista grep recipes específicos. Universal across frameworks:

| Anti-pattern | Universal grep | Severidade |
|---|---|---|
| Tautological assertion | `expect\((\w+)\)\.toBe\(\1\)` (TS), `assert (\w+) == \1` (Py), `\[\[ "(\$\w+)" = "\1" \]\]` (bats) | HIGH |
| Always-true literal | `expect\((true|1)\)\.toBe\((true|1)\)` (TS), `assert True\b` (Py), `\[\[ true \]\]` / `true # noqa` (bats) | HIGH |
| Skip without tracker | `\.skip\(` / `@pytest.mark.skip` / `skip "[^A-Z0-9]` sem `(BUG|CHORE|FEAT|TASK)-\d+` ou `GH #?\d+` próximo | HIGH |
| `.only` left in committed code | `\b(it|describe|test)\.only\(` / `pytest.mark.only` / `bats fdescribe` | CRITICAL (CI risk) |
| TODO test | `it\.todo\(` / `@pytest.mark.skip.*todo` sem tracker | MEDIUM |
| Console.log no teste body | `console\.log` em `*.test.*` | LOW (clutter) |

Mais específicos vão nos reference files — leia o reference do framework relevante quando o grep universal não basta.

## Step 3: Read flagged files

Grep dá candidatos; leitura confirma. Pra cada arquivo sinalizado:

1. **Estrutura geral** — tem `describe` + `it`/`test`? Quantos testes? Quantos com assertion explícita?
2. **Mock posture** — `vi.mock`/`@patch` mockam o SUT ou só dependências? Mock do SUT é red flag.
3. **Assertion-to-act ratio** — testes que chamam SUT mas só verificam mock interactions são suspeitos.
4. **Setup vs body** — assertions em `beforeEach`/`fixture` em vez do `it` body é setup-test, não behavior-test.
5. **Try/catch swallow** — `try { sut() } catch {}` seguido de assertion trivial = teste sempre passa.

Heurística: **se você consegue mudar o SUT pra retornar `null` (ou `undefined`/`""`) e o teste ainda passa, o teste não faz trabalho real.** Não precisa rodar pra todos — basta ler.

## Step 4: Classify

Severidade calibrada pra impacto em refactor safety:

| Severidade | Definição | Exemplos |
|---|---|---|
| **CRITICAL** | Teste sempre passa OU bloqueia CI quando deveria. Ação imediata. | `.only` em código commitado, swallow + `assert True`, skip todo a suite por engano |
| **HIGH** | Teste não pega regressão real do SUT. Refactor cego é arriscado. | Tautological, mock-everything, no assertion, snapshot sem behavior check |
| **MEDIUM** | Teste pega só uma fração do que devia. Cobertura ilusória. | Apenas `toHaveBeenCalled()` sem args, screenshot sem assert, `expect.any()` excessivo |
| **LOW** | Anti-pattern de qualidade mas não compromete safety. | Console.log, naming ruim, body duplicado, falta description |

CRITICAL pode subir a HIGH se o impacto for específico ao caso. Use julgamento.

## Step 5: Report

Output canônico em markdown — ver `references/output-template.md` pra o esqueleto exato.

Estrutura:

```markdown
# Test Rigor Audit — <target>

> Run: <date>  ·  Framework(s): <list>  ·  Files scanned: N  ·  Tests scanned: N

## Summary

| Severidade | Count | Top categoria |
|---|---|---|
| CRITICAL | N | ... |
| HIGH     | N | ... |
| MEDIUM   | N | ... |
| LOW      | N | ... |

## Findings (grouped by file)

### `path/to/file.test.ts` — N findings

#### 🔴 [CRITICAL] `it.only` em código commitado — line 42
```ts
it.only("renders hero", ...)  // ← bloqueia outros testes em CI
```
**Fix:** remover `.only`. Se intencional pra debug local, virou commit acidente.

#### 🟠 [HIGH] Tautological assertion — line 87
```ts
expect(user.id).toBe(user.id)  // ← sempre true
```
**Fix:** verificar contra valor esperado real (UUID v4 pattern? mock do repo retornando ID conhecido?).

(...)

## TaskNote bodies (HIGH+)

### TaskNote 1 — fortalecer assertions em `apps/web/src/.../UserCard.test.tsx`
<bloco markdown pronto pra `pnpm task:new` body>

(...)

## Next steps

1. Triar CRITICALs primeiro (≤ 1h normalmente).
2. Pra HIGH em arquivos de SUT que vão ser refatorados em breve, fortalecer ANTES do refactor.
3. ...
```

Salve o relatório em `docs/reports/test-rigor-audit-<YYYY-MM-DD>-<scope>.md` quando o usuário concordar — assim fica rastreável.

## Step 6: TaskNote bodies

Para CADA achado **HIGH ou CRITICAL** que represente trabalho > 30min, gerar body de TaskNote no formato:

```markdown
## Context

`<file>` tem `<N>` testes com anti-pattern `<categoria>` que não pegam regressão. Detectado pelo `test-rigor-audit` em `<date>`.

## Acceptance Criteria

- [ ] Para cada teste flagged, decidir: FORTALECER (escrever assertion real) | DELETAR (teste duplicado/inútil) | SKIP-EXPLICIT com tracker (bloqueado por upstream)
- [ ] Se FORTALECER: assertion ataca output real do SUT, não mock return value, não literal idêntico
- [ ] Se DELETAR: confirmar que comportamento já tem cobertura em outro teste (grep pelo símbolo)
- [ ] Se SKIP-EXPLICIT: comentário `// SKIP — <reason> — <tracker>` por convenção ADR-0150 (ou equivalente do projeto)
- [ ] `<framework run command>` exits 0
- [ ] Audit rerun no mesmo arquivo retorna 0 findings da categoria

## Source

Detectado por `test-rigor-audit` em `<date>`. Refs: `<audit-report-path>`.
```

NÃO crie o TaskNote automaticamente — só forneça o body. Usuário decide se vira task ou rodado inline.

Casos onde NÃO gerar TaskNote (não desperdiçar):

- 1-2 findings num arquivo → pequeno demais pra task, melhor inline.
- Findings LOW only → vão pra "next steps" no relatório, não pra task formal.
- Findings em arquivo já em `archive/` ou marcado deletion → ignorar.

## Heurísticas de investigação

### Counter-examples (testes que PARECEM fracos mas são legítimos)

Não flag falsamente — alguns padrões legitimos:

| Pattern | Por que é OK | Como NÃO confundir |
|---|---|---|
| `expect(fn).not.toThrow()` | Asserta que SUT NÃO levanta exception | Tem expect(), não confundir com swallow |
| Test renderiza componente sem expect explícito MAS usa `@testing-library/jest-dom`'s implicit checks | Render-only smoke test | Verificar se `render()` é a única call e se há matchers do jest-dom (`getByRole` com `name:` é asseridor implícito) |
| Snapshot test acompanhado de assertion behavioral no mesmo `it` | Snapshot é regressão visual + behavior em paralelo | OK só se ambos presentes |
| Test só verifica `toHaveBeenCalled()` quando o argumento É o comportamento testado (ex: "fetcher chama URL X") | Legítimo se URL/método é o output | Verificar se há toHaveBeenCalledWith mais restrito disponível |
| Skip com tracker recente (< 30d) sem ainda ter PR | Aguardando upstream | OK; flag só skips com tracker > 60d sem update |
| `expect(true).toBe(true)` em catch de TEST que afirma "não deveria chegar aqui" | Pattern unreachable-by-design | Tem que ter `expect.fail()` ou similar; bare `expect(true).toBe(true)` no fim do try é suspeito |

Quando em dúvida, marque como **MEDIUM com nota "verificar intent"** em vez de assumir HIGH.

### Falsos positivos comuns do grep

- `expect(x).toBe(x)` onde `x` é desestruturação de objeto e o LHS/RHS são propriedades diferentes do mesmo nome — RARO mas possível, leia.
- `assert True` em pytest fixture (não num teste) — fixture pode ter assertion como precondition.
- `[[ A ]]` em bats fora do test body (em setup/teardown) — setup chains são OK serem stand-alone.

Sempre confirme com Read antes de incluir no relatório.

## Limitações

- **Mutation testing > grep**: a verdade definitiva sobre "o teste pega regressão?" é mutation testing (Stryker, mutmut). Grep + leitura é heurística rápida; recomende mutation no relatório quando suite for crítica e o usuário quiser certeza.
- **Cobertura ≠ rigor**: 100% line coverage com 100% testes fracos = 0% rigor. Esta skill complementa `coverage-check`, não substitui.
- **Performance**: monorepo com 5k+ testes pode levar ~10min. Se o user pede "tudo", confirme antes e prefira escopar por pacote/portal.

## Reference files

| Arquivo | Quando ler |
|---|---|
| `references/vitest-jest.md` | Alvo é `*.test.ts(x)` ou `*.spec.ts(x)` em pkg TS |
| `references/pytest.md` | Alvo é `test_*.py` ou `*_test.py` |
| `references/playwright.md` | Alvo é `e2e/` ou `playwright.config.ts` próximo |
| `references/bats.md` | Alvo é `*.bats` |
| `references/output-template.md` | Sempre, pra estrutura final do relatório |

## Integration with other skills

- **`testing-strategy`** desenha suite. **`test-rigor-audit`** valida que a suite está fazendo o trabalho prometido. Use juntas: strategy primeiro, audit depois de N semanas.
- **`coverage-check`** mede % de linhas. Audit mede QUALIDADE da % medida. Não conflitam.
- **`code-quality`** detecta dead code geral. Audit é especializado em testes. Pode haver overlap em "test file que ninguém importa" — code-quality pega via análise de dependências, audit confirma.
- **`finishing-a-development-branch`** roda checks pré-merge. Audit pode rodar como gate opcional pré-refactor.

## Auto-update

Este reference deve ser revisado quando:

- Novo framework de teste entra no repo (ex: vitest-browser, deno test).
- Algum padrão novo de "teste fraco" causa regressão real (postmortem alimenta a skill).
- Convenção SKIP-EXPLICIT do projeto mudar (atualizar Step 6 template).

Atualize o `<!-- last-reviewed: -->` marker quando revisar.
