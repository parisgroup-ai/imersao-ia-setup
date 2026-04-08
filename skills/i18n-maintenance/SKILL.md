---
name: i18n-maintenance
description: Use when working with internationalization files, translation keys, or multi-language support - validates translation coverage, detects missing keys, finds unused translations, validates code↔JSON sync, and ensures consistency across all locales. Triggers on i18n, translation, locale, intl, multi-language, missing translation.
version: 1.0.0
author: gustavo
tags: [i18n, maintenance, translation]
---

# i18n Maintenance

## Overview

Mantém consistência entre arquivos de tradução (i18n) em projetos multi-idioma. Valida estrutura, detecta chaves faltando, encontra traduções não utilizadas, **valida sincronização código↔JSON** e garante cobertura completa.

**Princípio central**: O locale `en-US` é a **fonte de verdade** para estrutura de chaves. Todos os outros locales devem ter a mesma estrutura.

## Diferença desta Skill vs i18n-audit

| Skill | Foco | O que detecta |
|-------|------|---------------|
| **i18n-maintenance** (esta) | Arquivos JSON + código | Chaves faltando, órfãs, estrutura, **código↔JSON mismatch** |
| i18n-audit | Código fonte (TSX/TS) | Textos hardcoded que deveriam usar `t()` |

**Use esta skill quando:** Validando arquivos de tradução ou erros de chave faltando
**Use i18n-audit quando:** Procurando texto português hardcoded no código

## When to Use

**Use quando**:
- Adicionar novas strings de tradução
- Verificar se todas as chaves estão traduzidas
- Encontrar traduções órfãs (não utilizadas no código)
- **Erro `MISSING_MESSAGE: Could not resolve 'key'`** (código↔JSON mismatch)
- Antes de deploy para garantir cobertura completa
- Após criar novas páginas/componentes com texto

**Não use quando**:
- Apenas lendo conteúdo traduzido
- Trabalhando em código sem strings i18n
- Procurando texto hardcoded (use `i18n-audit`)

## Estrutura do Projeto

```
apps/web/src/i18n/
├── config.ts              # Configuração de locales
├── request.ts             # Função getRequestConfig
└── messages/
    ├── en-US.json         # ⭐ FONTE DE VERDADE + DEFAULT LOCALE
    ├── pt-BR.json
    ├── es-ES.json
    ├── fr-FR.json
    └── de-DE.json
```

**Locales suportados**: en-US (default + fonte de verdade), pt-BR, es-ES, fr-FR, de-DE

## Checklist de Validação

Execute na ordem:

### 1. Verificar Estrutura de Chaves (JSON ↔ JSON)

**1.1 Extrair todas as chaves do locale de referência**:
```bash
# Extrair chaves do en-US (fonte de verdade)
jq -r 'paths(scalars) | join(".")' apps/web/src/i18n/messages/en-US.json | sort > /tmp/keys-en-US.txt
```

**1.2 Comparar com outros locales**:
```bash
# Para cada locale
for locale in pt-BR es-ES fr-FR de-DE; do
  jq -r 'paths(scalars) | join(".")' apps/web/src/i18n/messages/$locale.json | sort > /tmp/keys-$locale.txt

  # Chaves faltando neste locale
  comm -23 /tmp/keys-en-US.txt /tmp/keys-$locale.txt
done
```

### 2. Validar Código ↔ JSON (CRÍTICO)

> **Esta validação detecta erros como `MISSING_MESSAGE: Could not resolve 'hero.subheadline'`**

**2.1 Extrair namespaces usados no código**:
```bash
# Extrair todos os namespaces de useTranslations/getTranslations
rg "(?:useTranslations|getTranslations)\(['\"]([^'\"]+)['\"]" apps/web/src -o -r '$1' | \
  cut -d: -f2 | sort -u > /tmp/namespaces-used.txt
```

**2.2 Extrair chaves usadas em cada arquivo**:
```bash
# Para um arquivo específico, extrair t('key') calls
rg "t\(['\"]([^'\"]+)['\"]" apps/web/src/components/marketing/HeroSection.tsx -o -r '$1' | \
  cut -d: -f2 | sort -u
```

**2.3 Validar se chaves existem no JSON**:
```bash
# Para cada namespace usado, verificar se as chaves existem
# Exemplo: namespace 'hero' com chaves 'subheadline', 'cta.explore'
jq '.hero.subheadline' apps/web/src/i18n/messages/en-US.json
# Se retornar null → ERRO: chave não existe
```

**2.4 Script de validação completa código↔JSON**:
```bash
#!/bin/bash
# Validar que todas as chamadas t('key') existem no JSON

echo "=== Validação Código ↔ JSON ==="

# Encontrar arquivos que usam useTranslations
files=$(rg -l "useTranslations" apps/web/src --type tsx --type ts)

for file in $files; do
  # Extrair namespace
  namespace=$(rg "useTranslations\(['\"]([^'\"]+)" "$file" -o -r '$1' | head -1)

  if [ -n "$namespace" ]; then
    # Extrair chaves usadas
    keys=$(rg "t\(['\"]([^'\"]+)['\"]" "$file" -o -r '$1' | sort -u)

    for key in $keys; do
      # Construir path completo
      full_path=".$namespace.$key"

      # Verificar se existe no JSON
      value=$(jq "$full_path" apps/web/src/i18n/messages/en-US.json 2>/dev/null)

      if [ "$value" = "null" ]; then
        echo "❌ MISSING: $full_path (usado em $file)"
      fi
    done
  fi
done
```

### 3. Verificar Chaves Não Utilizadas

**3.1 Encontrar uso de t() no código**:
```bash
# Padrões de uso comuns
rg "t\(['\"]([^'\"]+)" apps/web/src --only-matching -r '$1' | cut -d: -f2 | sort -u > /tmp/used-keys.txt

# Também verificar useTranslations namespace
rg "useTranslations\(['\"]([^'\"]+)" apps/web/src --only-matching -r '$1' | cut -d: -f2 | sort -u > /tmp/namespaces.txt
```

**3.2 Comparar com chaves existentes**:
```bash
# Chaves definidas mas não encontradas no código
comm -23 /tmp/keys-en-US.txt /tmp/used-keys.txt
```

### 4. Verificar Consistência de Valores

**4.1 Placeholders**: Garantir mesmos placeholders em todos os locales
```bash
# Extrair placeholders {variable}
jq -r '.. | strings | select(test("\\{[^}]+\\}"))' apps/web/src/i18n/messages/en-US.json
```

**4.2 HTML/Markdown**: Validar tags mantidas
```bash
# Verificar tags <b>, <strong>, <a> etc
jq -r '.. | strings | select(test("<[^>]+>"))' apps/web/src/i18n/messages/*.json
```

### 5. Relatório de Cobertura

| Locale | Total Chaves | Traduzidas | Faltando | Cobertura |
|--------|--------------|------------|----------|-----------|
| en-US  | N            | N          | 0        | 100%      |
| pt-BR  | N            | ?          | ?        | ?%        |
| es-ES  | N            | ?          | ?        | ?%        |
| fr-FR  | N            | ?          | ?        | ?%        |
| de-DE  | N            | ?          | ?        | ?%        |

## Modo Interativo de Correção

Para cada problema encontrado, perguntar:

**Chave faltando em locale** (JSON↔JSON):
- (a) Adicionar com valor do en-US (placeholder para tradução)
- (b) Adicionar com [NEEDS_TRANSLATION] prefix
- (c) Copiar tradução de outro locale
- (s) Pular

**Chave faltando no JSON** (Código↔JSON):
- (a) Adicionar chave ao en-US e sincronizar outros locales
- (b) Corrigir o código para usar chave existente
- (c) Investigar qual é a chave correta
- (s) Pular

**Chave não utilizada**:
- (a) Remover de todos os locales
- (b) Marcar como [LEGACY] para revisão
- (c) Manter (pode ser usada dinamicamente)
- (s) Pular

**Placeholder diferente**:
- (a) Sincronizar com en-US
- (b) Manter versão local
- (c) Revisar manualmente
- (s) Pular

**Estrutura diferente** (objeto vs string):
- (a) Padronizar com en-US
- (b) Investigar uso no código
- (s) Pular

**Sempre mostrar diff antes de salvar.**

## Comandos

| Comando | Descrição |
|---------|-----------|
| "Validar i18n" | Checklist completo + relatório de cobertura |
| "Sync i18n" | Sincronizar estrutura de en-US para outros locales |
| "Find missing translations" | Listar apenas chaves faltando entre locales |
| "Find unused translations" | Listar chaves não utilizadas no código |
| "Validate code keys" | **Validar se t('key') no código existe no JSON** |
| "Add translation key" | Adicionar nova chave em todos os locales |
| "i18n coverage report" | Gerar relatório de cobertura |

## Diagnóstico Rápido de Erros

### Erro: `MISSING_MESSAGE: Could not resolve 'namespace.key'`

**Causa**: O código usa `t('key')` mas a chave não existe no JSON.

**Diagnóstico**:
```bash
# 1. Encontrar onde a chave é usada
rg "t\(['\"]key['\"]" apps/web/src

# 2. Verificar namespace do componente
rg "useTranslations" <arquivo_encontrado>

# 3. Verificar se chave existe no JSON
jq '.namespace.key' apps/web/src/i18n/messages/en-US.json
```

**Correção**:
1. Se chave deveria existir → Adicionar ao en-US.json e sincronizar
2. Se código está errado → Corrigir para usar chave existente
3. Se estrutura mudou → Atualizar código ou JSON para ficarem sincronizados

### Erro: Chave existe mas com estrutura diferente

**Exemplo**: Código usa `t('author.name')` mas JSON tem `author: { name: "..." }`

**Diagnóstico**:
```bash
# Verificar estrutura no JSON
jq '.namespace.author' apps/web/src/i18n/messages/en-US.json
```

**Correção**: Achatar ou aninhar conforme o código espera.

## Templates

### Nova chave de tradução

Ao adicionar nova chave, adicionar em TODOS os locales:

```json
// en-US.json (fonte de verdade)
{
  "newSection": {
    "title": "My Title",
    "description": "My description"
  }
}

// pt-BR.json (tradução real)
{
  "newSection": {
    "title": "Meu Título",
    "description": "Minha descrição"
  }
}

// Outros locales (placeholder se não traduzido)
{
  "newSection": {
    "title": "[NEEDS_TRANSLATION] My Title",
    "description": "[NEEDS_TRANSLATION] My description"
  }
}
```

### Estrutura de namespace

```json
{
  "namespace": {
    "subNamespace": {
      "chave": "valor"
    }
  }
}
```

Uso no código:
```typescript
const t = useTranslations('namespace.subNamespace');
t('chave'); // "valor"
```

## Common Mistakes

| Erro | Correção |
|------|----------|
| Adicionar chave só em en-US | Sempre adicionar em TODOS os locales |
| Código usa chave diferente do JSON | Manter código e JSON sincronizados |
| Renomear chave no JSON sem atualizar código | Atualizar ambos juntos |
| Placeholder diferente entre locales | `{count}` deve ser igual em todos |
| Chave com espaços ou caracteres especiais | Usar camelCase ou kebab-case |
| Tradução hardcoded no código | Extrair para arquivo de mensagens |
| Não atualizar outros locales | Sempre sync após mudanças |
| Deixar strings vazias | Usar placeholder `[NEEDS_TRANSLATION]` |
| Estrutura aninhada no JSON, código espera flat | Manter consistência código↔JSON |

## Validação Automática

### Script de validação completa

```typescript
// scripts/validate-i18n.ts
import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';

const MESSAGES_DIR = 'apps/web/src/i18n/messages';
const SOURCE_DIR = 'apps/web/src';

// 1. Carregar todos os locales
const locales = readdirSync(MESSAGES_DIR)
  .filter(f => f.endsWith('.json'))
  .map(f => ({
    name: f.replace('.json', ''),
    data: JSON.parse(readFileSync(join(MESSAGES_DIR, f), 'utf-8'))
  }));

const enUS = locales.find(l => l.name === 'en-US')!;

function getKeys(obj: object, prefix = ''): string[] {
  return Object.entries(obj).flatMap(([key, value]) => {
    const path = prefix ? `${prefix}.${key}` : key;
    return typeof value === 'object' && value !== null
      ? getKeys(value, path)
      : [path];
  });
}

// 2. Validar estrutura entre locales
const baseKeys = new Set(getKeys(enUS.data));

for (const locale of locales) {
  if (locale.name === 'en-US') continue;

  const keys = new Set(getKeys(locale.data));
  const missing = [...baseKeys].filter(k => !keys.has(k));
  const extra = [...keys].filter(k => !baseKeys.has(k));

  if (missing.length) console.error(`${locale.name}: Missing ${missing.length} keys`);
  if (extra.length) console.warn(`${locale.name}: Extra ${extra.length} keys`);
}

// 3. Validar código↔JSON (simplificado)
// Para validação completa, usar o script bash na seção 2.4
console.log('Para validação código↔JSON, execute o script bash da seção 2.4');
```

## Boas Práticas

### Organização de chaves

```json
{
  "common": {
    "actions": {
      "save": "Salvar",
      "cancel": "Cancelar"
    },
    "labels": {
      "name": "Nome",
      "email": "Email"
    }
  },
  "pages": {
    "home": { ... },
    "dashboard": { ... }
  },
  "components": {
    "header": { ... },
    "footer": { ... }
  }
}
```

### Convenções de naming

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| Ações | Verbo imperativo | `save`, `delete`, `confirm` |
| Labels | Substantivo | `name`, `email`, `address` |
| Mensagens | Frase completa | `itemSaved`, `errorOccurred` |
| Plurais | Com count | `item` / `items` ou usar ICU |

### Interpolação

```json
{
  "welcome": "Bem-vindo, {name}!",
  "items": "{count, plural, =0 {Nenhum item} one {# item} other {# itens}}",
  "date": "Criado em {date, date, short}"
}
```

## Integração

- **i18n-audit**: Usar para detectar textos hardcoded no código
- **memory-bank**: Atualizar após grandes mudanças de i18n
- **code-quality**: Verificar strings hardcoded
- **reviewer**: Incluir verificação de i18n em PRs

## Config Reference

```typescript
// apps/web/src/i18n/config.ts
export const locales = ['en-US', 'pt-BR', 'es-ES', 'fr-FR', 'de-DE'] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = 'en-US';
```

`en-US` é tanto o **defaultLocale** da aplicação quanto a **fonte de verdade** para estrutura de chaves.
