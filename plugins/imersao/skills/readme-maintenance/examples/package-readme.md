# @repo/validators

Shared Zod schemas and validation utilities for the ToStudy platform.

## Features

- **Type-safe validation** - Zod schemas with full TypeScript inference
- **Reusable schemas** - Share validation logic across frontend and backend
- **Custom validators** - Brazilian CPF, CNPJ, phone, and more
- **Error formatting** - Consistent error messages for forms

## Installation

```bash
pnpm add @repo/validators
```

## Usage

### Basic Schemas

```typescript
import { userSchema, courseSchema } from '@repo/validators'

// Validate user input
const result = userSchema.safeParse(input)
if (!result.success) {
  console.error(result.error.flatten())
}

// TypeScript inference
type User = z.infer<typeof userSchema>
```

### Custom Validators

```typescript
import { cpf, cnpj, phone, currency } from '@repo/validators'

// Brazilian document validation
cpf.parse('123.456.789-00')  // Validates CPF format and checksum
cnpj.parse('12.345.678/0001-00')  // Validates CNPJ

// Phone validation
phone.parse('+55 11 99999-9999')  // Brazilian mobile

// Currency
currency.parse('R$ 1.234,56')  // Brazilian Real format
```

### Form Integration

```typescript
import { createUserSchema } from '@repo/validators'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

const form = useForm({
  resolver: zodResolver(createUserSchema),
  defaultValues: { name: '', email: '' }
})
```

## API Reference

### Schemas

| Schema | Description |
|--------|-------------|
| `userSchema` | User profile validation |
| `courseSchema` | Course creation/update |
| `enrollmentSchema` | Course enrollment |
| `paymentSchema` | Payment processing |
| `reviewSchema` | Course review submission |

### Validators

| Validator | Description |
|-----------|-------------|
| `cpf` | Brazilian CPF with checksum |
| `cnpj` | Brazilian CNPJ with checksum |
| `phone` | Phone number (BR format) |
| `email` | Email with domain validation |
| `url` | URL with protocol |
| `slug` | URL-safe slug |
| `uuid` | UUID v4 format |

### Utilities

| Utility | Description |
|---------|-------------|
| `formatZodError()` | Format Zod errors for display |
| `createPartialSchema()` | Make all fields optional |
| `mergeSchemas()` | Combine multiple schemas |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm test` | Run validation tests |
| `pnpm type-check` | TypeScript validation |

## Related

- [AGENTS.md](./AGENTS.md) - Agent instructions
- [@repo/api](../api/README.md) - Uses these schemas for input validation
