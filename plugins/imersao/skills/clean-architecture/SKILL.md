---
name: clean-architecture
description: "Enforce clean architecture principles, SOLID patterns, and scalable code organization. Use when building backends, APIs, microservices, or any application requiring maintainable, testable structure."
version: 1.1.0
author: gustavo
tags: [backend, architecture]
---

# Clean Architecture Skill

## Directory Structure

Organize by feature/domain, NOT by type:

```
src/
├── modules/
│   ├── users/
│   │   ├── domain/           # Entities, value objects
│   │   ├── application/      # Use cases, DTOs
│   │   ├── infrastructure/   # Repositories, adapters
│   │   └── presentation/     # Controllers
│   └── orders/
├── shared/
│   ├── domain/
│   ├── infrastructure/
│   └── utils/
└── main.ts
```

## SOLID Principles

**S - Single Responsibility**: One class = one purpose
**O - Open/Closed**: Extend via interfaces, not modification
**L - Liskov Substitution**: Subtypes replaceable for base types
**I - Interface Segregation**: Many small interfaces > one large
**D - Dependency Inversion**: Depend on abstractions

## Layer Rules

### Domain (Core)
- Entities, Value Objects, Domain Services
- ZERO external dependencies

```typescript
export class User {
  static create(props: CreateUserProps): User {
    return new User(generateId(), new Email(props.email), UserStatus.PENDING);
  }

  activate(): void {
    if (this._status !== UserStatus.PENDING) {
      throw new DomainError('Cannot activate');
    }
    this._status = UserStatus.ACTIVE;
  }
}
```

### Application
- Use Cases, DTOs, Port interfaces
- Depends only on Domain

```typescript
export class CreateUserUseCase {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly emailService: IEmailService
  ) {}

  async execute(input: CreateUserInput): Promise<CreateUserOutput> {
    const existing = await this.userRepository.findByEmail(input.email);
    if (existing) throw new UserAlreadyExistsError(input.email);

    const user = User.create(input);
    await this.userRepository.save(user);
    return { id: user.id };
  }
}
```

### Infrastructure
- Repository implementations, External adapters
- Implements Application interfaces

```typescript
export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findByEmail(email: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { email } });
    return data ? UserMapper.toDomain(data) : null;
  }
}
```

### Presentation
- Controllers, Resolvers
- Thin handlers, delegate to use cases

```typescript
@Controller('users')
export class UserController {
  constructor(private readonly createUser: CreateUserUseCase) {}

  @Post()
  async create(@Body() dto: CreateUserDto) {
    return this.createUser.execute(dto);
  }
}
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Entity | PascalCase | `User`, `Order` |
| Value Object | Descriptive | `Email`, `Money` |
| Use Case | VerbNounUseCase | `CreateUserUseCase` |
| Repository | INounRepository | `IUserRepository` |
| Controller | NounController | `UserController` |
| DTO | NounActionDto | `CreateUserDto` |
| Error | NounError | `UserNotFoundError` |

## Error Handling

```typescript
export abstract class DomainError extends Error {
  abstract readonly code: string;
}

export class UserNotFoundError extends DomainError {
  readonly code = 'USER_NOT_FOUND';
  constructor(id: string) {
    super(`User ${id} not found`);
  }
}
```

## Checklist

- [ ] Code organized by feature/domain
- [ ] Domain layer has ZERO dependencies
- [ ] Dependencies injected via interfaces
- [ ] Use cases are single-purpose
- [ ] Controllers < 15 lines per method
- [ ] No business logic in controllers
- [ ] Errors are domain-specific
- [ ] No circular dependencies

