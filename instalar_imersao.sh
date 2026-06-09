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

TOTAL=11

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
      erro "$display_name" "rode manualmente: brew install --cask $cask_name (veja docs/TROUBLESHOOTING.md)"
    fi
  fi
}

instalar_app "ghostty"                  "Ghostty (terminal)"            "Ghostty.app"
instalar_app "docker-desktop"           "Docker Desktop"                "Docker.app"
instalar_app "obsidian"                 "Obsidian (notas)"              "Obsidian.app"
instalar_app "claude"                   "Claude Desktop"                "Claude.app"
# Nerd Font: necessaria pros icones da statusline da ParisGroup (passo 10). Font cask, sem .app.
instalar_app "font-meslo-lg-nerd-font"  "Nerd Font (icones da statusline)"  ""

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
# 8) ToStudy CLI (npm, sem sudo) — cursos da imersao
# -----------------------------------------------------------
echo -e "${BLUE}[8/$TOTAL]${NC} Verificando ToStudy CLI..."
if command -v tostudy &>/dev/null; then
  pular "ToStudy CLI"
else
  echo "  Instalando ToStudy CLI..."
  if npm install -g @tostudy-ai/cli; then
    ok "ToStudy CLI"
  else
    erro "ToStudy CLI" "rode: npm install -g @tostudy-ai/cli"
  fi
fi

# -----------------------------------------------------------
# 9) Skills da Imersao (plugin do Claude Code)
# -----------------------------------------------------------
echo -e "${BLUE}[9/$TOTAL]${NC} Instalando as skills da Imersao (plugin 'imersao')..."
if command -v claude &>/dev/null; then
  PLUGIN_LOG="$(mktemp)"
  PLUGIN_OK=""
  # Tenta ate 2x: um Claude recem-instalado as vezes so registra o marketplace no 2o try.
  # NAO esconde o erro (2>&1 pro log) pra poder mostrar a causa real se falhar.
  for attempt in 1 2; do
    claude plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup >>"$PLUGIN_LOG" 2>&1
    claude plugin install imersao@imersao-ia >>"$PLUGIN_LOG" 2>&1
    if claude plugin list 2>/dev/null | grep -q 'imersao@imersao-ia'; then
      ok "Skills da Imersao (plugin 'imersao')"
      PLUGIN_OK=1
      break
    fi
    [ "$attempt" = 1 ] && sleep 3
  done
  if [ -z "$PLUGIN_OK" ]; then
    erro "Skills (plugin)" "auto-instalacao falhou — no Claude Code rode: /plugin marketplace add https://github.com/parisgroup-ai/imersao-ia-setup e depois /plugin install imersao@imersao-ia"
    echo -e "${YELLOW}     (erro real abaixo — manda esse trecho pra gente se persistir):${NC}"
    tail -6 "$PLUGIN_LOG" | sed 's/^/       /'
  fi
  rm -f "$PLUGIN_LOG"
else
  erro "Skills (plugin)" "Claude Code nao foi instalado — resolva o passo 6 e rode de novo"
fi

# -----------------------------------------------------------
# 10) Statusline da ParisGroup (statusline do Claude Code)
# -----------------------------------------------------------
echo -e "${BLUE}[10/$TOTAL]${NC} Configurando a statusline da ParisGroup..."
if command -v claude &>/dev/null; then
  # jq: necessario pro merge seguro do settings.json (e usado pela propria statusline)
  if ! command -v jq &>/dev/null; then
    echo "  Instalando jq (dependencia da statusline)..."
    brew install jq >/dev/null 2>&1 || true
  fi

  # CLI da statusline: baixa o script (bash AUTOCONTIDO) direto do repo PUBLICO.
  # Por que nao 'npm install -g'? O pacote @parisgroup-ai/* vive no GitHub Packages
  # (exige token) E o 'npm install -g github:...' instala um bin quebrado (symlink
  # pendurado). O script e um unico bash autocontido — baixar direto e robusto e sem token.
  SL_DIR="$HOME/.npm-global/bin"
  SL_BIN="$SL_DIR/claude-statusline"
  SL_URL="https://raw.githubusercontent.com/parisgroup-ai/claude-statusline/main/bin/cc-statusline.sh"
  SL_SMOKE='{"model":{"display_name":"x"},"cwd":"'"$HOME"'","workspace":{"current_dir":"'"$HOME"'"},"cost":{"total_cost_usd":0}}'
  mkdir -p "$SL_DIR"
  echo "  Baixando a statusline..."
  SL_TMP="$(mktemp)"
  # So instala se baixar E passar num smoke test real (roda com JSON no stdin, exit 0).
  # Presenca/--version nao servem: --version travaria (le stdin) e presenca mascararia bin quebrado.
  if curl -fsSL "$SL_URL" -o "$SL_TMP" && [ -s "$SL_TMP" ] && printf '%s' "$SL_SMOKE" | bash "$SL_TMP" >/dev/null 2>&1; then
    mv "$SL_TMP" "$SL_BIN" && chmod +x "$SL_BIN"
    ok "Statusline (claude-statusline)"
  else
    rm -f "$SL_TMP"
    erro "Statusline (CLI)" "baixe manual: curl -fsSL $SL_URL -o $SL_BIN && chmod +x $SL_BIN"
  fi

  # Liga a statusline no ~/.claude/settings.json — so se ainda NAO houver uma
  # (preserva o resto do arquivo e nao sobrescreve uma statusline customizada).
  SETTINGS="$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  if command -v jq &>/dev/null && command -v claude-statusline &>/dev/null; then
    if jq -e '.statusLine' "$SETTINGS" >/dev/null 2>&1; then
      pular "Statusline ja configurada no settings.json"
    else
      TMP_SET="$(mktemp)"
      if jq '.statusLine = {"type":"command","command":"claude-statusline"}' "$SETTINGS" > "$TMP_SET" 2>/dev/null && mv "$TMP_SET" "$SETTINGS"; then
        ok "Statusline ligada no Claude Code (settings.json)"
      else
        rm -f "$TMP_SET"
        erro "Statusline (settings.json)" "adicione \"statusLine\": {\"type\":\"command\",\"command\":\"claude-statusline\"} no ~/.claude/settings.json"
      fi
    fi
  elif ! command -v jq &>/dev/null; then
    erro "Statusline (settings.json)" "jq ausente — rode 'brew install jq' e adicione \"statusLine\": {\"type\":\"command\",\"command\":\"claude-statusline\"} no ~/.claude/settings.json"
  fi
else
  erro "Statusline" "Claude Code nao foi instalado — resolva o passo 6 e rode de novo"
fi

# -----------------------------------------------------------
# 11) Verificacao final
# -----------------------------------------------------------
echo ""
echo -e "${BLUE}[11/$TOTAL]${NC} Verificacao final..."
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
verificar "ToStudy CLI"     "tostudy" ""
# Statusline: smoke test real (JSON no stdin, exit 0). NAO usar --version (le stdin, travaria);
# so checar presenca mascararia um bin quebrado.
if command -v claude-statusline &>/dev/null && \
   printf '{"model":{"display_name":"x"},"cwd":"%s","workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":0}}' "$HOME" "$HOME" | claude-statusline >/dev/null 2>&1; then
  echo -e "  ${GREEN}OK${NC}  Statusline PG  (claude-statusline)"
else
  echo -e "  ${RED}X${NC}   Statusline PG  — NAO ENCONTRADO ou nao executa"
fi

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
echo -e "${YELLOW}============================================================${NC}"
echo -e "${YELLOW}  IMPORTANTE: feche e reabra o Claude Code UMA vez.${NC}"
echo -e "${YELLOW}  Os comandos /imersao:* so aparecem DEPOIS de reabrir.${NC}"
echo -e "${YELLOW}============================================================${NC}"

echo ""
echo -e "${BLUE}LEMBRETE — Falta fazer manualmente (nesta ordem):${NC}"
echo "  1. Assinar o Claude Max \$200/mes:  https://claude.ai"
echo "     (o plano gratuito NAO aguenta a imersao — assine ANTES do dia 1)"
echo "  2. Reabrir o terminal, rodar 'claude' e fazer login na 1a vez"
echo "     (sem isso NADA responde; as skills do plugin carregam quando o Claude Code reinicia)"
echo "  3. Criar conta no GitHub (gratis): https://github.com/"
echo "     e autenticar no terminal:  gh auth login"
echo "     (no fim da imersao seu projeto SOBE pro GitHub)"
echo "  4. Criar conta no Railway e assinar o Hobby (US\$5/mes, exige cartao): https://railway.app/"
echo "     (e onde seu app vai pro ar no fim; o Trial gratis de US\$5 sem cartao testa o"
echo "      deploy, mas pra MANTER no ar precisa do Hobby — assine antes do dia 1)"
echo "  5. Abrir o Docker Desktop 1x e esperar a baleia parar de animar"
echo "     (a Fase 3 usa o Docker pro banco de dados)"
echo ""
echo -e "${BLUE}PROXIMOS PASSOS:${NC}"
echo "  - Guia do dia 1:    https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/PRIMEIROS-PASSOS.md"
echo "  - Deu erro?         https://github.com/parisgroup-ai/imersao-ia-setup/blob/main/docs/TROUBLESHOOTING.md"
echo "  - Conferir tudo:    curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/check.sh | bash"
echo "  - Skills novas:     claude plugin update imersao  (atualiza durante a imersao)"
echo ""
echo -e "${BLUE}Usa Codex tambem?${NC} As skills viram plugin so no Claude Code. Pro Codex, rode:"
echo -e "  ${BLUE}curl -fsSL https://raw.githubusercontent.com/parisgroup-ai/imersao-ia-setup/main/scripts/sync-codex-skills.sh | bash${NC}"
echo ""
echo -e "${GREEN}Nos vemos na imersao! 🚀${NC}"
echo ""
