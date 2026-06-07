# Plugin `imersao`

Skills de IA curadas da **Imersão IA da ParisGroup**. Empacotadas como um plugin do Claude Code: o runtime descobre cada skill em `skills/<nome>/SKILL.md` automaticamente — sem copiar pastas à mão.

## Instalação (Claude Code)

```text
/plugin marketplace add parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

Ou, fora do Claude Code, pelo CLI:

```bash
claude plugin marketplace add parisgroup-ai/imersao-ia-setup
claude plugin install imersao@imersao-ia
```

Reinicie o Claude Code para carregar as skills. Use `/plugin` para listar, atualizar (`claude plugin update imersao`) ou desinstalar.

## Codex

Plugins são um recurso do Claude Code. Para usar essas skills no **Codex**, rode o script de sincronização (copia as skills para `~/.codex/skills/`):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/sync-codex-skills.sh | bash
```

## Processo da Imersão (comandos)

O plugin traz um **pipeline guiado** que leva da ideia ao app funcionando, em 3 fases
sobre um motor autônomo. Guia completo: [`docs/PROCESSO-IMERSAO.md`](../../docs/PROCESSO-IMERSAO.md).

| Comando | Fase | Para quê |
|---|---|---|
| `/pg-imersao-prd` | 1 | Ideia → `docs/PRD.md` (via brainstorming guiado) |
| `/pg-imersao-prototipo` | 2 | PRD → protótipo no **Design OS** público → export React+Tailwind |
| `/pg-imersao-implementar` | 3 | Export + PRD → app **Next.js + Tailwind + shadcn/ui + Drizzle + Postgres (Docker)** |
| `/pg-imersao-goal` | — | Motor autônomo (brainstorming → plano → execução → integração) com 2 gates humanos |

As skills-base de método (`brainstorming`, `writing-plans`, `executing-plans`,
`finishing-a-development-branch`, `test-driven-development`, `systematic-debugging`,
`subagent-driven-development`, `verification-before-completion`) são vendorizadas aqui
para que o pipeline funcione em qualquer projeto.

## Qual skill usar quando

Alguns grupos de skills se parecem — este mapa desambigua (você normalmente só descreve o que quer e o Claude escolhe sozinho):

| Quero… | Skill |
|--------|-------|
| Testar **app mobile no simulador iOS** | `maestro-run` (rodar), `maestro-analyze` (falhou), `maestro-capture` (screenshots), `maestro-fix-cycle` (corrigir em loop) |
| Ver se a **página web quebra em tela pequena** (responsivo, no navegador) | `qa-mobile` |
| Escrever/revisar um **app React Native / Expo** | `mobile-native-bestpractices` |
| **Testes end-to-end** de web (Playwright) | `e2e-run` (rodar), `e2e-architect` (planejar), `e2e-analyze` (falha), `e2e-fix-cycle` (corrigir), `e2e-chrome-devtools` (smoke visual) |
| **Cobertura de testes** | `coverage-run` (rodar), `coverage-check` (gate/threshold), `coverage-report` (tendência/histórico) |
| **Plano → execução → review** com vários agentes | `team-plan` → `team-execute` → `team-reviewer` |
| **Mobile**: nativo vs. simulador vs. web responsivo | `mobile-native-bestpractices` (código RN/Expo) · `maestro-*` (teste no simulador iOS) · `qa-mobile` (web responsivo no navegador) |

## Estrutura

```
plugins/imersao/
├── .claude-plugin/plugin.json   # manifesto (nome, versão, autor)
├── commands/
│   └── pg-imersao-*.md          # comandos do processo da imersão
└── skills/
    └── <nome>/SKILL.md          # uma skill por pasta
```

## Adicionar uma skill

1. Crie `skills/<nome>/SKILL.md` com frontmatter `name` + `description` (veja o README raiz para o formato).
2. Abra um Pull Request em `parisgroup-ai/imersao-ia-setup`.

O plugin descobre a nova skill automaticamente — não há tabela ou contador para manter em dia.
