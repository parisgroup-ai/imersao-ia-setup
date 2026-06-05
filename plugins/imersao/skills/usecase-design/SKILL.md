---
name: usecase-design
description: Use when implementing features in modular Clean Architecture with use cases and thin tRPC routers.
---

# Use Case Design (tRPC + Modules)

## Overview

Use cases encapsulam lógica de negócio na camada `application`. tRPC routers são **thin** - apenas validam input e chamam use cases.

**Estrutura:** `packages/api/src/modules/{module}/application/use-cases/`

## The Iron Law

```
ZERO LÓGICA DE NEGÓCIO NO TRPC ROUTER
```

O critério NÃO é contagem de linhas. É: **pode um dev júnior entender o router em 5 segundos sem conhecer Prisma ou regras de negócio?**

Se a resposta é não, refatore.

## Quick Reference

| Camada | Responsabilidade | Exemplo |
|--------|------------------|---------|
| Router (tRPC) | Validar input, chamar use case | `orderRouter.ts` |
| Use Case | Orquestrar lógica de negócio | `CreateOrderUseCase.ts` |
| Repository Interface | Contrato de acesso a dados | `IOrderRepository.ts` |
| Repository Impl | Implementação (Prisma, etc) | `PrismaOrderRepository.ts` |

## Estrutura de Módulo

```
packages/api/src/modules/orders/
├── application/
│   ├── use-cases/
│   │   ├── CreateOrderUseCase.ts
│   │   └── GetOrderUseCase.ts
│   ├── dtos/
│   │   ├── CreateOrderInput.ts
│   │   └── CreateOrderOutput.ts
│   └── ports/
│       └── IOrderRepository.ts
├── domain/
│   └── Order.ts
├── infrastructure/
│   └── PrismaOrderRepository.ts
└── presentation/
    └── order.router.ts
```

## Padrão de Use Case

```typescript
// application/use-cases/CreateOrderUseCase.ts
export class CreateOrderUseCase {
  constructor(
    private readonly orderRepository: IOrderRepository,
    private readonly productRepository: IProductRepository,
    private readonly userRepository: IUserRepository
  ) {}

  async execute(input: CreateOrderInput): Promise<CreateOrderOutput> {
    // 1. Validar usuário
    const user = await this.userRepository.findById(input.userId);
    if (!user) throw new UserNotFoundError(input.userId);

    // 2. Validar produtos e calcular
    const products = await this.productRepository.findByIds(input.productIds);
    const total = this.calculateTotal(products, input.items);

    // 3. Criar pedido
    const order = Order.create({ userId: user.id, items: input.items, total });
    await this.orderRepository.save(order);

    return { orderId: order.id, total };
  }

  private calculateTotal(products: Product[], items: OrderItem[]): number {
    // lógica de cálculo
  }
}
```

## Padrão de Router (THIN)

```typescript
// presentation/order.router.ts
export const orderRouter = router({
  create: protectedProcedure
    .input(createOrderSchema)
    .mutation(async ({ input, ctx }) => {
      // APENAS isso. Nada mais.
      return ctx.useCases.createOrder.execute(input);
    })
});
```

**Se seu router tem mais que isso, refatore.**

## Interface de Repositório

```typescript
// application/ports/IOrderRepository.ts
export interface IOrderRepository {
  findById(id: string): Promise<Order | null>;
  findByUserId(userId: string): Promise<Order[]>;
  save(order: Order): Promise<void>;
}
```

## Racionalizações Proibidas

| Desculpa | Realidade |
|----------|-----------|
| "É pragmático deixar no router" | Pragmático = use case testável e isolado |
| "Não precisa de tanta abstração" | Interfaces permitem testes e troca de implementação |
| "Vou refatorar depois" | Depois nunca chega. Faça certo agora. |
| "É só uma feature simples" | Features simples viram complexas. Estrutura certa desde o início. |
| "80% do problema resolvido" | 80% = débito técnico acumulando |
| "Sweet spot entre purismo e praticidade" | O sweet spot É seguir a arquitetura |
| "São só 4 linhas, está dentro do limite" | O limite não é linhas, é responsabilidade. Tem lógica? Refatore. |
| "O código já funciona, não tem bug" | Funcionar != arquitetura correta. Débito técnico acumula juros. |
| "Production-ready, sem over-engineering" | Over-engineering é diferente de estrutura correta. Use cases não são over. |

## Red Flags - PARE e Refatore

- [ ] Router com mais de 5 linhas no handler
- [ ] `prisma` usado diretamente no router
- [ ] Lógica de validação de negócio no router
- [ ] Cálculos no router
- [ ] `// TODO: mover para use case` no código
- [ ] Use case recebendo `PrismaClient` diretamente (sem interface)

## Checklist de Implementação

- [ ] Use case criado em `modules/{module}/application/use-cases/`
- [ ] Input/Output DTOs definidos
- [ ] Interface de repositório em `application/ports/`
- [ ] Implementação do repositório em `infrastructure/`
- [ ] Router thin (máximo 5 linhas no handler)
- [ ] Dependências injetadas via interface
- [ ] Use case testável sem banco de dados

## Injeção de Dependências (Context)

```typescript
// packages/api/src/context.ts
export const createContext = () => {
  const prisma = new PrismaClient();

  // Repositories
  const orderRepository = new PrismaOrderRepository(prisma);
  const productRepository = new PrismaProductRepository(prisma);
  const userRepository = new PrismaUserRepository(prisma);

  // Use Cases
  const createOrder = new CreateOrderUseCase(
    orderRepository,
    productRepository,
    userRepository
  );

  return {
    useCases: { createOrder }
  };
};
```

## Quando NÃO Usar Use Case

Em casos muito simples, você pode chamar o repository diretamente via service/context:

- Queries simples de leitura sem lógica
- CRUD trivial sem validações de negócio
- Health checks, status endpoints

**IMPORTANTE:** "Não usar use case" NÃO significa "colocar lógica no router". Significa chamar repository via ctx/service ao invés de use case.

```typescript
// ✅ CORRETO - Query simples sem use case
.query(async ({ ctx }) => ctx.repositories.user.findAll())

// ❌ ERRADO - Lógica no router
.query(async ({ ctx }) => {
  const users = await ctx.prisma.user.findMany();
  return users.filter(u => u.active); // LÓGICA NO ROUTER!
})
```

---

## Integração com Reviewer (ADR/PR)

> **Novos módulos e features complexas são decisões arquiteturais. Use o skill `reviewer` para documentação formal.**

### Quando Acionar o Reviewer

| Mudança | Requer ADR | Motivo |
|---------|------------|--------|
| Novo módulo de domínio | ✅ Sim | Define boundaries do sistema |
| Feature complexa (3+ use cases) | ✅ Sim | Impacto arquitetural significativo |
| Novo aggregate root | ✅ Sim | Muda modelo de domínio |
| Mudar padrão de DI | ✅ Sim | Afeta toda a estrutura |
| Migrar repository pattern | ✅ Sim | Breaking change |
| Adicionar nova camada | ✅ Sim | Mudança arquitetural |
| Criar use case simples | ❌ Não | Implementação seguindo padrão |
| Refatorar router para thin | ❌ Não | Correção/manutenção |
| Adicionar DTO | ❌ Não | Implementação normal |
| Criar repository interface | ❌ Não | Seguindo padrão existente |

### Classificação de Impacto

```
┌─────────────────────────────────────────────────────────────┐
│  🔴 CRÍTICO (ADR + Review de Arquitetura)                   │
├─────────────────────────────────────────────────────────────┤
│  • Novo bounded context / módulo de domínio                 │
│  • Mudança no padrão de injeção de dependências             │
│  • Migração de ORM ou pattern de persistência               │
│  • Introdução de event sourcing / CQRS                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🟡 MÉDIO (ADR recomendado)                                 │
├─────────────────────────────────────────────────────────────┤
│  • Feature com 3+ use cases                                 │
│  • Novo aggregate root                                      │
│  • Cross-module communication                               │
│  • Novo domain service                                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🟢 BAIXO (Implementar seguindo padrões)                    │
├─────────────────────────────────────────────────────────────┤
│  • Criar use case seguindo estrutura                        │
│  • Adicionar repository method                              │
│  • Criar DTOs                                               │
│  • Refatorar router para thin                               │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo para Novos Módulos/Features Complexas

```
1. Identificar escopo da feature
       │
       ▼
2. É novo módulo ou 3+ use cases? ──Não──▶ Implementar direto
       │
      Sim
       │
       ▼
3. Acionar skill `reviewer`
       │
       ▼
4. Criar proposta com:
   - Boundaries do módulo
   - Use cases necessários
   - Entities/Aggregates
   - Dependências entre módulos
       │
       ▼
5. Aprovação → Gerar ADR
       │
       ▼
6. Implementar estrutura
       │
       ▼
7. PR com link para ADR
```

### Campos Específicos no ADR de Use Case/Módulo

Além do template padrão do reviewer, incluir:

```markdown
## Domain-Specific

### Bounded Context
- Nome do módulo: {{nome}}
- Responsabilidade: {{descrição}}
- Invariantes de negócio: {{regras}}

### Estrutura do Módulo
\`\`\`
modules/{{nome}}/
├── application/
│   ├── use-cases/
│   │   ├── {{UseCase1}}.ts
│   │   └── {{UseCase2}}.ts
│   ├── dtos/
│   └── ports/
├── domain/
│   ├── {{Entity}}.ts
│   └── {{ValueObject}}.ts
├── infrastructure/
│   └── {{Repository}}.ts
└── presentation/
    └── {{router}}.ts
\`\`\`

### Use Cases Planejados
| Use Case | Input | Output | Complexidade |
|----------|-------|--------|--------------|
| {{CreateX}} | {{dto}} | {{dto}} | Alta/Média/Baixa |
| {{UpdateX}} | {{dto}} | {{dto}} | Alta/Média/Baixa |

### Entities e Aggregates
| Entity | Aggregate Root | Invariantes |
|--------|----------------|-------------|
| {{Order}} | ✅ Sim | {{regras}} |
| {{OrderItem}} | ❌ Não | {{regras}} |

### Dependências
- Módulos consumidos: {{lista}}
- Módulos que consomem: {{lista}}
- Comunicação: Síncrona / Eventos / Ambos

### Repository Interfaces
\`\`\`typescript
interface I{{Entity}}Repository {
  findById(id: string): Promise<{{Entity}} | null>;
  save(entity: {{Entity}}): Promise<void>;
  // ...
}
\`\`\`
```

### Convenções de Commit para Módulos/Use Cases

```
[ADR-NNNN] feat(orders): add orders module with CreateOrderUseCase

[ADR-NNNN] feat(payments): implement payment processing use cases

[ADR-NNNN] refactor(di): migrate to new dependency injection pattern

[ADR-NNNN] feat(inventory): add inventory bounded context
```

### Red Flags - PARE e Use Reviewer

- [ ] Criando novo diretório em `modules/`
- [ ] Feature requer mais de 3 use cases
- [ ] Novo aggregate root no domínio
- [ ] Comunicação entre módulos diferente do padrão
- [ ] Mudança na forma de injetar dependências

### Module Creation Checklist

```markdown
## New Module Checklist

### Pré-Implementação
- [ ] ADR aprovado
- [ ] Boundaries definidos
- [ ] Use cases listados
- [ ] Entities/Aggregates identificados
- [ ] Dependências mapeadas

### Implementação
- [ ] Estrutura de pastas criada
- [ ] Domain layer implementada
- [ ] Repository interfaces definidas
- [ ] Repository implementations
- [ ] Use cases implementados
- [ ] DTOs criados
- [ ] Router thin implementado
- [ ] Context atualizado com DI

### Validação
- [ ] Use cases testáveis sem DB
- [ ] Zero lógica no router
- [ ] Interfaces abstraem implementação
- [ ] Nenhum import circular
```

### Decisões de Design a Documentar no ADR

| Decisão | Documentar |
|---------|------------|
| Por que este bounded context? | Separação de responsabilidades |
| Por que X é aggregate root? | Invariantes que protege |
| Por que comunicação síncrona/eventos? | Trade-offs de consistência |
| Por que estas interfaces? | Contratos e testabilidade |

### Nunca Faça Sem ADR

| Ação | Por quê |
|------|---------|
| Criar novo módulo | Define boundaries do sistema |
| Adicionar aggregate root | Muda modelo de domínio |
| Comunicação cross-module | Pode criar acoplamento |
| Mudar padrão de DI | Impacta toda a codebase |
| Introduzir nova camada | Mudança arquitetural |
