# Contribuindo

Quer adicionar ou melhorar uma skill da Imersão? Bem-vindo! O fluxo é por **Pull Request** — ótimo jeito de praticar git durante a imersão.

## Adicionar ou editar uma skill

1. **Crie um branch:**
   ```bash
   git checkout -b skill/minha-skill
   ```
2. **Crie a pasta da skill** em `plugins/imersao/skills/<nome>/SKILL.md` com frontmatter mínimo:
   ```yaml
   ---
   name: minha-skill
   description: "O que faz e QUANDO usar. Inclua gatilhos em PT-BR e EN: ex. conserta o ci, fix ci, build quebrou."
   ---

   # Minha Skill

   Instruções em Markdown: passo a passo, exemplos, checklist.
   ```
   Regras: `name` em kebab-case **igual ao nome da pasta**; `description` com pelo menos 10 caracteres e bons gatilhos (é o que faz a skill disparar no Claude).
3. **Valide localmente** antes de abrir o PR:
   ```bash
   bash scripts/validate-skills.sh
   ```
   Tem que terminar em `✓ Tudo válido`.
4. **Commit + push + PR:**
   ```bash
   git add plugins/imersao/skills/minha-skill
   git commit -m "feat: add minha-skill skill"
   git push -u origin skill/minha-skill
   gh pr create --base main
   ```

O CI roda `validate-skills.sh` e `shellcheck` automaticamente. Depois do merge, quem já tem o plugin recebe a skill com `claude plugin update imersao`.

## Editar o instalador ou scripts

Os scripts `.sh` passam pelo `shellcheck -S warning` no CI. Rode antes:

```bash
shellcheck -S warning instalar_imersao.sh scripts/*.sh
```

## Dicas

- Skills devem ser **genéricas** — evite caminhos/nomes de projetos internos (ex. `packages/api/...`). O catálogo é público e usado por qualquer aluno.
- Não há tabela/contador de skills pra manter: o plugin descobre cada `SKILL.md` sozinho.
- Dúvida? Abra uma issue com o template **Problema no instalador** ou **Nova skill**.
