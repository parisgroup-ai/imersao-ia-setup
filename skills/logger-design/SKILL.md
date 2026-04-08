---
name: logger-design
description: "Design e implementação de logging estruturado com distributed tracing. Enforça schema rígido, correlation IDs, sanitização de PII e boas práticas de observabilidade. Multi-stack (Node.js, Python, Go, Frontend). Triggers on: log, logging, logger, trace, tracing, observability, correlation, span, structured log."
version: 1.0.0
author: gustavo
tags: [logging, observability, design, tracing]
---

# Logger Design Skill

Esta skill define padrões rígidos para logging estruturado com distributed tracing, garantindo rastreabilidade completa e segurança de dados sensíveis.

## Core Principle

> **Logs são a memória do sistema. Estruturados, rastreáveis e seguros.**

```
┌─────────────────────────────────────────────────────────────┐
│  ESTRUTURADO: Schema rígido, campos obrigatórios            │
│  RASTREÁVEL: Distributed tracing com correlation IDs        │
│  SEGURO: PII sanitizado, dados sensíveis protegidos         │
└─────────────────────────────────────────────────────────────┘
```

---

## Schema de Log Obrigatório

### Interface Base

```typescript
interface LogEntry {
  // === OBRIGATÓRIOS ===
  timestamp: string;        // ISO 8601: "2024-01-15T10:30:00.000Z"
  level: LogLevel;          // "debug" | "info" | "warn" | "error" | "fatal"
  message: string;          // Descrição legível
  service: string;          // Nome do serviço/app
  environment: string;      // "development" | "staging" | "production"

  // === TRACING (obrigatório em requests) ===
  traceId: string;          // ID único da requisição raiz
  spanId: string;           // ID do span atual
  parentSpanId?: string;    // ID do span pai (se existir)

  // === CONTEXTO (quando disponível) ===
  userId?: string;          // ID do usuário (nunca PII direto)
  sessionId?: string;       // ID da sessão
  requestId?: string;       // ID da requisição HTTP

  // === TÉCNICO ===
  caller?: string;          // "file.ts:123:functionName"
  duration?: number;        // Duração em ms (para operações)

  // === DADOS ADICIONAIS ===
  data?: Record<string, unknown>;  // Contexto específico
  error?: ErrorInfo;        // Detalhes do erro (se level = error/fatal)
}

interface ErrorInfo {
  name: string;
  message: string;
  stack?: string;
  code?: string;
  cause?: ErrorInfo;
}

type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'fatal';
```

### Níveis de Log

| Nível | Quando usar | Exemplo | Produção |
|-------|-------------|---------|----------|
| `debug` | Desenvolvimento, troubleshooting | "Query params: {...}" | ❌ Off |
| `info` | Eventos normais de negócio | "Order created" | ✅ On |
| `warn` | Situação inesperada, não crítica | "Retry attempt 2/3" | ✅ On |
| `error` | Erro que afeta operação | "Payment failed" | ✅ On |
| `fatal` | Sistema comprometido | "Database connection lost" | ✅ On |

### Exemplo de Log Válido

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "info",
  "message": "Order created successfully",
  "service": "order-service",
  "environment": "production",
  "traceId": "abc123def456",
  "spanId": "span-789",
  "parentSpanId": "span-456",
  "userId": "user-123",
  "requestId": "req-xyz",
  "duration": 145,
  "data": {
    "orderId": "order-456",
    "totalAmount": 299.90,
    "itemCount": 3
  }
}
```

---

## Distributed Tracing

### Hierarquia de IDs

```
┌─────────────────────────────────────────────────────────────┐
│  traceId: "abc123" (único para toda a jornada do request)   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ spanId: "span-1" (API Gateway)                      │   │
│  │ parentSpanId: null                                  │   │
│  └─────────────────────┬───────────────────────────────┘   │
│                        │                                    │
│         ┌──────────────┴──────────────┐                    │
│         ▼                             ▼                    │
│  ┌─────────────────┐          ┌─────────────────┐         │
│  │ spanId: "span-2"│          │ spanId: "span-3"│         │
│  │ (User Service)  │          │ (Order Service) │         │
│  │ parent: "span-1"│          │ parent: "span-1"│         │
│  └────────┬────────┘          └────────┬────────┘         │
│           │                            │                   │
│           ▼                            ▼                   │
│  ┌─────────────────┐          ┌─────────────────┐         │
│  │ spanId: "span-4"│          │ spanId: "span-5"│         │
│  │ (Database)      │          │ (Payment API)   │         │
│  │ parent: "span-2"│          │ parent: "span-3"│         │
│  └─────────────────┘          └─────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Headers de Propagação

```typescript
// Headers HTTP obrigatórios
const TRACE_HEADERS = {
  // Custom headers
  TRACE_ID: 'x-trace-id',
  SPAN_ID: 'x-span-id',
  PARENT_SPAN_ID: 'x-parent-span-id',
  REQUEST_ID: 'x-request-id',

  // W3C Trace Context (padrão OpenTelemetry)
  TRACEPARENT: 'traceparent',    // 00-{traceId}-{spanId}-{flags}
  TRACESTATE: 'tracestate',      // vendor-specific data
};

// Formato W3C traceparent
// 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
//    |_________________________________|________________|__|
//                traceId (32 hex)      spanId (16 hex)  flags
```

### Contexto Enriquecido

```typescript
interface RequestContext {
  // Tracing
  traceId: string;
  spanId: string;
  parentSpanId?: string;

  // User context
  userId?: string;
  sessionId?: string;
  userAgent?: string;
  ip?: string;            // Anonimizado em produção

  // Request info
  requestId: string;
  method: string;
  path: string;

  // Feature context
  featureFlags?: string[];
  abTestVariant?: string;

  // Timing
  startTime: number;
}
```

### Criação de Spans

```typescript
// Criar span para operação
function withSpan<T>(
  name: string,
  operation: (span: Span) => Promise<T>
): Promise<T> {
  const span = tracer.startSpan(name, {
    parent: context.active(),
  });

  return context.with(trace.setSpan(context.active(), span), async () => {
    try {
      const result = await operation(span);
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  });
}

// Uso
await withSpan('processPayment', async (span) => {
  span.setAttribute('payment.method', 'credit_card');
  span.setAttribute('payment.amount', 299.90);
  return await paymentService.process(order);
});
```

---

## Implementação Multi-Stack

### Node.js (Pino + OpenTelemetry)

```typescript
// src/logger/index.ts
import pino from 'pino';
import { context, trace } from '@opentelemetry/api';

const baseLogger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: () => `,"timestamp":"${new Date().toISOString()}"`,
  redact: {
    paths: ['password', 'token', 'authorization', 'creditCard', 'cpf'],
    censor: '[REDACTED]',
  },
});

export function getLogger(service: string) {
  return baseLogger.child({
    service,
    environment: process.env.NODE_ENV || 'development',
  });
}

export function getContextLogger(service: string) {
  const span = trace.getSpan(context.active());
  const spanContext = span?.spanContext();

  return getLogger(service).child({
    traceId: spanContext?.traceId,
    spanId: spanContext?.spanId,
  });
}

// Middleware Express
export function loggerMiddleware(serviceName: string) {
  return (req, res, next) => {
    const startTime = Date.now();
    const span = trace.getSpan(context.active());
    const spanContext = span?.spanContext();

    req.log = getLogger(serviceName).child({
      traceId: spanContext?.traceId || req.headers['x-trace-id'],
      spanId: spanContext?.spanId || generateSpanId(),
      requestId: req.headers['x-request-id'] || generateRequestId(),
      userId: req.user?.id,
      method: req.method,
      path: req.path,
    });

    req.log.info('Request received');

    res.on('finish', () => {
      req.log.info('Response sent', {
        statusCode: res.statusCode,
        duration: Date.now() - startTime,
      });
    });

    next();
  };
}
```

### Python (structlog + OpenTelemetry)

```python
# src/logger/__init__.py
import structlog
import os
from opentelemetry import trace
from datetime import datetime

def configure_logging():
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            add_timestamp,
            add_trace_context,
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
    )

def add_timestamp(logger, method_name, event_dict):
    event_dict["timestamp"] = datetime.utcnow().isoformat() + "Z"
    return event_dict

def add_trace_context(logger, method_name, event_dict):
    span = trace.get_current_span()
    if span:
        ctx = span.get_span_context()
        event_dict["traceId"] = format(ctx.trace_id, '032x')
        event_dict["spanId"] = format(ctx.span_id, '016x')
    return event_dict

def get_logger(service: str):
    return structlog.get_logger(
        service=service,
        environment=os.getenv("ENVIRONMENT", "development"),
    )

# Uso
logger = get_logger("order-service")
logger.info("Order created", order_id="123", total=299.90)
```

### Go (zap + OpenTelemetry)

```go
// pkg/logger/logger.go
package logger

import (
    "context"
    "os"

    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
    "go.opentelemetry.io/otel/trace"
)

var baseLogger *zap.Logger

func Init(service string) {
    config := zap.NewProductionConfig()
    config.EncoderConfig.TimeKey = "timestamp"
    config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder

    baseLogger, _ = config.Build()
    baseLogger = baseLogger.With(
        zap.String("service", service),
        zap.String("environment", os.Getenv("ENVIRONMENT")),
    )
}

func Get() *zap.Logger {
    return baseLogger
}

func WithContext(ctx context.Context) *zap.Logger {
    span := trace.SpanFromContext(ctx)
    if span == nil {
        return baseLogger
    }

    sc := span.SpanContext()
    return baseLogger.With(
        zap.String("traceId", sc.TraceID().String()),
        zap.String("spanId", sc.SpanID().String()),
    )
}

// Uso
func ProcessOrder(ctx context.Context, order Order) error {
    log := logger.WithContext(ctx)
    log.Info("Processing order",
        zap.String("orderId", order.ID),
        zap.Float64("total", order.Total),
    )
    // ...
}
```

### Frontend (Browser Logger)

```typescript
// src/logger/browser.ts
interface BrowserLogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  service: string;
  environment: string;
  sessionId: string;
  userId?: string;
  traceId?: string;
  url: string;
  userAgent: string;
  data?: Record<string, unknown>;
  error?: { name: string; message: string; stack?: string };
}

class BrowserLogger {
  private buffer: BrowserLogEntry[] = [];
  private readonly flushInterval = 5000;
  private readonly maxBufferSize = 100;
  private readonly service: string;
  private readonly environment: string;
  private sessionId: string;

  constructor(service: string) {
    this.service = service;
    this.environment = process.env.NODE_ENV || 'development';
    this.sessionId = this.getOrCreateSessionId();

    // Flush periodicamente
    setInterval(() => this.flush(), this.flushInterval);

    // Flush antes de fechar
    window.addEventListener('beforeunload', () => this.flush());

    // Captura erros globais
    window.addEventListener('error', (event) => {
      this.error('Uncaught error', {
        error: {
          name: event.error?.name || 'Error',
          message: event.message,
          stack: event.error?.stack,
        },
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
      });
    });

    // Captura promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.error('Unhandled promise rejection', {
        reason: String(event.reason),
      });
    });
  }

  private getOrCreateSessionId(): string {
    let sessionId = sessionStorage.getItem('sessionId');
    if (!sessionId) {
      sessionId = crypto.randomUUID();
      sessionStorage.setItem('sessionId', sessionId);
    }
    return sessionId;
  }

  private createEntry(
    level: LogLevel,
    message: string,
    data?: Record<string, unknown>
  ): BrowserLogEntry {
    return {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: this.service,
      environment: this.environment,
      sessionId: this.sessionId,
      userId: this.getUserId(),
      traceId: this.getTraceId(),
      url: window.location.href,
      userAgent: navigator.userAgent,
      data,
    };
  }

  private getUserId(): string | undefined {
    // Implementar conforme auth do projeto
    return window.__USER__?.id;
  }

  private getTraceId(): string | undefined {
    // Pegar do header de resposta ou meta tag
    return document.querySelector('meta[name="trace-id"]')?.getAttribute('content');
  }

  debug(message: string, data?: Record<string, unknown>) {
    if (this.environment === 'development') {
      console.debug(message, data);
      this.buffer.push(this.createEntry('debug', message, data));
    }
  }

  info(message: string, data?: Record<string, unknown>) {
    console.info(message, data);
    this.buffer.push(this.createEntry('info', message, data));
    this.checkBuffer();
  }

  warn(message: string, data?: Record<string, unknown>) {
    console.warn(message, data);
    this.buffer.push(this.createEntry('warn', message, data));
    this.checkBuffer();
  }

  error(message: string, data?: Record<string, unknown>) {
    console.error(message, data);
    this.buffer.push(this.createEntry('error', message, data));
    this.flush(); // Erros enviam imediatamente
  }

  private checkBuffer() {
    if (this.buffer.length >= this.maxBufferSize) {
      this.flush();
    }
  }

  private async flush() {
    if (this.buffer.length === 0) return;

    const logs = [...this.buffer];
    this.buffer = [];

    try {
      await fetch('/api/logs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(logs),
        keepalive: true, // Garante envio mesmo ao fechar página
      });
    } catch (error) {
      // Re-adiciona ao buffer em caso de falha
      this.buffer.unshift(...logs);
      console.error('Failed to flush logs', error);
    }
  }
}

// Singleton
export const logger = new BrowserLogger('web-app');
```

---

## Segurança e PII

### Dados NUNCA Logar

```
┌─────────────────────────────────────────────────────────────┐
│  🚫 PROIBIDO - NUNCA LOGAR                                  │
├─────────────────────────────────────────────────────────────┤
│  • Senhas (plain text ou hash)                              │
│  • Tokens de autenticação (JWT, API keys, refresh tokens)   │
│  • Números de cartão de crédito                             │
│  • CVV / Código de segurança                                │
│  • CPF, RG, CNH, passaporte                                 │
│  • Email completo (mascarar: j***@example.com)              │
│  • Telefone completo (mascarar: (**) ****-1234)             │
│  • Endereço completo                                        │
│  • IP completo em produção (anonimizar: 192.168.1.xxx)      │
│  • Dados de saúde (CID, exames, diagnósticos)               │
│  • Dados financeiros detalhados (saldo, extrato)            │
│  • Biometria                                                │
│  • Geolocalização precisa                                   │
└─────────────────────────────────────────────────────────────┘
```

### Funções de Sanitização

```typescript
// src/logger/sanitize.ts
export const sanitize = {
  email: (email: string): string => {
    if (!email || !email.includes('@')) return '[INVALID_EMAIL]';
    const [user, domain] = email.split('@');
    return `${user[0]}${'*'.repeat(Math.min(user.length - 1, 5))}@${domain}`;
  },

  phone: (phone: string): string => {
    const digits = phone.replace(/\D/g, '');
    if (digits.length < 4) return '[INVALID_PHONE]';
    return '*'.repeat(digits.length - 4) + digits.slice(-4);
  },

  cpf: (cpf: string): string => {
    const digits = cpf.replace(/\D/g, '');
    if (digits.length !== 11) return '[INVALID_CPF]';
    return `***.***${digits.slice(6, 9)}-**`;
  },

  creditCard: (card: string): string => {
    const digits = card.replace(/\D/g, '');
    if (digits.length < 4) return '[INVALID_CARD]';
    return `${'*'.repeat(digits.length - 4)}-${digits.slice(-4)}`;
  },

  ip: (ip: string): string => {
    if (ip.includes(':')) {
      // IPv6
      return ip.replace(/:[^:]+$/, ':xxxx');
    }
    // IPv4
    return ip.replace(/\.\d+$/, '.xxx');
  },

  token: (token: string): string => {
    if (token.length <= 8) return '[REDACTED]';
    return `${token.slice(0, 4)}...[REDACTED]...${token.slice(-4)}`;
  },

  // Sanitiza objeto recursivamente
  object: <T extends Record<string, unknown>>(
    obj: T,
    sensitiveKeys?: string[]
  ): T => {
    const keys = sensitiveKeys || SENSITIVE_FIELDS;
    const sanitized = { ...obj };

    for (const [key, value] of Object.entries(sanitized)) {
      const lowerKey = key.toLowerCase();

      if (keys.some(k => lowerKey.includes(k.toLowerCase()))) {
        sanitized[key as keyof T] = '[REDACTED]' as any;
      } else if (value && typeof value === 'object' && !Array.isArray(value)) {
        sanitized[key as keyof T] = sanitize.object(
          value as Record<string, unknown>,
          keys
        ) as any;
      }
    }

    return sanitized;
  },
};

// Campos sensíveis padrão
const SENSITIVE_FIELDS = [
  'password', 'senha', 'pwd',
  'token', 'accessToken', 'refreshToken', 'apiKey', 'api_key', 'secret',
  'authorization', 'auth',
  'creditCard', 'cardNumber', 'card_number', 'cvv', 'cvc',
  'cpf', 'rg', 'ssn', 'cnh',
  'privateKey', 'private_key',
];
```

### Middleware de Auto-Sanitização

```typescript
// src/logger/auto-sanitize.ts
import { sanitize, SENSITIVE_FIELDS } from './sanitize';

export function createSanitizedLogger(baseLogger: Logger): Logger {
  return {
    ...baseLogger,

    debug: (message: string, data?: Record<string, unknown>) =>
      baseLogger.debug(message, data ? sanitize.object(data) : undefined),

    info: (message: string, data?: Record<string, unknown>) =>
      baseLogger.info(message, data ? sanitize.object(data) : undefined),

    warn: (message: string, data?: Record<string, unknown>) =>
      baseLogger.warn(message, data ? sanitize.object(data) : undefined),

    error: (message: string, data?: Record<string, unknown>) =>
      baseLogger.error(message, data ? sanitize.object(data) : undefined),

    fatal: (message: string, data?: Record<string, unknown>) =>
      baseLogger.fatal(message, data ? sanitize.object(data) : undefined),
  };
}
```

### Níveis por Ambiente

| Ambiente | Nível mínimo | PII | Stack traces | Retenção |
|----------|--------------|-----|--------------|----------|
| development | debug | Permitido | Completo | Local |
| staging | debug | Mascarado | Completo | 7 dias |
| production | info | Mascarado | Só errors | 30-90 dias |

---

## Padrões de Log por Contexto

### HTTP Request/Response

```typescript
// Request recebido
logger.info('HTTP request received', {
  type: 'http_request_in',
  method: req.method,
  path: req.path,
  query: sanitize.object(req.query),
  headers: {
    'content-type': req.headers['content-type'],
    'user-agent': req.headers['user-agent'],
    'content-length': req.headers['content-length'],
  },
  ip: sanitize.ip(req.ip),
});

// Response enviado
logger.info('HTTP response sent', {
  type: 'http_response_out',
  statusCode: res.statusCode,
  duration: Date.now() - startTime,
  contentLength: res.get('content-length'),
});
```

### Database Operations

```typescript
// Query executada
logger.debug('Database query executed', {
  type: 'db_query',
  operation: 'SELECT',
  table: 'users',
  duration: queryTime,
  rowCount: results.length,
  // NUNCA logar a query completa com valores em produção
});

// Erro de database
logger.error('Database error', {
  type: 'db_error',
  operation: 'INSERT',
  table: 'orders',
  errorCode: error.code,
  errorMessage: error.message,
});
```

### External API Calls

```typescript
// Chamada externa
logger.info('External API call', {
  type: 'http_request_out',
  service: 'payment-gateway',
  method: 'POST',
  url: '/v1/charges', // Sem query params sensíveis
  duration: callTime,
  statusCode: response.status,
});
```

### Business Events

```typescript
// Evento de negócio
logger.info('Order created', {
  type: 'business_event',
  event: 'order.created',
  orderId: order.id,
  userId: order.userId,
  totalAmount: order.total,
  itemCount: order.items.length,
  paymentMethod: order.paymentMethod,
});
```

### Errors

```typescript
// Erro com contexto completo
logger.error('Payment processing failed', {
  type: 'error',
  error: {
    name: error.name,
    message: error.message,
    code: error.code,
    stack: process.env.NODE_ENV !== 'production' ? error.stack : undefined,
  },
  context: {
    orderId: order.id,
    paymentMethod: order.paymentMethod,
    attempt: retryCount,
  },
});
```

---

## Integração com Ecossistema

### Quando Acionar Outras Skills

| Situação | Skill | Motivo |
|----------|-------|--------|
| Mudar schema de log | `reviewer` | Breaking change |
| Mudar estratégia de tracing | `reviewer` | Decisão arquitetural |
| Adicionar novo transport | `reviewer` + `docker-devops` | Infra change |
| Log expondo dados sensíveis | `security-practices` | Validar PII |
| Logs em endpoints de API | `api-design` | Padronizar |
| Logs em containers | `docker-devops` | Configurar drivers |

### Campos Específicos no ADR de Logging

```markdown
## Logging-Specific

### Mudança Proposta
- **Tipo**: Schema / Transport / Biblioteca / Estratégia
- **Escopo**: {{serviços afetados}}

### Schema Antes/Depois
| Campo | Antes | Depois | Breaking? |
|-------|-------|--------|-----------|
| {{campo}} | {{tipo}} | {{tipo}} | {{sim/não}} |

### Impacto em Observabilidade
- Dashboards afetados: {{lista}}
- Alertas afetados: {{lista}}
- Queries a atualizar: {{lista}}

### Compatibilidade
- Logs antigos parseáveis: {{sim/não}}
- Período de migração: {{tempo}}
- Fallback configurado: {{sim/não}}

### Volume e Custos
- Volume atual: {{GB/dia}}
- Volume estimado: {{GB/dia}}
- Retenção: {{dias}}
- Custo mensal estimado: {{valor}}
```

### Convenções de Commit

```
[ADR-NNNN] feat(logging): add distributed tracing with OpenTelemetry

[ADR-NNNN] refactor(logging): migrate from winston to pino

feat(logging): add request correlation middleware

fix(logging): sanitize PII in error logs
```

---

## Checklist de Implementação

### Setup Inicial

```markdown
- [ ] Biblioteca de logging instalada (pino/winston/structlog/zap)
- [ ] OpenTelemetry configurado
- [ ] Schema de log definido e documentado
- [ ] Sanitização de PII implementada
- [ ] Níveis de log configurados por ambiente
- [ ] Middleware de contexto implementado
```

### Por Request

```markdown
- [ ] traceId propagado/gerado
- [ ] spanId único para cada operação
- [ ] requestId nos headers de resposta
- [ ] Log de entrada e saída
- [ ] Duração registrada
- [ ] Erros com stack trace (não-prod)
```

### Segurança

```markdown
- [ ] Campos sensíveis na lista de redação
- [ ] Auto-sanitização ativa
- [ ] PII mascarado em todos os ambientes
- [ ] Tokens nunca logados
- [ ] IPs anonimizados em produção
```

### Observabilidade

```markdown
- [ ] Logs enviados para agregador (ELK/Loki/CloudWatch)
- [ ] Traces enviados para backend (Jaeger/Tempo/X-Ray)
- [ ] Dashboards criados
- [ ] Alertas configurados
- [ ] Retenção definida
```

---

## Red Flags - PARE Imediatamente

- [ ] PII em texto claro nos logs
- [ ] Tokens/senhas aparecendo em logs
- [ ] Logs sem traceId em produção
- [ ] Stack traces completos em produção
- [ ] Logs de request sem sanitização
- [ ] Volume de logs crescendo sem controle
- [ ] Logs sem timestamp ou timezone errado

---

## Anti-Patterns

| Não faça | Faça |
|----------|------|
| `logger.info(JSON.stringify(user))` | `logger.info('User action', { userId: user.id })` |
| `logger.error(error)` | `logger.error('Operation failed', { error: { name, message, code } })` |
| Logar request body completo | Logar campos relevantes sanitizados |
| Logar em formato texto livre | Usar structured logging (JSON) |
| Criar logger por arquivo | Usar logger singleton com contexto |
| Logar níveis debug em produção | Configurar nível por ambiente |
| Ignorar correlação | Sempre propagar traceId |

---

## Métricas de Logging

### Volume Saudável

| Nível | % Esperado | Alerta se |
|-------|------------|-----------|
| debug | 0% (prod) | > 0% |
| info | 70-80% | < 50% ou > 90% |
| warn | 10-20% | > 30% |
| error | 5-10% | > 15% |
| fatal | < 1% | > 1% |

### KPIs de Observabilidade

| Métrica | Target |
|---------|--------|
| Traces completos | > 99% |
| Logs com traceId | 100% |
| Latência de ingestão | < 5s |
| Retenção | 30+ dias |
| Tempo para encontrar root cause | < 15min |

---

## Comandos Rápidos

| Comando | Ação |
|---------|------|
| `setup logging` | Configura logging no projeto |
| `add tracing` | Adiciona distributed tracing |
| `check pii` | Verifica vazamento de PII nos logs |
| `log schema` | Mostra schema de log atual |
