---
name: api-design
description: "Design and implement professional REST APIs with consistent patterns, proper error handling, versioning, pagination, and OpenAPI documentation. Use when building any API endpoint, service, or backend interface. Triggers on: REST API, GraphQL, endpoint design, API routes, backend services, webhooks."
version: 1.1.0
author: gustavo
tags: [backend, api]
---

# API Design Skill

This skill ensures every API is consistent, well-documented, and follows industry best practices.

## URL Structure

```
/api/v1/{resource}                    # Collection
/api/v1/{resource}/{id}               # Single item
/api/v1/{resource}/{id}/{sub-resource}  # Nested resource
```

**Rules:**
- Use plural nouns: `/users`, `/orders`, `/products`
- Use kebab-case for multi-word: `/order-items`
- Max 2 levels of nesting

## HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve | Yes | Yes |
| POST | Create | No | No |
| PUT | Replace | Yes | No |
| PATCH | Update | Yes | No |
| DELETE | Remove | Yes | No |

## Response Format

### Success
```json
{
  "data": { },
  "meta": {
    "requestId": "req_xyz789",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Must be valid email" }
    ]
  },
  "meta": { "requestId": "req_xyz789" }
}
```

## Status Codes

| Code | When to Use |
|------|-------------|
| 200 | Successful GET, PUT, PATCH |
| 201 | Successful POST (created) |
| 204 | Successful DELETE |
| 400 | Bad request |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Not found |
| 409 | Conflict |
| 422 | Validation failed |
| 429 | Rate limited |
| 500 | Server error |

## Pagination

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "perPage": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## Filtering & Sorting

```
GET /api/v1/users?status=active&sort=-createdAt&fields=id,name
```

## Checklist

- [ ] URLs use plural nouns and kebab-case
- [ ] Correct HTTP methods for each operation
- [ ] Consistent response envelope
- [ ] Proper status codes
- [ ] Pagination on all list endpoints
- [ ] Validation with detailed errors
- [ ] Rate limiting headers
- [ ] OpenAPI documentation

