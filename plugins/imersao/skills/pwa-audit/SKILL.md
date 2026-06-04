---
name: pwa-audit
description: "Scan components for PWA mobile-first compliance violations. Use when: auditing touch targets, input sizing, touch-manipulation, safe areas across a codebase or module."
---

# PWA Audit

Scanner que detecta violacoes de usabilidade mobile-first em componentes React/TSX.

## Diferenca do `mobile-pwa-usability`

| Skill | Proposito |
|-------|-----------|
| `mobile-pwa-usability` | **Guia** — checklist para aplicar ao construir componentes |
| `pwa-audit` | **Scanner** — busca violacoes em codigo existente |

## Quando Usar

- Apos criar/modificar multiplos componentes interativos
- Auditoria periodica de compliance PWA
- Sprint de revisao mobile-first (como o sprint PWA Review)
- Antes de release que afeta componentes de UI

## Criterios de Auditoria

| Criterio | Regra | Padrao Correto | Violacao |
|----------|-------|----------------|----------|
| Touch targets | min 44x44px | `min-h-[var(--touch-target-min)]` | `h-6`, `h-8`, `p-1`, `p-1.5` em botoes |
| Font size inputs | min 16px | `text-base` | `text-sm`, `text-xs` em `<input>`, `<textarea>`, `<select>` |
| Touch manipulation | Eliminar tap delay | `touch-manipulation` | Ausencia em elementos clicaveis |
| Search inputs | Semantica mobile | `type="search"` + `inputMode="search"` | `type="text"` em campos de busca |
| Safe areas | Suporte notch | `env(safe-area-inset-*)` | Elementos fixos sem safe area |

## Procedimento de Scan

### Fase 1: Definir Escopo

Determinar quais arquivos auditar:

```bash
# Escopo completo (todos os componentes interativos)
find src -name "*.tsx" | grep -v __tests__ | grep -v '.test.' | grep -v '.stories.'

# Por layer
find src/primitives -name "*.tsx" | grep -v __tests__
find src/layouts -name "*.tsx" | grep -v __tests__
find src/interactions -name "*.tsx" | grep -v __tests__
find src/composites -name "*.tsx" | grep -v __tests__
```

### Fase 2: Scan Automatizado

Buscar padroes de violacao com grep/ripgrep:

#### Touch Targets Insuficientes

```bash
# Botoes com padding pequeno (provavelmente < 44px)
rg '(className.*button|<button|<Button)' --type tsx -l | \
  xargs rg 'p-1[^0-9]|p-1\.5|h-6 |h-7 |h-8 |w-6 |w-7 |w-8 ' --type tsx -n

# Botoes SEM touch target minimo
rg '<button' --type tsx -l | \
  xargs rg -L 'touch-target-min|min-h-\[44|min-h-\[2\.75' --type tsx
```

#### Inputs sem text-base

```bash
# Inputs com text-sm (causa zoom no iOS Safari)
rg '<input|<textarea|<select|Input |Textarea ' --type tsx -l | \
  xargs rg 'text-sm|text-xs' --type tsx -n
```

#### Elementos interativos sem touch-manipulation

```bash
# Botoes/links sem touch-manipulation
rg '<button|<a |onClick' --type tsx -l | \
  xargs rg -L 'touch-manipulation' --type tsx
```

#### Search inputs sem type="search"

```bash
# Campos de busca usando type="text"
rg 'search|Search|busca|filtro|filter' --type tsx -l | \
  xargs rg 'type="text"' --type tsx -n
```

### Fase 3: Analise Manual

Para cada violacao encontrada, verificar:

1. **E realmente interativo?** Elementos decorativos nao precisam de touch targets
2. **Ja tem wrapper com touch target?** O pai pode ter o tamanho adequado
3. **E desktop-only?** Alguns componentes usam `pointer-coarse:` para touch condicional
4. **Tem pseudo-element expandido?** Pattern `before:inset-[-Npx]` expande area sem mudar layout

### Fase 4: Relatorio

```markdown
## PWA Audit Report

**Escopo**: [modulo/pasta auditada]
**Data**: [timestamp]

### Resumo

| Criterio | Violacoes | Arquivos |
|----------|-----------|----------|
| Touch targets | N | N |
| Font size inputs | N | N |
| Touch manipulation | N | N |
| Search semantics | N | N |
| Safe areas | N | N |

### Violacoes por Severidade

#### Criticas (bloqueantes)
- `src/path/File.tsx:L42` — `<button className="p-1">` sem touch target minimo
- `src/path/File.tsx:L88` — `<input className="text-sm">` causa zoom iOS

#### Medias
- `src/path/File.tsx:L15` — botao sem `touch-manipulation`

#### Baixas (informativo)
- `src/path/File.tsx:L30` — elemento clicavel sem `:active` state

### Fixes Recomendados
| Arquivo | Linha | Fix |
|---------|-------|-----|
| File.tsx | 42 | Adicionar `min-h-[var(--touch-target-min)] touch-manipulation` |
| File.tsx | 88 | Trocar `text-sm` por `text-base` |
```

## Padroes de Fix por Tipo de Componente

### Botoes

```tsx
// Botao padrao
className="min-h-[var(--touch-target-min)] touch-manipulation ..."

// Botao icone (sem texto)
className="min-h-[var(--touch-target-min)] min-w-[var(--touch-target-min)] flex items-center justify-center touch-manipulation ..."

// Botao com restricao desktop (manter menor em desktop)
className="pointer-coarse:min-h-[var(--touch-target-min)] touch-manipulation ..."
```

### Inputs

```tsx
// Input de texto
className="text-base touch-manipulation ..."

// Input de busca
type="search" inputMode="search" enterKeyHint="search"
className="text-base touch-manipulation ..."
```

### Checkboxes/Switches/Radios

```tsx
// Expandir area de toque com pseudo-element
className="relative before:absolute before:inset-[-12px] before:content-[''] touch-manipulation ..."
```

### Accordion/Collapsible Triggers

```tsx
className="min-h-[var(--touch-target-min)] touch-manipulation ..."
```

## Referencia: CSS Variable

```css
/* Definida em src/theme/tokens/components.css */
--touch-target-min: 2.75rem; /* 44px — WCAG 2.1 Level AAA */
```

## Integracao com Outros Skills

| Situacao | Skill |
|----------|-------|
| Aplicar fixes encontrados | `mobile-pwa-usability` (guia) |
| QA visual no mobile | `qa-mobile` |
| Testar em viewports | `e2e-run` com mobile viewport |
| Auditar layout completo | `layout-audit` |
