#!/bin/bash
# ============================================================
#  INSTALADOR - IMERSAO DE IA (ParisGroup)
#  Cole este comando no Terminal e deixe rodar!
# ============================================================

# Se estiver rodando via pipe (curl | bash), salva o script
# localmente e re-executa com stdin livre pro sudo funcionar
if [ ! -t 0 ]; then
  TMPSCRIPT="$HOME/.instalar_imersao_tmp.sh"
  cat > "$TMPSCRIPT"
  exec bash "$TMPSCRIPT"
fi

# Remove o script temporario do modo curl|bash ao terminar (evita lixo no HOME)
trap 'rm -f "$HOME/.instalar_imersao_tmp.sh"' EXIT

# Obs: NAO usamos 'set -e' de proposito. O script faz seu proprio controle
# de erros (ok/erro + contador ERROS) e SEMPRE mostra o resumo final, mesmo
# quando um passo falha. Com 'set -e' o script abortaria no meio sem avisar.

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL=9

# -----------------------------------------------------------
# BLOQUEIO: nao pode rodar como root / sudo su
# -----------------------------------------------------------
if [[ "$EUID" -eq 0 ]] || [[ "$USER" == "root" ]]; then
  echo ""
  echo -e "${RED}============================================================${NC}"
  echo -e "${RED}   ERRO: NAO RODE ESTE SCRIPT COMO ROOT!                   ${NC}"
  echo -e "${RED}============================================================${NC}"
  echo ""
  echo -e "  Voce esta logado como ${RED}root${NC} (provavelmente usou 'sudo su')."
  echo ""
  echo -e "  ${GREEN}COMO RESOLVER:${NC}"
  echo "  1. Digite: exit"
  echo "  2. Depois rode o comando de novo SEM sudo su:"
  echo ""
  echo -e "     ${BLUE}curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/instalar_imersao.sh | bash${NC}"
  echo ""
  echo "  O script vai pedir sua senha quando precisar. Nao precisa de sudo su!"
  echo ""
  exit 1
fi

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}   INSTALADOR DA IMERSAO DE IA                              ${NC}"
echo -e "${BLUE}   Relaxa e deixa rodar — pode demorar alguns minutos!      ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# -----------------------------------------------------------
# Autentica sudo logo no inicio pra nao travar depois
# -----------------------------------------------------------
if ! sudo -n true 2>/dev/null; then
  echo -e "${YELLOW}Digite a senha do seu Mac pra continuar (nao aparece nada ao digitar, e normal):${NC}"
  sudo -v
fi
# Mantem o sudo ativo em background durante o script
(while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &)
echo ""

# Contador de sucesso
INSTALADOS=0
ERROS=0

ok() {
  echo -e "  ${GREEN}[OK]${NC} $1"
  INSTALADOS=$((INSTALADOS + 1))
}

pular() {
  echo -e "  ${YELLOW}[JA INSTALADO]${NC} $1"
  INSTALADOS=$((INSTALADOS + 1))
}

erro() {
  echo -e "  ${RED}[ERRO]${NC} $1 — $2"
  ERROS=$((ERROS + 1))
}

# Acrescenta uma linha ao ~/.zprofile apenas se ainda nao existir (idempotente)
persist_zprofile() {
  local line="$1"
  local marker="$2"
  touch "$HOME/.zprofile"
  if ! grep -qF "$marker" "$HOME/.zprofile" 2>/dev/null; then
    echo "$line" >> "$HOME/.zprofile"
  fi
}

# -----------------------------------------------------------
# 1) Xcode Command Line Tools (inclui Git)
# -----------------------------------------------------------
echo -e "${BLUE}[1/$TOTAL]${NC} Verificando Xcode Command Line Tools (inclui Git)..."
if xcode-select -p &>/dev/null; then
  pular "Xcode CLI Tools (Git incluso)"
else
  echo "  Instalando Xcode CLI Tools... (pode pedir sua senha e abrir uma janela)"
  xcode-select --install 2>/dev/null || true
  echo "  Aguardando a instalacao terminar (ate 30 min — conclua a janela que abriu)..."
  WAITED=0
  until xcode-select -p &>/dev/null; do
    sleep 5
    WAITED=$((WAITED + 5))
    if [ $((WAITED % 60)) -eq 0 ]; then
      echo "  ... ainda aguardando o Xcode CLI Tools ($((WAITED / 60)) min)"
    fi
    if [ "$WAITED" -ge 1800 ]; then
      erro "Xcode CLI Tools" "instale manualmente e rode o script de novo: xcode-select --install"
      break
    fi
  done
  if xcode-select -p &>/dev/null; then
    ok "Xcode CLI Tools instalado"
  fi
fi

# -----------------------------------------------------------
# 2) Homebrew
# -----------------------------------------------------------
echo -e "${BLUE}[2/$TOTAL]${NC} Verificando Homebrew..."
if command -v brew &>/dev/null; then
  pular "Homebrew"
else
  echo "  Instalando Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if command -v brew &>/dev/null || [[ -x /opt/homebrew/bin/brew || -x /usr/local/bin/brew ]]; then
    ok "Homebrew instalado"
  else
    erro "Homebrew" "instale manualmente em https://brew.sh"
  fi
fi

# Garante brew no PATH desta sessao E persiste pro proximo terminal.
# Cobre Apple Silicon (/opt/homebrew) E Intel (/usr/local) — antes so o Apple Silicon era persistido.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  persist_zprofile 'eval "$(/opt/homebrew/bin/brew shellenv)"' '/opt/homebrew/bin/brew shellenv'
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
  persist_zprofile 'eval "$(/usr/local/bin/brew shellenv)"' '/usr/local/bin/brew shellenv'
fi

# -----------------------------------------------------------
# 3) Node.js + prefixo global do npm no HOME (sem sudo)
# -----------------------------------------------------------
echo -e "${BLUE}[3/$TOTAL]${NC} Verificando Node.js..."
if command -v node &>/dev/null; then
  pular "Node.js ($(node -v))"
else
  echo "  Instalando Node.js..."
  if brew install node; then
    ok "Node.js $(node -v)"
  else
    erro "Node.js" "rode: brew install node"
  fi
fi

# Configura o npm pra instalar pacotes globais no HOME (~/.npm-global).
# Evita o anti-padrao 'sudo npm install -g', que quebra updates futuros.
if command -v npm &>/dev/null; then
  NPM_PREFIX="$HOME/.npm-global"
  mkdir -p "$NPM_PREFIX"
  npm config set prefix "$NPM_PREFIX" 2>/dev/null || true
  persist_zprofile "export PATH=\"$NPM_PREFIX/bin:\$PATH\"" '.npm-global/bin'
  export PATH="$NPM_PREFIX/bin:$PATH"
fi

# -----------------------------------------------------------
# 4) GitHub CLI (gh)
# -----------------------------------------------------------
echo -e "${BLUE}[4/$TOTAL]${NC} Verificando GitHub CLI (gh)..."
if command -v gh &>/dev/null; then
  pular "GitHub CLI (gh)"
else
  echo "  Instalando gh..."
  if brew install gh; then
    ok "GitHub CLI (gh)"
  else
    erro "GitHub CLI (gh)" "rode: brew install gh"
  fi
fi

# -----------------------------------------------------------
# 5) Apps via Homebrew Cask
# -----------------------------------------------------------
echo -e "${BLUE}[5/$TOTAL]${NC} Instalando aplicativos..."

instalar_app() {
  local cask_name="$1"
  local display_name="$2"
  local app_check="$3"

  if [[ -n "$app_check" ]] && [[ -d "/Applications/$app_check" ]]; then
    pular "$display_name"
  elif brew list --cask "$cask_name" &>/dev/null; then
    pular "$display_name"
  else
    echo "  Instalando $display_name..."
    if brew install --cask "$cask_name" 2>/dev/null; then
      ok "$display_name"
    else
      erro "$display_name" "tenta baixar manualmente"
    fi
  fi
}

instalar_app "ghostty"         "Ghostty (terminal)"  "Ghostty.app"
instalar_app "docker-desktop"  "Docker Desktop"      "Docker.app"
instalar_app "obsidian"        "Obsidian (notas)"    "Obsidian.app"
instalar_app "claude"          "Claude Desktop"      "Claude.app"

# -----------------------------------------------------------
# 6) Claude Code (npm, sem sudo)
# -----------------------------------------------------------
echo -e "${BLUE}[6/$TOTAL]${NC} Verificando Claude Code..."
if command -v claude &>/dev/null; then
  pular "Claude Code"
else
  echo "  Instalando Claude Code..."
  if npm install -g @anthropic-ai/claude-code; then
    ok "Claude Code"
  else
    erro "Claude Code" "rode: npm install -g @anthropic-ai/claude-code"
  fi
fi

# -----------------------------------------------------------
# 7) Codex CLI (npm, sem sudo)
# -----------------------------------------------------------
echo -e "${BLUE}[7/$TOTAL]${NC} Verificando Codex CLI..."
if command -v codex &>/dev/null; then
  pular "Codex CLI"
else
  echo "  Instalando Codex CLI..."
  if npm install -g @openai/codex; then
    ok "Codex CLI"
  else
    erro "Codex CLI" "rode: npm install -g @openai/codex"
  fi
fi

# -----------------------------------------------------------
# 8) Skills da Imersao (plugin do Claude Code)
# -----------------------------------------------------------
echo -e "${BLUE}[8/$TOTAL]${NC} Instalando as skills da Imersao (plugin 'imersao')..."
if command -v claude &>/dev/null; then
  claude plugin marketplace add parisgroup-ai/imersao-ia-setup 2>/dev/null || true
  if claude plugin install imersao@imersao-ia 2>/dev/null; then
    ok "Skills da Imersao (plugin 'imersao')"
  else
    erro "Skills (plugin)" "no Claude Code rode: /plugin marketplace add parisgroup-ai/imersao-ia-setup e depois /plugin install imersao@imersao-ia"
  fi
else
  erro "Skills (plugin)" "Claude Code nao foi instalado — resolva o passo 6 e rode de novo"
fi

# -----------------------------------------------------------
# 9) Verificacao final
# -----------------------------------------------------------
echo ""
echo -e "${BLUE}[9/$TOTAL]${NC} Verificacao final..."
echo -e "${BLUE}------------------------------------------------------------${NC}"

verificar() {
  local nome="$1"
  local cmd="$2"
  local app_path="$3"
  local ver=""

  if [[ -n "$cmd" ]] && command -v "$cmd" &>/dev/null; then
    ver=$("$cmd" --version 2>/dev/null | head -1)
    echo -e "  ${GREEN}OK${NC}  $nome  ($ver)"
  elif [[ -n "$app_path" ]] && [[ -d "/Applications/$app_path" ]]; then
    echo -e "  ${GREEN}OK${NC}  $nome  (instalado)"
  else
    echo -e "  ${RED}X${NC}   $nome  — NAO ENCONTRADO"
  fi
}

verificar "Git"             "git"     ""
verificar "Node.js"         "node"    ""
verificar "Homebrew"        "brew"    ""
verificar "GitHub CLI"      "gh"      ""
verificar "Ghostty"         ""        "Ghostty.app"
verificar "Docker Desktop"  ""        "Docker.app"
verificar "Obsidian"        ""        "Obsidian.app"
verificar "Claude Desktop"  ""        "Claude.app"
verificar "Claude Code"     "claude"  ""
verificar "Codex CLI"       "codex"   ""

echo -e "${BLUE}------------------------------------------------------------${NC}"
echo ""

echo -e "  ${GREEN}$INSTALADOS OK${NC}  |  ${RED}$ERROS com erro${NC}"
echo ""
if [[ $ERROS -eq 0 ]]; then
  echo -e "${GREEN}TUDO PRONTO! Ambiente configurado com sucesso.${NC}"
else
  echo -e "${YELLOW}Quase la! $ERROS item(ns) precisam de atencao manual (veja os [ERRO] acima).${NC}"
fi

echo ""
echo -e "${BLUE}LEMBRETE — Falta fazer manualmente:${NC}"
echo "  1. Criar conta no GitHub:   https://github.com/"
echo "  2. Criar conta no Claude:   https://claude.ai/login  (plano Max \$100 ou \$200/mes)"
echo "  3. Criar conta no ChatGPT:  https://chat.openai.com/  (plano Plus \$20/mes)"
echo "  4. Abrir o Docker Desktop pelo menos 1x pra finalizar setup"
echo "  5. Abrir o Claude Desktop e fazer login"
echo "  6. Fechar e reabrir o terminal (ou o Claude Code) pra carregar as skills do plugin"
echo ""
echo -e "${BLUE}PROXIMOS PASSOS:${NC}"
echo "  - Guia do dia 1:  https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/PRIMEIROS-PASSOS.md"
echo "  - Deu erro?       https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md"
echo "  - Conferir tudo:  curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash"
echo ""
echo -e "${BLUE}Usa Codex tambem?${NC} As skills viram plugin so no Claude Code. Pro Codex, rode:"
echo -e "  ${BLUE}curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/sync-codex-skills.sh | bash${NC}"
echo ""
echo -e "${GREEN}Nos vemos na imersao! 🚀${NC}"
echo ""
