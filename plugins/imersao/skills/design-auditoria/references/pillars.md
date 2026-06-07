# Pilares de score — `design-auditoria`

Seis pilares ponderados. Total = 1.0. Cada pilar nota 0-10 com justificativa em 1 frase.

| # | Pilar | Peso |
|---|---|---:|
| 1 | Hierarquia & legibilidade visual | 0.20 |
| 2 | Clareza de proposta + CTA | 0.20 |
| 3 | Acessibilidade (WCAG AA) | 0.20 |
| 4 | Performance & responsividade | 0.15 |
| 5 | Prova social & confiança | 0.15 |
| 6 | Polimento & craft | 0.10 |

**Score final** = Σ (pilar × peso). Aparece no sumário executivo + numa "régua" visual no documento.

---

## 1. Hierarquia & legibilidade visual (0.20)

**O que avalia:** ordem de leitura, contraste de pesos tipográficos, escala, ritmo vertical, agrupamento, white space.

**Rubrica:**
- **9-10** — Hierarquia inequívoca: usuário sabe em <1s o que ler primeiro. Tipografia segue escala consistente (3-5 níveis). Espaçamento conta a história.
- **7-8** — Hierarquia clara mas com 1-2 ruídos: peso/cor competindo, headline e sub indistintos.
- **5-6** — Hierarquia presente mas frágil: precisa de 2-3s pra orientar.
- **3-4** — Sem hierarquia clara: tudo grita igual ou tudo sussurra.
- **0-2** — Caos visual.

**Violações típicas:** body com peso bold, todos os títulos no mesmo tamanho, CTA com mesma proeminência da nav, ausência de white space respiratório, ratios não derivados de escala (text-base sem relação com text-lg).

---

## 2. Clareza de proposta + CTA (0.20)

**O que avalia:** dá pra explicar a oferta em 5s? CTA primário identificável de cara? Funil até a conversão é direto?

**Rubrica:**
- **9-10** — Em 5s o visitante sabe (a) o que é, (b) pra quem é, (c) o que fazer. CTA primário único, fisicamente proeminente, ação clara ("Agendar consulta", não "Saiba mais").
- **7-8** — Proposta clara mas CTA ambíguo, ou vice-versa.
- **5-6** — Precisa de scroll pra entender. CTA primário coexiste com 2-3 secundários.
- **3-4** — Mensagem genérica ("Soluções inteligentes pra seu negócio"), CTAs múltiplos competindo.
- **0-2** — Não dá pra dizer o que vendem nem o que querem que faça.

**Violações típicas:** headline metafórico sem subhead aterrissando, CTA "Saiba mais" sem destino claro, 4+ CTAs na primeira dobra, hero sem proposta + sem CTA visível.

---

## 3. Acessibilidade (WCAG AA) (0.20)

**O que avalia:** contraste, foco, navegação por teclado, alt text, landmarks, motion.

**Rubrica:**
- **9-10** — Lighthouse A11y ≥ 95. axe-core 0 erros críticos. Nav teclado completa com focus visível. Sem motion involuntário.
- **7-8** — Lighthouse 85-94. axe com 1-3 erros menores.
- **5-6** — Lighthouse 70-84. Problemas óbvios de contraste em 1 região.
- **3-4** — Lighthouse 50-69. Múltiplos elementos sem alt, focus invisível.
- **0-2** — Lighthouse < 50. Inacessível pra teclado e leitor de tela.

**Violações típicas:** body em cinza claro (#999) sobre branco, focus removido com `outline: none` sem substituição, autoplay de vídeo com som, ícones decorativos sem aria-hidden, alt vazio em imagens informativas.

---

## 4. Performance & responsividade (0.15)

**O que avalia:** LCP, CLS, INP, fluidez em 5 breakpoints (320, 480, 768, 1024, 1440), peso de assets.

**Rubrica:**
- **9-10** — LCP ≤ 2.5s, CLS ≤ 0.1, INP ≤ 200ms. Layout fluido em todos os breakpoints. Imagens otimizadas (WebP/AVIF, srcset).
- **7-8** — LCP ≤ 4s, CLS ≤ 0.25. 1 breakpoint com glitch visual.
- **5-6** — LCP > 4s OU CLS > 0.25. 2-3 breakpoints quebrados.
- **3-4** — LCP > 6s. Mobile inviável (overflow horizontal, fonte 10px).
- **0-2** — Página não carrega em <10s ou quebra em mobile completamente.

**Violações típicas:** hero image sem otimização (>500KB), fonte personalizada bloqueando render, CLS por banner de cookies tardio, breakpoints "fixos" (sem fluido entre 768 e 1024).

---

## 5. Prova social & confiança (0.15)

> **Aplicabilidade contextual:** este pilar foi pensado pra **landing pública**. Em painel logado, dashboard, fluxo ou app, perde aplicação direta — ver "Redistribuição de pesos" no fim deste arquivo.

**O que avalia:** testemunhos, logos de clientes, números (anos, clientes, projetos), garantias, transparência.

**Rubrica:**
- **9-10** — Prova social ancorada: testemunhos com nome+foto+empresa+contexto, números verificáveis, logos reais de clientes reconhecíveis, garantia explícita.
- **7-8** — Prova social presente mas genérica (testemunhos sem foto, "5000 clientes" sem fonte).
- **5-6** — Apenas 1 forma de prova (só logos OU só testemunhos).
- **3-4** — Prova social vaga ("muitos clientes confiam", "anos de experiência").
- **0-2** — Sem prova social.

**Violações típicas:** testemunho com "João S., empreendedor" (sem empresa), logos genéricos ou fake, números redondos suspeitos sem fonte, ausência de qualquer endereço/CNPJ/info verificável.

---

## 6. Polimento & craft (0.10)

**O que avalia:** atenção a detalhes finos. Alinhamentos, transições, microinterações, copy revisada, ícones consistentes, ausência de bug visual.

**Rubrica:**
- **9-10** — Tudo alinhado ao pixel. Microinterações em hover/focus/active. Copy sem typo, sem inglês onde devia ser pt, sem placeholder lorem ipsum esquecido. Ícones de uma família só.
- **7-8** — 1-2 inconsistências sutis (ícone fora da família, transição faltando, vírgula errada).
- **5-6** — 3-5 inconsistências visíveis. Copy com 1 typo. Mistura de bordas/sombras inconsistentes.
- **3-4** — 6+ inconsistências. Lorem ipsum visível, imagens placeholder, links quebrados.
- **0-2** — Página parece WIP. Bug visual em 1ª dobra.

**Violações típicas:** ícones outline misturados com solid, button-radius 4px aqui e 12px ali, hover sem feedback, "Loren ipsum" esquecido, link "saiba mais" 404, drop shadow desigual.

---

## Como calcular o score final

```
score_final = Σ (pilar_n × peso_n)

Exemplo:
  Hierarquia        7  × 0.20 = 1.40
  Clareza+CTA       6  × 0.20 = 1.20
  WCAG              5  × 0.20 = 1.00
  Performance       8  × 0.15 = 1.20
  Prova social      4  × 0.15 = 0.60
  Polimento         7  × 0.10 = 0.70
                              ━━━━━
  Total             6.10 / 10
```

**Veredicto:**
- **≥ 8.0** — Pronto pra produção, refino contínuo.
- **6.0-7.9** — Vai pro ar, mas com plano de correção em sprints (impacto × esforço × risco).
- **4.0-5.9** — Não recomendado. Refazer pilares com nota < 5 antes de lançar.
- **< 4.0** — Reformulação geral. Recomeçar do diagnóstico estrutural.

**Regra editorial:** veredicto aparece logo no sumário executivo, em frase única. Justificativas detalhadas no § 07 (Score por pilar) e § 08 (Plano de correção).

---

## Redistribuição contextual de pesos (por tipo de interface)

Os pesos default cobrem **landing pública**. Outros tipos de interface redistribuem o peso do Pilar 5 (prova social) — que perde aplicação direta — pra reforçar pilares contextualmente relevantes.

| Tipo | Hierarquia | Clareza+CTA | A11y | Perf | Prova social | Polimento |
|---|---:|---:|---:|---:|---:|---:|
| Landing pública (default) | 0.20 | 0.20 | 0.20 | 0.15 | 0.15 | 0.10 |
| Painel logado / dashboard | 0.25 | 0.25 | 0.20 | 0.15 | 0.05 ⁽²⁾ | 0.10 |
| Fluxo multi-step | 0.20 | 0.30 | 0.20 | 0.15 | 0.05 ⁽²⁾ | 0.10 |
| App / produto | 0.20 | 0.25 | 0.20 | 0.20 | 0.05 ⁽²⁾ | 0.10 |

⁽²⁾ Em interfaces logadas, "prova social" é reinterpretada como **feedback de estado / confiança operacional** — indicadores de status do sistema, mensagens de sucesso/erro graceful, transparência sobre o que o sistema está fazendo. Total = 1.0 sempre.

**Regra:** declarar o peso usado no início do § 07. Se peso não-default, justificar em 1 frase ("redistribuído por ser painel logado").
