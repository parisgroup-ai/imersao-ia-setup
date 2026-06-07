# Bats (Bash Automated Testing System) Test Rigor Audit

Anti-patterns, grep recipes, e counter-examples específicos pra bats — usado pra testar shell scripts, hooks, e ferramentas CLI.

Bats tem peculiaridades que outras frameworks não têm: o exit code e a captura de output via `run` são parte central, e o shell silencia muita coisa por default.

## Anti-pattern catalog

### 1. `[[ ]]` chained sem `&&` — CRITICAL ⚠️

**O grande gotcha.** Bats faz pass/fail do test pelo exit code do ÚLTIMO statement. Encadear assertions com `;` ou newline faz só a última contar:

```bash
# 🔴 Bad — só a última assertion vale
@test "validates output" {
  run my_cmd
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ "expected" ]]
  [[ "$output" =~ "another" ]]
}
# Se a primeira falha, bats reporta passing porque a última passou.
```

```bash
# ✅ Good — chain com &&, qualquer falha aborta
@test "validates output" {
  run my_cmd
  [[ "$status" -eq 0 ]] && \
  [[ "$output" =~ "expected" ]] && \
  [[ "$output" =~ "another" ]]
}
```

```bash
# ✅ Better — bats-assert helpers (se disponível)
@test "validates output" {
  run my_cmd
  assert_success
  assert_output --partial "expected"
  assert_output --partial "another"
}
```

**Detect:** procurar consecutivos `[[ ]]` no mesmo `@test` sem `&&` entre eles:
```bash
# Hits onde duas linhas seguidas começam com [[
rg -n -A1 '^\s*\[\[' --type-add 'bats:*.bats' --type bats | rg -B1 '^\s*\[\['
```

Esta é a anti-pattern #1 da skill — origem do gotcha está documentada na CLAUDE.md global do usuário. Confirmado em 2026-05-09: 24/24 bats "passing" escondiam 4 bugs distintos.

### 2. `run cmd` sem checar `$status` ou `$output` — HIGH

```bash
# 🔴 Bad
@test "command runs" {
  run my_command
  # zero verification do que aconteceu
}
```

`run` captura `$status` e `$output` — ignorar ambos = teste sempre passa.

**Detect:**
```bash
# Tests com `run` sem subsequent $status ou $output reference
rg -n 'run ' --type-add 'bats:*.bats' --type bats | head -100
# (manual review — pequeno escopo de bats geralmente)
```

### 3. `skip "..."` sem tracker — HIGH

```bash
# 🔴 Bad
@test "concurrent flag" {
  skip "needs investigation"
  ...
}

# ✅ Good
@test "concurrent flag" {
  skip "blocked by upstream race — see CHORE-1234"
  ...
}
```

**Detect:** `rg -n 'skip ' --type-add 'bats:*.bats' --type bats | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'`

### 4. `assert_*` mas NÃO usa `bats-assert` — confusion — LOW

```bash
# 🔴 Bad — function não definida, retorna 127, mas teste passa por causa do gotcha #1
@test "ok" {
  run my_cmd
  assert_success  # ← assume bats-assert. Sem load, isto é "command not found"
  [[ "$status" -eq 0 ]]
}
```

`bats-assert` precisa `load` no setup. Se não foi loaded, `assert_*` é "comando inexistente" → exit 127, MAS o `[[ ]]` final passou → teste verde.

**Detect:** arquivo com `assert_*` mas sem `load.*bats-assert`:
```bash
rg -l 'assert_(success|failure|output|equal|contains)' --type-add 'bats:*.bats' --type bats | while read f; do
  rg -q 'load.*bats-assert|load_helper.*bats-assert' "$f" || echo "MISSING-LOAD: $f"
done
```

### 5. `true` ou `:` como única verificação — CRITICAL

```bash
# 🔴 Bad
@test "noop" {
  do_stuff
  true  # ← teste passa não importa o que do_stuff fez
}
```

**Detect:**
```bash
rg -n -B2 '^\s*(true|:)\s*$' --type-add 'bats:*.bats' --type bats
```

### 6. `setup`/`teardown` que falha silenciosamente — MEDIUM

```bash
# 🔴 Bad
setup() {
  cp fixture.json /tmp/test.json  # ← se cp falhar, todo teste passa do mesmo jeito
}

@test "reads file" {
  run cat /tmp/test.json
  # se setup falhou, file não existe, run falha, teste falha por motivo errado
}
```

**Fix:** `set -euo pipefail` no top do setup, OR explicit checks com mensagem.

### 7. Hardcoded paths com `/tmp/<file>` (multi-instance unsafe) — MEDIUM

```bash
# 🔴 Risky
setup() { echo "data" > /tmp/test-input.txt; }
```

Em ambiente com múltiplos jobs paralelos, `/tmp/test-input.txt` colide. Documented gotcha (CLAUDE.md global). Use `BATS_TMPDIR` ou `mktemp`.

**Detect:** `rg -n '/tmp/[a-z]' --type-add 'bats:*.bats' --type bats`

## File-level red flags

- **Test file com 0 `[[`, 0 `assert_*`, 0 `[ ` (POSIX test).** Imediato HIGH.
- **Setup que faz cd / sets vars sem cleanup teardown.** Pode poluir runs subsequentes.
- **Mais de 5 testes consecutivos sem `run` — teste de função interna sem capture.** Pode ser intencional (testar function pure) mas merece olhar.

## Calibração específica de projeto

- **Hooks de ciclo de sessão / lifecycle**: quando bats roda hooks de CI, o padrão `run cmd` + assertions encadeadas com `&&` é comum. A auditoria aqui é especialmente valiosa porque um false-green em teste de hook vira false-green no CI inteiro.
- **Lição de origem:** uma suíte bats 24/24 verde já escondeu 4 bugs reais — daí a necessidade desta skill.

## Grep recipes (copiar-colar)

```bash
# Chained [[ sem &&
rg -n '\[\[' --type-add 'bats:*.bats' --type bats -A1 | awk '/\[\[/{
  if (prev && !match(prev, /&& *\\?$/)) print prev "\n" $0 "\n---"
  prev=$0
}'

# run sem checagem
rg -n -A5 '^\s*run ' --type-add 'bats:*.bats' --type bats | grep -B5 -E '^\s*\}' | head -100

# skip sem tracker
rg -n '^\s*skip ' --type-add 'bats:*.bats' --type bats | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'

# bats-assert sem load
rg -l 'assert_(success|failure|output|equal|contains)' --type-add 'bats:*.bats' --type bats | while read f; do
  rg -q 'load.*bats-assert' "$f" || echo "MISSING-BATS-ASSERT-LOAD: $f"
done

# /tmp hardcoded
rg -n '/tmp/[a-z]' --type-add 'bats:*.bats' --type bats

# noop verifications
rg -n -B2 '^\s*(true|:)\s*$' --type-add 'bats:*.bats' --type bats
```
