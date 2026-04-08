---
name: database-design
description: "Design efficient database schemas with proper indexing, relationships, normalization, and migration strategies. Use when creating or modifying database structures. Triggers on: database schema, tables, migrations, indexes, SQL, queries, data modeling."
version: 1.1.0
author: gustavo
tags: [database, design, sql, schema]
---

# Database Design Skill

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | snake_case, plural | `users`, `order_items` |
| Columns | snake_case | `created_at`, `user_id` |
| Primary Key | `id` | UUID or BIGINT |
| Foreign Key | `{table_singular}_id` | `user_id` |
| Indexes | `idx_{table}_{columns}` | `idx_users_email` |

## Required Columns

Every table MUST have:

```sql
CREATE TABLE example (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Data Types (PostgreSQL)

| Use Case | Type |
|----------|------|
| Primary Key | UUID or BIGINT |
| Text | TEXT or VARCHAR(n) |
| Integer | INTEGER or BIGINT |
| Money | NUMERIC(12,2) |
| Boolean | BOOLEAN |
| Timestamp | TIMESTAMPTZ |
| JSON | JSONB |

## Indexing Strategy

**Always index:**
- Foreign keys
- Columns in WHERE clauses
- Columns in ORDER BY

```sql
-- Composite index (order matters!)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Partial index
CREATE INDEX idx_users_active ON users(email) WHERE status = 'active';
```

## Relationships

```sql
-- One-to-Many
CREATE TABLE books (
  id UUID PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES authors(id) ON DELETE CASCADE
);
CREATE INDEX idx_books_author ON books(author_id);

-- Many-to-Many
CREATE TABLE categories_products (
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  PRIMARY KEY (category_id, product_id)
);
```

## Soft Deletes

```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;
```

## Migration Rules

1. Never modify existing migrations
2. Always include down() for rollbacks
3. Test both directions
4. Use CONCURRENTLY for large table indexes

## Checklist

- [ ] All tables have id, created_at, updated_at
- [ ] Foreign keys are indexed
- [ ] Naming conventions consistent
- [ ] Cascade behavior explicit
- [ ] Migrations reversible

---

## Integração com Reviewer (ADR/PR)

> **Mudanças de schema são decisões estruturais. Use o skill `reviewer` para documentação formal.**

### Quando Acionar o Reviewer

| Mudança | Requer ADR | Motivo |
|---------|------------|--------|
| Nova tabela | ✅ Sim | Impacto arquitetural |
| Alter table (add column) | ⚠️ Depende | Se nullable, não. Se NOT NULL com migration de dados, sim |
| Drop table/column | ✅ Sim | Irreversível, risco de perda de dados |
| Mudança de tipo de coluna | ✅ Sim | Pode causar perda de dados |
| Novo índice em tabela grande | ✅ Sim | Impacto em performance, lock de tabela |
| Mudança em FK/cascade | ✅ Sim | Afeta integridade referencial |
| Nova constraint | ⚠️ Depende | Se pode falhar em dados existentes, sim |

### Fluxo Obrigatório para Migrations

```
1. Identificar mudança de schema
       │
       ▼
2. Mudança é estrutural? ──Não──▶ Apenas executar
       │
      Sim
       │
       ▼
3. Acionar skill `reviewer`
       │
       ▼
4. Criar proposta com:
   - Impacto em dados existentes
   - Tempo estimado de lock
   - Plano de rollback (down migration)
       │
       ▼
5. Aprovação → Gerar ADR
       │
       ▼
6. Implementar migration
       │
       ▼
7. PR com link para ADR
```

### Campos Específicos no ADR de Database

Além do template padrão do reviewer, incluir:

```markdown
## Database-Specific

### Impacto em Dados
- Registros afetados: {{estimativa}}
- Tempo de migration: {{estimativa}}
- Lock de tabela: {{sim/não, duração}}

### Compatibilidade
- Backwards compatible: {{sim/não}}
- Requer deploy coordenado: {{sim/não}}

### Rollback (Down Migration)
\`\`\`sql
{{sql_de_rollback}}
\`\`\`

### Validação Pós-Deploy
\`\`\`sql
-- Query para validar sucesso
{{sql_de_validacao}}
\`\`\`
```

### Convenções de Commit para Migrations

```
[ADR-NNNN] feat(db): add users table

[ADR-NNNN] fix(db): add index on orders.user_id
```

### Red Flags - PARE e Use Reviewer

- [ ] DROP TABLE ou DROP COLUMN
- [ ] ALTER COLUMN com mudança de tipo
- [ ] Migration em tabela com > 1M registros
- [ ] Mudança em constraint de FK
- [ ] Qualquer mudança que não tenha down() funcional
