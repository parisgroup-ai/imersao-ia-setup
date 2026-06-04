# Active Documentation Project

**Last Updated:** 2025-12-23

## Current Project

| Field | Value |
|-------|-------|
| **Project** | Ana Courses |
| **Docs Path** | `/Users/cleitonparis/www/cursos/docs/` |
| **Vault Root** | `docs/` |
| **Status** | Active |

## Folder Structure

```
docs/
├── .obsidian/             # Obsidian config
├── adr/                   # Architecture Decision Records
├── api/                   # API documentation
│   └── knowledge/         # Knowledge Base API docs
├── stories/               # User stories (legacy)
├── ui/                    # UI component documentation
│   ├── README.md          # Index
│   ├── NEW-COMPOSITE-VARIANTS.md
│   └── PAGE-SHELL-MIGRATION-MAP.md
└── design-system-guidelines.md
```

## Recent Documentation Work

| Date | Doc | Action |
|------|-----|--------|
| 2025-12-23 | docs/ui/*.md | Created PageShell migration documentation |
| 2025-12-23 | composites/README.md | Added LinearFlowPage documentation |

## Pending Documentation

| Priority | Doc | Description |
|----------|-----|-------------|
| High | API Reference | Complete REST/tRPC endpoint docs |
| Medium | Architecture | System overview with diagrams |
| Low | Glossary | Terms and definitions |

## Documentation Standards

### Frontmatter (Required)

```yaml
---
title: Document Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Author Name
status: draft | review | published
tags:
  - type/category
  - topic/subtopic
related:
  - "[[Related Doc 1]]"
  - "[[Related Doc 2]]"
---
```

### Status Definitions

| Status | Meaning |
|--------|---------|
| `draft` | Work in progress, not ready for review |
| `review` | Ready for peer review |
| `published` | Approved and finalized |
| `deprecated` | Outdated, superseded by another doc |

## Session Notes

<!-- Add notes during documentation sessions -->

### 2025-12-23

- Created docs/ui/ folder with 3 documents
- Documented LinearFlowPage composite implementation
- Updated memory-bank with documentation progress
