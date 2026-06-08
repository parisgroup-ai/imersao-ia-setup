#!/usr/bin/env bash
# ============================================================
#  CHECK — diagnóstico do ambiente da Imersão IA (ParisGroup)
#  Re-rodável. Mostra o que está OK e o que falta.
#  Uso: curl -fsSL .../scripts/check.sh | bash   (ou: bash scripts/check.sh)
# ============================================================
set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

OK=0; FALTA=0; AVISO=0
ok()    { echo -e "  ${GREEN}OK${NC}   $1${2:+  ($2)}"; OK=$((OK + 1)); }
falta() { echo -e "  ${RED}X${NC}    $1 — ${YELLOW}$2${NC}"; FALTA=$((FALTA + 1)); }
aviso() { echo -e "  ${YELLOW}!${NC}    $1"; AVISO=$((AVISO + 1)); }

# Garante brew/claude no PATH mesmo via curl|bash num shell mínimo
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"

echo ""
echo -e "${BLUE}=== Imersão IA — diagnóstico do ambiente ===${NC}"
echo ""

# Ferramentas de linha de comando
check_cmd() {
  local nome="$1" cmd="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$nome" "$("$cmd" --version 2>/dev/null | head -1)"
  else
    falta "$nome" "$hint"
  fi
}
echo -e "${BLUE}Ferramentas:${NC}"
check_cmd "Git"          git    "instale o Xcode CLI Tools: xcode-select --install"
check_cmd "Homebrew"     brew   "https://brew.sh — depois reabra o terminal"
check_cmd "Node.js"      node   "brew install node"
check_cmd "GitHub CLI"   gh     "brew install gh"
check_cmd "Claude Code"  claude "npm install -g @anthropic-ai/claude-code"
check_cmd "Codex CLI"    codex  "npm install -g @openai/codex"
check_cmd "ToStudy CLI"  tostudy "npm install -g @tostudy-ai/cli"

# Aplicativos (.app)
echo ""
echo -e "${BLUE}Aplicativos:${NC}"
check_app() {
  local nome="$1" app="$2" cask="$3"
  if [ -d "/Applications/$app" ]; then ok "$nome"; else falta "$nome" "brew install --cask $cask"; fi
}
check_app "Ghostty"        "Ghostty.app"  "ghostty"
check_app "Docker Desktop" "Docker.app"   "docker-desktop"
check_app "Obsidian"       "Obsidian.app" "obsidian"
check_app "Claude Desktop" "Claude.app"   "claude"

# Plugin de skills da Imersão
echo ""
echo -e "${BLUE}Skills da Imersão:${NC}"
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q 'imersao@imersao-ia'; then
    ok "Plugin 'imersao' instalado"
  else
    falta "Plugin 'imersao'" "no Claude Code: /plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup && /plugin install imersao@imersao-ia"
  fi
else
  falta "Plugin 'imersao'" "instale o Claude Code primeiro"
fi

# Pronto pra usar (instalar não basta — precisa estar PRONTO)
echo ""
echo -e "${BLUE}Pronto pra usar:${NC}"
# Docker REALMENTE rodando (não só instalado) — necessário na Fase 3
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  ok "Docker rodando"
elif [ -d "/Applications/Docker.app" ]; then
  aviso "Docker está PARADO — abra o app Docker Desktop e espere a baleia 🐳 na barra de cima parar de animar (precisa pra Fase 3)."
fi
# Lembretes que o check não consegue verificar sozinho:
aviso "Logado no Claude Code? Rode 'claude' e faça login na 1ª vez — sem isso nada responde."
aviso "Os comandos /imersao:* só aparecem depois de FECHAR e REABRIR o Claude Code uma vez."

# Resumo
echo ""
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "  ${GREEN}$OK OK${NC}  |  ${RED}$FALTA faltando${NC}  |  ${YELLOW}$AVISO avisos${NC}"
if [ "$FALTA" -eq 0 ] && [ "$AVISO" -eq 0 ]; then
  echo -e "  ${GREEN}Tudo certo! Bora pra imersão. 🚀${NC}"
elif [ "$FALTA" -eq 0 ]; then
  echo -e "  ${GREEN}Tudo instalado!${NC} ${YELLOW}Antes de usar, resolva os avisos ⚠ acima (login, reabrir o Claude, Docker).${NC}"
else
  echo -e "  ${YELLOW}Veja os itens marcados com X acima.${NC}"
  echo -e "  Guia: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md"
fi
echo ""
