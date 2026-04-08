---
name: maestro-analyze
description: Use when investigating Maestro mobile test failures or diagnosing why a mobile flow failed.
---

# maestro-analyze - Maestro Failure Analysis

Analyze Maestro flow failures with step reconstruction, code correlation, selector validation, and pattern matching.

## Usage

```bash
/maestro-analyze                # Analyze last run (from maestro-run-result.yaml)
/maestro-analyze <flow>         # Analyze specific flow
```

## Analysis Steps

### Step 1: Load Last Run

```bash
cat apps/mobile/maestro-run-result.yaml
```

If no result file exists, prompt user to run `/maestro-run` first.

### Step 2: For Each Failure, Reconstruct Flow Steps

Read the failing YAML flow and the Maestro output to reconstruct what happened:

```yaml
failure_timeline:
  flow: "auth/login.yaml"
  steps:
    - step: "launchApp (clearState: true)"
      status: "ok"
    - step: "waitForAnimationToEnd"
      status: "ok"
    - step: "tapOn: 'Email'"
      status: "ok"
    - step: "inputText: ${TEST_EMAIL}"
      status: "ok"
    - step: "tapOn: 'Sign In'"
      status: "timeout"
      error: "Element 'Sign In' not found after 5000ms"

  app_state:
    screen: "login"
    visible_elements: ["Email field", "Password field", "Log In button"]
```

### Step 3: Code Correlation

For each failure, correlate with app source code:

```yaml
code_correlation:
  failing_selector: "Sign In"
  selector_type: "text"

  search_results:
    - query: "grep -r 'Sign In' apps/mobile/app/"
      found: false
    - query: "grep -r 'Log In' apps/mobile/app/"
      found: true
      file: "apps/mobile/app/(auth)/login.tsx"
      line: 42

  suggestion:
    action: "flow-update"
    description: "Button text is 'Log In', not 'Sign In'. Update flow selector."
    confidence: 0.95
```

Correlation checks (in order):
1. **Text selectors** — grep for the exact text in app source (`*.tsx` files)
2. **testID selectors** — grep for the `testID` prop in components
3. **Sub-flow references** — verify shared flow paths are correct
4. **Environment variables** — check if `${TEST_EMAIL}` etc. are set
5. **mockNetwork paths** — verify API path regex matches actual tRPC endpoints
6. **Tab names** — verify tab labels match i18n keys in `apps/mobile/i18n/en.json`

### Step 4: Pattern Matching

Check against known Maestro failure patterns:

| Pattern | Symptoms | Root Cause |
|---------|----------|------------|
| `text-mismatch` | Element not found by text | Button/label text changed in app |
| `missing-testid` | Element not found by id | Component missing `testID` prop |
| `animation-timing` | Step fails intermittently | `waitForAnimationToEnd` not enough |
| `auth-failure` | Flow fails after login sub-flow | Credentials wrong or API down |
| `network-mock-miss` | mockNetwork doesn't intercept | Path regex doesn't match actual URL |
| `stale-navigation` | Wrong screen after tap | Navigation structure changed |
| `locale-mismatch` | Text assertion fails | Simulator in wrong locale (pt-BR vs en) |
| `clearState-issue` | State from previous test leaks | Missing `clearState: true` in launchApp |

### Step 5: Check i18n

If a text-based selector fails, check both locales:

```bash
# Check English
grep -r "Sign In" apps/mobile/i18n/en.json

# Check Portuguese
grep -r "Sign In" apps/mobile/i18n/pt-BR.json

# Check if using t() function in component
grep -r "t('.*sign.*in\|t('.*login" apps/mobile/app/(auth)/login.tsx
```

If the app uses `t('login.signIn')`, the visible text depends on simulator locale. The flow should either:
- Force English locale, or
- Use `testID` instead of text selector

### Step 6: Generate Diagnosis

Create `apps/mobile/maestro-diagnosis.yaml`:

```yaml
analyzed_at: <ISO8601>
source: "maestro-run-result.yaml"
total_failures: <count>

diagnoses:
  - flow: "auth/login.yaml"
    step: "tapOn: 'Sign In'"
    category: "text-mismatch"
    confidence: 0.95
    batchable: true

    timeline_summary: "Login flow failed at Sign In button tap — text doesn't match"

    code_correlation:
      expected_text: "Sign In"
      actual_text: "Log In"
      file: "apps/mobile/app/(auth)/login.tsx"
      line: 42

    suggested_fix:
      type: "flow-update"
      file: "apps/mobile/.maestro/flows/auth/login.yaml"
      description: "Replace 'Sign In' with 'Log In' in tapOn step"

    i18n_note: "Consider using testID instead of text for locale independence"

batches:
  - category: "text-mismatch"
    count: <n>
    flows: [...]

  - category: "missing-testid"
    count: <n>
    flows: [...]
```

## Output

Present analysis in readable format:

```
═══════════════════════════════════════════════════════════
  MAESTRO ANALYSIS COMPLETE

  4 failures analyzed, 2 patterns identified

  PATTERN 1: text-mismatch (2 flows)
    → Fix: Update button text selectors to match app
    → Flows: auth/login.yaml, shared/logout.yaml
    → Recommendation: Migrate to testID selectors

  PATTERN 2: animation-timing (2 flows)
    → Fix: Add explicit element wait after navigation
    → Flows: student/course-detail.yaml, engagement/badges.yaml

  Next: /maestro-fix-cycle to auto-fix
═══════════════════════════════════════════════════════════
```

## Maestro Studio for Investigation

When analysis needs visual confirmation:

```bash
cd apps/mobile && maestro studio
```

Maestro Studio lets you:
- See the simulator screen in real-time
- Click elements to discover their selectors
- Test individual steps interactively
- View the accessibility hierarchy

This is the Maestro equivalent of Playwright's `--debug` mode.

## Project Context

- **Flows:** `apps/mobile/.maestro/flows/`
- **App source:** `apps/mobile/app/`
- **i18n:** `apps/mobile/i18n/{en,pt-BR}.json`
- **Components:** `apps/mobile/components/`
- **Results:** `apps/mobile/maestro-run-result.yaml`
- **Diagnosis:** `apps/mobile/maestro-diagnosis.yaml`
