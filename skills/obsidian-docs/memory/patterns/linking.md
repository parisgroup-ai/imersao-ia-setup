# Linking Patterns

Best practices for Obsidian wikilinks and references.

## Wikilink Syntax

### Basic Links

```markdown
<!-- Link to page in same folder -->
[[Page Name]]

<!-- Link with display alias -->
[[Page Name|Display Text]]

<!-- Link to heading within page -->
[[Page Name#Heading]]

<!-- Link to heading with alias -->
[[Page Name#Heading|Display Text]]
```

### Cross-Folder Links

```markdown
<!-- Link to parent folder -->
[[../Other Page]]

<!-- Link to sibling folder -->
[[../sibling-folder/Page]]

<!-- Deep nested link -->
[[../../level-up/then-down/Page]]
```

### Embeds

```markdown
<!-- Embed entire page -->
![[Page Name]]

<!-- Embed specific section -->
![[Page Name#Section]]

<!-- Embed image -->
![[image.png]]

<!-- Embed with size (images only) -->
![[image.png|300]]
![[image.png|300x200]]
```

## Link Patterns by Document Type

### ADRs

```markdown
<!-- Link to requirements -->
- Requisitos: [[REQ-042]], [[REQ-043]]

<!-- Link to related ADRs -->
- ADRs relacionados: [[ADR-001]], [[ADR-005]]

<!-- Link to implementation -->
- Implementação: [[PR #123]]
```

### API Documentation

```markdown
<!-- Link to auth docs -->
See [[Authentication]] for token setup.

<!-- Link to error codes -->
Returns [[Error Codes#404]] if not found.

<!-- Link to related endpoints -->
Related: [[GET /users]], [[POST /users]]
```

### Component Documentation

```markdown
<!-- Link to base component -->
Extends [[PageShell]] base component.

<!-- Link to related components -->
Often used with [[Button]], [[Card]].

<!-- Link to patterns -->
Follows [[systemPatterns#Pattern-15]].
```

## Navigation Patterns

### Breadcrumb Links

```markdown
[[../README|← Back to Index]] | [[../parent/README|Parent Section]]
```

### See Also Section

```markdown
## Related

- [[Component A]] - Similar purpose
- [[Component B]] - Often used together
- [[Pattern Guide]] - Design patterns
```

### Table of Contents

```markdown
## Contents

- [[#Overview]]
- [[#Usage]]
- [[#Examples]]
- [[#API Reference]]
```

## Anti-Patterns (Avoid)

```markdown
<!-- ❌ External links for internal pages -->
[Page](./page.md)

<!-- ✅ Use wikilinks -->
[[Page]]

<!-- ❌ Broken relative paths -->
[[../../wrong/path/Page]]

<!-- ✅ Verify path exists -->
[[../correct/Page]]

<!-- ❌ Orphan pages (no incoming links) -->
<!-- ✅ Always link from at least one index/MOC -->
```

## Link Maintenance

### Check for Broken Links

Use Obsidian's "Outgoing links" panel to verify all links resolve.

### Rename Handling

Obsidian auto-updates wikilinks when renaming files (if enabled in settings).

### Alias Consistency

When using aliases, keep them consistent:

```markdown
<!-- Consistent -->
[[PAGE-SHELL-MIGRATION-MAP|Migration Map]]
[[PAGE-SHELL-MIGRATION-MAP|Migration Map]]

<!-- Inconsistent (avoid) -->
[[PAGE-SHELL-MIGRATION-MAP|Migration Map]]
[[PAGE-SHELL-MIGRATION-MAP|Page Shell Map]]
```
