---
name: security-practices
description: "Implement security best practices including authentication, authorization, input validation, encryption, and OWASP Top 10 protection. Use when handling user data, auth, or sensitive operations. Triggers on: security, authentication, authorization, JWT, OAuth, password, encryption, validation, XSS, SQL injection."
version: 1.1.0
author: gustavo
tags: [security, backend]
---

# Security Practices Skill

## Input Validation

**Never trust user input. Validate everything on the server.**

```typescript
import { z } from 'zod';

const registerSchema = z.object({
  email: z.string().email().max(255).transform(v => v.toLowerCase().trim()),
  password: z.string()
    .min(8)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain number')
    .regex(/[^A-Za-z0-9]/, 'Must contain special character'),
});
```

## Password Security

```typescript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

## JWT Authentication

```typescript
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';

function generateTokens(user) {
  const accessToken = jwt.sign(
    { sub: user.id, type: 'access' },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRY }
  );
  
  const refreshToken = jwt.sign(
    { sub: user.id, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRY }
  );
  
  return { accessToken, refreshToken };
}
```

## SQL Injection Prevention

```typescript
// ❌ VULNERABLE
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ SAFE - Parameterized
const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

## Security Headers

```typescript
import helmet from 'helmet';
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
  },
}));
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // 5 failed attempts
  skipSuccessfulRequests: true,
});

app.use('/api/auth/login', authLimiter);
```

## Environment Variables

```typescript
// Validate at startup
const envSchema = z.object({
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  DATABASE_URL: z.string().url(),
});

const env = envSchema.parse(process.env);
```

## Checklist

- [ ] All input validated on server
- [ ] Parameterized queries only
- [ ] Passwords hashed with bcrypt (12+ rounds)
- [ ] JWT with short expiry + refresh tokens
- [ ] Security headers (Helmet)
- [ ] Rate limiting on auth endpoints
- [ ] CORS properly configured
- [ ] No secrets in code or logs

