---
name: design-usabilidade
description: >-
  Use when analyzing user journeys, auditing UX quality, prototyping flows, or
  designing new pages/features from a product perspective. Triggers on: jornada
  do usuario, fluxo de agendamento, prototipo, prototipar, experiencia do
  usuario, UX audit, usabilidade, melhorar conversao, nova pagina, nova feature,
  redesign, agendamento, checkout, onboarding, cadastro, landing page, flow,
  wireframe, mockup, prototipacao. Runs BEFORE implementation — analyzes the
  PRODUCT experience, not the code.
version: 2.1.0
tags: [ux, design, prototype, usability, journey, product]
---

<!-- last-reviewed: 2026-05-17 -->

# Superpower: Design de Usabilidade

Audita jornadas, da nota objetiva, sugere melhorias priorizadas por negocio, e prototipa solucoes com qualidade visual de produto real. Roda ANTES de implementar.

```
usabilidade = PRODUTO (jornada, personalizacao, conversao, retencao)
              "A experiencia e boa?" — analise + pesquisa + prototipo
              Roda ANTES de implementar.

qualidade   = CODIGO (tokens, a11y, contraste, responsividade real)
              "A implementacao esta certa?" — auditoria via Playwright
              Roda DEPOIS de implementar. (skill separada)
```

## Fase -1: Ler Projeto (SEMPRE, antes de tudo)

Antes de qualquer interacao com usuario, ler silenciosamente:

```
1. CLAUDE.md, AGENTS.md, README.md, docs/**
2. package.json, estrutura src/, git log -20
3. .claude/memory/**
4. Specs e auditorias em docs/superpowers/
5. node_modules/<sua-lib-de-ui>/package.json (versoes do design system)
```

Fallback se nao existir:
- Sem docs? Le package.json + estrutura de pastas
- Sem registry? Grep nos composites/components
- Sem specs? Le git log -50 pra entender historico
- A skill NUNCA trava por falta de docs. Trabalha com o que tem.

Mostrar ao usuario O QUE JA SABE antes de perguntar qualquer coisa.

## Fase 0: Contexto Inteligente

Se veio de outra superpower → ja tem contexto, NAO repergunta.
Se e chamada direta → pergunta so o que nao da pra inferir:

1. **O PROBLEMA** — "O que te levou a precisar disso?"
2. **O OBJETIVO** — "O que quer que aconteca quando estiver pronto?"
3. **QUEM USA** — "Quem usa no dia a dia?"
4. **O QUE JA EXISTE** — "Hoje como funciona?"
5. **OBRIGATORIO** — "O que nao pode faltar?"

Uma pergunta por vez. Mostra o que ja sabe antes de perguntar.

## Fase 1: Mapeamento da Jornada

Mapear a jornada completa do usuario:

```
Para cada ponto de contato:
  ● = existe no projeto (composite, pagina, componente)
  ○ = nao existe (gap)
  ⚠️ = existe mas com problemas

Resultado: diagrama da jornada com gaps identificados
```

Identificar personas e mapear variantes:
- Persona 1 (ex: paciente novo) → caminho A
- Persona 2 (ex: paciente recorrente) → caminho B
- Para cada: o que precisa, o que nao precisa, referencia de mercado

## Fase 2: Pesquisa de Referencia

Para cada tela/fluxo, pesquisar em 4 camadas:

```
Camada 1 — Design Systems consolidados
  Material Design 3, Apple HIG, Radix, Shadcn, Ant Design

Camada 2 — Produtos de referencia (como USAM)
  SaaS: Linear, Notion, Vercel, Stripe
  Saude: Doctoralia, Clinicorp, Booksy
  Educacao: Coursera, Hotmart, Google Classroom
  Fintech: Nubank, Stripe Dashboard, Wise
  eCommerce: Shopify, Gumroad, LemonSqueezy

Camada 3 — Padroes de UX (teoria)
  Nielsen Norman Group, Baymard Institute, Laws of UX, WCAG

Camada 4 — O que JA existe no seu design system
  Componentes, primitives, hooks e tokens ja disponiveis
```

## Fase 3: Prototipo HTML

Gerar prototipo standalone navegavel (HTML + Tailwind CDN + Lucide).

**REGRA ABSOLUTA: Aplicar TODAS as regras do Banco de Regras abaixo SEM perguntar.**

O prototipo DEVE:
- Ser navegavel (clicaveis, transicoes entre telas)
- Mobile-first (max-w-md)
- Ter TODAS as telas do fluxo (nao so a principal)
- Ter todos os estados (vazio, preenchido, erro, sucesso)
- Parecer produto final, NAO wireframe

## Fase 4: Score (7 pilares — checklist objetiva)

| Pilar | O que mede | Como verifica |
|---|---|---|
| Jornada | Caminho faz sentido? Atalhos? | Grep por logica de fluxo |
| Personalizacao | Reconhece usuario? Adapta? | Grep por dados do usuario |
| Pos-acao | O que acontece apos CTA? | Verificar tela pos-acao |
| Conversao | Completa o objetivo? Quantos passos? | Contar steps do fluxo |
| Retencao | Motivo pra voltar? | Verificar historico, lembretes |
| Responsividade | Funciona em qualquer tela? | Screenshots em viewports |
| Acessibilidade | WCAG AA, keyboard, screen reader? | Axe audit |

Escala: 1-3 Problema, 4-5 Funcional, 6-7 Bom, 8-9 Excelente, 10 Referencia

Apos score, perguntar prioridade de NEGOCIO:
"Pelo impacto tecnico, recomendo X. Mas pro seu negocio, o que importa mais?"

## Fase 5: Oportunidades

Classificar cada oportunidade:
- **Design (a skill resolve):** tela, layout, experiencia, prototipo
- **Backend (o dev precisa):** API, autenticacao, dados
- **Dependencia:** "Essa oportunidade so funciona SE o backend fornecer X"

## Fase 6: Entrega

Salvar auditoria em: `docs/superpowers/audits/YYYY-MM-DD-[tema].md`

Contem: contexto, score, oportunidades, decisoes do usuario.
Quando outra superpower roda, le esse arquivo.

---

## Banco de Regras de Design (aplica sem perguntar)

### Regras de Produto
- Usuario so ve o que e relevante pra SUA tarefa
- Menos opcoes = menos erro = mais conversao
- Se da pra resolver em 1 passo, nao faz 3
- Se da pra inferir, nao pergunta
- Toda acao tem resposta visual imediata
- 1 acao principal por tela (CTA unico)
- Acoes destrutivas sempre com confirmacao
- Sempre saber onde esta e como voltar
- Formulario nao pede o que da pra inferir
- Default inteligente > campo obrigatorio

### Regras de Writer

**Regra fundamental — toda mensagem visivel ao usuario DEVE conter 3 partes:**
1. **O que aconteceu** — descrever o estado atual de forma que o usuario entenda sem reler
2. **Por que** — quando o sistema sabe a causa, informar em linguagem humana
3. **O que fazer agora** — uma acao especifica de baixo esforco que o usuario pode executar

Se qualquer parte estiver ausente, a mensagem esta incompleta e deve ser reescrita.

**Voz do design system — 4 atributos obrigatorios:**

| Atributo | Significa na pratica | NAO significa |
|----------|---------------------|---------------|
| Clara | Usuario entende na primeira leitura | Simplista ou vaga |
| Direta | Vai ao ponto sem preambulo | Seca ou fria |
| Confiavel | Transmite seguranca, especialmente em falha | Excessivamente otimista |
| Humana | Fala como pessoa, nao como log de sistema | Informal ou com humor |

**Tom por momento — a voz e constante, o tom muda:**

| Momento | Tom | Regra |
|---------|-----|-------|
| Sucesso | Positivo, breve | Confirmar O QUE foi feito, nao "Sucesso!" |
| Informacao | Neutro, orientador | Fato + como usar, sem interromper fluxo |
| Atencao | Calmo, preventivo | Consequencia ANTES da acao + opcoes nomeadas |
| Erro | Calmo, construtivo | O que falhou + acao especifica + alternativa |

**NUNCA** usar humor em erro, pagamento ou seguranca.

**Titulos:**
- Comunica o que o usuario GANHA, nao o que ele FAZ
- ERRADO: "Escolha o servico" / "Confirmar agendamento" / "Meus agendamentos"
- CERTO: "Cuide do seu sorriso hoje" / "Tudo certo? Revise antes de confirmar" / "Suas proximas consultas"

**Subtitulos (OBRIGATORIO em todo titulo):**
- Explica O QUE ACONTECE ao agir, em 1 frase
- ERRADO: (sem subtitulo)
- CERTO: "Selecione o procedimento e siga para escolher data e horario."

**Labels de secao:**
- Explicam POR QUE aquilo esta ali, nao O QUE e
- ERRADO: "Nossa equipe" / "Historico" / "Localizacao"
- CERTO: "Conheca quem vai cuidar de voce" / "Suas consultas anteriores" / "Como chegar na clinica"

**Regras gerais de escrita:**

| Elemento | Regra | Correto | Incorreto |
|----------|-------|---------|-----------|
| Titulos | Maximo 5 palavras | "Users" | "User Management Dashboard" |
| Descricoes | Maximo 1 frase. Dizer o que faz, nao o que e | "List and manage patients" | "This is a patient management module" |
| Botoes/CTAs | Verbo imperativo que descreve o resultado | "Save", "Delete permanently" | "OK", "Confirm", "Submit" |
| Jargao | Nunca sem definir | "composite (template de pagina)" | "composite" |
| Marketing | Zero na interface | "ListPage" | "Our Amazing List Solution" |

**Proibido:**
- Nunca repetir estrutura de frase entre telas
- Zero vicios: "clique aqui", "selecione abaixo", "escolha uma opcao"
- Nunca titulo generico sem contexto do dominio
- Nunca CTA sem explicar o que acontece ao clicar

### Regras de Hierarquia de Informacao

- A ACAO PRINCIPAL sempre vem primeiro (o que trouxe o usuario)
- Informacao de suporte vem depois (prova social, localizacao, historico)
- Nunca um card de contexto (ultimo atendimento) antes da acao de agendamento
- Dados duplicados entre secoes = remover o menor
- Ordem da landing: confianca (rating) → acao (servicos) → credibilidade (equipe) → prova social (depoimentos) → suporte (local)
- Ordem do paciente recorrente: servico escolhido → horarios → historico

### Regras Visuais (Anti-AutoCAD)

**Fotos e imagens:**
- Fotos reais OBRIGATORIAS (Unsplash): equipe, fachada, interior, avatares
- Nunca placeholder cinza "imagem aqui" ou mapa mundi generico
- Foto de fachada/interior real na secao de localizacao
- Avatares de profissionais com fotos reais

**Icones:**
- Zero emojis como icones em prototipos — Lucide SVG sempre
- Cada secao/servico com icone em cor diferenciada (brand, blue, amber, purple, green)
- Icones contextuais por item em listas (id-card, scan, clock — nao check generico)

**Cards e containers:**
- Cards de acao com icone + titulo + subtitulo (NUNCA botao flat)
- Cards de sucesso/confirmacao com gradiente brand (nao icone solto)
- Card de WhatsApp com circulo verde identitario
- Sombras: card (sutil), hover (card-hover), destaque (elevated)

**Interacao:**
- Horarios sem fundo colorido — border hover com shadow, range visivel (ex: "08:00 — 08:30")
- Nunca overlay verde cru — hover e border + shadow
- Separacao de turnos com icone (sunrise/sunset), nao label seca
- Badge de urgencia no contexto (ex: "em 7 dias", "6 vagas")
- Transicoes em TUDO interativo (hover, active, focus)

**Calendario:**
- Dias passados: riscados (line-through), cor mais clara, sem interacao
- Dias disponiveis: peso normal + ponto verde embaixo indicando vagas
- Dias sem vaga: cinza claro, sem ponto, sem cursor
- Hoje: marcado com label "HOJE" embaixo + ring
- Selecionado: preenchido brand-500, bold, shadow
- Legenda com mini-exemplos visuais (nao so bolinha + texto)

**Confirmacao/Revisao:**
- Tela de confirmacao e tela de REVISAO (nao separacao de botoes)
- Header com gradiente brand mostrando o servico
- Labels por categoria (PROFISSIONAL, DATA, LOCAL, VALOR)
- Botao "Alterar" em cada linha — permite editar sem voltar cegamente
- Valor em destaque com badge de pagamento

**Tipografia e layout:**
- Inter font (Google Fonts) — nunca system font sozinha
- Mobile-first (max-w-md)
- -webkit-font-smoothing: antialiased
- Backdrop-blur no nav superior
- Animacao slideUp nas transicoes de tela

**Theming multi-preset:**
- Highlights de estado (ativo/atual/selecionado) usam sempre cores SOLIDAS ou pares invariantes (ex: Chip tone=primary). Opacidade derivada (primary/5, primary/10) varia entre presets — some em temas suaves.
- Mesmo componente 2x na mesma tela forca diferenciacao (container, posicao, tamanho) OU substituir por componente diferente. Usuario decifra em 1 fixacao.
- Mudancas em bg/border/ring/shadow/tokens validam em TODOS os presets x light/dark antes de concluir. "Passa no admin dark" nao e validacao.

### Regras de Acessibilidade Minima
- Contraste WCAG AA minimo
- Touch target proporcional a prioridade: primaria 44px (NN/g, WCAG AAA), secundaria 40px, meta/dev 24-32px (WCAG 2.5.8 AA). Nao infle meta-controle.
- Labels em todos os campos (nunca so placeholder)
- Cards responsivos: 2col mobile, expandem em desktop
- Nunca card cortado, texto transbordando, scroll horizontal
- Feedback: loading com progresso, sucesso confirma o que aconteceu, erro diz o que fazer

### Regras de Tom e Microcopy

**Voz da interface:**
- Tom empatico e direto — como uma recepcionista atenciosa, nao um robo
- Falar sobre o USUARIO, nao sobre o sistema ("Sua consulta esta confirmada" > "Agendamento realizado com sucesso")
- Usar linguagem do dominio do usuario, nao jargao tecnico ("Sua limpeza dental" > "Servico ID #4521")
- Frases curtas. Se precisa de ponto e virgula, quebrar em duas frases

**Microcopy por contexto:**
- Botao de acao: verbo + beneficio ("Confirmar agendamento" > "Submeter" / "OK")
- Campo de formulario: label + placeholder com exemplo real ("Telefone" + "(11) 99999-0000")
- Estado vazio: empatia + acao ("Voce ainda nao tem consultas. Que tal agendar a primeira?")
- Loading: informa o que esta acontecendo ("Verificando horarios disponiveis...")

**Modelo por tipo de mensagem — usar como template:**

ERRO:
```
Estrutura: [o que falhou] + [acao especifica] + [alternativa se persistir]
Correto:  "Nao conseguimos salvar suas alteracoes. Verifique sua conexao e tente salvar novamente. Se continuar acontecendo, atualize a pagina."
Incorreto: "Ocorreu um erro. Tente novamente." / "Erro 500" / "Falha ao salvar"

Regras:
- Dizer O QUE falhou (nao "ocorreu um erro")
- Oferecer ACAO ESPECIFICA (nao "tente novamente" generico)
- Erros graves: 2 caminhos escalonados (tente X → se persistir, faca Y)
- Nunca culpar o usuario ("entrada invalida", "voce errou")
- Tranquilizar se dados em risco ("seus dados estao seguros")
- Formato por severidade: toast=1 frase, banner=+alternativa, modal=so se bloqueia fluxo
```

SUCESSO:
```
Estrutura: [o que foi feito] + [proximo passo se nao obvio]
Correto:  "Paciente cadastrado. Agende a primeira consulta."
Correto:  "Alteracoes salvas." / "Email enviado para maria@email.com"
Incorreto: "Sucesso!" / "Operacao realizada com sucesso!"

Regras:
- Maximo 1 frase, 2 se incluir proximo passo
- Confirmar a acao ESPECIFICA (nao "sucesso")
- Toast auto-dismiss em 3-5 segundos
```

ATENCAO (warning):
```
Estrutura: [o que vai acontecer] + [consequencia] + [opcoes com CTAs nomeados]
Correto:  "Ao excluir, os agendamentos futuros serao cancelados. Os passados continuam no historico."
          CTAs: "Excluir e cancelar agendamentos" / "Manter ativo"
Incorreto: "Tem certeza?" CTAs: "OK" / "Cancelar"

Regras:
- Explicar consequencia ANTES da acao
- CTAs DEVEM nomear a acao ("Excluir permanentemente", nao "Confirmar")
- Para acoes destrutivas: CTA primario = acao destrutiva nomeada
```

INFORMACAO:
```
Estrutura: [fato relevante] + [como usar essa informacao]
Correto:  "Historico disponivel dos ultimos 12 meses. Para dados anteriores, entre em contato com o suporte."
Incorreto: "Informacao" / "Atencao!" (sem consequencia)

Regras:
- Nao interromper fluxo — inline, tooltip ou banner discreto
- Usar quando o usuario pode nao saber algo que afeta sua decisao
```

**Tom por momento da jornada:**
- Chegada: acolhedor, confiante ("Cuide do seu sorriso hoje")
- Decisao: claro, sem pressao ("Quando fica melhor pra voce?")
- Confirmacao: seguro, revisavel ("Tudo certo? Revise antes de confirmar")
- Sucesso: celebratorio mas util ("Consulta confirmada! Veja o que levar")
- Erro: calmo, com saida ("Algo deu errado. Voce pode tentar de novo ou escolher outro horario")

**Checklist obrigatorio pre-producao (toda mensagem visivel):**
1. O que aconteceu esta claro?
2. Causa explicada quando possivel?
3. Acao especifica (nao "tente novamente" generico)?
4. Sem culpa ao usuario?
5. Tom adequado ao momento?
6. CTA descreve o resultado?
7. Severidade visual correta (toast/banner/modal)?
8. Traduzido para todos os idiomas?

**Antipatterns — NUNCA usar:**

| Proibido | Por que e ruim | Usar em vez disso |
|----------|---------------|-------------------|
| "Ocorreu um erro" | Sem contexto | "Nao conseguimos carregar [conteudo especifico]" |
| "Entrada invalida" | Culpa o usuario | "Use o formato exemplo@email.com" |
| "Error 500", "Timeout" | Jargao tecnico | "Estamos com um problema. Tente novamente em instantes." |
| "OK", "Confirmar" como CTA | Nao diz o resultado | "Excluir permanentemente", "Salvar e sair" |
| "Ops!" em falha | Minimiza frustracao | Tom calmo e construtivo |
| "Sucesso!" | Qual operacao? | "Alteracoes salvas." |
| "Atencao!" sem consequencia | Atencao ao que? | "[Consequencia]. [Opcoes]." |
| Toast com 4+ frases | Ninguem le | 1 frase, maximo 2 |

**Referencia:** NNGroup Error Message Guidelines, NNGroup Scoring Rubric

**Proibido (geral):**
- "Clique aqui", "Saiba mais", "Veja mais" — sem contexto do que acontece
- "Cadastre-se ja!", "Nao perca!", "Ultimas vagas!" — urgencia falsa sem dado real
- Texto em CAPS LOCK para enfase (usar peso tipografico em vez disso)
- Humor forcado ou trocadilhos que nao respeitam o contexto (saude != meme)
- NUNCA usar humor em erro, pagamento ou seguranca

### Regras de Motion Design

**Principio: motion com proposito, nunca decorativo.**

**Transicoes obrigatorias:**
- Entrada de tela: `slideUp` 0.3s ease-out (conteudo sobe suavemente)
- Saida de tela: fade-out 0.2s (rapido, nao atrasa o usuario)
- Abertura de modal/sheet: slide-up + overlay fade 0.25s
- Cards interativos: `translateY(-2px)` + shadow no hover (eleva ao tocar)
- Botao de acao: `scale(0.97)` no active (feedback tatil)
- Loading: skeleton com shimmer (nao spinner sozinho — preserva layout)
- Sucesso: icone de check com scale-in 0.3s + bounce sutil

**Timing por contexto:**
- Micro-interacao (hover, focus): 150ms (instantaneo)
- Transicao de estado (tab, toggle): 200ms (perceptivel mas rapido)
- Entrada de conteudo (tela, modal): 300ms (suave, nao lento)
- Animacao decorativa (counter, reveal): 500ms-1s (atrai atencao)

**Easing:**
- Entrada: `cubic-bezier(0.16, 1, 0.3, 1)` (rapido no inicio, suave no fim)
- Saida: `ease-out` (desacelera naturalmente)
- Nunca: `linear` (parece mecanico) ou `ease-in` (parece lento pra comecar)

**Regra de acessibilidade:**
- SEMPRE respeitar `prefers-reduced-motion: reduce` — desativar animacoes decorativas
- Manter transicoes funcionais (fade de loading/error) mesmo com reduced-motion
- Maximo 3 animacoes simultaneas por viewport (excesso = distração)

**Proibido:**
- Animacao que bloqueia interacao (usuario espera ela terminar)
- Parallax em mobile (jank, performance)
- Bounce/wobble em textos (distrai da leitura)
- Spinner sem contexto ("carregando..." sem dizer o que)
- Transicao de tela > 400ms (usuario sente travamento)

### Regras de Performance Percebida

**Principio: a velocidade que o usuario SENTE importa mais que o tempo real.**

**Skeleton-first loading:**
- Nunca tela em branco enquanto carrega — mostrar skeleton do layout imediato
- Skeleton deve ter o FORMATO do conteudo (card skeleton = shape de card, nao retangulos genericos)
- Carregar acima da dobra primeiro, abaixo lazy
- Texto placeholder com largura variada (nao todas as linhas iguais)

**Feedback imediato:**
- Ao clicar em CTA: desabilitar + spinner em < 100ms (antes do request voltar)
- Ao digitar busca: mostrar "buscando..." em < 200ms, resultados em < 500ms
- Ao navegar entre telas: transicao visual imediata, dados podem carregar depois
- Optimistic UI: mostrar resultado esperado antes da confirmacao do servidor

**Imagens:**
- Hero image: < 200KB (WebP/AVIF preferencial)
- Thumbnails: < 50KB
- Avatares: < 20KB (48x48 ou 80x80 max)
- Lazy load em imagens abaixo da dobra
- Placeholder blur ou cor solida enquanto carrega (nunca espaco vazio)

**Prioridade de carregamento:**
1. Shell da pagina (nav, layout, skeleton) — instantaneo
2. Conteudo acima da dobra (hero, CTA principal) — < 1s
3. Conteudo secundario (depoimentos, localizacao) — < 2s
4. Imagens decorativas e analytics — < 5s

**Proibido:**
- Tela branca por mais de 500ms (usuario acha que travou)
- Loading spinner fullscreen sem contexto
- Carregar 50 items de uma vez (paginar/virtualizar)
- Imagem de 2MB como hero (comprimir para < 200KB)
- Fonte custom sem fallback (FOUT flash inaceitavel > 300ms)

---

## Regra Visual Absoluta

> **Se esta comparando, MOSTRA. Se esta sugerindo, MOSTRA. Se esta perguntando, MOSTRA.**

Nunca perguntar "prefere A ou B?" sem prototipar A e B lado a lado.
Toda referencia de mercado precisa de: link OU screenshot OU prototipo. Nunca so o nome.

Se nao consigo atingir qualidade visual alta no HTML, admitir e sugerir Figma.
Nunca usar emojis como icones em mockups.
Prototipos devem parecer produto final, nao rascunho.

---

## Red Flags — PARE e Reconsidere

| Pensamento | Realidade |
|---|---|
| "Vou usar emoji como icone, e mais rapido" | NAO. Lucide SVG sempre. |
| "O titulo 'Escolha o servico' esta claro" | NAO. Qual servico? Pra que? Precisa de subtitulo. |
| "O calendario esta bom com numeros simples" | NAO. Estados visuais claros: passado, disponivel, selecionado. |
| "Confirmar agendamento e so um botao" | NAO. E uma tela de REVISAO completa com "Alterar" por item. |
| "Vou mostrar o ultimo atendimento primeiro" | NAO. A acao principal vem primeiro. Contexto vem depois. |
| "O overlay verde no hover ta ok" | NAO. Border + shadow. Sem preenchimento verde cru. |
| "Posso usar foto generica do Unsplash" | NAO. Foto deve ser contextual (fachada real, consultorio, equipe). |
| "O prototipo e so wireframe, depois melhora" | NAO. O prototipo JA e o produto. Se parece autocad, esta errado. |
| "Vou colocar o depoimento antes dos servicos" | NAO. Servicos primeiro (acao). Depoimento depois (prova social). |
| "Uma lista flat com bullets resolve" | NAO. Cada item com icone contextual + titulo + subtitulo. |
| "5% de opacidade do primary vai dar destaque suave" | NAO. Varia por preset. Sempre solido. |
| "HTML standalone e rapido pra testar contraste" | NAO. Nao reproduz OKLCH. Use demo app. |

---

## Catalogo de Paginas por Categoria

Quando o usuario pede uma pagina, consultar este catalogo para referencia e composite:

```
AUTENTICACAO
  Login              → FormPage       Ref: Clerk, Auth0, Supabase
  Cadastro           → WizardPage     Ref: Stripe Onboarding, Linear
  Recuperar senha    → FormModal      Ref: GitHub, Notion
  Verificacao email  → DetailPage     Ref: Resend, Postmark

PAGAMENTOS
  Checkout           → WizardPage     Ref: Stripe, Paddle, LemonSqueezy
  Planos/Pricing     → ListPage       Ref: Vercel, Linear, Cal.com
  Historico faturas  → ListPage       Ref: Stripe Dashboard
  Metodo pagamento   → FormPage       Ref: Stripe Settings

CONFIGURACOES
  Perfil usuario     → SettingsPage   Ref: GitHub Settings, Linear
  Preferencias       → PreferencesPage Ref: Notion Settings, Slack
  Notificacoes       → SettingsPage   Ref: Discord, Slack
  Integracoes        → CardSettingsPage Ref: Zapier, n8n
  Seguranca (2FA)    → SettingsPage   Ref: GitHub Security

CRUD / GESTAO
  Listagem           → ListPage       Ref: Linear, Notion Databases
  Listagem com tabs  → TabbedListPage Ref: Intercom, HubSpot
  Detalhe            → DetailPage     Ref: Notion Page, Linear Issue
  Formulario criar   → FormPage       Ref: Typeform, JotForm
  Formulario editar  → FormPage       Ref: Airtable Record
  Modal rapido       → FormModal      Ref: Linear Quick Add

DASHBOARDS
  Overview           → DashboardPage  Ref: Vercel Analytics, Plausible
  Lista + metricas   → DashboardListPage Ref: Stripe Dashboard
  Analytics          → AnalyticsPage  Ref: PostHog, Mixpanel

ONBOARDING
  Wizard setup       → WizardPage     Ref: Notion First Run, Linear
  Tour guiado        → (overlay)      Ref: Intercom Product Tour
  Empty state        → DetailPage     Ref: Stripe Empty Dashboard

AGENDAMENTO
  Landing clinica    → custom         Ref: Doctoralia, Booksy, Calendly
  Paciente recorrente → custom        Ref: Doctoralia, Cal.com
  Calendario         → CalendarPage   Ref: Google Calendar, Cal.com
  Confirmacao        → DetailPage     Ref: Stripe Checkout, Calendly
  Pos-agendamento    → DetailPage     Ref: Doctoralia, Uber (pos-viagem)
  Meus agendamentos  → ListPage       Ref: Cal.com, Google Calendar

MARKETPLACE
  Catalogo produtos  → ListPage       Ref: Shopify, MUI Store
  Detalhe produto    → DetailPage     Ref: Product Hunt, Gumroad
  Comparacao         → DetailPage     Ref: G2, Capterra
```

## Setores de Mercado para Pesquisa

Saude, Educacao, Comercio/Varejo, Moda, Beleza/Estetica, Engenharia Civil, Vendas/CRM, Contabilidade, Fitness, Advocacia/Juridico, Fintech, SaaS/Tech, Restaurantes/Food, Imobiliario, Agro

## Design Systems de Referencia

Tier 1 (obrigatorio): Material Design 3, Apple HIG, Fluent 2, Carbon, Spectrum
Tier 2 (tendencia): Radix, Shadcn, Ant Design, Chakra, Mantine, Primer, Atlassian, Polaris
Tier 3 (especializados): Tremor, Park UI, Base UI, Ariakit

## Passagem de Contexto

A usabilidade salva resultado em: `docs/superpowers/audits/YYYY-MM-DD-[tema].md`
Contem: contexto, score, oportunidades, decisoes do usuario.
Quando outra superpower roda, le esse arquivo. Funciona entre sessoes.

## Skills Relacionadas

| Situacao | Skill |
|---|---|
| Implementar a pagina (APOS prototipo) | `superpower-design-paginas` |
| Auditar codigo (APOS implementar) | `superpower-design-qualidade` |
| Criar componente novo | `superpower-design-componente` |
| Evoluir design system | `superpower-design-sistema` |
