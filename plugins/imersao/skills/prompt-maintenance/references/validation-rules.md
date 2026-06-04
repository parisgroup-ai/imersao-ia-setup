# Validation Rules

Rules applied by `audit` and `check` commands.

## Errors (Block Execution)

| ID | Rule | Description |
|----|------|-------------|
| E001 | header-exists | Template must have comment header block |
| E002 | context-field | Header must have `Context:` field |
| E003 | output-field | Header must have `Output:` field |
| E004 | utf8-encoding | File must be valid UTF-8 |
| E005 | include-exists | All `{% include 'X' %}` must reference existing files |
| E006 | no-cycles | No circular include dependencies |
| E007 | framework-exists | If domain uses `render_cached()`, `_framework.jinja2` must exist |

## Warnings (Report Only)

| ID | Rule | Description |
|----|------|-------------|
| W001 | section-order | Sections should follow: ROLE → CONTEXT → TASK → RULES → OUTPUT |
| W002 | output-rules-include | JSON-returning prompts should include `_shared/output_rules` |
| W003 | terminology-consistency | Templates should use consistent language (pt-BR or en) |
| W004 | orphan-template | Template not referenced by Jinja includes OR Python code |
| W005 | description-length | Description should be 10-200 characters |

## Error Detection

### E001: header-exists

```python
# Pattern: First non-whitespace must be {# with header content
pattern = r'^\s*\{#\s*=*\s*\n?\s*[\w/]+\.jinja2'
```

### E005: include-exists

```python
# Find all includes
includes = re.findall(r"\{%\s*include\s+['\"]([^'\"]+)['\"]\s*%\}", content)
# Verify each exists relative to templates root
```

### E006: no-cycles

Build directed graph from includes, detect cycles using DFS.

### W004: orphan-template

A template is considered orphan if it's not referenced anywhere. Detection checks:

1. **Jinja includes**: `{% include 'template.jinja2' %}`
2. **Python references**:
   - `PromptLoader.render("domain/template")`
   - `PromptLoader.render_cached("domain/template", ...)`
   - `get_template("template.jinja2")`
   - `PackageLoader("app", "templates/domain")`

**Exclusions** (never reported as orphan):
- Templates in `_shared/` directory (designed for inclusion)
- Templates named `_framework.jinja2` (designed for prompt caching)
- Templates named `_context.jinja2` (internal context builders)

```python
# Scan Python files for template references
python_patterns = [
    r'PromptLoader\.render\(["\']([^"\']+)["\']',
    r'PromptLoader\.render_cached\(["\']([^"\']+)["\']',
    r'get_template\(["\']([^"\']+)["\']',
]
```

## Severity Levels

- **ERROR**: Blocks `check` command (exit code 1)
- **WARNING**: Reported but doesn't block (exit code 0)
- **INFO**: Suggestions for improvement (only in `audit`)
