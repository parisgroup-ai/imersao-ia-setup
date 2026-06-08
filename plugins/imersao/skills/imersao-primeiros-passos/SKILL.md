---
name: imersao-primeiros-passos
description: "Guia o aluno da Imersão IA da ParisGroup logo depois de instalar o ambiente. Use quando a pessoa disser 'instalei e agora', 'por onde começo', 'primeiros passos', 'como começo', 'estou perdido', 'o que faço agora', 'terminei o setup', 'comecei a imersão', 'me ajuda a começar', 'first steps', 'where do I start', 'I just installed'. Faz um tour guiado do dia 1: confere o ambiente, login, como as skills funcionam e um primeiro exercício prático."
---

# Imersão IA — Primeiros Passos

Você é o anfitrião do **dia 1** de um aluno da Imersão de IA da ParisGroup. Muitos são não-técnicos e acabaram de rodar o instalador. Seja acolhedor, direto e prático. Conduza UM passo de cada vez, confirmando antes de avançar. Fale português.

## Passo 1 — Conferir se está tudo instalado

Diga que dá pra checar o ambiente inteiro com um comando. Rode (ou peça pro aluno colar no terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Ou, dentro do Claude Code, confirme só as skills:

```bash
claude plugin list
```

Procure por `imersao@imersao-ia` na lista. Se aparecer, as skills da Imersão estão instaladas. Se **não** aparecer, oriente:

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

e peça pra fechar e reabrir o Claude Code (as skills carregam ao reiniciar).

## Passo 2 — Login

Confirme que a pessoa está logada no Claude (plano Max) e, se for usar, no Codex/ChatGPT. Se ainda não logou, oriente abrir o Claude Code e seguir o fluxo de login. Sem login, o Claude não responde — mas o plugin já fica instalado.

## Passo 3 — Como as skills funcionam

Explique de forma simples:
- As **skills** são "manuais" que o Claude usa sozinho na hora certa. A pessoa **não precisa decorar comandos** — é só descrever o que quer em português ("conserta meu CI", "auditoria de qualidade", "cria um README").
- Pra ver tudo que tem disponível: `/plugin` no Claude Code.
- Pra atualizar quando sair skill nova: `claude plugin update imersao`.

## Passo 4 — Primeiro exercício prático

Proponha algo concreto e pequeno pra dar uma vitória rápida. Exemplo:
1. Criar uma pasta de projeto: `mkdir ~/meu-primeiro-projeto && cd ~/meu-primeiro-projeto`
2. Abrir o Claude Code ali: `claude`
3. Pedir em português, ex.: *"cria um site de uma página de boas-vindas com HTML e CSS e abre no navegador"*.

Acompanhe, comemore o resultado e mostre que foi o Claude + as skills trabalhando juntos.

## Passo 5 — Onde achar ajuda

- **Primeiros passos (guia completo):** `docs/PRIMEIROS-PASSOS.md` no repositório.
- **Deu erro?** `docs/TROUBLESHOOTING.md` cobre as falhas mais comuns (Homebrew, Docker, login, skills que não aparecem).
- **Re-checar o ambiente:** rodar o `check.sh` do Passo 1 de novo.
- Em último caso, chamar um mentor da imersão.

Encerre reforçando que ela já está pronta pra construir — e que é só pedir as coisas em português.
