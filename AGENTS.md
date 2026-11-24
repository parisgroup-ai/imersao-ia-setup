<!-- pg-frota:inicio v13 -->
## Regras da Paris Group (frota v13)

Bloco gerado por `pg-devkit regras` de `packages/baseline/regras-frota.md`. Toda IA segue este bloco. Edite a fonte. As regras mais específicas do produto prevalecem.

### Ao começar a sessão
1. Rode `pg-devkit --version`. Se não existir, instale você mesmo. O token fica só no ambiente, nunca em argumento, arquivo ou chat:
   ```sh
   rc="$(mktemp)"; printf '%s\n' '@parisgroup-ai:registry=https://npm.pkg.github.com' '//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}' > "$rc"
   NODE_AUTH_TOKEN="$(gh auth token)" NPM_CONFIG_USERCONFIG="$rc" npm i -g @parisgroup-ai/pg-devkit; rm -f "$rc"
   ```
   Nunca use `npx pg-devkit` nem um pacote `pg-devkit` sem escopo: esse nome não é nosso.
2. Depois rode `pg-devkit doctor`. Nunca peça comandos ao humano. A única exceção: erro E401 ou E403 de pacote. Aí peça uma vez: "Rode `gh auth refresh -h github.com -s read:packages` e me avise."
3. Leia a caixa de entrada: `pg-devkit caixa`.
4. Se algo falhar (sem rede, sem `gh`, sem cota), não pare a tarefa. Siga este arquivo e avise numa linha no fim.
5. Padrão Paris v1 (11 itens, com a nota no Mission Control): `pg-devkit padrao` mostra o que falta neste repo.
6. **PRs antes de funcionalidade nova (obrigatório).** Antes do primeiro passo de uma funcionalidade nova, rode `gh pr list` e resolva antes os PRs abertos que esperam revisão, correção, conflito ou merge. Exceção: uma sessão nos PRs e outra na funcionalidade, as duas se falando (quem está em qual PR e arquivo). Produção parada passa na frente.

### Dono e rota (regras 1 e 2)
- Dono é medido: quem fez 1/3 ou mais dos commits da branch padrão em 90 dias, sem robô nem pin (a `rota` calcula). `donos:` no `devkit.config.yaml` é opcional e vence. CODEOWNERS e times do GitHub não valem. Sem dono: vale o time `leads`.
- Robô e agente nunca entram em `donos:`.
- Antes de subir, rode `pg-devkit rota`. Ela responde DIRETO, PR, ISSUE ou PULAR_E_AVISAR, e para quem. Sem o dono na sessão, some `--agente-sozinho`; algo que não se desfaz, `--irreversivel`; pedido sem código, `--tipo pedido`.
- O dono, ou a IA dele, vai direto na branch padrão depois dos gates. Quem não é dono abre PR, e só o dono ou a IA dele faz o merge. Pedido sem código vira issue.
- Revisão: no PR de produto, o dono aprova. Os sócios (`leads`) só revisam repo de todos (omnichannel, platform, pg-platform, pg-devkit, infra), produto tier 1 no MC e as pastas de segurança, dinheiro e dado de cliente (login, permissão, segredo, `.github/`, cobrança, pagamento, banco, migration), que o `.github/CODEOWNERS` dá a `@parisgroup-ai/leads` abaixo da linha `*`. Fora disso, não peça revisão a eles.
- A proteção do servidor vence: se ela exige PR, abra o PR.
- Antes do push: `git pull --rebase`. Nunca `--force`. Nunca pule os hooks, de nenhum jeito (`--no-verify`, `-n`, `HUSKY=0`, `SKIP=`, `core.hooksPath`). Hook lento ou falhando: conserte, ou `pg-devkit caixa abrir`. Nunca `gh run cancel`: o CI de outra sessão não se cancela.
- Revert puro sempre vai direto, pelos gates normais, nunca com checagem mais forte (`--tipo revert`).

### Gates (regra 3)
- Nada chega à produção sem um portão automático antes. Mudança arriscada (migration, RLS, auth, dinheiro, contrato público, gates, `donos:`) ganha checagem automática mais forte; pessoa a mais, só a da regra 2.
- Migration só pelo script do repo que faz lint, ensaio e registro. Segredo nunca entra no código. Feature nova declara `Rollout:` no commit.
- Escreveu migration: rode duas vezes no banco local (tem que ser idempotente) e rode os E2E que o seletor de impacto escolher, antes do PR ou do push.
- Teste instável vira issue e nunca é apagado.
- Commit só de docs não faz deploy.
- Actions custam por minuto e cada push na branch principal roda a suíte inteira. Trabalhe local: commits pequenos, gates locais, e **um push no fim do bloco** (ou no `/session-close`), não um por commit. PR fica em rascunho até acabar.
- Label de E2E completo (`trigger:full-e2e`, `run-e2e`) só com o PR pronto ou a pedido do dono.
- Script ou agente na API do GitHub: leia `/rate_limit` antes, até 300 chamadas REST por execução, e prefira `git clone --filter=blob:none --sparse` para ler arquivos.

### Agente sozinho (regra 4)
- Sem o dono na sessão (daemon, `claude -p`, nuvem), siga a política de decisão escrita do produto.
- Nunca faça sozinho o que não se desfaz: re-parear ou deslogar WhatsApp, envio em massa, verba, apagar dados, trocar chave, env ou DNS, afrouxar um gate ou mudar `donos:`. Avise o dono por uma issue na caixa, sem esperar resposta: `pg-devkit caixa abrir "<o que foi>"` mostra o comando pronto, sem duplicar e com os donos marcados. Pule a tarefa e siga. Nunca acorde ninguém.

### Atualização e máquina (regras 5 e 7)
- Atualizações de versão são do zelador. O Dependabot pode abrir PR para alerta de segurança npm com `open-pull-requests-limit: 0`. Nunca rode `npm install` para atualizar pacotes na sessão.
- A sessão nunca altera arquivo gerenciado que está no git (worktree, VPS, repo de outro dono). Só lê e avisa numa linha.
- `estado: congelado` e `congelados:` travam atualizações. Segurança sempre passa.

### Regras na raiz (regra 6)
- Este `AGENTS.md` é a fonte única. `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/pg.mdc` e `.github/copilot-instructions.md` só apontam para cá.
- Limite de 24 KB por `AGENTS.md`, na raiz e nas subpastas. O excesso vai para `docs/`, com link.
- Regra que protege o produto mora aqui, não na memória de uma IA. O repo vence a regra pessoal.
- Fora do padrão: `excecoes:` no `devkit.config.yaml`, com `regra`, `motivo` e `link` da ADR.

### Pedir para cima (regra 8)
Problema na plataforma vira issue (ou PR) no repo dono do assunto:

| Assunto | Repo |
|---|---|
| pacote `@parisgroup-ai/x` | pg-platform, se lá existir `packages/x`; senão, o repo de mesmo nome |
| skill e CLI | pg-devkit |
| hospedagem, segredos, LiteLLM, Keycloak | infra |
| tela ou dado do Mission Control | platform |
| na dúvida | pg-devkit |

Mande só uma reprodução mínima e o link do repo de origem. Nunca código, dado, print ou nome de cliente.

### Caixa de entrada e avisos (regra 9)
- O que a Paris precisa deste projeto vira issue aqui, com a etiqueta `paris:caixa` (precisa do dono). `pg-devkit caixa` mostra as issues e os PRs que esperam você; os de merge seu (`--prioridade`) vêm antes de trabalho novo.
- Pedido: `pg-devkit caixa abrir "<o que foi>" [--para <repo>]`.
- Chame o dono na hora só por produção parada, dinheiro saindo, decisão pendente ou segurança, uma vez por dia por assunto. Parceiro e cliente recebem pela caixa.
- Paris Chat: um assunto por mensagem, o pedido na 1ª linha, até 3 linhas e 400 caracteres; o detalhe vai no PR ou na issue, com link. O `paris-chat team send` recusa o resto.

### Agentes, Mission Control e Vordin (regras 10 a 12)
- Todo repo da parisgroup-ai aparece no Mission Control. Se o `pg-devkit doctor` disser que não, avise numa linha: os leads já têm a tarefa.
- Todo agente e serviço, em qualquer conta (Railway, VPS, conta pessoal), fica no `.pgdk/agents.yaml` e manda batimento, com o slug do produto dono, e resultado ao Mission Control pelo contrato HTTP. Sem token, nada é enviado. Teste local nunca grava no MC. MC fora do ar nunca trava o agente.
- Entrega só conta como verificada se quem confere não é o próprio agente.
- O Vordin é o CRM único. Vai para lá só lead ou cliente em negociação real; prospecção fria e o cliente do cliente ficam no produto. Antes de mandar mensagem, consulte "não contatar". Número oficial de WhatsApp nunca é pareado em Baileys.
- Site e anúncio entram pelo `/api/leads/intake` do Vordin.
- Adoção é medida por projeto, nunca por pessoa.

### Relato de trabalho (regra 13)
- Ao começar: `pg-devkit trabalho direcao` e `pg-devkit trabalho relato --fase inicio`.
- Ao fechar: `pg-devkit trabalho relato --fase fim` e `pg-devkit trabalho entrega "<o que entregou>" --prova <link>`.
- Relato sincero, "não para controle, mas sim para tomada de decisão": o que travou, o que foi decidido, o que precisa de um sócio.
- Nunca dado de cliente nem trecho da conversa. Sem entrega: diga o pendente. Conta entrega, não hora.
<!-- pg-frota:fim -->
