# Primeiros Passos — Imersão IA

Você rodou o instalador e a barra encheu. E agora? Siga estes passos.

> Dica: dentro do Claude Code você pode só pedir **"primeiros passos"** ou **"instalei e agora"** — a skill `imersao-primeiros-passos` te guia interativamente.

## 1. Abra um terminal novo

Feche o terminal atual e abra de novo (de preferência o **Ghostty**, que o instalador instalou). Isso carrega o `PATH` atualizado — sem isso, comandos como `claude` e `brew` podem "não existir".

## 2. Confira que está tudo instalado

Cole no terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

Tudo verde = pronto. Algo vermelho? Veja o [TROUBLESHOOTING](./TROUBLESHOOTING.md).

## 3. Faça login no Claude

Abra o Claude Code:

```bash
claude
```

Na primeira vez ele pede login — siga o fluxo (plano **Max**). Sem login, o Claude não responde. As skills já ficam instaladas independentemente do login.

## 4. Confirme as skills

Dentro do Claude Code:

```text
/plugin
```

Você deve ver **`imersao@imersao-ia`** na lista. Se não aparecer, instale:

```text
/plugin marketplace add parisgroup-ai/imersao-ia-setup
/plugin install imersao@imersao-ia
```

e reinicie o Claude Code (as skills carregam ao reiniciar).

## 5. Seu primeiro projeto

```bash
mkdir ~/meu-primeiro-projeto && cd ~/meu-primeiro-projeto
claude
```

Aí é só pedir em português, por exemplo:

> *"cria um site de uma página de boas-vindas com HTML e CSS e abre no navegador"*

Você **não precisa decorar comandos nem nomes de skill** — descreva o que quer e o Claude usa a skill certa sozinho ("conserta meu CI", "auditoria de qualidade", "cria um README", "roda os testes").

## 6. Construindo seu app de verdade (o projeto da imersão)

O hello-world acima é só pra sentir o Claude Code. Pra construir o **app da imersão** —
da ideia até um app funcionando, com banco de dados — existe um caminho guiado em **3
passos**. Comece criando a pasta do seu app e abrindo o Claude nela:

```bash
mkdir ~/meu-app && cd ~/meu-app
claude
```

Dentro do Claude, rode a **bússola** (digite `/` e escolha na lista, não precisa decorar):

```text
/imersao:pg-imersao-start
```

Ela mostra os 3 passos (**definir → desenhar → construir**) e te diz exatamente o próximo
— sem fazer por você (quem constrói é você, pra aprender a lógica). Roteiro completo:
[PROCESSO-IMERSAO.md](./PROCESSO-IMERSAO.md).

## 7. Atualizando as skills depois

Saiu skill nova durante a imersão? Atualize com:

```bash
claude plugin update imersao
```

(ou `/plugin` → update). Reinicie o Claude Code pra carregar.

---

**Travou em algo?** → [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) · ou chame um mentor. Bom proveito! 🚀
