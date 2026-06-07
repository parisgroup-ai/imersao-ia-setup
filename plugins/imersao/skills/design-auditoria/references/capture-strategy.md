# Estratégia de captura — `design-auditoria`

Fonte de evidência ≠ login manual. Esta skill **não pode bloquear esperando "loga aí"** — auditoria precisa ser replicável e não depender da disponibilidade do solicitante a cada rodada.

> Lição que motivou esta seção: 1ª rodada real (ToStudy /student/* em 01/05/2026) bateu em login expirado entre captura e Lighthouse, exigindo intervenção humana 2× e quebrando a autonomia da skill.

---

## Hierarquia de fontes (do mais autônomo pro menos)

### Opção A — `storageState` persistido (default recomendado)

Solicitar login interativo **uma vez**, persistir cookies pra próximas rodadas.

```javascript
// Script de setup (rodar 1× quando começa o trabalho)
import { chromium } from '@playwright/test';
const browser = await chromium.launch({ headless: false });
const ctx = await browser.newContext();
const page = await ctx.newPage();
await page.goto('https://exemplo.com/login');
console.log('Faça login manualmente. Pressione ENTER quando terminar.');
await new Promise(r => process.stdin.once('data', r));
await ctx.storageState({ path: '~/.claude/playwright-state/<dominio>.json' });
await browser.close();
```

```javascript
// Próximas rodadas
const ctx = await browser.newContext({
  storageState: '~/.claude/playwright-state/<dominio>.json'
});
```

**Trade-off:** cookies expiram (em geral semanas). Avisar o solicitante quando o storageState ficar inválido (HTTP 302 → /login na navegação inicial).

### Opção B — Conta de teste com cred em env

Plano free / cohort de teste. Credenciais em `.env` ou `~/.zshrc`:

```bash
export EXEMPLO_TEST_EMAIL="alana+teste@…"
export EXEMPLO_TEST_PASSWORD="…"
```

Login programático no início de cada captura. **Trade-off:** só funciona se o produto tiver login email/senha (não OAuth-only).

### Opção C — Screenshots existentes

Pasta de assets fornecida pelo solicitante ou capturada em sessão anterior. **Trade-off:** podem estar desatualizados — checar timestamp e validar com 1 print fresco do estado atual.

### Opção D — Auditoria parcial pública

Roda Camada 1 + Lighthouse só nas URLs públicas (landing, login, pricing, features). Documenta na seção "Limites desta avaliação" que área logada não foi medida diretamente. **Trade-off:** maioria dos achados de UX mora atrás do login.

### Opção E — Mock textual

Descreve interface em prosa baseada em código fonte ou descrição prévia. **Trade-off:** não é evidência real — fere R9 (prints ancorando). Só usar quando A-D são impossíveis e isso for explícito no doc.

---

## Quando login manual é inevitável

Cenários legítimos (raríssimos):
- Setup inicial do storageState (Opção A) — 1× por trabalho
- OAuth com 2FA via dispositivo físico (Opção B falha)
- Conta de demonstração não disponível

**Regra de ouro:** se chegar aqui, declarar pro solicitante:
> "Vou precisar que você logue UMA vez agora. Vou salvar a sessão pra que eu não precise pedir de novo nas próximas rodadas (até cookie expirar, em ~N semanas)."

Não pedir login a cada rodada. Não pedir login pra cada nova URL.

---

## Análise heurística sem login (Lighthouse + a11y tree)

Quando login automatizado não está disponível **e a captura já tem snapshots Playwright** de uma sessão anterior, é possível extrair achados estruturais do a11y tree salvo em `.playwright-mcp/page-*.yml`:

```bash
# Contar landmarks
grep -c "^\s*-\s*main\s" snapshot.yml          # 0 ou 2 = ❌ (esperado: 1)
grep -c "^\s*-\s*navigation\s" snapshot.yml    # esperado: 1-2
grep -c 'heading.*\[level=1\]' snapshot.yml    # esperado: 1

# Imagens sem alt (heurística — pode ter aria-label compensando)
grep -cE "-\s*img\s+\[ref" snapshot.yml

# Skip-link presente
grep -q "Pular para o conteúdo" snapshot.yml && echo "✓"
```

**Pareamento:**
- Lighthouse rodado em URL pública → score Performance + A11y baseline
- a11y tree dos snapshots logados → confirmação heurística de violações estruturais (landmarks, headings, ordem)

Documentar no doc: "Lighthouse rodou em [URLs públicas]. Área logada usou análise heurística de N snapshots Playwright. Score WCAG/Perf têm margem ±1 ponto."

---

## Setup de storageState como artefato da skill

**Quando criar:**
- Primeira rodada de auditoria com necessidade de login
- Após cookie expirar (auditoria recorrente)

**Onde salvar:**
- `~/.claude/playwright-state/<dominio>.json` — global, reutilizável entre projetos
- Adicionar ao `.gitignore` global: `.claude/playwright-state/` (cookies podem ter token)

**Quando validar:**
- Início de cada captura: navegar pra URL logada esperada, conferir HTTP 200 e ausência de redirect pra `/login`. Se redirect, storageState expirou → solicitar nova rodada de setup.
