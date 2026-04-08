---
name: i18n-audit
description: "Audita código fonte para encontrar textos hardcoded em português que precisam usar o sistema de tradução (i18n). Detecta strings em TSX/TS que deveriam usar t() ou useTranslations. Triggers on: texto hardcoded, hardcoded text, auditoria i18n, i18n audit, tradução faltando, missing translation in code, portuguese text, texto português."
version: 1.0.0
author: gustavo
tags: [i18n, audit, translation, code-quality]
---

# i18n Audit Skill

Audita código fonte para encontrar textos em português que estão hardcoded e precisam ser migrados para o sistema de internacionalização (i18n).

## Core Principle

> **Todo texto visível ao usuário deve vir do sistema de tradução. Texto hardcoded é dívida de i18n.**

```
┌─────────────────────────────────────────────────────────────┐
│  PROATIVO: Detectar durante desenvolvimento                 │
│  SOB DEMANDA: Auditoria completa quando solicitado          │
│  INTERATIVO: Sugerir chaves e adicionar traduções           │
└─────────────────────────────────────────────────────────────┘
```

## Diferença desta Skill vs i18n-maintenance

| Skill | Foco | O que detecta |
|-------|------|---------------|
| **i18n-audit** (esta) | Código fonte (TSX/TS) | Textos hardcoded que deveriam usar `t()` |
| i18n-maintenance | Arquivos JSON | Chaves faltando, órfãs, estrutura |

**Use esta skill quando:** Procurando texto português no código
**Use i18n-maintenance quando:** Validando arquivos de tradução

## O Que Detectar

### Padrões de Texto Hardcoded

| Padrão | Exemplo | Severidade |
|--------|---------|------------|
| String literal em JSX | `<h1>Bem-vindo</h1>` | Alta |
| Atributo com texto | `placeholder="Digite seu nome"` | Alta |
| String em template | `` `Olá ${name}` `` | Alta |
| Texto em array | `['Opção 1', 'Opção 2']` | Média |
| Texto em objeto | `{ label: 'Nome' }` | Média |
| Constantes com texto | `const TITLE = 'Meu App'` | Alta |
| Toast/notificação | `toast.success('Salvo!')` | Alta |
| Erro com mensagem | `throw new Error('Usuário não encontrado')` | Média |
| Validação | `'Campo obrigatório'` | Alta |

### Padrões a IGNORAR

| Padrão | Motivo |
|--------|--------|
| Nomes técnicos | `console.log`, `className`, `id` |
| Chaves de objeto | `{ userId: 123 }` |
| URLs e paths | `/api/users`, `https://...` |
| Regex | `/^[a-z]+$/` |
| Código/IDs | `'user-123'`, `'btn-submit'` |
| Imports | `import ... from '...'` |
| TypeScript types | `type Status = 'active' \| 'inactive'` |
| Data attributes | `data-testid="..."` |
| CSS classes | `'flex items-center'` |
| Logs técnicos | `logger.debug('Processing...')` |

---

## Comandos de Detecção

### Busca Rápida (Bash)

```bash
# Textos em português em arquivos TSX (padrões comuns)
rg -n ">[A-ZÁÉÍÓÚÃÕÂÊÔ][a-záéíóúãõâêôç\s]+<" apps/web/src --type tsx

# Placeholders em português
rg -n 'placeholder="[^"]*[áéíóúãõâêôçÁÉÍÓÚÃÕÂÊÔÇ][^"]*"' apps/web/src

# Strings com acentos (indicativo de português)
rg -n '"[^"]*[áéíóúãõâêôçÁÉÍÓÚÃÕÂÊÔÇ][^"]*"' apps/web/src --type ts --type tsx

# Labels em português
rg -n "label[=:].*['\"][^'\"]*[áéíóúãõâêôç][^'\"]*['\"]" apps/web/src

# Títulos hardcoded
rg -n "title[=:].*['\"][^'\"]*[áéíóúãõâêôç][^'\"]*['\"]" apps/web/src

# Mensagens de erro
rg -n "message[=:].*['\"][^'\"]*[áéíóúãõâêôç][^'\"]*['\"]" apps/web/src

# Toast notifications
rg -n "toast\.(success|error|warning|info)\(['\"][^'\"]*[áéíóúãõâêôç]" apps/web/src
```

### Palavras-Chave Comuns em Português

```bash
# Verbos de ação
rg -n "(Salvar|Cancelar|Editar|Excluir|Criar|Adicionar|Remover|Enviar|Confirmar|Voltar)" apps/web/src --type tsx --type ts

# Labels de formulário
rg -n "(Nome|Email|Senha|Telefone|Endereço|CPF|CNPJ|Data|Valor)" apps/web/src --type tsx --type ts

# Status
rg -n "(Ativo|Inativo|Pendente|Aprovado|Rejeitado|Concluído|Em andamento)" apps/web/src --type tsx --type ts

# Mensagens de erro
rg -n "(obrigatório|inválido|não encontrado|erro|falha|sucesso)" apps/web/src --type tsx --type ts -i

# Conectivos (indicam frases)
rg -n "\"[^\"]*\b(de|da|do|para|com|em|por|que|não|seu|sua)\b[^\"]*\"" apps/web/src
```

---

## Checklist de Auditoria

### 1. Varredura Inicial

```markdown
- [ ] Buscar textos com acentos em TSX/TS
- [ ] Buscar palavras-chave portuguesas comuns
- [ ] Verificar placeholders de formulários
- [ ] Verificar labels e títulos
- [ ] Verificar mensagens de toast/notificação
- [ ] Verificar textos de botões
- [ ] Verificar mensagens de erro/validação
```

### 2. Classificação por Prioridade

| Prioridade | Critério | Ação |
|------------|----------|------|
| P0 (Crítica) | UI visível, texto longo | Migrar imediatamente |
| P1 (Alta) | Labels, botões, títulos | Migrar neste sprint |
| P2 (Média) | Erros, validações | Planejar migração |
| P3 (Baixa) | Logs, comentários | Considerar migração |

### 3. Para Cada Texto Encontrado

```markdown
- [ ] Identificar o namespace apropriado
- [ ] Criar chave descritiva
- [ ] Adicionar em todos os locales
- [ ] Substituir no código por t('chave')
- [ ] Testar renderização
```

---

## Formato do Relatório

### Resumo Executivo

```markdown
## 📊 i18n Audit Report

**Escopo**: {{caminho auditado}}
**Data**: {{timestamp}}

### Resumo
| Severidade | Encontrados | Arquivos |
|------------|-------------|----------|
| 🔴 P0 (Crítica) | X | N |
| 🟠 P1 (Alta) | X | N |
| 🟡 P2 (Média) | X | N |
| 🟢 P3 (Baixa) | X | N |
| **Total** | **X** | **N** |

### Top 5 Arquivos com Mais Ocorrências
1. `path/to/file.tsx` - X textos
2. `path/to/file.tsx` - X textos
...
```

### Relatório Detalhado por Arquivo

```markdown
### 📁 src/components/UserProfile.tsx

#### 🔴 P0 - Crítico (migrar imediatamente)

| Linha | Texto Atual | Chave Sugerida | Namespace |
|-------|-------------|----------------|-----------|
| 24 | `<h1>Perfil do Usuário</h1>` | `profile.title` | `pages.profile` |
| 45 | `placeholder="Digite seu nome"` | `form.name.placeholder` | `common.form` |

#### 🟠 P1 - Alta (migrar neste sprint)

| Linha | Texto Atual | Chave Sugerida | Namespace |
|-------|-------------|----------------|-----------|
| 67 | `label="Email"` | `labels.email` | `common.labels` |

---

**Ações:**
- [ ] `migrar arquivo` - Migra todos os textos deste arquivo
- [ ] `migrar P0` - Migra apenas críticos
- [ ] `gerar chaves` - Cria entradas nos arquivos JSON
```

---

## Fluxo de Migração

### Modo Interativo

```
1. Texto hardcoded detectado
       │
       ▼
2. Claude sugere:
   - Namespace: "pages.dashboard"
   - Chave: "welcomeMessage"
   - Valor EN: "Welcome back!"
   - Valor PT: [texto atual]
       │
       ▼
3. Usuário confirma/ajusta
       │
       ▼
4. Claude adiciona em TODOS os locales:
   - en-US.json: valor em inglês
   - pt-BR.json: texto original
   - Outros: [NEEDS_TRANSLATION] + valor EN
       │
       ▼
5. Claude substitui no código:
   const t = useTranslations('pages.dashboard');
   <p>{t('welcomeMessage')}</p>
```

### Template de Migração

**Antes:**
```tsx
// src/components/Dashboard.tsx
export function Dashboard() {
  return (
    <div>
      <h1>Bem-vindo ao Painel</h1>
      <p>Gerencie suas configurações aqui.</p>
      <button>Salvar alterações</button>
    </div>
  );
}
```

**Depois:**
```tsx
// src/components/Dashboard.tsx
import { useTranslations } from 'next-intl';

export function Dashboard() {
  const t = useTranslations('pages.dashboard');

  return (
    <div>
      <h1>{t('title')}</h1>
      <p>{t('description')}</p>
      <button>{t('saveButton')}</button>
    </div>
  );
}
```

**Adicionado em en-US.json:**
```json
{
  "pages": {
    "dashboard": {
      "title": "Welcome to Dashboard",
      "description": "Manage your settings here.",
      "saveButton": "Save changes"
    }
  }
}
```

**Adicionado em pt-BR.json:**
```json
{
  "pages": {
    "dashboard": {
      "title": "Bem-vindo ao Painel",
      "description": "Gerencie suas configurações aqui.",
      "saveButton": "Salvar alterações"
    }
  }
}
```

---

## Convenções de Nomenclatura

### Estrutura de Namespaces

```
{categoria}.{subcategoria}.{chave}

Categorias:
├── common       → Textos reutilizáveis (labels, actions, status)
├── pages        → Textos específicos de páginas
├── components   → Textos de componentes reutilizáveis
├── forms        → Labels, placeholders, validações
├── errors       → Mensagens de erro
├── success      → Mensagens de sucesso
├── modals       → Títulos e conteúdo de modais
└── navigation   → Menu, breadcrumb, tabs
```

### Convenções de Chaves

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Títulos | `{contexto}.title` | `dashboard.title` |
| Descrições | `{contexto}.description` | `dashboard.description` |
| Botões | `{ação}Button` | `saveButton`, `cancelButton` |
| Labels | `labels.{campo}` | `labels.email`, `labels.name` |
| Placeholders | `{campo}.placeholder` | `email.placeholder` |
| Validações | `validation.{regra}` | `validation.required` |
| Erros | `errors.{tipo}` | `errors.notFound` |
| Status | `status.{estado}` | `status.active` |

---

## Casos Especiais

### Texto com Variáveis

**Hardcoded:**
```tsx
<p>Olá, {userName}! Você tem {count} mensagens.</p>
```

**Migrado:**
```tsx
<p>{t('greeting', { name: userName, count })}</p>
```

**JSON:**
```json
{
  "greeting": "Olá, {name}! Você tem {count, plural, =0 {nenhuma mensagem} one {# mensagem} other {# mensagens}}."
}
```

### Texto com HTML

**Hardcoded:**
```tsx
<p>Leia nossos <a href="/terms">termos de uso</a>.</p>
```

**Migrado:**
```tsx
<p>
  {t.rich('termsNotice', {
    link: (chunks) => <a href="/terms">{chunks}</a>
  })}
</p>
```

**JSON:**
```json
{
  "termsNotice": "Leia nossos <link>termos de uso</link>."
}
```

### Arrays e Objetos

**Hardcoded:**
```tsx
const options = [
  { value: 'active', label: 'Ativo' },
  { value: 'inactive', label: 'Inativo' },
];
```

**Migrado:**
```tsx
const options = [
  { value: 'active', label: t('status.active') },
  { value: 'inactive', label: t('status.inactive') },
];
```

---

## Integração com Outras Skills

| Situação | Acionar Skill |
|----------|---------------|
| Após migração | `i18n-maintenance` para validar JSONs |
| Mudança em componente | `frontend-design` para validar UI |
| > 10 arquivos alterados | `reviewer` para ADR |
| Criar nova página | Esta skill proativamente |

---

## Red Flags - Alerta Imediato

```markdown
- [ ] Texto longo (> 50 chars) hardcoded
- [ ] Título de página hardcoded
- [ ] Mensagem de erro visível ao usuário hardcoded
- [ ] Label de formulário hardcoded
- [ ] Texto de botão de ação principal hardcoded
- [ ] Conteúdo de modal hardcoded
- [ ] Toast/notificação hardcoded
```

---

## Comandos Rápidos

| Comando | Ação |
|---------|------|
| `i18n audit` | Auditoria completa de `apps/web/src` |
| `i18n audit [path]` | Auditoria de arquivo/pasta específica |
| `i18n find hardcoded` | Lista todos textos hardcoded |
| `i18n find P0` | Lista apenas críticos |
| `i18n migrate [file]` | Migra textos de um arquivo |
| `i18n suggest keys` | Sugere chaves para textos encontrados |
| `i18n report` | Gera relatório de auditoria |

---

## Anti-Patterns

| Não faça | Faça |
|----------|------|
| Ignorar textos em componentes "internos" | Todo texto visível precisa de i18n |
| Criar chaves genéricas demais | Chaves específicas e descritivas |
| Traduzir no componente | Sempre usar arquivos JSON |
| Concatenar strings traduzidas | Usar interpolação |
| Deixar NEEDS_TRANSLATION indefinidamente | Traduzir ou remover |
| Hardcode em constantes globais | Constantes devem usar t() também |

---

## Métricas de Sucesso

### Score de Cobertura i18n

```
Score = (textos_migrados / total_textos_detectados) * 100

Meta: 100% para textos P0 e P1
Aceitável: > 90% para P2
```

### KPIs

| Métrica | Meta |
|---------|------|
| Textos P0 hardcoded | 0 |
| Textos P1 hardcoded | 0 |
| Cobertura geral | > 95% |
| Novos textos sem i18n | 0 por sprint |
