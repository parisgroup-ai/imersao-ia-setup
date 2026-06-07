---
name: spell-check-pt-en
description: >-
  Use when writing or editing user-facing text (PT-BR or EN) that will be
  persisted to files — UI copy, i18n strings, error messages, CLI help text,
  README/docs, commit messages, doc comments. Do NOT use for chat replies to the
  user, internal logs, or temporary scratch text.
version: 1.0.0
author: dhiogogabriel
---

<!-- last-reviewed: 2026-05-17 -->

# Spell Check PT-BR / EN

## Overview

The user types fast and often with typos so the assistant moves quickly. That's fine for chat. But typos must NEVER reach files the project ships — UI copy, i18n locales, READMEs, CLI help text, error messages, commit messages, or doc comments (`///`, JSDoc, docstrings).

**Core rule:** Before writing/editing text into a file, normalize spelling and accentuation. Preserve the user's tone, voice, capitalization style, and intent. Do not rewrite, expand, or "improve" the prose.

## When to Use

Apply BEFORE every Write or Edit that contains prose in PT-BR or EN, including:

- Locale files (`*.json`, `*.po`, `messages/*.ts`)
- UI copy in components (labels, placeholders, button text, toasts, empty states)
- Error messages, validation messages, exception strings
- CLI help text (`clap`, `commander`, `argparse`)
- Public docs: README, CHANGELOG, ADRs, markdown in `docs/`
- Doc comments that ship to public reference (rustdoc `///`, JSDoc `/** */`, Python docstrings)
- Commit messages and PR titles/descriptions
- Notas e documentação persistidas (ex.: vault, wiki)

## When NOT to Use

- Chat replies to the user (keep them fast and informal)
- Internal log lines, debug prints, temporary console output
- Variable/function/file names (those follow code conventions, not spelling rules)
- Code identifiers, API field names, DB column names
- User-supplied content quoted verbatim (preserve as-is)

## Procedure

1. **Detect language** of the text being written (PT-BR, EN, or mixed).
2. **Normalize:**
   - Fix obvious typos (`pra` → `para` only in formal copy; keep `pra` in casual brand voice if the surrounding copy is casual).
   - Restore accents/cedilla in PT-BR (`nao` → `não`, `usuario` → `usuário`, `acao` → `ação`).
   - Fix capitalization of proper nouns (`react` → `React`, `nextjs` → `Next.js`, `postgres` → `Postgres`, `ai` → `AI`).
   - Fix punctuation: missing periods, double spaces, smart-quote consistency within a file.
3. **Preserve:**
   - The user's chosen tone (formal vs casual). If the file already uses `você`, keep it; if it uses `tu`, keep it.
   - Intentional informality in marketing copy or brand voice.
   - Domain jargon (see Technical Dictionary below).
   - Casing of brand names exactly as the user wrote them when intentional.
4. **Do not:**
   - Rewrite sentence structure.
   - Expand abbreviations the user chose deliberately.
   - Translate between PT and EN.
   - Add Oxford commas or change style choices already consistent in the file.

## Technical Dictionary (do not "correct")

These are correct as-is — do not flag or change:

**Generic tech:** AST, CLI, API, SDK, MCP, LLM, JWT, OAuth, OIDC, CORS, CRUD, DTO, ORM, RPC, gRPC, GraphQL, HogQL, HTTP, HTTPS, IPC, JSON, JSX, TSX, MDX, ORM, REPL, REST, RFC, SaaS, SQL, SSR, SSG, ISR, TLS, TTL, URL, URI, UUID, VPC, WAL, YAML, ZSTD.

**Tools/libs:** tree-sitter, ripgrep, biome, drizzle, prisma, clerk, resend, stripe, supabase, vercel, cloudflare, posthog, sentry, pnpm, turborepo, vitest, playwright, maestro, clap, anyhow, serde, tokio, actix, axum, tonic.

**Domain (análise de código):** AST, hotspot, circular dependency, knowledge graph, dependency graph, call graph, edge, node, vertex, subgraph, traversal.

**Domain (web):** composite, slot, token, locale, middleware, server action, route handler.

When in doubt, leave the term alone.

## Quick Reference: PT-BR Common Fixes

| Wrong | Right |
|---|---|
| nao, sao, mae | não, são, mãe |
| voce, voces | você, vocês |
| usuario, calendario, relatorio | usuário, calendário, relatório |
| acao, opcao, configuracao | ação, opção, configuração |
| publico, basico, automatico | público, básico, automático |
| ja, la, ate, apos | já, lá, até, após |
| esta (verb) vs está | está (when verb "to be") |
| pra (in formal copy) | para |
| obrigatorio, conteudo | obrigatório, conteúdo |
| sucesso, processo (no fix needed) | sucesso, processo |

## Quick Reference: EN Common Fixes

| Wrong | Right |
|---|---|
| recieve, occured, seperate | receive, occurred, separate |
| dependant (adj) | dependent |
| sucessful | successful |
| accross | across |
| existant | existent / existing |
| neccessary | necessary |
| occurence | occurrence |

## Output

Apply corrections silently as part of the Write/Edit. Do NOT announce "I corrected X" unless the user explicitly asked for a spell-check pass on existing content. The goal is invisible quality, not commentary.

If you find a term that looks like a typo but might be intentional brand/product naming, leave it as the user wrote it. Bias toward preservation.

## Common Mistakes

- **Over-correcting brand voice.** "Pra você" in a casual landing page is fine — don't change to "Para você" if the file's voice is informal.
- **Translating.** Spell-check ≠ translation. If a string is in EN, fix EN typos; do not switch to PT.
- **Touching code.** Identifiers, keys, enum values, API field names are code, not prose. Skip them.
- **Announcing the fix.** Silent normalization. The diff speaks for itself.
- **Correcting the user's chat.** This skill applies to file writes, not to replies in conversation.

## Red Flags — STOP

- About to rewrite a sentence for clarity → that's editing, not spell-check. Don't.
- About to translate PT ↔ EN → out of scope. Don't.
- About to "modernize" or "improve" the tone → out of scope. Don't.
- About to fix a string a user pasted verbatim from an external source → preserve it.

If any of these come up: revert to the user's text, fix only orthography/accents, move on.
