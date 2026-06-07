# Design systems embutidos — `design-auditoria`

Cinco DS consolidados que ficam como **base estável** da Camada 6 (pesquisa de referência). Não mudam toda hora, são citáveis, cobrem ~90% dos padrões de landing.

Quando a auditoria precisar referenciar um padrão de mercado ("botão primário deve ter X", "form fields seguem Y"), priorizar essas fontes — só ir pra web em busca de **concorrentes específicos do setor** ou **padrões emergentes**.

---

## 1. Material Design 3 (Google)

**URL:** [m3.material.io](https://m3.material.io)

**Forte em:**
- Sistemas de cor com tokens (light/dark, accessibility-first)
- Tipografia escalonada com escala matemática
- Componentes de form muito maduros (text fields, dropdowns)
- Motion guidelines (durations, easing)
- States: hover, focus, pressed, disabled, dragged

**Quando citar:** padrões de **input**, **button**, **app bars**, **navigation**, **motion**.

**Como citar:** "Padrão Material Design 3 — botão primário com elevação 0 em rest e 1 em hover. Ref: m3.material.io/components/buttons/specs"

---

## 2. Apple Human Interface Guidelines (HIG)

**URL:** [developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)

**Forte em:**
- Princípios de design (hierarchy, consistency, deference)
- Tipografia editorial com pareamento
- Espaçamento em base 4 pt
- Microinterações refinadas
- Padrões de navegação iOS/macOS (transferíveis pra mobile web)

**Quando citar:** padrões de **clareza visual**, **hierarchy**, **microcopy**, **mobile UX**.

**Como citar:** "Apple HIG recomenda áreas tappáveis ≥ 44×44 pt. Ref: developer.apple.com/design/human-interface-guidelines/layout"

---

## 3. Atlassian Design System

**URL:** [atlassian.design](https://atlassian.design)

**Forte em:**
- Padrões para **produtos B2B / SaaS**
- Forms longos e complexos
- Empty states bem desenhados
- Tom de voz consistente
- Densidade de informação (jira-style)

**Quando citar:** landings de **SaaS B2B**, dashboards, ferramentas de produtividade.

**Como citar:** "Atlassian Design — empty state primário com ilustração + headline + 1 CTA. Ref: atlassian.design/components/empty-state/usage"

---

## 4. Salesforce Lightning Design System (SLDS)

**URL:** [lightningdesignsystem.com](https://www.lightningdesignsystem.com)

**Forte em:**
- Padrões para **enterprise** (alta densidade, alta complexidade)
- Data tables sofisticadas
- Forms com validação avançada
- Acessibilidade WCAG AA por padrão

**Quando citar:** landings de **enterprise software**, sistemas de **CRM/ERP**, ferramentas com **muito dado**.

**Como citar:** "SLDS define hierarquia de notification em 4 níveis (info/success/warning/error). Ref: lightningdesignsystem.com/components/notifications"

---

## 5. Carbon Design System (IBM)

**URL:** [carbondesignsystem.com](https://carbondesignsystem.com)

**Forte em:**
- Tipografia editorial + tech (IBM Plex)
- Grid system muito disciplinado (2x base, 4x base)
- Padrões de produto enterprise
- Acessibilidade
- Documentação de **conteúdo / tom de voz**

**Quando citar:** landings com **viés editorial/corporativo**, B2B sério, finance/legal/healthcare.

**Como citar:** "Carbon recomenda max-width 672px pra blocos de body text. Ref: carbondesignsystem.com/guidelines/typography/productive"

---

## Estratégia híbrida (decisão FEAT-016)

| Fonte | Quando usar | Custo |
|---|---|---|
| **Embutida** (estes 5 DS) | Padrões consolidados, "best practice" geral | Zero — citação direta |
| **Web em tempo real** | Concorrentes do setor (auditoria-específica), tendências recentes (<6 meses), padrões locais (mercado BR) | Toolcalls — usar com economia |
| **Pasta fornecida** | Cliente passou refs próprias (logo, brand, screenshots) | Zero — prioridade máxima |

**Regra:** se a referência é **padrão consolidado**, prefira embutida. Reserve web pra **concorrência direta** ou **padrões setoriais específicos**.

**Como combinar num doc:** apêndice tem 3 blocos:
1. **Design systems referenciados** (extraído daqui)
2. **Concorrentes do setor** (3-5 via web, com screenshot)
3. **Refs do cliente** (se houver)

Cada item com URL + screenshot embutido.

---

## Quando NÃO usar nenhum DS

Se a landing pertence a um **nicho com estética própria** (e.g., agências criativas, marcas de luxo, indie SaaS com identidade forte), **nenhum dos 5 acima é referência**. Nesse caso:

- Buscar **3-5 concorrentes diretos via web** (camada 6 web)
- Citar 1-2 **landings premiadas** (Awwwards, CSS Design Awards) do mesmo setor
- Documentar no doc: "Esta landing opera num nicho onde DS consolidados são pouco aplicáveis. Referências de mercado priorizadas."

Honestidade é regra: não force Material Design numa landing de joalheria.
