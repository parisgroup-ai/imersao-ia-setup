---
name: railway-logs
description: Use when fetching or diagnosing Railway deployment logs for production issues.
---

# Railway Logs Skill

Fetch and analyze Railway production logs to diagnose deployment and runtime issues.

## Usage

`/railway-logs [service] [--tail N] [--filter pattern]`

- `service`: `web` | `ana-service` | `api-server` (default: `web`)
- `--tail N`: last N lines (default: 100)
- `--filter pattern`: grep pattern to filter output

## Steps

1. Run `railway status` to confirm the active project and environment.
2. Run `railway logs --service <service> -n <tail>` to fetch logs.
3. If `--filter` was provided, pipe output through `grep -i <pattern>`.
4. Analyze the output and identify root causes.

## Error Pattern Reference

| Pattern | Likely Cause |
|---|---|
| `ECONNREFUSED` | Database or Redis not reachable |
| `Module not found` | Missing build artifact — rebuild needed |
| `OOM` / `out of memory` | Railway memory limit hit |
| `ImportError` / `ModuleNotFoundError` | ana-service Python dep missing |
| `ETIMEDOUT` | External API timeout (Anthropic, S3, Stripe) |
| `prisma` / `drizzle` error | DB schema mismatch — migration needed |
| `401` / `403` | Auth token expired or missing env var |

## After Fetching Logs

- If error found: explain the root cause and suggest a fix.
- If logs are clean: check the previous deployment with `railway logs --deployment <id>`.
- For crashes: look for the last line before the restart marker.
