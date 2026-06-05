# README Templates

Standard templates for documentation files in the monorepo.

## Package README Template

```markdown
# @repo/{package-name}

{One-line description of the package purpose.}

## Features

- **Feature 1**: Brief description
- **Feature 2**: Brief description
- **Feature 3**: Brief description

## Installation

```bash
pnpm add @repo/{package-name}
```

## Usage

### Basic Usage

```typescript
import { mainExport } from '@repo/{package-name}'

// Example code showing primary use case
const result = mainExport(options)
```

### Advanced Usage

```typescript
import { advancedFeature } from '@repo/{package-name}'

// Example of more complex usage
```

## API Reference

### `mainExport(options)`

Description of the main export.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `option1` | `string` | Yes | Description |
| `option2` | `boolean` | No | Description (default: `false`) |

**Returns:** `ReturnType` - Description

### `secondaryExport`

Description of secondary export.

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `VAR_NAME` | `value` | Description |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm test` | Run tests |
| `pnpm type-check` | TypeScript validation |
| `pnpm lint` | ESLint |

## Testing

```bash
pnpm -C packages/{package-name} test
```

## Related

- [ADR-XXXX](../../docs/06-ADRs/ADR-XXXX.md) - Related decision
- [@repo/related-package](../related-package/README.md) - Related package
```

## PageShell Package README Template

```markdown
# @pageshell/{package-name}

{One-line description.}

## Installation

```bash
pnpm add @pageshell/{package-name}
```

## Components

| Component | Description |
|-----------|-------------|
| `Component1` | Brief description |
| `Component2` | Brief description |

## Usage

### Component1

```tsx
import { Component1 } from '@pageshell/{package-name}'

<Component1
  prop1="value"
  prop2={true}
/>
```

### Component2

```tsx
import { Component2 } from '@pageshell/{package-name}'

<Component2>
  Children content
</Component2>
```

## Props Reference

### Component1Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `prop1` | `string` | Yes | - | Description |
| `prop2` | `boolean` | No | `false` | Description |

## Tree-Shaking

Import from subpaths for better tree-shaking:

```tsx
import { Component1 } from '@pageshell/{package-name}/component1'
import { Component2 } from '@pageshell/{package-name}/component2'
```

## Peer Dependencies

- React 18+ or 19+
- @pageshell/core
- @pageshell/primitives

## License

MIT
```

## App README Template

```markdown
# {App Name}

{One-line description of the app purpose.}

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 15 | Framework |
| React | 19 | UI Library |
| tRPC | v11 | API Layer |

## Getting Started

### Prerequisites

- Node.js 20+
- pnpm 10+
- Docker (for database)

### Development

```bash
# Start dependencies
docker-compose -f docker/docker-compose.yml up -d

# Install dependencies (from repo root)
pnpm install

# Start development server
pnpm dev --filter {app-name}
```

### Environment Variables

Create `.env.local`:

```env
DATABASE_URL=postgresql://...
NEXTAUTH_SECRET=...
```

See `.env.example` for all variables.

## Project Structure

```
apps/{app-name}/
├── src/
│   ├── app/           # Next.js App Router
│   ├── components/    # React components
│   ├── lib/           # Utilities
│   └── trpc/          # tRPC client setup
├── public/            # Static assets
└── package.json
```

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm dev` | Development server |
| `pnpm build` | Production build |
| `pnpm start` | Start production |
| `pnpm lint` | ESLint |
| `pnpm type-check` | TypeScript |

## Testing

```bash
pnpm -C apps/{app-name} test
```

## Deployment

Deployed via Railway/Vercel. See CI/CD pipeline in `.github/workflows/`.

## Related

- [AGENTS.md](./AGENTS.md) - Agent instructions
- [API Package](../../packages/api/README.md) - Shared API
```

## AGENTS.md Template

```markdown
---
title: "AGENTS.md ({location})"
created: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
status: active
tags:
  - type/guide
  - status/active
  - {category}/{name}
related:
  - "[[../AGENTS]]"
  - "[[../../AGENTS]]"
---

# AGENTS.md ({location})

## Scope

This file applies to everything under `{path}/`.
It **inherits** the global rules and routing in the repo root `AGENTS.md`.

## Project Context

`{package-name}` is {brief description}. It provides:
- Feature 1
- Feature 2
- Feature 3

## Mandatory Startup (ToStudy)

- If you are working in `{path}/`, you are in **ToStudy** context → follow the root `AGENTS.md` startup before implementation work.

## Key Locations

| Path | Description |
|------|-------------|
| `src/index.ts` | Public entry point |
| `src/feature/` | Feature implementation |
| `src/types.ts` | TypeScript types |

## Public API

### Basic Usage

```typescript
import { mainExport } from '{package-name}'

mainExport(options)
```

### Common Patterns

```typescript
// Pattern example
```

## Safe Defaults (Local)

- Do not {dangerous action} without explicit request
- Keep {important thing} consistent with existing patterns
- Avoid {common mistake}

## Validation

```bash
pnpm -C {path} test        # Run tests
pnpm -C {path} type-check  # TypeScript check
```

## Architecture

```
┌─────────────────────────────────────────┐
│              {Package Name}              │
├─────────────────────────────────────────┤
│  ┌──────────┐    ┌──────────┐          │
│  │ Module A │───▶│ Module B │          │
│  └──────────┘    └──────────┘          │
└─────────────────────────────────────────┘
```

---

## Herança

- **Pai**: [[../AGENTS]] ({parent})
- **Root**: [[../../AGENTS]]

## Links

- [[CLAUDE.md]] - Entry point
- [[README.md]] - Package documentation
```

## Minimal README (for simple packages)

```markdown
# @repo/{package-name}

{One-line description.}

## Usage

```typescript
import { feature } from '@repo/{package-name}'

feature()
```

## Scripts

- `pnpm test` - Run tests
- `pnpm type-check` - TypeScript validation
```
