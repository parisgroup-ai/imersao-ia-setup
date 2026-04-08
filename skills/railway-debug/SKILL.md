---
name: railway-debug
description: Analyze Railway production logs and debug deploy/runtime errors. Full workflow from log collection through root cause analysis, migration recovery, and post-deploy verification.
version: 1.0.0
author: cleitonparis
---

# Railway Debug

Analyze Railway production logs, identify errors, and guide the fix for deploy and production issues.

> **Persistent memory:** Check project memory for Railway-specific notes before any action.

---

## Debug Workflow

```
0. CHECK MEMORY
   - Read project memory for Railway notes
   - Check known pitfalls and tested commands

1. COLLECT CONTEXT
   - railway status (project and environment)
   - Identify which service has the problem

2. ANALYZE LOGS
   - Runtime logs (production errors)
   - Build logs (deploy errors)
   - Filter by error level

3. ACCESS PRODUCTION DB (if needed)
   - Use public URL (switchyard.proxy.rlwy.net)
   - NEVER use internal hostname (.railway.internal)

4. IDENTIFY ROOT CAUSE
   - Categorize error type
   - Correlate with local code

5. PROPOSE AND APPLY FIX
   - Suggest specific fix
   - Apply fix in code
   - Validate locally before deploy

6. VERIFY FIX
   - Re-deploy
   - Confirm clean logs

7. UPDATE MEMORY
   - Save lessons learned
```

---

## Railway CLI Commands (Tested and Working)

### Commands that WORK

```bash
# General status (shows project, environment, current service)
railway status

# View variables for a specific service
railway variables --service <service-name>

# Execute command with Railway env vars injected
railway run -- node -e "console.log(process.env.DATABASE_URL ? 'ok' : 'no')"

# Runtime logs
railway logs -n 100 --service <service-name>

# Build logs
railway logs -n 200 --service <service-name> --build

# Redeploy
railway redeploy --service <service-name> --yes

# Variables as JSON (avoids table truncation)
railway variables --service <service-name> --json
```

### Commands that DO NOT WORK (pitfalls)

```bash
# DOES NOT WORK: service list (does not exist)
railway service list        # "Service not found"

# DOES NOT WORK: railway run with psql (internal hostname)
railway run -- psql "$DATABASE_URL" -c "SELECT 1"
# Fails because DATABASE_URL = postgres.railway.internal (only resolves inside Railway)

# DOES NOT WORK: interactive prompts
railway service   # Requires TTY to select service

# DOES NOT WORK: railway link --service (requires TTY)
railway link --service <name>   # Can't be scripted
```

---

## Production Database Access

### RULE: Always use public URL

The internal hostname (`postgres.railway.internal`) only resolves inside Railway's network.
To access locally, **always use the public URL** via `switchyard.proxy.rlwy.net`.

### Get the public URL

```bash
# Shows DATABASE_PUBLIC_URL among other variables
railway variables --service Postgres

# Programmatic access (avoids truncation)
railway variables --service Postgres --json | python3 -c "import json,sys; print(json.load(sys.stdin)['DATABASE_PUBLIC_URL'])"
```

### Connect via Node.js (WORKS)

```javascript
const { Client } = require("pg");
const client = new Client({
  connectionString: "<DATABASE_PUBLIC_URL>",
  ssl: { rejectUnauthorized: false }   // REQUIRED for Railway
});
await client.connect();
const result = await client.query("SELECT count(*) FROM ...");
await client.end();
```

### Connect via psql (WORKS)

```bash
psql "<DATABASE_PUBLIC_URL>" -c "SELECT count(*) FROM ..."
psql "<DATABASE_PUBLIC_URL>" < script.sql
```

### Connect via pipe (WORKS)

```bash
echo "SELECT 1;" | railway connect postgres
```

### Connection pitfalls

```bash
# railway run with local psql - DOES NOT resolve internal hostname
railway run -- psql "$DATABASE_URL" -c "SELECT 1"

# Node.js inside railway run - SAME failure
railway run -- node -e "require('pg')..."
# "getaddrinfo ENOTFOUND postgres.railway.internal"
```

---

## Drizzle Migration Audit (Production)

### Audit Workflow

```
1. Count entries in local journal
   cat migrations/meta/_journal.json | jq '.entries|length'

2. Count local SQL files
   ls migrations/*.sql | wc -l

3. Query production DB (via public URL)
   SELECT count(*) FROM drizzle.__drizzle_migrations

4. Compare by SHA-256 hash
   For each local .sql: sha256sum -> search in DB
   Drizzle registers by name OR by hash

5. Classify missing migrations:
   Cat.1: Schema exists, just register hash
   Cat.2: Schema missing, apply + register
   Cat.3: Data not migrated, apply + register

6. Generate idempotent script (BEGIN/COMMIT)
   - CREATE TABLE IF NOT EXISTS
   - DO $$ EXCEPTION WHEN duplicate_object
   - NOT EXISTS for __drizzle_migrations
```

### __drizzle_migrations table details

```
Schema: drizzle
Columns:
  id         integer (PK, serial)
  hash       text    (NO unique constraint!)
  created_at bigint  (timestamp in milliseconds)
```

**Important:** No unique constraint on `hash` — use `NOT EXISTS` instead of `ON CONFLICT`:

```sql
INSERT INTO drizzle.__drizzle_migrations (hash, created_at)
SELECT v.hash, v.created_at FROM (VALUES
  ('sha256hash...', 1770000000000::bigint)
) AS v(hash, created_at)
WHERE NOT EXISTS (
  SELECT 1 FROM drizzle.__drizzle_migrations m WHERE m.hash = v.hash
);
```

### Hash formats

Drizzle registers migrations in two forms (both coexist):
- **By name:** `0112_clean_sauron` (old format)
- **By SHA-256:** `542a0ed10308a4fa8bf...` (new format)

To verify:
```bash
shasum -a 256 migrations/XXXX_name.sql | awk '{print $1}'
```

### SQL pitfalls in migrations

| Pitfall | Example | Solution |
|---------|---------|----------|
| Enum column mismatch | `INSERT ... 'string'` into typed column | Explicit cast: `'string'::enum_type` |
| Enum ADD VALUE in transaction | `ALTER TYPE ... ADD VALUE` inside BEGIN | Use `IF NOT EXISTS` or DO block outside transaction |
| Duplicate CREATE TYPE | `CREATE TYPE x AS ENUM(...)` | `DO $$ BEGIN CREATE TYPE ... EXCEPTION WHEN duplicate_object THEN NULL; END $$` |
| Duplicate FK constraint | `ALTER TABLE ADD CONSTRAINT ...` | `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$` |

### Mega-migration detection

A migration is a mega-migration if:
- File > 50KB
- 10+ CREATE TYPE statements
- 20+ CREATE TABLE statements

**If detected:** DO NOT apply. Manually register the missing objects instead.

---

## Log Analysis

### Runtime Logs

```bash
# Last 100 logs from a service
railway logs -n 100 --service <service-name>

# Filter errors only
railway logs -n 100 --service <service-name> --filter "@level:error"

# Filter errors and warnings
railway logs -n 100 --service <service-name> --filter "@level:error OR @level:warn"
```

### Build Logs

```bash
# Build logs from latest deploy
railway logs -n 200 --service <service-name> --build
```

---

## Error Categorization

| Category | Symptoms | Initial Action |
|----------|----------|----------------|
| **Build Failure** | "Build failed", exit code != 0 | Check build logs |
| **Runtime Error** | "Error:", stack traces | Check related code |
| **Type Error** | "TypeError", "is not a function" | Run type-check locally |
| **Import Error** | "Module not found", "Cannot find" | Check paths and exports |
| **Database Error** | "Connection refused", "ECONNREFUSED" | Check DATABASE_URL |
| **Migration Error** | "type already exists", "relation already exists" | See Migration Recovery |
| **Auth Error** | "Unauthorized", "Invalid token" | Check secrets/env vars |
| **Memory/Timeout** | "OOMKilled", "Timeout" | Optimize or increase resources |
| **Network Error** | "ENOTFOUND", "ETIMEDOUT" | Check URLs and connectivity |

---

## Service-Specific Debugging

### Next.js Services

**1. Build fails on types**
```bash
pnpm type-check
```

**2. Module not found**
```bash
pnpm ls <package-name>
```

**3. Environment variables**
```bash
railway variables --service <service-name>
```

**4. Hydration mismatch**
- Check if component uses `'use client'`
- Check SSR vs client-side rendering

### FastAPI / Python Services

**1. Python import error**
```bash
cat <service-path>/requirements.txt
```

**2. Database connection**
```bash
railway variables --service <service-name>
```

**3. CORS/Network**
- Check CORS configuration in `app/main.py`

---

## Migration Recovery (Production)

### "type already exists" / "relation already exists"

This happens when a migration tries to create something that already exists.

**Recovery workflow:**

1. Identify the failed migration in logs
2. Check if the objects already exist in the DB via public URL
3. If they exist: register the hash in `__drizzle_migrations`
4. If they don't exist: apply with `IF NOT EXISTS` + register
5. Redeploy

### Template script to register an already-applied migration

```sql
-- Get hash: shasum -a 256 migrations/XXXX_name.sql
INSERT INTO drizzle.__drizzle_migrations (hash, created_at)
SELECT '<sha256_hash>', <timestamp_from_journal>::bigint
WHERE NOT EXISTS (
  SELECT 1 FROM drizzle.__drizzle_migrations WHERE hash = '<sha256_hash>'
);
```

---

## Common Framework Errors

### Next.js 15+ / React 19

| Error | Cause | Solution |
|-------|-------|----------|
| `useFormStatus` undefined | Wrong import | `import { useFormStatus } from 'react-dom'` |
| Hydration mismatch | SSR/Client diff | Add `'use client'` or `suppressHydrationWarning` |
| `headers()` async | Next.js 15 breaking change | `await headers()` |

### tRPC

| Error | Cause | Solution |
|-------|-------|----------|
| `TRPC_UNAUTHORIZED` | Session expired | Check auth config |
| `TRPC_BAD_REQUEST` | Zod validation failed | Check input schema |
| `TRPC_INTERNAL_SERVER_ERROR` | Procedure error | Check server logs |

### Database (Drizzle/PostgreSQL)

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | DB not reachable | Check DATABASE_URL |
| `relation does not exist` | Missing migration | Audit migrations |
| `duplicate key value` | Constraint violation | Check unique constraints |
| `type already exists` | Migration desync | Register hash manually |
| `column is of type X but expression is of type text` | Enum without cast | Add `::enum_name` |

---

## Local Validation Checklist

```bash
pnpm type-check        # TypeScript
pnpm lint              # ESLint
pnpm build             # Production build
pnpm test              # Tests
```

---

## Post-Deploy Verification

```bash
# Check logs from new deploy
railway logs -n 50 --service <service-name>

# Confirm errors stopped
railway logs -n 100 --service <service-name> --filter "@level:error"
```

---

## Action Flow Summary

1. **Check memory** for Railway-specific notes
2. **Ask which service** has the problem
3. **Collect logs** (runtime or build)
4. **If DB-related:** use public URL for direct diagnosis
5. **Categorize and locate** in code
6. **Propose fix** with idempotent script
7. **Validate locally** before push
8. **Verify post-deploy**
9. **Update memory** with lessons learned
