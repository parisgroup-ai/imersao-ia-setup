---
description: Fase 2 da imersão — vira o PRD em protótipo funcional no Design OS público (setup automático).
---

# /imersao:pg-imersao-prototipo — Fase 2: PRD → protótipo

Objetivo: a partir do `docs/PRD.md`, **montar e subir o Design OS público sozinho**
(o aluno não cola bloco nenhum) e então conduzir o design até o protótipo aprovado.

## Narração didática (Fase 2)

Automatize o setup (clone/install/server) **sem** narrar a sintaxe, mas explique o
**porquê** em 1 linha simples, na primeira vez:

| Conceito | Diga assim |
|---|---|
| protótipo | "Um protótipo é um rascunho clicável das suas telas — a gente valida o visual ANTES de construir de verdade, porque é muito mais barato mudar um desenho do que um app pronto." |
| Design OS | "O Design OS é uma ferramenta de desenho de telas: você conversa, ele desenha, e você vê na hora no navegador." |

## 1. Pré-condições

- Exija **`docs/PRD.md`**. Se faltar, peça `/imersao:pg-imersao-prd` antes e pare.
- A partir da pasta do app, derive a pasta-irmã do design (mantenha o `cwd` na raiz do
  app o tempo todo — **nunca** use `cd` solto; prefira `git -C`/`npm --prefix`):

  ```bash
  APP="$(basename "$PWD")"; DESIGN_DIR="../${APP}-design"; echo "design em: $DESIGN_DIR"
  ```

## 2. Setup automático (VOCÊ executa via Bash — não mande o aluno colar)

1. **Clonar com guarda idempotente** (trata os 3 casos: já clonado / pasta parcial / não existe):
   ```bash
   if [ -d "$DESIGN_DIR/.git" ]; then
     echo "Design OS já clonado — pulando clone."
   elif [ -d "$DESIGN_DIR" ]; then
     echo "ERRO: $DESIGN_DIR existe mas não é um repo git (clone anterior interrompido). Apague a pasta e rode de novo."; exit 1
   else
     git clone https://github.com/buildermethods/design-os.git "$DESIGN_DIR"
   fi
   git -C "$DESIGN_DIR" remote remove origin 2>/dev/null || true
   ```
2. **Instalar dependências** só se faltar `node_modules` (pode levar 1–2 min — espere terminar):
   ```bash
   [ -d "$DESIGN_DIR/node_modules" ] || npm --prefix "$DESIGN_DIR" install
   ```
3. **Levar o PRD** pra dentro da pasta do design:
   ```bash
   cp docs/PRD.md "$DESIGN_DIR/PRD.md"
   ```
4. **Subir o dev server DESTACADO** (sobrevive a fechar qualquer janela do Claude — use
   `nohup`, **não** o background do Bash do Claude):
   ```bash
   nohup npm --prefix "$DESIGN_DIR" run dev > "$DESIGN_DIR/dev.log" 2>&1 &
   echo $! > "$DESIGN_DIR/.dev-server.pid"
   ```
5. **Descobrir a porta real e confirmar que subiu.** O Design OS usa 3000 por padrão,
   mas se estiver ocupada ele sobe em outra (ex.: 3001) — **leia a porta do log**, não
   assuma 3000:
   ```bash
   sleep 4
   URL="$(grep -oE 'http://localhost:[0-9]+' "$DESIGN_DIR/dev.log" | head -1)"
   URL="${URL:-http://localhost:3000}"
   for i in $(seq 1 30); do c=$(curl -s -o /dev/null -w '%{http_code}' "$URL"); [ "$c" = "200" ] && break; sleep 2; done
   echo "$URL -> $c"
   ```
   - Se `$c` ≠ 200 depois do loop, mostre o fim do log pro aluno entender o erro:
     `tail -30 "$DESIGN_DIR/dev.log"`.
6. **Abrir no navegador** (macOS): `open "$URL"`.

## 3. Conduza o design — NESTA mesma sessão (NÃO abra um 2º Claude)

O pulo do gato: **você (Claude) faz o trabalho de design daqui mesmo, na sessão do app.**
O aluno conversa com **você** o tempo todo — **não** mande ele abrir uma segunda sessão
do Claude. (O único terminal extra possível é o do servidor, que já subiu sozinho.)

**Como:** os comandos do Design OS (`product-vision`, `design-screen`…) são **arquivos de
prompt** dentro do clone, em `$DESIGN_DIR/.claude/commands/` (procure a pasta `design-os`).
**Leia cada arquivo e execute as instruções você mesmo**, escrevendo os arquivos de
design onde o comando manda, dentro de `$DESIGN_DIR`. O servidor (já no ar) renderiza ao
vivo a cada arquivo.

⚠️ **Pra NÃO dar tela em branco:** siga o formato dos arquivos do Design OS **à risca**
(nomes de pasta/seção, estrutura, manifestos). **Não improvise** o formato — o
renderizador dele é exigente. Na dúvida, releia o arquivo de comando correspondente no
clone antes de escrever.

Siga a sequência (lendo o comando no clone antes de cada etapa), **narrando em 1 linha**:
visão do produto → roadmap → modelo de dados → tokens → shell → telas (uma por seção) →
dados de exemplo.

> Se o servidor cair, o aluno reabre num terminal com `npm --prefix <DESIGN_DIR> run dev`
> — isso é só o **servidor**, nunca um 2º Claude. Pra pará-lo:
> `kill $(cat <DESIGN_DIR>/.dev-server.pid)`.

## 4. Revisar e ajustar — na mesma conversa, em tempo real

🛑 **Gate:** o aluno olha a **aba do navegador** e pede mudanças em **linguagem natural**
("aumenta o card", "tira esse campo") **aqui mesmo, falando com você**. Você reescreve o
arquivo da tela afetada e o servidor recarrega na hora. **Nunca** regenere telas já
aprovadas. Loop até o aluno aprovar.

## 5. Exportar e seguir

- Aprovado? Execute o **export** do Design OS (leia o arquivo de comando de export no
  clone e siga) → o pacote (componentes React + Tailwind + specs) fica em
  `$DESIGN_DIR/export/` (ou `design/product-plan.zip`). Confirme que existe e diga o
  caminho real ao aluno.
- **Próximo passo:** você já está na sessão do app — é só rodar
  **`/imersao:pg-imersao-implementar`** (ou pedir o próximo passo, ou `/imersao:pg-imersao-start`).
