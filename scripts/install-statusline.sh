#!/usr/bin/env bash
# ============================================================
#  INSTALL STATUSLINE — ParisGroup / Imersão IA
#  Multi-OS: macOS · Windows/WSL · Linux
#  Idempotente: binário + PATH + jq + ~/.claude/settings.json
#
#  Uso:
#    bash scripts/install-statusline.sh
#    curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh | bash
# ============================================================
set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

OK=0; ERROS=0
ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; OK=$((OK + 1)); }
pula() { echo -e "  ${YELLOW}[JA OK]${NC} $1"; OK=$((OK + 1)); }
erro() { echo -e "  ${RED}[ERRO]${NC} $1 — $2"; ERROS=$((ERROS + 1)); }
info() { echo -e "  ${BLUE}→${NC} $1"; }

SL_URL="${SL_URL:-https://raw.githubusercontent.com/parisgroup-ai/claude-statusline/main/bin/cc-statusline.sh}"
# Repo da imersão (só para mensagens de fallback)
REPO_HINT="https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/install-statusline.sh"

echo ""
echo -e "${BLUE}=== Imersão IA — instalar statusline do Claude Code ===${NC}"
echo ""

# --- SO ---
OS_KERNEL="$(uname -s 2>/dev/null || echo unknown)"
IS_MAC=0
PROFILE="unknown"
case "$OS_KERNEL" in
  Darwin) IS_MAC=1; PROFILE="macOS" ;;
  Linux)
    if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
      PROFILE="Windows/WSL"
    else
      PROFILE="Linux"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    erro "Ambiente" "rode no Ubuntu (WSL2), nao no Git Bash/PowerShell. Guia: docs/WINDOWS.md"
    exit 1
    ;;
  *) PROFILE="$OS_KERNEL" ;;
esac
info "Perfil: $PROFILE"

# --- PATH helpers: npm global sem sudo ---
ensure_npm_global_dir() {
  SL_DIR="${SL_DIR:-$HOME/.npm-global/bin}"
  mkdir -p "$SL_DIR"
  export PATH="$SL_DIR:$PATH"

  # Sessão atual + shells comuns (Orca/WSL costumam carregar bashrc ou zprofile)
  persist_path_line() {
    local file="$1"
    local line='export PATH="$HOME/.npm-global/bin:$PATH"'
    local marker='.npm-global/bin'
    touch "$file" 2>/dev/null || return 0
    if ! grep -qF "$marker" "$file" 2>/dev/null; then
      echo "$line" >> "$file"
      info "PATH persistido em $file"
    fi
  }

  persist_path_line "$HOME/.zprofile"
  persist_path_line "$HOME/.zshrc"
  persist_path_line "$HOME/.bashrc"
  persist_path_line "$HOME/.profile"

  if command -v npm >/dev/null 2>&1; then
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true
  fi
}

# --- jq (obrigatorio: a statusline usa jq no runtime) ---
install_jq() {
  if command -v jq >/dev/null 2>&1; then
    pula "jq ($(jq --version 2>/dev/null | head -1))"
    return 0
  fi
  info "Instalando jq (dependencia da statusline)..."
  if [ "$IS_MAC" -eq 1 ]; then
    if command -v brew >/dev/null 2>&1 && brew install jq >/dev/null 2>&1; then
      ok "jq"
      return 0
    fi
    erro "jq" "rode: brew install jq"
    return 1
  fi
  # WSL / Linux
  if command -v apt-get >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
      sudo apt-get update -qq >/dev/null 2>&1 || true
      if sudo apt-get install -y -qq jq >/dev/null 2>&1; then
        ok "jq"
        return 0
      fi
    else
      info "Precisa de sudo uma vez para instalar jq"
      if sudo apt-get update -qq && sudo apt-get install -y -qq jq; then
        ok "jq"
        return 0
      fi
    fi
  elif command -v dnf >/dev/null 2>&1; then
    if sudo dnf install -y jq >/dev/null 2>&1; then ok "jq"; return 0; fi
  elif command -v yum >/dev/null 2>&1; then
    if sudo yum install -y jq >/dev/null 2>&1; then ok "jq"; return 0; fi
  elif command -v pacman >/dev/null 2>&1; then
    if sudo pacman -S --noconfirm jq >/dev/null 2>&1; then ok "jq"; return 0; fi
  fi
  erro "jq" "instale jq (apt/dnf/brew) e rode de novo: curl -fsSL $REPO_HINT | bash"
  return 1
}

# --- merge settings.json (path ABSOLUTO do bin = funciona no Orca/GUI sem PATH) ---
wire_settings() {
  local bin_abs="$1"
  local settings="$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  [ -f "$settings" ] || echo '{}' > "$settings"

  # Ja tem statusLine? nao sobrescreve customizacao
  if command -v jq >/dev/null 2>&1 && jq -e '.statusLine' "$settings" >/dev/null 2>&1; then
    pula "statusLine ja existe em settings.json (preservada)"
    return 0
  fi
  if command -v node >/dev/null 2>&1; then
    if node -e "
const fs=require('fs');
const p=process.argv[1];
const bin=process.argv[2];
let o={};
try { o=JSON.parse(fs.readFileSync(p,'utf8')||'{}'); } catch(e) { o={}; }
if (o.statusLine) { process.exit(0); }
o.statusLine={type:'command', command: bin};
fs.writeFileSync(p, JSON.stringify(o, null, 2) + '\n');
" "$settings" "$bin_abs" 2>/dev/null; then
      if command -v jq >/dev/null 2>&1 && jq -e '.statusLine' "$settings" >/dev/null 2>&1; then
        ok "statusLine ligada (path absoluto)"
        return 0
      fi
      # node escreveu sem jq para validar — confere grepping
      if grep -q 'statusLine' "$settings" 2>/dev/null; then
        ok "statusLine ligada (path absoluto)"
        return 0
      fi
    fi
  fi
  if command -v jq >/dev/null 2>&1; then
    local tmp
    tmp="$(mktemp)"
    if jq --arg cmd "$bin_abs" '.statusLine = {"type":"command","command":$cmd}' "$settings" > "$tmp" 2>/dev/null && mv "$tmp" "$settings"; then
      ok "statusLine ligada (path absoluto)"
      return 0
    fi
    rm -f "$tmp"
  fi
  erro "settings.json" "adicione manualmente: \"statusLine\": {\"type\":\"command\",\"command\":\"$bin_abs\"}"
  return 1
}

# --- download + smoke ---
# Smoke real: saida nao vazia e nao e so o placeholder sem jq (exit 0 enganoso).
_statusline_smoke_ok() {
  local bin="$1" smoke="$2" out
  out="$(printf '%s' "$smoke" | bash "$bin" 2>/dev/null || true)"
  case "$out" in
    *'[install jq]'*) return 1 ;;
    '') return 1 ;;
    *) return 0 ;;
  esac
}

install_bin() {
  local sl_bin="$SL_DIR/claude-statusline"
  local smoke
  smoke="$(printf '{"model":{"display_name":"x"},"cwd":"%s","workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":0}}' "$HOME" "$HOME")"

  # Se ja funciona de verdade, so garante settings
  if command -v claude-statusline >/dev/null 2>&1; then
    local existing
    existing="$(command -v claude-statusline)"
    if _statusline_smoke_ok "$existing" "$smoke"; then
      pula "claude-statusline ($existing)"
      SL_BIN_ABS="$existing"
      return 0
    fi
  fi

  if ! command -v jq >/dev/null 2>&1; then
    erro "smoke" "jq ausente — a statusline nao roda sem jq"
    return 1
  fi

  info "Baixando statusline de $SL_URL ..."
  local tmp
  tmp="$(mktemp)"
  if ! curl -fsSL "$SL_URL" -o "$tmp" || [ ! -s "$tmp" ]; then
    rm -f "$tmp"
    erro "download" "curl falhou. Verifique rede e rode: curl -fsSL $SL_URL -o $sl_bin && chmod +x $sl_bin"
    return 1
  fi

  if ! _statusline_smoke_ok "$tmp" "$smoke"; then
    info "Smoke falhou; saida:"
    printf '%s' "$smoke" | bash "$tmp" 2>&1 | head -5 || true
    rm -f "$tmp"
    erro "smoke" "script baixado nao executa. Abra issue ou fale com o mentor."
    return 1
  fi

  mv "$tmp" "$sl_bin" && chmod +x "$sl_bin"
  hash -r 2>/dev/null || true
  export PATH="$SL_DIR:$PATH"

  if _statusline_smoke_ok "$sl_bin" "$smoke"; then
    ok "claude-statusline → $sl_bin"
    SL_BIN_ABS="$sl_bin"
    return 0
  fi
  erro "claude-statusline" "instalado em $sl_bin mas smoke falhou"
  return 1
}

# --- run ---
ensure_npm_global_dir
install_jq || true
SL_BIN_ABS=""
install_bin || true

if [ -n "${SL_BIN_ABS:-}" ]; then
  # Prefere path absoluto resolvido
  if command -v realpath >/dev/null 2>&1; then
    SL_BIN_ABS="$(realpath "$SL_BIN_ABS" 2>/dev/null || echo "$SL_BIN_ABS")"
  elif command -v readlink >/dev/null 2>&1; then
    # macOS readlink sem -f; se falhar mantem path
    _r="$(readlink -f "$SL_BIN_ABS" 2>/dev/null || true)"
    [ -n "$_r" ] && SL_BIN_ABS="$_r"
  fi
  wire_settings "$SL_BIN_ABS" || true
elif command -v claude-statusline >/dev/null 2>&1; then
  wire_settings "$(command -v claude-statusline)" || true
fi

echo ""
echo -e "${BLUE}------------------------------------------------------------${NC}"
echo -e "  ${GREEN}$OK OK${NC}  |  ${RED}$ERROS erro(s)${NC}"
if [ "$ERROS" -eq 0 ]; then
  echo -e "  ${GREEN}Statusline pronta.${NC} ${YELLOW}Feche e reabra o Claude Code${NC} (Orca/terminal) para carregar."
  echo "  Confira: curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash"
  exit 0
fi
echo -e "  ${YELLOW}Resolva os [ERRO] acima e rode de novo.${NC}"
exit 1
