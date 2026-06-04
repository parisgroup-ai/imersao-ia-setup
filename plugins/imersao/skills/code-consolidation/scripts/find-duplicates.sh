#!/bin/bash
#
# find-duplicates.sh - Automated duplicate detection for code consolidation
#
# Usage:
#   ./find-duplicates.sh [path] [--ts|--py|--all]
#
# Examples:
#   ./find-duplicates.sh .                    # All patterns in current dir
#   ./find-duplicates.sh src --ts             # TypeScript only
#   ./find-duplicates.sh apps/service --py    # Python only

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SEARCH_PATH="${1:-.}"
LANG_FILTER="${2:---all}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Code Duplication Analysis Report                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Search Path: ${GREEN}$SEARCH_PATH${NC}"
echo -e "Language: ${GREEN}${LANG_FILTER#--}${NC}"
echo -e "Generated: $(date)"
echo ""

# Function to find TypeScript duplicates
find_ts_duplicates() {
    echo -e "${YELLOW}═══ TypeScript/JavaScript Analysis ═══${NC}"
    echo ""

    # Duplicate type/interface names
    echo -e "${BLUE}► Duplicate Type/Interface Names:${NC}"
    grep -rhn "export type \|export interface " "$SEARCH_PATH" \
        --include="*.ts" --include="*.tsx" 2>/dev/null | \
        sed 's/.*export type \([A-Za-z0-9_]*\).*/\1/' | \
        sed 's/.*export interface \([A-Za-z0-9_]*\).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 1 {printf "  %-30s %d occurrences\n", $2, $1}' | head -15 || echo "  None found"
    echo ""

    # Duplicate class names (especially errors)
    echo -e "${BLUE}► Duplicate Error Classes:${NC}"
    grep -rhn "class [A-Za-z0-9_]*Error" "$SEARCH_PATH" \
        --include="*.ts" --include="*.tsx" 2>/dev/null | \
        sed 's/.*class \([A-Za-z0-9_]*Error\).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 1 {printf "  %-30s %d occurrences\n", $2, $1}' | head -15 || echo "  None found"
    echo ""

    # Configuration objects
    echo -e "${BLUE}► Configuration Patterns:${NC}"
    count=$(grep -rn "STATUS_CONFIG\|VARIANT_CONFIG\|STATE_CONFIG" "$SEARCH_PATH" \
        --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')
    echo "  Found $count config pattern occurrences"
    echo ""

    # Factory functions
    echo -e "${BLUE}► Factory Functions:${NC}"
    grep -rhn "export function create" "$SEARCH_PATH" \
        --include="*.ts" 2>/dev/null | \
        sed 's/.*export function \(create[A-Za-z0-9_]*\).*/\1/' | \
        sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %-30s %d occurrences\n", $2, $1}' || echo "  None found"
    echo ""

    # Duplicate hook names
    echo -e "${BLUE}► Duplicate Hooks:${NC}"
    grep -rhn "export function use" "$SEARCH_PATH" \
        --include="*.ts" --include="*.tsx" 2>/dev/null | \
        sed 's/.*export function \(use[A-Za-z0-9_]*\).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 1 {printf "  %-30s %d occurrences\n", $2, $1}' | head -15 || echo "  None found"
    echo ""
}

# Function to find Python duplicates
find_py_duplicates() {
    echo -e "${YELLOW}═══ Python Analysis ═══${NC}"
    echo ""

    # Duplicate exception classes
    echo -e "${BLUE}► Duplicate Error Classes:${NC}"
    grep -rhn "class [A-Za-z0-9_]*Error\|class [A-Za-z0-9_]*Exception" "$SEARCH_PATH" \
        --include="*.py" 2>/dev/null | \
        grep -v "__pycache__" | \
        sed 's/.*class \([A-Za-z0-9_]*\(Error\|Exception\)\).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 1 {printf "  %-30s %d occurrences\n", $2, $1}' | head -15 || echo "  None found"
    echo ""

    # Pydantic models
    echo -e "${BLUE}► Duplicate Pydantic Models:${NC}"
    grep -rhn "class [A-Za-z0-9_]*(BaseModel)" "$SEARCH_PATH" \
        --include="*.py" 2>/dev/null | \
        grep -v "__pycache__" | \
        sed 's/.*class \([A-Za-z0-9_]*\)(BaseModel).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 1 {printf "  %-30s %d occurrences\n", $2, $1}' | head -15 || echo "  None found"
    echo ""

    # Utility functions (more than 2 occurrences)
    echo -e "${BLUE}► Repeated Function Names (>2):${NC}"
    grep -rhn "^def [a-z_][a-z0-9_]*" "$SEARCH_PATH" \
        --include="*.py" 2>/dev/null | \
        grep -v "__pycache__" | \
        sed 's/.*def \([a-z_][a-z0-9_]*\).*/\1/' | \
        sort | uniq -c | sort -rn | \
        awk '$1 > 2 {printf "  %-30s %d occurrences\n", $2, $1}' | head -20 || echo "  None found"
    echo ""
}

# Function to generate summary
generate_summary() {
    echo -e "${YELLOW}═══ Summary ═══${NC}"
    echo ""

    local ts_types=$(grep -rhn "export type \|export interface " "$SEARCH_PATH" \
        --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')
    local ts_errors=$(grep -rhn "class [A-Za-z0-9_]*Error" "$SEARCH_PATH" \
        --include="*.ts" 2>/dev/null | wc -l | tr -d ' ')
    local py_errors=$(grep -rhn "class [A-Za-z0-9_]*Error" "$SEARCH_PATH" \
        --include="*.py" 2>/dev/null | grep -v "__pycache__" | wc -l | tr -d ' ')

    echo -e "  TypeScript type exports:  ${GREEN}$ts_types${NC}"
    echo -e "  TypeScript error classes: ${GREEN}$ts_errors${NC}"
    echo -e "  Python error classes:     ${GREEN}$py_errors${NC}"
    echo ""
}

# Main execution
case "$LANG_FILTER" in
    --ts)
        find_ts_duplicates
        ;;
    --py)
        find_py_duplicates
        ;;
    --all|*)
        find_ts_duplicates
        find_py_duplicates
        generate_summary
        ;;
esac

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "Report complete. Use ${GREEN}grep -rn${NC} for detailed locations."
