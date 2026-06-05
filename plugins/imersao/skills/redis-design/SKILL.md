---
name: redis-design
description: "Use when designing Redis data structures, caching strategies, or key schemas - enforces key naming conventions, hash tags for clustering, memory optimization, proper cache patterns, error handling with circuit breakers, and rate limiting algorithms. Triggers on: Redis, cache, key design, TTL, rate limit, pub/sub, sorted set, session store."
version: 1.0.0
author: gustavo
tags: [redis, caching, design, infrastructure]
---

# Redis Design Skill

## Key Naming Convention

**MANDATORY FORMAT:** `{env}:{app}:{entity}:{id}[:suffix]`

| Component | Example | Purpose |
|-----------|---------|---------|
| env | `prod`, `stg`, `dev` | Environment isolation |
| app | `api`, `worker`, `web` | Application namespace |
| entity | `user`, `session`, `cache` | Data type |
| id | `usr_123`, `abc456` | Unique identifier |
| suffix | `:v1`, `:meta` | Versioning/subkey |

```redis
# Good
prod:api:session:sess_abc123
prod:api:cache:user:usr_789:v1
prod:api:ratelimit:usr_789:28381681

# Bad - no namespace, collision risk
session:abc123
user:789
```

## Hash Tags for Clustering

**CRITICAL:** Related keys MUST share hash tag for atomic operations.

```redis
# Keys on SAME slot (required for MULTI/EXEC)
{user:123}:profile
{user:123}:sessions
{user:123}:preferences

# WRONG - different slots, MULTI fails
user:123:profile
user:123:sessions
```

## Data Structure Selection

| Use Case | Structure | Why NOT alternatives |
|----------|-----------|---------------------|
| Object with fields | Hash | String+JSON = full deserialize |
| Unique collection | Set | List allows duplicates |
| Ranked data | Sorted Set | Manual sorting = O(n log n) |
| Queue | Stream | List = no consumer groups |
| Counter | String+INCR | Hash HINCRBY if grouped |
| Time-series | Stream | Sorted Set = manual cleanup |
| Events (fire-forget) | Pub/Sub | Stream = unnecessary persistence |
| Events (guaranteed) | Stream | Pub/Sub = no replay/ACK |

## Cache Patterns

| Pattern | When to Use | Implementation |
|---------|-------------|----------------|
| Cache-Aside | Read-heavy, tolerates stale | App reads cache, misses hit DB |
| Write-Through | Consistency critical | Write DB + cache atomically |
| Write-Behind | Write-heavy, eventual OK | Queue writes, batch to DB |

**Stampede Prevention:**
```redis
# Probabilistic early refresh: refresh at TTL * 0.8 randomly
SET key value EX 300
# When TTL < 60 AND random() < 0.1 → background refresh
```

## Rate Limiting (Lua for atomicity)

```lua
-- Token Bucket (smooth traffic)
local key = KEYS[1]
local rate = tonumber(ARGV[1])     -- tokens per second
local capacity = tonumber(ARGV[2]) -- bucket size
local now = tonumber(ARGV[3])
local requested = tonumber(ARGV[4])

local data = redis.call('HMGET', key, 'tokens', 'last')
local tokens = tonumber(data[1]) or capacity
local last = tonumber(data[2]) or now

local delta = math.max(0, now - last)
tokens = math.min(capacity, tokens + delta * rate)

if tokens >= requested then
    tokens = tokens - requested
    redis.call('HMSET', key, 'tokens', tokens, 'last', now)
    redis.call('EXPIRE', key, capacity / rate * 2)
    return 1
end
return 0
```

## Error Handling

**MANDATORY:** Every Redis client MUST implement:

1. **Connection Pool** - Min 5, Max 20 per service
2. **Circuit Breaker** - Open after 5 failures, half-open at 30s
3. **Retry** - Exponential backoff: 100ms, 200ms, 400ms (max 3)
4. **Fallback** - Serve stale or skip cache on Redis down

```typescript
// Fallback pattern
async function getWithFallback<T>(key: string, fetchFn: () => Promise<T>): Promise<T> {
  try {
    const cached = await redis.get(key);
    if (cached) return JSON.parse(cached);
  } catch (e) {
    logger.warn('Redis unavailable, falling back to DB');
  }
  return fetchFn();
}
```

## Pipeline Batching

**Use PIPELINE for multiple operations:**
```redis
# BAD - 3 round trips
GET key1
GET key2
GET key3

# GOOD - 1 round trip
PIPELINE
  GET key1
  GET key2
  GET key3
EXEC
```

**Rule:** >3 independent commands = PIPELINE.

## Memory Optimization

- **Key length:** <100 bytes (keys stored multiple times)
- **Compression:** MessagePack for values >1KB
- **TTL everything:** No TTL = memory leak
- **Max memory policy:** `volatile-lru` or `allkeys-lru`

```redis
CONFIG SET maxmemory 2gb
CONFIG SET maxmemory-policy volatile-lru
```

## Serialization Schema

```json
{
  "_v": 2,           // Schema version - REQUIRED
  "_t": 1702900800,  // Cached at timestamp
  "data": { ... }
}
```

On version mismatch → treat as cache miss, refetch.

## Security

- **ACLs:** Separate users per service with minimal permissions
- **PII:** Never cache raw PII without encryption
- **TLS:** Mandatory in production

```redis
ACL SETUSER api-service on >password ~prod:api:* +get +set +del +expire
```

## Observability

| Metric | Alert Threshold |
|--------|-----------------|
| Memory used | >80% maxmemory |
| Connected clients | >80% maxclients |
| Keyspace misses | >50% of ops |
| Evicted keys | Any (investigate) |
| Slowlog entries | >10/min |

```redis
INFO memory
INFO stats
SLOWLOG GET 10
```

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| No env prefix in keys | Production/staging data collision | Always `{env}:` prefix |
| KEYS command in production | Blocks Redis, O(N) scan | Use SCAN with cursor |
| No TTL on cache keys | Memory grows unbounded | Every key needs expiration |
| Pub/Sub for queues | Messages lost if no subscribers | Use Streams for guaranteed delivery |
| JSON in Hash fields | Double serialization | Use String for full objects, Hash for partial access |
| MULTI without hash tags | Cross-slot errors in Cluster | All keys in transaction need same `{tag}` |

## Checklist

- [ ] Key naming follows `{env}:{app}:{entity}:{id}` format
- [ ] Related keys use hash tags `{entity:id}:*`
- [ ] All keys have TTL (no unbounded growth)
- [ ] Cache pattern documented (aside/through/behind)
- [ ] Circuit breaker + retry + fallback implemented
- [ ] Schema versioning in cached values
- [ ] ACLs configured per service
- [ ] Memory alerts configured
- [ ] No KEYS command (use SCAN instead)
- [ ] Pipeline for >3 operations
