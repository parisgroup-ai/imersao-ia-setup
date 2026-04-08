---
name: code-quality
description: "Análise proativa e sob demanda de qualidade de código. Detecta código morto, duplicações, oportunidades de consolidação, complexidade excessiva e code smells. Sugere melhorias e executa correções com aprovação. Triggers on: código morto, dead code, duplicação, duplicated, cleanup, refactor, complexidade, smell, consolidar, health check, qualidade, quality."
version: 1.0.0
author: gustavo
tags: [quality, refactoring]
---

# Code Quality Skill

Esta skill mantém a saúde do código através de análise proativa e sob demanda. Detecta problemas, sugere consolidações e executa correções com aprovação.

## Core Principle

> **Código limpo não é luxo, é necessidade. Débito técnico acumula juros.**

```
┌─────────────────────────────────────────────────────────────┐
│  PROATIVO: Detectar durante desenvolvimento                 │
│  SOB DEMANDA: Análise profunda quando solicitado            │
│  INTERATIVO: Sugerir e corrigir com aprovação               │
└─────────────────────────────────────────────────────────────┘
```

## Categorias de Análise

| Categoria | O que detecta | Severidade |
|-----------|---------------|------------|
| 🪦 Código morto | Imports, variáveis, funções não usadas | Média |
| 🔄 Duplicação | Blocos similares, lógica repetida | Alta |
| 🧩 Consolidação | Componentes similares, padrões repetidos que virariam abstração | Alta |
| 🌀 Complexidade | Funções longas, aninhamento profundo, muitos parâmetros | Média |
| 🦨 Code smells | God classes, feature envy, primitive obsession | Alta |
| 🔗 Acoplamento | Dependências circulares, tight coupling | Alta |

---

## Modos de Operação

### Modo Proativo (Durante Desenvolvimento)

Ativado automaticamente. Alerta ao detectar problemas em qualquer arquivo visível.

```
1. Claude trabalhando em arquivo
       │
       ▼
2. Detecta problema em arquivo atual OU relacionado
       │
       ▼
3. Severidade Alta? ──Não──▶ Anota para relatório final
       │
      Sim
       │
       ▼
4. Alerta inline:
   "⚠️ Detectei [problema] em [arquivo:linha].
    Quer que eu analise/corrija agora ou depois?"
```

**Gatilhos proativos:**

| Problema | Threshold para alertar |
|----------|------------------------|
| Código morto óbvio | Import/variável não usada no arquivo atual |
| Duplicação | Bloco > 10 linhas duplicado |
| Consolidação | 3+ componentes/funções similares detectados |
| Complexidade | Função > 50 linhas ou aninhamento > 4 |
| Code smell | God class, feature envy detectado |
| Acoplamento | Dependência circular criada |

### Modo Sob Demanda (Análise Profunda)

Ativado por comandos do usuário.

**Triggers:**
- "analisa qualidade do código"
- "cleanup"
- "health check"
- "encontra código morto"
- "encontra duplicações"
- "sugere consolidações"

```
1. Usuário solicita análise
       │
       ▼
2. Define escopo:
   - Arquivo específico
   - Módulo/pasta
   - Projeto inteiro
       │
       ▼
3. Executa análise completa
       │
       ▼
4. Apresenta relatório categorizado
       │
       ▼
5. Usuário seleciona o que corrigir
       │
       ▼
6. Executa correções com aprovação incremental
```

---

## Técnicas de Detecção

### 🪦 Código Morto

```
Detectar:
├── Imports não utilizados
├── Variáveis declaradas mas não usadas
├── Funções/classes nunca chamadas
├── Parâmetros ignorados
├── Código após return/throw
├── Feature flags antigas (> 30 dias)
└── Arquivos órfãos (sem imports)

Técnicas: AST analysis, grep reverso, dependency graph
```

**Comandos de detecção:**

```bash
# Imports não usados (TypeScript)
npx ts-prune

# Exports não usados
npx ts-unused-exports tsconfig.json

# Dependências não usadas
npx depcheck
```

### 🔄 Duplicação

```
Detectar:
├── Blocos idênticos (> 10 linhas)
├── Blocos similares (> 70% match)
├── Lógica repetida com variações mínimas
└── Copy-paste com find/replace

Threshold: Reportar quando duplicado em 2+ lugares
```

**Padrões de duplicação:**

| Tipo | Exemplo | Ação |
|------|---------|------|
| Idêntica | Mesmo código em 2 arquivos | Extrair para shared |
| Paramétrica | Mesmo código, valores diferentes | Criar função com parâmetros |
| Estrutural | Mesma estrutura, nomes diferentes | Criar abstração |

### 🧩 Consolidação

```
Detectar:
├── Componentes com props similares (> 60% overlap)
├── Funções com assinatura e corpo parecidos
├── Hooks com lógica repetida
├── Tipos/interfaces quase idênticos
└── Padrões que se repetem 3+ vezes

Sugerir:
├── Componente base + variantes
├── Factory functions
├── Hooks compartilhados
└── Generics/tipos utilitários
```

**Exemplos de consolidação:**

```typescript
// ❌ ANTES: Componentes similares
// UserCard.tsx - 80 linhas
// ProfileCard.tsx - 75 linhas (70% similar)
// MemberCard.tsx - 70 linhas (65% similar)

// ✅ DEPOIS: Componente base + variantes
// Card.tsx - 60 linhas (base)
// UserCard.tsx - 15 linhas (extends Card)
// ProfileCard.tsx - 12 linhas (extends Card)
// MemberCard.tsx - 10 linhas (extends Card)
```

```typescript
// ❌ ANTES: Funções repetidas
function validateEmail(email: string) { /* regex + error */ }
function validatePhone(phone: string) { /* regex + error */ }
function validateCPF(cpf: string) { /* regex + error */ }

// ✅ DEPOIS: Factory
const validateEmail = createValidator(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Email inválido');
const validatePhone = createValidator(/^\d{10,11}$/, 'Telefone inválido');
const validateCPF = createValidator(/^\d{11}$/, 'CPF inválido');
```

### 🌀 Complexidade

```
Detectar:
├── Funções > 50 linhas
├── Aninhamento > 4 níveis
├── Complexidade ciclomática > 10
├── Parâmetros > 5
└── Arquivos > 300 linhas

Sugerir:
├── Extract function
├── Early return
├── Strategy pattern
└── Decomposição
```

**Métricas de complexidade:**

| Métrica | Bom | Aceitável | Problemático |
|---------|-----|-----------|--------------|
| Linhas/função | < 20 | 20-50 | > 50 |
| Aninhamento | < 3 | 3-4 | > 4 |
| Ciclomática | < 5 | 5-10 | > 10 |
| Parâmetros | < 3 | 3-5 | > 5 |
| Linhas/arquivo | < 200 | 200-300 | > 300 |

### 🦨 Code Smells

```
Detectar:
├── God class (> 10 métodos públicos, > 500 linhas)
├── Feature envy (usa mais de outro objeto que do próprio)
├── Primitive obsession (strings/numbers que deveriam ser tipos)
├── Long parameter list (> 5 parâmetros)
├── Data clumps (grupos de dados sempre juntos)
└── Shotgun surgery (mudança requer N arquivos)
```

**Code smells e refatorações:**

| Smell | Sintoma | Refatoração |
|-------|---------|-------------|
| God class | Classe faz tudo | Extract class |
| Feature envy | Método usa muito de outra classe | Move method |
| Primitive obsession | Strings como IDs, status | Value objects |
| Data clump | Mesmos 3 params juntos | Parameter object |
| Long method | Função > 50 linhas | Extract method |

### 🔗 Acoplamento

```
Detectar:
├── Dependências circulares (A → B → C → A)
├── Imports entre camadas incorretos (infra → domain)
├── Tight coupling (classes inseparáveis)
└── God modules (importado por > 50% do projeto)
```

**Regras de dependência (Clean Architecture):**

```
✅ PERMITIDO:
Presentation → Application → Domain
Infrastructure → Application

❌ PROIBIDO:
Domain → Application (direção errada)
Domain → Infrastructure (dependência externa)
Application → Presentation (direção errada)
```

---

## Formato do Relatório

### Relatório Resumido

```markdown
## 📊 Code Quality Report

**Escopo**: {{projeto/módulo/arquivo}}
**Data**: {{timestamp}}

### Resumo
| Categoria | Encontrados | Críticos | Ação |
|-----------|-------------|----------|------|
| 🪦 Código morto | 12 | 3 | Remover |
| 🔄 Duplicação | 5 | 2 | Extrair |
| 🧩 Consolidação | 8 | 4 | Unificar |
| 🌀 Complexidade | 6 | 1 | Refatorar |
| 🦨 Code smells | 3 | 1 | Refatorar |
| 🔗 Acoplamento | 2 | 2 | Desacoplar |

**Score geral**: {{0-100}}/100
**Tendência**: {{melhorando/estável/piorando}}
```

### Relatório Detalhado (por categoria)

```markdown
### 🧩 Consolidação (8 encontrados, 4 críticos)

#### [CRÍTICO] Componentes similares: UserCard, ProfileCard, MemberCard

**Arquivos**:
- `src/components/UserCard.tsx` (80 linhas)
- `src/components/ProfileCard.tsx` (75 linhas)
- `src/components/MemberCard.tsx` (70 linhas)

**Similaridade**: 70%

**Sugestão**:
Criar componente base `Card` com variantes via props.

**Impacto**:
- Redução: ~120 linhas
- Arquivos afetados: 3 → 4 (novo base)
- Manutenção: Centralizada

**Ações**:
- [ ] `corrige este` - Executa consolidação
- [ ] `mostra diff` - Preview das mudanças
- [ ] `ignora` - Marca como intencional
```

### Ações Disponíveis

| Comando | Ação |
|---------|------|
| `corrige tudo` | Executa todas as correções com aprovação |
| `corrige [categoria]` | Foca em uma categoria |
| `corrige [item]` | Corrige item específico |
| `mostra detalhes [item]` | Detalha um problema |
| `mostra diff [item]` | Preview das mudanças |
| `ignora [item]` | Marca como intencional |
| `exporta relatório` | Gera markdown do relatório |

