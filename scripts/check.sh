#!/usr/bin/env bash
# ============================================================
#  CHECK — diagnóstico do ambiente da Imersão IA (ParisGroup)
#  Multi-OS: macOS (caminho ouro) · WSL/Windows · Linux
#  Uso: curl -fsSL .../scripts/check.sh | bash   (ou: bash scripts/check.sh)
# ============================================================
set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

OK=0; FALTA=0; AVISO=0
ok()    { echo -e "  ${GREEN}OK${NC}   $1${2:+  ($2)}"; OK=$((OK + 1)); }
falta() { echo -e "  ${RED}X${NC}    $1 — ${YELLOW}$2${NC}"; FALTA=$((FALTA + 1)); }
aviso() { echo -e "  ${YELLOW}!${NC}    $1"; AVISO=$((AVISO + 1)); }

# --- Detecta SO ---
OS_KERNEL="$(uname -s 2>/dev/null || echo unknown)"
IS_MAC=0; IS_WSL=0; IS_LINUX=0; IS_WIN_NATIVE=0
PROFILE="unknown"

case "$OS_KERNEL" in
  Darwin) IS_MAC=1; PROFILE="macOS" ;;
  Linux)
    if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
      IS_WSL=1; PROFILE="Windows/WSL"
    else
      IS_LINUX=1; PROFILE="Linux"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    IS_WIN_NATIVE=1; PROFILE="Windows (Git Bash/MSYS — use WSL Ubuntu)"
    ;;
  *)
    PROFILE="$OS_KERNEL"
    ;;
esac

# PATH: brew (Mac) + npm global
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
[ -d "$HOME/.npm-global/bin" ] && export PATH="$HOME/.npm-global/bin:$PATH"
# nvm (comum no WSL)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.nvm/nvm.sh" 2>/dev/null || true
fi

echo ""
echo -e "${BLUE}=== Imersão IA — diagnóstico do ambiente ===${NC}"
echo -e "  Perfil: ${YELLOW}${PROFILE}${NC}"
echo ""

if [ "$IS_WIN_NATIVE" -eq 1 ]; then
  aviso "Voce parece estar no Git Bash/MSYS. Para a imersao, use o terminal Ubuntu (WSL2)."
  aviso "Guia: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md"
fi

if [ "$IS_WSL" -eq 1 ] || [ "$IS_LINUX" -eq 1 ]; then
  aviso "Caminho suportado: core = Node + Claude Code + Docker + plugin (sem Homebrew)."
  aviso "Ambiente padrao de trabalho = Orca (desktop + app no celular). Instale em https://www.onorca.dev/download"
  if [ "$IS_WSL" -eq 1 ]; then
    aviso "Guia Windows: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md"
  fi
fi

# Ferramentas de linha de comando
check_cmd() {
  local nome="$1" cmd="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$nome" "$("$cmd" --version 2>/dev/null | head -1)"
  else
    falta "$nome" "$hint"
  fi
}

echo -e "${BLUE}Ferramentas (core):${NC}"
if [ "$IS_MAC" -eq 1 ]; then
  check_cmd "Git"          git    "instale o Xcode CLI Tools: xcode-select --install"
  check_cmd "Homebrew"     brew   "https://brew.sh — depois reabra o terminal"
  check_cmd "Node.js"      node   "brew install node"
  check_cmd "GitHub CLI"   gh     "brew install gh"
  check_cmd "jq"           jq     "brew install jq"
else
  check_cmd "Git"          git    "sudo apt install -y git"
  # Homebrew e opcional fora do Mac
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew" "$(brew --version 2>/dev/null | head -1)"
  else
    aviso "Homebrew ausente (ok no Windows/Linux — use apt/nvm)"
  fi
  check_cmd "Node.js"      node   "instale via nvm: https://github.com/nvm-sh/nvm — ver docs/WINDOWS.md"
  check_cmd "GitHub CLI"   gh     "https://github.com/cli/cli#installation"
  # jq e core em todo SO: a statusline PG depende dele no runtime
  check_cmd "jq" jq "sudo apt install -y jq  (ou: curl -fsSL .../scripts/install-statusline.sh | bash)"
fi

check_cmd "Claude Code"  claude "npm install -g @anthropic-ai/claude-code"
check_cmd "Codex CLI"    codex  "npm install -g @openai/codex"
check_cmd "ToStudy CLI"  tostudy "npm install -g @tostudy-ai/cli"

# Aplicativos — Mac checa /Applications; WSL/Linux: Docker CLI + lembrete Orca
echo ""
echo -e "${BLUE}Aplicativos / ambiente de trabalho:${NC}"
if [ "$IS_MAC" -eq 1 ]; then
  check_app() {
    local nome="$1" app="$2" cask="$3"
    if [ -d "/Applications/$app" ]; then ok "$nome"; else falta "$nome" "brew install --cask $cask"; fi
  }
  # Orca = padrao da imersao (ADE + companion no celular). Ghostty = terminal opcional.
  if [ -d "/Applications/Orca.app" ]; then
    ok "Orca (ambiente padrao)"
  else
    falta "Orca" "brew install --cask stablyai/orca/orca  — https://www.onorca.dev/download"
  fi
  if [ -d "/Applications/Ghostty.app" ]; then
    ok "Ghostty (terminal opcional)"
  else
    aviso "Ghostty ausente (ok — o padrao e o Orca; se quiser: brew install --cask ghostty)"
  fi
  check_app "Docker Desktop" "Docker.app"   "docker-desktop"
  check_app "Obsidian"       "Obsidian.app" "obsidian"
  check_app "Claude Desktop" "Claude.app"   "claude"
else
  aviso "No Windows/Linux: instale o Orca desktop (padrao) em https://www.onorca.dev/download"
  aviso "Obsidian/Claude Desktop no host Windows sao opcionais; Ghostty e so Mac."
  if command -v docker >/dev/null 2>&1; then
    ok "Docker CLI presente"
  else
    falta "Docker CLI" "Docker Desktop (Windows) com integracao WSL, ou Docker Engine (Linux)"
  fi
fi

# Plugin de skills da Imersão
echo ""
echo -e "${BLUE}Skills da Imersão:${NC}"
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q 'imersao@imersao-ia'; then
    ok "Plugin 'imersao' instalado"
  else
    falta "Plugin 'imersao'" "no Claude Code: /plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup && /plugin install imersao@imersao-ia"
  fi
  PLUGIN_COUNT=$(claude plugin list 2>/dev/null | grep -c '@' || true)
  if [ "${PLUGIN_COUNT:-0}" -gt 8 ]; then
    aviso "Muitos plugins Claude Code ($PLUGIN_COUNT) — prefira Setup oficial + lista curta (imersão; ver README §2)"
  else
    ok "Plugins Claude Code em quantidade razoavel" "${PLUGIN_COUNT:-0} linhas"
  fi
else
  falta "Plugin 'imersao'" "instale o Claude Code primeiro"
fi

# Statusline — core em Mac, WSL e Linux (mesma barra do Claude Code)
echo ""
echo -e "${BLUE}Statusline:${NC}"
SL_INSTALL_HINT="curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash"
SL_SMOKE_JSON=$(printf '{"model":{"display_name":"x"},"cwd":"%s","workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":0}}' "$HOME" "$HOME")
# Smoke: exit 0 e saida real (sem jq a statusline imprime '[install jq]' e exit 0)
_SL_OUT=""
if command -v claude-statusline >/dev/null 2>&1; then
  _SL_OUT="$(printf '%s' "$SL_SMOKE_JSON" | claude-statusline 2>/dev/null || true)"
fi
if [ -n "$_SL_OUT" ] && [[ "$_SL_OUT" != *'[install jq]'* ]]; then
  ok "Statusline instalada" "claude-statusline"
  if [ -f "$HOME/.claude/settings.json" ] && command -v jq >/dev/null 2>&1 && jq -e '.statusLine' "$HOME/.claude/settings.json" >/dev/null 2>&1; then
    ok "Statusline ligada no settings.json"
  elif [ -f "$HOME/.claude/settings.json" ] && grep -q '"statusLine"' "$HOME/.claude/settings.json" 2>/dev/null; then
    ok "Statusline ligada no settings.json"
  else
    falta "Statusline NAO ligada" "rode: $SL_INSTALL_HINT"
  fi
else
  falta "Statusline PG" "rode: $SL_INSTALL_HINT"
fi

# Pronto pra usar
echo ""
echo -e "${BLUE}Pronto pra usar:${NC}"
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  ok "Docker rodando"
elif [ "$IS_MAC" -eq 1 ] && [ -d "/Applications/Docker.app" ]; then
  aviso "Docker esta PARADO — abra o app Docker Desktop e espere a baleia na barra parar de animar (precisa pra Fase 3)."
elif [ "$IS_WSL" -eq 1 ] || [ "$IS_LINUX" -eq 1 ]; then
  aviso "Docker nao esta rodando — no Windows: abra Docker Desktop e ligue a integracao WSL da Ubuntu."
fi

aviso "Ambiente padrao = Orca. Abra o app Orca e rode 'claude' la dentro (nao so no Terminal)."
aviso "Celular: pareie Orca Mobile (iOS/Android) com o desktop — https://www.onorca.dev/download"
aviso "Logado no Claude Code? Rode 'claude' e faca login na 1a vez — sem isso nada responde."
aviso "Os comandos /imersao:* so aparecem depois de FECHAR e REABRIR o Claude Code uma vez."

# Resumo
echo ""
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "  ${GREEN}$OK OK${NC}  |  ${RED}$FALTA faltando${NC}  |  ${YELLOW}$AVISO avisos${NC}  |  perfil ${PROFILE}"
if [ "$FALTA" -eq 0 ] && [ "$AVISO" -eq 0 ]; then
  echo -e "  ${GREEN}Tudo certo! Bora pra imersao. 🚀${NC}"
elif [ "$FALTA" -eq 0 ]; then
  echo -e "  ${GREEN}Core instalado!${NC} ${YELLOW}Antes de usar, resolva os avisos acima (login, reabrir o Claude, Docker).${NC}"
else
  echo -e "  ${YELLOW}Veja os itens marcados com X acima.${NC}"
  if [ "$IS_MAC" -eq 1 ]; then
    echo -e "  Guia: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md"
  else
    echo -e "  Guia Windows: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/WINDOWS.md"
    echo -e "  Troubleshooting: https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md"
  fi
fi
echo ""
