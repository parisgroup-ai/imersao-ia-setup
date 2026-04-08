#!/usr/bin/env bash
# audit-readmes.sh - Audit README and AGENTS files in monorepo
#
# Usage:
#   ./audit-readmes.sh              # Audit all packages and apps
#   ./audit-readmes.sh packages/api # Audit specific path
#   ./audit-readmes.sh --missing    # Only show missing files
#   ./audit-readmes.sh --json       # Output as JSON

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
MISSING_README=0
MISSING_AGENTS=0
OUTDATED=0
BROKEN_LINKS=0

# Options
SPECIFIC_PATH=""
MISSING_ONLY=false
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --missing)
      MISSING_ONLY=true
      shift
      ;;
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    *)
      SPECIFIC_PATH="$1"
      shift
      ;;
  esac
done

# Header
if ! $JSON_OUTPUT; then
  echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}                    README AUDIT REPORT                         ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
fi

# Function to check if file exists
check_file() {
  local path=$1
  local file=$2
  if [[ -f "$path/$file" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to validate README content
validate_readme() {
  local readme=$1
  local pkg_json="${readme%README.md}package.json"
  local issues=()

  # Check package name match
  if [[ -f "$pkg_json" ]]; then
    local pkg_name=$(jq -r '.name' "$pkg_json" 2>/dev/null || echo "")
    local readme_title=$(head -1 "$readme" | sed 's/^# //')

    if [[ -n "$pkg_name" && "$readme_title" != "$pkg_name" ]]; then
      issues+=("Package name mismatch: README='$readme_title' vs package.json='$pkg_name'")
    fi
  fi

  # Check for required sections
  local content=$(cat "$readme")

  if ! echo "$content" | grep -q "^## Usage"; then
    issues+=("Missing '## Usage' section")
  fi

  # Check for code blocks without language
  if echo "$content" | grep -q '```$'; then
    issues+=("Code block without language identifier")
  fi

  # Output issues
  for issue in "${issues[@]}"; do
    echo "  - $issue"
  done

  return ${#issues[@]}
}

# Function to check internal links
check_links() {
  local file=$1
  local dir=$(dirname "$file")
  local issues=()

  # Extract markdown links
  local links=$(grep -oE '\[.*\]\([^)]+\)' "$file" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' || true)

  for link in $links; do
    # Skip external URLs
    if [[ "$link" =~ ^https?:// ]]; then
      continue
    fi

    # Skip anchor links
    if [[ "$link" =~ ^# ]]; then
      continue
    fi

    # Check relative file links
    local target="$dir/$link"
    target=$(echo "$target" | sed 's/#.*//')  # Remove anchor

    if [[ ! -f "$target" && ! -d "$target" ]]; then
      issues+=("Broken link: $link")
      ((BROKEN_LINKS++))
    fi
  done

  for issue in "${issues[@]}"; do
    echo "  - $issue"
  done
}

# Audit packages
audit_packages() {
  local path_filter="${1:-packages/*}"

  if ! $JSON_OUTPUT; then
    echo -e "${YELLOW}📦 Packages${NC}"
    echo ""
  fi

  for pkg in $path_filter/; do
    [[ -d "$pkg" ]] || continue
    [[ "$pkg" == *node_modules* ]] && continue

    local pkg_name=$(basename "$pkg")
    local has_readme=false
    local has_agents=false

    if check_file "$pkg" "README.md"; then
      has_readme=true
    else
      ((MISSING_README++))
    fi

    if check_file "$pkg" "AGENTS.md"; then
      has_agents=true
    else
      ((MISSING_AGENTS++))
    fi

    if ! $JSON_OUTPUT; then
      if $has_readme && $has_agents; then
        if ! $MISSING_ONLY; then
          echo -e "${GREEN}✓${NC} $pkg_name"
          # Validate content
          validate_readme "$pkg/README.md"
          check_links "$pkg/README.md"
        fi
      elif $has_readme; then
        echo -e "${YELLOW}⚠${NC} $pkg_name - Missing AGENTS.md"
      elif $has_agents; then
        echo -e "${YELLOW}⚠${NC} $pkg_name - Missing README.md"
      else
        echo -e "${RED}✗${NC} $pkg_name - Missing README.md and AGENTS.md"
      fi
    fi
  done

  echo ""
}

# Audit apps
audit_apps() {
  local path_filter="${1:-apps/*}"

  if ! $JSON_OUTPUT; then
    echo -e "${YELLOW}🚀 Apps${NC}"
    echo ""
  fi

  for app in $path_filter/; do
    [[ -d "$app" ]] || continue
    [[ "$app" == *node_modules* ]] && continue

    local app_name=$(basename "$app")
    local has_readme=false
    local has_agents=false

    if check_file "$app" "README.md"; then
      has_readme=true
    else
      ((MISSING_README++))
    fi

    if check_file "$app" "AGENTS.md"; then
      has_agents=true
    else
      ((MISSING_AGENTS++))
    fi

    if ! $JSON_OUTPUT; then
      if $has_readme && $has_agents; then
        if ! $MISSING_ONLY; then
          echo -e "${GREEN}✓${NC} $app_name"
          validate_readme "$app/README.md"
          check_links "$app/README.md"
        fi
      elif $has_readme; then
        echo -e "${YELLOW}⚠${NC} $app_name - Missing AGENTS.md"
      elif $has_agents; then
        echo -e "${YELLOW}⚠${NC} $app_name - Missing README.md"
      else
        echo -e "${RED}✗${NC} $app_name - Missing README.md and AGENTS.md"
      fi
    fi
  done

  echo ""
}

# Main
if [[ -n "$SPECIFIC_PATH" ]]; then
  if [[ "$SPECIFIC_PATH" == packages/* ]]; then
    audit_packages "$SPECIFIC_PATH"
  elif [[ "$SPECIFIC_PATH" == apps/* ]]; then
    audit_apps "$SPECIFIC_PATH"
  else
    echo "Path must start with 'packages/' or 'apps/'"
    exit 1
  fi
else
  audit_packages
  audit_apps
fi

# Summary
if ! $JSON_OUTPUT; then
  echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}                         SUMMARY                                ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "Missing README.md:  ${RED}$MISSING_README${NC}"
  echo -e "Missing AGENTS.md:  ${RED}$MISSING_AGENTS${NC}"
  echo -e "Broken links:       ${YELLOW}$BROKEN_LINKS${NC}"
  echo ""

  if [[ $MISSING_README -eq 0 && $MISSING_AGENTS -eq 0 && $BROKEN_LINKS -eq 0 ]]; then
    echo -e "${GREEN}✓ All documentation files present and valid!${NC}"
  else
    echo -e "${YELLOW}Run '/readme generate <path>' to create missing files${NC}"
  fi
fi
