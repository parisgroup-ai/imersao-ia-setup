# Documentation Conventions

**Last Updated:** 2025-12-23

Project-specific documentation conventions and rules.

## Ana Courses Project Conventions

### Folder Structure Rules

| Folder | Purpose | Naming |
|--------|---------|--------|
| `docs/adr/` | Architecture decisions | `ADR-NNNN-title.md` |
| `docs/api/` | API reference | `module-name.md` |
| `docs/ui/` | UI components | `COMPONENT-NAME.md` |
| `docs/stories/` | User stories (legacy) | `epic-NN-story-MM.md` |

### File Naming

- **ADRs**: `ADR-0001-use-postgresql.md` (4-digit padded)
- **Components**: `PAGE-SHELL-MIGRATION-MAP.md` (UPPERCASE-KEBAB)
- **Modules**: `knowledge-base-api.md` (lowercase-kebab)
- **Indexes**: `README.md` per folder

### Language

- **Primary**: Portuguese (pt-BR) for user-facing content
- **Technical terms**: English (API, endpoint, component, etc.)
- **Comments in code**: English

### Linking Conventions

```markdown
<!-- Within same folder -->
[[README]]
[[Other-Doc]]

<!-- Cross-folder (use relative paths) -->
[[../ui/PAGE-SHELL-MIGRATION-MAP]]
[[../../memory-bank/systemPatterns]]

<!-- With aliases (for cleaner text) -->
[[PAGE-SHELL-MIGRATION-MAP|Migration Map]]
```

### Callout Usage

| Callout | When to Use |
|---------|-------------|
| `> [!info]` | General context, explanations |
| `> [!tip]` | Best practices, recommendations |
| `> [!warning]` | Potential issues, deprecations |
| `> [!danger]` | Breaking changes, critical issues |
| `> [!todo]` | Action items, pending tasks |
| `> [!success]` | Completed items, good outcomes |
| `> [!example]` | Code examples, demonstrations |
| `> [!question]` | FAQs, open questions |

### Table Standards

Always include headers and alignment:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

### Code Blocks

Always specify language for syntax highlighting:

```markdown
\`\`\`typescript
// TypeScript code
\`\`\`

\`\`\`bash
# Shell commands
\`\`\`

\`\`\`tsx
// React/TSX code
\`\`\`
```

## ADR Conventions (Ana Courses)

### Required Sections

1. **Status** - proposed | accepted | rejected | superseded
2. **Contexto** - Problem and constraints (Portuguese)
3. **Decisão** - Chosen option with justification
4. **Consequências** - Positives and negatives
5. **Opções Consideradas** - Alternatives evaluated

### ID Assignment

- Check existing ADRs in `docs/adr/`
- Use next sequential number (4-digit padded)
- Never reuse IDs, even for rejected ADRs

## Component Documentation Conventions

### Required Sections

1. **Overview** - What it does, when to use
2. **Props** - Full props table with types
3. **Usage Examples** - At least 2 examples
4. **Slots/Customization** - If applicable
5. **Related** - Links to related components

### Props Table Format

```markdown
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `theme` | `'admin' \| 'creator' \| 'student'` | `'creator'` | Portal theme |
| `title` | `string` | - | Page title (required) |
```

## Changelog Conventions

Every significant document should have a changelog:

```markdown
## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2025-12-23 | Claude Code | Initial version |
| 2025-12-24 | Claude Code | Added new section |
```
