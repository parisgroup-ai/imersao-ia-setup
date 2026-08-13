# Ambiente e instalação

Antes de tudo: notebook com **16 GB de RAM ou mais** e uns 20 GB livres.

## Contas (crie antes do Dia 1)

- [Claude](https://claude.ai) — plano Max. O gratuito não aguenta a imersão.
- [GitHub](https://github.com/signup) — grátis.
- [Railway](https://railway.app) — Hobby, com cartão. Trial serve para testar o deploy.

## macOS (caminho ouro)

No Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

O instalador coloca, entre outras coisas: Git, Homebrew, Node, GitHub CLI, **Orca**, Docker, Obsidian, Claude Code, plugin da imersão.

Pode pedir a senha do Mac. Ele pula o que já está instalado.

## Conferir (qualquer sistema)

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Tudo verde no core + Orca no Mac = pronto. Algo vermelho: [[Se travou]].

## Depois do instalador

1. Abra o **Orca** (não só o Terminal).
2. Feche e reabra se o instalador acabou de rodar — senão o `PATH` fica velho.
3. No terminal do Orca: `claude --version`, depois `claude` e faça o login.
4. Autentique o GitHub: `gh auth login`.

## Windows

Siga o guia do repositório: [docs/WINDOWS.md](https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md).

Resumo: WSL2 + Ubuntu. Projeto em `~/founders-ai` **dentro do Linux**. Orca no Windows. Detalhe: [[Windows]].

## Linux

Sem instalador one-shot. Core à mão + Orca + mentor se travar.

## Pasta de trabalho

```text
~/founders-ai/
├── playbook/          # rotina real
├── projeto/           # PRD, export, plano, app e provas
└── projeto-design/    # Design OS
```

Estrutura completa: [[Pasta do projeto]].
