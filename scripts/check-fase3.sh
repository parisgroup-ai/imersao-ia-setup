#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE3 — invariantes da honestidade de funcionalidade
#  (pg-imersao-implementar + toques em prd/publicar).
#  Garante que o contrato "real ou demonstração explícita" e o
#  caminho da chave de API estão presentes e não regridem.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

IMPL="plugins/imersao/commands/pg-imersao-implementar.md"
PRD="plugins/imersao/commands/pg-imersao-prd.md"
PUB="plugins/imersao/commands/pg-imersao-publicar.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasi() { grep -qiE "$1" "$IMPL"; }
hasp() { grep -qiE "$1" "$PRD"; }
hasu() { grep -qiE "$1" "$PUB"; }

for f in "$IMPL" "$PRD" "$PUB"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 3 ($IMPL) =="
hasi 'Conexões de fora'                    && ok "lê Conexões de fora do plano"     || err "não lê Conexões de fora"
hasi 'chave de API'                        && ok "explica a chave de API"           || err "sem chave de API"
hasi 'separad[a-z]* da (sua )?assinatura'  && ok "chave ≠ assinatura do Claude"     || err "não separa chave de assinatura"
hasi 'centavos'                            && ok "custo honesto (centavos por uso)" || err "sem custo honesto"
hasi 'criar agora|console\.anthropic\.com' && ok "caminho guiado de criar a chave"  || err "sem caminho guiado da chave"
hasi 'modo demonstração'                   && ok "modo demonstração explícito"      || err "sem modo demonstração"
hasi 'selo'                                && ok "selo de demonstração na tela"     || err "sem selo de demonstração"
hasi 'silencios'                           && ok "proíbe simulação silenciosa"      || err "não proíbe simulação silenciosa"
hasi 'ANTHROPIC_API_KEY'                   && ok "variável ANTHROPIC_API_KEY"       || err "sem ANTHROPIC_API_KEY"
hasi '\.gitignore'                         && ok "garante .env no .gitignore"       || err "sem regra .env/.gitignore"
hasi '@anthropic-ai/sdk'                   && ok "SDK oficial"                      || err "sem SDK oficial"
hasi 'haiku'                               && ok "modelo barato por padrão"         || err "sem modelo barato padrão"
hasi 'o-que-e-real\.md'                    && ok "registro o-que-e-real.md"         || err "sem registro o-que-e-real.md"
hasi 'stripe'                              && ok "pagamento via Stripe modo teste"  || err "sem padrão de pagamento"

echo ""
echo "== Toques na Fase 1 ($PRD) =="
hasp 'chave'                               && ok "plano avisa da chave"             || err "Fase 1 não avisa da chave"
hasp 'centavos'                            && ok "plano menciona o custo"           || err "Fase 1 sem custo aproximado"

echo "== Toques na Fase 4 ($PUB) =="
hasu 'ANTHROPIC_API_KEY'                   && ok "variável no Railway"              || err "Fase 4 sem ANTHROPIC_API_KEY"
hasu 'modo demonstração'                   && ok "narra status demonstração"        || err "Fase 4 sem status demonstração"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 3 OK"; else echo "✗ Fase 3 com problemas (veja acima)"; fi
exit "$fail"
