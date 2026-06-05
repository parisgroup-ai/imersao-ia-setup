#!/usr/bin/env bash
# ============================================================
#  VALIDATE — manifestos do marketplace/plugin + frontmatter das skills
#  Sem dependências externas (só bash). Roda em CI e localmente.
# ============================================================
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." || exit 2

fail=0
err() { echo "  ✗ $1"; fail=1; }

echo "== Manifestos =="
for f in .claude-plugin/marketplace.json plugins/imersao/.claude-plugin/plugin.json; do
  if [ ! -f "$f" ]; then err "faltando: $f"; continue; fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null \
      && echo "  ✓ JSON válido: $f" || err "JSON inválido: $f"
  elif [ -n "${CI:-}" ]; then
    err "python3 ausente — não dá pra validar o JSON em CI: $f"
  else
    echo "  • (python3 ausente, pulando checagem de JSON) $f"
  fi
done

echo ""
echo "== Skills =="
count=0; bad=0
for d in plugins/imersao/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  f="${d}SKILL.md"
  count=$((count + 1))
  if [ ! -f "$f" ]; then err "sem SKILL.md: $name"; bad=$((bad + 1)); continue; fi
  fm="$(awk 'NR==1&&/^---/{f=1;next} f&&/^---/{exit} f{print}' "$f")"
  echo "$fm" | grep -q '^name:' || { err "sem 'name': $name"; bad=$((bad + 1)); }
  echo "$fm" | grep -q '^description:' || { err "sem 'description': $name"; bad=$((bad + 1)); }
  # tr remove aspas duplas ("), aspas simples (\047) e CR (\r) — evita falso
  # positivo de "name != pasta" em arquivos com final de linha CRLF (Windows).
  fmname="$(echo "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '"\047\r' | xargs)"
  if [ -n "$fmname" ] && [ "$fmname" != "$name" ]; then
    err "'name: $fmname' difere da pasta '$name'"; bad=$((bad + 1))
  fi
done

echo ""
echo "Skills verificadas: $count | problemas: $bad"
if [ "$fail" -eq 0 ]; then echo "✓ Tudo válido"; else echo "✗ Encontrei problemas (veja acima)"; fi
exit "$fail"
