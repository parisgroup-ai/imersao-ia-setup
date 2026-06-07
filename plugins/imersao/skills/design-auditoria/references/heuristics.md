# Heurísticas aplicadas — `design-auditoria`

Catálogo de referências citáveis pra Camada 3. Cada violação detectada na auditoria registra o formato:

```
{heurística} | {evidência (screenshot/print HTML)} | {severidade P0/P1/P2} | {referência citável (URL)}
```

---

## Nielsen — 10 Heurísticas de Usabilidade

Fonte canônica: [Nielsen Norman Group — 10 Usability Heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/) (2020 update).

| # | Heurística | Aplicação em landing |
|---|---|---|
| H1 | **Visibilidade do status do sistema** | Loading states em form/CTA, feedback após submit, indicador de progresso em multi-step |
| H2 | **Match com o mundo real** | Linguagem do setor (não jargão interno), ordem natural ("CEP→endereço", não "endereço→CEP"), ícones reconhecíveis |
| H3 | **Controle e liberdade** | Botão "voltar" em fluxos, "fechar" em modal proeminente, opt-out de newsletter sem armadilha |
| H4 | **Consistência e padrões** | CTA primário sempre da mesma cor, ícones de uma família, hover behavior consistente, lados (logo esquerda, ações direita) |
| H5 | **Prevenção de erros** | Validação inline em forms, confirmação antes de ações destrutivas, defaults seguros |
| H6 | **Reconhecimento > recall** | Não esconder info crítica em tooltips, repetir contexto em forms longos, breadcrumbs |
| H7 | **Flexibilidade e eficiência** | Atalhos de teclado em fluxos repetidos, autopreenchimento em forms, busca além de navegação |
| H8 | **Design estético e minimalista** | Cada elemento ganha seu lugar; remover ou justificar. Whitespace ≠ desperdício |
| H9 | **Reconhecer, diagnosticar, recuperar de erros** | Mensagens de erro humanas (não "Error 500"), sugestão de ação ("tente novamente em 1min"), preservação de input |
| H10 | **Ajuda e documentação** | FAQ visível, chat/contato acessível, links de help sem tirar contexto |

**Como citar:** "Violação Nielsen H4 (Consistência) — três variações de border-radius nos cards (4px, 8px, 12px). Ref: nngroup.com/articles/ten-usability-heuristics"

---

## Laws of UX (top 8 pra landing)

Fonte canônica: [lawsofux.com](https://lawsofux.com/) (Jon Yablonski).

| Lei | Ideia central | Aplicação em landing |
|---|---|---|
| **Fitts's Law** | Tempo pra atingir alvo cresce com distância e cai com tamanho do alvo | CTA primário ≥ 44px altura, áreas tappáveis em mobile com padding generoso |
| **Hick's Law** | Tempo de decisão cresce com nº de opções | Hero com 1 CTA primário, máx 2 secundários. Nav com ≤ 5-7 items |
| **Jakob's Law** | Usuários esperam que seu site funcione como os outros que conhecem | Hambúrguer no topo, busca à direita, carrinho à direita, login no canto |
| **Miller's Law** | 7±2 itens na memória de trabalho | Listas com até 5-7 features, agrupar em chunks |
| **Tesler's Law** | Toda complexidade tem mínimo irredutível — alguém vai pagar (sistema ou usuário) | Forms longos com auto-fill em vez de pedir tudo manualmente |
| **Von Restorff Effect** | Item visualmente diferente é lembrado | CTA primário com cor de destaque única na página |
| **Aesthetic-Usability Effect** | Usuários percebem design bonito como mais usável | Investir em primeira impressão visual reduz fricção percebida |
| **Doherty Threshold** | Resposta < 400ms mantém atenção | Loading visual em qualquer ação > 400ms (skeleton, spinner, progressivo) |

**Como citar:** "Violação Hick's Law — primeira dobra com 5 CTAs competindo (Agendar, Conhecer, Solicitar Demo, Ver Preço, Baixar PDF). Ref: lawsofux.com/hicks-law"

---

## Baymard Institute (quando aplicar)

Fonte: [baymard.com/research](https://baymard.com/research) — referência canônica em e-commerce e form-heavy UX.

**Quando usar:** landing tem **checkout, cart, multi-step form, comparação de produto, busca + filtros**. Caso contrário, Nielsen + Laws of UX bastam.

**Padrões mais aplicáveis:**

- **Mobile checkout** — campos auto-formatados, teclado numérico em CEP/CPF/cartão, salvar progresso
- **Form fields** — labels acima do input (não dentro), erro inline e em tempo real, exemplos visuais ("(11) 98765-4321")
- **Search & filter** — autocomplete progressivo, filtros aplicáveis em batch, "limpar filtros" sempre disponível
- **Product page** — galeria com zoom, especificações em scanner-friendly format, prova social próxima ao CTA

**Como citar:** "Violação Baymard E-Commerce — campo CEP sem auto-preencher endereço (estudo 2022, Baymard 'Address Forms'). Ref: baymard.com/checkout-usability"

---

## Severidades

Padrão herdado do doc Pedro:

| Severidade | Critério | Exemplo |
|---|---|---|
| **P0** | Bloqueia conversão. Usuário desiste ou erra no fluxo crítico | CTA invisível, form quebrado em mobile, link 404 no botão principal |
| **P1** | Atrito significativo, mas usuário consegue completar | Hierarquia confusa, copy ambígua, contraste WCAG AA falhando |
| **P2** | Polimento. Não bloqueia, mas reduz percepção de qualidade | Ícone fora de família, hover sem feedback, microcopy genérico |

**Distribuição esperada num doc:** 60-70% P1, 20-30% P2, 10% P0. Se for tudo P0, calibragem do auditor está errada (excesso de drama). Se for tudo P2, perdeu o foco (estética > função).

---

## Cobertura mínima por auditoria

Pelo menos uma evidência citada de cada bloco:

- [ ] Nielsen — mín. 3 das 10 heurísticas violadas detectadas (se nenhuma viola: declarar explicitamente)
- [ ] Laws of UX — mín. 2 das 8 leis aplicadas
- [ ] Baymard — só se aplicável (skip explícito quando não)

Se a página passa em todas — registrar como **ponto forte** no § 07 (Score por pilar). Auditoria não é só achar problema; é diagnóstico equilibrado.
