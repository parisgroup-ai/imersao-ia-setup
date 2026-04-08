---
name: readme-maintenance
description: This skill should be used when the user asks to "audit READMEs", "update documentation", "check README consistency", "find missing READMEs", "generate README", "validate docs", or mentions README/documentation maintenance for packages and apps.
version: 1.0.0
author: gustavo
tags: [documentation, maintenance, monorepo]
---

# README Maintenance

Audit, standardize, generate, and validate README.md and AGENTS.md files across the monorepo.

## Purpose

Maintain consistent, accurate documentation for all packages and apps by:
1. **Auditing** existing READMEs for consistency and accuracy
2. **Detecting** missing documentation files
3. **Generating** new READMEs from code analysis
4. **Validating** links, exports, and command references
5. **Standardizing** format across the monorepo

## Quick Commands

| Action | Command |
|--------|---------|
| Audit all | `/readme audit` |
| Check specific package | `/readme audit packages/api` |
| Find missing | `/readme missing` |
| Generate README | `/readme generate packages/validators` |
| Validate links | `/readme links` |
| Fix inconsistencies | `/readme fix packages/api` |

## Audit Workflow

### Step 1: Discovery

Run the missing docs check first:

```bash
# Find packages without README.md
for pkg in packages/*/; do [ -f "$pkg/README.md" ] || echo "Missing: $pkg"; done

# Find packages without AGENTS.md
for pkg in packages/*/; do [ -f "$pkg/AGENTS.md" ] || echo "Missing: $pkg"; done

# Find apps without documentation
for app in apps/*/; do
  [ -f "$app/README.md" ] || echo "Missing README: $app"
  [ -f "$app/AGENTS.md" ] || echo "Missing AGENTS: $app"
done
```

### Step 2: Consistency Check

For each existing README, verify:

| Check | How |
|-------|-----|
| Package name matches | Compare `# @repo/name` with `package.json#name` |
| Exports documented | Cross-reference `package.json#exports` with README sections |
| Commands exist | Verify `pnpm` commands in README work |
| Links valid | Check internal links resolve |
| API up-to-date | Compare documented API with actual exports |

### Step 3: Content Analysis

Read existing READMEs to extract patterns. Reference `references/templates.md` for standard sections.

### Step 4: Report Generation

Output findings as:

```markdown
## README Audit Report

### Missing Documentation
- [ ] `packages/validators` - No README.md
- [ ] `packages/analytics` - No README.md

### Outdated Documentation
- [ ] `packages/api/README.md` - Missing router: `ideas`
- [ ] `packages/logger/README.md` - Undocumented export: `sanitize.headers()`

### Broken Links
- [ ] `packages/database/README.md:45` - Link to non-existent ADR

### Format Issues
- [ ] `packages/config/README.md` - Missing "Usage" section
```

## Generation Workflow

To generate a README for a package:

### Step 1: Analyze Package

```typescript
// Read package.json for metadata
const pkg = await readJson('package.json')
// name, description, exports, dependencies, scripts

// Read src/index.ts for public API
const exports = await analyzeExports('src/index.ts')

// Check for existing AGENTS.md context
const agents = await readFile('AGENTS.md')
```

### Step 2: Apply Template

Use the template from `references/templates.md`, filling:

- **Package name** from `package.json#name`
- **Description** from `package.json#description` or AGENTS.md context
- **Installation** (standard for all)
- **Usage** with examples from AGENTS.md or generated
- **API** from analyzed exports
- **Configuration** from env vars or options interfaces
- **Scripts** from `package.json#scripts`

### Step 3: Validate Generation

- Ensure all exports are documented
- Verify code examples compile
- Check links resolve

## Validation Checks

### Export Consistency

```bash
# Extract exports from package.json
jq -r '.exports | keys[]' packages/api/package.json

# Compare with documented exports in README
grep -E "^import.*from '@repo/api" packages/api/README.md
```

### Command Validation

```bash
# Extract pnpm commands from README
grep -oE 'pnpm [a-z:-]+' packages/database/README.md | sort -u

# Verify each exists in package.json scripts or root
```

### Link Validation

```bash
# Extract markdown links
grep -oE '\[.*\]\([^)]+\)' README.md

# Check each resolves (file exists or URL responds)
```

## Standardization Rules

### README Structure

Every README MUST have these sections in order:

1. **Title** - `# @repo/package-name` or `# @pageshell/name`
2. **Description** - One-line summary
3. **Features** (optional) - Bullet list of key features
4. **Installation** (for published packages)
5. **Usage** - Primary usage examples with code blocks
6. **API** (for libraries) - Public API reference
7. **Configuration** (if applicable) - Env vars, options
8. **Scripts** - Available npm/pnpm scripts
9. **Testing** (if tests exist)
10. **Related** (optional) - Links to ADRs, other docs

### AGENTS.md Structure

Every AGENTS.md MUST have:

1. **YAML frontmatter** with title, created, updated, status, tags
2. **Scope** - What this file covers
3. **Project Context** - Purpose of package/app
4. **Mandatory Startup** - Reference to root AGENTS.md
5. **Key Locations** - Important file paths table
6. **Public API** (for packages) - Usage examples
7. **Safe Defaults** - What NOT to do automatically
8. **Validation** - Test/lint/typecheck commands
9. **Herança** - Parent AGENTS links
10. **Links** - Related documentation

### Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Package README title | `# @repo/name` | `# @repo/logger` |
| PageShell package | `# @pageshell/name` | `# @pageshell/composites` |
| App README title | `# App Name` | `# Web (Next.js 15)` |
| Code blocks | Language specified | ` ```typescript ` |

### Code Examples

- Always include language identifier in code blocks
- Show imports explicitly
- Provide minimal but complete examples
- Use real types from the package

## Scripts

### `scripts/audit-readmes.sh`

Comprehensive audit script that checks all packages and apps.

### `scripts/generate-readme.sh`

Template-based README generator for packages.

### `scripts/validate-links.sh`

Link checker for markdown files.

## Additional Resources

### Reference Files

- **`references/templates.md`** - Standard templates for README and AGENTS.md
- **`references/checklist.md`** - Full audit checklist
- **`references/examples.md`** - Examples of well-written docs from this repo

### Example Files

- **`examples/package-readme.md`** - Complete package README example
- **`examples/app-readme.md`** - Complete app README example
- **`examples/agents-md.md`** - Complete AGENTS.md example

## Common Issues

| Issue | Solution |
|-------|----------|
| Missing README | Generate using template + code analysis |
| Outdated exports | Re-analyze `src/index.ts` and update |
| Dead links | Remove or update to valid targets |
| Missing code examples | Extract from AGENTS.md or tests |
| Inconsistent formatting | Apply standard template sections |
| Duplicate content in README/AGENTS | Keep detailed API in AGENTS.md, summary in README |

## Integration with Other Skills

- Use `agents-maintenance` for AGENTS.md validation
- Use `code-quality` to ensure documentation matches implementation
- Use `i18n-audit` if documentation contains hardcoded strings
