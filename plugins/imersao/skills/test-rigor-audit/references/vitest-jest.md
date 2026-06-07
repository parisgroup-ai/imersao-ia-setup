# Vitest / Jest Test Rigor Audit

Anti-patterns, grep recipes, e counter-examples específicos pra TypeScript com vitest ou jest.

## Anti-pattern catalog

### 1. Tautological assertions — HIGH

```ts
// 🔴 Bad
expect(user.id).toBe(user.id);
expect(result).toEqual(result);
expect(mockFn.mock.calls[0][0]).toBe(mockFn.mock.calls[0][0]);
```

**Detect:** `rg -n 'expect\(([^)]+)\)\.(toBe|toEqual)\(\1\)' --type ts`

**Fix:** comparar contra valor esperado real. Se não há valor esperado conhecível, o teste não tem nada pra verificar.

### 2. Constant literal assertions — HIGH

```ts
// 🔴 Bad
expect(true).toBe(true);
expect(1).toBe(1);
expect("foo").toBe("foo");
```

**Detect:** `rg -n 'expect\((true|false|\d+|"[^"]*"|'"'"'[^'"'"']*'"'"')\)\.(toBe|toEqual)\(\1\)'`

**Counter-example:** `expect(arr.length).toBe(3)` é OK se 3 é o valor esperado e `arr.length` é dynamic.

### 3. No assertion in test body — HIGH

```ts
// 🔴 Bad
it("renders without crashing", () => {
  render(<MyComponent />);
});  // ← zero expect, zero implicit assertion
```

**Detect:** AST scan ou heurística textual:
```bash
# arquivos suspeitos: testes sem expect/assert/should/toHave
rg -L 'expect\(|assert\.|should\.|\.to(Have|Be|Match|Throw)' --type ts -g '*.test.ts*' -g '*.spec.ts*'
```

**Counter-example:** render-only smoke pode ser válido se o `render()` lança em modo strict E o teste documenta a intenção.

### 4. Mock-everything (SUT também mockado) — CRITICAL

```ts
// 🔴 Bad — mocking the thing you're testing
import { processPayment } from "@/lib/payments";

vi.mock("@/lib/payments", () => ({
  processPayment: vi.fn().mockResolvedValue({ success: true }),
}));

it("processes payment", async () => {
  const result = await processPayment({ amount: 100 });
  expect(result.success).toBe(true);  // ← testando o mock, não o SUT
});
```

**Detect:** o path do `vi.mock(...)` aparece em `import` statement do mesmo arquivo de teste. Comparar paths.

```bash
# arquivos onde import e vi.mock referenciam o mesmo path — suspeito
rg -n 'vi\.mock\("([^"]+)"' --type ts -g '*.test.ts*' | while read line; do
  file=$(echo "$line" | cut -d: -f1)
  path=$(echo "$line" | sed -E 's/.*vi\.mock\("([^"]+)".*/\1/')
  if rg -q "from \"$path\"" "$file"; then
    echo "SUSPICIOUS: $file mocks $path AND imports from it"
  fi
done
```

**Counter-example:** OK mockar o módulo SE o teste usa **outra função** importada do mesmo módulo. Verifique se é o mesmo símbolo.

### 5. Swallowed exception + always-pass — CRITICAL

```ts
// 🔴 Bad
it("handles errors gracefully", () => {
  try {
    riskyOperation();
  } catch {
    // engole
  }
  expect(true).toBe(true);  // ← teste passa mesmo se riskyOperation NÃO lança
});
```

**Detect:**
```bash
rg -n -A2 'catch\s*\(?\s*\)?\s*\{?\s*\}' --type ts -g '*.test.ts*' | rg 'expect\((true|1)\)\.toBe' -B2
```

**Fix correto:** `expect.fail("should have thrown")` ANTES do catch ou `expect(() => sut()).toThrow()`.

### 6. Setup-only assertions — MEDIUM

```ts
// 🔴 Bad
let user;
beforeEach(() => {
  user = createUser({ name: "John" });
  expect(user.name).toBe("John");  // ← assertion no setup, não no body
});

it("does something", () => {
  user.deactivate();
  // sem expect — teste do body é vácuo
});
```

**Detect:** procurar `expect(` dentro de `beforeEach`/`beforeAll` em arquivo onde algum `it` body não tem `expect`.

### 7. `it.only` / `describe.only` em commit — CRITICAL

```ts
// 🔴 Bad — bloqueia outros testes em CI
it.only("debug case", () => { /* ... */ });
describe.only("focus suite", () => { /* ... */ });
```

**Detect:** `rg -n '\b(it|test|describe|fit|fdescribe)\.only\(' --type ts`

**Fix:** remover `.only`. Considere CI rule via `eslint-plugin-vitest` rule `no-focused-tests`.

### 8. `it.todo` sem tracker — MEDIUM

```ts
// 🔴 Bad
it.todo("handles concurrent requests");

// ✅ Good
it.todo("handles concurrent requests — see TASK-1234");
```

**Detect:** `rg -n '\.(todo|skip)\(' --type ts | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'`

### 9. `expect(mock).toHaveBeenCalled()` only — MEDIUM

```ts
// 🟡 Suspicious
it("calls fetcher", () => {
  doStuff();
  expect(fetcher).toHaveBeenCalled();  // ← chamou com QUE args?
});
```

**Fix:** prefer `toHaveBeenCalledWith(expectedArgs)` ou `toHaveBeenCalledTimes(N)` se o número importa.

**Counter-example:** `toHaveBeenCalled()` sem args é OK se o ÚNICO comportamento testado é "fetcher foi chamado" (ex: lazy init). Documente intent in comment.

### 10. Snapshot sem behavior assertion — MEDIUM

```ts
// 🟡 Suspicious
it("renders correctly", () => {
  const { container } = render(<MyForm />);
  expect(container).toMatchSnapshot();  // ← snapshot é a única verificação
});
```

Snapshot regenerated cegamente vira regression sink. **Counter-example:** OK se acompanhado de assertion behavioral (`getByRole("button", { name: "Save" })`) no mesmo `it`.

### 11. `expect.any()` / `expect.anything()` excessivo — LOW/MEDIUM

```ts
// 🟡 Suspicious
expect(handler).toHaveBeenCalledWith(expect.anything(), expect.anything(), expect.anything());
```

Se TODOS args viram `expect.anything()`, o teste só verifica "foi chamado com 3 args" — pouco diferente de `toHaveBeenCalled()`.

**Severidade:** MEDIUM se 100% dos args; LOW se 1-2 dos args (legitimo: timestamp dinâmico, callback function).

### 12. Render sem query/assertion — HIGH

```tsx
// 🔴 Bad — react-testing-library
it("renders", () => {
  render(<Modal open />);
  // sem screen.getBy*, sem expect, sem axe — render-only
});
```

**Detect:** test que importa `render` de `@testing-library/react` mas não chama `screen.*` nem `expect`:
```bash
rg -l 'from "@testing-library/react"' --type ts -g '*.test.ts*' | xargs -I{} sh -c '
  if ! rg -q "screen\.|expect\(" "{}"; then echo "RENDER-ONLY: {}"; fi
'
```

## File-level red flags

Padrões que valem mais que um `it` individual:

- **Arquivo com 0 `expect()` em todo o body.** Imediato HIGH.
- **Razão `vi.mock` chamadas / `expect` chamadas > 3:1.** Prováveis testes de mock interactions.
- **Todos `it` blocks com mesmo nome ou nomes não-descritivos** (`"test 1"`, `"works"`). LOW + sugestão de rename.
- **Test file > 500 linhas.** Não é anti-pattern direto, mas correlaciona com setup duplicado e assertion fragmentada — sinalize MEDIUM "candidato a quebrar".

## Calibração específica de projeto

- **Mock de biblioteca de UI:** mocks de componentes de uma design library (ex.: `vi.mock("@/components/ui")` ou de um pacote de composites) são esperados em testes de páginas. NÃO são o SUT — a UI library é dependência, não o sistema sob teste. OK.
- **`next-intl` global mock** (`vitest.setup.ts`): legítimo, é fixture compartilhado. NÃO sinalize.
- **trpc mock pattern** (`vi.mock("@/trpc/react")`): legítimo pra testes de UI pura. SUT é o componente, não o tRPC.
- **i18n contract tests** (`*Copy.test.tsx` em `__tests__/`): legítimos como pinning de strings shipped. Asserções como `expect(text).toBe("Métodos de Recebimento")` NÃO são tautológicas — o LHS é dinâmico (resolve via `useTranslations`).

## Grep recipes (copiar-colar)

```bash
# Tautological / constant
rg -n 'expect\(([^)]+)\)\.(toBe|toEqual)\(\1\)' --type ts -g '*.test.*' -g '*.spec.*'

# .only em commit
rg -n '\b(it|test|describe|fit|fdescribe)\.only\(' --type ts -g '*.test.*' -g '*.spec.*'

# .skip / .todo sem tracker próximo (10 chars depois)
rg -n '\.(skip|todo)\(' --type ts -g '*.test.*' -g '*.spec.*' | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'

# Render sem screen.* nem expect
rg -l 'render\(<' --type tsx -g '*.test.*' | while read f; do
  rg -q '(screen\.|expect\()' "$f" || echo "RENDER-ONLY: $f"
done

# vi.mock + import do mesmo path (suspect SUT mock)
rg -n 'vi\.mock\("([^"]+)"' --type ts -g '*.test.*' | while IFS=: read -r f line content; do
  path=$(echo "$content" | sed -E 's/.*vi\.mock\("([^"]+)".*/\1/')
  if rg -q "from \"$path\"" "$f"; then
    echo "SUT-MOCK?: $f:$line — $path"
  fi
done

# Swallow + always-pass
rg -n -A3 'catch\s*\(?[^)]*\)?\s*\{[^}]{0,20}\}' --type ts -g '*.test.*' | rg -B1 -A1 'expect\((true|1)\)\.'
```
