# PII Patterns

Patterns completos para detecção de PII (Personally Identifiable Information) em logs.

## Categorias de PII

### Alta Severidade (CRITICAL)

PII que NUNCA deve aparecer em logs:

| Tipo | Pattern | Exemplo | Risco |
|------|---------|---------|-------|
| Senha | `password`, `senha`, `pwd` | `pwd: "123456"` | Acesso não autorizado |
| Token JWT | `eyJ[a-zA-Z0-9_-]+\.eyJ...` | `eyJhbGciOiJIUzI1...` | Session hijacking |
| API Key | `sk-`, `pk_`, `api_key` | `sk-proj-abc123` | Acesso a serviços |
| Cartão crédito | `\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}` | `4111-1111-1111-1111` | Fraude financeira |
| CVV | `cvv`, `cvc`, `security_code` | `cvv: 123` | Fraude financeira |
| CPF | `\d{3}\.\d{3}\.\d{3}-\d{2}` | `123.456.789-00` | Identidade |
| SSN | `\d{3}-\d{2}-\d{4}` | `123-45-6789` | Identidade (US) |

### Média Severidade (HIGH)

PII que deve ser sanitizado:

| Tipo | Pattern | Sanitização |
|------|---------|-------------|
| Email | `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` | `j***@example.com` |
| Telefone | `\+?\d{10,13}` | `*******8888` |
| IP | `\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}` | `192.168.1.xxx` |
| RG | `\d{2}\.\d{3}\.\d{3}-\d{1}` | `**.***.***-*` |

### Baixa Severidade (MEDIUM)

Dados que requerem atenção:

| Tipo | Contexto | Ação |
|------|----------|------|
| Nome completo | Em combinação com outros dados | Avaliar necessidade |
| Endereço | Logs de entrega | Sanitizar parcialmente |
| Data nascimento | Logs de cadastro | Avaliar necessidade |

---

## Regex Patterns

### JavaScript/TypeScript

```typescript
export const PII_PATTERNS = {
  // === CRITICAL ===
  jwt: /eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+/g,

  creditCard: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,

  cpf: /\b\d{3}\.\d{3}\.\d{3}-\d{2}\b/g,
  cpfUnformatted: /\b\d{11}\b/g, // Requer contexto

  ssn: /\b\d{3}-\d{2}-\d{4}\b/g,

  // API Keys (common patterns)
  openaiKey: /sk-[a-zA-Z0-9]{48}/g,
  stripeKey: /(sk|pk)_(test|live)_[a-zA-Z0-9]{24,}/g,
  awsKey: /AKIA[A-Z0-9]{16}/g,

  // === HIGH ===
  email: /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b/g,

  phone: /\b\+?[1-9]\d{9,13}\b/g,
  phoneBR: /\b\(?[1-9]{2}\)?\s?9?\d{4}[-\s]?\d{4}\b/g,

  ipv4: /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/g,
  ipv6: /\b(?:[a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}\b/g,

  rg: /\b\d{2}\.\d{3}\.\d{3}-\d{1}\b/g,

  // === MEDIUM ===
  dateOfBirth: /\b(?:0[1-9]|[12][0-9]|3[01])\/(?:0[1-9]|1[012])\/(?:19|20)\d{2}\b/g,
} as const;

// Campos sensíveis (buscar em keys de objetos)
export const SENSITIVE_FIELDS = [
  // Autenticação
  'password', 'senha', 'pwd', 'pass',
  'token', 'accessToken', 'access_token', 'refreshToken', 'refresh_token',
  'apiKey', 'api_key', 'apikey', 'secret', 'secretKey', 'secret_key',
  'authorization', 'auth', 'bearer',

  // Financeiro
  'creditCard', 'credit_card', 'cardNumber', 'card_number',
  'cvv', 'cvc', 'securityCode', 'security_code',
  'accountNumber', 'account_number', 'routingNumber',

  // Identificação
  'cpf', 'rg', 'ssn', 'cnh', 'passport',
  'socialSecurity', 'taxId', 'tax_id',

  // Criptografia
  'privateKey', 'private_key', 'encryptionKey',
  'signingKey', 'certificate', 'cert',
];
```

### Python

```python
import re

PII_PATTERNS = {
    # === CRITICAL ===
    'jwt': re.compile(r'eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'),
    'credit_card': re.compile(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
    'cpf': re.compile(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b'),
    'ssn': re.compile(r'\b\d{3}-\d{2}-\d{4}\b'),

    # === HIGH ===
    'email': re.compile(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'),
    'phone': re.compile(r'\b\+?[1-9]\d{9,13}\b'),
    'ipv4': re.compile(r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'),
}

SENSITIVE_FIELDS = [
    'password', 'senha', 'token', 'api_key', 'secret',
    'credit_card', 'cvv', 'cpf', 'ssn', 'private_key',
]
```

---

## Detecção em Logs

### Algoritmo

```typescript
interface PIIMatch {
  type: string;
  value: string;
  masked: string;
  location: {
    file?: string;
    line?: number;
    field?: string;
  };
  severity: 'critical' | 'high' | 'medium';
}

function detectPII(logEntry: LogEntry): PIIMatch[] {
  const matches: PIIMatch[] = [];
  const content = JSON.stringify(logEntry);

  // 1. Verificar campos sensíveis
  for (const field of SENSITIVE_FIELDS) {
    if (hasField(logEntry, field)) {
      const value = getFieldValue(logEntry, field);
      if (value && value !== '[REDACTED]') {
        matches.push({
          type: 'sensitive_field',
          value: maskValue(value),
          masked: '[REDACTED]',
          location: { field },
          severity: 'critical',
        });
      }
    }
  }

  // 2. Verificar patterns no conteúdo
  for (const [type, pattern] of Object.entries(PII_PATTERNS)) {
    const found = content.match(pattern);
    if (found) {
      for (const value of found) {
        matches.push({
          type,
          value: maskForReport(value),
          masked: getSanitizedVersion(type, value),
          location: findLocation(logEntry, value),
          severity: getSeverity(type),
        });
      }
    }
  }

  return matches;
}
```

### Falsos Positivos

Patterns que podem gerar falsos positivos:

| Pattern | Falso Positivo | Como Evitar |
|---------|----------------|-------------|
| `\d{11}` (CPF) | IDs numéricos | Verificar contexto do campo |
| `\d{10,13}` (phone) | Timestamps | Verificar formato |
| Email | URLs com @ | Verificar domínio válido |
| IP | Versões semânticas | Verificar range válido |

### Whitelist

```typescript
const WHITELIST = {
  // Emails de teste/exemplo
  emails: [
    'test@example.com',
    'noreply@example.com',
    'user@localhost',
  ],

  // IPs internos/localhost
  ips: [
    '127.0.0.1',
    '0.0.0.0',
    'localhost',
  ],

  // CPFs de teste (inválidos)
  cpfs: [
    '000.000.000-00',
    '111.111.111-11',
  ],
};
```

---

## Correções Sugeridas

### Para @repo/logger

```typescript
// ANTES (leak)
logger.info('User logged in', { email: user.email });

// DEPOIS (correto)
import { sanitize } from '@repo/logger';
logger.info('User logged in', { email: sanitize.email(user.email) });
```

### Adicionar Campo Sensível

```typescript
// Em logger options
const logger = createLogger('auth', {
  sensitiveFields: ['customToken', 'internalId'],
});
```

### Para Python (ana-service)

```python
# ANTES (leak)
logger.info("User logged in", extra={"email": user.email})

# DEPOIS (correto)
from app.utils.sanitize import mask_email
logger.info("User logged in", extra={"email": mask_email(user.email)})
```

---

## Relatório de PII

### Formato no Audit Report

```markdown
## PII Leaks Detectados

### LEAK-001: JWT exposto em logs
- **Severidade:** CRITICAL
- **Tipo:** jwt
- **Arquivo:** `apps/api/src/auth/middleware.ts:45`
- **Campo:** `headers.authorization`
- **Valor:** `eyJhbG...` (truncado)
- **Correção:**
  ```typescript
  // Remover log ou usar sanitize.token()
  logger.debug('Auth header', {
    auth: sanitize.token(headers.authorization)
  });
  ```

### LEAK-002: Email não sanitizado
- **Severidade:** HIGH
- **Tipo:** email
- **Arquivo:** `apps/api/src/users/service.ts:123`
- **Campo:** `user.email`
- **Valor:** `j***@example.com`
- **Correção:**
  ```typescript
  logger.info('User created', {
    email: sanitize.email(user.email)
  });
  ```
```

---

## Checklist de Verificação

```markdown
- [ ] JWT/tokens não aparecem em logs
- [ ] Senhas nunca logadas
- [ ] Emails sanitizados (j***@domain.com)
- [ ] Telefones sanitizados (*******1234)
- [ ] CPF/RG/SSN nunca logados
- [ ] IPs anonimizados em produção (*.*.*.xxx)
- [ ] Números de cartão nunca logados
- [ ] API keys não aparecem em logs
- [ ] Headers Authorization sanitizados
```
