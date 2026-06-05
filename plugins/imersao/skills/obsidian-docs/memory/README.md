# Obsidian-Docs Memory Bank

**Last Updated:** 2025-12-23

Persistent memory for the obsidian-docs skill. Maintains context, templates, and patterns across sessions.

## Structure

```
memory/
├── README.md              # This file - overview
├── activeProject.md       # Current documentation project state
├── conventions.md         # Project-specific conventions
├── templates/             # Ready-to-use document templates
│   ├── adr.md             # Architecture Decision Record
│   ├── runbook.md         # Operations runbook
│   ├── api-endpoint.md    # API endpoint documentation
│   ├── component-doc.md   # Component/module documentation
│   ├── pr-template.md     # Pull request template
│   └── page-index.md      # Index/MOC page template
├── patterns/              # Documentation patterns & examples
│   ├── linking.md         # Wikilink patterns
│   ├── callouts.md        # Callout usage guide
│   └── governance.md      # ADR/PR governance rules
└── projects/              # Per-project state (optional)
    └── {project-name}.md  # Project-specific docs state
```

## Session Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  OBSIDIAN-DOCS SESSION START                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. READ activeProject.md                                   │
│     → Current docs focus, pending items                     │
│                                                              │
│  2. CHECK conventions.md                                    │
│     → Project-specific rules, folder structure              │
│                                                              │
│  3. USE templates/ as needed                                │
│     → Copy and customize for new docs                       │
│                                                              │
│  4. FOLLOW patterns/ for consistency                        │
│     → Linking, callouts, governance                         │
│                                                              │
│  5. UPDATE activeProject.md when done                       │
│     → Track what was created/modified                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Quick Commands

| Task | Action |
|------|--------|
| New ADR | Copy `templates/adr.md`, fill in details |
| New Runbook | Copy `templates/runbook.md`, customize |
| API docs | Copy `templates/api-endpoint.md` per endpoint |
| Index page | Copy `templates/page-index.md` for MOCs |

## Conventions Summary

- **Wikilinks**: `[[Page Name]]` for internal links
- **Callouts**: `> [!info]`, `> [!warning]`, `> [!tip]`, `> [!danger]`
- **Frontmatter**: Always include title, created, updated, tags
- **Folder structure**: Numbered prefixes for sorting (00-Index, 01-Getting-Started)

## Update Triggers

| Event | File to Update |
|-------|----------------|
| Start docs session | Read activeProject.md |
| Create new doc | Log in activeProject.md |
| New convention added | Update conventions.md |
| Template improved | Update templates/*.md |
| Session ends | Update activeProject.md status |
