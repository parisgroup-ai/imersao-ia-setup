---
name: prompt-db-audit
description: Use when auditing prompt templates, operation types, or context variables against database schemas or Python code.
---

# Prompt Database Audit

Auditoria completa de consistência entre templates Jinja2, schemas do banco de dados e código Python.

## Comandos

- `/prompt-db-audit` - Auditoria completa (3 dimensões)
- `/prompt-db-audit operations` - Apenas Template ↔ LLM Analytics
- `/prompt-db-audit schema` - Apenas Template ↔ Domain Schemas
- `/prompt-db-audit references` - Apenas Template ↔ Code References

## Configuração

A skill procura `.prompt-db-audit.json` na raiz do projeto. Se não existir, usa convenções padrão.

**Estrutura do config:**
```json
{
  "templates": { "root": "apps/ana-service/app/templates", "pattern": "**/*.jinja2" },
  "schemas": { "root": "packages/database/src/schema", "pattern": "*.ts" },
  "python": { "root": "apps/ana-service", "pattern": "**/*.py" },
  "operationMappings": { "spark_interview": "interview/system.jinja2" },
  "schemaAliases": { "target_audience": "courses.targetRoles" },
  "ignoredOrphans": ["_shared/*", "*/_framework.jinja2", "*/_context.jinja2"]
}
```

## Processo de Auditoria

### 1. SCAN PHASE

Carregar e indexar todos os artefatos:

```
Templates:
  - Glob: {templates.root}/{templates.pattern}
  - Extrair: path, context variables, includes, header metadata

Schemas:
  - Glob: {schemas.root}/{schemas.pattern}
  - Extrair: table names, column names, types, relations

Python Code:
  - Glob: {python.root}/{python.pattern}
  - Extrair: PromptLoader.render() calls, set_llm_operation_type() calls
```

### 2. ANALYSIS PHASE

Executar validações em 3 dimensões:

**2.1 Operations Audit (Template ↔ LLM Analytics)**

```python
# Pseudo-code
for operation_type in python_operation_types:
    template = find_matching_template(operation_type)
    if not template:
        report_error("OP001", f"operation '{operation_type}' has no matching template")

for template in system_templates:  # **/system.jinja2
    if template not in mapped_operations:
        report_warning("OP002", f"template '{template}' not mapped to operationType")
```

Regras: Ver `references/validation-rules.md` seção Operations.

**2.2 Schema Audit (Template ↔ Domain Schemas)**

```python
# Pseudo-code
for template in templates:
    for variable in template.context_variables:
        prefix, field = parse_variable(variable)  # course_title → (course, title)
        schema = get_schema_for_prefix(prefix)    # course → courses

        if schema and field not in schema.columns:
            alias = check_alias(variable)
            if not alias:
                report_error("SC001", f"variable '{variable}' not found in {schema}")
```

Mapeamento de prefixos:
- `course_*` → `courses` schema
- `module_*` → `modules` schema
- `lesson_*` → `lessons` schema
- `user_*` → `users` schema

Regras: Ver `references/validation-rules.md` seção Schema.

**2.3 References Audit (Template ↔ Code)**

```python
# Pseudo-code
for render_call in python_render_calls:
    template_path = render_call.template_name
    if not template_exists(template_path):
        report_error("RF001", f"template '{template_path}' does not exist")

for template in all_templates:
    if template not in python_references and template not in jinja_includes:
        if not matches_ignored_patterns(template):
            report_warning("RF002", f"template '{template}' is orphan")
```

Regras: Ver `references/validation-rules.md` seção References.

### 3. REPORT PHASE

Gerar relatório estruturado:

```
prompt-db-audit

Scanning...
  ✓ {n} templates loaded
  ✓ {n} operation types found
  ✓ {n} schema files parsed
  ✓ {n} Python references found

═══════════════════════════════════════════════════════════════
 OPERATIONS AUDIT (Template ↔ LLM Analytics)
═══════════════════════════════════════════════════════════════

ERRORS ({n}):
  ✗ {rule_id}: {message}
    → Found in: {file}:{line}
    → Suggestion: {suggestion}

WARNINGS ({n}):
  ⚠ {rule_id}: {message}

═══════════════════════════════════════════════════════════════
 SCHEMA AUDIT (Template ↔ Domain Schemas)
═══════════════════════════════════════════════════════════════

ERRORS ({n}):
  ✗ {rule_id}: {message}
    → {schema} has: {available_fields}
    → Suggestion: {suggestion}

═══════════════════════════════════════════════════════════════
 REFERENCES AUDIT (Template ↔ Code)
═══════════════════════════════════════════════════════════════

ERRORS ({n}): ...
WARNINGS ({n}): ...

═══════════════════════════════════════════════════════════════
 SUMMARY
═══════════════════════════════════════════════════════════════

| Dimension   | Errors | Warnings | Pass Rate |
|-------------|--------|----------|-----------|
| Operations  |      X |        Y |       Z%  |
| Schema      |      X |        Y |       Z%  |
| References  |      X |        Y |       Z%  |
| TOTAL       |      X |        Y |       Z%  |

Report saved: docs/audits/prompt-db-audit-YYYY-MM-DD.md
```

## Parsing Logic

### Template Context Extraction

```python
def extract_context_variables(content: str) -> list[str]:
    """Extract variables from template header Context: { var1, var2 }"""
    match = re.search(r'Context:\s*\{\s*([^}]+)\s*\}', content)
    if match:
        return [v.strip() for v in match.group(1).split(',')]
    return []
```

### Operation Type Extraction

```python
def extract_operation_types(python_files: list[str]) -> dict[str, str]:
    """Extract set_llm_operation_type() calls with file locations"""
    pattern = r"set_llm_operation_type\(['\"]([^'\"]+)['\"]\)"
    results = {}
    for file in python_files:
        for match in re.finditer(pattern, read_file(file)):
            results[match.group(1)] = file
    return results
```

### Schema Field Extraction

```typescript
// Pattern to extract from Drizzle schema
// title: varchar("title", { length: 255 }).notNull()
// → field: "title", db_name: "title"

// targetRoles: jsonb("target_roles").$type<string[]>()
// → field: "targetRoles", db_name: "target_roles"
```

## References

- `references/validation-rules.md` - Todas as regras de validação
- `references/operation-mappings.md` - Mapeamento operationType → template
- `references/schema-aliases.md` - Aliases de variáveis de contexto
- `examples/audit-report.md` - Exemplo de relatório completo
