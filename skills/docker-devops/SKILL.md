---
name: docker-devops
description: "Create optimized Docker configurations, docker-compose setups, Kubernetes manifests, and CI/CD pipelines. Use when containerizing applications, setting up deployment infrastructure, or automating builds. Triggers on: Docker, Dockerfile, container, docker-compose, Kubernetes, k8s, CI/CD, GitHub Actions, deployment."
version: 1.1.0
author: gustavo
tags: [docker, devops, ci-cd, deployment]
---

# Docker & DevOps Skill

## Multi-Stage Dockerfile (Node.js)

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production
FROM node:20-alpine AS production
WORKDIR /app

# Security: non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/main.js"]
```

## Docker Compose

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      target: production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s

volumes:
  postgres_data:
  redis_data:
```

## GitHub Actions CI/CD

```yaml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run test:coverage

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: \${{ github.actor }}
          password: \${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          push: \${{ github.ref == 'refs/heads/main' }}
          tags: ghcr.io/\${{ github.repository }}:\${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy
        run: echo "Deploy to production"
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
      containers:
        - name: app
          image: ghcr.io/org/app:latest
          ports:
            - containerPort: 3000
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
```

## .dockerignore

```
node_modules
.git
.env*
!.env.example
*.md
coverage
dist
.next
```

## Checklist

- [ ] Multi-stage builds
- [ ] Non-root user
- [ ] Health checks
- [ ] Resource limits
- [ ] No secrets in images
- [ ] .dockerignore configured
- [ ] CI/CD pipeline

---

## Integração com Reviewer (ADR/PR)

> **Mudanças de infraestrutura podem causar downtime. Use o skill `reviewer` para decisões de deploy e infra.**

### Quando Acionar o Reviewer

| Mudança | Requer ADR | Motivo |
|---------|------------|--------|
| Nova base image | ✅ Sim | Pode introduzir vulnerabilidades |
| Mudança em CI/CD pipeline | ✅ Sim | Afeta todo o processo de deploy |
| Alteração de recursos (CPU/memory) | ✅ Sim | Impacto em custos e performance |
| Nova variável de ambiente | ⚠️ Depende | Se é secret ou afeta comportamento, sim |
| Mudança em Kubernetes manifests | ✅ Sim | Pode causar downtime |
| Alteração de replicas/scaling | ✅ Sim | Impacto em custos e disponibilidade |
| Mudança em health checks | ✅ Sim | Pode afetar rollouts |
| Nova integração de serviço | ✅ Sim | Dependência externa |
| Mudança em volumes/persistência | ✅ Sim | Risco de perda de dados |
| Atualização de versão de serviço | ⚠️ Depende | Se breaking change, sim |

### Classificação de Impacto de Infra

```
┌─────────────────────────────────────────────────────────────┐
│  🔴 CRÍTICO (ADR + Janela de Manutenção + Rollback Ready)   │
├─────────────────────────────────────────────────────────────┤
│  • Mudança em database/storage                              │
│  • Alteração de rede/DNS                                    │
│  • Migração de cloud provider                               │
│  • Mudança em secrets management                            │
│  • Alteração de certificados TLS                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🟡 MÉDIO (ADR + Deploy em Staging primeiro)                │
├─────────────────────────────────────────────────────────────┤
│  • Nova base image                                          │
│  • Mudança em CI/CD                                         │
│  • Alteração de recursos                                    │
│  • Mudança em replicas/scaling                              │
│  • Atualização de dependências de runtime                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🟢 BAIXO (Pode aplicar com monitoramento)                  │
├─────────────────────────────────────────────────────────────┤
│  • Adicionar label/annotation                               │
│  • Ajuste fino de health check timing                       │
│  • Atualização de .dockerignore                             │
│  • Melhoria em build cache                                  │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo para Mudanças de Infra

```
1. Identificar mudança de infra
       │
       ▼
2. Classificar impacto (Crítico/Médio/Baixo)
       │
       ▼
3. Crítico ou Médio? ──Não──▶ Aplicar com monitoramento
       │
      Sim
       │
       ▼
4. Acionar skill `reviewer`
       │
       ▼
5. Criar proposta com:
   - Impacto em disponibilidade
   - Estimativa de custo
   - Plano de rollback
   - Janela de manutenção (se crítico)
       │
       ▼
6. Aprovação → Gerar ADR
       │
       ▼
7. Deploy em staging
       │
       ▼
8. Validar em staging
       │
       ▼
9. Deploy em production
       │
       ▼
10. PR com link para ADR
```

### Campos Específicos no ADR de Infra

Além do template padrão do reviewer, incluir:

```markdown
## Infra-Specific

### Impacto em Disponibilidade
- Downtime esperado: {{zero/estimativa}}
- Estratégia de deploy: {{rolling/blue-green/canary}}
- Janela de manutenção: {{se necessário}}

### Custos
- Custo atual: {{valor}}
- Custo após mudança: {{valor}}
- Variação: {{percentual}}

### Recursos
| Recurso | Antes | Depois |
|---------|-------|--------|
| CPU | {{value}} | {{value}} |
| Memory | {{value}} | {{value}} |
| Replicas | {{value}} | {{value}} |
| Storage | {{value}} | {{value}} |

### Dependências
- Serviços afetados: {{lista}}
- Ordem de deploy: {{sequência}}

### Rollback

**Trigger automático**:
- Health check failing > {{N}} vezes
- Error rate > {{X}}%
- Latency p99 > {{Y}}ms

**Comando de rollback**:
\`\`\`bash
{{comando_de_rollback}}
\`\`\`

### Validação Pós-Deploy
- [ ] Health checks passando
- [ ] Métricas dentro do baseline
- [ ] Logs sem erros críticos
- [ ] Smoke tests executados
```

### Convenções de Commit para Infra

```
[ADR-NNNN] infra(docker): upgrade base image to node:20

[ADR-NNNN] infra(k8s): increase replicas for high availability

[ADR-NNNN] infra(ci): add security scanning to pipeline

[ADR-NNNN] infra(breaking): migrate from ECS to Kubernetes
```

### Red Flags - PARE e Use Reviewer

- [ ] Qualquer mudança em production sem staging primeiro
- [ ] Alteração de base image sem security scan
- [ ] Mudança em secrets ou credentials
- [ ] Alteração que pode causar downtime
- [ ] Mudança em persistência/volumes
- [ ] Remoção de health checks ou probes

### Deploy Checklist (incluir no PR)

```markdown
## Deploy Checklist

### Pré-Deploy
- [ ] ADR aprovado (se necessário)
- [ ] Testado em staging
- [ ] Rollback plan documentado
- [ ] Monitoramento configurado
- [ ] Time de plantão avisado (se crítico)

### Deploy
- [ ] Deploy em staging ✅
- [ ] Validação em staging ✅
- [ ] Deploy em production
- [ ] Smoke tests

### Pós-Deploy
- [ ] Health checks verdes
- [ ] Métricas estáveis
- [ ] Sem erros em logs
- [ ] Usuários não impactados
```

### Nunca Faça Sem ADR

| Ação | Por quê |
|------|---------|
| Deploy direto em prod | Sem validação em staging |
| Mudar base image sem scan | Pode ter vulnerabilidades |
| Remover health check | Deploys cegos sem validação |
| Aumentar recursos 10x | Impacto significativo em custos |
| Mudar secrets em runtime | Risco de exposição |
