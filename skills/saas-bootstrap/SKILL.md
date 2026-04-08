---
name: saas-bootstrap
description: "Use when starting a new SaaS project from scratch, bootstrapping a production-ready monorepo with Stripe billing, authentication, and AI services. Triggers on: novo saas, bootstrap saas, criar projeto saas, new saas project, scaffold saas, production-ready saas, saas from scratch, monorepo saas, start new project, iniciar projeto."
version: 1.0.0
author: gustavo
tags: [saas, bootstrap, monorepo, fullstack]
---

# SaaS Bootstrap — Production-Ready from Day One

Bootstrap um SaaS completo com monorepo Turborepo, Next.js 15, tRPC, Drizzle ORM, Auth.js v5, Stripe billing, FastAPI AI service, e PageShell UI — tudo com pipeline CI/CD de 7 estágios.

<HARD-GATE>
Execute TODAS as fases em ordem (Discovery → Pre-Flight → Phases 1-6). Cada fase tem um checklist de validação que DEVE passar antes de seguir para a próxima. NÃO pule fases. NÃO comece a próxima fase sem validar a anterior.
</HARD-GATE>

## Phase 0: Product Discovery

**ANTES de qualquer decisão técnica**, entenda o produto. Faça estas perguntas UMA POR VEZ:

### 0.1 Problema & Público

1. **Qual problema esse SaaS resolve?** (1-2 frases)
2. **Quem é o usuário principal?** (persona: dev, dentista, PME, etc.)
3. **Existe concorrência direta?** (se sim, qual o diferencial)

### 0.2 MVP & Features

4. **Quais são as 3-5 features core do MVP?** (o mínimo para validar)
5. **O produto precisa de IA?** Se sim, para quê? (geração de texto, análise de imagem, recomendações, etc.)
6. **Modelo de negócio:** SaaS com planos fixos? Usage-based? Freemium? Marketplace?

### 0.3 Requisitos Técnicos (derivados do produto)

7. **Precisa de real-time?** (chat, notificações live, collaborative editing)
8. **Multi-tenancy?** (cada cliente tem workspace isolado vs. single-tenant)
9. **Compliance especial?** (HIPAA, LGPD estrita, PCI-DSS, SOC2)
10. **Volume esperado?** (dezenas, milhares, ou milhões de usuários no primeiro ano)

### 0.4 Adaptar Stack com Base no Discovery

Com base nas respostas, ajustar o scaffold:

| Requisito | Adaptação |
|-----------|-----------|
| Real-time necessário | Adicionar Pusher/Ably ou WebSocket server |
| Multi-tenancy | Schema com `organizationId` em todas as tabelas, org switcher no UI |
| HIPAA/compliance pesado | Audit logging, encryption at rest, BAA com providers |
| Alto volume (>100k users) | Redis caching layer, connection pooling, CDN config |
| Sem IA | Pular FastAPI service, remover ai router |
| Marketplace/platform | Adicionar Stripe Connect, seller onboarding |

**Se o usuário já chegar com uma descrição clara do produto ou um plano, extraia as respostas do texto e confirme antes de prosseguir.** Não force perguntas que já foram respondidas.

---

## Stack Canônica

| Camada | Tecnologia | Versão Mínima |
|--------|-----------|---------------|
| Framework | Next.js (App Router) | 15+ |
| API | tRPC | v11 |
| ORM | Drizzle ORM | latest |
| Database | PostgreSQL (Neon) | 16+ |
| Auth | Auth.js (NextAuth) | v5 |
| Billing | Stripe | latest SDK |
| AI Service | FastAPI (Python) | 0.100+ |
| UI | @parisgroup-ai/pageshell + Tailwind + shadcn/ui | latest |
| Monorepo | Turborepo + pnpm | latest |
| Deploy | Vercel (web) + Railway/Fly.io (AI) | — |
| CI/CD | GitHub Actions | — |

## Pre-Flight: Coletar Informações Técnicas

Após o Product Discovery, coletar os dados técnicos para o scaffold:

1. **Nome do projeto** (kebab-case, ex: `my-saas-app`)
2. **OAuth providers desejados** (Google, GitHub, ou ambos — default: ambos)
3. **Planos de pricing** (nomes e preços, ou default: Free/$0, Pro/$29, Enterprise/$99 — adaptar com base no modelo de negócio do Discovery)
4. **Domínio de produção** (se já tem, ou placeholder)
5. **Repositório GitHub** (org/repo, para CI/CD)

Use valores sensatos como default quando o usuário não especificar. A descrição e features de IA já vêm do Discovery.

---

## Phase 1: Project Init

### 1.1 Criar Monorepo Turborepo

```bash
# Criar diretório e inicializar
mkdir {project-name} && cd {project-name}
pnpm init
git init
```

### 1.2 pnpm-workspace.yaml

```yaml
packages:
  - "apps/*"
  - "packages/*"
  - "tooling/*"
```

### 1.3 turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "test:integration": {
      "dependsOn": ["^build"]
    },
    "db:push": {
      "cache": false
    },
    "db:migrate": {
      "cache": false
    }
  }
}
```

### 1.4 Root package.json

```json
{
  "name": "{project-name}",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "type-check": "turbo type-check",
    "test": "turbo test",
    "test:integration": "turbo test:integration",
    "db:push": "turbo db:push --filter=@{project-name}/db",
    "db:migrate": "turbo db:migrate --filter=@{project-name}/db",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md}\""
  },
  "devDependencies": {
    "prettier": "^3.0.0",
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0",
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### 1.5 .env.example

```env
# Database
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/{project-name}"

# Auth.js
AUTH_SECRET="generate-with-openssl-rand-base64-32"
AUTH_URL="http://localhost:3000"

# OAuth Providers
AUTH_GOOGLE_ID=""
AUTH_GOOGLE_SECRET=""
AUTH_GITHUB_ID=""
AUTH_GITHUB_SECRET=""

# Stripe
STRIPE_SECRET_KEY=""
STRIPE_PUBLISHABLE_KEY=""
STRIPE_WEBHOOK_SECRET=""

# AI Service
AI_SERVICE_URL="http://localhost:8000"
AI_SERVICE_API_KEY="dev-api-key-change-in-production"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

### 1.6 docker-compose.yml (Dev Environment)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: {project-name}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  stripe-cli:
    image: stripe/stripe-cli:latest
    command: listen --forward-to http://host.docker.internal:3000/api/stripe/webhook
    environment:
      STRIPE_API_KEY: ${STRIPE_SECRET_KEY}

volumes:
  postgres_data:
```

### 1.7 Shared Configs

**tooling/ts-config/base.json:**
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "bundler",
    "module": "esnext",
    "target": "es2022",
    "lib": ["es2022", "dom", "dom.iterable"],
    "jsx": "react-jsx",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "incremental": true,
    "noUncheckedIndexedAccess": true
  },
  "exclude": ["node_modules"]
}
```

**tooling/ts-config/nextjs.json:**
```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }],
    "module": "esnext",
    "moduleResolution": "bundler",
    "allowJs": true,
    "noEmit": true
  }
}
```

**tooling/eslint-config/base.js:**
```javascript
/** @type {import("eslint").Linter.Config} */
module.exports = {
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  rules: {
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    "@typescript-eslint/no-explicit-any": "warn",
  },
  ignorePatterns: ["dist/", ".next/", "node_modules/"],
};
```

### 1.8 .gitignore

```
node_modules/
.next/
dist/
.turbo/
*.env.local
.env
!.env.example
.DS_Store
*.tsbuildinfo
coverage/
__pycache__/
*.pyc
.venv/
```

### 1.9 CLAUDE.md (Project AI Context)

```markdown
# {Project Name}

## Stack
- Monorepo: Turborepo + pnpm
- Web: Next.js 15 (App Router) + tRPC v11 + Drizzle ORM
- Auth: Auth.js v5 (JWT strategy)
- Billing: Stripe (subscriptions + usage-based metering)
- AI: FastAPI microservice
- UI: @parisgroup-ai/pageshell + Tailwind + shadcn/ui
- DB: PostgreSQL (Neon in production)

## Structure
- apps/web/ — Next.js application
- apps/ai-service/ — FastAPI Python service
- packages/api/ — tRPC routers (shared)
- packages/db/ — Drizzle schemas and migrations
- packages/auth/ — Auth.js configuration
- packages/stripe/ — Stripe integration
- packages/ui/ — Shared UI components (PageShell)

## Commands
- pnpm dev — Start all services
- pnpm build — Build all packages
- pnpm test — Run unit tests
- pnpm db:push — Push schema to database
- pnpm db:migrate — Run migrations

## Conventions
- Feature-based organization inside packages
- tRPC routers are thin — business logic in use cases
- All money values use NUMERIC(12,2) in DB
- Timestamps always UTC with timezone
- Snake_case for DB columns, camelCase for TypeScript
```

### Phase 1 Validation

```bash
# Verificar estrutura criada
ls -la apps/ packages/ tooling/
# Verificar pnpm workspace
pnpm install  # Deve resolver sem erros
# Verificar turbo
pnpm turbo --dry build
```

---

## Phase 2: Database & ORM

### 2.1 packages/db/package.json

```json
{
  "name": "@{project-name}/db",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./schema": "./src/schema/index.ts",
    "./client": "./src/client.ts"
  },
  "scripts": {
    "db:push": "drizzle-kit push",
    "db:migrate": "drizzle-kit migrate",
    "db:generate": "drizzle-kit generate",
    "db:studio": "drizzle-kit studio",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "drizzle-orm": "^0.36.0",
    "@neondatabase/serverless": "^0.10.0",
    "postgres": "^3.4.0"
  },
  "devDependencies": {
    "drizzle-kit": "^0.30.0",
    "typescript": "^5.5.0",
    "@{project-name}/tsconfig": "workspace:*"
  }
}
```

### 2.2 drizzle.config.ts

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/schema",
  out: "./src/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### 2.3 packages/db/src/client.ts

```typescript
import { drizzle } from "drizzle-orm/neon-serverless";
import { Pool } from "@neondatabase/serverless";
import * as schema from "./schema";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export const db = drizzle(pool, { schema });
export type Database = typeof db;
```

### 2.4 packages/db/src/schema/users.ts

```typescript
import { pgTable, text, timestamp, boolean } from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

export const users = pgTable("users", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  name: text("name"),
  email: text("email").notNull().unique(),
  emailVerified: timestamp("email_verified", { mode: "date" }),
  image: text("image"),
  role: text("role", { enum: ["user", "admin"] })
    .default("user")
    .notNull(),
  stripeCustomerId: text("stripe_customer_id").unique(),
  createdAt: timestamp("created_at", { mode: "date" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: "date" }).defaultNow().notNull(),
});

export const accounts = pgTable("accounts", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  userId: text("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  type: text("type").notNull(),
  provider: text("provider").notNull(),
  providerAccountId: text("provider_account_id").notNull(),
  refreshToken: text("refresh_token"),
  accessToken: text("access_token"),
  expiresAt: timestamp("expires_at", { mode: "date" }),
  tokenType: text("token_type"),
  scope: text("scope"),
  idToken: text("id_token"),
});

export const sessions = pgTable("sessions", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  sessionToken: text("session_token").notNull().unique(),
  userId: text("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  expires: timestamp("expires", { mode: "date" }).notNull(),
});

export const verificationTokens = pgTable("verification_tokens", {
  identifier: text("identifier").notNull(),
  token: text("token").notNull().unique(),
  expires: timestamp("expires", { mode: "date" }).notNull(),
});

export const usersRelations = relations(users, ({ many }) => ({
  accounts: many(accounts),
  subscriptions: many(subscriptions),
}));

// Forward reference — defined in subscriptions.ts
import { subscriptions } from "./subscriptions";
```

### 2.5 packages/db/src/schema/subscriptions.ts

```typescript
import {
  pgTable,
  text,
  timestamp,
  boolean,
  integer,
  jsonb,
  numeric,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";
import { users } from "./users";

export const subscriptionPlans = pgTable("subscription_plans", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  stripePriceIdMonthly: text("stripe_price_id_monthly"),
  stripePriceIdYearly: text("stripe_price_id_yearly"),
  stripeMeteredPriceId: text("stripe_metered_price_id"),
  priceMonthly: numeric("price_monthly", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  priceYearly: numeric("price_yearly", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  features: jsonb("features").$type<string[]>().default([]),
  limits: jsonb("limits")
    .$type<Record<string, number>>()
    .default({}),
  sortOrder: integer("sort_order").default(0),
  isActive: boolean("is_active").default(true).notNull(),
  createdAt: timestamp("created_at", { mode: "date" }).defaultNow().notNull(),
});

export const subscriptions = pgTable("subscriptions", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  userId: text("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  planId: text("plan_id")
    .notNull()
    .references(() => subscriptionPlans.id),
  stripeSubscriptionId: text("stripe_subscription_id").unique(),
  stripeCurrentPeriodStart: timestamp("stripe_current_period_start", {
    mode: "date",
  }),
  stripeCurrentPeriodEnd: timestamp("stripe_current_period_end", {
    mode: "date",
  }),
  status: text("status", {
    enum: [
      "active",
      "canceled",
      "past_due",
      "trialing",
      "incomplete",
      "incomplete_expired",
      "unpaid",
    ],
  })
    .default("active")
    .notNull(),
  cancelAtPeriodEnd: boolean("cancel_at_period_end").default(false),
  createdAt: timestamp("created_at", { mode: "date" }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { mode: "date" }).defaultNow().notNull(),
});

export const usageRecords = pgTable("usage_records", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  userId: text("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  subscriptionId: text("subscription_id").references(() => subscriptions.id),
  type: text("type").notNull(),
  quantity: integer("quantity").notNull().default(1),
  stripeUsageRecordId: text("stripe_usage_record_id"),
  metadata: jsonb("metadata"),
  createdAt: timestamp("created_at", { mode: "date" }).defaultNow().notNull(),
});

export const subscriptionsRelations = relations(subscriptions, ({ one }) => ({
  user: one(users, {
    fields: [subscriptions.userId],
    references: [users.id],
  }),
  plan: one(subscriptionPlans, {
    fields: [subscriptions.planId],
    references: [subscriptionPlans.id],
  }),
}));
```

### 2.6 packages/db/src/schema/index.ts

```typescript
export * from "./users";
export * from "./subscriptions";
```

### 2.7 packages/db/src/index.ts

```typescript
export { db, type Database } from "./client";
export * from "./schema";
```

### 2.8 Seed Data (Plans)

```typescript
// packages/db/src/seed.ts
import { db } from "./client";
import { subscriptionPlans } from "./schema";

const defaultPlans = [
  {
    id: "free",
    name: "Free",
    description: "Get started for free",
    priceMonthly: "0",
    priceYearly: "0",
    features: ["5 AI generations/month", "Basic support", "1 project"],
    limits: { aiGenerations: 5, projects: 1 },
    sortOrder: 0,
  },
  {
    id: "pro",
    name: "Pro",
    description: "For growing teams",
    priceMonthly: "29",
    priceYearly: "290",
    features: [
      "100 AI generations/month",
      "Priority support",
      "Unlimited projects",
      "Advanced analytics",
    ],
    limits: { aiGenerations: 100, projects: -1 },
    sortOrder: 1,
  },
  {
    id: "enterprise",
    name: "Enterprise",
    description: "For large organizations",
    priceMonthly: "99",
    priceYearly: "990",
    features: [
      "Unlimited AI generations",
      "Dedicated support",
      "Unlimited projects",
      "Custom integrations",
      "SLA guarantee",
    ],
    limits: { aiGenerations: -1, projects: -1 },
    sortOrder: 2,
  },
];

async function seed() {
  console.log("Seeding subscription plans...");
  for (const plan of defaultPlans) {
    await db
      .insert(subscriptionPlans)
      .values(plan)
      .onConflictDoUpdate({
        target: subscriptionPlans.id,
        set: { ...plan },
      });
  }
  console.log("Done seeding.");
}

seed().catch(console.error);
```

### Phase 2 Validation

```bash
docker compose up -d postgres          # Start PostgreSQL
pnpm --filter @{project-name}/db db:push  # Push schema
pnpm --filter @{project-name}/db type-check
# Run seed: npx tsx packages/db/src/seed.ts
```

---

## Phase 3: Authentication

### 3.1 packages/auth/package.json

```json
{
  "name": "@{project-name}/auth",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts"
  },
  "dependencies": {
    "next-auth": "^5.0.0",
    "@auth/drizzle-adapter": "^1.0.0",
    "@{project-name}/db": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@{project-name}/tsconfig": "workspace:*"
  }
}
```

### 3.2 packages/auth/src/index.ts

```typescript
import NextAuth from "next-auth";
import Google from "next-auth/providers/google";
import GitHub from "next-auth/providers/github";
import Resend from "next-auth/providers/resend";
import { DrizzleAdapter } from "@auth/drizzle-adapter";
import { db } from "@{project-name}/db/client";
import { users, accounts, sessions, verificationTokens } from "@{project-name}/db/schema";
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: DrizzleAdapter(db, {
    usersTable: users,
    accountsTable: accounts,
    sessionsTable: sessions,
    verificationTokensTable: verificationTokens,
  }),
  session: { strategy: "jwt" },
  pages: {
    signIn: "/login",
    error: "/login",
  },
  providers: [
    Google({
      clientId: process.env.AUTH_GOOGLE_ID,
      clientSecret: process.env.AUTH_GOOGLE_SECRET,
    }),
    GitHub({
      clientId: process.env.AUTH_GITHUB_ID,
      clientSecret: process.env.AUTH_GITHUB_SECRET,
    }),
    Resend({
      from: process.env.AUTH_RESEND_FROM ?? "noreply@example.com",
    }),
  ],
  callbacks: {
    async jwt({ token, user, trigger }) {
      if (user) {
        token.id = user.id;
        token.role = (user as any).role ?? "user";

        // Create Stripe customer on first login
        const dbUser = await db.query.users.findFirst({
          where: (u, { eq }) => eq(u.id, user.id!),
        });

        if (dbUser && !dbUser.stripeCustomerId) {
          const customer = await stripe.customers.create({
            email: user.email!,
            name: user.name ?? undefined,
            metadata: { userId: user.id! },
          });

          await db
            .update(users)
            .set({ stripeCustomerId: customer.id })
            .where(eq(users.id, user.id!));

          token.stripeCustomerId = customer.id;
        } else {
          token.stripeCustomerId = dbUser?.stripeCustomerId;
        }
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        session.user.role = token.role as string;
        session.user.stripeCustomerId = token.stripeCustomerId as string;
      }
      return session;
    },
  },
});

// Import for the update query
import { eq } from "drizzle-orm";
```

### 3.3 Type Augmentation

```typescript
// packages/auth/src/types.ts
import { DefaultSession } from "next-auth";

declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      role: string;
      stripeCustomerId: string;
    } & DefaultSession["user"];
  }
}
```

### 3.4 Middleware (apps/web/src/middleware.ts)

```typescript
import { auth } from "@{project-name}/auth";

export default auth((req) => {
  const { nextUrl, auth: session } = req;
  const isLoggedIn = !!session?.user;

  const isAuthRoute = nextUrl.pathname.startsWith("/login") ||
    nextUrl.pathname.startsWith("/register");
  const isProtectedRoute = nextUrl.pathname.startsWith("/dashboard") ||
    nextUrl.pathname.startsWith("/settings") ||
    nextUrl.pathname.startsWith("/billing");
  const isApiRoute = nextUrl.pathname.startsWith("/api");

  // Redirect logged-in users away from auth pages
  if (isAuthRoute && isLoggedIn) {
    return Response.redirect(new URL("/dashboard", nextUrl));
  }

  // Protect dashboard routes
  if (isProtectedRoute && !isLoggedIn) {
    const callbackUrl = encodeURIComponent(nextUrl.pathname + nextUrl.search);
    return Response.redirect(
      new URL(`/login?callbackUrl=${callbackUrl}`, nextUrl)
    );
  }

  return undefined;
});

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|public/).*)",
  ],
};
```

### Phase 3 Validation

```bash
pnpm --filter @{project-name}/auth type-check
# Test: navigate to /dashboard → should redirect to /login
# Test: login with OAuth → should redirect to /dashboard
# Test: check Stripe dashboard → customer should be created
```

---

## Phase 4: Billing (Stripe)

### 4.1 packages/stripe/package.json

```json
{
  "name": "@{project-name}/stripe",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./client": "./src/client.ts",
    "./webhooks": "./src/webhooks.ts",
    "./checkout": "./src/checkout.ts",
    "./portal": "./src/portal.ts",
    "./metered": "./src/metered.ts"
  },
  "dependencies": {
    "stripe": "^17.0.0",
    "@{project-name}/db": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@{project-name}/tsconfig": "workspace:*"
  }
}
```

### 4.2 packages/stripe/src/client.ts

```typescript
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2024-12-18.acacia",
  typescript: true,
});
```

### 4.3 packages/stripe/src/checkout.ts

```typescript
import { stripe } from "./client";

interface CreateCheckoutParams {
  customerId: string;
  priceId: string;
  successUrl: string;
  cancelUrl: string;
  trialDays?: number;
}

export async function createCheckoutSession({
  customerId,
  priceId,
  successUrl,
  cancelUrl,
  trialDays,
}: CreateCheckoutParams) {
  return stripe.checkout.sessions.create({
    customer: customerId,
    mode: "subscription",
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: cancelUrl,
    subscription_data: trialDays
      ? { trial_period_days: trialDays }
      : undefined,
    allow_promotion_codes: true,
  });
}
```

### 4.4 packages/stripe/src/portal.ts

```typescript
import { stripe } from "./client";

export async function createPortalSession(
  customerId: string,
  returnUrl: string
) {
  return stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: returnUrl,
  });
}
```

### 4.5 packages/stripe/src/metered.ts

```typescript
import { stripe } from "./client";
import { db } from "@{project-name}/db/client";
import { usageRecords, subscriptions } from "@{project-name}/db/schema";
import { eq, and } from "drizzle-orm";

interface ReportUsageParams {
  userId: string;
  type: string;
  quantity?: number;
  metadata?: Record<string, unknown>;
}

export async function reportUsage({
  userId,
  type,
  quantity = 1,
  metadata,
}: ReportUsageParams) {
  // Find active subscription with metered component
  const subscription = await db.query.subscriptions.findFirst({
    where: and(
      eq(subscriptions.userId, userId),
      eq(subscriptions.status, "active")
    ),
    with: { plan: true },
  });

  if (!subscription?.stripeSubscriptionId) {
    throw new Error("No active subscription found");
  }

  // Get subscription items from Stripe
  const stripeSubscription = await stripe.subscriptions.retrieve(
    subscription.stripeSubscriptionId,
    { expand: ["items.data"] }
  );

  const meteredItem = stripeSubscription.items.data.find(
    (item) => item.price.recurring?.usage_type === "metered"
  );

  let stripeUsageRecordId: string | undefined;

  if (meteredItem) {
    const usageRecord = await stripe.subscriptionItems.createUsageRecord(
      meteredItem.id,
      {
        quantity,
        timestamp: Math.floor(Date.now() / 1000),
        action: "increment",
      }
    );
    stripeUsageRecordId = usageRecord.id;
  }

  // Always record locally
  await db.insert(usageRecords).values({
    userId,
    subscriptionId: subscription.id,
    type,
    quantity,
    stripeUsageRecordId,
    metadata,
  });
}
```

### 4.6 packages/stripe/src/webhooks.ts

```typescript
import Stripe from "stripe";
import { stripe } from "./client";
import { db } from "@{project-name}/db/client";
import {
  subscriptions,
  subscriptionPlans,
  users,
} from "@{project-name}/db/schema";
import { eq } from "drizzle-orm";

export async function handleWebhookEvent(event: Stripe.Event) {
  switch (event.type) {
    case "checkout.session.completed":
      return handleCheckoutCompleted(
        event.data.object as Stripe.Checkout.Session
      );

    case "customer.subscription.updated":
      return handleSubscriptionUpdated(
        event.data.object as Stripe.Subscription
      );

    case "customer.subscription.deleted":
      return handleSubscriptionDeleted(
        event.data.object as Stripe.Subscription
      );

    case "invoice.payment_failed":
      return handlePaymentFailed(event.data.object as Stripe.Invoice);

    case "invoice.paid":
      return handleInvoicePaid(event.data.object as Stripe.Invoice);

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
}

async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  if (session.mode !== "subscription" || !session.subscription) return;

  const stripeSubscription = await stripe.subscriptions.retrieve(
    session.subscription as string
  );

  const customerId = session.customer as string;

  // Find user by Stripe customer ID
  const user = await db.query.users.findFirst({
    where: eq(users.stripeCustomerId, customerId),
  });

  if (!user) {
    console.error(`No user found for Stripe customer: ${customerId}`);
    return;
  }

  // Map Stripe price to plan
  const priceId = stripeSubscription.items.data[0]?.price.id;
  const plan = await db.query.subscriptionPlans.findFirst({
    where: (p, { or, eq }) =>
      or(
        eq(p.stripePriceIdMonthly, priceId!),
        eq(p.stripePriceIdYearly, priceId!)
      ),
  });

  if (!plan) {
    console.error(`No plan found for price: ${priceId}`);
    return;
  }

  await db
    .insert(subscriptions)
    .values({
      userId: user.id,
      planId: plan.id,
      stripeSubscriptionId: stripeSubscription.id,
      stripeCurrentPeriodStart: new Date(
        stripeSubscription.current_period_start * 1000
      ),
      stripeCurrentPeriodEnd: new Date(
        stripeSubscription.current_period_end * 1000
      ),
      status: stripeSubscription.status,
    })
    .onConflictDoUpdate({
      target: subscriptions.stripeSubscriptionId,
      set: {
        planId: plan.id,
        status: stripeSubscription.status,
        stripeCurrentPeriodEnd: new Date(
          stripeSubscription.current_period_end * 1000
        ),
        updatedAt: new Date(),
      },
    });
}

async function handleSubscriptionUpdated(sub: Stripe.Subscription) {
  await db
    .update(subscriptions)
    .set({
      status: sub.status,
      cancelAtPeriodEnd: sub.cancel_at_period_end,
      stripeCurrentPeriodEnd: new Date(sub.current_period_end * 1000),
      updatedAt: new Date(),
    })
    .where(eq(subscriptions.stripeSubscriptionId, sub.id));
}

async function handleSubscriptionDeleted(sub: Stripe.Subscription) {
  await db
    .update(subscriptions)
    .set({
      status: "canceled",
      updatedAt: new Date(),
    })
    .where(eq(subscriptions.stripeSubscriptionId, sub.id));
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  if (!invoice.subscription) return;
  await db
    .update(subscriptions)
    .set({
      status: "past_due",
      updatedAt: new Date(),
    })
    .where(
      eq(subscriptions.stripeSubscriptionId, invoice.subscription as string)
    );
}

async function handleInvoicePaid(invoice: Stripe.Invoice) {
  if (!invoice.subscription) return;
  await db
    .update(subscriptions)
    .set({
      status: "active",
      updatedAt: new Date(),
    })
    .where(
      eq(subscriptions.stripeSubscriptionId, invoice.subscription as string)
    );
}

export function constructWebhookEvent(
  body: string,
  signature: string
): Stripe.Event {
  return stripe.webhooks.constructEvent(
    body,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET!
  );
}
```

### 4.7 Stripe Webhook API Route (apps/web/src/app/api/stripe/webhook/route.ts)

```typescript
import { NextRequest, NextResponse } from "next/server";
import { constructWebhookEvent, handleWebhookEvent } from "@{project-name}/stripe/webhooks";

export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = req.headers.get("stripe-signature");

  if (!signature) {
    return NextResponse.json({ error: "Missing signature" }, { status: 400 });
  }

  try {
    const event = constructWebhookEvent(body, signature);
    await handleWebhookEvent(event);
    return NextResponse.json({ received: true });
  } catch (err) {
    console.error("Webhook error:", err);
    return NextResponse.json(
      { error: "Webhook handler failed" },
      { status: 400 }
    );
  }
}

// Disable Next.js body parsing for raw body access
export const config = {
  api: { bodyParser: false },
};
```

### 4.8 packages/stripe/src/index.ts

```typescript
export { stripe } from "./client";
export { createCheckoutSession } from "./checkout";
export { createPortalSession } from "./portal";
export { reportUsage } from "./metered";
export { handleWebhookEvent, constructWebhookEvent } from "./webhooks";
```

### Phase 4 Validation

```bash
pnpm --filter @{project-name}/stripe type-check
# Test with Stripe CLI:
# stripe listen --forward-to localhost:3000/api/stripe/webhook
# stripe trigger checkout.session.completed
```

---

## Phase 5: tRPC + UI & Pages

### 5.1 packages/api/ — tRPC Setup

**packages/api/src/trpc.ts:**
```typescript
import { initTRPC, TRPCError } from "@trpc/server";
import superjson from "superjson";
import { ZodError } from "zod";
import type { Session } from "next-auth";
import type { Database } from "@{project-name}/db";

export interface Context {
  db: Database;
  session: Session | null;
}

const t = initTRPC.context<Context>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: "UNAUTHORIZED" });
  }
  return next({
    ctx: {
      session: { ...ctx.session, user: ctx.session.user },
    },
  });
});

export const adminProcedure = protectedProcedure.use(({ ctx, next }) => {
  if (ctx.session.user.role !== "admin") {
    throw new TRPCError({ code: "FORBIDDEN" });
  }
  return next({ ctx });
});
```

**packages/api/src/routers/billing.ts:**
```typescript
import { z } from "zod";
import { router, protectedProcedure } from "../trpc";
import { createCheckoutSession } from "@{project-name}/stripe/checkout";
import { createPortalSession } from "@{project-name}/stripe/portal";
import { subscriptions, subscriptionPlans } from "@{project-name}/db/schema";
import { eq } from "drizzle-orm";

export const billingRouter = router({
  getPlans: protectedProcedure.query(async ({ ctx }) => {
    return ctx.db.query.subscriptionPlans.findMany({
      where: eq(subscriptionPlans.isActive, true),
      orderBy: (p, { asc }) => [asc(p.sortOrder)],
    });
  }),

  getSubscription: protectedProcedure.query(async ({ ctx }) => {
    return ctx.db.query.subscriptions.findFirst({
      where: eq(subscriptions.userId, ctx.session.user.id),
      with: { plan: true },
      orderBy: (s, { desc }) => [desc(s.createdAt)],
    });
  }),

  createCheckout: protectedProcedure
    .input(z.object({ priceId: z.string() }))
    .mutation(async ({ ctx, input }) => {
      const session = await createCheckoutSession({
        customerId: ctx.session.user.stripeCustomerId,
        priceId: input.priceId,
        successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/billing?success=true`,
        cancelUrl: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
      });
      return { url: session.url };
    }),

  createPortal: protectedProcedure.mutation(async ({ ctx }) => {
    const session = await createPortalSession(
      ctx.session.user.stripeCustomerId,
      `${process.env.NEXT_PUBLIC_APP_URL}/billing`
    );
    return { url: session.url };
  }),
});
```

**packages/api/src/routers/user.ts:**
```typescript
import { z } from "zod";
import { router, protectedProcedure } from "../trpc";
import { users } from "@{project-name}/db/schema";
import { eq } from "drizzle-orm";

export const userRouter = router({
  me: protectedProcedure.query(async ({ ctx }) => {
    return ctx.db.query.users.findFirst({
      where: eq(users.id, ctx.session.user.id),
    });
  }),

  update: protectedProcedure
    .input(z.object({ name: z.string().min(1).max(100).optional() }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db
        .update(users)
        .set({ ...input, updatedAt: new Date() })
        .where(eq(users.id, ctx.session.user.id))
        .returning();
    }),
});
```

**packages/api/src/routers/ai.ts:**
```typescript
import { z } from "zod";
import { router, protectedProcedure } from "../trpc";
import { reportUsage } from "@{project-name}/stripe/metered";

const AI_SERVICE_URL = process.env.AI_SERVICE_URL ?? "http://localhost:8000";
const AI_SERVICE_API_KEY = process.env.AI_SERVICE_API_KEY ?? "";

export const aiRouter = router({
  generate: protectedProcedure
    .input(z.object({ prompt: z.string().min(1).max(10000) }))
    .mutation(async ({ ctx, input }) => {
      const response = await fetch(`${AI_SERVICE_URL}/api/v1/generate`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${AI_SERVICE_API_KEY}`,
        },
        body: JSON.stringify({
          prompt: input.prompt,
          userId: ctx.session.user.id,
        }),
        signal: AbortSignal.timeout(30_000),
      });

      if (!response.ok) {
        throw new Error(`AI service error: ${response.status}`);
      }

      const result = await response.json();

      // Report usage for metered billing
      await reportUsage({
        userId: ctx.session.user.id,
        type: "ai_generation",
        quantity: 1,
        metadata: { prompt: input.prompt.slice(0, 100) },
      });

      return result;
    }),
});
```

**packages/api/src/root.ts:**
```typescript
import { router } from "./trpc";
import { userRouter } from "./routers/user";
import { billingRouter } from "./routers/billing";
import { aiRouter } from "./routers/ai";

export const appRouter = router({
  user: userRouter,
  billing: billingRouter,
  ai: aiRouter,
});

export type AppRouter = typeof appRouter;
```

### 5.2 Next.js App — tRPC Client

**apps/web/src/lib/trpc.ts:**
```typescript
import { createTRPCReact } from "@trpc/react-query";
import type { AppRouter } from "@{project-name}/api/root";

export const trpc = createTRPCReact<AppRouter>();
```

**apps/web/src/app/api/trpc/[trpc]/route.ts:**
```typescript
import { fetchRequestHandler } from "@trpc/server/adapters/fetch";
import { appRouter } from "@{project-name}/api/root";
import { auth } from "@{project-name}/auth";
import { db } from "@{project-name}/db";

const handler = async (req: Request) => {
  const session = await auth();
  return fetchRequestHandler({
    endpoint: "/api/trpc",
    req,
    router: appRouter,
    createContext: () => ({ db, session }),
  });
};

export { handler as GET, handler as POST };
```

### 5.3 PageShell Setup

**packages/ui/package.json:**
```json
{
  "name": "@{project-name}/ui",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./pageshell": "./src/pageshell.ts"
  },
  "dependencies": {
    "@parisgroup-ai/pageshell": "latest",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@{project-name}/tsconfig": "workspace:*"
  }
}
```

**packages/ui/src/pageshell.ts:**
```typescript
// Re-export PageShell composites used in this project
export {
  DashboardPage,
  SettingsPage,
  ListPage,
  DetailPage,
  FormPage,
  FormModal,
} from "@parisgroup-ai/pageshell";

// Re-export layout primitives
export { AppLayout, Sidebar, Header } from "@parisgroup-ai/pageshell";
```

### 5.4 Key Pages (examples)

**apps/web/src/app/(dashboard)/dashboard/page.tsx:**
```tsx
import { DashboardPage } from "@{project-name}/ui/pageshell";
import { trpc } from "@/lib/trpc";

export default function Dashboard() {
  const { data: subscription } = trpc.billing.getSubscription.useQuery();
  const { data: user } = trpc.user.me.useQuery();

  return (
    <DashboardPage
      title="Dashboard"
      subtitle={`Welcome back, ${user?.name ?? "there"}`}
      stats={[
        {
          label: "Current Plan",
          value: subscription?.plan?.name ?? "Free",
        },
        {
          label: "AI Credits Used",
          value: "0", // TODO: wire up from usage records
        },
      ]}
    >
      {/* Dashboard content */}
    </DashboardPage>
  );
}
```

**apps/web/src/app/(dashboard)/billing/page.tsx:**
```tsx
import { SettingsPage } from "@{project-name}/ui/pageshell";
import { trpc } from "@/lib/trpc";

export default function BillingPage() {
  const { data: subscription } = trpc.billing.getSubscription.useQuery();
  const { data: plans } = trpc.billing.getPlans.useQuery();
  const createPortal = trpc.billing.createPortal.useMutation();

  async function handleManageBilling() {
    const { url } = await createPortal.mutateAsync();
    if (url) window.location.href = url;
  }

  return (
    <SettingsPage title="Billing & Subscription">
      {/* Current plan display */}
      {/* Plan comparison cards */}
      {/* Manage billing button */}
    </SettingsPage>
  );
}
```

**apps/web/src/app/(marketing)/pricing/page.tsx:**
```tsx
// Public pricing page with plan cards
// Links to /login if not authenticated, or /billing for checkout
```

### Phase 5 Validation

```bash
pnpm build                    # Full build should pass
pnpm type-check               # Zero type errors
pnpm dev                      # Dev server starts
# Navigate: / → pricing → login → dashboard → billing
```

---

## Phase 6: FastAPI AI Service + DevOps

### 6.1 apps/ai-service/

**apps/ai-service/src/main.py:**
```python
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from .config import settings
from .routers import generate

app = FastAPI(
    title=f"{settings.project_name} AI Service",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.allowed_origin],
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

async def verify_api_key(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    if credentials.credentials != settings.api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return credentials

app.include_router(
    generate.router,
    prefix="/api/v1",
    dependencies=[Depends(verify_api_key)],
)

@app.get("/health")
async def health():
    return {"status": "ok"}
```

**apps/ai-service/src/config.py:**
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    project_name: str = "{project-name}"
    api_key: str = "dev-api-key-change-in-production"
    allowed_origin: str = "http://localhost:3000"

    class Config:
        env_file = ".env"

settings = Settings()
```

**apps/ai-service/src/routers/generate.py:**
```python
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class GenerateRequest(BaseModel):
    prompt: str
    userId: str

class GenerateResponse(BaseModel):
    result: str
    tokens_used: int

@router.post("/generate", response_model=GenerateResponse)
async def generate(request: GenerateRequest):
    # TODO: Replace with actual AI model call
    return GenerateResponse(
        result=f"AI response for: {request.prompt[:50]}...",
        tokens_used=0,
    )
```

**apps/ai-service/Dockerfile:**
```dockerfile
FROM python:3.12-slim AS base
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

RUN adduser --disabled-password --gecos "" appuser
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**apps/ai-service/requirements.txt:**
```
fastapi>=0.100.0
uvicorn[standard]>=0.20.0
pydantic>=2.0.0
pydantic-settings>=2.0.0
```

### 6.2 GitHub Actions — 7-Stage Pipeline

**.github/workflows/ci.yml:**
```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ vars.TURBO_TEAM }}

jobs:
  # ========== Stage 1 & 2: Parallel ==========
  lint:
    name: "Stage 1: Lint & Format"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm format:check

  type-check:
    name: "Stage 2: Type Check"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm type-check

  # ========== Stage 3, 4, 5: Parallel (after 1 & 2) ==========
  unit-tests:
    name: "Stage 3: Unit Tests"
    needs: [lint, type-check]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm test -- --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  integration-tests:
    name: "Stage 4: Integration Tests"
    needs: [lint, type-check]
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    env:
      DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm db:push
      - run: pnpm test:integration

  e2e-tests:
    name: "Stage 5: E2E Tests"
    needs: [lint, type-check]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
      - run: npx playwright install --with-deps
      - run: pnpm exec playwright test
        env:
          DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}

  # ========== Stage 6 & 7: Parallel (after 3, 4, 5) ==========
  security-scan:
    name: "Stage 6: Security Scan"
    needs: [unit-tests, integration-tests, e2e-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm audit --audit-level=high
      - uses: returntocorp/semgrep-action@v1
        with:
          config: p/security-audit

  performance-audit:
    name: "Stage 7: Performance Audit"
    needs: [unit-tests, integration-tests, e2e-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
      - uses: treosh/lighthouse-ci-action@v12
        with:
          configPath: "./lighthouserc.json"
          uploadArtifacts: true
```

### 6.3 lighthouserc.json

```json
{
  "ci": {
    "collect": {
      "startServerCommand": "pnpm --filter web start",
      "startServerReadyPattern": "ready on",
      "url": ["http://localhost:3000", "http://localhost:3000/pricing"]
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.9 }],
        "categories:accessibility": ["error", { "minScore": 0.9 }],
        "categories:best-practices": ["error", { "minScore": 0.9 }],
        "categories:seo": ["warn", { "minScore": 0.8 }],
        "first-contentful-paint": ["warn", { "maxNumericValue": 2000 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.1 }]
      }
    }
  }
}
```

### Phase 6 Validation

```bash
# AI Service
cd apps/ai-service && pip install -r requirements.txt
uvicorn src.main:app --reload     # Health check: curl localhost:8000/health

# Full build
pnpm build                        # All packages build
pnpm type-check                   # Zero errors

# Docker
docker compose up -d              # PostgreSQL + Stripe CLI start

# GitHub Actions (local test with act)
# act -j lint --secret-file .env
```

---

## Post-Bootstrap Checklist

After all 6 phases complete, verify:

- [ ] `pnpm install` — zero errors
- [ ] `pnpm build` — all packages build
- [ ] `pnpm type-check` — zero type errors
- [ ] `pnpm lint` — zero lint errors
- [ ] `docker compose up` — PostgreSQL starts
- [ ] `pnpm dev` — web app starts on :3000
- [ ] Auth flow works (login → dashboard → logout)
- [ ] Stripe checkout creates subscription
- [ ] Webhook handler processes events
- [ ] AI service responds on :8000/health
- [ ] CLAUDE.md accurately describes the project
- [ ] `.env.example` has all required variables
- [ ] `git log` shows clean commit history

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting `"type": "module"` in package.json | All packages must use ESM |
| Hardcoding Stripe price IDs | Use subscription_plans table, never hardcode |
| Missing `onDelete: "cascade"` on user references | Always cascade user deletions |
| Not verifying webhook signatures | ALWAYS use `constructEvent` with secret |
| Exposing STRIPE_SECRET_KEY to client | Only NEXT_PUBLIC_ vars are client-safe |
| Missing CORS on AI service | FastAPI needs explicit CORS middleware |
| Not handling Stripe idempotency | Webhook handlers must be idempotent (upsert) |
| Skipping `--frozen-lockfile` in CI | Always use frozen lockfile in CI |

## Security Checklist

- [ ] All secrets in .env, never committed
- [ ] Stripe webhook signature verified
- [ ] Auth middleware on all protected routes
- [ ] CORS restricted to app domain in production
- [ ] Rate limiting on auth and API endpoints
- [ ] SQL injection prevented (Drizzle ORM parameterizes)
- [ ] CSRF protection via Auth.js
- [ ] Content Security Policy headers
- [ ] Secure HTTP headers (via next.config.ts)
