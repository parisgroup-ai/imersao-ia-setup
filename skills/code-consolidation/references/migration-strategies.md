# Migration Strategies

Step-by-step guides for consolidating different types of code duplication.

## Strategy 1: Factory Pattern Extraction

Use when multiple files define similar configuration objects with helper functions.

### Example: Status Configuration

**Before State:**
```
courses/constants.ts    → STATUS_CONFIG, getStatusLabel(), getStatusVariant()
ideas/constants.ts      → STATUS_CONFIG, getStatusLabel(), getStatusVariant()
brainstorms/constants.ts → STATUS_CONFIG, getStatusLabel(), getStatusVariant()
```

**Migration Steps:**

1. **Create Factory Module**
```typescript
// lib/status-config-factory.ts
export interface StatusDefinition<V extends string> {
  label: string;
  labelKey: string;
  variant: V;
  icon?: string;
}

export function createStatusConfig<
  S extends string,
  V extends string
>(configs: Record<S, StatusDefinition<V>>) {
  return configs;
}

export function createStatusHelpers<S extends string, V extends string>(
  configs: Record<S, StatusDefinition<V>>
) {
  return {
    getLabel: (status: S) => configs[status]?.label ?? status,
    getVariant: (status: S) => configs[status]?.variant,
    getIcon: (status: S) => configs[status]?.icon,
  };
}
```

2. **Migrate First Consumer**
```typescript
// courses/constants.ts
import { createStatusConfig, createStatusHelpers } from '@/lib/status-config-factory';

export const COURSE_STATUS_CONFIG = createStatusConfig({
  draft: { label: 'Rascunho', labelKey: 'status.draft', variant: 'default' },
  published: { label: 'Publicado', labelKey: 'status.published', variant: 'success' },
});

const helpers = createStatusHelpers(COURSE_STATUS_CONFIG);
export const getStatusLabel = helpers.getLabel;
export const getStatusVariant = helpers.getVariant;
```

3. **Verify First Migration**
```bash
pnpm type-check
pnpm test -- --testPathPattern="courses"
```

4. **Migrate Remaining Consumers**
Repeat step 2 for each remaining file.

5. **Cleanup**
- Remove duplicate helper implementations
- Keep backward-compatible exports

---

## Strategy 2: Error Hierarchy Consolidation

Use when error classes are scattered across services with duplicate names.

### Example: Python Service Errors

**Before State:**
```
module_generator.py     → ModuleGeneratorError, ModuleValidationError
module_regenerator.py   → ModuleRegeneratorError, ModuleValidationError (duplicate!)
rate_limiter.py         → RateLimitError
llm/providers/base.py   → RateLimitError (duplicate!)
```

**Migration Steps:**

1. **Create Error Hierarchy**
```python
# errors/__init__.py
from .base import AppError
from .service import (
    ServiceError,
    GenerationError,
    ValidationError,
)
from .infrastructure import (
    RateLimitError,
)

__all__ = [
    "AppError",
    "ServiceError",
    "GenerationError",
    "ValidationError",
    "RateLimitError",
]
```

```python
# errors/base.py
class AppError(Exception):
    """Base error for all application errors."""
    code: str = "APP_ERROR"

    def __init__(self, message: str, code: str | None = None, details: dict | None = None):
        self.message = message
        if code:
            self.code = code
        self.details = details or {}
        super().__init__(message)
```

```python
# errors/service.py
from .base import AppError

class ServiceError(AppError):
    code = "SERVICE_ERROR"

class GenerationError(ServiceError):
    code = "GENERATION_ERROR"

class ValidationError(ServiceError):
    code = "VALIDATION_ERROR"
```

2. **Add Backward Compatibility Aliases**
```python
# module_generator.py
from app.errors import GenerationError, ValidationError

# Backward compatibility
ModuleGeneratorError = GenerationError
ModuleValidationError = ValidationError
```

3. **Update Imports Incrementally**
```python
# Old (keep working)
from app.services.module_generator import ModuleGeneratorError

# New (preferred)
from app.errors import GenerationError
```

4. **Verify Tests Pass**
```bash
python -m pytest tests/services/test_module_generator.py -v
python -m pytest tests/ -k "error" -v
```

5. **Add Deprecation Warnings** (optional)
```python
import warnings

class ModuleGeneratorError(GenerationError):
    def __init__(self, *args, **kwargs):
        warnings.warn(
            "ModuleGeneratorError is deprecated. Use GenerationError from app.errors",
            DeprecationWarning,
            stacklevel=2
        )
        super().__init__(*args, **kwargs)
```

---

## Strategy 3: Barrel Export Reorganization

Use when utilities sprawl across flat directories without organization.

### Example: Utils Directory

**Before State:**
```
utils/
├── auth.ts
├── crypto.ts
├── email.ts
├── email-retry.ts
├── email-monitor.ts
├── redis-keys.ts
├── redis-metrics.ts
├── slug.ts
└── ... (40+ files)
```

**Migration Steps:**

1. **Create Barrel Index**
```typescript
// utils/index.ts
/**
 * Utils Index - Organized by Domain
 *
 * Categories:
 * - AUTH: totp, recovery-codes, account-lockout
 * - EXTERNAL: email, stripe, r2
 * - SECURITY: encryption, session-revocation
 * - DATA: slug, transactions
 */

// AUTH
export * from './totp';
export * from './recovery-codes';
export * from './account-lockout';

// EXTERNAL
export * from './r2';
export * from './stripe';
export * from './email';

// Handle naming conflicts with explicit re-exports
export {
  withEmailRetry,
  isRetryableEmailError,
  EMAIL_RETRY_CONFIG,
  logEmailEvent as logEmailRetryEvent,  // Renamed to avoid conflict
} from './email-retry';

export {
  logEmailEvent,  // Original name preserved
  getEmailMonitoringStats,
} from './email-monitor';

// SECURITY
export * from './encryption';
export * from './session-revocation';

// DATA
export * from './slug';
export * from './transactions';
```

2. **Handle Export Conflicts**

When two files export the same name:
```typescript
// Option A: Rename one export
export { logEmailEvent as logEmailRetryEvent } from './email-retry';
export { logEmailEvent } from './email-monitor';

// Option B: Use explicit exports for one module
export {
  specificFunction1,
  specificFunction2,
  // Don't export the conflicting name from this module
} from './conflicting-module';
```

3. **Update Imports**

Keep both paths working:
```typescript
// Direct import (still works)
import { foo } from '@/utils/specific-file';

// Barrel import (new, preferred for discovery)
import { foo } from '@/utils';
```

4. **Verify No Circular Dependencies**
```bash
# Check for circular imports
npx madge --circular src/utils/
```

---

## Strategy 4: Type Definition Consolidation

Use when the same types are defined in multiple packages.

### Example: Booking Types

**Before State:**
```
packages/types/src/booking.ts        → BookingSlot, BookingInput
packages/validators/src/booking.ts   → bookingSchema (Zod)
packages/api/modules/booking/types.ts → BookingEntity, BookingDTO
```

**Consolidation Approach:**

**Keep Separated by Concern:**
```
packages/types/           → Domain value types (pure TS interfaces)
packages/validators/      → Runtime validation (Zod schemas)
packages/api/modules/     → Module-internal types (domain entities)
```

**This is NOT duplication if:**
- `types/` has `BookingSlot` (shared across packages)
- `validators/` has `bookingSlotSchema` (validation logic)
- `api/modules/` has `BookingEntity` (ORM/domain model)

**Consolidate only when:**
- Same interface exists in 2+ places with identical structure
- Types can be derived from Zod schemas

**Migration Example (Zod → Types):**
```typescript
// packages/validators/src/booking.ts
import { z } from 'zod';

export const bookingSlotSchema = z.object({
  startTime: z.string().datetime(),
  endTime: z.string().datetime(),
  durationMinutes: z.number(),
});

// Infer type from schema (single source of truth)
export type BookingSlot = z.infer<typeof bookingSlotSchema>;

// packages/types/src/booking.ts
// Re-export from validators (not duplicate)
export type { BookingSlot } from '@repo/validators/booking';
```

---

## Strategy 5: Component/Hook Consolidation

Use when similar React components or hooks exist in multiple places.

### Example: useDebounce Hook

**Before State:**
```
app/admin/hooks/useDebounce.ts
app/creator/hooks/useDebounce.ts
lib/hooks/useDebounce.ts
```

**Migration Steps:**

1. **Choose Primary Location**
```
lib/hooks/useDebounce.ts  # Primary
```

2. **Compare Implementations**
```bash
diff app/admin/hooks/useDebounce.ts lib/hooks/useDebounce.ts
diff app/creator/hooks/useDebounce.ts lib/hooks/useDebounce.ts
```

3. **Merge Features into Primary**
Take the best features from each implementation.

4. **Update Imports**
```typescript
// Old
import { useDebounce } from '../hooks/useDebounce';

// New
import { useDebounce } from '@/lib/hooks/useDebounce';
```

5. **Delete Duplicates**
```bash
rm app/admin/hooks/useDebounce.ts
rm app/creator/hooks/useDebounce.ts
```

---

## Verification Checklist

After any consolidation:

- [ ] Type check passes: `pnpm type-check`
- [ ] Tests pass: `pnpm test`
- [ ] No broken imports: `grep -rn "from.*deleted/path"`
- [ ] No duplicate exports: Check barrel exports
- [ ] Backward compatibility: Old imports still resolve
- [ ] Documentation updated: ADR created if significant

## Common Pitfalls

### 1. Breaking Backward Compatibility
**Problem:** Removing exports that consumers depend on
**Solution:** Always add re-exports before removing

### 2. Circular Dependencies
**Problem:** A imports from B, B imports from A
**Solution:** Extract shared types to third module C

### 3. Over-Consolidation
**Problem:** Putting everything in one mega-file
**Solution:** Organize by domain, keep files focused

### 4. Forgetting Tests
**Problem:** Consolidation breaks tests
**Solution:** Run tests after each migration step

### 5. Missing Type Exports
**Problem:** Types not exported from barrel
**Solution:** Include `export type { ... }` in barrel
