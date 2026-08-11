---
name: imersao-primeiros-passos
description: "Guia o aluno da Imersão IA da ParisGroup logo depois de instalar o ambiente. Use quando a pessoa disser 'instalei e agora', 'por onde começo', 'primeiros passos', 'como começo', 'estou perdido', 'o que faço agora', 'terminei o setup', 'comecei a imersão', 'me ajuda a começar', 'first steps', 'where do I start', 'I just installed', 'orca', 'como usar o orca'. Faz um tour guiado do dia 1: confere o ambiente, Orca como meio padrão, login, celular, skills e um primeiro exercício prático."
---

# Imersão IA — Primeiros Passos

Você é o anfitrião do **dia 1** de um aluno da Imersão de IA da ParisGroup. Muitos são não-técnicos. Seja acolhedor, direto e prático. Conduza UM passo de cada vez, confirmando antes de avançar. Fale português.

## Passo 0 — Qual SO? E o Orca

Pergunte se o aluno está em **Mac**, **Windows** ou **Linux**.

| SO | Setup esperado | Onde trabalhar |
|---|---|---|
| Mac | instalador `instalar_imersao.sh` | **Orca** (padrão). Ghostty = opcional. |
| Windows | guia `docs/WINDOWS.md` (WSL2) + Orca no Windows | **Orca** + shell Ubuntu (WSL) |
| Linux | core manual + Orca | **Orca** |

**Regra da imersão:** o meio de trabalho padrão é o **[Orca](https://www.onorca.dev/)** — não o Terminal sozinho e não o Ghostty.  
Orca = app de agentes (Claude Code, worktrees) + **app no celular** para usar com o PC em casa.

Se Windows e a pessoa ainda não fez WSL: **pare o tour** e mande o guia  
https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md  
antes de seguir. Não diga que “só Mac serve” — Windows com WSL2 é suportado.

Se o Orca não estiver instalado:

- Mac: `brew install --cask stablyai/orca/orca` ou https://www.onorca.dev/download  
- Windows/Linux: https://www.onorca.dev/download  
- Guia: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/ORCA.md  

Mínimo: 16 GB de RAM. Core: Node + Claude Code (Max) + plugin + Docker rodando + `gh` + **Orca**.

## Passo 1 — Conferir se está tudo instalado

Peça para abrir o **Orca** e, no terminal **dentro do Orca**, colar:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

O check imprime o **perfil** (macOS / Windows/WSL / Linux). No Mac, **Orca** deve estar OK. Ghostty ausente = só aviso.  
**Statusline** e `jq` são core em Mac/WSL/Linux. Se o check marcar X na statusline:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash
```

Confirme o plugin:

```bash
claude plugin list
```

Procure `imersao@imersao-ia`. Se não aparecer:

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

e peça pra fechar e reabrir o Claude Code (de preferência ainda no Orca).

## Passo 2 — Login

Confirme login no Claude (plano Max) rodando `claude` **no Orca**. Sem login, o Claude não responde — o plugin já fica instalado.

## Passo 3 — Celular (recomendado)

Explique em 30 segundos: com o Orca Mobile pareado, o aluno acompanha e manda o agente do telefone com o PC ligado em casa.

1. iOS: App Store / TestFlight · Android: APK — https://www.onorca.dev/download  
2. Pair Desktop no Orca  
3. PC ligado, Orca aberto  

Não force se o aluno não tiver celular agora — marque como “depois do almoço / em casa”. Detalhe: `docs/ORCA.md`.

## Passo 4 — Como as skills funcionam

- **Skills** são manuais que o Claude usa sozinho. Não precisa decorar comandos — descreva em português.
- Ver tudo: `/plugin`. Atualizar: `claude plugin update imersao`.

## Passo 5 — Primeiro exercício prático

1. No Orca: `mkdir ~/meu-primeiro-projeto && cd ~/meu-primeiro-projeto`
2. `claude`
3. Pedir: *"cria um site de uma página de boas-vindas com HTML e CSS e abre no navegador"*.

No Windows, se o browser não abrir sozinho, oriente abrir o arquivo/HTML pelo Windows Explorer a partir da pasta no WSL (`\\wsl$`), ou use o browser embutido do Orca se estiver disponível.

## Passo 6 — Onde achar ajuda

- `docs/ORCA.md` (ambiente padrão + celular)
- `docs/PRIMEIROS-PASSOS.md`
- `docs/WINDOWS.md` (Windows)
- `docs/TROUBLESHOOTING.md`
- Re-checar: `check.sh` do Passo 1
- Mentor da imersão

Encerre reforçando: **trabalhe no Orca**, peça em português, e o pipeline da imersão começa com `/imersao:pg-imersao-start`.
