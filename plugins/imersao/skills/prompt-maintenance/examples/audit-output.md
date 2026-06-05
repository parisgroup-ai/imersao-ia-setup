# Audit Output Example

Example output from `/prompt-maintenance audit`.

## Clean Run (No Issues)

```
prompt-maintenance audit

Scanning apps/ana-service/app/templates/...

✓ 68 templates analyzed
✓ 156 dependencies mapped
✓ 0 errors, 0 warnings

Stats:
  By domain: lesson (12), brainstorm (8), interview (4), _shared (4),
             proposal (3), validation (2), study (6), extraction (7),
             module (2), outline (2), mcp (3), spark (3), tutor (3),
             resource (2), translation (2), video_prompt (3), workspace (1)

  Most included: _shared/output_rules (23 refs), _shared/platform_context (15 refs)
  Orphans: 0

All templates valid. Run '/prompt-maintenance sync' to update catalog.
```

## Run With Issues

```
prompt-maintenance audit

Scanning apps/ana-service/app/templates/...

✓ 68 templates analyzed
✓ 156 dependencies mapped

ERRORS (3):
  ✗ spark/intent.jinja2:1 - E001: Missing header block
  ✗ study/new_feature.jinja2:5 - E002: Missing Context field
  ✗ extraction/draft.jinja2:12 - E005: Include not found: '_shared/legacy.jinja2'

WARNINGS (4):
  ⚠ extraction/idea_user.jinja2 - W001: Sections out of order (OUTPUT before TASK)
  ⚠ mcp/review_code.jinja2 - W002: Returns JSON but doesn't include _shared/output_rules
  ⚠ video_prompt/legacy.jinja2 - W004: Orphan template (not referenced)
  ⚠ test/mock.jinja2 - W004: Orphan template (not referenced)

Stats:
  By domain: lesson (12), brainstorm (8), ...
  Orphans: 2

Fix errors before running '/prompt-maintenance sync'.
```

## JSON Output Mode

With `--format json`:

```json
{
  "summary": {
    "templates": 68,
    "dependencies": 156,
    "errors": 3,
    "warnings": 4
  },
  "errors": [
    {
      "file": "spark/intent.jinja2",
      "line": 1,
      "code": "E001",
      "message": "Missing header block"
    }
  ],
  "warnings": [
    {
      "file": "extraction/idea_user.jinja2",
      "code": "W001",
      "message": "Sections out of order (OUTPUT before TASK)"
    }
  ],
  "stats": {
    "by_domain": {"lesson": 12, "brainstorm": 8},
    "orphans": 2
  }
}
```
