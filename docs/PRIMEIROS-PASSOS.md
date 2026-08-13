# Primeiros Passos — Imersão IA

Você rodou o instalador (Mac) **ou** o guia Windows. E agora? Siga estes passos.

> Dica: dentro do Claude Code você pode só pedir **"primeiros passos"** ou **"instalei e agora"** — a skill `imersao-primeiros-passos` te guia interativamente.

## 0. Qual SO você usa?

| SO | Setup | Onde trabalhar no dia a dia |
|---|---|---|
| **macOS** | `instalar_imersao.sh` | **Orca** (padrão). Ghostty = terminal opcional. |
| **Windows** | [WINDOWS.md](./WINDOWS.md) (WSL2) + Orca desktop | **Orca** + shell Ubuntu (WSL) |
| **Linux** | Manual (core) + Orca | **Orca** |

Mínimo: **16 GB de RAM**.  
Core do D1: Node + Claude Code logado + plugin imersão + Docker rodando + `gh` + Railway + **Orca**.

Guia do ambiente padrão: **[ORCA.md](./ORCA.md)** · site: https://www.onorca.dev/

## 1. Abra o Orca (não só o Terminal)

1. Abra o app **Orca** no computador.  
2. Se o instalador acabou de rodar no **Mac**, feche e reabra o Orca (ou um terminal novo) para carregar o `PATH` — sem isso, `claude` e `brew` podem "não existir".  
3. **Windows:** core no **Ubuntu (WSL)**; o app Orca roda no Windows e é o “escritório” da imersão.  
4. No terminal **dentro do Orca**, confira:

```bash
claude --version
```

Ghostty no Mac é opcional — se preferir shell puro, ok, mas **em sala usamos Orca**.

## 2. Confira que está tudo instalado

Cole no terminal (Mac, WSL ou Linux — preferencialmente no Orca):

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

O check mostra o **perfil** (macOS / Windows/WSL / Linux). Tudo verde no core (incl. **statusline**) + Orca no Mac = pronto.  
Statusline com X? `curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash`  
Algo vermelho? [TROUBLESHOOTING](./TROUBLESHOOTING.md) · Windows: [WINDOWS.md](./WINDOWS.md) · Orca: [ORCA.md](./ORCA.md).

## 3. Faça login no Claude (dentro do Orca)

No terminal do Orca:

```bash
claude
```

Na primeira vez ele pede login — siga o fluxo. **Assine o Claude Max $200/mês antes do dia 1** — o plano gratuito não aguenta a imersão. Sem login, o Claude não responde; as skills já ficam instaladas independentemente do login.

> Você também vai precisar de uma conta no **GitHub** (grátis — autentique com `gh auth login`) e uma no **Railway** (Hobby **$5/mês**, exige cartão; o Trial grátis sem cartão dá pra testar o deploy) — é onde, no último passo, seu app sobe e vai pro ar. Crie as duas antes de começar.

## 4. Celular (recomendado na imersão)

Para usar o **computador em casa** e o **celular** para acompanhar/mandar o agente:

1. Instale o **Orca Mobile**  
   - iOS: [App Store](https://apps.apple.com/us/app/orca-ide/id6766130217) ou [TestFlight](https://testflight.apple.com/join/YjeGMQBA)  
   - Android: APK em https://www.onorca.dev/download  
2. No desktop Orca, use **Pair Desktop** / emparelhar.  
3. Escaneie o QR no celular.  
4. Deixe o PC ligado e o Orca aberto.

Passo a passo: [ORCA.md](./ORCA.md#app-no-celular-companion).

## 5. Setup oficial, depois skills da imersão

**Ordem:** login no Claude → (opcional) plugin oficial de **Claude Code Setup** no marketplace Anthropic → **só então** o plugin `imersao@imersao-ia`.  
Não instale dezenas de plugins aleatórios; na imersão a lista curta é: imersão (+ GitHub se o instrutor pedir).

Dentro do Claude Code:

```text
/plugin
```

Você deve ver **`imersao@imersao-ia`** na lista. Se não aparecer, instale:

```text
/plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

e reinicie o Claude Code (as skills carregam ao reiniciar).

## 6. Seu primeiro projeto

No Orca, abra um terminal na pasta do projeto (ou crie a pasta e abra no Orca):

```bash
mkdir ~/meu-primeiro-projeto && cd ~/meu-primeiro-projeto
claude
```

Aí é só pedir em português, por exemplo:

> *"cria um site de uma página de boas-vindas com HTML e CSS e abre no navegador"*

Você **não precisa decorar comandos nem nomes de skill** — descreva o que quer e o Claude usa a skill certa sozinho ("conserta meu CI", "auditoria de qualidade", "cria um README", "roda os testes").

## 7. Construindo seu app de verdade (o projeto da imersão)

O hello-world acima é só pra sentir o Claude Code. O app da imersão segue o
**método da sala** (3 dias): playbook → PRD com ondas → protótipo → onda 1 → validar
→ no ar.

Pasta da turma:

```bash
mkdir -p ~/founders-ai/{playbook,projeto,projeto-design}
cd ~/founders-ai/projeto
claude
```

Manual: [`caderno/Comece aqui.md`](../caderno/Comece%20aqui.md).
Como falar (sem colar): [`caderno/Como falar com o Claude.md`](../caderno/Como%20falar%20com%20o%20Claude.md).

Dentro do Claude, a **bússola** (digite `/` e escolha):

```text
/imersao:pg-imersao-start
```

Ela mostra os 3 dias e o próximo passo — sem fazer por você. Roteiro:
[PROCESSO-IMERSAO.md](./PROCESSO-IMERSAO.md).

## 8. Atualizando as skills depois

Saiu skill nova durante a imersão? Atualize com:

```bash
claude plugin update imersao
```

(ou `/plugin` → update). Reinicie o Claude Code pra carregar.

---

**Travou em algo?** → [ORCA.md](./ORCA.md) · [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) · ou chame um mentor. Bom proveito! 🚀
