#!/usr/bin/env bash
# ============================================================
#  CHECK-FASE4 — invariantes do gate de honestidade pré-publicar
#  (pg-imersao-publicar + toques em start/processo).
#  Garante que nada vai pro ar sem o aluno ver o quadro honesto
#  (real × demonstração) do docs/o-que-e-real.md.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

PUB="plugins/imersao/commands/pg-imersao-publicar.md"
START="plugins/imersao/commands/pg-imersao-start.md"
PROC="docs/PROCESSO-IMERSAO.md"
fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }
hasu() { grep -qiE "$1" "$PUB"; }
hass() { grep -qiE "$1" "$START"; }
hasc() { grep -qiE "$1" "$PROC"; }

for f in "$PUB" "$START" "$PROC"; do
  [ -f "$f" ] || { echo "✗ faltando: $f"; exit 1; }
done

echo "== Invariantes da Fase 4 ($PUB) =="
hasu 'o-que-e-real\.md'                     && ok "lê o registro o-que-e-real.md"      || err "não lê o registro o-que-e-real.md"
hasu 'passo 0'                              && ok "gate é o Passo 0 (antes do GitHub)" || err "sem Passo 0 antes do GitHub"
hasu 'reconstru|escanea'                    && ok "reconstrói registro ausente"        || err "não reconstrói registro ausente"
hasu 'diverg'                               && ok "verifica registro × realidade"      || err "sem verificação registro × realidade"
hasu 'publicar assim'                       && ok "saída 1: publicar assim mesmo"      || err "sem saída publicar-assim-mesmo"
hasu 'ativar a chave'                       && ok "saída 2: ativar a chave agora"      || err "sem saída ativar-a-chave"
hasu 'segurar'                              && ok "saída 3: segurar a publicação"      || err "sem saída segurar"
hasu 'nunca (mostre|ecoe).*(valor|chave)'   && ok "valor da chave nunca ecoado"        || err "não proíbe ecoar o valor da chave"
hasu 'herda'                                && ok "Variables herda a decisão do gate"  || err "Variables não herda a decisão do gate"
hasu 'atualiz[a-z]*.*registro'              && ok "registro atualizado pós-deploy"     || err "sem atualização pós-deploy do registro"
hasu 'selo'                                 && ok "demo no ar mantém o selo"           || err "sem linguagem do selo"

echo ""
echo "== Toque na bússola ($START) =="
hass 'antes de ir pro ar'                   && ok "bússola anuncia o gate"             || err "bússola não anuncia o gate"

echo "== Toque no guia do processo ($PROC) =="
hasc 'antes de publicar, a honestidade'     && ok "guia descreve o gate"               || err "guia não descreve o gate"

echo ""
if [ "$fail" -eq 0 ]; then echo "✓ Fase 4 OK"; else echo "✗ Fase 4 com problemas (veja acima)"; fi
exit "$fail"
