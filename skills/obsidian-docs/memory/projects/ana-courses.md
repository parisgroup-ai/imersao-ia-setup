# Ana Courses Documentation Project

**Last Updated:** 2025-12-23

Project-specific documentation state for Ana Courses.

## Project Info

| Field | Value |
|-------|-------|
| **Name** | Ana Courses |
| **Type** | EAD Marketplace Platform |
| **Docs Root** | `/Users/cleitonparis/www/cursos/docs/` |
| **Memory Bank** | `/Users/cleitonparis/www/cursos/memory-bank/` |

## Documentation Structure

```
docs/
├── .obsidian/                  # Obsidian config
├── adr/                        # Architecture Decision Records
│   ├── ADR-0001-*.md
│   ├── ADR-0002-*.md
│   └── ADR-0003-*.md
├── api/                        # API Documentation
│   ├── knowledge/              # Knowledge Base API
│   │   ├── README.md
│   │   ├── domain-model.md
│   │   ├── api-endpoints.md
│   │   └── ...
│   └── reference.md            # API Reference Index
├── stories/                    # User Stories (legacy)
│   └── epic-*/
├── ui/                         # UI Documentation
│   ├── README.md
│   ├── NEW-COMPOSITE-VARIANTS.md
│   └── PAGE-SHELL-MIGRATION-MAP.md
└── design-system-guidelines.md
```

## Conventions

### Language

- **Docs**: Portuguese (pt-BR)
- **Technical terms**: English
- **Code comments**: English

### Frontmatter

```yaml
---
title: Document Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Author Name | Claude Code
status: draft | review | published
tags:
  - type/category
  - topic/subtopic
related:
  - "[[Related Doc]]"
---
```

### ADR Numbering

- Format: `ADR-NNNN-kebab-case-title.md`
- Start at: 0001
- Current max: 0003

### Linking

- Use wikilinks: `[[Page Name]]`
- Cross-folder: `[[../folder/Page]]`
- Memory bank links: `[[../../memory-bank/file]]`

## Documentation Inventory

### Existing

| Folder | Count | Status |
|--------|-------|--------|
| adr/ | 3 | Published |
| api/ | 6+ | In Progress |
| ui/ | 3 | Published |
| stories/ | ~50 | Legacy/Archive |

### Planned

| Doc | Priority | Status |
|-----|----------|--------|
| Architecture Overview | High | Not Started |
| API Complete Reference | High | In Progress |
| Component Library | Medium | Partial |
| Deployment Guide | Low | Not Started |

## Session Log

### 2025-12-23

**Created:**
- `docs/ui/README.md`
- `docs/ui/NEW-COMPOSITE-VARIANTS.md`
- `docs/ui/PAGE-SHELL-MIGRATION-MAP.md`

**Updated:**
- `packages/ui/src/components/page-shell/composites/README.md`
- `memory-bank/activeContext.md`
- `memory-bank/progress.md`

**Notes:**
- Documented LinearFlowPage composite implementation
- Created comprehensive migration map for 91 pages
- Identified 3 remaining composite variants needed

## Related Files

- [[../activeProject|Active Project State]]
- [[../conventions|Documentation Conventions]]
- [[../../memory-bank/SKILL|Memory Bank Skill]]
