# Geração de PDF — `design-auditoria`

Receita pra converter o HTML A4 do entregável em PDF print-ready via Playwright headless. Origem: memória `reference_pdf_gen_playwright.md` + adaptações específicas pra esta skill.

---

## Pré-requisitos

- `pnpm` no PATH
- Playwright instalado em algum projeto que sirva como host
- Navegador Chromium instalado: `pnpm exec playwright install chromium` (uma vez)

---

## Script base (copiar e adaptar)

Salvar como `gen-pdf.mjs` no diretório onde mora o HTML:

```javascript
import { chromium } from '@playwright/test';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// R18 v0.5: NOME do arquivo reflete escopo. Substitua "<slug>" pelo slug do escopo da auditoria
// (mesmo da pasta-mãe). Ex: "menu-creator.html", "jornada-student-iniciar-curso.html".
// NUNCA usar "auditoria.html" genérico (colide entre auditorias).
const SLUG = 'CHANGE_ME'; // ← editar pra cada nova auditoria
const HTML_INPUT = resolve(__dirname, `${SLUG}.html`);
const PDF_OUTPUT = resolve(__dirname, `${SLUG}.pdf`);

const browser = await chromium.launch();
const ctx = await browser.newContext();
const page = await ctx.newPage();

await page.goto(`file://${HTML_INPUT}`, { waitUntil: 'networkidle' });
await page.emulateMedia({ media: 'print' });

await page.pdf({
  path: PDF_OUTPUT,
  format: 'A4',
  printBackground: true,
  margin: { top: '0', right: '0', bottom: '0', left: '0' },
  preferCSSPageSize: true,
});

await browser.close();
console.log(`✓ PDF gerado: ${PDF_OUTPUT}`);
```

Rodar de dentro de um projeto que tenha Playwright como dep:

```bash
cd /caminho/pra/projeto-com-playwright
node /caminho/onde/esta/auditoria/gen-pdf.mjs
```

---

## Configurações críticas

| Opção | Valor | Por quê |
|---|---|---|
| `format` | `'A4'` | Formato padrão do entregável |
| `printBackground` | `true` | **Sem isso, cores de fundo desaparecem.** Hero escuro vira branco no PDF. |
| `margin` | `0` em todos | O HTML controla via `@page { margin: 22mm 18mm; }`. Conflito derruba o layout. |
| `preferCSSPageSize` | `true` | Garante que `@page` do CSS prevalece sobre o `format` da API. |
| `emulateMedia({ media: 'print' })` | obrigatório antes de `.pdf()` | Sem isso, regras `@media print` no CSS são ignoradas. |
| `waitUntil: 'networkidle'` | em `page.goto()` | Espera fontes web carregarem antes de capturar. Se omitir, fontes podem aparecer fallback no PDF. |

---

## CSS @page recomendado (no HTML do doc)

```css
@page {
  size: A4;
  margin: 22mm 18mm;
}

@media print {
  body {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  .page-break {
    page-break-before: always;
  }

  .no-break {
    page-break-inside: avoid;
  }

  /* R19.B v0.5 — figure { break-inside: avoid } evita whitespace excessivo
     (section global causava páginas vazias quando section tinha imagem grande) */
  figure, .evidence, .empathy-card, .sprint, table { break-inside: avoid; }
  h2 { break-before: page; break-after: avoid; }
  h3, h4 { break-after: avoid; }

  /* R19.B v0.5 — NÃO usar max-height fixo genérico (gera whitespace).
     Aspect-ratio do screenshot original cuida do tamanho final. */
  img { max-width: 100%; height: auto; }

  /* Caso específico: aspect ratio extremo portrait (>1:1.8) — limitar altura */
  img.portrait-extreme {
    max-height: 200mm;
    width: auto;
    max-width: 100%;
    object-fit: contain;
    display: block;
    margin: 0 auto;
  }
}
```

**Anti-pattern descoberto na 5ª rodada (R19):** usar `section { break-inside: avoid-page }` global. Causa páginas A4 com whitespace ≥40% quando uma section tem imagem grande, gerando sensação de "imagem sumida" mesmo a imagem estando renderizada. Solução: `break-inside: avoid` em figures/cards específicos, não em sections inteiras.

---

## Self-check obrigatório pós-geração (R19.C)

Antes de marcar entregue, **sempre rodar**:

```bash
# 1. HTML usa base64 inline (não path relativo) — falha em sandbox/preview senão
grep -c 'src="assets/' <slug>.html   # → DEVE ser 0
grep -c 'src="data:image' <slug>.html # → DEVE ser igual ao nº de <img>

# 2. PDF tem todas as imagens
pdfimages -list <slug>.pdf | tail -n +3 | wc -l
# → DEVE ser ≥ nº de <img class="full"> no HTML

# 3. Renderizar 3 páginas com imagens pra confirmar visual
pdftoppm -f 6 -l 8 -r 80 -png <slug>.pdf /tmp/audit-check
# Abrir /tmp/audit-check-*.png e confirmar:
# — imagem aparece (não placeholder vazio)
# — whitespace abaixo < 40% da página
# — aspect ratio sem distorção

# 4. Tamanho final
du -h <slug>.pdf  # → entre 500KB e 5MB típico
du -h <slug>.html # → entre 1MB e 4MB típico (com base64 inline)
```

**Pré-requisito de ferramentas:** `brew install poppler` (instala `pdfimages`, `pdftoppm`, `pdfinfo`, `pdftotext`).

---

---

## Gotchas conhecidos

### 1. Imagens com aspect ratio extremo geram página em branco

**Sintoma:** screenshot full-page de mobile (390×8000px) renderiza enorme no PDF, cria 5 páginas vazias.

**Causa:** sem `max-height`, a img estoura a página A4.

**Solução:**
```html
<img src="mobile-fullpage.png" class="tall" alt="..." style="max-height: 220mm; object-fit: contain;">
```

Inline override garante mesmo se a classe `.tall` não estiver no CSS.

### 2. Fontes web aparecem fallback no PDF

**Sintoma:** doc usa Playfair Display, mas no PDF aparece serif genérico.

**Causa:** Playwright capturou antes das fontes terminarem de carregar.

**Solução:** `waitUntil: 'networkidle'` + opcionalmente um pequeno delay:
```javascript
await page.goto(url, { waitUntil: 'networkidle' });
await page.waitForTimeout(500); // garantia extra
```

### 3. Cores de fundo somem

**Sintoma:** hero com `background: black` aparece branco no PDF.

**Causa:** `printBackground: false` (default) ou CSS sem `print-color-adjust: exact`.

**Solução dupla:** ambos.

### 4. Margens duplicadas

**Sintoma:** doc tem 40mm de margem em vez dos 22mm esperados.

**Causa:** `@page { margin: 22mm }` no CSS + `margin: 22mm` na API do Playwright = soma.

**Solução:** API com `margin: 0` em todos os lados. CSS controla.

### 5. Componente `.example-pair` (lado a lado) quebra no PDF

**Sintoma:** "antes" e "depois" se separam, "antes" fica em uma página, "depois" em outra.

**Causa:** flex container sem `page-break-inside: avoid`.

**Solução:**
```css
.example-pair {
  display: flex;
  gap: 16mm;
  page-break-inside: avoid;
  break-inside: avoid;
}
```

---

## Self-check pré-PDF

Antes de gerar:

- [ ] `printBackground: true` na chamada `.pdf()`
- [ ] `emulateMedia({ media: 'print' })` antes de gerar
- [ ] `waitUntil: 'networkidle'` no goto
- [ ] CSS tem `@page { size: A4; margin: 22mm 18mm; }`
- [ ] CSS tem `print-color-adjust: exact` no body
- [ ] Imagens com aspect ratio extremo têm `max-height` inline
- [ ] `.example-pair` (ou similar) tem `page-break-inside: avoid`
- [ ] Sem caminho de arquivo / URL local visível em nenhum lugar do HTML

---

## Validação pós-geração

Após o PDF ser criado:

1. **Abrir no Preview/Acrobat** — não confiar só na geração silenciosa
2. **Conferir paginação** — sem página em branco no meio (sintoma de imagem alta sem cap)
3. **Conferir fontes** — abrir em outro computador idealmente; fontes devem renderizar igual
4. **Conferir cores** — hero escuro permanece escuro
5. **Conferir tamanho** — PDFs de auditoria normal ficam 1-3MB. >10MB indica imagens não otimizadas.

Se um item falhar: voltar ao HTML, corrigir, regerar. Não enviar PDF com defeito visível.

---

## Quando NÃO usar Playwright

Para casos isolados (1 página A4, sem imagens):
- **Browser nativo:** abrir HTML, Cmd+P, "Salvar como PDF". Funciona pra docs simples.
- **Pandoc:** se o doc é majoritariamente texto e não precisa de fidelidade visual.

Pra **auditorias completas** (20+ páginas, imagens, layout editorial), Playwright é a única opção confiável.
