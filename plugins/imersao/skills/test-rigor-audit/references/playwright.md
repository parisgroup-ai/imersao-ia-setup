# Playwright E2E Test Rigor Audit

Anti-patterns, grep recipes, e counter-examples específicos pra Playwright.

E2E tem perfil diferente de unit: o "trabalho real" é interagir com o produto e verificar que o usuário viu o que devia ver. Falsos verdes em E2E geralmente vêm de race conditions silenciosas, locators frágeis, ou screenshots tomados sem assertion.

## Anti-pattern catalog

### 1. `test.skip()` sem tracker — HIGH

```ts
// 🔴 Bad
test.skip("login flow", async ({ page }) => { ... });

// ✅ Good
test.skip("login flow — blocked by FEAT-1234", async ({ page }) => { ... });
```

**Detect:** `rg -n 'test\.skip\(|test\.fixme\(' --type ts -g '*.spec.ts' | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'`

### 2. Action sem assertion — HIGH

```ts
// 🔴 Bad
test("user can submit form", async ({ page }) => {
  await page.goto("/form");
  await page.click("button[type=submit]");
  // ← sem expect, sem waitForURL, sem getByText("Success")
});
```

Click sem verificar o que aconteceu = teste passa mesmo se backend explodiu.

**Detect:**
```bash
# Specs onde page.click é o último statement do test
rg -n 'await page\.click' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts' | head -200
# Inspecionar o test body completo dos hits
```

### 3. `waitForTimeout` em vez de `waitFor` — MEDIUM/HIGH

```ts
// 🔴 Bad — flaky em CI lenta, lento em CI rápida
await page.waitForTimeout(2000);
await page.click("button");

// ✅ Good
await page.waitForSelector("button:not([disabled])");
await page.click("button");

// ✅ Better
await expect(page.getByRole("button", { name: "Save" })).toBeEnabled();
await page.getByRole("button", { name: "Save" }).click();
```

**Detect:** `rg -n 'page\.waitForTimeout\(' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'`

**Severidade:** MEDIUM se o sleep é < 500ms (flaky symptom); HIGH se > 2000ms (CI tax acumulado por 100 testes = minutos).

### 4. Locator frágil (DOM-positional) — MEDIUM

```ts
// 🔴 Bad — quebra com qualquer reorganização do DOM
await page.locator(":nth-child(3)").click();
await page.locator("div > div > button").click();

// ✅ Good
await page.getByRole("button", { name: "Confirm" }).click();
await page.getByTestId("confirm-button").click();
```

**Detect:**
```bash
rg -n 'locator\("[^"]*:nth-child' --type ts -g '*.spec.ts'
rg -n 'locator\("[^"]*>\s*[a-z]+\s*>' --type ts -g '*.spec.ts'
```

### 5. Screenshot como única "verificação" — HIGH

```ts
// 🔴 Bad
test("page renders", async ({ page }) => {
  await page.goto("/dashboard");
  await page.screenshot({ path: "dashboard.png" });
  // ← screenshot salva mas não é asserido contra baseline
});
```

**Fix:** `await expect(page).toHaveScreenshot("dashboard.png")` (visual regression test) OU adicione assertion behavioral.

**Detect:**
```bash
# screenshot calls que NÃO são toHaveScreenshot
rg -n 'page\.screenshot\(' --type ts -g '*.spec.ts'
```

### 6. Navegação sem `waitForURL` ou assertion — HIGH

```ts
// 🔴 Bad
await page.click("a[href='/profile']");
await page.click("button.edit");  // ← assume que /profile carregou. flaky.

// ✅ Good
await page.click("a[href='/profile']");
await page.waitForURL("**/profile");
await expect(page.getByRole("heading", { name: "Profile" })).toBeVisible();
await page.getByRole("button", { name: "Edit" }).click();
```

### 7. `expect(true).toBe(true)` — CRITICAL

Mesmo padrão de unit test. Em E2E é até pior — ciclo é caro, fingir verde é desperdício de minutos por run.

**Detect:** `rg -n 'expect\((true|1)\)\.toBe\((true|1)\)' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'`

### 8. `test.only` em commit — CRITICAL

CI só roda esse teste, todos os outros silenciosamente skipados. Pior em E2E porque suite passa "verde" com 1% dos casos.

**Detect:** `rg -n 'test\.only\(' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'`

### 9. Auth/seed setup sem verification — MEDIUM

```ts
// 🔴 Suspicious
test.beforeEach(async ({ page }) => {
  await page.goto("/login");
  await page.fill("[name=email]", "test@x.com");
  await page.click("button[type=submit]");
  // ← sem waitForURL, sem assertion. Login pode ter falhado e teste segue como se autenticado.
});
```

Tests que assumem auth implicitamente passam em "logged out" se a auth quebrar — todo body de teste vira no-op.

### 10. `try/catch` em test body — HIGH

```ts
// 🔴 Bad
test("checkout", async ({ page }) => {
  try {
    await page.goto("/checkout");
    await page.click("button.pay");
  } catch {
    // engole
  }
});
```

Em E2E você quase nunca quer try/catch. O Playwright já faz retry/timeout dos comandos. Try/catch convertendo erro em silêncio é red flag.

## Project-specific calibration (cursos repo)

- **`apps/web/e2e/`**: convenção interna pode ter helpers que asseridem implicitamente (ex: `loginAs(...)` que internamente faz `expect(page).toHaveURL`). NÃO sinalize se o helper já asserta.
- **Storybook play-functions**: similar a Playwright mas com `@storybook/test`. Aplique mesmas heurísticas.
- **`e2e-philosophy.md`** topic file (cursos): tem regra dura "testes E2E falhando NÃO são problemas dos testes". Audit detecta os testes que NUNCA vão falhar — eles são o sintoma oposto, mesmo problema cultural.

## Grep recipes (copiar-colar)

```bash
# .skip / .fixme sem tracker
rg -n 'test\.(skip|fixme)\(' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts' | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'

# .only em commit
rg -n 'test\.only\(' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'

# waitForTimeout — flaky/lento
rg -n 'page\.waitForTimeout\(' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'

# Locator positional / encadeado
rg -n 'locator\("[^"]*:nth-child' --type ts -g '*.spec.ts'
rg -n 'locator\("[^"]*>\s*[a-z]+\s*>' --type ts -g '*.spec.ts'

# Screenshot sem expect
rg -n 'page\.screenshot\(' --type ts -g '*.spec.ts' | while IFS=: read -r f line _; do
  ctx=$(sed -n "$((line-2)),$((line+2))p" "$f")
  echo "$ctx" | rg -q 'toHaveScreenshot' || echo "SCREENSHOT-NO-ASSERT: $f:$line"
done

# Tautological / constant
rg -n 'expect\((true|1|"[^"]*")\)\.toBe\((true|1|"[^"]*")\)' --type ts -g '*.spec.ts' -g 'e2e/**/*.ts'

# Try/catch em test body
rg -n -A3 'test\(.+async.+\{$' --type ts -g '*.spec.ts' | rg 'try\s*\{'
```
