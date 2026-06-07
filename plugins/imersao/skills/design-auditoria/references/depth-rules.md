# Regras de profundidade obrigatórias — `design-auditoria`

> Esta skill **não pode** entregar auditoria superficial. As regras abaixo existem porque nem toda pessoa que usar a skill terá olho UX refinado pra detectar superficialidade — então a skill detecta antes.
>
> **Regra-mãe:** se uma das regras abaixo for violada, a auditoria está incompleta. Voltar antes de entregar.

> **Histórico de versões:**
> - **v0.2** — R1–R12 derivadas da 1ª rodada (ToStudy /student/* 01-02/05/2026, 56 págs)
> - **v0.3** — R2 e R9 reforçadas + R13–R16 adicionadas, derivadas da 2ª rodada (ToStudy landing pública 11/05/2026) onde falhei em 4 pontos: pulei empathy/journey explícitos no doc, coloquei prints em apêndice, usei jargão UX nos títulos visíveis, redesenhei o hero apagando identidade visual do produto
> - **v0.4** — R17 adicionada, derivada da 3ª rodada (revalidação do menu /student 11/05/2026 tarde) onde revalidei em cima do `.md` preliminar em vez do PDF final. O `.md` continha "proposta inicial superficial" que o próprio PDF marcava como **superseded** na §14 — refiz a revalidação inteira (markdown + protótipo HTML) com a proposta errada, apresentei pra usuária, e só descobri o erro quando ela mandou o caminho do PDF

---

## R1. Pesquisa antes de proposta — sempre

Auditoria UX **proíbe**:
- Persona inventada do nada (nome + idade sem base)
- Jornada hipotética sem ancoragem
- Mapa de empatia com frases projetadas pelo auditor
- "Achei que o usuário sente X" — sem fonte

**Hierarquia de fontes (do melhor pro pior, escolher o melhor disponível):**
1. Entrevistas internas com 5+ usuários reais
2. Métricas de uso (analytics, retenção, tickets de suporte)
3. Session recordings (Hotjar, Clarity)
4. **Feedbacks reais coletados em concorrentes** (Reclame Aqui, app stores, Reddit, fóruns oficiais, YouTube comments)
5. Literatura acadêmica/setor (NN/g, Baymard, NN/g Returners study, etc)

**Se chegar até a fonte 4 e ainda não tiver dado:** parar a auditoria e pedir ao solicitante. Não inventar.

**Implementação na skill:** sempre que for criar persona/jornada/empathy, validar internamente "tenho fonte real?" — se não, partir pra pesquisa de concorrentes ANTES de escrever uma frase de persona.

---

## R2. Ordem dos frameworks (pirâmide de evidência)

Frameworks UX **só funcionam na ordem certa**. Inverter gera ficção que se reforça mutuamente.

**Ordem obrigatória:**

```
1. Funnel / Drop-off       ← ONDE doer (quanti, sem viés)
2. Persona                 ← QUEM está nesses pontos
3. Empathy Map             ← O QUE se passa por dentro
4. Journey Map             ← O ARCO completo
5. Problem Statement       ← SÍNTESE acionável
6. Hipóteses Lean UX       ← INTERVENÇÃO testável
```

**Anti-pattern detectável:** problem statement antes de funnel = opinião disfarçada de diagnóstico. Persona antes de pesquisa de concorrentes (quando não há dados internos) = ficção.

**Empathy + Journey são entregáveis VISÍVEIS no doc (v0.3 — reforço pós-2ª rodada):**

Pular empathy/journey em nome de "ir direto pro funnel" é a falha mais comum desta skill — aparenta velocidade, custa contexto humano. Na 2ª rodada (tostudy landing 11/05/2026) caí nessa: entreguei §05 "Funil de Abandono" sem §03 "Empathy" nem "Journey" explícitos, e o solicitante cobrou.

**Não basta cumprir mentalmente — tem que aparecer no doc:**

- **Empathy map por persona** em §02 ou §03 · formato canônico: <strong>pensa · vê · ouve · sente · barreira</strong> · 4–6 itens por dimensão · cada item derivado de fonte real (R1) e não inventado
- **Journey map** em §03 · mínimo 5–6 estágios sequenciais · cada estágio com: nome do estágio, tempo aproximado, estado emocional (fala em primeira pessoa do usuário), nota explicativa do que a página entrega ou falha em entregar nesse momento
- **Pontos de saída marcados explicitamente** no journey — não basta listar estágios, é preciso apontar onde a pessoa sai/hesita/desconfia
- **§05 (funnel)** vem DEPOIS, referenciando os estágios da journey — não substitui

**Se a skill detectar que a ordem foi violada:** voltar e refazer ou marcar explicitamente como rascunho.

**Anti-pattern v0.3:** "Ordem das seções da página" listada como se fosse "journey". Ordem das seções é navegação. Journey é o que acontece dentro da pessoa enquanto ela atravessa essa navegação — são coisas diferentes. As duas vão no doc, em seções distintas.

---

## R3. Reorganização de IA — 3 lentes obrigatórias

Nunca propor reorganização de menu/estrutura aplicando só "agrupar similares". Antes da proposta, **passar pelas 3 lentes**:

### Lente 1 — Frequência de uso (Pareto)
- Quais itens compõem 80% do uso esperado? Esses são primary nav.
- Quais são uso ocasional (semanal/mensal)? Vão pra utility nav (avatar dropdown, footer).
- Quais são uso raro (uma vez na vida)? Saem do menu.

**Pergunta de teste:** "o que dos N itens propostos o usuário acessa toda semana?" Se a resposta honesta for menos da metade, a proposta ainda é ruim.

### Lente 2 — Padrão de mercado consolidado
- Pesquisar **5+ concorrentes consagrados** do mesmo segmento.
- Identificar onde mora cada tipo de função (perfil, billing, configurações, ajuda, retomada).
- Convenção é affordance: quebrar sem motivo forte é desperdício.

**Duas categorias de produto, duas convenções válidas pra utility nav:**

| Tipo de produto | Onde mora utility nav (perfil, billing, configs, ajuda) | Exemplos |
|---|---|---|
| **Apps de consumo / SaaS tradicional** | Avatar dropdown no header (top-right) | Netflix, Spotify, Coursera, Notion, Slack, Stripe Dashboard |
| **Apps IA chat / produtividade IA** | User card no rodapé da sidebar (com dropdown ascendente) | Claude, ChatGPT, Perplexity, Cursor |

**Como decidir:** o produto auditado se encaixa em qual categoria? Se a proposta de valor é "interface de IA pra X", herdar padrão IA chat (user card no rodapé). Se é app de consumo/conteúdo, herdar avatar dropdown no header. **NÃO inventar terceira convenção** sem motivo claro.

**Convenções universais (independem da categoria):**
- **Utility nav NUNCA mora como item de sidebar primária** (qualquer das 2 categorias respeita isso)
- **Help → utility nav** (rodapé sidebar ou avatar dropdown), raramente item primário
- **CTA principal de retomada → hero da home**, NÃO item de menu
- **Workspace/contexto switcher → topo da sidebar OU dropdown próprio**
- **Saldo de billing/credit → no mesmo lugar da utility nav** (user card sidebar OU avatar header), nunca como item de menu

### Lente 3 — Anti-patterns documentados
- Itens com nomes ambíguos (sing/plural, sinônimos competindo)
- Configurações fragmentadas em múltiplos prefixos de URL
- Mistura de uso diário com uso raro no mesmo nível visual
- Mais de 1 lugar pra mesma função
- Item declarado mas órfão (sem link)
- Link declarado mas item inexistente (404)

**Implementação na skill:** rodar checklist explícito antes de propor reorganização. Se uma das lentes não foi aplicada, recusar a entrega.

---

## R4. CTA principal vem ANTES do menu

Antes de organizar qualquer menu, identificar:

**"O que >70% dos usuários fazem ao entrar?"**

Se há resposta clara (quase sempre há), essa ação é **CTA proeminente** — não item de menu enterrado entre N outros.

**Padrões de mercado:**
- Netflix: "Continue Watching" — primeira row
- Coursera: "Continue Learning" — hero do dashboard
- YouTube: "Resume" cards no topo do feed
- Audible: "Continue listening" — card grande primeira dobra

**Pra plataforma educacional:**
- "Continue de onde parou" + nome do módulo + progress bar = HERO
- Não é "Learning Path" no sidebar

**Anti-pattern automaticamente detectável:** se a auditoria propõe "X" como item de menu mas é a ação que o usuário sempre faz, está errado. X deveria ser CTA.

---

## R5. Primary nav ≠ Utility nav

**Primary navigation** (sidebar/header principal):
- Conteúdo/atividade principal do produto
- Ações que o usuário faz por sessão
- Funções do "trabalho/estudo/uso" propriamente dito

**Utility navigation** (mora num de 2 lugares dependendo da categoria do produto — ver R3 lente 2):
- Account, Profile, Settings, Preferences
- Billing, Subscription, Purchases, Credits
- Help, Support, FAQ
- Logout, Switch context
- Notifications (geralmente ícone separado)

**Onde colocar utility nav:**

| Categoria do produto | Destino da utility nav |
|---|---|
| Apps consumo / SaaS tradicional (Netflix, Spotify, Coursera, Notion, Slack, Stripe) | Avatar dropdown no header (top-right) |
| Apps IA chat / produtividade IA (Claude, ChatGPT, Perplexity, Cursor) | User card no rodapé da sidebar (com dropdown ascendente) |

**Regra dura (qualquer categoria):** **utility nav NÃO entra como item de primary nav.** Em produto educacional autodidata com IA: estudar é primary, mudar idioma é utility — e utility vai pra um dos 2 destinos acima conforme a categoria do produto.

**Por quê:** mistura confunde mental model + viola convenção (10/10 produtos top de cada categoria separam) + infla menu desnecessariamente.

---

## R6. Toda afirmação técnica precisa de fonte citável

Auditoria não é opinião pessoal. Toda regra UX que a skill aplicar deve vir com fonte:

- Heurísticas → Nielsen Norman Group (1994 + revisões)
- Leis de UX → lawsofux.com (Yablonski) ou fontes primárias
- E-commerce / forms → Baymard Institute
- IA / sidebar / menu → NN/g + Baymard
- Tipografia / hierarquia → Cooper, Krug, IxDF
- Frameworks de pesquisa → IDEO, Stanford d.school, Lean UX (Gothelf)

**Se uma afirmação não tem fonte:** marcar como "opinião do auditor" explicitamente, ou removê-la.

**Exceção legítima:** observação direta da plataforma auditada (com print) é fonte por si — não precisa de literatura externa pra dizer "esse link está quebrado".

---

## R7. Risco real, não cosmético

Toda auditoria UX deve descrever **consequências reais**, não cosméticas.

**Anti-patterns de risco superficial:**
- "Usuário perde tempo" → o risco real é **abandono**
- "Fica feio" → o risco real é **percepção de amadorismo + perda de confiança**
- "Pequena fricção" → o risco real é **substituição por alternativa gratuita**

**Pra cada problema P0/P1, perguntar:**
1. O que acontece se isso continuar? (curto prazo)
2. O que acontece em 3-6 meses cumulativamente? (médio prazo)
3. Qual a alternativa óbvia que o usuário tem? (a barra real de competição)
4. O usuário consegue verbalizar o problema, ou só "se afasta"? (silent churn?)

**Pra plataforma educacional especificamente:** a barra é "menos atrito que abrir YouTube enquanto faz café", não "melhor que concorrente pago".

---

## R8. Cada P0/P1 com 4 blocos obrigatórios

Não basta listar "problema X". A skill exige pra cada problema:

1. **O que vemos hoje** — descrição factual + idealmente print
2. **Por que isso é problema** — 3-5 pontos com consequências concretas
3. **Por que a proposta resolve** — justificativa de cada escolha
4. **Ação proposta** — checklist numerado e específico

**Sem isso, o leitor não consegue confiar na decisão.** "Consolidar X" sem justificativa é decisão a cega.

---

## R9. Prints ancorando cada crítica visual — INLINE na seção do finding (v0.3)

Toda afirmação sobre interface deve ter **print da interface** ao lado:
- "Settings fragmentados" → print do hub mostrando os 8 cards heterogêneos
- "Learning Path/Paths confunde" → print da sidebar com os dois itens lado a lado
- "Privacy 404" → print da tela de erro

**Reforço v0.3 — prints ficam INLINE na seção do finding, não em apêndice:**

Na 1ª rodada da skill (v0.2) interpretei R9 como "ter o print em algum lugar do doc" e coloquei tudo em apêndice. Errado. Auditoria longa (20-30 págs) perde o leitor se a evidência exige clique mental ("§04 finding 5 → apêndice A → volta pro §04"). O leitor não volta.

**Regra concreta:**
- Cada finding P0/P1 com crítica visual tem **crop específico** (não full-page) **embutido na própria seção**, na altura do olho, ao lado ou logo abaixo do parágrafo que faz a crítica
- Layout recomendado: 2 colunas no finding · argumento à esquerda · print à direita (~75mm largura A4)
- Para findings que comparam duas regiões (ex: "5.0 no hero vs 0.0 nos cards"), **os dois crops** dentro do mesmo finding
- Captura: usar `browser_take_screenshot` com target ou ref via Playwright; OU scroll + screenshot da viewport. Full-page screenshot serve apenas como referência de contexto no apêndice — não como evidência de finding específico

**Apêndice de capturas reserva-se a:**
- Full-page desktop + mobile (referência completa pra quem quiser checar contexto fora dos crops)
- Snapshots a11y (markdown)
- JSON brutos (axe, network, tipografia)

**Se não há acesso pra capturar:** declarar explicitamente "print pendente — solicitante deve fornecer" e listar exatamente quais. Não escrever crítica visual sem evidência.

**Anti-pattern v0.3:** finding com referência cruzada tipo "ver §03" ou "ver apêndice A linha N". Funciona pro autor; falha pro leitor. Quem escreveu sabe onde está; quem lê não vai procurar.

---

## R10. Self-check de profundidade antes de entregar

Antes de marcar auditoria como entregue, validar:

- [ ] Pesquisei concorrentes (mín. 3) ou tenho dados internos?
- [ ] Apliquei a ordem certa de frameworks (funnel → persona → empathy → journey → problem → hipóteses)?
- [ ] Toda afirmação técnica tem fonte citável (NN/g, Baymard, etc)?
- [ ] Apliquei as 3 lentes na reorganização de IA (frequência, padrão de mercado, anti-patterns)?
- [ ] Identifiquei o CTA principal e separei de itens de menu?
- [ ] Diferenciei primary nav vs utility nav?
- [ ] Cada P0/P1 tem os 4 blocos (hoje · por que problema · por que proposta · ação)?
- [ ] Cada crítica visual tem print ancorando?
- [ ] Risco descrito é real (abandono, churn, substituição) e não superficial (tempo perdido)?
- [ ] Limitações honestas declaradas (sem dados internos? Marcar)?
- [ ] Hipóteses falsificáveis com métrica (Lean UX)?
- [ ] Persona é derivada de fonte real, não inventada?

**Se 1 dos itens falhou: voltar.** Não entregar parcial.

---

## R11. Quando o solicitante for não-UX

Auditorias podem ser lidas por: dono de produto, dev, marketing, CEO. Nem todos têm vocabulário UX.

**Adaptações obrigatórias:**
- Glossário no início do doc com termos técnicos (P0/P1, Hick's Law, mental model, 404, redirect 301, etc)
- Glossário de termos da plataforma específica auditada
- Sempre traduzir labels do produto pra pt-BR quando o produto está em inglês (com termo original entre colchetes)
- Anti-patterns explicados em consequência humana, não jargão

**Anti-pattern:** assumir que leitor "sabe o que é UX" — escrever sempre como se fosse pessoa esperta mas sem o vocabulário do campo.

---

## R12. Auditoria muda funcionamento — é decisão estratégica

Reorganizar IA de uma plataforma é mudança estrutural com impacto em:
- Conversão (quem entra)
- Retenção (quem fica)
- LTV (quanto paga)
- Carga de suporte (quanto custa)
- Planejamento do time (o que constrói depois)

**Não pode ser superficial.** Toda recomendação deve:
- Ser justificada com fonte ou dado
- Ter custo estimado (esforço × risco)
- Ter métrica de validação (como saberemos que funcionou?)
- Ter rollback plan se piorar

**Implementação:** seção "Plano de correção em sprints" com colunas obrigatórias de **Impacto · Esforço · Risco · Métrica de validação**.

---

## R13. Renderizar o "depois" visual — sempre (v0.3)

Recomendação UX sem mockup é metade da entrega. Para cada P0/P1 com componente visual proposto, o doc apresenta o "depois" renderizado — não descrito.

**Anti-pattern detectado na 2ª rodada:** §09 "Protótipo de Validação" entregue como prosa ("o protótipo deveria reproduzir a primeira dobra mobile com as correções 1.1, 1.3, 1.4, 1.5 aplicadas..."). Texto descrevendo o protótipo NÃO é o protótipo. O leitor sai do doc com inventário de problemas, sem visualizar o caminho.

**Forma canônica:**
- **Mockup HTML/CSS inline no PDF** (preferido pra entrega externa formal) · renderizado dentro do próprio doc A4 com a paleta e tipografia reais do produto · screenshot atual à esquerda, proposto à direita
- **OU diff cirúrgico:** hero original (screenshot) com marcadores numerados sobrepostos nas regiões a alterar + tabela "muda / preserva" por marcador (forma preferida quando R14 manda preservar DS — ver R14)
- **OU arquivo .html standalone navegável separado** (preferido quando o objetivo é teste com 5 usuários · vai em `<projeto>/<area>-protoypes/` referenciado no doc)

**Pra cada P0/P1 com componente visual proposto:** ao menos uma figura. Refactor de página inteira? mostrar pelo menos o hero proposto + 1-2 seções críticas — não precisa ser página inteira.

**Tokens reais do projeto:** antes de renderizar, buscar `UX/design-system/`, `packages/theme`, brand guide, OU capturar via DevTools `getComputedStyle` da landing real. Não inventar paleta.

**Implementação na skill:** se §09 contiver mais texto que figuras, o self-check falha.

---

## R14. Mockup preserva design system existente — cirurgia, não redesign (v0.3)

Auditoria entrega diagnóstico + recomendação **cirúrgica**. Não entrega redesign autoral. Quem decide o redesign é o time, não a auditoria.

**Anti-pattern detectado na 2ª rodada:** propus "hero alternativo" do ToStudy que apagou o que torna o produto distintivo: reduzi H1 Source Serif 4 de ~60px pra 18pt, removi o card de depoimento à direita (layout 2 colunas → 1 coluna), troquei a paleta cream warm específica por cream genérico, refiz o badge estilizado como pill comum. Feedback da Alana: "perdeu todo o visual do ToStudy, ao ser grosseiro e alterar tipografia e itens da página, removeu o visual e deixou sem dinâmica". Confundi "recomendação de copy" com "redesign".

**Regra dura:** o mockup proposto **preserva**, por default:
- Tipografia (família, escala, peso)
- Paleta (background, foreground, accent, tokens semânticos)
- Layout estrutural (número de colunas, posição de elementos não-citados)
- Bordas, raios, sombras
- Espaçamentos e ritmo vertical
- Componentes da identidade (badges, cards, botões com tratamento próprio)

**O mockup só altera os elementos especificamente apontados pela auditoria** — cada um com justificativa em 1 frase + linha "Preserva: [tipografia, escala, posição, ...]" explicitando o que NÃO mudou.

**Tabela "O que NÃO muda"** é obrigatória no §09 — lista explícita do que permanece intocado, idealmente em coluna dupla, com check verde. Sinal pro time auditado de que a recomendação respeita o trabalho que eles já fizeram.

**Frase canônica pra fechar §09:** *"Esta auditoria não recomenda redesign. Recomenda cirurgia de copy e arquitetura de informação sobre um produto cuja identidade visual já é diferenciada e merece ser preservada."*

**Exceção legítima:** quando o solicitante explicitamente pede repensar visual (input `manter design system = liberdade`). Mesmo nesse caso, declarar no início do §09 que a liberdade foi autorizada — não assumir.

---

## R15. Pergunta-zero antes de propor mockup (v0.3)

Antes de renderizar qualquer "depois" visual, perguntar ao solicitante:

> "Quer manter o design system atual (tipografia, escala, paleta, bordas, layout) e eu só altero os elementos que a auditoria apontou? Ou tem liberdade pra repensar visual?"

**Default sem resposta clara:** `manter` (mínimo intervencionista — ver R14).

**Três respostas possíveis e o que cada uma habilita:**

| Resposta | Habilita | Output do §09 |
|---|---|---|
| `manter` (default) | Diff cirúrgico sobre o original | Hero original com marcadores numerados + tabela muda/preserva |
| `liberdade` | Redesign autoral autorizado | Mockup HTML completo com decisões visuais novas — mas ainda preservando tokens de marca quando possível |
| `diff-visual` | Como `manter` mas só com marcadores | Screenshot do original + overlays numerados, sem renderizar HTML |

**Por que essa pergunta existe:** cliente abre o PDF, não reconhece o próprio produto, sai com sensação "vocês não me ouviram". Esse foi exatamente o caso da 2ª rodada — eu assumi liberdade que não tinha.

**Implementação na skill:** a pergunta-zero entra na fase de inputs (antes da Camada 1), junto com URL/persona/setor. Se já entrou em execução sem perguntar, voltar e perguntar antes de §09.

---

## R16. Títulos editoriais humanos no doc final — não jargão UX (v0.3)

Os títulos das seções da skill (`§03 Diagnóstico Estrutural`, `§04 Heurísticas Violadas`, `§05 Funil de Abandono`, `§07 Score por Pilar`, `§08 Plano de Correção em Sprints`) são **nomes de função estrutural** — vocabulário da skill para auditor entender o método. **Não viram título visível no doc entregue** — jargão UX/método afasta leitor não-UX.

**Anti-pattern detectado na 2ª rodada:** entreguei doc com títulos "§03 Diagnóstico Estrutural", "§04 Heurísticas Violadas", "§05 Funil de Abandono". Cliente abriu o sumário e não soube se cada seção valia o tempo. Perdi leitor antes do conteúdo.

**Tom alvo:** como contar pra cliente num café, sem palavra técnica.

**Tabela de tradução canônica (calibrável pelo tom do solicitante):**

| Nome estrutural (interno) | Título humano (visível no doc) |
|---|---|
| Sumário executivo | "O que tá funcionando — e o que tá te custando venda" |
| Contexto · persona · setor | "Quem chega aqui (e o que ela espera)" |
| Diagnóstico estrutural · journey · empathy | "A jornada que ela faz" · "O que ela vê em 5 segundos" |
| Heurísticas violadas | "Os N pontos onde a landing trava" |
| Funil de abandono | "Onde você perde gente" |
| Acessibilidade WCAG AA | "Acessibilidade: você tá quase lá" |
| Score por pilar | "Nota: X em 10 — e o que isso significa" |
| Plano de correção em sprints | "Plano: N semanas, do barato pro essencial" |
| Protótipo de validação | "Como a primeira tela poderia ficar" · "As N alterações cirúrgicas" |
| Sistema de criação sugerido | "Para a próxima página que vocês criarem" |

**O que permanece técnico (intencionalmente):**
- Códigos de finding (H-01, F-02, A-03) — referência rápida pro time
- Apêndice (refs citadas, glossário, ferramentas) — parte que documenta o método
- Self-check items — pra quem audita a auditoria

**Relação com R11:** R11 cobre glossário e adaptação de jargão dentro do CONTEÚDO. R16 cobre escolha de títulos da estrutura do DOC. São complementares — R11 explica os termos que aparecem no texto, R16 garante que o sumário não afasta o leitor antes do texto começar.

**Anti-pattern v0.3:** sumário com "§04 Heurísticas Violadas (Nielsen + Laws + Baymard)". Soa como TCC. Cliente fecha o PDF.

---

## R17. Ler doc canônico final antes de revalidar — nunca preliminar (v0.4)

Antes de revalidar uma auditoria anterior, **ler o documento canônico final** (PDF, HTML formal, ou versão marcada como entregue), não a versão preliminar (`.md`, rascunho, draft).

**Anti-pattern detectado na 3ª rodada:** revalidação do menu /student do ToStudy (11/05/2026 tarde). Li o `.md` (187 linhas) que estava na pasta de auditoria, fiz revalidação inteira (markdown + protótipo HTML), apresentei pra usuária. Ela mandou o caminho do PDF e descobri que o `.md` continha a "proposta inicial superficial" explicitamente **superseded** pelo PDF na §14. O HTML/PDF tinha 4345 linhas com 17 seções (persona Júlia derivada, jornada do usuário, mapa de empatia, score por pilar com Lighthouse, proposta refinada "5 itens flat + user card no rodapé + CTA hero", 10 cleanups com 6 descobertos via Playwright, 5 sprints planejados). Meu trabalho saiu do zero baseado em proposta obsoleta.

**Regra concreta:**

- Antes de começar revalidação, **inventariar todos os artefatos** da auditoria original na pasta: `.md`, `.html`, `.pdf`, `-standalone.html`, etc.
- **Hierarquia de fontes** (do canônico pro preliminar):
  1. **PDF / HTML formal entregue ao stakeholder** — peso editorial maior, geralmente final
  2. **`.md` na pasta** — pode ser draft, preliminar, ou versão simplificada
  3. **Tarefas / GH issues derivados** — refletem decisões pós-auditoria, não a auditoria em si
- **Ler o doc canônico inteiro** antes de tocar qualquer revalidação — incluindo seções de "comparação com versão anterior" / "por que X e não Y"
- **Detecção de "proposta superseded":** se o doc canônico tem seção tipo "Comparação com proposta anterior desta auditoria" ou linguagem "uma versão intermediária propunha X, foi superseded porque...", isso é o sinal de que o `.md` está obsoleto

**Self-check antes de começar revalidação:**

- [ ] Li o doc canônico (PDF/HTML formal) inteiro, do início ao fim?
- [ ] Conferi se existe seção "comparação com versão anterior" que mostre o que foi descartado?
- [ ] Se a auditoria tem persona/jornada/score/empathy, esses já estão derivados no doc final — não inventar do zero
- [ ] Cleanups e P0/P1 são os do doc final, não do rascunho
- [ ] Em caso de dúvida sobre qual é o doc canônico, **perguntar ao solicitante** antes de seguir

**Aplicação cruzada:** essa regra também vale pra revalidar PRD, ADR, design spec, ou qualquer documento que tenha versões. A versão `.md` pode ser fonte de verdade quando esse for o entregável; é fonte preliminar quando existe `.pdf` / `.html` formal ao lado.

**Anti-pattern v0.4:** ler 187 linhas de `.md` e assumir "é o doc". Se a auditoria existe em PDF de 5 MB ao lado, o conteúdo real está lá — `.md` pode ser índice, draft ou versão preliminar.

---

## R18. Nome do arquivo entregável reflete escopo da auditoria — nunca genérico (v0.5)

O artefato HTML/PDF/markdown final **deve ter nome que comunica o escopo da auditoria** (curso, fluxo, módulo, página auditada). Nomear como `auditoria.html` / `auditoria.pdf` cria colisão semântica quando o usuário tem múltiplas auditorias na pasta.

**Anti-pattern detectado na 5ª rodada:** após entregar 2 auditorias seguidas (menu creator 21/mai + jornada student 22/mai), a Alana percebeu que ambos arquivos saíram com nome `auditoria.html` / `auditoria.pdf`. Quick-switcher do Obsidian e Spotlight não distinguem qual é qual sem abrir a pasta-mãe. Compromete navegabilidade dos artefatos no workspace dela ao longo do tempo.

**Regra concreta:**

- **Nome do arquivo = slug do escopo** + extensão (`.html`, `.pdf`)
- **NUNCA usar nomes genéricos**: ❌ `auditoria.html`, ❌ `audit.pdf`, ❌ `report.md`, ❌ `documento.html`
- **Slug do escopo** segue o padrão da pasta-mãe (`docs/audits/<slug>-YYYY-MM-DD/`), mas dentro do arquivo:

| Pasta (modo completo) | Arquivo HTML | Arquivo PDF |
|---|---|---|
| `menu-creator-2026-05-21/` | ❌ ~~`auditoria.html`~~ → ✅ `menu-creator.html` | ✅ `menu-creator.pdf` |
| `jornada-student-iniciar-curso-2026-05-22/` | ✅ `jornada-student-iniciar-curso.html` | ✅ `jornada-student-iniciar-curso.pdf` |
| `landing-publica-2026-05-11/` | ✅ `landing-publica.html` | ✅ `landing-publica.pdf` |

- **Modo `interno` / `foco-*`** (markdown único): nome do arquivo já segue convenção (`<slug>-YYYY-MM-DD.md`), continua sendo isso.
- **Date fica na pasta-mãe, não no arquivo** — evita redundância e mantém slug curto pra Spotlight/quick-switcher.
- **Se a pasta tem `assets/`, `findings.md`, `gen-pdf.mjs` e outros aux files**, esses mantêm nomes genéricos — a regra é só para o entregável final HTML/PDF.

**Self-check antes de escrever o arquivo HTML/PDF:**

- [ ] O nome do arquivo é o slug do escopo da auditoria, não "auditoria"?
- [ ] Se eu copiar/baixar 5 PDFs de auditorias diferentes pra Downloads/, consigo distinguir pelo nome sem abrir cada um?
- [ ] Quick-switcher/Spotlight encontra o arquivo digitando "<scopo>"?

**Aplicação cruzada:** essa regra também vale para artefatos secundários (mockup standalone, capturas de referência exportadas). Ex: `mockup-sidebar-creator.html`, não `mockup.html`.

**Anti-pattern v0.5:** 3 PDFs com nome `auditoria.pdf` em pastas diferentes. Usuário fala "abre a auditoria" e precisa abrir pasta-mãe pra saber qual.

---

## R19. Imagens devem renderizar em todos os contextos (HTML preview, PDF, email, share) (v0.5)

Toda imagem inserida no doc **deve ser visível em qualquer contexto onde o doc pode ser aberto** — não só no PDF gerado pelo Playwright/Chromium, mas também no HTML preview do Claude Code, em email forwarding, em outras versões de PDF viewer, ao baixar e abrir off-line.

**Anti-pattern detectado na 5ª rodada:** a Alana abriu o `auditoria.html` no preview panel do Claude Code e relatou "as imagens não estão sendo exibidas". Investigação revelou que o HTML estava referenciando `assets/*.png` em path relativo — preview panel do Claude Code é sandbox que não consegue resolver paths relativos do filesystem (mesma falha em iframes, contextos sandboxed, email clients). PDF estava OK porque Playwright resolveu `file://` durante geração e embedou os PNGs no fluxo do Skia/PDF. Mas o HTML "vazou" o problema. Fix: inline base64 dos PNGs no `<img src="data:image/png;base64,...">`.

**Adicional do mesmo episódio:** mesmo com inline base64, layout `max-height: 220mm; object-fit: contain` + `section { break-inside: avoid-page }` em sections com imagens cria páginas PDF com **≥30-50% whitespace abaixo da imagem** — usuário interpreta como "imagem sumida / página vazia". Combinado com prints landscape-extremo (proporção 2:1 → fica fininha na A4) gera sensação de imagem invisível mesmo estando lá.

**Regra concreta:**

### 19.A — Embedding obrigatório das imagens

**Modo completo / entrega externa (HTML + PDF):**
- Imagens **inline base64** no `<img src="data:image/png;base64,...">` — garante portabilidade total
- Pasta `assets/` paralela continua existindo (pra Playwright fonte original + futuras edições), mas o HTML/PDF entregue **não depende dela**
- **Tamanho-alvo do HTML final: ≤1.5 MB** (preview panel-friendly em sandbox Claude/iframe). Acima disso, preview pode falhar ou demorar a renderizar (validado 25/05/2026 — HTML 2.5 MB falhava no preview).
- **Otimização de PNGs OBRIGATÓRIA antes do base64** (não opcional como antes):
  - `oxipng -o 4 --strip safe assets/*.png` (lossless, ~20% redução)
  - `pngquant --quality=70-90 --skip-if-larger --force --ext .png --strip assets/*.png` (lossy controlada, +40-60% redução adicional)
  - Validado empiricamente: HTML 2.5 MB → 1.0 MB (-60%) sem perda visual perceptível em PDF print A4
- **Self-check anti-duplicação**: `md5 assets/*.png | sort -k4 | uniq -d -f3` — se retornar algo, há PNGs com mesmo MD5 (duplicados, nomes diferentes). Causa inflação desnecessária do HTML. Re-capturar ou consolidar — descoberto na 5ª rodada (3-chatstudy-first-load.png == 4-chatstudy-personalize-modal.png).

**Modo `interno` (markdown único):**
- Caminho relativo `assets/<file>.png` é OK (vive na mesma pasta), MAS:
- Adicionar nota no topo do md: `> **Imagens vivem em** \`./assets/\` — copie a pasta junto se forwarding.`

### 19.B — Layout que evita "imagem sumida visual"

- Imagens com aspect ratio **landscape extremo (>2.5:1)**: usar `max-width: 100%; max-height: auto` e renderizar 100% do width disponível (174mm em A4). Não setar max-height fixo.
- Imagens com aspect ratio **portrait extremo (>1:1.8)**: setar `max-height: 200mm; width: auto; object-fit: contain; margin: 0 auto;` (centralizado, não estica).
- Imagens com aspect ratio **balanceado (entre 4:3 e 16:9)**: `width: 100%; height: auto;` deixa o browser/PDF decidir.
- **Evitar `section { break-inside: avoid-page }` em sections com imagens + texto longo** — preferir `figure { break-inside: avoid }` ao redor da imagem específica, deixando o resto da section flexível pra quebrar.
- **Caption logo abaixo da imagem (não em margem)** garante que crop não corta contexto.

### 19.C — Self-check obrigatório antes de marcar entregue

Comandos a rodar antes de afirmar que o doc está OK:

```bash
# 1. Confirmar que TODAS as imagens inseridas no HTML têm formato base64 (não asset path)
grep -c 'src="assets/' auditoria.html  # → deve ser 0
grep -c 'src="data:image' auditoria.html  # → deve ser N (igual ao número de <img>)

# 2. Confirmar que TODAS as imagens estão visíveis no PDF
pdfimages -list <slug>.pdf | tail -n +3 | wc -l  # → deve ≥ número de <img class="full"> no HTML

# 3. Render visual de pelo menos 3 páginas com imagens
pdftoppm -f 6 -l 8 -r 80 -png <slug>.pdf /tmp/audit-check
ls /tmp/audit-check-*.png  # → ler manualmente pra confirmar:
                            # — imagem aparece (não placeholder)
                            # — não há whitespace > 40% da página vazio abaixo
                            # — imagem não está com aspect ratio distorcido
```

### 19.D — Detecção do "false null" do usuário

Se o usuário relatar "imagens não estão sendo exibidas":
1. **NÃO assumir que falta tecnicamente** — primeiro fazer `pdfimages -list` e confirmar count
2. **Renderizar 1-2 páginas** pra ver se há problema visual (whitespace, distorção, crop estranho)
3. **Confirmar o contexto onde a Alana viu** — HTML preview do Claude? Adobe Reader? macOS Preview? Email forwarding?
4. Se imagens TÊM tecnicamente mas layout cria sensação de ausência → fix layout (19.B), não o embedding

**Self-check antes de gerar PDF:**

- [ ] Todas `<img>` usam base64 (`grep src="assets/" auditoria.html` retorna 0)?
- [ ] Aspect ratios extremos têm CSS específico (não usam max-height fixo genérico)?
- [ ] Sections com imagem têm `figure { break-inside: avoid }` (não `section { break-inside: avoid-page }` global)?
- [ ] Após gerar PDF, rodei `pdfimages -list` e count bate com inserções?
- [ ] Após gerar PDF, abri visualmente pelo menos 3 páginas com imagens?
- [ ] **Tamanho do HTML final ≤ 1.5 MB** (preview panel Claude / sandbox iframes têm limite — testado 25/05/2026, HTML 2.5 MB falhava silenciosamente em renderizar)
- [ ] PNGs rodaram `oxipng -o 4 --strip safe` + `pngquant --quality=70-90` antes do base64 inline?
- [ ] `md5 assets/*.png | sort -k4 | uniq -d -f3` retorna vazio? (sem PNGs duplicados inflando HTML)

**Aplicação cruzada:** mesma lógica vale pra mockups standalone HTML, exports de capturas referenciadas em ADRs, e qualquer entregável visual que sai da pasta de auditoria.

**Anti-pattern v0.5 — 3 sintomas do mesmo bug:**
1. HTML referenciando `src="assets/..."` em contexto sandbox → preview panel não renderiza
2. Imagem com max-height fixo + aspect landscape → comprime e sobra whitespace
3. Section inteira com `break-inside: avoid-page` + imagem grande → quebra forçada com página meia-vazia

Os três combinados deram a sensação de "PDF não tem as imagens". Tinha sim — mas o usuário viu o HTML primeiro e generalizou.

---

## Resumo executivo das 19 regras

| # | Regra | Detecta | Vers |
|---|---|---|---|
| R1 | Pesquisa antes de proposta | Persona/jornada inventadas | v0.2 |
| R2 | Ordem dos frameworks · empathy + journey **explícitos no doc** | Frameworks fora de ordem · empathy/journey pulados | v0.2 → reforço v0.3 |
| R3 | 3 lentes na reorganização IA | Reorg superficial ("agrupar similares") | v0.2 |
| R4 | CTA antes do menu | CTA principal virou item de menu | v0.2 |
| R5 | Primary ≠ Utility nav | Conta/billing no menu lateral | v0.2 |
| R6 | Fonte citável | Opinião disfarçada de fato | v0.2 |
| R7 | Risco real | "Perda de tempo" em vez de "abandono" | v0.2 |
| R8 | 4 blocos por P0/P1 | Decisão a cegas | v0.2 |
| R9 | Prints ancorando **inline na seção** — não em apêndice | Crítica visual sem evidência · prints em apêndice | v0.2 → reforço v0.3 |
| R10 | Self-check de profundidade | Auditoria incompleta entregue | v0.2 |
| R11 | Adaptação não-UX (glossário) | Jargão sem explicação | v0.2 |
| R12 | Decisão estratégica · Impacto · Esforço · Risco · Métrica | Recomendação sem custo/métrica/rollback | v0.2 |
| **R13** | **Renderizar o "depois" visual** — mockup ou diff, não prosa | "Protótipo" entregue como texto descritivo | **v0.3** |
| **R14** | **Mockup preserva DS existente** — cirurgia, não redesign | Identidade visual do produto apagada pelo auditor | **v0.3** |
| **R15** | **Pergunta-zero antes do mockup** ("manter DS?") | Auditor assume liberdade que não tem | **v0.3** |
| **R16** | **Títulos editoriais humanos** no doc visível — não jargão | Sumário com vocabulário da skill afasta leitor | **v0.3** |
| **R17** | **Ler doc canônico final** (PDF/HTML) antes de revalidar — nunca preliminar (`.md` / draft) | Revalidação em cima de proposta obsoleta · conclusões erradas apresentadas como verdade | **v0.4** |
| **R18** | **Nome do arquivo entregável = slug do escopo** — nunca genérico ("auditoria.html") | Múltiplos PDFs com nome igual em pastas diferentes · usuário não distingue sem abrir cada um | **v0.5** |
| **R19** | **Imagens renderizam em todos contextos** (HTML preview, PDF, email) + layout sem whitespace excessivo · self-check via `pdfimages -list` + render visual | Imagens com `src="assets/"` em sandbox (preview falha) · max-height fixo gerando page com 50% whitespace · usuário relata "imagens não exibidas" | **v0.5** |
