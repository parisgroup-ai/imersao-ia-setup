# Schema Aliases

Mapeamento de variáveis de contexto dos templates para campos do banco de dados.

## Prefixos de Domínio

| Prefixo | Schema | Tabela |
|---------|--------|--------|
| `course_` | courses.ts | `courses` |
| `module_` | modules.ts | `modules` |
| `lesson_` | lessons.ts | `lessons` |
| `user_` | users.ts | `users` |
| `student_` | users.ts | `users` (role=student) |
| `creator_` | users.ts | `users` (role=creator) |

## Mapeamento Direto

Variáveis que mapeiam diretamente para colunas (mesmo nome):

### courses

| Variável Template | Coluna DB | Tipo |
|-------------------|-----------|------|
| `course_title` | `title` | varchar(255) |
| `course_description` | `description` | text |
| `course_slug` | `slug` | varchar(255) |
| `course_status` | `status` | enum |
| `course_featured` | `featured` | boolean |

### modules

| Variável Template | Coluna DB | Tipo |
|-------------------|-----------|------|
| `module_title` | `title` | varchar(255) |
| `module_description` | `description` | text |
| `module_order` | `order` | integer |
| `module_objectives` | `objectives` | jsonb |

### lessons

| Variável Template | Coluna DB | Tipo |
|-------------------|-----------|------|
| `lesson_title` | `title` | varchar(255) |
| `lesson_content` | `content` | text |
| `lesson_type` | `type` | varchar(50) |
| `lesson_order` | `order` | integer |
| `lesson_hints` | `hints` | jsonb |

## Aliases (Nomes Diferentes)

Variáveis que precisam de mapeamento explícito:

### courses

| Variável Template | Coluna DB | Motivo |
|-------------------|-----------|--------|
| `target_audience` | `targetRoles` | Nome legado nos templates |
| `duration_hours` | `metadata.durationHours` | Campo em JSON |
| `style` | `metadata.style` | Campo em JSON |
| `total_duration_hours` | `metadata.durationHours` | Alias alternativo |
| `course_level` | `level` | Prefixo redundante removido |

### modules

| Variável Template | Coluna DB | Motivo |
|-------------------|-----------|--------|
| `total_modules` | *(calculado)* | COUNT de modules por course |
| `module_duration_minutes` | `estimatedDurationMinutes` | Camel vs snake |
| `learning_objectives` | `objectives` | Nome mais descritivo |
| `real_world_problem` | `metadata.realWorldProblem` | Campo em JSON |
| `concepts_from_kb` | `conceptsFromKb` | Camel case |

### lessons

| Variável Template | Coluna DB | Motivo |
|-------------------|-----------|--------|
| `lesson_duration` | `estimatedTimeMinutes` | Nome diferente |
| `previous_lessons` | *(calculado)* | Query de lessons anteriores |
| `acceptance_criteria` | `acceptanceCriteria` | Camel case |

### Variáveis Compostas

| Variável Template | Origem | Descrição |
|-------------------|--------|-----------|
| `environment` | `courses.metadata.environment` | web, desktop, mobile |
| `tools` | `courses.metadata.tools` | Ferramentas do curso |
| `teaching_approach` | `courses.metadata.teachingApproach` | hybrid, practical, theoretical |

## Variáveis Sem Prefixo

Variáveis comuns usadas em múltiplos contextos:

| Variável | Contexto Esperado | Schema Provável |
|----------|-------------------|-----------------|
| `title` | Ambíguo | Requer prefixo |
| `description` | Ambíguo | Requer prefixo |
| `content` | lesson | lessons.content |
| `order` | Ambíguo | Requer prefixo |

**Recomendação:** Sempre usar prefixo para evitar ambiguidade.

## Variáveis Especiais

Variáveis que não vêm do banco:

| Variável | Origem | Descrição |
|----------|--------|-----------|
| `kb_context` | Knowledge Base | Contexto extraído da KB |
| `brainstorming_data` | Session state | Dados da sessão de brainstorm |
| `brainstorm_data` | Session state | Alias |
| `step` | Flow control | Passo atual do fluxo |
| `mode` | Runtime | Modo de operação |
| `variant` | Runtime | Variante de curso |
| `hint_level` | Runtime | Nível do hint (1-3) |
| `message` | User input | Mensagem do usuário |

## Configuração de Aliases

No `.prompt-db-audit.json`:

```json
{
  "schemaAliases": {
    "target_audience": "courses.targetRoles",
    "style": "courses.metadata.style",
    "duration_hours": "courses.metadata.durationHours",
    "total_duration_hours": "courses.metadata.durationHours",
    "module_duration_minutes": "modules.estimatedDurationMinutes",
    "learning_objectives": "modules.objectives",
    "real_world_problem": "modules.metadata.realWorldProblem",
    "lesson_duration": "lessons.estimatedTimeMinutes",
    "environment": "courses.metadata.environment",
    "tools": "courses.metadata.tools",
    "teaching_approach": "courses.metadata.teachingApproach"
  },
  "ignoredVariables": [
    "kb_context",
    "brainstorming_data",
    "brainstorm_data",
    "step",
    "mode",
    "variant",
    "hint_level",
    "message",
    "previous_lessons",
    "total_modules"
  ]
}
```

## Validação de Tipos

A auditoria também verifica compatibilidade de tipos:

| Uso no Template | Tipo Esperado | Exemplo |
|-----------------|---------------|---------|
| `{{ var }}` | string, number | Interpolação simples |
| `{% for x in var %}` | array | Iteração |
| `{% if var %}` | any (truthy) | Condicional |
| `{{ var \| join(',') }}` | array | Filter de array |
| `{{ var \| default('x') }}` | any | Com fallback |
