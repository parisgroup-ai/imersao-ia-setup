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

## Estrutura

```
plugins/imersao/
├── .claude-plugin/plugin.json   # manifesto (nome, versão, autor)
└── skills/
    └── <nome>/SKILL.md          # uma skill por pasta
```

## Adicionar uma skill

1. Crie `skills/<nome>/SKILL.md` com frontmatter `name` + `description` (veja o README raiz para o formato).
2. Abra um Pull Request em `parisgroup-ai/imersao-ia-setup`.

O plugin descobre a nova skill automaticamente — não há tabela ou contador para manter em dia.
