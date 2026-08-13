# Guia 3 — encontrar o projeto no GitHub e no Railway

## GitHub

1. Entre em [github.com](https://github.com) → **Sign in**.
2. Esqueceu a senha? **Forgot password** e siga o e-mail.
3. Clique na foto de perfil → **Your repositories**.
4. Cada projeto tem um endereço: `github.com/seu-usuario/nome-do-projeto`.

## Railway

1. Entre em [railway.app](https://railway.app) com a conta do GitHub.
2. Clique no projeto → serviço principal.
3. **Settings → Networking**.
4. Endereço `*.up.railway.app` = link do produto.
5. Se não houver, **Generate Domain**.

Por que isso existe (prova, uso, manutenção): [[Por que publicar]].

## Antes de qualquer push

1. Abra `docs/o-que-e-real.md`.
2. Compare com a interface.
3. Peça ao Claude: “liste o que neste projeto é sensível e não deveria ser publicado.”
4. `.env` nunca vai para o Git. `.env.example` só tem os **nomes** das variáveis.

Se houver suspeita de segredo no repositório: pare, avise a facilitação e troque a chave.

Ver: [[GitHub]] · [[Railway]] · [[Seguranca dos dados]] · [[Modelo o-que-e-real]]
