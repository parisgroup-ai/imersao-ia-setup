#!/usr/bin/env bash
# ============================================================
#  SYNC CODEX SKILLS — Imersão IA (ParisGroup)
#  Copia as skills do plugin 'imersao' para ~/.codex/skills/
#
#  Usuários de Claude Code NÃO precisam disto — usem o plugin:
#    claude plugin marketplace add parisgroup-ai/imersao-ia-setup
#    claude plugin install imersao@imersao-ia
#
#  Codex não suporta plugins, então sincronizamos por cópia.
# ============================================================
set -euo pipefail

REPO_URL="https://github.com/parisgroup-ai/imersao-ia-setup.git"
CODEX_SKILLS="$HOME/.codex/skills"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Descobre a origem das skills: prefere o repositório onde este script vive;
# senão (ex.: rodando via curl | bash), clona/atualiza um cache local.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../plugins/imersao/skills" ]; then
  SRC="$(cd "$SCRIPT_DIR/../plugins/imersao/skills" && pwd)"
else
  CACHE="$HOME/.imersao-ia-cache"
  if [ -d "$CACHE/.git" ]; then
    echo ">>> Atualizando cache em $CACHE..."
    # Se o pull falhar (ex.: histórico divergente), reclona — nunca seguir
    # adiante com skills desatualizadas reportando sucesso.
    if ! git -C "$CACHE" pull --ff-only --quiet 2>/dev/null; then
      echo -e "${YELLOW}>>> Não consegui atualizar o cache; reclonando...${NC}"
      rm -rf "$CACHE"
      git clone --depth 1 --quiet "$REPO_URL" "$CACHE"
    fi
  else
    echo ">>> Clonando $REPO_URL em $CACHE..."
    git clone --depth 1 --quiet "$REPO_URL" "$CACHE"
  fi
  SRC="$CACHE/plugins/imersao/skills"
fi

if [ ! -d "$SRC" ]; then
  echo "ERRO: não encontrei as skills em $SRC" >&2
  exit 1
fi

mkdir -p "$CODEX_SKILLS"

count=0
for skill_dir in "$SRC"/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  [ -f "$skill_dir/SKILL.md" ] || continue
  rm -rf "${CODEX_SKILLS:?}/$name"
  cp -R "$skill_dir" "$CODEX_SKILLS/$name"
  count=$((count + 1))
done

echo ""
echo -e "${GREEN}✓ $count skills sincronizadas em $CODEX_SKILLS${NC}"
echo -e "${YELLOW}Reinicie o Codex para carregar as skills.${NC}"
