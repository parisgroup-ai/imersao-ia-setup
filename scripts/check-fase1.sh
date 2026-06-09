#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE1 — invariantes do comando da Fase 1 (pg-imersao-prd)
#  Garante que o redesenho (pesquisa de mercado + direções + modos)
#  está presente e não regride. Só bash; roda em CI e localmente.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

F="plugins/imersao/commands/pg-imersao-prd.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
has() { grep -qiE "$1" "$F"; }

[ -f "$F" ] || { echo "✗ faltando: $F"; exit 1; }

echo "== Invariantes da Fase 1 ($F) =="
has 'pesquis[a-z]* (de )?mercado'            && ok "pesquisa de mercado"            || err "sem pesquisa de mercado"
has 'WebSearch'                              && ok "usa busca real (WebSearch)"     || err "sem WebSearch (busca real)"
has 'fonte'                                  && ok "cita fontes"                    || err "não cita fontes"
{ has 'vender' && has 'economiz|otimiz'; }   && ok "duas lentes de valor"           || err "falta lente vender/economizar"
{ has 'direç'  && has 'recomend'; }          && ok "direções + recomendação"        || err "sem direções/recomendação"
has 'refut|cétic'                            && ok "passo cético"                   || err "sem passo cético"
{ has 'ideia nova' && has 'analisar|construir ou melhorar'; } && ok "modos greenfield/brownfield" || err "sem detecção de contexto"
has 'pesquisa-de-mercado\.md'                && ok "artefato pesquisa-de-mercado.md" || err "sem artefato de pesquisa"
has 'plano-do-produto\.md'                   && ok "artefato plano-do-produto.md"   || err "sem plano-do-produto.md"
has 'Por que vale a pena'                    && ok "seção 'Por que vale a pena'"    || err "sem seção de valor no plano"
has 'chute|não consegui pesquisar'           && ok "fallback sem internet"          || err "sem fallback de pesquisa"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 1 OK"; else echo "✗ Fase 1 com problemas (veja acima)"; fi
exit "$fail"
