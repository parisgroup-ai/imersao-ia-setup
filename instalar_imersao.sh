#!/bin/bash
# ============================================================
#  INSTALADOR - IMERSAO DE IA
#  Cole este comando no Terminal e deixe rodar!
# ============================================================

# Se estiver rodando via pipe (curl | bash), salva o script
# localmente e re-executa com stdin livre pro sudo funcionar
if [ ! -t 0 ]; then
  TMPSCRIPT="$HOME/.instalar_imersao_tmp.sh"
  cat > "$TMPSCRIPT"
  exec bash "$TMPSCRIPT"
fi

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# -----------------------------------------------------------
# 1) Xcode Command Line Tools (inclui Git)
# -----------------------------------------------------------
echo -e "${BLUE}[1/7]${NC} Verificando Xcode Command Line Tools (inclui Git)..."
if xcode-select -p &>/dev/null; then
  pular "Xcode CLI Tools (Git incluso)"
else
  echo "  Instalando Xcode CLI Tools... (pode pedir sua senha e abrir uma janela)"
  xcode-select --install 2>/dev/null || true
  # Espera a instalacao terminar
  echo "  Aguardando instalacao do Xcode CLI Tools..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLI Tools instalado"
fi

# -----------------------------------------------------------
# 2) Homebrew
# -----------------------------------------------------------
echo -e "${BLUE}[2/7]${NC} Verificando Homebrew..."
if command -v brew &>/dev/null; then
  pular "Homebrew"
else
  echo "  Instalando Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Configura o PATH do Homebrew
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Adiciona ao perfil se nao existir
    if ! grep -q 'homebrew' ~/.zprofile 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew instalado"
fi

# Garante que brew esta no PATH para esta sessao
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------
# 3) Node.js (necessario pro Claude Code e Codex)
# -----------------------------------------------------------
echo -e "${BLUE}[3/7]${NC} Verificando Node.js..."
if command -v node &>/dev/null; then
  NODE_V=$(node -v)
  pular "Node.js ($NODE_V)"
else
  echo "  Instalando Node.js..."
  brew install node
  ok "Node.js $(node -v)"
fi

# -----------------------------------------------------------
# 4) Apps via Homebrew Cask
# -----------------------------------------------------------
echo -e "${BLUE}[4/7]${NC} Instalando aplicativos..."

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

instalar_app "ghostty"        "Ghostty (terminal)"           "Ghostty.app"
instalar_app "docker"         "Docker Desktop"               "Docker.app"
instalar_app "obsidian"       "Obsidian (notas)"             "Obsidian.app"
instalar_app "claude"         "Claude Desktop"               "Claude.app"

# -----------------------------------------------------------
# 5) Claude Code (npm)
# -----------------------------------------------------------
echo -e "${BLUE}[5/7]${NC} Verificando Claude Code..."
if command -v claude &>/dev/null; then
  pular "Claude Code"
else
  echo "  Instalando Claude Code..."
  if npm install -g @anthropic-ai/claude-code 2>/dev/null; then
    ok "Claude Code"
  else
    # Tenta com sudo se falhar permissao
    echo "  Tentando com permissao elevada..."
    if sudo npm install -g @anthropic-ai/claude-code; then
      ok "Claude Code (com sudo)"
    else
      erro "Claude Code" "rode: npm install -g @anthropic-ai/claude-code"
    fi
  fi
fi

# -----------------------------------------------------------
# 6) Codex CLI (npm)
# -----------------------------------------------------------
echo -e "${BLUE}[6/7]${NC} Verificando Codex CLI..."
if command -v codex &>/dev/null; then
  pular "Codex CLI"
else
  echo "  Instalando Codex CLI..."
  if npm install -g @openai/codex 2>/dev/null; then
    ok "Codex CLI"
  else
    echo "  Tentando com permissao elevada..."
    if sudo npm install -g @openai/codex; then
      ok "Codex CLI (com sudo)"
    else
      erro "Codex CLI" "rode: npm install -g @openai/codex"
    fi
  fi
fi

# -----------------------------------------------------------
# 7) Verificacao final
# -----------------------------------------------------------
echo ""
echo -e "${BLUE}[7/7]${NC} Verificacao final..."
echo -e "${BLUE}------------------------------------------------------------${NC}"

verificar() {
  local nome="$1"
  local cmd="$2"
  local app_path="$3"

  if [[ -n "$cmd" ]] && command -v "$cmd" &>/dev/null; then
    local ver=$($cmd --version 2>/dev/null | head -1)
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
verificar "Ghostty"         ""        "Ghostty.app"
verificar "Docker Desktop"  ""        "Docker.app"
verificar "Obsidian"        ""        "Obsidian.app"
verificar "Claude Desktop"  ""        "Claude.app"
verificar "Claude Code"     "claude"  ""
verificar "Codex CLI"       "codex"   ""

echo -e "${BLUE}------------------------------------------------------------${NC}"
echo ""

if [[ $ERROS -eq 0 ]]; then
  echo -e "${GREEN}TUDO PRONTO! Ambiente configurado com sucesso.${NC}"
else
  echo -e "${YELLOW}Quase la! $ERROS item(ns) precisam de atencao manual.${NC}"
fi

echo ""
echo -e "${BLUE}LEMBRETE — Falta fazer manualmente:${NC}"
echo "  1. Criar conta no GitHub:   https://github.com/"
echo "  2. Criar conta no Claude:   https://claude.ai/login  (plano Max \$100 ou \$200/mes)"
echo "  3. Criar conta no ChatGPT:  https://chat.openai.com/  (plano Plus \$20/mes)"
echo "  4. Abrir o Docker Desktop pelo menos 1x pra finalizar setup"
echo "  5. Abrir o Claude Desktop e fazer login"
echo ""
echo -e "${GREEN}Nos vemos amanha na imersao! 🚀${NC}"
echo ""
