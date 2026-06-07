---
name: design-auditoria
description: >
  Use ao auditar produto digital (landing pública, painel logado, dashboard,
  fluxo multi-step, app) e entregar documento formal A4 print-ready (HTML + PDF)
  pronto pra stakeholder externo. Roda método em 6 camadas (captura, diagnóstico
  estrutural, heurísticas Nielsen+Laws of UX+Baymard, WCAG, fricção/drop-off,
  pesquisa de referência) e gera documento editorial com sumário executivo,
  score por pilar, plano de correção em sprints, protótipo de validação e
  sistema de criação prescritivo. Triggers em pt-BR e en — "auditoria UX",
  "audit produto", "audit plataforma", "validar menus", "relatório UX formal",
  "audit page para cliente". NÃO usar pra crítica rápida interna (use
  design-critic), prescrição antes de implementar (use design-usabilidade),
  checklist técnico de pré-lançamento (use launch-audit).
version: 0.6.0
author: Paris Group
---

<!-- last-reviewed: 2026-05-25 -->
<!-- author-validate-allow: cursos -->
<!-- author-validate-allow: ToStudy -->

# design-auditoria

Audita um **produto digital ou interface** (landing pública, painel logado, dashboard, fluxo multi-step, app) e entrega documento formal A4 (HTML + PDF) pronto pra stakeholder externo.

> Status: v0.6 — calibrado com 6 rodadas reais + 1 revisão crítica + 1 expansão de ferramentas:
> - **1ª rodada** (v0.2 · 30/04/2026): ToStudy /student/* — área logada, 56 págs A4
> - **2ª rodada** (v0.3 · 11/05/2026 manhã): ToStudy landing pública /pt-BR — revelou 4 falhas estruturais (protótipo como prosa, prints em apêndice, títulos com jargão, mockup que apaga DS). Viraram R13–R16.
> - **3ª rodada** (v0.4 · 11/05/2026 tarde): **Revalidação** da auditoria 1ª rodada · descobri tarde que revalidei em cima do `.md` preliminar (proposta superseded) em vez do PDF/HTML final (proposta refinada). Custou ~1h refazendo trabalho. Virou **R17**: ler doc canônico final antes de revalidar, nunca preliminar.
> - **4ª rodada** (v0.5 base · 21/05/2026): ToStudy menu creator portal — 24 itens visíveis · 3 níveis de profundidade · 10 findings + mockup diff-cirúrgico preservando DS terracota. Entregue HTML+PDF.
> - **5ª rodada** (v0.5 · 22/05/2026): ToStudy jornada student multi-canal (web + CLI + MCP + Mobile) · 27 findings · 5 GH issues abertas em prod (#581–#585). **Revelou 2 falhas estruturais** (R18+R19) que foram adicionadas à skill mas **não tinham sido aplicadas** em geração real.
> - **6ª rodada** (v0.5.1 · 25/05/2026): ToStudy jornada de inscrição em curso (descoberta → catálogo → ficha → checkout → confirmação → primeira aula) · 10 findings (3 P0 críticos) · score 5.4/10. **Repetiu violação R18+R19** apesar de existirem na skill. Calibrou **R20** (H1 explícito).
> - **Revisão crítica** (v0.5.2 · 25/05/2026 tarde): durante revisão da 6ª rodada, a solicitante identificou **3 falhas estruturais que afetam credibilidade do método**: (a) score inflado em pilares onde a evidência era subjetiva (Hierarquia 7.5 reduzida pra 5.5; Performance 6.5 reduzida pra 5.0\* — sem Lighthouse formal); (b) auditoria parecia influenciada pelo que o usuário disse na sessão; (c) protótipo §09 não está sendo entregue em auditorias da equipe apesar de R13. Viraram **R21 (score falsificável)**, **R22 (independência metodológica anti-viés)** e **R23 (§09 mockup é gate bloqueante)**. Score recalibrado da 6ª rodada: 5.4 → 4.8.
> - **Expansão de ferramentas** (v0.6 · 25/05/2026 noite): a solicitante recomendou enriquecer a camada de descoberta de jornada com 4 ferramentas adicionais usadas profissionalmente em UX Research. Retrofit na 6ª rodada validou que adicionam valor concreto, não filler: **JTBD** expôs barreira emocional dominante (não desistir); **Service Blueprint** transformou F-01 de bug de UX em bug de arquitetura (rota enrollFree não cria wallet com bonus); **Moments of Truth** validou objetivamente a priorização (3 P0s atingem 3 dos 4 MoTs); **Mental Model Map** mostrou que 4 findings compartilham a mesma raiz estrutural. Viraram **R24 (JTBD)**, **R25 (Service Blueprint condicional)**, **R26 (MoT)** e **R27 (Mental Model Map condicional)**.
>
> Falta 1 rodada em outro tipo de produto (SaaS B2B / e-commerce / app mobile) pra marcar v1.

---

## Quando invocar

- Cliente solicitou auditoria UX formal de landing pública
- Stakeholder externo (dono de produto, investidor, parceiro) pediu relatório
- Quer documento entregável que justifique decisões UX e dê plano de correção

## Quando NÃO invocar

| Cenário | Skill correta |
|---|---|
| Crítica rápida interna pro time | `design-critic` |
| Prescrição ANTES de implementar | `design-usabilidade` |
| Checklist técnico de pré-lançamento (perf/security/tests) | `launch-audit` |

## Independência

`design-auditoria` é skill autônoma. **Não** chama, importa nem modifica `design-critic`, `design-usabilidade`, `launch-audit` ou outras. O conteúdo aqui foi escrito do zero, inspirado em padrões dessas skills.

---

## Inputs

**Obrigatórios**
- **URL** ou **screenshot full-page** ou **acesso ao repo** da interface
- **Tipo de interface:** landing pública / painel logado / dashboard / fluxo multi-step / app — calibra camadas 5-6 e pilares
- **Setor / domínio** (educação, clínica, SaaS B2B, e-commerce, …) — calibra a pesquisa de referência
- **Persona-alvo** (uma frase: quem usa a interface)
- **Modo:** `completo` (default) | `interno` | `foco-ia` | `foco-visual` | `foco-a11y` | `foco-perf` — ver abaixo
- **Manter design system existente?** (R15 · pergunta-zero antes de propor mockup) — opções:
  - `manter` (default) — tipografia, escala, paleta, layout, bordas, espaçamentos preservados; mockup é cirúrgico, só toca nos elementos da auditoria
  - `liberdade` — auditor pode propor redesign do hero/seção; usar só quando o solicitante explicitamente pede repensar visual
  - `diff-visual` — mostrar hero original com marcadores numerados nas regiões de alteração, sem renderizar mockup completo

**Opcionais**
- **Briefing do solicitante** (quem é, o que quer com a auditoria)
- **Pasta de assets** com referências fornecidas (logo, brand guide, screenshots de concorrentes que ele já mapeou)
- **Stack detectada** (auto via DevTools ou declarada)
- **Pasta do design system do projeto** — se existir (ex: `UX/design-system/`, `packages/theme`, brand guide) — pra extrair tokens reais antes de propor qualquer mockup (R14)

---

## Modos de execução

| Modo | Output | Camadas | Quando usar |
|---|---|---|---|
| `completo` (default) | HTML A4 + PDF, 20-30 pág, editorial | 1-6 + score + plano + protótipo + § 10 | Entrega formal pra stakeholder externo |
| `interno` | Markdown curto (1-3 pág), achados priorizados | 1-5 enxutas | Auditoria pro time, discussão interna, follow-up |
| `foco-ia` | Markdown estrutural com mapa de rotas + menu + reorg proposta | 1-3 priorizando arquitetura de informação | Validar menus, agrupar/remover, taxonomia |
| `foco-visual` | Markdown ou A4 com pilares + evidências | 2 + 7 (estrutural + score) | Crítica de execução visual isolada |
| `foco-a11y` | Markdown com violações + plano | 4 expandida | Compliance WCAG isolada |
| `foco-perf` | Markdown com LCP/CLS/INP + plano | 1 (perf) expandida | Otimização de performance isolada |

**Regra:** se solicitante não declarar modo, default é `completo`. Modos `foco-*` produzem entregáveis menores e não geram PDF — só markdown. Modo `interno` também é só markdown.

**Regra obrigatória — sempre salvar artefato em disco:** o output da skill é **sempre** salvo em arquivo, não entregue só na conversa. Convenção de caminho:

| Modo | Caminho padrão | Formato |
|---|---|---|
| `completo` (entrega externa) | `docs/audits/<slug>-YYYY-MM-DD/` (folder com `<slug>.html` + `<slug>.pdf` + `assets/`) | HTML A4 + PDF |
| `interno`, `foco-*` | `docs/audits/<slug>-YYYY-MM-DD.md` | Markdown único |

**Convenção de nomenclatura:** **título primeiro, data por último** na pasta (`<slug>-YYYY-MM-DD/`). Não usar `YYYY-MM-DD-<slug>` — quick-switcher do Obsidian e busca ranqueiam melhor com título no início.

**Nome do arquivo entregável (R18 · v0.5):** o arquivo HTML/PDF dentro da pasta **DEVE** ser nomeado com o slug do escopo da auditoria (mesmo da pasta-mãe, sem a data), **nunca** genérico como `auditoria.html` / `audit.pdf` / `report.html`. Justificativa: usuário com múltiplas auditorias no workspace precisa distinguir pelos nomes no Spotlight/quick-switcher sem abrir cada um.

| Pasta-mãe | Arquivo HTML/PDF correto | Anti-pattern |
|---|---|---|
| `menu-creator-2026-05-21/` | ✅ `menu-creator.html` · `menu-creator.pdf` | ❌ `auditoria.html` · `auditoria.pdf` |
| `jornada-student-iniciar-curso-2026-05-22/` | ✅ `jornada-student-iniciar-curso.html` · `jornada-student-iniciar-curso.pdf` | ❌ `auditoria.html` |
| `landing-publica-2026-05-11/` | ✅ `landing-publica.html` · `landing-publica.pdf` | ❌ `audit.pdf` |

Arquivos auxiliares (`findings.md`, `gen-pdf.mjs`, pasta `assets/`) podem manter nomes genéricos — a regra é só pro entregável final.

Sempre que um projeto for auditado, salvar **dentro do repo daquele projeto** seguindo a convenção `<repo>/docs/audits/...` (ou onde o time já guarda artefatos). Quando o projeto não tem essa pasta, perguntar onde salvar antes de gerar.

No fim da execução, **mostrar o caminho absoluto do arquivo na conversa** pra usuário acessar. Resumir achados de alto impacto na conversa também (sumário executivo) — mas o detalhe vive no arquivo.

---

## Método em 6 camadas

Roda em ordem (no modo `completo`). Modos `foco-*` rodam apenas as camadas relevantes. Cada camada gera evidência que alimenta o capítulo correspondente do documento final.

### Camada 1 — Captura e mapeamento

**Fontes de verdade (escolher conforme acesso disponível):**

| Fonte | Quando usar | Captura |
|---|---|---|
| **URL pública** | Default — landing pública, marketing, SaaS aberto | Playwright/Chrome DevTools — screenshots + DOM + Lighthouse |
| **Screenshots fornecidos** | URL autenticada quando solicitante prefere não compartilhar credenciais | PNGs de cada zona-chave (sidebar, header, telas principais) |
| **Código-fonte do app (repo local)** | Painel logado / app interno quando o repo está disponível — é fonte de verdade pra **arquitetura de informação** (rotas + componente de nav) | Mapear: estrutura de rotas (Next App Router, React Router, etc.) + componente de sidebar/menu + cruzamento (rotas órfãs ↔ itens órfãos). Ideal pra modo `foco-ia`. Visual ainda exige screenshots. |

**Captura padrão (quando há URL ou screenshots):**
- Screenshots **desktop** (1440×900) e **mobile** (390×844), full-page com scroll integral
- Parse do HTML — inventário de seções, ordem, hierarquia de headings (h1→h6)
- Performance: LCP, CLS, INP via Lighthouse
- Viewport / breakpoints: detectar quebras visuais nos 5 breakpoints (320, 480, 768, 1024, 1440)

**Área logada — estratégia de acesso (ver `references/capture-strategy.md`):**

A skill **não pode bloquear esperando "loga aí"** — auditoria precisa ser autônoma. Hierarquia de fontes:

1. **`storageState` persistido** (default) — login interativo UMA vez, cookies salvos em `~/.claude/playwright-state/<dominio>.json`. Próximas rodadas reusam.
2. **Conta de teste com cred em env** — `EXEMPLO_TEST_EMAIL/PASSWORD` em `.env`. Login programático.
3. **Screenshots existentes** — pasta de assets do solicitante.
4. **Auditoria parcial pública** — só URLs públicas + Lighthouse. Heurística de a11y tree dos snapshots Playwright já capturados pra suplementar.
5. **Mock textual** — só quando 1-4 falham. Marcar explicitamente que fere R9.

Pedir login a cada nova URL = não. Solicitar setup one-shot do storageState e seguir.

**Captura por código (quando há repo, modo `foco-ia`):**
- Listar TODAS as rotas (page.tsx, route.tsx, etc.) sob a área alvo
- Localizar componente de navegação principal — extrair lista exata de items expostos (label + href)
- Cruzamento: rotas órfãs (existem, não estão no menu) ↔ itens órfãos (no menu, sem rota) ↔ duplicação semântica

**Saída:** `cap-1-captura.json` (ou markdown estruturado em modos `foco-*`) com evidências brutas + PNGs (se aplicável).

### Camada 2 — Diagnóstico estrutural

- **Hierarquia HTML** vs hierarquia visual (alinhadas? divergem?)
- **Ordem das seções** vs jornada esperada da persona
- **Defaults vs hidden** — o que está visível na primeira dobra? O que aparece só com scroll/click?
- **Código vs intenção** — o que o HTML promete que o visual não cumpre, e vice-versa

### Camada 3 — Heurísticas aplicadas

Cada violação encontrada → registra no formato `{heurística}, {evidência}, {severidade}, {referência citável}`.

- **Nielsen 10 heurísticas** (visibilidade do status, match com mundo real, controle, consistência, prevenção de erro, reconhecimento > recall, flexibilidade, design minimalista, ajuda na recuperação, ajuda + documentação)
- **Laws of UX** (Fitts, Hick, Jakob, Miller, Tesler, Von Restorff, Aesthetic-Usability, Doherty…)
- **Baymard Institute** (e-commerce e form-heavy quando aplicável)

### Camada 4 — Acessibilidade

- **axe-core** automatizado (via Playwright)
- **Lighthouse Accessibility** score
- **Manual:**
  - Fotossensibilidade (motion, autoplay, flashing)
  - Contraste WCAG AA em todos os textos + componentes interativos
  - Navegação por teclado (focus visível, ordem lógica)
  - Screen reader (alt text, aria-labels, landmarks)

### Camada 5 — Fricção e drop-off

Mapear pontos onde o usuário desiste, hesita ou erra. Adapta-se ao tipo de interface:

- **Landing pública:** time-to-first-CTA, scroll-depth previsto, bounces, atrito de conversão (CTA escondido, copy vaga, prova social ausente)
- **Painel logado / dashboard:** menus ignorados ou redundantes, ações abandonadas, fricção de navegação, descoberta de funções, tempo até a tarefa principal
- **Fluxo multi-step:** drop-off por etapa, erros de validação, voltas/loops, falta de progresso visível, validação tardia
- **App / produto:** retenção de feature, abandono no onboarding, dead-ends, descoberta de função avançada
- **Arquitetura de informação (IA):** quando o foco é menus/agrupamento — taxonomia, profundidade de árvore (>3 níveis = bandeira), itens duplicados em locais diferentes, itens órfãos, agrupamentos arbitrários sem critério

### Camada 6 — Pesquisa de referência (híbrida)

Decisão registrada no FEAT-016: **híbrido automático**.

- **Embutidos (sempre disponíveis):** Material Design, Apple HIG, Atlassian Design System, Salesforce Lightning, Carbon (IBM)
- **Web em tempo real:** 3-5 concorrentes do mesmo setor (search dirigido por domínio)
- **Pasta fornecida (prioridade):** se o solicitante passou refs, use-as e suplemente com 1-2 web

**Critério de citação:** todo padrão referenciado tem URL + screenshot embutido no apêndice.

---

## Pilares de score

Seis pilares, ponderados. Cada pilar nota 0-10, com justificativa em 1 frase. Detalhamento dos critérios em [`references/pillars.md`](pillars.md).

| Pilar | Peso |
|---|---|
| Hierarquia & legibilidade visual | 0.20 |
| Clareza de proposta + CTA | 0.20 |
| Acessibilidade (WCAG AA) | 0.20 |
| Performance & responsividade | 0.15 |
| Prova social & confiança ⁽¹⁾ | 0.15 |
| Polimento & craft | 0.10 |

⁽¹⁾ Em **painel logado / dashboard / app**, este pilar perde aplicação direta — peso é redistribuído (geralmente +0.05 hierarquia, +0.10 clareza+CTA, ou reforça pilar contextualmente relevante como "feedback de estado / confiança operacional"). Calibrar conforme `Tipo de interface` declarado nos inputs. Detalhes em `references/pillars.md`.

**Score final = média ponderada.** Aparece no sumário executivo + numa "régua" visual no documento.

---

## Output: documento A4 print-ready

### Estrutura do doc (10 capítulos)

> **Regra R16 — Títulos editoriais humanos.** Os títulos abaixo são a função estrutural do capítulo. **No documento final, traduzir pra título humano que convide o leitor a entrar** — jargão UX afasta leitor não-UX e queima sumário. Exemplos de tradução na coluna "Título humano".

| § | Função estrutural | Título humano (exemplo) | Páginas |
|---|---|---|---|
| 01 | Sumário executivo (3 frases diagnóstico + 3 solução + KPIs estimados) | "O que tá funcionando — e o que tá te custando venda" | 1 |
| 02 | Contexto (briefing, persona, setor, stack) | "Quem chega aqui (e o que ela espera)" | 1-2 |
| 03 | Diagnóstico estrutural + **empathy map + journey map explícitos** (R2) | "A jornada que ela faz" / "O que ela vê em 5 segundos" | 3-4 |
| 04 | Heurísticas violadas (Nielsen + Laws + Baymard) — **com print inline em cada finding** (R9 fortalecida) | "Os N pontos onde a landing trava" | 3-5 |
| 05 | Funil de abandono | "Onde você perde gente" | 2 |
| 06 | Acessibilidade WCAG | "Acessibilidade: você tá quase lá" / "Onde precisa endereçar AA" | 2 |
| 07 | Score por pilar | "Nota: X em 10 — e o que isso significa" | 1-2 |
| 08 | Plano de correção em sprints (impacto × esforço × risco × métrica) | "Plano: N semanas, do barato pro essencial" | 2-3 |
| 09 | **Mockup do depois** renderizado (R13) — diff cirúrgico ou hero proposto preservando DS (R14, R15) | "Como a primeira tela poderia ficar" / "As N alterações cirúrgicas" | 2-3 |
| 10 | Sistema de criação sugerido (princípios + slots + self-check) | "Para a próxima página que vocês criarem" | 2-3 |
| AP | Apêndice (capturas full-page de referência, refs citadas, ferramentas, glossário) | Apêndice A · B · C | 3-5 |

**Total:** 20-30 páginas A4.

**Regra R9 (fortalecida v0.3):** prints/crops ancoram cada finding **inline na mesma seção** — apêndice fica reservado pra capturas full-page de contexto e artefatos brutos. Quando o finding compara duas regiões da página (ex: "5.0 no hero vs 0.0 nos cards"), os dois crops aparecem lado a lado dentro do finding, não em apêndice.

**Regra R13 (nova v0.3):** §09 (protótipo de validação) **renderiza o "depois"** — mockup HTML inline no PDF OU arquivo standalone navegável. Prosa descrevendo "o que o protótipo deveria fazer" não conta como entrega. Cada P0/P1 com componente visual proposto deve aparecer renderizado.

**Regra R14 (nova v0.3):** o mockup **preserva o design system existente** por default. Tipografia, escala, paleta, layout, bordas, espaçamentos do produto auditado vêm da landing real (via DevTools getComputedStyle ou da pasta DS do projeto) e NÃO são alterados pela auditoria — exceto quando especificamente apontados como problema. Anti-pattern grave: refazer hero "do meu jeito" em vez de marcar as N alterações cirúrgicas sobre o original.

**Regra R15 (nova v0.3):** antes de produzir mockup, perguntar ao solicitante: "Manter design system existente? Ou tem liberdade pra repensar visual?" Default = `manter`.

### Regras herdadas (não negociáveis)

- **Layout A4 print-ready** com `@page { size: A4; margin: 22mm 18mm; }`
- **Tipografia editorial** — sugerido Playfair Display + Inter + JetBrains Mono (calibrar pela marca do solicitante)
- **Componentes reutilizáveis:** `.section-num`, `.section-lede`, `.kpi-grid`, `.compare`, `.sprint`, `.evidence`, `.example-pair` (lado a lado pra caber em A4)
- **Imagens com aspect ratio extremo (>5:1)** sempre com `max-height: 220mm; object-fit: contain` inline → evita página em branco no PDF
- **Caminho de arquivo / URL local NUNCA aparece no doc** — entregável é peça pública (memória `feedback_doc_externo_no_caminho_arquivo.md`)
- **Geração de PDF** via Playwright headless (`emulateMedia: 'print'` + `printBackground: true`) — receita em memória `reference_pdf_gen_playwright.md`

### Templates HTML reutilizáveis

A definir em `references/output-template.html` (subtask pendente).

---

## Fluxo de execução

```
1. Input recebido (URL + setor + persona)
2. Roda Camada 1 (captura) — 5min
3. Roda Camadas 2-5 em paralelo (cada uma gera fragmentos do doc) — 15-25min
4. Roda Camada 6 (pesquisa) — 5-10min
5. Consolida em documento HTML A4 — 3-5min
6. Self-check pré-PDF (lista abaixo)
7. Gera PDF via Playwright headless — 1-2min
8. Entrega: HTML + PDF + arquivo bruto de evidências
```

**Tempo total esperado:** 30-50min por landing.

---

## Regras de profundidade obrigatórias

**Esta skill não pode entregar auditoria superficial.** Antes de qualquer proposta, validar contra as 19 regras em [`references/depth-rules.md`](depth-rules.md). Resumo:

| # | Regra | Detecta |
|---|---|---|
| R1 | Pesquisa antes de proposta (concorrentes se sem dados internos) | Persona/jornada inventadas |
| R2 | Ordem dos frameworks: funnel → persona → **empathy** → **journey** → problem → hipóteses · empathy + journey **explícitos no doc** | Frameworks fora de ordem · empathy/journey pulados |
| R3 | 3 lentes na reorganização IA (frequência · padrão de mercado · anti-patterns) | Reorg superficial ("agrupar similares") |
| R4 | CTA principal vem ANTES do menu | CTA virou item de menu enterrado |
| R5 | Primary nav ≠ Utility nav (conta/billing/help vão pro avatar dropdown) | Utility no menu lateral |
| R6 | Toda afirmação técnica com fonte citável (NN/g, Baymard, etc) | Opinião disfarçada de fato |
| R7 | Risco real (abandono, churn, substituição) — não superficial (tempo perdido) | Diagnóstico cosmético |
| R8 | Cada P0/P1 com 4 blocos: hoje · por que problema · por que proposta · ação | Decisão a cegas |
| R9 | Prints/crops ancoram cada crítica visual **inline na seção do finding** — não em apêndice | Crítica sem evidência · prints no apêndice obrigando leitor a voltar |
| R10 | Self-check de profundidade antes de entregar | Auditoria incompleta |
| R11 | Glossário pra leitor não-UX (termos da plataforma + jargões UX) | Jargão sem explicação |
| R12 | Toda recomendação com Impacto · Esforço · Risco · Métrica de validação | Recomendação sem custo |
| **R13** | **Renderizar o "depois" visual** — mockup HTML inline ou arquivo standalone · prosa descrevendo o protótipo não conta como entrega | "Protótipo de Validação" entregue como texto |
| **R14** | **Mockup preserva design system existente** — tipografia, escala, paleta, layout, bordas, espaçamentos do produto auditado · só altera o que a auditoria apontou | Redesign autoral em vez de cirurgia mínima · identidade do produto apagada |
| **R15** | **Pergunta-zero antes de propor mockup:** "Manter DS? Liberdade pra repensar? Diff visual?" · default = manter | Auditor assume liberdade que não tem · cliente abre PDF e não reconhece próprio produto |
| **R16** | **Títulos editoriais humanos** no doc final — não jargão UX/método ("Diagnóstico Estrutural", "Heurísticas Violadas", "Funil de Abandono", "Score por Pilar" são nomes de função estrutural, não títulos visíveis) | Sumário com vocabulário da skill · leitor não-UX não sabe se vale o tempo dele |
| **R17** | **Antes de revalidar auditoria anterior, ler o doc canônico FINAL** (PDF/HTML formal entregue), não a versão preliminar (`.md`, rascunho, draft). Auditorias com peso editorial costumam ter ≥2 versões — preliminar superficial vs final refinada — e o `.md` pode estar superseded explicitamente | Revalidação em cima de proposta obsoleta · conclusões erradas apresentadas como verdade |
| **R18** | **Nome do arquivo entregável reflete o escopo** (`<slug>.html` / `<slug>.pdf`), nunca genérico `auditoria.html` / `audit.pdf`. Date fica só na pasta-mãe (`<slug>-YYYY-MM-DD/`), não no nome do arquivo dentro dela | Múltiplos PDFs com nome igual em pastas diferentes · usuário não distingue sem abrir cada um no Spotlight/quick-switcher |
| **R19** | **Imagens devem renderizar em todos contextos** (HTML preview do Claude, PDF Skia, email, share) — usar base64 inline; aspect ratios extremos têm CSS específico; sections com imagem usam `figure { break-inside: avoid }` (não `section { break-inside: avoid-page }` global); self-check via `pdfimages -list` + render visual de 3 páginas | Imagens com `src="assets/"` em sandbox falham · max-height fixo + landscape gera whitespace ≥40% percebido como "imagem sumida" |
| **R20** | **H1 da capa nomeia explicitamente tipo + escopo da auditoria** — formato `Auditoria [de tipo] [da/do/de] [escopo]` (ex: "Auditoria de Experiência da Jornada de Inscrição em Curso", "Auditoria UX do Painel Creator", "Auditoria de Acessibilidade da Landing Pública"). Subtítulo pode ser editorial/poético, **H1 não.** Stakeholder externo abre o doc e em 1s sabe o que está lendo · search/Spotlight no PDF acha por palavra-chave do escopo | Capa só com título poético ("Da curiosidade à primeira aula") sem dizer que é auditoria · leitor confunde com case study, ensaio ou pitch · sumário do PDF não tem palavra "auditoria" |
| **R21** | **Cada nota de pilar exige evidência falsificável citável** — não opinião. Pra dar 7+ em qualquer pilar, listar ≥2 evidências objetivas (axe-core, Lighthouse, getComputedStyle, screenshot crop, contagem de violações). Pilares sem medição formal recebem nota com asterisco "*sem medição" e cap de 5.0 (não inflar com palpite). Hierarquia bonita ≠ hierarquia semântica correta · landing limpa não compensa checkout quebrado | Score inflado por impressão estética · pilares com nota 7+ sem evidência citável · soma final injustificável quando questionada |
| **R22** | **Independência metodológica anti-viés** — auditoria parte do **produto em produção**, não da conversa de sessão. Pra cada P0/P1, perguntar: "esse problema veio de algo que o usuário me apontou, ou eu descobri sozinha capturando a tela?". Documentar a origem de cada finding em tabela no §10. A única decisão influenciada pela sessão pode ser a **persona-alvo** (calibra heurísticas) — tudo mais é independente | Auditor reproduz o que o usuário falou na sessão como descoberta · diagnóstico vira eco · auditoria perde autoridade quando stakeholder externo descobre que veio de briefing, não de captura |
| **R23** | **Protótipo §09 é gate bloqueante** — auditoria não pode ser entregue sem mockup renderizado. Self-check automatizado: `grep -c 'mockup-stage\|mockup-render\|prototipo' <slug>.html` deve retornar ≥2 (no mínimo 2 mockups: 1 pro pior P0 + 1 pro 2º pior P0/P1). R13 reforçada com check automatizado — descrever em prosa "o protótipo mostraria X" não passa o gate. Pilares com aspect ratio extremo OU dependência de DS exigem renderização inline | Auditoria entregue sem §09 renderizado · prosa onde deveria haver mockup · solicitante abre o PDF, chega no §09, encontra parágrafos descritivos em vez de tela proposta |
| **R24** | **JTBD obrigatório em §02** — minimum 3 jobs declarados (functional, emotional, social) seguindo formato Christensen/Ulwick: `"Quando [contexto], quero [ação], para que [resultado]."`. Bonus: card "Implicação pra auditoria" linkando ao P0 mais crítico. Persona descreve QUEM, JTBD descreve O QUE A PESSOA ESTÁ CONTRATANDO O PRODUTO PRA FAZER — sem isso o doc cita demografia em vez de motivação | §02 só com empathy map + persona · diagnóstico fica funcional sem captar motivação real · findings não conectam com "por que isso importa pra ela" |
| **R25** | **Service Blueprint condicional em §03b** — obrigatório quando o produto **cruza canais** (web + app + CLI + MCP), tem **backstage relevante** (validação assíncrona, IA, billing, fila), ou quando o briefing pede causa-raiz. Skippable em landings estáticas puras (1 canal, sem backstage). Tabela com 3 colunas: Frontstage (o que usuário vê) · Backstage (sistema/time) · Processos de suporte. Linhas = estágios da jornada. Highlight em vermelho/amarelo onde backstage falha gera finding de UX | Findings tratados como bugs de UX quando são bugs de arquitetura · plano de correção propõe "esconder o aviso" em vez de "corrigir o backstage que dispara o aviso" · solução de copy sobre causa estrutural |
| **R26** | **Moments of Truth obrigatório em §03c** — mínimo 3 MoTs declarados (Carlzon, 1986) com critério: momentos onde a percepção do produto se forma de maneira definitiva. Coluna "Findings que atingem" linkando aos P0/P1 declarados. Funciona como **validação cruzada da priorização**: se os P0 declarados NÃO atingem MoTs, a priorização do §08 está errada. Se atingem, o §08 está defensável | Plano de correção lista 10 findings com mesma criticidade aparente · time do produto não sabe onde investir primeiro · solicitante questiona "por que F-01 antes de F-05?" e auditor não tem resposta estrutural |
| **R27** | **Mental Model Map condicional em §04b** — obrigatório quando ≥2 findings compartilham padrão de mismatch entre vocabulário do produto e vocabulário do usuário. Disparador automático: 2+ findings citam Nielsen #2 "match com mundo real". Tabela 4 colunas: Conceito · Mental model do usuário · Conceptual model do sistema · Severidade do mismatch. Revela que findings aparentemente isolados são UMA CLASSE DE BUG que precisa de glossário interno como remediação sistêmica | Findings de mismatch ("checkout" pra grátis, "Investimento" pra inscrita, "créditos" sem onboarding do conceito) tratados isoladamente · plano corrige 1 a 1 sem ver o padrão · solução vira tactical em vez de estrutural |

**Regra-mãe:** se uma das 27 for violada (ou aplicável e ignorada), a auditoria está incompleta. Voltar antes de entregar.

**Lógica condicional (R25 e R27):**
- **R25 Service Blueprint** dispara obrigatório se: (a) produto cruza ≥2 canais, OU (b) Camada 1 captura indica backstage não-trivial (IA, billing, fila, sync), OU (c) briefing explicitamente pede causa-raiz. Caso contrário, OPCIONAL.
- **R27 Mental Model Map** dispara obrigatório se: ≥2 findings citam Nielsen #2 (match com mundo real) OU palavras do produto aparecem em ≥2 findings como problema (ex: "checkout" + "investimento" + "créditos"). Caso contrário, OPCIONAL.
- Quando OPCIONAL e não-aplicado, documentar no §10 "Sobre esta auditoria" por que foi pulado (1 frase).

---

## Self-check pré-entrega

Antes de gerar o PDF e marcar entregue, validar:

**Conteúdo + estrutura:**
- [ ] Score por pilar com justificativa em 1 frase cada
- [ ] Plano em sprints com 4 colunas: Impacto · Esforço · Risco · Métrica de validação (R12)
- [ ] § 10 (sistema de criação) presente e prescritivo, não descritivo
- [ ] Mínimo 3 referências de mercado citadas com URL + screenshot
- [ ] Apêndice tem capturas full-page desktop + mobile da landing original (apenas como contexto — prints específicos de cada finding ficam inline)

**Frameworks na ordem (R2):**
- [ ] §03 do doc tem **journey map explícito** (não só "ordem das seções") — mínimo 5–6 estágios com estado emocional/pensamento por estágio
- [ ] §02 ou §03 tem **empathy map por persona** — pensa · vê · ouve · sente · barreira — derivado de fonte real (R1) e não inventado
- [ ] Funnel/drop-off (§05) vem DEPOIS de empathy + journey, não antes

**Evidência visual (R9 + R13):**
- [ ] Cada finding P0/P1 com componente visual tem **print/crop inline na própria seção** — não em apêndice
- [ ] §09 entrega **mockup renderizado** (HTML inline ou standalone) — prosa descrevendo "como o protótipo deveria ser" é violação de R13

**Respeito ao design existente (R14 + R15):**
- [ ] Perguntei ao solicitante "Manter DS existente?" antes de produzir mockup (R15)
- [ ] Mockup proposto usa **tokens reais do produto** (tipografia, escala, paleta, layout) — confirmado via DevTools getComputedStyle ou pasta DS do projeto
- [ ] Tabela "O que NÃO muda" presente no §09 listando explicitamente o que permanece intocado
- [ ] Cada alteração proposta tem justificativa em 1 frase (linkando ao finding) + linha "Preserva: ..."

**Linguagem do doc (R16 + R11):**
- [ ] Títulos de seção visíveis são **editoriais humanos**, não jargão da skill ("Diagnóstico Estrutural", "Heurísticas Violadas", "Funil de Abandono", "Score por Pilar" são nomes internos — não aparecem como título no doc)
- [ ] Glossário no apêndice cobre termos UX + termos específicos do produto auditado
- [ ] Toda label em inglês do produto tem tradução PT-BR entre colchetes na primeira menção

**Pente fino de coerência (rodar SEMPRE — ver `references/coherence-sweep.md`):**
- [ ] Decisões prévias da sessão refletidas em TODAS as passagens correlatas (sweep grep do termo antigo + novo)
- [ ] Labels capturados (real) usados em narrativa, não labels memorizados antigos
- [ ] Math fecha (pesos = 1.00, score em todos os lugares = mesma nota, contagens partida → migração → chegada)
- [ ] Numeração sequencial (capítulos, cleanup-list, sprint-table) sem gap
- [ ] Refs cruzadas (§ XX) apontam pra seção que existe
- [ ] Crítica visual ancorada em print (R9) ou marcada como "print pendente"

**Artefato técnico:**
- [ ] PDF gerado com `printBackground: true` (cores fundamentais não desaparecem)
- [ ] Imagens com aspect ratio extremo têm CSS específico (não usar `max-height: 220mm` genérico — ver R19.B)
- [ ] Sem caminho de arquivo / URL local visível no documento
- [ ] Tamanho do PDF < 10MB (acima indica imagens não otimizadas)

**Naming do entregável (R18 · v0.5):**
- [ ] Arquivo HTML se chama `<slug>.html` (não `auditoria.html`)?
- [ ] Arquivo PDF se chama `<slug>.pdf` (não `auditoria.pdf`)?
- [ ] Slug do arquivo bate com a pasta-mãe (sem a data)?
- [ ] Se eu baixar 5 PDFs de auditorias diferentes pra Downloads, consigo distinguir só pelo nome?

**Imagens renderizam em todos contextos (R19 · v0.5):**
- [ ] **Todas as `<img>` usam base64 inline** (`grep -c 'src="assets/' <slug>.html` retorna `0`)?
- [ ] `grep -c 'src="data:image' <slug>.html` retorna número igual ao total de `<img>` inseridas?
- [ ] **Após gerar PDF**, rodei `pdfimages -list <slug>.pdf | tail -n +3 | wc -l` e count ≥ número de `<img class="full">` no HTML?
- [ ] **Após gerar PDF**, renderizei pelo menos 3 páginas com imagens via `pdftoppm` e confirmei visualmente:
  - imagem aparece (não placeholder vazio)
  - não há whitespace > 40% abaixo da imagem
  - aspect ratio não distorcido
- [ ] Aspect ratios extremos (>2.5:1 landscape OU >1:1.8 portrait) têm CSS específico, não `max-height: 220mm` genérico
- [ ] Sections com imagem usam `figure { break-inside: avoid }` ao redor da `<img>` específica, não `section { break-inside: avoid-page }` global
- [ ] Tamanho do HTML final está entre 1-4 MB (se < 100 KB suspeitar de assets faltando; se > 8 MB otimizar PNGs com `oxipng -o4` ou `pngquant`; fallback macOS: `sips -Z 1200 -s format jpeg -s formatOptions 78`)
- [ ] Abri o HTML no preview panel do Claude Code OU outro contexto sandbox e confirmei que imagens aparecem (não só no Skia/PDF do Playwright)

**H1 da capa nomeia tipo + escopo (R20 · v0.5.1):**
- [ ] H1 da capa começa com a palavra **"Auditoria"** (não título só poético/editorial)?
- [ ] H1 nomeia o **tipo de auditoria** (UX, de Experiência, de Acessibilidade, de Performance, etc.)?
- [ ] H1 nomeia o **escopo específico** (jornada de inscrição, painel creator, landing pública, etc.)?
- [ ] `<title>` do `<head>` reflete o H1 e inclui nome do produto + data (pra resultado de busca + Spotlight)?
- [ ] Stakeholder externo que abre o PDF sem briefing entende em 1s o que está lendo?
- [ ] Subtítulo (h2 ou `.cover-subtitle`) pode ser editorial/poético — mas é complementar, não substituto do H1?

**Score falsificável (R21 · v0.5.2):**
- [ ] Cada pilar com nota ≥7 tem **2+ evidências objetivas citáveis** (axe-core ID, Lighthouse score, getComputedStyle, count de violações, screenshot crop)?
- [ ] Pilares sem medição formal (ex: Performance sem Lighthouse) têm **asterisco "*sem medição"** e nota ≤5.0?
- [ ] Cada justificativa de pilar lista **evidência específica**, não impressão estética ("editorial bonito" → 7.5 é violação R21)?
- [ ] Pesos somam **exatamente 1.00**?
- [ ] Recalculei a soma ponderada à mão e bate com o "Score final" exibido?
- [ ] Se solicitante questionar nota X, consigo defender com evidência citável **sem refazer o raciocínio**?

**Independência metodológica anti-viés (R22 · v0.5.2):**
- [ ] §10 tem **tabela explícita "Origem de cada finding"** (Produto · Sessão · ⚠️Sessão flagged)?
- [ ] Cada P0/P1 tem coluna **"o que me convenceria do contrário"** documentando hipótese de falsificação?
- [ ] **Única decisão da sessão é persona-alvo** (input obrigatório do método); tudo mais vem do produto?
- [ ] Se o usuário **não tivesse falado nada** além de "audita aqui", eu chegaria nos mesmos findings? Se não, identifico o(s) que foi(ram) sugestionado(s)?
- [ ] Não usei expressões como "como você comentou", "conforme apontado por", "a solicitante mencionou" em nenhum finding — auditor partiu da tela, não da conversa?

**§09 mockup é gate bloqueante (R23 · v0.5.2):**
- [ ] `grep -c 'mockup-stage\|mockup-render\|prototipo-render' <slug>.html` retorna **≥2**?
- [ ] §09 entrega **mockup HTML inline renderizado** pro pior P0 + pro 2º pior P0/P1 (mínimo 2 mockups)?
- [ ] **Nenhum parágrafo de prosa** descrevendo "como o protótipo deveria ser" no §09 — todos os mockups são visuais?
- [ ] Tabela "O que NÃO muda" presente no §09 (já obrigatória em R14)?
- [ ] Mockup usa tokens reais do DS (já obrigatório em R14)?

**Ferramentas de descoberta de jornada (R24-R27 · v0.6):**

**R24 · JTBD em §02 (sempre obrigatório):**
- [ ] §02 tem **3 jobs declarados** (functional, emotional, social) no formato `"Quando [contexto], quero [ação], para que [resultado]"`?
- [ ] Bonus: card "Implicação pra auditoria" linkando o job dominante ao P0 mais crítico?
- [ ] Os 3 jobs **não inventam** motivações sem base — derivam de pesquisa real, briefing, ou análise de produto comparável (R1)?

**R25 · Service Blueprint em §03b (condicional):**
- [ ] Identifiquei se produto cruza ≥2 canais OU tem backstage não-trivial?
- [ ] Se SIM aplicável: tabela 3 colunas (Frontstage · Backstage · Processos suporte) por estágio?
- [ ] Highlights coloridos onde backstage falha gera finding de UX (transforma sintoma em causa-raiz)?
- [ ] Se NÃO aplicável (landing estática pura): §10 documenta por que foi pulado em 1 frase?

**R26 · Moments of Truth em §03c (sempre obrigatório):**
- [ ] Mínimo **3 MoTs declarados** com critério "momento onde percepção se forma de maneira definitiva"?
- [ ] Cada MoT tem coluna "Findings que atingem" linkando a tag de severidade?
- [ ] **Validação cruzada:** P0s declarados caem em MoTs? Se não, justificar ou rever priorização do §08?

**R27 · Mental Model Map em §04b (condicional):**
- [ ] Contei findings que citam Nielsen #2 ou palavras-do-produto como problema?
- [ ] Se ≥2 → tabela 4 colunas (Conceito · Mental model usuário · Conceptual model sistema · Severidade)?
- [ ] Conclusão da tabela identifica explicitamente "estes N findings compartilham a mesma raiz estrutural"?
- [ ] Recomendação de glossário interno como remediação sistêmica linkando ao §10?
- [ ] Se <2 mismatches: §10 documenta que foi pulado em 1 frase?

---

## Anti-patterns (não fazer)

- **Não** descrever a landing — auditar é diagnóstico, não recap
- **Não** suavizar críticas pra agradar o solicitante
- **Não** dar plano de correção sem priorização (impacto × esforço × risco é obrigatório)
- **Não** copiar refs sem citar (URL + screenshot ou nada)
- **Não** colocar "achei legal", "fica bonito", "parece" — toda afirmação ancora em heurística + evidência
- **Não** entregar HTML sem gerar PDF — PDF é o artefato canônico
- **Não** colocar prints em apêndice quando ancoram um finding específico (R9) — leitor não volta procurar
- **Não** entregar §09 "Protótipo de Validação" como texto descritivo (R13) — se diz que precisa de mockup, o mockup é renderizado
- **Não** redesenhar o hero "do meu jeito" em nome de "melhoria UX" (R14) — auditoria entrega diagnóstico + recomendação cirúrgica, redesign é trabalho do time do produto
- **Não** assumir liberdade de redesign sem perguntar (R15) — pergunta-zero "Manter DS?" é obrigatória antes de qualquer mockup
- **Não** usar títulos de seção com jargão UX/método no doc final (R16) — "Diagnóstico Estrutural", "Heurísticas Violadas" são nomes internos, não fachada
- **Não** pular empathy map / journey map em nome de "ir direto pro funnel" (R2) — funnel sem journey é diagnóstico sem contexto humano
- **Não** salvar arquivo como `auditoria.html`/`audit.pdf`/`report.html` (R18) — sempre `<slug>.html`/`<slug>.pdf` pra distinguir entre múltiplas auditorias no quick-switcher
- **Não** usar `src="assets/..."` em `<img>` (R19) — base64 inline obrigatório, falha em preview panel + sandbox + email
- **Não** colocar título poético/editorial isolado no H1 da capa (R20) — H1 nomeia tipo + escopo ("Auditoria de Experiência da Jornada de Inscrição"); subtítulo pode ser poético
- **Não** dar nota ≥7 em pilar sem 2+ evidências citáveis (R21) — "editorial bonito" não é evidência; "Georgia 56px + ratio 1:1.6 em 4 telas + 0 violations a11y" é
- **Não** dar nota em Performance sem rodar Lighthouse (R21) — preferir asterisco "*sem medição" + cap 5.0 a especular
- **Não** reproduzir como descoberta o que o usuário apontou na sessão (R22) — diagnóstico vira eco, perde autoridade externa
- **Não** entregar §09 como parágrafos descritivos (R23 fortalecendo R13) — gate automatizado: `grep mockup-stage` ≥2 ou auditoria volta
- **Não** pular JTBD em §02 (R24) — persona sem JTBD é demografia sem motivação; doc cita quem mas não capta o quê
- **Não** tratar findings de UX como problemas isolados quando há backstage envolvido (R25) — sem Service Blueprint, F-01 estilo "paywall pós-grátis" vira bug de copy quando é bug de arquitetura
- **Não** declarar P0 sem ancorar em MoT (R26) — se a priorização não passa pela validação cruzada "atinge MoT?", está arbitrária
- **Não** corrigir findings de mismatch um a um (R27) — quando ≥2 findings compartilham padrão de vocabulário, a solução é glossário sistêmico, não fix tactical

---

## Referências internas

- **Casos de uso reais:** áreas logadas (painéis), landing pages públicas e fluxos multi-step — calibraram as regras R13–R18 desta skill.
- **Memórias relevantes:**
  - `feedback_doc_externo_no_caminho_arquivo.md` — não vazar caminhos de arquivo no doc entregue
  - `reference_pdf_gen_playwright.md` — receita de geração de PDF
  - `feedback_skills_no_correlation.md` — independência entre skills
  - `feedback_audit_show_after.md` — R13 · sempre renderizar o depois visual (v0.3)
  - `feedback_audit_inline_evidence.md` — R9 fortalecida · prints inline na seção do finding, não em apêndice (v0.3)
  - `feedback_titles_no_jargon.md` — R16 · títulos editoriais humanos no doc visível (v0.3)
  - `feedback_audit_preserve_design_system.md` — R14 + R15 · mockup preserva DS · pergunta-zero antes de propor (v0.3)
  - `feedback_audit_read_final_not_preliminary.md` — R17 · ler doc canônico final antes de revalidar, nunca preliminar (.md) (v0.4)
  - `feedback_audit_filename_scope.md` — R18 · nome do arquivo entregável reflete escopo, nunca genérico (v0.5)
  - `feedback_audit_images_base64.md` — R19 · imagens base64 inline obrigatório, falha em sandbox/preview com path relativo (v0.5)
  - `feedback_audit_h1_names_scope.md` — R20 · H1 da capa nomeia tipo + escopo ("Auditoria de Experiência de X"); subtítulo pode ser poético, H1 não (v0.5.1)
  - `feedback_audit_score_falsifiable.md` — R21 · score por pilar com evidência citável, não impressão estética; sem medição = asterisco + cap 5.0 (v0.5.2)
  - `feedback_audit_independence_anti_bias.md` — R22 · auditoria parte do produto, não da conversa de sessão; "o que me convenceria do contrário" pra cada finding (v0.5.2)
  - `feedback_audit_prototype_gate.md` — R23 · §09 mockup renderizado é gate bloqueante; grep automatizado ≥2 mockups inline (v0.5.2)
  - `feedback_audit_jtbd_required.md` — R24 · JTBD obrigatório em §02 com 3 jobs (functional/emotional/social); persona sem JTBD é demografia sem motivação (v0.6)
  - `feedback_audit_service_blueprint.md` — R25 · Service Blueprint condicional em §03b; transforma findings de UX em findings de arquitetura quando produto tem backstage relevante (v0.6)
  - `feedback_audit_moments_of_truth.md` — R26 · Moments of Truth obrigatório em §03c; validação cruzada de priorização do §08 (v0.6)
  - `feedback_audit_mental_model_map.md` — R27 · Mental Model Map condicional em §04b; revela findings compartilhando classe estrutural quando há ≥2 mismatches de vocabulário (v0.6)

---

## TODO antes de marcar v1

- [x] Criar `references/output-template.html` (extrair do doc Pedro como base reutilizável)
- [x] Criar `references/heuristics.md` (Nielsen + Laws of UX + Baymard com referência citável por item)
- [x] Criar `references/design-systems.md` (resumo dos 5 DS embutidos)
- [x] Criar `references/pillars.md` (detalhamento dos 6 pilares + critérios de pontuação)
- [x] Criar `references/pdf-recipe.md` (script Playwright copiável)
- [x] Criar `references/capture-strategy.md` (5 alternativas a login manual + heurística a11y sem login) — adicionado v0.2 após 1ª rodada
- [x] Criar `references/coherence-sweep.md` (pente fino obrigatório antes de PDF) — adicionado v0.2 após 1ª rodada
- [x] 1ª rodada real (ToStudy /student/* — área logada, painel dashboard, 56 págs A4)
- [x] 2ª rodada real (ToStudy landing pública /pt-BR 11/05/2026) — calibrou R13–R16 e os títulos editoriais
- [x] 3ª rodada real (revalidação menu /student 11/05/2026 tarde) — calibrou R17 (ler doc final, não preliminar)
- [ ] Atualizar `references/output-template.html` v0.3 com componentes novos: `.journey-row`, `.empathy-card`, `.diff-wrap` + `.diff-marker` + `.diff-item`, `.preserve-table` (extrair do doc tostudy 11/05/2026)
- [ ] Testar em 1 outro tipo de produto (SaaS B2B, e-commerce, app mobile) pra calibrar pesos
- [ ] Calibrar pesos dos pilares com base nas 3 rodadas (student painel + landing + 3º tipo)
