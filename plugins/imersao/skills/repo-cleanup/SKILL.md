---
name: repo-cleanup
description: >-
  Use when cleaning legacy junk accumulated in a repository — orphan docs, stale
  test artifacts, abandoned scripts, unused assets, backup files, deprecated
  migrations. Works generically across any stack (JS/TS, Python, Rust, Go, PHP,
  mixed monorepos). Uses grep/ripgrep to verify zero references before
  proposing deletion. Triggers on phrases like "limpa o lixo", "repo está sujo",
  "tem muita coisa legada", "clean up the repo", "remove dead files", "arquivos
  antigos", "coisa abandonada", "screenshot de teste antigo", "docs órfãs", or
  whenever the user wants to reduce repository bloat without touching live
  source code.
version: 1.1.0
---

<!-- last-reviewed: 2026-05-17 -->

# Repo Cleanup Skill

Remove lixo acumulado em repositórios de forma **segura e interativa**. Detecta artefatos legados, apresenta em batches por categoria, e só deleta após confirmação explícita.

## Core Principle

> **Repositórios acumulam lixo silenciosamente.** O `.gitignore` protege o que nunca deveria entrar, mas arquivos *já commitados* (screenshots de teste antigos, docs de features removidas, scripts abandonados) só saem com intervenção manual. Essa skill faz a arqueologia, você aprova.

> **Segurança primeiro:** `in_degree=0` mente. Re-export chains, dynamic imports, CI YAML references, scripts `npm run` — tudo escapa de uma busca ingênua. **Sempre verificar referências antes de propor deleção** — busque em todo o repo com grep/ripgrep (basename, caminho da pasta e imports dinâmicos).

## Code Search Order (busca por referências)

Antes de propor `git rm` em qualquer arquivo de código, módulo, ou pasta legada, **procure referências no repositório inteiro** com grep/ripgrep:

| Pergunta | Como verificar |
|---|---|
| "`<file>` tem importadores?" | `grep -rn "modulo" --include='*.ts' --include='*.tsx'` (teste basename **E** caminho relativo) |
| "Quem usa `<symbol>` exportado?" | `grep -rn "<symbol>"` no repo inteiro |
| "Asset `/public/foo.png` é referenciado?" | `grep -rn "foo.png"` (assets carregam por string, não import) |
| Docs órfãs (`.md` sem links em outros `.md`) | `grep -rn "nome-do-doc"` (links são plain-text) |
| Scripts em `package.json`/CI YAML | `grep -rn "nome-do-script"` (configs são plain-text) |

**Atenção com imports indiretos:** `git rm` em arquivo com re-export chain ou dynamic import quebra runtime sem aviso (CI passa, prod cai). `grep` por basename perde `import X from './foo'` quando o arquivo se chama `foo/index.ts` — então **busque também pelo caminho da pasta** e por imports dinâmicos (`import(`, `require(`). Na dúvida, **não delete**: liste para revisão manual.

## Fluxo Geral

```
0. BASELINE              → lista de arquivos TRACKED pelo git (fonte única de verdade)
1. DETECTAR stack        → adapta heurísticas ao projeto
2. SCAN por categoria    → coleta candidatos (operando SEMPRE sobre o baseline)
3. VERIFICAR references  → grep cruzado antes de marcar lixo
4. APRESENTAR em batches → user aprova/rejeita/refina por categoria
5. EXECUTAR deleções     → git rm em commits separados por categoria
6. RELATÓRIO final       → resumo do que foi removido + bytes liberados
```

## Etapa 0 — Baseline (OBRIGATÓRIA antes de qualquer scan)

**Por que:** scans crus (`Glob`, `find`) retornam arquivos dentro de `node_modules/`, `.venv/`, `.git/`, `.next/`, etc — tudo gerado/instalado, não trackeado pelo git. Propor `git rm` nesses arquivos é inútil (não estão no index) ou destrutivo (no caso de `.git/`, corrompe o repo).

### 0.1 — Gerar lista de arquivos tracked

```bash
cd <repo-root>
git ls-files > /tmp/repo-cleanup-tracked.txt
```

**Todos os candidatos de deleção DEVEM sair dessa lista.** Se um arquivo não está aqui, não está trackeado — a skill não deve propor `git rm`, pode no máximo sugerir `rm` local (ex: `.DS_Store` no working tree que o usuário ainda não gitignored).

### 0.2 — Hard exclusion list (defense in depth)

Mesmo operando sobre `git ls-files`, aplicar exclusão extra. Se qualquer candidato matchar um destes paths, **descartar silenciosamente** — nunca apresentar ao usuário:

```
^\.git/
(^|/)node_modules/
(^|/)\.venv/
(^|/)venv/
(^|/)env/
(^|/)\.next/
(^|/)\.nuxt/
(^|/)\.turbo/
(^|/)\.cache/
(^|/)dist/
(^|/)build/
(^|/)out/
(^|/)__pycache__/
(^|/)\.pytest_cache/
(^|/)target/           # Rust build
(^|/)vendor/           # Go, PHP
\.pyc$
```

**Regra absoluta: `.git/` nunca entra no scan, sob nenhuma circunstância.** Mesmo que `git ls-files` retorne algo dentro de `.git/` (não deveria, mas defense in depth), descartar.

### 0.3 — Detecção de `.DS_Store` e similares no working tree

Esses artefatos de OS (`.DS_Store`, `Thumbs.db`, `desktop.ini`) aparecem normalmente **fora** do index. Comando correto:

```bash
find . -name '.DS_Store' -not -path './.git/*' -not -path './node_modules/*' -not -path '*/.venv/*'
```

Para esses, propor `rm` local (não `git rm`) + adicionar ao `.gitignore` global do usuário ou do repo.

## Etapa 1 — Detecção de Stack

Rodar em paralelo para identificar o projeto:

| Arquivo | Stack inferida | Implica |
|---------|----------------|---------|
| `package.json` | Node/JS/TS | Verificar `scripts`, `dependencies`, workspaces |
| `pnpm-workspace.yaml` / `turbo.json` | Monorepo JS | Scan por workspace |
| `Cargo.toml` | Rust | `[bin]` targets, `examples/`, `benches/` |
| `go.mod` | Go | `_test.go`, `cmd/` |
| `requirements.txt` / `pyproject.toml` | Python | `tests/`, `conftest.py` |
| `composer.json` | PHP | `scripts`, autoload |
| `.github/workflows/*.yml` | GitHub Actions | Refs a scripts em jobs |
| `Makefile` / `Justfile` | Task runners | Refs a scripts em targets |

**Output:** mapa `{stack, package_managers, ci_files, task_runners, workspaces}` usado nas etapas seguintes.

## Etapa 2 — Categorias de Scan

Executar categorias em paralelo. Cada uma tem heurística de detecção + regra de verificação.

**Pré-condição:** todas as categorias operam sobre o baseline gerado na Etapa 0 (`git ls-files` filtrado pela hard exclusion list). Se uma categoria precisa procurar fora do index (ex: `.DS_Store` no working tree), isso está explicitado na própria categoria.

**Padrão de implementação:** filtrar a lista baseline por regex/glob da categoria em memória, em vez de rodar `Glob`/`find` no filesystem cru. Isso elimina por design qualquer contaminação de `node_modules/`, `.venv/`, `.git/` etc.

### Categoria A: Test Artifacts (baixo risco)

Gerados por runners de teste, frequentemente commitados por engano.

| Padrão | Ferramenta típica |
|--------|-------------------|
| `playwright-report/` | Playwright |
| `test-results/` | Playwright, generic |
| `coverage/`, `.nyc_output/` | Jest, nyc, Vitest |
| `__snapshots__/` órfãos (sem teste correspondente) | Jest snapshots |
| `*.test.ts.snap` órfãos | Vitest |
| `cypress/screenshots/`, `cypress/videos/` | Cypress |
| `e2e/screenshots-*`, `tests/screenshots/legacy-*` | Custom |
| `maestro-test-output/` | Maestro |

**Verificação:** nenhuma necessária para pastas geradas (`playwright-report`, `coverage` etc — podem sempre ir pra `.gitignore` + deletar). Para snapshots, cruzar com testes vivos.

### Categoria B: Backup / Versioned files (baixo risco)

| Padrão | Critério |
|--------|----------|
| `*.bak`, `*.backup`, `*.old`, `*.orig` | Nome literal |
| `*_old.*`, `*_legacy.*`, `*_deprecated.*` | Sufixo |
| `*.copy`, `*.copy.*` | macOS Finder copies |
| `LEGACY_*`, `OLD_*`, `DEPRECATED_*` | Prefixo UPPERCASE |
| Arquivos com `_v1`, `_v2` quando existe versão sem sufixo | Comparar pares |

**Verificação:** grep pelo path — raramente referenciados.

### Categoria C: Orphan Documentation (médio risco)

Docs não linkadas em nenhum outro documento.

**Heurística:**
1. Listar todos `**/*.md` em `docs/`, `documentation/`, raiz (exceto `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE*`, `AGENTS.md`, `CLAUDE.md`)
2. Para cada `X.md`, grep por `X.md`, `X)`, `(./X`, `[X]` em:
   - Outros `.md`
   - `README*`
   - `package.json` (campo `docs`, `homepage`)
   - `.github/`
3. Zero matches → candidato

**Verificação extra:** `git log --oneline -- <file> | head -1` — se último commit foi <30 dias, avisar no relatório (pode ser doc nova ainda não linkada).

### Categoria D: Orphan Scripts (médio risco)

Scripts não invocados em lugar nenhum.

**Heurística:**
1. Listar `scripts/**/*.{sh,ts,js,py}`, `bin/**`, `tools/**`
2. Para cada script, grep o nome do arquivo em:
   - `package.json` → `scripts`
   - `Makefile`, `Justfile`, `Taskfile.yml`
   - `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/`
   - `Dockerfile*`, `docker-compose*.yml`
   - `.husky/`, `.pre-commit*`
   - Outros scripts (invocações cruzadas)
   - Docs (referenciado em tutoriais?)
3. Zero matches → candidato

**Verificação extra:** scripts com shebang (`#!/usr/bin/env`) podem ser chamados manualmente — marcar como "possivelmente manual" em vez de certeza.

### Categoria E: Orphan Assets (médio risco)

Imagens/PDFs/fontes não referenciadas em código ou docs.

**Heurística:**
1. Listar `**/*.{png,jpg,jpeg,gif,svg,webp,pdf,woff,woff2,ttf,mp4,mov}` em `public/`, `assets/`, `static/`, `docs/`, `images/`
2. Para cada asset, grep o **nome do arquivo** (sem path completo) em:
   - `**/*.{ts,tsx,js,jsx,vue,svelte,astro,html,css,scss,md,mdx,json}`
   - Excluir matches dentro da própria pasta de assets
3. Zero matches → candidato

**Verificação extra:** assets em `public/` acessados via URL pública (`/logo.png`) podem ser referenciados por string parcial — incluir busca por basename sem extensão também.

### Categoria F: Legacy / Deprecated Modules (alto risco — FLAG ONLY)

Código ou pastas com sinais explícitos de abandono.

**Heurística:**
- Pastas contendo `DEPRECATED`, `LEGACY`, `OLD_`, `_deprecated`, `_legacy`
- Arquivos com comentários `@deprecated`, `// LEGACY`, `// TODO: remove after`
- TODOs com data passada (`TODO(2024-06-01)`)

**Verificação obrigatória:** antes de incluir qualquer módulo dessa categoria no relatório, rode `grep -rn` no path/símbolo pra contar referências (lembre de testar basename e caminho da pasta). Marker `@deprecated` mente — código permanece referenciado por anos. Reportar `(N referências encontradas)` na linha do arquivo pra que o operador decida.

**Ação:** **NÃO propor deleção automática.** Listar no relatório para revisão manual, pois podem ter importadores ativos apesar do marker.

### Categoria G: Database Migrations (alto risco — FLAG ONLY)

Migrações são históricas e imutáveis por design.

**Heurística:**
- Arquivos em `migrations/`, `db/migrations/`, `packages/database/migrations/`, `alembic/versions/`
- Arquivos com timestamp muito antigo (>1 ano)

**Ação:** **NUNCA deletar.** Apenas reportar contagem e range de datas. Se usuário quiser consolidar/squash, orientar para usar ferramenta nativa do ORM (drizzle-kit, alembic, prisma).

### Categoria H: Duplicates & Stale Archives (médio risco)

| Padrão | Exemplo |
|--------|---------|
| Pastas `archive/` com conteúdo >6 meses | `docs/archive/`, `tasks/archive/` |
| Arquivos duplicados por hash | Mesmo conteúdo em paths diferentes |
| `.DS_Store`, `Thumbs.db`, `desktop.ini` | Artefatos de OS |

**Verificação:** hash comparison via `md5sum` / `shasum` para detectar duplicatas reais.

## Etapa 3 — Apresentação Interativa (padrão batch-per-category)

Para **cada categoria com resultados**, apresentar no formato:

```
═══════════════════════════════════════════════════════════
📁 Categoria X: <nome> (<risco>)
   Encontrados: N arquivos | Total: XXX MB

Exemplos (primeiros 5):
  1. path/to/file-a.md          (last modified: 2023-05-12)
  2. path/to/file-b.png         (size: 2.3 MB)
  3. path/to/file-c.sh          (last modified: 2024-01-03)
  4. path/to/file-d.snap        (size: 12 KB)
  5. path/to/file-e.backup      (size: 8 KB)
  ... e mais N-5 arquivos

Ação proposta: git rm (soft) + commit separado
═══════════════════════════════════════════════════════════

Opções:
  [a] Aprovar deleção de todos os N
  [r] Ver lista completa antes de decidir
  [s] Selecionar subset (me diga quais excluir)
  [k] Pular categoria (manter tudo)
  [f] Flag only (adicionar ao relatório sem deletar)
```

**Regras de UX:**
- Sempre mostrar categorias em ordem de risco crescente (A → H)
- Nunca agrupar categorias de risco diferente num mesmo batch
- Para categorias FLAG ONLY (F, G), não oferecer opção `[a]`
- Se N > 50, recomendar `[r]` antes de `[a]`

## Etapa 4 — Execução

**Commits separados por categoria** para reversibilidade limpa:

```
chore(cleanup): remove N orphan test artifacts
chore(cleanup): remove N backup files
chore(cleanup): remove N orphan docs
chore(cleanup): remove N orphan scripts
chore(cleanup): remove N orphan assets
```

**Comandos preferidos:**
- `git rm <file>` (mantém histórico em Git)
- Nunca `rm -rf` diretamente em pastas rastreadas
- Atualizar `.gitignore` quando apropriado (test artifacts regeneráveis)

**Antes de cada commit:**
- Rodar `git status` e mostrar ao usuário
- Confirmar que só os arquivos aprovados estão staged
- Para monorepos: respeitar boundaries (não deletar em workspace que usuário não autorizou)

## Etapa 5 — Relatório Final

Template obrigatório ao final da sessão:

```markdown
# Repo Cleanup Report — <repo name> — <date>

## Summary
- Files removed: N
- Space reclaimed: XXX MB
- Commits created: M

## By Category
| Categoria | Detectados | Removidos | Pulados | Flag only |
|-----------|-----------:|----------:|--------:|----------:|
| A - Test artifacts | 42 | 42 | 0 | - |
| B - Backup files | 8 | 8 | 0 | - |
| C - Orphan docs | 15 | 12 | 3 | - |
| ... | | | | |

## Flagged (manual review needed)
- path/to/legacy-module/ — @deprecated since 2024-03
- packages/database/migrations/ — 247 migrations, oldest 2022-11

## Gitignore additions
Added to .gitignore to prevent re-commit:
- playwright-report/
- coverage/
- test-results/

## Follow-up suggestions
- Consolidar migrações antigas via `pnpm db:squash` (tema para sessão futura)
- Revisar pastas archive/ trimestralmente
```

## Safety Invariants

Quebrar qualquer um destes = bug na skill:

1. **Nunca deletar sem confirmação explícita** (`[a]` ou `[s]` do usuário)
2. **Nunca `rm -rf` em paths rastreados pelo Git** — sempre `git rm`
3. **Nunca tocar em `.git/`** — sob nenhuma hipótese, independente do que o scan retorne. Se um candidato contém `.git/` no path, descartar imediatamente.
4. **Candidatos vêm do baseline da Etapa 0** — arquivos fora de `git ls-files` não podem virar `git rm`. Para artefatos no working tree (ex: `.DS_Store` não-gitignored), propor `rm` local, não `git rm`.
5. **Nunca tocar em código-fonte ativo** (`src/`, `app/`, `lib/`, `packages/*/src/`) — se aparecer como candidato, é bug de detecção
6. **Nunca deletar migrações de DB** — apenas reportar
7. **Sempre verificar referências** via grep antes de incluir na lista (especialmente categorias C/D/E)
8. **Sempre um commit por categoria** — facilita revert seletivo
9. **Preservar:** `README.md`, `LICENSE*`, `CHANGELOG.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `.gitattributes`, qualquer arquivo em `.github/` a menos que claramente órfão (workflow desabilitado etc)
10. **Content regeneráveis dentro do index:** se `playwright-report/` ou `coverage/` aparecem em `git ls-files`, foram commitados por engano. Propor deleção **e** adição ao `.gitignore` — não só deletar, senão voltam no próximo run de teste.

## Stack-Specific Gotchas

### Monorepos (pnpm workspaces, Turborepo, Nx)
- Scripts podem ser invocados via `turbo run <script>` — grepar `turbo.json` também
- Workspaces podem importar assets de outros workspaces — grepar em todo o repo, não só no workspace atual

### Next.js / Nuxt / SvelteKit
- Arquivos em `public/` acessados por URL absoluta — verificar string `/<filename>` em todo o código
- Rotas dinâmicas podem carregar assets — não confiar só em imports estáticos

### Rust
- `examples/` e `benches/` parecem órfãos mas são build targets oficiais — **não deletar**
- `src/bin/*.rs` são `[[bin]]` targets implícitos — **não deletar** mesmo se não importados
- Fixtures carregadas via `include_str!`, `include_bytes!`, `std::fs::read_to_string`, `Path::new` — essas referências são por string, grep estático as perde

### Python
- `conftest.py` parece órfão (nunca importado) mas é auto-descoberto pelo pytest — **não deletar**
- Fixtures em `tests/fixtures/` podem ser carregados via path string — verificar `open(`, `Path(`, `pytest.fixture`

### Go
- `//go:embed` carrega assets via string — grepar `embed` também
- Arquivos `_test.go` só rodam em teste — se suite vazia, podem ser órfãos

### Universal rule: Test fixtures & runtime path-loaded files

**Qualquer arquivo cujo path contenha** `/fixtures/`, `/testdata/`, `/__fixtures__/`, `/snapshots/`, `/golden/`, `/seeds/`, `/samples/` → **FLAG ONLY, nunca propor deleção automática**.

Motivo: fixtures são quase sempre carregadas por string em runtime (`open("fixtures/x.json")`, `include_str!("fixtures/y.md")`, `readFile("testdata/z.yaml")`). Análise estática grep por basename encontra pouco, mas deletar quebra testes inteiros.

### Universal rule: Claude Code / AI tooling assets

**Pastas de ferramentas AI (`.claude/`, `claude/`, `.cursor/`, `.github/copilot/`, `.skills/`) contêm arquivos `.md` carregados por ferramentas externas por convenção de path.** Nunca tratar arquivos em:
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`
- `claude/commands/`, `claude/agents/` (variantes sem dot)
- `.cursor/rules/`
- Qualquer `SKILL.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` em qualquer nível

…como "orphan docs" só porque não estão linkados em outros `.md`. Eles são consumidos por slashcommands / agent loaders / skill registries, não por humanos via links.

## Quando NÃO usar essa skill

- Usuário quer deletar arquivos específicos já conhecidos → use `rm` / `git rm` direto
- Problema é código morto dentro de arquivos vivos (funções não usadas, imports não usados) → use skill `code-quality`
- Duplicação de lógica entre módulos → use skill `code-consolidation`
- Preparação de release / bump de versão → use skill `release-maintenance`

## Exemplo de Sessão

```
User: "o repo tá cheio de lixo, limpa pra mim"

Claude: [roda detecção de stack]
        "Detectei: pnpm monorepo, Next.js + FastAPI + Expo.
         Vou escanear 8 categorias em paralelo."

Claude: [apresenta Categoria A — test artifacts]
        "42 arquivos em playwright-report/ e coverage/ (18 MB).
         Essas pastas são regeneradas pelos runners.
         [a] aprovar | [r] ver lista | [k] pular | [f] flag"

User: "a + adiciona no gitignore"

Claude: [git rm + commit + .gitignore update]
        "✅ 42 arquivos removidos, .gitignore atualizado."

... continua por categorias B-H ...

Claude: [relatório final]
```
