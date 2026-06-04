# Severity Rules

Regras detalhadas para cálculo de severidade de issues detectadas.

## Matriz de Severidade

```
┌─────────────────────────────────────────────────────────────┐
│  CRITICAL (Ação imediata)                                    │
├─────────────────────────────────────────────────────────────┤
│  • level = fatal (qualquer ocorrência)                       │
│  • level = error + >50 ocorrências/hora                     │
│  • PII leak detectado (qualquer)                            │
│  • Serviço principal indisponível                           │
│  • Dados corrompidos/perdidos                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  HIGH (Resolver no sprint atual)                             │
├─────────────────────────────────────────────────────────────┤
│  • level = error + >10 ocorrências/hora                     │
│  • Funcionalidade core degradada                            │
│  • Timeout em serviços externos                             │
│  • Erros de autenticação em massa                           │
│  • Schema validation failing em >5% dos logs                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  MEDIUM (Backlog prioritário)                                │
├─────────────────────────────────────────────────────────────┤
│  • level = error + <10 ocorrências/hora                     │
│  • Funcionalidade secundária afetada                        │
│  • Retry success após falha inicial                         │
│  • Logs sem traceId (3-10%)                                 │
│  • Erros de validação de input                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  LOW (Backlog)                                               │
├─────────────────────────────────────────────────────────────┤
│  • level = warn recorrente                                  │
│  • Deprecation warnings                                      │
│  • Performance degradada (não crítica)                      │
│  • Logs sem caller em errors                                │
│  • Edge cases conhecidos                                     │
└─────────────────────────────────────────────────────────────┘
```

## Fórmulas de Cálculo

### Taxa de Erro

```typescript
const errorRate = (errorCount / totalLogs) * 100;

// Thresholds
const thresholds = {
  critical: 10,  // >10% = crítico
  high: 5,       // >5% = alto
  medium: 2,     // >2% = médio
  low: 0,        // qualquer = baixo
};
```

### Frequência de Ocorrência

```typescript
const occurrencesPerHour = errorCount / periodInHours;

// Thresholds
const thresholds = {
  critical: 50,  // >50/hora
  high: 10,      // >10/hora
  medium: 5,     // >5/hora
  low: 0,        // qualquer
};
```

### Score Composto

```typescript
function calculateSeverity(error: ErrorGroup): Severity {
  const scores = {
    level: getLevelScore(error.level),           // 0-40
    frequency: getFrequencyScore(error.rate),    // 0-30
    impact: getImpactScore(error.service),       // 0-20
    recency: getRecencyScore(error.lastSeen),    // 0-10
  };

  const total = Object.values(scores).reduce((a, b) => a + b, 0);

  if (total >= 80) return 'critical';
  if (total >= 60) return 'high';
  if (total >= 40) return 'medium';
  return 'low';
}

function getLevelScore(level: string): number {
  return { fatal: 40, error: 30, warn: 15, info: 0 }[level] || 0;
}

function getFrequencyScore(rate: number): number {
  if (rate > 50) return 30;
  if (rate > 10) return 20;
  if (rate > 5) return 10;
  return 0;
}

function getImpactScore(service: string): number {
  const criticalServices = ['api', 'auth', 'payment', 'database'];
  return criticalServices.includes(service) ? 20 : 10;
}

function getRecencyScore(lastSeen: Date): number {
  const hoursAgo = (Date.now() - lastSeen.getTime()) / (1000 * 60 * 60);
  if (hoursAgo < 1) return 10;
  if (hoursAgo < 6) return 5;
  return 0;
}
```

## Escalation Rules

### Auto-escalation

```
┌─────────────────────────────────────────────────────────────┐
│  MEDIUM → HIGH                                               │
│  Se: mesma issue aparece em 3+ auditorias consecutivas      │
├─────────────────────────────────────────────────────────────┤
│  HIGH → CRITICAL                                             │
│  Se: issue não resolvida em 48h + ainda ocorrendo           │
└─────────────────────────────────────────────────────────────┘
```

### De-escalation

```
┌─────────────────────────────────────────────────────────────┐
│  Ocorrências = 0 nas últimas 24h                            │
│  → Mover para "Resolved" no relatório                       │
│  → Não criar nova task (issue resolvida)                    │
└─────────────────────────────────────────────────────────────┘
```

## Serviços Críticos

Lista de serviços que automaticamente elevam a severidade:

| Serviço | Multiplicador | Motivo |
|---------|---------------|--------|
| `api` | 1.5x | Core do sistema |
| `auth` | 2x | Segurança |
| `payment` | 2x | Financeiro |
| `database` | 2x | Dados |
| `web` | 1x | Frontend |
| `mcp-server` | 1x | Ferramentas |
| `ana-service` | 1x | AI (não crítico) |

## Exemplos

### Exemplo 1: Critical

```json
{
  "level": "error",
  "message": "Payment processing failed",
  "service": "payment",
  "occurrences": 87,
  "periodHours": 1
}
```

Score: `30 (error) + 30 (>50/h) + 20 (payment) + 10 (recent) = 90` → **CRITICAL**

### Exemplo 2: High

```json
{
  "level": "error",
  "message": "External API timeout",
  "service": "api",
  "occurrences": 25,
  "periodHours": 2
}
```

Score: `30 (error) + 20 (12.5/h) + 20 (api) + 5 (recent) = 75` → **HIGH**

### Exemplo 3: Medium

```json
{
  "level": "error",
  "message": "User not found",
  "service": "web",
  "occurrences": 8,
  "periodHours": 4
}
```

Score: `30 (error) + 0 (2/h) + 10 (web) + 0 (not recent) = 40` → **MEDIUM**
