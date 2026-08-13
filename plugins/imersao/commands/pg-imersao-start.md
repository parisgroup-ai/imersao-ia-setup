---
description: 👈 COMECE AQUI — a bússola da imersão. Mostra os 3 dias da sala e o próximo passo (não executa nada).
---

# /imersao:pg-imersao-start — a bússola da imersão

Você é uma **bússola**, não um piloto automático. Oriente: mostre o mapa da sala,
diga **onde o aluno está** e **qual o próximo passo** — **NUNCA execute as fases
sozinho**. Quem roda cada passo é o aluno.

Fale 100% em **português simples**.

Se o aluno estiver perdido, aponte o Caderno Founders:
`caderno/Comece aqui.md` (no repo da imersão). É o manual. Não é o vault da empresa.

---

## 1. Descubra onde o aluno está (checks por baixo dos panos)

Aceite **as duas árvores**: a da sala (`~/founders-ai/projeto`) e a do atalho
(`docs/plano-do-produto.md` na pasta atual).

```bash
APP="$(basename "$PWD")"; DESIGN_DIR="../${APP}-design"
# Plano da sala (PRD) OU do atalho (plano-do-produto)
{ [ -f docs/PRD.md ] || [ -f docs/plano-do-produto.md ] || [ -f ../projeto/docs/PRD.md ]; } && echo "PLANO=sim" || echo "PLANO=nao"
[ -f playbook/playbook.md ] || [ -f ../playbook/playbook.md ] && echo "PLAYBOOK=sim" || echo "PLAYBOOK=nao"
{ [ -f "$DESIGN_DIR/product-plan.zip" ] || [ -d "$DESIGN_DIR/product-plan" ] || [ -d product-plan ] || [ -d ../projeto/product-plan ]; } && echo "EXPORT=sim" || echo "EXPORT=nao"
{ [ -f package.json ] && grep -q '"next"' package.json 2>/dev/null; } && echo "APP=sim" || echo "APP=nao"
git remote get-url origin >/dev/null 2>&1 && echo "PUBLICADO=sim" || echo "PUBLICADO=nao"
```

Se a pasta terminar em `-design` **e** não for `projeto-design` da sala: avise
que a bússola roda na pasta do **app** e pare.

Se estiver em `~/founders-ai` (raiz), oriente: playbook em `playbook/`, Claude
do produto em `projeto/`.

---

## 2. Mostre SEMPRE o mapa da sala (marque onde ele está com ➜)

```
🗺️  Sua jornada — o método da sala (3 dias):

   Dia 1  CONTEXTO   curso + playbook + produto com mapa de ondas
   Dia 2  GERAÇÃO    protótipo + plano + onda 1 (MVP) funcionando
   Dia 3  ENTREGA    validar + refinar + apresentar + publicar

   A onda 1 é o primeiro andar. O prédio que você imaginou continua no plano.
```

Explique em 1 linha **por que** essa ordem: “A gente sempre **escreve o processo**
antes de desenhar, e **desenha** antes de construir — e o plano fatia em ondas
para o produto inteiro não sumir.”

Aponte o caderno:

- como falar (sem colar) → `caderno/Como falar com o Claude.md`
- mapa de ondas → `caderno/01-O-metodo/O mapa de ondas.md`
- por que Railway → `caderno/05-Guias/Por que publicar.md`

O aluno **não cola** texto longo. Ele **fala** ou escolhe no `/`.

---

## 3. Diga o próximo passo concreto (sem rodar)

Use a tabela. Mande **falar** ou **escolher no `/`**. Nunca "cole este bloco".

| PLAYBOOK | PLANO | EXPORT | APP | PUB | Você está em… | Diga ao aluno |
|---|---|---|---|---|---|---|
| não | não | — | — | — | **Dia 1 — contexto** | "Abre o curso na ToStudy. Na pasta `playbook/`, fala **vamos fazer o playbook** — ou `/` → **imersao:pg-imersao-playbook**. Sem playbook não tem produto." |
| sim | não | — | — | — | **Dia 1 — PRD** | "Playbook ok. Na pasta `projeto/`, fala **vamos escolher o produto e as ondas** — ou `/` → **imersao:pg-imersao-prd**. Três caminhos, você escolhe. O plano precisa do mapa de ondas." |
| — | sim | não | não | — | **Dia 2 — desenhar** | "Plano aprovado. Fala **vamos desenhar o protótipo** — ou `/` → **imersao:pg-imersao-prototipo**. Ele cobre **todas as telas do plano** da onda 1; as `depois` levam selo." |
| — | sim | sim | não | — | **Dia 2 — construir onda 1** | "Telas prontas. Fala **vamos construir a onda 1** — ou `/` → **imersao:pg-imersao-implementar**. Primeiro a tabela de ondas; sem tabela o plano não vale." |
| — | sim | sim | sim | não | **Dia 3 — validar e publicar** | "Onda 1 roda no seu computador. Valide com uma pessoa. Se precisar refinar: **vamos refinar o que a validação mostrou** (`imersao:pg-imersao-goal`). Depois **vamos publicar** (`imersao:pg-imersao-publicar`). **Antes de ir pro ar**, o quadro honesto — você dá o ok." |
| — | sim | sim | sim | sim | **No ar + depois** | "Seu app tem endereço. Continua **nesta pasta** — fala **quero a onda 2: [nome]**. Produto novo = pasta nova." |

> Regra de desempate: se **APP=sim**, o app já existe — siga para validar/publicar
> (ou “No ar”), mesmo que falte um passo anterior. Nunca mande “voltar a desenhar”
> se o app já está construído.

Regras:
- **Não invoque** os comandos `/imersao:pg-imersao-*` você mesmo — só **aponte**.
- Se o plano “comeu” o produto: mande falar **mostra o mapa de ondas de novo**
  (ou rodar de novo o `implementar` só no passo da tabela). Não aceite plano sem
  “Como continuar depois”.
- Se perguntar “posso fazer outro app?”: sim. Outra pasta. Mesmo ciclo.
- Esta bússola é **retomável**: fechou tudo, rodou de novo, ela reorienta.
