---
name: db-migration
description: Create and apply Drizzle ORM migrations safely with Docker sync. Use when the user says "create migration", "db migrate", "schema change", or modifies database schema files.
disable-model-invocation: true
---

# Database Migration Skill

Safe workflow for Drizzle ORM migrations in the ToStudy monorepo.

## Pre-flight Checks

1. Verify Docker is running: `docker ps | grep postgres`
2. Check current migration state: `ls -la packages/database/migrations/ | tail -5`
3. Review the schema changes: `git diff packages/database/src/schema/`

## Migration Workflow

### Step 1: Generate Migration

```bash
pnpm db:generate
```

Review the generated SQL file in `packages/database/migrations/`. Verify:
- No destructive operations (DROP TABLE, DROP COLUMN) unless explicitly intended
- Index names are meaningful
- Foreign key constraints are correct

### Step 2: Apply Migration (Local)

```bash
pnpm db:migrate
```

### Step 3: Verify

```bash
pnpm db:studio  # Visual check (optional)
pnpm type-check  # Ensure schema types propagate
```

### Step 4: Docker Sync (CRITICAL for Railway)

The Docker build uses the committed migration files. After applying:

```bash
git add packages/database/migrations/
```

## Safety Rules

- NEVER edit an existing migration file (they are immutable once applied)
- NEVER delete migration files
- If a migration needs correction, create a NEW migration that fixes it
- Always review generated SQL before applying
- For destructive changes (DROP), require explicit user confirmation
- Run `pnpm type-check` after migration to catch downstream breaks

## Rollback

If a migration fails:
1. Check error message in terminal
2. Fix the schema in `packages/database/src/schema/`
3. Delete the UNAPPLIED migration file (only if never applied)
4. Re-generate with `pnpm db:generate`
