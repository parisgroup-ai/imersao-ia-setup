# Prompt Database Audit Report

> Generated: 2026-01-30 12:00:00
> Project: cursos (ToStudy Platform)

## Scan Summary

```
Scanning...
  ✓ 68 templates loaded from apps/ana-service/app/templates
  ✓ 45 operation types found in Python code
  ✓ 12 schema files parsed from packages/database/src/schema
  ✓ 74 Python references found (PromptLoader.render)
```

---

## Operations Audit (Template ↔ LLM Analytics)

### ERRORS (2)

```
✗ OP001: operation 'study_compaction' has no matching template
  → Found in: apps/ana-service/app/services/study/compaction_engine.py:260
  → Also at: apps/ana-service/app/services/study/compaction_engine.py:321
  → Suggestion: Create study/compaction.jinja2 or add to operationMappings

✗ OP001: operation 'chunk_indexing' has no matching template
  → Found in: apps/ana-service/app/services/knowledge_processor.py:1986
  → Note: This operation uses embeddings, may not need LLM template
  → Suggestion: Add to ignoredOperations in config if intentional
```

### WARNINGS (3)

```
⚠ OP002: template 'brainstorm/system.jinja2' not mapped to any operationType
  → Template exists but no set_llm_operation_type() references it
  → Suggestion: Add set_llm_operation_type('brainstorm_system') where used

⚠ OP002: template '_shared/pedagogical_framework.jinja2' not mapped to operationType
  → This is a shared include, not a standalone prompt
  → Suggestion: Add to ignoredOrphans in config

⚠ OP003: operation 'study_course_message_init' uses inconsistent naming
  → Expected: 'study_course_message' or 'study_message_init'
  → Current name mixes concepts
```

---

## Schema Audit (Template ↔ Domain Schemas)

### ERRORS (1)

```
✗ SC001: variable 'course_level' in lesson/intro.jinja2:28 not found in courses schema
  → Template uses: {{ course_level }}
  → courses schema has: level (courseLevelEnum)
  → Suggestion: Use 'level' instead, or add alias mapping:
    "schemaAliases": { "course_level": "courses.level" }
```

### WARNINGS (2)

```
⚠ SC005: variable 'style' in multiple templates has no prefix
  → Used in: lesson/exercise.jinja2, lesson/concept.jinja2, outline/generate.jinja2
  → Ambiguous: could be course style, module style, or teaching style
  → Suggestion: Use 'course_style' or add to ignoredVariables with documentation

⚠ SC006: variable 'previous_lessons' expects array but is calculated
  → Used in: lesson/concept.jinja2, lesson/exercise.jinja2
  → Not a direct DB column - built from query
  → Suggestion: Add to ignoredVariables (calculated field)
```

---

## References Audit (Template ↔ Code)

### ERRORS (0)

All `PromptLoader.render()` calls reference existing templates.

### WARNINGS (4)

```
⚠ RF002: template 'extraction/enrichment_system.jinja2' may be orphan
  → Not found in PromptLoader.render() calls
  → Not included by other templates
  → Found in: idea_extractor.py uses 'extraction/enrichment_system'
  → Status: FALSE POSITIVE - reference uses path without .jinja2
  → Suggestion: Standardize references to include extension

⚠ RF002: template 'mcp/review_code.jinja2' may be orphan
  → Referenced via: _jinja_env.get_template("review_code.jinja2")
  → Different loader pattern (PackageLoader for mcp domain)
  → Status: FALSE POSITIVE - used by MCP service
  → Suggestion: Add pattern for get_template() in mcp_service.py

⚠ RF002: template 'video_prompt/avatar.jinja2' referenced indirectly
  → Template loaded dynamically: get_template(f"video_prompt/{format}.jinja2")
  → Cannot statically verify reference
  → Suggestion: Add to dynamicTemplates in config

⚠ RF002: template 'video_prompt/motion.jinja2' referenced indirectly
  → Same as above (dynamic loading)
```

---

## Summary

| Dimension | Errors | Warnings | Templates | Pass Rate |
|-----------|--------|----------|-----------|-----------|
| Operations | 2 | 3 | 45 ops | 95.6% |
| Schema | 1 | 2 | 68 templates | 98.5% |
| References | 0 | 4 | 74 refs | 100% |
| **TOTAL** | **3** | **9** | - | **97.8%** |

---

## Recommended Actions

### High Priority (Errors)

1. **Create study/compaction.jinja2** or document why `study_compaction` operation doesn't need a template
2. **Document chunk_indexing** as embedding-only operation (no LLM completion)
3. **Fix course_level variable** in lesson/intro.jinja2 - either rename to `level` or add alias

### Medium Priority (Warnings)

1. Add `brainstorm/system.jinja2` to operationType mapping
2. Add prefix to ambiguous `style` variable across templates
3. Document `previous_lessons` as calculated field

### Low Priority (Improvements)

1. Standardize PromptLoader references to always include `.jinja2` extension
2. Add patterns for `get_template()` calls in MCP service
3. Document dynamic template loading for video_prompt domain

---

## Configuration Suggestions

Add to `.prompt-db-audit.json`:

```json
{
  "operationMappings": {
    "brainstorm_system": "brainstorm/system.jinja2"
  },
  "schemaAliases": {
    "course_level": "courses.level",
    "style": "courses.metadata.style"
  },
  "ignoredVariables": [
    "previous_lessons",
    "total_modules",
    "kb_context"
  ],
  "ignoredOperations": [
    "chunk_indexing"
  ],
  "dynamicTemplates": [
    "video_prompt/*.jinja2"
  ]
}
```

---

*Report generated by `/prompt-db-audit` skill*
