---
name: testing-strategy
description: "Write comprehensive test suites with proper structure, mocking strategies, fixtures, and coverage goals. Use when implementing unit tests, integration tests, or e2e tests. Triggers on: tests, testing, unit test, integration test, e2e, jest, vitest, pytest, mocking, TDD."
version: 1.1.0
author: gustavo
tags: [testing, quality]
---

# Testing Strategy Skill

## Test Types

| Type | Purpose | Speed | Coverage Target |
|------|---------|-------|-----------------|
| Unit | Single function/class | Fast | 80%+ business logic |
| Integration | Module interactions | Medium | Critical paths |
| E2E | Full user flows | Slow | Happy paths |

## Test Structure (AAA Pattern)

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { name: 'John', email: 'john@example.com' };
      const mockRepo = createMockRepository();
      const service = new UserService(mockRepo);

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(result.id).toBeDefined();
      expect(mockRepo.save).toHaveBeenCalledWith(expect.objectContaining(userData));
    });
  });
});
```

## Naming Convention

Pattern: `should_expectedBehavior_when_condition`

```typescript
it('should return null when user not found', () => {});
it('should throw ValidationError when email invalid', () => {});
```

## Test Data Factories

```typescript
import { faker } from '@faker-js/faker';

export function createUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    ...overrides,
  };
}
```

## Mocking Guidelines

**Mock these:**
- Database repositories
- HTTP clients
- External services
- Time/Date

**Don't mock:**
- The class under test
- Simple value objects
- Pure functions

```typescript
const mockRepo = {
  findById: jest.fn(),
  save: jest.fn(),
};
mockRepo.findById.mockResolvedValue(createUser());
```

## Integration Test Setup

```typescript
beforeAll(async () => {
  await database.migrate();
});

afterAll(async () => {
  await database.close();
});

beforeEach(async () => {
  await database.truncateAll();
});
```

## Checklist

- [ ] Tests follow AAA pattern
- [ ] Test names describe behavior
- [ ] External dependencies mocked
- [ ] Test data uses factories
- [ ] No test interdependencies
- [ ] Coverage meets targets

