# Validation Rules

Rules applied by the `prompt-db-audit` skill.

## Operations Audit (Template ↔ LLM Analytics)

| ID | Rule | Severity | Description |
|----|------|----------|-------------|
| OP001 | operation-has-template | ERROR | Each `set_llm_operation_type('X')` must have a corresponding template |
| OP002 | system-template-mapped | WARNING | System templates (`**/system.jinja2`) should be mapped to an operationType |
| OP003 | operation-naming | WARNING | operationType must follow snake_case convention |
| OP004 | duplicate-operation | ERROR | Same operationType used with different templates |

### OP001: operation-has-template

Every `set_llm_operation_type()` call indicates an LLM operation that should have a corresponding prompt template.

**Detection:**
```python
# Find all operation types in Python code
pattern = r"set_llm_operation_type\(['\"]([^'\"]+)['\"]\)"

# Match to templates using convention:
# operation: 'spark_interview' → template: interview/system.jinja2 OR interview/*.jinja2
# operation: 'study_tutor' → template: study/tutor_system.jinja2 OR study/tutor*.jinja2
```

**Resolution:**
1. Create missing template in appropriate domain
2. Or add explicit mapping in `.prompt-db-audit.json` operationMappings

### OP002: system-template-mapped

System templates define the AI's behavior and should be tracked for cost analytics.

**Detection:**
```python
# System templates pattern
system_templates = glob("**/system.jinja2") + glob("**/*_system.jinja2")

# Check if referenced by any set_llm_operation_type()
```

**Resolution:**
1. Add `set_llm_operation_type()` call where template is used
2. Or add to ignoredOrphans if intentionally unmapped

### OP003: operation-naming

Operation types should follow snake_case for consistency with database columns.

**Valid:** `spark_interview`, `study_tutor`, `module_generation`
**Invalid:** `sparkInterview`, `StudyTutor`, `MODULE_GENERATION`

### OP004: duplicate-operation

Same operation type should not map to multiple different templates (ambiguous tracking).

---

## Schema Audit (Template ↔ Domain Schemas)

| ID | Rule | Severity | Description |
|----|------|----------|-------------|
| SC001 | course-variable-exists | ERROR | `course_*` variable must exist in courses schema |
| SC002 | module-variable-exists | ERROR | `module_*` variable must exist in modules schema |
| SC003 | lesson-variable-exists | ERROR | `lesson_*` variable must exist in lessons schema |
| SC004 | user-variable-exists | ERROR | `user_*` variable must exist in users schema |
| SC005 | undocumented-variable | WARNING | Variables without domain prefix should be documented |
| SC006 | type-mismatch | WARNING | Variable type doesn't match schema column type |

### SC001-SC004: Domain Variable Exists

Variables with domain prefixes must correspond to actual database columns.

**Prefix Mapping:**
| Prefix | Schema Table | Example |
|--------|--------------|---------|
| `course_` | courses | `course_title` → `courses.title` |
| `module_` | modules | `module_description` → `modules.description` |
| `lesson_` | lessons | `lesson_order` → `lessons.order` |
| `user_` | users | `user_name` → `users.name` |

**Detection:**
```python
def validate_variable(variable: str, schemas: dict) -> bool:
    prefix, field = parse_variable(variable)
    if prefix in DOMAIN_PREFIXES:
        schema = schemas.get(DOMAIN_PREFIXES[prefix])
        return field in schema.columns or variable in ALIASES
    return True  # Non-prefixed variables pass (SC005 handles them)
```

**Resolution:**
1. Fix variable name to match schema column
2. Or add alias in `.prompt-db-audit.json` schemaAliases
3. Or the schema may need updating

### SC005: undocumented-variable

Variables without standard prefixes should be documented in schemaAliases.

**Common unprefixed variables:**
- `title`, `description` - Could be course, module, or lesson
- `target_audience` - Alias for `courses.targetRoles`
- `style` - From course metadata JSON
- `duration_hours` - Calculated field

### SC006: type-mismatch

Variable usage suggests different type than schema definition.

**Example:**
```jinja2
{% for item in course_tags %}  {# expects array #}
```
If `courses.tags` is `text` instead of `jsonb`, this is a mismatch.

---

## References Audit (Template ↔ Code)

| ID | Rule | Severity | Description |
|----|------|----------|-------------|
| RF001 | render-template-exists | ERROR | `PromptLoader.render('X')` must reference existing template |
| RF002 | orphan-template | WARNING | Template not referenced by Python or includes |
| RF003 | valid-header | ERROR | Template must have valid header per ADR-0081 |
| RF004 | include-exists | ERROR | `{% include 'X' %}` must reference existing template |
| RF005 | circular-include | ERROR | No circular include dependencies |

### RF001: render-template-exists

All PromptLoader references must point to actual template files.

**Detection:**
```python
patterns = [
    r"PromptLoader\.render\(['\"]([^'\"]+)['\"]",
    r"PromptLoader\.render_cached\(['\"]([^'\"]+)['\"]",
    r"\.get_template\(['\"]([^'\"]+)['\"]",
]
```

### RF002: orphan-template

Templates should be used somewhere in the codebase.

**Exceptions (not reported as orphan):**
- `_shared/*` - Designed for inclusion only
- `*/_framework.jinja2` - Prompt caching frameworks
- `*/_context.jinja2` - Internal context builders
- Templates in `ignoredOrphans` config

### RF003: valid-header

Templates must follow ADR-0081 header format:

```jinja2
{# =============================================================================
   domain/filename.jinja2
   Brief description.

   Context: { var1, var2 }
   Output: Description of output format

   ADR-0081: Claude API Prompt Caching Strategy
============================================================================= #}
```

Required fields:
- Path (first line)
- Context (variables or "None")
- Output (format description)

### RF004: include-exists

All Jinja2 includes must reference existing templates.

```jinja2
{% include '_shared/output_rules.jinja2' %}  {# Must exist #}
```

### RF005: circular-include

Include dependencies must form a DAG (no cycles).

**Detection:** Build directed graph, detect cycles using DFS.

---

## Severity Levels

| Level | Exit Code | Description |
|-------|-----------|-------------|
| ERROR | 1 | Blocks audit, must be fixed |
| WARNING | 0 | Should be reviewed, doesn't block |
| INFO | 0 | Suggestions for improvement |
