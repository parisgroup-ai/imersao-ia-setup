# Template Header Format

Every Jinja2 template MUST start with a header comment block.

## Required Format

```jinja2
{# =============================================================================
   domain/template_name.jinja2
   Brief description of what this prompt does.

   Context: { var1, var2, var3 }
   Output: JSON with field1, field2
============================================================================= #}
```

## Fields

| Field | Required | Description |
|-------|----------|-------------|
| Path | Yes | `domain/filename.jinja2` on first line |
| Description | Yes | 1-2 sentences explaining purpose |
| Context | Yes | Variables the template expects: `{ var1, var2 }` |
| Output | Yes | What the prompt returns: `JSON with X` or `Text describing Y` |

## Parsing Rules

1. Header must be first content in file (whitespace allowed before)
2. Uses Jinja2 comment syntax: `{# ... #}`
3. Separator line of `=` characters optional but recommended
4. Context field uses `{ var1, var2 }` format (parsed as list)
5. Output field is free text description

## Examples

### Minimal Valid Header

```jinja2
{# brainstorm/validate.jinja2
   Validates course idea against policies.
   Context: { title, description }
   Output: JSON with valid, reasons
#}
```

### Full Header with ADR Reference

```jinja2
{# =============================================================================
   lesson/exercise.jinja2
   Generates hands-on exercise content following pedagogical framework.

   Context: { course_title, module_title, lesson_title, target_audience, style }
   Output: JSON with content and exercises array

   ADR-0081: Claude API Prompt Caching Strategy
============================================================================= #}
```
