# API Endpoint Template

Copy this template for API endpoint documentation.

---

```markdown
---
title: "API: {{endpoint_name}}"
created: {{date}}
updated: {{date}}
version: v1
tags:
  - type/api
  - api/{{resource}}
---

# {{HTTP_METHOD}} {{endpoint_path}}

{{brief_description}}

## Overview

| Property | Value |
|----------|-------|
| **Method** | `{{HTTP_METHOD}}` |
| **Path** | `{{endpoint_path}}` |
| **Auth** | Required / Optional / None |
| **Rate Limit** | 100 req/min |

## Request

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Bearer token |
| `Content-Type` | Yes | `application/json` |

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string (UUID) | Resource identifier |

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page |

### Request Body

\`\`\`json
{
  "name": "string",
  "email": "string",
  "role": "user | admin"
}
\`\`\`

## Response

### Success (200 OK)

\`\`\`json
{
  "data": {
    "id": "usr_abc123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "requestId": "req_xyz789"
  }
}
\`\`\`

### Errors

| Code | Error | Description |
|------|-------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 404 | `NOT_FOUND` | Resource not found |
| 422 | `UNPROCESSABLE` | Business rule violation |

> [!example] Error Response
> \`\`\`json
> {
>   "error": {
>     "code": "VALIDATION_ERROR",
>     "message": "Invalid input",
>     "details": [
>       { "field": "email", "message": "Invalid format" }
>     ]
>   }
> }
> \`\`\`

## Examples

### cURL

\`\`\`bash
curl -X {{HTTP_METHOD}} \
  '{{base_url}}{{endpoint_path}}' \
  -H 'Authorization: Bearer {{token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "John Doe",
    "email": "john@example.com"
  }'
\`\`\`

### TypeScript (tRPC)

\`\`\`typescript
const result = await api.{{resource}}.{{method}}.mutate({
  name: 'John Doe',
  email: 'john@example.com',
});
\`\`\`

## Related

- [[Authentication]]
- [[Error Codes]]
- [[Rate Limiting]]
```
