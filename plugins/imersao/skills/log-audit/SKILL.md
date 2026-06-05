---
name: log-audit
description: Use when analyzing error logs, production failures, or recurring log patterns from Railway, files, or console output.
---

# Log Audit Skill

Auditoria completa de logs com detecção de padrões, análise de saúde, debugging assistido e verificação de compliance/PII.

## Core Principle

> **Logs contam a história do sistema. Esta skill extrai insights acionáveis.**

```
┌─────────────────────────────────────────────────────────────┐
│  FONTES           │  ANÁLISES          │  OUTPUT            │
├───────────────────┼────────────────────┼────────────────────┤
│  • Railway        │  • Padrões erro    │  • Relatório .md   │
│  • Arquivos .log  │  • Saúde/volume    │  • Tasks criadas   │
│  • Console dev    │  • Timeline trace  │  • Ações sugeridas │
│                   │  • PII/Compliance  │                    │
└───────────────────┴────────────────────┴────────────────────┘
```

---

## Comandos

### Comando Principal

```bash
/log-audit [subcommand] [options]
```

### Subcomandos

| Subcomando | Descrição | Exemplo |
|------------|-----------|---------|
| `railway` | Logs do Railway (default) | `/log-audit railway --last 6h` |
| `file` | Arquivo ou glob pattern | `/log-audit file logs/*.log` |
| `console` | Output do terminal dev | `/log-audit console` |
| `trace` | Timeline de um traceId | `/log-audit trace abc123` |
| `pii` | Apenas verificação PII | `/log-audit pii --fix` |
| `health` | Apenas métricas saúde | `/log-audit health` |

### Opções Globais

| Opção | Descrição | Default |
|-------|-----------|---------|
| `--last <duration>` | Período (1h, 6h, 24h, 7d) | `1h` |
| `--service <name>` | Filtrar por serviço | todos |
| `--output, -o <path>` | Caminho do relatório | `docs/audits/` |
| `--format <md\|json>` | Formato de saída | `md` |
| `--no-tasks` | Não criar tasks | false |
| `--severity <level>` | Severidade mínima | all |
| `--quiet, -q` | Apenas sumário | false |

---

## Fluxo de Execução

```
┌─────────────────────────────────────────────────────────────┐
│  1. COLETA                                                   │
│     ├─ Railway: railway logs --json                         │
│     ├─ Arquivo: parse JSON/texto estruturado                │
│     └─ Console: buffer recente do terminal                  │
│                                                              │
│  2. PARSE                                                    │
│     ├─ Extrair campos: timestamp, level, message, etc.      │
│     ├─ Validar schema (@repo/logger)                        │
│     └─ Normalizar mensagens (remover IDs dinâmicos)         │
│                                                              │
│  3. ANÁLISE                                                  │
│     ├─ Agrupar erros por similaridade                       │
│     ├─ Calcular severidade                                  │
│     ├─ Detectar PII leaks                                   │
│     └─ Gerar métricas de saúde                              │
│                                                              │
│  4. OUTPUT                                                   │
│     ├─ Gerar relatório markdown                             │
│     ├─ Criar tasks para issues críticas                     │
│     └─ Exibir sumário no terminal                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Análise de Erros

### Agrupamento por Similaridade

```typescript
// Normalização de mensagens
"User user_123 not found" → "User {id} not found"
"Request abc-def-ghi failed" → "Request {uuid} failed"
"Timeout after 5000ms" → "Timeout after {ms}ms"

// Critérios de agrupamento
1. Mensagem normalizada (similaridade > 80%)
2. Arquivo:linha (caller)
3. Error code/name
```

### Cálculo de Severidade

| Severidade | Critério |
|------------|----------|
| `critical` | level=fatal OU >50 ocorrências/hora |
| `high` | level=error + >10 ocorrências/hora |
| `medium` | level=error + <10 ocorrências/hora |
| `low` | level=warn recorrente |

### Detecção de Root Cause

```
┌─────────────────────────────────────────────────────────────┐
│  ERRO: "Database connection timeout"                         │
│  ↓                                                           │
│  Buscar padrões correlacionados:                            │
│  • Mesmo traceId com erro anterior?                         │
│  • Pico de erros no mesmo período?                          │
│  • Serviço específico afetado?                              │
│  ↓                                                           │
│  ROOT CAUSE SUGERIDO: "Redis connection pool exhausted"     │
└─────────────────────────────────────────────────────────────┘
```

---

## Detecção de PII

### Patterns Verificados

```typescript
const PII_PATTERNS = {
  email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
  cpf: /\d{3}\.\d{3}\.\d{3}-\d{2}/,
  phone: /\+?\d{10,13}/,
  creditCard: /\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}/,
  jwt: /eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+/,
  ipv4: /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/,
};
```

### Campos que DEVEM Estar Sanitizados

```typescript
const MUST_BE_REDACTED = [
  'password', 'senha', 'pwd',
  'token', 'accessToken', 'refreshToken',
  'apiKey', 'api_key', 'secret',
  'authorization', 'auth',
  'creditCard', 'cardNumber', 'cvv',
  'cpf', 'rg', 'ssn',
];
```

### Output de PII Leak

```markdown
## PII Leaks Detectados

### LEAK-001: Email não sanitizado
- **Arquivo:** `apps/api/src/modules/auth/login.ts:89`
- **Campo:** `user.email`
- **Valor encontrado:** `john.doe@example.com`
- **Correção:** Usar `sanitize.email()` do @repo/logger
```

---

## Validação de Schema

### Campos Obrigatórios (@repo/logger)

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| `timestamp` | ISO 8601 | ✅ |
| `level` | LogLevel | ✅ |
| `message` | string | ✅ |
| `service` | string | ✅ |
| `traceId` | string | ✅ (requests) |
| `spanId` | string | ✅ (requests) |
| `caller` | string | ✅ (errors) |

### Alertas de Schema

```markdown
## Problemas de Schema

| Problema | Ocorrências | Severidade |
|----------|-------------|------------|
| Logs sem traceId | 412 (3.2%) | medium |
| Errors sem caller | 23 (2.1%) | low |
| Timestamp inválido | 5 (0.04%) | low |
```

---

## Integração TaskNotes

### Criação Automática de Tasks

```
┌─────────────────────────────────────────────────────────────┐
│  Issue severidade >= high?                                   │
│  ├─ Não → Apenas reportar no relatório                      │
│  └─ Sim → Criar task via CLI                                │
│                                                              │
│  pnpm task:new "Fix: {título}" \                            │
│    -t BUG \                                                  │
│    -p {priority} \                                          │
│    -c "log-audit,{service}" \                               │
│    --sprint                                                  │
└─────────────────────────────────────────────────────────────┘
```

### Mapeamento Severidade → Prioridade

| Severidade | Prioridade | Auto-sprint |
|------------|------------|-------------|
| critical | high | ✅ |
| high | high | ✅ |
| medium | normal | ❌ |
| low | low | ❌ |

### Template de Task

```markdown
---
uid: BUG-{id}
status: open
priority: {priority}
tags: [task, bug, log-audit]
projects: ["[[sprint.md]]"]
designDoc: "[[docs/audits/{date}-log-audit.md]]"
---

# Fix: {título}

## Contexto (do audit)
- **Ocorrências:** {count} nas últimas {period}
- **Primeiro:** {first_occurrence}
- **Último:** {last_occurrence}
- **Arquivo:** `{caller}`

## TraceIds para investigação
{traceIds}

## Ação sugerida
{suggested_action}

Ver relatório completo: [[docs/audits/{date}-log-audit.md#{issue_id}]]
```

---

## Estrutura do Relatório

### Localização

```
docs/audits/
├── 2026-02-04-log-audit.md
├── 2026-02-03-log-audit.md
└── ...
```

### Seções do Relatório

1. **Sumário Executivo** - Métricas principais, status geral
2. **Distribuição por Nível** - Gráfico ASCII de levels
3. **Issues Críticas** - Detalhes + tasks criadas
4. **Issues Médias** - Listagem resumida
5. **PII Leaks** - Se detectados
6. **Problemas de Schema** - Validações falhando
7. **Recomendações** - Ações sugeridas

### Exemplo de Sumário

```markdown
## Sumário Executivo

| Métrica | Valor | Status |
|---------|-------|--------|
| Total de logs | 12,847 | - |
| Período | 00:00 - 12:00 | - |
| Erros únicos | 23 | 🔴 Alto |
| Warnings | 156 | 🟡 Normal |
| PII leaks | 2 | 🔴 Crítico |
| Logs sem traceId | 3.2% | 🟡 Atenção |

## Distribuição por Nível

fatal  ████░░░░░░░░░░░░░░░░  0.1% (12)
error  ████████░░░░░░░░░░░░  8.2% (1,053)
warn   ██████░░░░░░░░░░░░░░  6.1% (783)
info   ████████████████████  82.4% (10,587)
debug  ████░░░░░░░░░░░░░░░░  3.2% (412)
```

---

## Exemplos de Uso

### Auditoria Rápida (Railway)

```bash
/log-audit railway --last 1h
```

Output:
```
🔍 Analisando logs do Railway (última 1h)...

📊 Sumário:
  • 2,341 logs analisados
  • 5 erros únicos (2 críticos)
  • 0 PII leaks

📝 Tasks criadas:
  • BUG-042: Payment webhook timeout (high)

📄 Relatório: docs/audits/2026-02-04-log-audit.md
```

### Investigar Trace Específico

```bash
/log-audit trace abc123def456
```

Output:
```
🔍 Timeline do trace abc123def456

10:30:00.000 │ INFO  │ api      │ Request received POST /api/payments
10:30:00.012 │ INFO  │ api      │ User authenticated user_789
10:30:00.045 │ INFO  │ payment  │ Processing payment order_456
10:30:05.001 │ ERROR │ payment  │ Timeout connecting to gateway ← ROOT CAUSE
10:30:05.002 │ ERROR │ api      │ Payment failed
10:30:05.003 │ INFO  │ api      │ Response sent 500

Duração total: 5.003s
Erro detectado: Timeout no payment gateway
```

### Verificar PII

```bash
/log-audit pii --fix
```

Output:
```
🔍 Verificando PII nos logs...

🔴 2 leaks encontrados:

1. apps/api/src/modules/auth/login.ts:89
   Campo: user.email
   Correção: logger.info('Login', { email: sanitize.email(user.email) })

2. apps/web/src/lib/auth.ts:45
   Campo: phone
   Correção: Adicionar 'phone' ao sensitiveFields do logger

Aplicar correções automaticamente? [y/N]
```

---

## Comandos Relacionados

| Após auditoria | Comando |
|----------------|---------|
| Ver tasks criadas | `pnpm task:list --sprint` |
| Iniciar correção | `pnpm task:start BUG-042` |
| Ver relatório | `cat docs/audits/2026-02-04-log-audit.md` |
| Logs Railway live | `railway logs --follow` |

---

## Checklist de Execução

Ao executar `/log-audit`:

```markdown
- [ ] Identificar fonte de logs (railway/file/console)
- [ ] Coletar logs do período especificado
- [ ] Parsear e validar schema
- [ ] Agrupar erros por similaridade
- [ ] Calcular severidades
- [ ] Detectar PII leaks
- [ ] Gerar relatório markdown
- [ ] Criar tasks para issues críticas
- [ ] Exibir sumário no terminal
- [ ] Sugerir próximos passos
```

---

## Red Flags - Ações Imediatas

| Situação | Ação |
|----------|------|
| PII leak detectado | Task crítica + alerta imediato |
| >100 errors/hora | Investigar root cause urgente |
| Logs sem traceId >10% | Revisar middleware de logging |
| fatal logs | Verificar saúde do sistema |

---

## Referências

- [[references/severity-rules]] - Regras detalhadas de severidade
- [[references/pii-patterns]] - Patterns completos de PII
- [[examples/sample-report]] - Exemplo de relatório completo
- `packages/logger/AGENTS.md` - Schema do @repo/logger
