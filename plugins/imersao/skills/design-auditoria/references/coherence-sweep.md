# Pente fino de coerência — `design-auditoria`

> Lição que motivou esta seção: na 1ª rodada real (ToStudy 01-02/05/2026), 24 incoerências foram encontradas em pente fino manual após o solicitante questionar uma proposta antiga sobrevivente. Auditoria que se contradiz quebra a confiança do leitor. Sweep abaixo é **obrigatório** antes de gerar PDF.

---

## Por que pente fino é não-negociável

Auditoria evolui durante a sessão:
- Decisões mudam (ex: "saldo no header" → "saldo no user card")
- Labels capturados aparecem só depois (substituem labels memorizados)
- Score recalcula quando pilares pendentes são preenchidos
- Math se desatualiza quando contagens mudam

**Convivência de versão antiga + nova = 1 segundo de descrédito do leitor.** O entregável precisa ser internamente consistente como se tivesse sido escrito de uma vez só.

---

## Checklist de sweep (rodar antes do PDF final)

### 1. Decisões prévias da sessão

Para cada decisão registrada na sessão (memória `project_*` ou no próprio doc), grep do termo **antigo** e do **novo**:

```bash
# Exemplo (decisão "saldo no rodapé sidebar, não no header"):
grep -nE "saldo no header|HEADER permanente|chip de saldo" auditoria.html
# Esperado: 0 (excluindo descrições de mercado tipo "apps fintech usam header")
```

**Lugares mais comuns onde versão antiga sobrevive:**
- Lede do topo
- Tabelas comparativas P0/P1
- Wireframes ANTES/DEPOIS
- Hipóteses (§07)
- Plano de sprints (ações específicas)
- Callouts cumulativos / resumos / veredictos
- Anexos (tabelas de mercado)
- Sistema de criação (princípios)

### 2. Labels capturados vs labels memorizados

Se a captura confirmou labels REAIS da plataforma (ex: pt-BR), grep dos labels antigos (em inglês, ou de versão diferente):

```bash
# Excluir glossário (Termo (Original) é OK), URLs, paths e citações de mercado
grep -nE "\\bDashboard\\b|\\bSettings\\b|\\bHelp\\b|\\bProfile\\b|\\bReports\\b" auditoria.html \
  | grep -v "Coursera\|Khan\|Spotify\|Netflix\|Notion\|Slack\|Stripe\|<code>"
```

**Distinguir 3 categorias:**
- ✓ **Citação de mercado externo** — "Coursera 'My Learning'" — manter em inglês
- ✓ **Glossário** — "Configurações (Settings)" — termo original entre parênteses, OK
- ✗ **Narrativa pt-BR usando termo en** — "vai pro Settings" → trocar por "vai pra Configurações"

### 3. Math que precisa fechar

Toda contagem ou soma no doc precisa fechar:

- **Pesos dos pilares** = 1.00 exato
- **Score ponderado** = soma das contribuições
- **Reorganização do menu** — partida + migrações = chegada
  - Ex: "Hoje 16. Migra 4 (Perfil) + 2 (Créditos) = 6 → 10. Merges Aprendizado (6→3) e Conquistas (3→1) = -5 → 5 final"
- **Tabela ANTES vs DEPOIS** — cada item descontinuado tem destino declarado

```python
# Validar pesos
weights = [0.25, 0.25, 0.20, 0.15, 0.05, 0.10]
assert sum(weights) == 1.00, f"pesos somam {sum(weights)}, esperado 1.00"

# Validar score
notas = [4.0, 3.0, 3.0, 4.0, 4.0, 5.0]
score = sum(n*w for n,w in zip(notas, weights))
# Comparar com score declarado em todas as N menções no doc
```

### 4. Score em todos os lugares

```bash
# Todas as menções do score final devem bater
grep -nE "[0-9]\\.[0-9]{1,2} ?/ ?10|score-big-value" auditoria.html
```

Lugares onde o score aparece (verificar todos):
- Score-summary card (topo do §07/§13)
- Régua tripartida (`title="X.YZ"` no marker, `left: NN%` na posição)
- Radar chart (notas individuais nos vértices)
- Tabela de cálculo
- Veredicto
- Sumário executivo (se citar score)

### 5. Numeração e referências cruzadas

```bash
# Capítulos sequenciais sem gap
grep -E "<h2><span class=\"num\">§ " auditoria.html | awk -F'§ ' '{print $2}' | head -1

# Refs cruzadas: § XX deve apontar pra seção que existe
grep -oE "§ [0-9]+" auditoria.html | sort -u

# Cleanup-list ou sprint-table — numeração sem gap
grep -cE '<span class="num">[0-9]+</span>' auditoria.html
```

### 6. Imagens ancorando críticas (R9)

Cada P0/P1 deve ter print ancorando. Ou declaração explícita "print pendente". Não pode haver crítica visual sem evidência:

```bash
# Lista os callout p0/p1 que NÃO têm <figure class="audit-screenshot"> próximo
# (verificação manual — grep não captura proximidade espacial)
```

### 7. Caminho local / URL não vaza

```bash
grep -nE "/Users/|/home/|file://|localhost|127\\.0\\.0\\.1" auditoria.html
# Esperado: 0 (caminho de arquivo nunca aparece em entregável externo)
```

---

## Workflow obrigatório

```
1. Rodar todas as 6 verificações acima
2. Listar achados antes de corrigir (caso a Alana ou solicitante queira validar)
3. Aplicar correções em sequência
4. Re-rodar verificações até zero achado
5. Só então gerar PDF
```

**Nunca pular essa etapa.** Skill que entrega doc com auto-contradição perde credibilidade do solicitante — e auditoria depende de credibilidade.
