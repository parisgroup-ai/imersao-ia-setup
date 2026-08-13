# Comandos do terminal

Os únicos comandos essenciais da imersão. Não digite o `$`.

## Entrar na pasta

```bash
cd (arraste a pasta aqui)
```

ou

```bash
cd ~/founders-ai
```

## Onde estou e o que tem aqui

```bash
pwd
```

Mostra a pasta atual. No Windows, se começar com `/mnt/c`, você está no lugar errado. Ver [[Windows]].

```bash
ls
```

Lista arquivos e pastas.

## Git, só para reconhecer

```bash
git status
```

Mostra o que mudou.

```bash
git diff
```

Mostra o conteúdo das mudanças.

## Claude

```bash
claude --version
```

Confere se está instalado.

```bash
claude
```

Abre o Claude Code dentro da pasta.

## Olhos no navegador (uma vez)

```bash
claude mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest
```

## Conferir o ambiente

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash
```

## Instalador (Mac)

```bash
curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash
```

Se aparecer algo que você não entendeu: copie a mensagem (sem senha) e mostre ao Claude. Não continue no escuro.

Ver: [[Terminal e Mac]] · [[Se travou]]
