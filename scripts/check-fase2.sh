#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE2 — invariantes da cobertura de telas no protótipo
#  (pg-imersao-prototipo + toques em start/processo).
#  Garante que TODA tela do plano vira uma tela demonstrável no
#  protótipo, com o mapa-de-telas.md de fio condutor e gate
#  pré-export que nunca trava (dispensa explícita do aluno).
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

PROTO="plugins/imersao/commands/pg-imersao-prototipo.md"
START="plugins/imersao/commands/pg-imersao-start.md"
PROC="docs/PROCESSO-IMERSAO.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasp() { grep -qiE "$1" "$PROTO"; }
hass() { grep -qiE "$1" "$START"; }
hasc() { grep -qiE "$1" "$PROC"; }

for f in "$PROTO" "$START" "$PROC"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 2 ($PROTO) =="
hasp 'mapa-de-telas\.md'          && ok "artefato mapa-de-telas.md existe"          || err "sem artefato mapa-de-telas.md"
hasp 'telas e navega'             && ok "mapa derivado de 'Telas e navegação'"      || err "mapa não deriva de 'Telas e navegação'"
hasp 'mapa vazio'                 && ok "nunca segue com mapa vazio (edge Fluxos)"  || err "sem guarda de mapa vazio"
hasp 'toda tela do mapa'          && ok "roadmap: toda tela atribuída a uma seção"  || err "product-vision sem restrição de cobertura"
hasp 'sem pular'                  && ok "loop percorre todas as seções"             || err "loop não explicita todas as seções"
hasp 'demonstr'                   && ok "cada tela demonstrável no navegador"       || err "sem exigência de tela demonstrável"
hasp 'tela nova'                  && ok "mapa vivo (tela nova na revisão entra)"    || err "sem mapa vivo na revisão"
hasp 'passo 0'                    && ok "gate de cobertura é Passo 0 do export"     || err "sem gate pré-export"
hasp 'desenhar agora'             && ok "faltante: oferece desenhar agora"          || err "sem oferta de desenhar na hora"
hasp 'dispensad'                  && ok "faltante: dispensa explícita registrada"   || err "sem caminho de dispensa explícita"
hasp 'em aberto / futuro'         && ok "dispensa anotada no plano do produto"      || err "dispensa não volta pro plano"
hasp 'sem pausa extra'            && ok "100% coberto passa sem fricção"            || err "sem regra de zero fricção"

echo ""
echo "== Toque na bússola ($START) =="
hass 'todas as telas do plano'    && ok "bússola anuncia a cobertura"               || err "bússola não anuncia a cobertura"

echo "== Toque no guia do processo ($PROC) =="
hasc 'mapa de telas'              && ok "guia descreve o mapa de telas"             || err "guia não descreve o mapa de telas"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 2 OK"; else echo "✗ Fase 2 com problemas (veja acima)"; fi
exit "$fail"
