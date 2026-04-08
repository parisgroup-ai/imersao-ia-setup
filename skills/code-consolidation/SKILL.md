---
name: code-consolidation
description: This skill should be used when the user asks to "find duplicated code", "map responsibilities", "consolidate code", "find code sprawl", "analyze duplication", "create consolidation plan", or mentions "código duplicado", "responsabilidades espalhadas", "consolidar". Analyzes codebases to identify scattered responsibilities that should be centralized.
version: 1.0.0
author: gustavo
tags: [analysis, refactoring, code-quality]
---

# Code Consolidation Mapper

Analyze codebases to identify responsibilities scattered across multiple files that should be consolidated into single sources of truth.

## Purpose

Map fragmented code responsibilities and generate actionable consolidation plans. Detect:
- Duplicate type definitions
- Scattered utility functions
- Repeated configuration patterns
- Fragmented error hierarchies
- Inconsistent factory implementations

## When to Use

- Before major refactoring efforts
- When onboarding to brownfield codebases
- During architecture reviews
- When code smells indicate duplication
- Planning consolidation sprints

## Analysis Process

### Phase 1: Pattern Detection

Scan for common duplication patterns using targeted searches:

```bash
# Type definitions scattered
grep -rn "export (type|interface) " --include="*.ts" | sort | uniq -d

# Similar function names in different files
grep -rn "export function \w+" --include="*.ts" | awk -F: '{print $3}' | sort | uniq -c | sort -rn

# Duplicate class definitions
grep -rn "class \w+Error" --include="*.ts" --include="*.py"

# Configuration objects with same structure
grep -rn "STATUS_CONFIG\|VARIANT_CONFIG" --include="*.ts"

# Factory patterns repeated
grep -rn "create.*Factory\|.*Factory\(" --include="*.ts"
```

### Phase 2: Responsibility Mapping

For each detected pattern, classify by category:

| Category | Detection Pattern | Consolidation Target |
|----------|-------------------|---------------------|
| **Types** | Same interface in 2+ packages | `packages/types/` |
| **Validators** | Duplicate Zod schemas | `packages/validators/` |
| **Errors** | Scattered error classes | `app/errors/` or `lib/errors/` |
| **Config** | Repeated status/variant configs | `lib/{domain}-config-factory.ts` |
| **Utils** | Similar functions across files | `lib/utils/{domain}.ts` |
| **Constants** | Duplicate magic values | `lib/constants/{domain}.ts` |

### Phase 3: Impact Analysis

For each consolidation opportunity, assess:

1. **File Count**: How many files contain the duplicate?
2. **Line Count**: Estimated lines of code affected
3. **Import Depth**: How many consumers import from scattered locations?
4. **Breaking Risk**: Will consolidation break existing APIs?

### Phase 4: Prioritization Matrix

Score opportunities using:

| Factor | Weight | Scoring |
|--------|--------|---------|
| Files affected | 30% | 1-5 files (1pt), 6-10 (2pt), 11+ (3pt) |
| Maintenance burden | 25% | Low (1pt), Medium (2pt), High (3pt) |
| Bug risk | 25% | Low (1pt), Medium (2pt), High (3pt) |
| Effort required | 20% | High (1pt), Medium (2pt), Low (3pt) |

Priority = (Files × 0.30) + (Maintenance × 0.25) + (BugRisk × 0.25) + (Effort × 0.20)

## Output Format

Generate consolidation map in markdown:

```markdown
# Consolidation Map: [Project Name]

## Executive Summary
- **Duplication Categories Found:** X
- **Files Affected:** Y
- **Estimated Lines to Eliminate:** Z

## Priority Matrix

| Priority | Category | Files | Impact | Effort | Score |
|----------|----------|-------|--------|--------|-------|
| 🔴 High  | [name]   | X     | High   | Low    | 2.8   |
| 🟡 Med   | [name]   | X     | Med    | Med    | 2.1   |
| 🟢 Low   | [name]   | X     | Low    | High   | 1.4   |

## Detailed Findings

### 1. [Category Name] 🔴 High Priority

**Problem:** [Description]

**Duplicated Locations:**
- `path/to/file1.ts:line` - [what it exports]
- `path/to/file2.ts:line` - [what it exports]

**Consolidation Target:** `path/to/consolidated/location.ts`

**Migration Steps:**
1. Create consolidated module
2. Add backward-compatible re-exports
3. Update consumers incrementally
4. Remove deprecated locations

**Verification:**
```bash
# Check for remaining references
grep -rn "old_import" src/
```
```

## Consolidation Patterns

### Pattern: Factory Extraction

When multiple files define similar configuration objects:

**Before (scattered):**
```typescript
// file1/constants.ts
export const STATUS_CONFIG = { draft: {...}, published: {...} };
export function getStatusLabel(status) { return STATUS_CONFIG[status].label; }

// file2/constants.ts
export const STATUS_CONFIG = { active: {...}, archived: {...} };
export function getStatusLabel(status) { return STATUS_CONFIG[status].label; }
```

**After (consolidated):**
```typescript
// lib/status-config-factory.ts
export function createStatusConfig<T extends string>(configs: Record<T, StatusDef>) { ... }
export function createStatusHelpers<T extends string>(configs: Record<T, StatusDef>) { ... }

// file1/constants.ts
import { createStatusConfig } from '@/lib/status-config-factory';
export const STATUS_CONFIG = createStatusConfig({ draft: {...}, published: {...} });
```

### Pattern: Error Hierarchy

When error classes are scattered:

**Before:**
```python
# service1.py
class Service1Error(Exception): pass
class ValidationError(Service1Error): pass

# service2.py
class Service2Error(Exception): pass
class ValidationError(Service2Error): pass  # Duplicate name!
```

**After:**
```python
# errors/__init__.py
from .base import AppError
from .service import ServiceError, ValidationError

# errors/service.py
class ServiceError(AppError): pass
class ValidationError(ServiceError): pass
```

### Pattern: Barrel Export Reorganization

When utilities sprawl across flat directories:

**Before:**
```
utils/
├── auth.ts
├── crypto.ts
├── email.ts
├── redis.ts
├── slug.ts
└── ... (40+ files)
```

**After:**
```
utils/
├── index.ts           # Barrel export with categories
├── auth/              # Or just organized exports in index.ts
│   └── index.ts       # export * from '../auth'; export * from '../crypto';
└── ...
```

## Backward Compatibility

Always maintain backward compatibility during migration:

1. **Re-export from old location:**
```typescript
// old/location.ts (deprecated)
export { Thing } from '@/new/location';
```

2. **Add deprecation comments:**
```typescript
/**
 * @deprecated Import from '@/new/location' instead
 */
export { Thing } from '@/new/location';
```

3. **Create alias for renamed exports:**
```typescript
// When renaming, keep old name as alias
export const OldName = NewName;
```

## Verification Commands

After consolidation, verify no orphaned references:

```bash
# Find remaining imports from deprecated location
grep -rn "from ['\"].*deprecated/path" src/

# Type check
pnpm type-check

# Run tests
pnpm test

# Check for duplicate exports
grep -rn "export.*SameName" src/ | wc -l
```

## Integration with TaskNotes

After generating consolidation map, create tasks:

```bash
# Create consolidation tasks
pnpm task:new "Consolidar [Category]" --sprint -t CHORE -p [priority]
```

## Additional Resources

### Reference Files

- **`references/detection-patterns.md`** - Detailed grep/ripgrep patterns for each language
- **`references/migration-strategies.md`** - Step-by-step migration guides

### Scripts

- **`scripts/find-duplicates.sh`** - Automated duplicate detection
- **`scripts/generate-consolidation-report.sh`** - Report generator
