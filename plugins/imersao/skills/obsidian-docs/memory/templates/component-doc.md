# Component Documentation Template

Copy this template for UI component documentation.

---

```markdown
---
title: "Component: {{name}}"
created: {{date}}
updated: {{date}}
author: {{team}}
status: active | deprecated | experimental
tags:
  - type/component
  - ui/{{category}}
---

# {{name}}

{{brief_description}}

## Overview

| Property | Value |
|----------|-------|
| **Package** | `@repo/ui` |
| **Path** | `packages/ui/src/components/{{path}}` |
| **Status** | {{status}} |

## When to Use

- Use case 1
- Use case 2

## When NOT to Use

- Anti-pattern 1
- Anti-pattern 2

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `theme` | `'admin' \| 'creator' \| 'student'` | `'creator'` | Portal theme |
| `title` | `string` | - | Page title (required) |
| `children` | `ReactNode` | - | Content |

## Usage Examples

### Basic Usage

\`\`\`tsx
import { {{name}} } from '@repo/ui';

export function Example() {
  return (
    <{{name}} title="Example">
      <p>Content here</p>
    </{{name}}>
  );
}
\`\`\`

### With All Options

\`\`\`tsx
<{{name}}
  theme="creator"
  title="Full Example"
  description="With all props"
  icon={Settings}
>
  {(data) => <Content data={data} />}
</{{name}}>
\`\`\`

## Slots / Customization

| Slot | Description |
|------|-------------|
| `slots.header` | Custom header content |
| `slots.footer` | Custom footer content |

## Styling

Uses theme tokens:

- `--{{theme}}-primary` - Primary color
- `--{{theme}}-surface` - Background color

## Accessibility

- Keyboard navigation: ✅
- Screen reader support: ✅
- Focus management: ✅

## Related Components

- [[Component A]] - Similar purpose
- [[Component B]] - Often used together

## Changelog

| Date | Author | Change |
|------|--------|--------|
| {{date}} | {{author}} | Initial version |
```
