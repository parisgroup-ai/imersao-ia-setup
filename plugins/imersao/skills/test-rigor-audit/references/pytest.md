# Pytest Test Rigor Audit

Anti-patterns, grep recipes, e counter-examples específicos pra Python com pytest.

## Anti-pattern catalog

### 1. Tautological assertions — HIGH

```python
# 🔴 Bad
assert user.id == user.id
assert result == result
```

**Detect:** `rg -n 'assert (\w+(\.\w+)*) == \1\b' --type py`

### 2. Constant literal assertions — HIGH

```python
# 🔴 Bad
assert True
assert 1 == 1
assert "x" == "x"
```

**Detect:** `rg -n '^\s*assert (True|1 == 1|".+" == ".+")\s*$' --type py`

**Counter-example:** `assert response.status_code == 200` é OK — RHS é literal, mas LHS é dinâmico.

### 3. No assertion in test function — HIGH

```python
# 🔴 Bad
def test_renders_without_crashing(client):
    client.get("/page")
    # zero assert
```

**Detect:** test function sem `assert`/`pytest.raises`/`with pytest.warns`:
```bash
# arquivos com test_ functions mas sem assertion calls
rg -L '(\bassert\b|pytest\.raises|pytest\.warns)' --type py -g 'test_*.py' -g '*_test.py'
```

### 4. Mock-everything (SUT também mockado) — CRITICAL

```python
# 🔴 Bad
from myapp.services import process_payment

@patch("myapp.services.process_payment")
def test_processes_payment(mock_process):
    mock_process.return_value = {"success": True}
    result = process_payment({"amount": 100})  # ← está testando o mock
    assert result["success"] is True
```

**Detect:** `@patch` ou `monkeypatch.setattr` cujo target string aparece em `from X import Y` do mesmo arquivo, com `Y` sendo o símbolo testado.

### 5. Swallowed exception + always-pass — CRITICAL

```python
# 🔴 Bad
def test_handles_errors():
    try:
        risky_operation()
    except Exception:
        pass
    assert True  # ← passa mesmo se risky_operation NÃO lança
```

**Detect:**
```bash
rg -n -A3 'except[^:]*:\s*\n\s*pass\b' --type py -g 'test_*.py' -g '*_test.py' | rg -B2 'assert (True|1 == 1)'
```

**Fix:** `with pytest.raises(ExpectedError): risky_operation()`. Sem `pytest.raises`, o try é decorativo.

### 6. `@pytest.mark.skip` sem reason / tracker — HIGH

```python
# 🔴 Bad
@pytest.mark.skip
def test_concurrent_access(): ...

# 🔴 Bad — reason vazio ou genérico
@pytest.mark.skip(reason="flaky")
def test_concurrent_access(): ...

# ✅ Good
@pytest.mark.skip(reason="blocked by upstream race condition — TASK-1234")
def test_concurrent_access(): ...
```

**Detect:**
```bash
rg -n '@pytest\.mark\.skip\b' --type py -g 'test_*.py' -g '*_test.py' | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'
```

### 7. `@pytest.mark.xfail` sem `strict=True` — MEDIUM

```python
# 🔴 Bad — passa silenciosamente se o teste começar a passar
@pytest.mark.xfail(reason="upstream bug")
def test_thing(): ...

# ✅ Good
@pytest.mark.xfail(reason="upstream bug — issue #42", strict=True)
def test_thing(): ...
```

`strict=True` faz pytest gritar se o "expected failure" começar a passar — sinal de que o upstream foi consertado e o xfail deve ser removido.

### 8. Setup-only assertions — MEDIUM

```python
# 🔴 Bad
@pytest.fixture
def user():
    u = create_user(name="John")
    assert u.name == "John"  # assertion no fixture, não no teste
    return u

def test_user_does_something(user):
    user.deactivate()
    # zero assert no body
```

### 9. `pytest.raises` sem `match=` — LOW/MEDIUM

```python
# 🟡 Suspicious — qualquer subclasse de ValueError passa
def test_raises_on_invalid():
    with pytest.raises(ValueError):
        sut.parse("bogus")
```

**Fix:** `with pytest.raises(ValueError, match=r"invalid format"):` valida a mensagem também.

**Severidade:** MEDIUM se a exception é genérica (ValueError, RuntimeError); LOW se é uma exception customizada do domínio.

### 10. Mock chamado sem `assert_called_with` — MEDIUM

```python
# 🟡 Suspicious
def test_calls_publisher(mock_publisher):
    do_stuff()
    mock_publisher.publish.assert_called()  # com QUE args?
```

**Fix:** `mock_publisher.publish.assert_called_with(expected_event)`.

### 11. `parametrize` com 1 caso só — LOW

```python
# 🟡 Code smell, não bug
@pytest.mark.parametrize("input,expected", [(1, 2)])
def test_inc(input, expected): ...
```

Não justifica `parametrize`. Se for só um caso, escreva direto. Sinaliza MEDIUM se a lista parametrize tem 1 entrada e o teste claramente esperava mais.

## File-level red flags

- **Arquivo com 0 `assert` e 0 `pytest.raises`.** Imediato HIGH.
- **Todas funções `test_*` retornam `None` rapidamente sem trabalho substantivo.** Pode ser "wishful test" — esquema preparado mas teste não escrito.
- **Razão chamadas-de-mock / asserts > 3:1.** Provável teste de mock interactions.

## Project-specific calibration (ana-service, cursos repo)

- **`pytest-asyncio` async tests:** legítimos. `await` não substitui `assert` — verifique mesmo assim.
- **FastAPI TestClient** (`client.get(...)`) já validates 200 implicitamente? **NÃO** — `client.get` retorna response object; sem `assert response.status_code == X` o teste passa em 500.
- **LLM provider mocks** (Anthropic, OpenAI): legítimo mockar — não é SUT da maioria dos serviços. Mas se o SUT é `LLMProvider.send`, mockar `LLMProvider.send` é red flag.

## Grep recipes (copiar-colar)

```bash
# Tautological / constant
rg -n 'assert (\w+(\.\w+)*) == \1\b' --type py
rg -n '^\s*assert (True|1 == 1)\s*$' --type py

# Skip sem tracker
rg -n '@pytest\.mark\.skip\b' --type py | rg -v '(BUG|CHORE|FEAT|TASK)-\d+|GH #?\d+'

# xfail sem strict
rg -n '@pytest\.mark\.xfail\(' --type py | rg -v 'strict\s*=\s*True'

# Test sem assert/raises
rg -L '(\bassert\b|pytest\.raises|pytest\.warns)' --type py -g 'test_*.py' -g '*_test.py'

# Swallow + always-pass
rg -n -B1 -A3 'except[^:]*:\s*$' --type py -g 'test_*.py' | rg 'assert (True|1 == 1)'

# Patch + import do mesmo target — suspect SUT-mock
rg -n '@patch\("([^"]+)"' --type py -g 'test_*.py' | while IFS=: read -r f line content; do
  target=$(echo "$content" | sed -E 's/.*@patch\("([^"]+)".*/\1/')
  module=$(echo "$target" | sed 's/\.[^.]*$//')
  symbol=$(echo "$target" | sed 's/.*\.//')
  if rg -q "from $module import.*\b$symbol\b" "$f"; then
    echo "SUT-MOCK?: $f:$line — patches $target AND imports $symbol"
  fi
done
```
