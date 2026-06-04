---
name: agents-maintenance
description: "Use when working in monorepos with multiple apps/packages, when CLAUDE.md or AGENTS.md files need validation, when detecting broken links, redundant or conflicting instructions, vague instructions, incomplete coverage, or inconsistent formatting - validates structure, links, and instruction quality with interactive correction mode"
version: 1.0.0
author: gustavo
tags: [maintenance, monorepo, documentation]
---

# Agents Maintenance

## Overview

Mantém consistência entre arquivos de instrução (CLAUDE.md, AGENTS.md, READMEs) em monorepos. Valida estrutura, links bidirecionais, timestamps e detecta redundâncias/conflitos.

**Princípio central**: Cada nível do monorepo tem um par `CLAUDE.md → [[AGENTS.md]]`, formando hierarquia navegável.

## When to Use

**Use quando**:
- Iniciar sessão em monorepo com múltiplos apps/packages
- Criar/mover/renomear apps ou packages
- Suspeitar de instruções desatualizadas ou conflitantes
- Links quebrados entre arquivos de instrução
- Após refatorações que movem código entre módulos

**Não use quando**:
- Projeto single-app sem subdiretórios
- Apenas editando código (não instruções)

## Estrutura Esperada

```
raiz/
├── CLAUDE.md ─────→ [[AGENTS.md]]
├── AGENTS.md       (índice geral de agentes)
│
├── apps/
│   └── app1/
│       ├── CLAUDE.md ─→ [[AGENTS.md]]
│       ├── AGENTS.md ─→ [[../../AGENTS.md]] (link pai)
│       └── README.md
│
└── packages/
    └── shared/
        ├── CLAUDE.md ─→ [[AGENTS.md]]
        ├── AGENTS.md ─→ [[../../AGENTS.md]] (link pai)
        └── README.md
```

**Regras**:
1. Todo CLAUDE.md DEVE ter `[[AGENTS.md]]`
2. Todo AGENTS.md filho DEVE linkar para pai
3. AGENTS.md raiz lista todos os agentes/apps

## Checklist de Validação

Execute na ordem:

### 1. Descoberta e Identificação de Candidatos

**1.1 Encontrar arquivos existentes**:
```bash
find . -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "README.md"
```

**1.2 Identificar áreas que DEVERIAM ter AGENTS.md**:

| Indicador | Por que precisa de AGENTS.md |
|-----------|------------------------------|
| Tem `package.json` próprio | App/package independente |
| Tem `tsconfig.json` próprio | Configuração específica |
| Tem pasta `src/` ou `lib/` | Código fonte significativo |
| Tem pasta `tests/` ou `__tests__/` | Lógica testável |
| Tem `Dockerfile` | Deploy independente |
| Tem `README.md` sem AGENTS.md | Documentado mas sem instruções |
| Diretório em `apps/`, `packages/`, `services/`, `modules/` | Convenção de monorepo |
| Mais de 10 arquivos `.ts`/`.js` | Volume de código significativo |

**Comando para descobrir candidatos**:
```bash
# Diretórios com package.json mas sem AGENTS.md
find . -name "package.json" -exec dirname {} \; | while read dir; do
  [ ! -f "$dir/AGENTS.md" ] && echo "CANDIDATO: $dir"
done

# Diretórios em apps/ ou packages/ sem AGENTS.md
find ./apps ./packages -mindepth 1 -maxdepth 1 -type d | while read dir; do
  [ ! -f "$dir/AGENTS.md" ] && echo "CANDIDATO: $dir"
done
```

**Prioridade de criação**:
```
🔴 Alta:   apps/* e packages/* sem AGENTS.md
🟡 Média:  Diretórios com package.json próprio
🟢 Baixa:  Diretórios com apenas README.md
```

### 2. Verificação de Pares
| Verificação | Ação se falhar |
|-------------|----------------|
| AGENTS.md existe mas CLAUDE.md não | Criar CLAUDE.md com template |
| CLAUDE.md não contém `[[AGENTS.md]]` | Adicionar link |

### 3. Verificação de Links
| Verificação | Ação se falhar |
|-------------|----------------|
| Link `[[arquivo]]` não existe | Criar arquivo ou remover link |
| Arquivo linkado não linka de volta | Adicionar link bidirecional |
| AGENTS.md filho não linka para pai | Adicionar `[[../AGENTS.md]]` |

### 4. Verificação de Timestamps
```bash
# Comparar datas de modificação
stat -f "%m %N" CLAUDE.md AGENTS.md | sort -n
```
Se CLAUDE.md mais recente que AGENTS.md relacionado → possível desatualização.

### 5. Verificação de Conteúdo

**Redundância** (mesma instrução em múltiplos níveis):
```markdown
# AGENTS.md raiz
Use TypeScript para todo código.

# apps/web/AGENTS.md
Use TypeScript para todo código.  ← REDUNDANTE
```
→ Manter apenas no pai (herança implícita)

**Conflito** (instrução contradiz pai):
```markdown
# AGENTS.md raiz
Use Jest para testes.

# apps/web/AGENTS.md
Use Vitest para testes.  ← CONFLITO
```
→ Se intencional, marcar com `@override`:
```markdown
@override teste: Use Vitest (velocidade para Vite apps)
```

### 6. Verificação de Qualidade de Instruções

Avaliar cada instrução nos 4 critérios:

#### 6.1 Clareza e Especificidade

| Problema | Exemplo Ruim | Exemplo Bom |
|----------|--------------|-------------|
| Vago | "Escreva bom código" | "Use TypeScript strict mode" |
| Ambíguo | "Teste adequadamente" | "Cobertura mínima 80% em use cases" |
| Subjetivo | "Código limpo" | "Funções com máximo 20 linhas" |

**Red flags**: "adequado", "bom", "limpo", "correto", "melhor", sem métricas.

#### 6.2 Completude

AGENTS.md deve cobrir (quando aplicável):

| Área | Obrigatório | Exemplos |
|------|-------------|----------|
| Stack/Linguagem | Sim | TypeScript, Node 20, pnpm |
| Padrões de código | Sim | ESLint config, Prettier |
| Testes | Sim | Framework, cobertura mínima |
| Convenções de naming | Recomendado | camelCase, kebab-case para arquivos |
| Estrutura de pastas | Recomendado | Onde criar novos arquivos |
| Commits | Opcional | Conventional commits |
| CI/CD | Opcional | Pipeline obrigatória |

**Verificar**: Falta alguma área essencial? Há seções vazias ou com `{{placeholder}}`?

#### 6.3 Acionabilidade

Instrução acionável = agente sabe EXATAMENTE o que fazer.

| Não Acionável | Acionável |
|---------------|-----------|
| "Siga boas práticas de segurança" | "Sanitize inputs com zod antes de usar" |
| "Documente o código" | "JSDoc em funções públicas exportadas" |
| "Use padrões do projeto" | "Siga estrutura em `src/modules/exemplo/`" |
| "Mantenha consistência" | "Use o hook `useApiQuery` para fetching" |

**Teste**: Se der a instrução para outro dev sem contexto, ele consegue executar?

#### 6.4 Consistência de Formato

Todos os AGENTS.md devem seguir mesmo padrão:

| Elemento | Padrão Esperado |
|----------|-----------------|
| Seções | Mesmo nome e ordem em todos |
| Instruções | Bullets ou tabelas (não misturar) |
| Exemplos de código | Mesmo estilo de formatação |
| Links | Sempre `[[relativo]]`, nunca absoluto |
| Data | Formato ISO: `YYYY-MM-DD` |

**Verificar**: Compare AGENTS.md de diferentes apps - estão consistentes?

## Modo Interativo de Correção

Para cada problema encontrado, perguntar:

**Candidato a AGENTS.md** (área sem instruções):
- (a) Criar CLAUDE.md + AGENTS.md com templates
- (b) Apenas AGENTS.md (CLAUDE.md não necessário)
- (c) Marcar como ignorado (adicionar a `.agentsignore`)
- (s) Pular

**Links quebrados**:
- (a) Criar arquivo faltante
- (b) Remover link
- (c) Corrigir caminho
- (s) Pular

**Pares incompletos**:
- (a) Criar CLAUDE.md com template
- (b) Criar AGENTS.md com template
- (c) Ignorar diretório
- (s) Pular

**Redundância**:
- (a) Remover do filho (herdar do pai)
- (b) Manter em ambos (marcar intencional)
- (c) Mover para o pai
- (s) Pular

**Conflito**:
- (a) Manter versão do pai
- (b) Manter versão do filho + `@override`
- (c) Editar manualmente
- (s) Pular

**Instrução vaga/não-acionável**:
- (a) Reescrever com métrica específica
- (b) Adicionar exemplo concreto
- (c) Remover instrução (não agrega valor)
- (s) Pular

**Área faltante (completude)**:
- (a) Adicionar seção com template
- (b) Marcar como N/A (não aplicável)
- (c) Herdar do pai (se existir)
- (s) Pular

**Inconsistência de formato**:
- (a) Padronizar com base no raiz
- (b) Padronizar com base no mais completo
- (c) Definir novo padrão
- (s) Pular

**Sempre mostrar diff antes de salvar.**

## Templates

### CLAUDE.md (entry point)

```markdown
# {{nome}}

> Entry point. Leia primeiro.

## Instruções do Agente

→ [[AGENTS.md]]

## Contexto

- **O quê**: {{descrição}}
- **Stack**: {{tecnologias}}
- **Pai**: [[../../CLAUDE.md]]

## Links

- [[README.md]] - Documentação técnica
- [[../../AGENTS.md]] - Índice geral

---
*Atualizado: {{data}}*
```

### AGENTS.md (raiz - índice)

```markdown
# Agentes do Projeto

> Índice de todos os agentes/apps.

## Hierarquia

| Agente | Caminho | Descrição |
|--------|---------|-----------|
| {{nome}} | [[apps/x/AGENTS.md]] | {{desc}} |

## Instruções Globais

{{instruções para TODOS os agentes}}

## Herança

Instruções aqui se aplicam a filhos.
Filhos podem sobrescrever com `@override: razão`.

---
*Atualizado: {{data}}*
```

### AGENTS.md (filho)

```markdown
# Agente: {{nome}}

> Instruções específicas.

## Herança

- **Pai**: [[../../AGENTS.md]]

## Instruções Específicas

{{apenas o que é diferente do pai}}

## Sobrescritas

@override {{item}}: {{valor}} ({{razão}})

## Links

- [[CLAUDE.md]]
- [[README.md]]

---
*Atualizado: {{data}}*
```

## Comandos

| Comando | Descrição |
|---------|-----------|
| "Validar agentes" | Checklist completo + modo interativo |
| "Criar estrutura de agentes" | Cria par CLAUDE.md + AGENTS.md |
| "Adicionar agente em X" | Cria estrutura + atualiza índice |
| "Relatório de agentes" | Lista hierarquia sem corrigir |
| "Sync timestamps" | Atualiza datas após revisão |

## Common Mistakes

### Estrutura
| Erro | Correção |
|------|----------|
| Esquecer link bidirecional | Sempre verificar: A linka B? B linka A? |
| Duplicar instrução do pai | Usar herança implícita |
| Conflito sem `@override` | Marcar sobrescritas intencionais |
| CLAUDE.md sem link para AGENTS.md | Primeira linha após título: `→ [[AGENTS.md]]` |
| Não atualizar índice raiz | Após criar novo agente, adicionar na tabela |

### Qualidade de Instruções
| Erro | Correção |
|------|----------|
| Instrução vaga ("bom código") | Adicionar métrica: "max 20 linhas por função" |
| Sem exemplos concretos | Adicionar: "como em `src/modules/user/`" |
| Área obrigatória faltando | Adicionar seção mesmo que herde do pai |
| Misturar formatos (bullets + tabelas) | Escolher um e padronizar |
| Usar termos subjetivos | Substituir por critérios objetivos mensuráveis |
| Placeholder `{{}}` não preenchido | Preencher ou remover seção |
| Instrução não-testável | Reformular para ter critério de sucesso claro |

## Arquivo .agentsignore

Para ignorar diretórios que não precisam de AGENTS.md:

```bash
# .agentsignore na raiz do projeto
node_modules/
dist/
build/
.git/
coverage/
scripts/          # Scripts de build, não precisam de instruções
tools/internal/   # Ferramentas internas simples
```

**Quando ignorar**:
- Diretórios gerados (dist, build, node_modules)
- Scripts simples sem lógica de negócio
- Ferramentas internas triviais
- Fixtures de teste

**Quando NÃO ignorar**:
- Apps com deploy independente
- Packages consumidos por outros
- Módulos com regras de negócio
- Qualquer código que outro dev pode modificar

## Integração

- **memory-bank**: CLAUDE.md pode linkar `[[memory-bank/]]`
- **obsidian-docs**: Usa convenção `[[link]]` compatível
- **code-quality**: Executar após refatorações grandes
