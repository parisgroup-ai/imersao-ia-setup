# Pomodoro Workflow

O plugin TaskNotes tem Pomodoro **integrado nativamente**. Não precisa de plugin separado.

## Configuração Atual

```json
{
  "pomodoroWorkDuration": 25,        // minutos de trabalho
  "pomodoroShortBreakDuration": 5,   // pausa curta
  "pomodoroLongBreakDuration": 15,   // pausa longa
  "pomodoroLongBreakInterval": 4,    // pausa longa a cada 4 pomodoros
  "pomodoroAutoStartBreaks": true,   // inicia pausas automaticamente
  "pomodoroAutoStartWork": false,    // não inicia trabalho automaticamente
  "pomodoroNotifications": true,     // notificações habilitadas
  "pomodoroSoundEnabled": true       // som habilitado
}
```

## Ciclo Pomodoro

```
┌─────────────────────────────────────────────────────────┐
│  CICLO POMODORO (4x)                                    │
├─────────────────────────────────────────────────────────┤
│  🍅 Trabalho (25min) → ☕ Pausa curta (5min)           │
│  🍅 Trabalho (25min) → ☕ Pausa curta (5min)           │
│  🍅 Trabalho (25min) → ☕ Pausa curta (5min)           │
│  🍅 Trabalho (25min) → 🛋️ Pausa longa (15min)          │
│                                                         │
│  Total: 2h10min por ciclo (1h40min trabalho efetivo)   │
└─────────────────────────────────────────────────────────┘
```

## Frontmatter para Pomodoros

```yaml
---
uid: task-001
status: in-progress
priority: high
timeEstimate: 480        # minutos (8h = 8 * 60)
pomodoros: 3             # pomodoros completados
timeEntries:             # log detalhado automático
  - startTime: "2026-01-18T09:00:00"
    endTime: "2026-01-18T09:25:00"
    type: "pomodoro"
  - startTime: "2026-01-18T09:30:00"
    endTime: "2026-01-18T09:55:00"
    type: "pomodoro"
tags:
  - task
---
```

## Estimativas com Pomodoros

| Estimativa | Pomodoros | Tempo Real (com pausas) |
|------------|-----------|-------------------------|
| 30min | 1 | ~30min |
| 1h | 2 | ~1h05min |
| 2h | 4 | ~2h10min (1 ciclo) |
| 4h | 8 | ~4h20min (2 ciclos) |
| 8h | 16 | ~8h40min (4 ciclos) |

### Conversão Rápida

```
timeEstimate em minutos → pomodoros esperados
480 min (8h) = 480 / 25 = ~19 pomodoros
240 min (4h) = 240 / 25 = ~10 pomodoros
120 min (2h) = 120 / 25 = ~5 pomodoros
60 min (1h) = 60 / 25 = ~2-3 pomodoros
```

## Workflow Diário

### Início do Dia

1. Abrir Agenda view no TaskNotes
2. Verificar tasks scheduled para hoje
3. Ordenar por prioridade
4. Iniciar primeiro pomodoro na task mais importante

### Durante Pomodoro

- **Foco total** na task selecionada
- Interrupções → anotar para depois
- Ao finalizar 25min → pausa automática

### Entre Pomodoros

- Pausas curtas (5min): esticar, água, banheiro
- Pausas longas (15min): lanche, caminhar, descansar olhos

### Fim do Dia

- Verificar pomodoros completados por task
- Comparar `timeEstimate` vs `pomodoros * 25`
- Ajustar estimativas futuras com base no aprendizado

## Views Úteis para Pomodoro

### Dataview: Pomodoros Hoje

```dataview
TABLE
  pomodoros as "🍅",
  (pomodoros * 25) + "min" as "Tempo",
  status
FROM "TaskNotes/Tasks"
WHERE pomodoros > 0 AND file.mtime >= date(today)
SORT pomodoros DESC
```

### Dataview: Estimativa vs Real

```dataview
TABLE
  timeEstimate + "min" as "Estimado",
  (pomodoros * 25) + "min" as "Real",
  choice(pomodoros * 25 > timeEstimate, "⚠️ Over", "✅ OK") as "Status"
FROM "TaskNotes/Tasks"
WHERE status = "done" AND pomodoros > 0
SORT file.mtime DESC
LIMIT 10
```

## Integração com Sprint

Ao criar task para sprint:

```yaml
---
uid: task-xxx
timeEstimate: 480       # 8h em minutos
pomodoros: 0            # inicia zerado
sprint: "[[sprint.md|Sprint Atual]]"
---
```

Ao completar task, calcular eficiência:

```markdown
## Summary

✅ Completed

- **Estimativa:** 480min (8h)
- **Pomodoros:** 16 🍅
- **Tempo real:** 400min (6h40m)
- **Eficiência:** 120% (terminou antes!)
```

## Comandos TaskNotes

| Comando | Ação |
|---------|------|
| `Ctrl+Shift+P` (ou Command Palette) | Start/Stop Pomodoro |
| Sidebar → Pomodoro tab | Timer visual |
| Click na task → Start timer | Inicia pomodoro para task específica |

## Dicas de Produtividade

1. **Uma task por pomodoro** - Se task precisa de múltiplos pomodoros, considere quebrar em subtasks

2. **Estimar em pomodoros** - Em vez de pensar "4h", pense "8 pomodoros"

3. **Respeitar pausas** - Pausas são parte do sistema, não pule

4. **Ajustar estimativas** - Se sempre subestima, multiplique por 1.5x

5. **Agrupar tarefas pequenas** - Tasks de < 25min podem ser agrupadas em 1 pomodoro
