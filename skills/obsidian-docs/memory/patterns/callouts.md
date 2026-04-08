# Callout Patterns

Obsidian callout usage guide and examples.

## Callout Syntax

```markdown
> [!type] Optional Title
> Callout content here.
> Can span multiple lines.
```

## Standard Callouts

### Information

```markdown
> [!info] Information
> General context or explanatory notes.
```

Use for: Background info, context, explanations

### Tips

```markdown
> [!tip] Pro Tip
> Best practices and helpful suggestions.
```

Use for: Recommendations, shortcuts, best practices

### Warnings

```markdown
> [!warning] Warning
> Potential issues or important cautions.
```

Use for: Deprecations, gotchas, potential problems

### Danger

```markdown
> [!danger] Critical
> Breaking changes or security concerns.
```

Use for: Breaking changes, security issues, data loss risks

### Examples

```markdown
> [!example] Example
> Code examples or demonstrations.
```

Use for: Code snippets, usage examples

### Questions

```markdown
> [!question] FAQ
> Common questions and answers.
```

Use for: FAQs, clarifications

### Todos

```markdown
> [!todo] Action Required
> Tasks that need to be completed.
> - [ ] Task 1
> - [ ] Task 2
```

Use for: Pending tasks, action items

### Success

```markdown
> [!success] Completed
> Successfully finished items or good outcomes.
```

Use for: Completed features, successful migrations

### Quote

```markdown
> [!quote] Reference
> Citations or external references.
> — Source
```

Use for: Quotes, citations, references

## Custom Callouts

### Abstract/Summary

```markdown
> [!abstract] Summary
> Brief overview of the document.
```

### Bug

```markdown
> [!bug] Known Issue
> Description of a known bug.
```

### Note

```markdown
> [!note] Note
> Additional notes or considerations.
```

## Callout Modifiers

### Foldable (Collapsed by Default)

```markdown
> [!info]- Click to expand
> Hidden content here.
```

### Foldable (Expanded by Default)

```markdown
> [!info]+ Click to collapse
> Visible content here.
```

## Usage by Document Type

### ADRs

```markdown
> [!warning] Status: Proposed
> This ADR is pending review.

> [!danger] Breaking Change
> This decision affects existing APIs.

> [!success] Status: Accepted
> Approved on 2025-12-23.
```

### Runbooks

```markdown
> [!warning] Severity Level
> **P1** - Response time: 15 minutes

> [!danger] Use with caution
> Only proceed if resolution steps fail.

> [!todo] Post-Incident
> - [ ] Update ticket
> - [ ] Notify stakeholders
```

### API Documentation

```markdown
> [!info] Authentication Required
> This endpoint requires a valid Bearer token.

> [!example] Error Response
> \`\`\`json
> { "error": "NOT_FOUND" }
> \`\`\`
```

### Component Documentation

```markdown
> [!tip] When to Use
> Use this component for CRUD list pages.

> [!warning] Deprecation Notice
> `oldProp` will be removed in v2.0.
```

## Nested Callouts

```markdown
> [!info] Outer Callout
> Some content here.
>
> > [!warning] Nested Warning
> > Important detail.
```

## Best Practices

1. **Don't overuse** - Too many callouts reduce their impact
2. **Be specific** - Use the right callout type for the content
3. **Keep titles short** - Optional titles should be brief
4. **Use consistently** - Same callout type for same purpose across docs
