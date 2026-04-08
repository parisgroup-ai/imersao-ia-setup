---
name: prompt-maintenance
description: Maintain prompt templates with dependency tracking, documentation, and validation. Use when auditing prompts, generating catalog, or checking template structure.
version: 1.0.0
author: gustavo
tags: [prompts, maintenance, templates]
---

# Prompt Maintenance

Manages prompt template health across the project.

## Commands

### `/prompt-maintenance audit`

Full analysis of all configured sources.

**Process:**
1. Load `.prompt-maintenance.json` from project root
2. For each source:
   - Scan files matching pattern
   - Parse headers and extract metadata
   - Build dependency graph from `{% include %}` statements
   - **Scan Python files for direct template references** (PromptLoader, get_template)
   - Validate against rules in `references/validation-rules.md`
3. Report errors and warnings
4. Show statistics

**Output Format:**
```
prompt-maintenance audit

Scanning apps/ana-service/app/templates/...

✓ 68 templates analyzed
✓ 156 dependencies mapped

ERRORS (N):
  ✗ path/file.jinja2:line - Error description

WARNINGS (N):
  ⚠ path/file.jinja2 - Warning description

Stats:
  By domain: lesson (12), brainstorm (8), _shared (4), ...
  Orphans: 2 templates not referenced

Run '/prompt-maintenance sync' to update catalog.
```

### `/prompt-maintenance sync`

Regenerate documentation artifacts.

**Process:**
1. Run full audit (silent mode)
2. Generate `prompts.json` for each source
3. Generate individual catalog per source
4. Generate combined `catalog.md` with Mermaid graph
5. Report files updated

**Output Format:**
```
prompt-maintenance sync

Scanning sources...
✓ ana-service: 68 templates

Generated:
  ✓ apps/ana-service/prompts.json
  ✓ docs/prompts/ana-service.md
  ✓ docs/prompts/catalog.md

Done.
```

### `/prompt-maintenance check <file>`

Validate single template (for hooks).

**Process:**
1. Parse template header
2. Validate structure (E001-E003)
3. Check encoding (E004)
4. Verify includes exist (E005)
5. Return pass/fail

**Output Format (pass):**
```
✓ lesson/exercise.jinja2 - Valid
```

**Output Format (fail):**
```
✗ lesson/exercise.jinja2
  E002: Missing Context field in header
  E005: Include not found: '_shared/missing.jinja2'
```

## Parsing Logic

### Header Extraction

```python
def parse_header(content: str) -> dict:
    """Extract metadata from template header."""
    # Find header block
    match = re.search(r'\{#\s*=*\s*(.*?)\s*=*\s*#\}', content, re.DOTALL)
    if not match:
        return None

    header = match.group(1)

    # Extract fields
    result = {
        'path': None,
        'description': None,
        'context': [],
        'output': None,
    }

    # First line is path
    lines = header.strip().split('\n')
    if lines:
        result['path'] = lines[0].strip()

    # Find Context: { ... }
    context_match = re.search(r'Context:\s*\{\s*([^}]+)\s*\}', header)
    if context_match:
        vars = context_match.group(1)
        result['context'] = [v.strip() for v in vars.split(',')]

    # Find Output: ...
    output_match = re.search(r'Output:\s*(.+?)(?:\n|$)', header)
    if output_match:
        result['output'] = output_match.group(1).strip()

    # Description is everything between path and Context/Output
    # (simplified - extract middle lines)

    return result
```

### Include Extraction

```python
def find_includes(content: str) -> list[str]:
    """Find all {% include %} references."""
    pattern = r"\{%\s*include\s+['\"]([^'\"]+)['\"]\s*%\}"
    return re.findall(pattern, content)
```

### Section Detection

```python
def find_sections(content: str) -> list[str]:
    """Find section comments like {# ROLE #}."""
    pattern = r'\{#\s*(ROLE|CONTEXT|TASK|RULES|OUTPUT)\s*#\}'
    return re.findall(pattern, content)
```

### Python Reference Detection

Templates may be loaded directly via Python code instead of `{% include %}`.
Scan Python files to detect these references and avoid false orphan warnings.

```python
def find_python_references(python_files: list[str]) -> dict[str, list[str]]:
    """
    Find template references in Python code.

    Returns dict mapping template names to files that reference them.
    """
    references = {}

    patterns = [
        # PromptLoader.render("domain/template")
        r'PromptLoader\.render\(["\']([^"\']+)["\']',
        # PromptLoader.render_cached("domain/template", ...)
        r'PromptLoader\.render_cached\(["\']([^"\']+)["\']',
        # get_template("template.jinja2")
        r'get_template\(["\']([^"\']+)["\']',
        # PackageLoader("app", "templates/domain") - extract domain
        r'PackageLoader\(["\'][^"\']+["\'],\s*["\']templates/([^"\']+)["\']',
    ]

    for py_file in python_files:
        content = read_file(py_file)
        for pattern in patterns:
            matches = re.findall(pattern, content)
            for match in matches:
                # Normalize template name
                template = match.rstrip('.jinja2')
                if template not in references:
                    references[template] = []
                references[template].append(py_file)

    return references
```

**Usage in orphan detection:**

```python
def is_orphan(template: str, jinja_includes: set, python_refs: dict) -> bool:
    """
    Check if template is truly orphan.

    A template is NOT orphan if:
    1. It's included by another template via {% include %}
    2. It's referenced directly in Python code
    3. It's in _shared/ (designed for inclusion)
    4. It's a _framework.jinja2 (designed for caching)
    """
    # Check Jinja includes
    if template in jinja_includes:
        return False

    # Check Python references
    template_variants = [
        template,
        template + '.jinja2',
        template.split('/')[-1],  # Just filename
        template.split('/')[-1].rstrip('.jinja2'),
    ]
    for variant in template_variants:
        if variant in python_refs:
            return False

    # Check if it's a shared/framework template
    if '/_shared/' in template or template.startswith('_shared/'):
        return False
    if '/_framework' in template or template.endswith('_framework'):
        return False

    return True
```

## References

- `references/template-header-format.md` - Header structure
- `references/validation-rules.md` - Error and warning rules
- `examples/well-formed-template.md` - Reference example
