#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# collect-stats.sh — Portable project statistics collector (v2 — fast)
#
# Works on any git project. Outputs JSON to stdout.
# Auto-detects: languages, monorepo, test files, deps, frameworks.
#
# Performance: Single find pass + xargs wc for LOC (10x faster than v1).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ─── Helpers ─────────────────────────────────────────────────────────────────
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'; }
safe_num() { local v="${1:-0}"; echo "${v:-0}" | tr -d ' '; }

# ─── Project Root ────────────────────────────────────────────────────────────
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"
PROJECT_NAME=$(basename "$ROOT")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_SLUG=$(date +"%Y-%m-%d")

# ─── Exclude pattern (reused everywhere) ────────────────────────────────────
EXCLUDE_DIRS="node_modules|\.next|dist|build|\.git|__pycache__|target|\.turbo|vendor|\.expo|\.worktrees|coverage|\.cache"

# ─── Single find pass: collect all source files into a temp file ─────────────
TMPFILES=$(mktemp)
trap 'rm -f "$TMPFILES"' EXIT

find . -type f \( \
  -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
  -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
  -o -name "*.css" -o -name "*.scss" -o -name "*.html" \
  -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.md" -o -name "*.sh" -o -name "*.sql" \
  -o -name "*.php" -o -name "*.swift" -o -name "*.kt" \
\) 2>/dev/null | grep -vE "/($EXCLUDE_DIRS)/" > "$TMPFILES" || true

# ─── Count files by extension from the cached list ──────────────────────────
count_ext() {
  local n
  n=$(grep -cE "\.$1$" "$TMPFILES" 2>/dev/null) || n=0
  echo "$n"
}

TS_FILES=$(count_ext "ts")
TSX_FILES=$(count_ext "tsx")
JS_FILES=$(count_ext "js")
JSX_FILES=$(count_ext "jsx")
PY_FILES=$(count_ext "py")
GO_FILES=$(count_ext "go")
RS_FILES=$(count_ext "rs")
JAVA_FILES=$(count_ext "java")
CSS_FILES=$(count_ext "css")
SCSS_FILES=$(count_ext "scss")
HTML_FILES=$(count_ext "html")
JSON_FILES=$(count_ext "json")
YAML_FILES=$(count_ext "yml")
YAML2_FILES=$(count_ext "yaml")
MD_FILES=$(count_ext "md")
SH_FILES=$(count_ext "sh")
SQL_FILES=$(count_ext "sql")
PHP_FILES=$(count_ext "php")
SWIFT_FILES=$(count_ext "swift")
KOTLIN_FILES=$(count_ext "kt")

# ─── LOC counts via xargs wc -l (fast: wc reads files directly) ─────────────
loc_for_ext() {
  local ext="$1"
  local files
  files=$(grep -E "\.$ext$" "$TMPFILES" 2>/dev/null || true)
  if [ -z "$files" ]; then
    echo 0
    return
  fi
  # Sum individual file counts, filtering out "total" lines from xargs batches
  echo "$files" | xargs wc -l 2>/dev/null | grep -v " total$" | awk '{s+=$1} END{print s+0}'
}

TS_LOC=$(loc_for_ext "ts")
TSX_LOC=$(loc_for_ext "tsx")
JS_LOC=$(loc_for_ext "js")
JSX_LOC=$(loc_for_ext "jsx")
PY_LOC=$(loc_for_ext "py")
GO_LOC=$(loc_for_ext "go")
RS_LOC=$(loc_for_ext "rs")
CSS_LOC=$(loc_for_ext "css")
PHP_LOC=$(loc_for_ext "php")

TOTAL_SOURCE_FILES=$((TS_FILES + TSX_FILES + JS_FILES + JSX_FILES + PY_FILES + GO_FILES + RS_FILES + JAVA_FILES + CSS_FILES + SCSS_FILES + PHP_FILES + SWIFT_FILES + KOTLIN_FILES))
TOTAL_SOURCE_LOC=$((TS_LOC + TSX_LOC + JS_LOC + JSX_LOC + PY_LOC + GO_LOC + RS_LOC + CSS_LOC + PHP_LOC))

# ─── Test Files ──────────────────────────────────────────────────────────────
TEST_FILES_SPEC=$(grep -cE '\.spec\.' "$TMPFILES" 2>/dev/null) || TEST_FILES_SPEC=0
TEST_FILES_TEST=$(grep -cE '\.test\.' "$TMPFILES" 2>/dev/null) || TEST_FILES_TEST=0
TEST_FILES_PY=$(grep -cE '(^|/)test_.*\.py$|_test\.py$' "$TMPFILES" 2>/dev/null) || TEST_FILES_PY=0
E2E_FILES=$(grep -cE '/e2e/.*\.(spec|e2e)\.(ts|js)$' "$TMPFILES" 2>/dev/null) || E2E_FILES=0
TOTAL_TEST_FILES=$((TEST_FILES_SPEC + TEST_FILES_TEST + TEST_FILES_PY))

# ─── Git Stats ───────────────────────────────────────────────────────────────
GIT_TOTAL_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo 0)
GIT_COMMITS_TODAY=$(safe_num "$(git log --oneline --since="midnight" 2>/dev/null | wc -l)")
GIT_COMMITS_WEEK=$(safe_num "$(git log --oneline --since="1 week ago" 2>/dev/null | wc -l)")
GIT_COMMITS_MONTH=$(safe_num "$(git log --oneline --since="1 month ago" 2>/dev/null | wc -l)")
GIT_CONTRIBUTORS=$(safe_num "$(git shortlog -sn --all 2>/dev/null | wc -l)")
GIT_BRANCHES=$(safe_num "$(git branch -a 2>/dev/null | wc -l)")
GIT_TAGS=$(safe_num "$(git tag 2>/dev/null | wc -l)")
GIT_FIRST_COMMIT=$(git log --reverse --format="%aI" 2>/dev/null | head -1) || true
[ -z "$GIT_FIRST_COMMIT" ] && GIT_FIRST_COMMIT="unknown"
GIT_LAST_COMMIT=$(git log -1 --format="%aI" 2>/dev/null) || true
[ -z "$GIT_LAST_COMMIT" ] && GIT_LAST_COMMIT="unknown"
GIT_DIRTY=$(safe_num "$(git status --porcelain 2>/dev/null | wc -l)")
GIT_UNPUSHED=$(safe_num "$(git log --oneline @{upstream}..HEAD 2>/dev/null | wc -l)" || echo 0)

# Lines added/removed this week
OLDEST_WEEK_COMMIT=$(git log --since='1 week ago' --format='%H' 2>/dev/null | tail -1 || echo "")
if [ -n "$OLDEST_WEEK_COMMIT" ]; then
  WEEK_STATS=$(git diff --shortstat "$OLDEST_WEEK_COMMIT" HEAD 2>/dev/null || echo "")
else
  WEEK_STATS=""
fi
WEEK_ADDED=$(safe_num "$(echo "$WEEK_STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)")
WEEK_REMOVED=$(safe_num "$(echo "$WEEK_STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)")

# Commit types (single git log call, awk splits by type)
MONTHLY_LOG=$(git log --oneline --since="1 month ago" 2>/dev/null || true)
FEAT_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ feat' || echo 0)")
FIX_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ fix' || echo 0)")
CHORE_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ chore' || echo 0)")
REFACTOR_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ refactor' || echo 0)")
TEST_COMMIT_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ test' || echo 0)")
DOCS_COUNT=$(safe_num "$(echo "$MONTHLY_LOG" | grep -cE '^[a-f0-9]+ docs' || echo 0)")

# AI collaboration ratio
AI_COMMITS=$(safe_num "$(git log --since="1 month ago" --format="%b" 2>/dev/null | grep -c "Co-Authored-By:" || echo 0)")

# ─── Dependencies ────────────────────────────────────────────────────────────
NPM_DEPS=0
NPM_DEV_DEPS=0
if [ -f "package.json" ]; then
  NPM_DEPS=$(python3 -c "
import json
try:
  d = json.load(open('package.json'))
  print(len(d.get('dependencies', {})))
except: print(0)
" 2>/dev/null || echo 0)
  NPM_DEV_DEPS=$(python3 -c "
import json
try:
  d = json.load(open('package.json'))
  print(len(d.get('devDependencies', {})))
except: print(0)
" 2>/dev/null || echo 0)
fi

PY_DEPS=0
if [ -f "requirements.txt" ]; then
  PY_DEPS=$(grep -cvE '^\s*(#|$)' requirements.txt 2>/dev/null || echo 0)
elif [ -f "pyproject.toml" ]; then
  PY_DEPS=$(grep -cE '^\s*"[^"]+' pyproject.toml 2>/dev/null || echo 0)
fi

GO_DEPS=0
if [ -f "go.mod" ]; then
  GO_DEPS=$(grep -c "^\t" go.mod 2>/dev/null || echo 0)
fi

# ─── Monorepo Detection ─────────────────────────────────────────────────────
IS_MONOREPO=false
MONOREPO_TOOL="none"
WORKSPACE_COUNT=0
APPS_COUNT=0
PKGS_COUNT=0

if [ -f "turbo.json" ]; then
  IS_MONOREPO=true; MONOREPO_TOOL="turborepo"
elif [ -f "lerna.json" ]; then
  IS_MONOREPO=true; MONOREPO_TOOL="lerna"
elif [ -f "nx.json" ]; then
  IS_MONOREPO=true; MONOREPO_TOOL="nx"
elif [ -f "pnpm-workspace.yaml" ]; then
  IS_MONOREPO=true; MONOREPO_TOOL="pnpm-workspaces"
fi

if [ "$IS_MONOREPO" = true ]; then
  [ -d "apps" ] && APPS_COUNT=$(safe_num "$(ls -d apps/*/ 2>/dev/null | wc -l)")
  [ -d "packages" ] && PKGS_COUNT=$(safe_num "$(ls -d packages/*/ 2>/dev/null | wc -l)")
  WORKSPACE_COUNT=$((APPS_COUNT + PKGS_COUNT))
fi

# ─── Framework Detection ────────────────────────────────────────────────────
FRAMEWORKS=""
detect_fw() {
  for f in $2; do
    if [ -f "$f" ]; then FRAMEWORKS="${FRAMEWORKS}\"$1\","; return 0; fi
  done
  return 0
}
detect_fw "Next.js" "next.config.ts next.config.js next.config.mjs"
detect_fw "Vite" "vite.config.ts vite.config.js"
detect_fw "Nuxt" "nuxt.config.ts nuxt.config.js"
detect_fw "Angular" "angular.json"
detect_fw "SvelteKit" "svelte.config.js"
detect_fw "Astro" "astro.config.mjs"
detect_fw "Remix" "remix.config.js"
detect_fw "Rust/Cargo" "Cargo.toml"
detect_fw "Go" "go.mod"
detect_fw "Django" "manage.py"
detect_fw "Ruby/Rails" "Gemfile"
detect_fw "PHP/Composer" "composer.json"
# Expo detection (needs content check)
if [ -f "app.json" ] && grep -q "expo" "app.json" 2>/dev/null; then FRAMEWORKS="${FRAMEWORKS}\"Expo\","; fi
# FastAPI detection
for f in app.py main.py; do
  if [ -f "$f" ] && grep -ql "fastapi\|FastAPI" "$f" 2>/dev/null; then FRAMEWORKS="${FRAMEWORKS}\"FastAPI\","; fi
done
FRAMEWORKS="${FRAMEWORKS%,}"

# ─── TODOs & FIXMEs (from cached file list) ─────────────────────────────────
SOURCE_FILES_FOR_GREP=$(grep -E '\.(ts|tsx|js|jsx|py|go|rs|php)$' "$TMPFILES" 2>/dev/null || true)
if [ -n "$SOURCE_FILES_FOR_GREP" ]; then
  TODO_COUNT=$(safe_num "$(echo "$SOURCE_FILES_FOR_GREP" | xargs grep -l "TODO" 2>/dev/null | wc -l)")
  FIXME_COUNT=$(safe_num "$(echo "$SOURCE_FILES_FOR_GREP" | xargs grep -lE "FIXME|HACK|XXX" 2>/dev/null | wc -l)")
else
  TODO_COUNT=0
  FIXME_COUNT=0
fi

# ─── i18n ────────────────────────────────────────────────────────────────────
I18N_KEYS=0
I18N_LOCALES="[]"
I18N_DIR=""
for d in messages locales public/locales src/locales; do
  [ -d "$d" ] && { I18N_DIR="$d"; break; }
done
if [ -n "$I18N_DIR" ]; then
  I18N_LOCALES_LIST=$(ls "$I18N_DIR"/*.json 2>/dev/null | xargs -I{} basename {} .json | sort || true)
  if [ -n "$I18N_LOCALES_LIST" ]; then
    I18N_LOCALES="[$(echo "$I18N_LOCALES_LIST" | sed 's/.*/"&"/' | paste -sd, -)]"
    FIRST_LOCALE=$(echo "$I18N_LOCALES_LIST" | head -1)
    I18N_KEYS=$(python3 -c "
import json
def count_keys(obj):
    c = 0
    if isinstance(obj, dict):
        for v in obj.values():
            c += count_keys(v) if isinstance(v, dict) else 1
    return c
try: print(count_keys(json.load(open('$I18N_DIR/$FIRST_LOCALE.json'))))
except: print(0)
" 2>/dev/null || echo 0)
  fi
fi

# ─── Docker ──────────────────────────────────────────────────────────────────
DOCKERFILE_COUNT=$(find . -maxdepth 3 -name "Dockerfile*" -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
COMPOSE_EXISTS=false
for f in docker-compose.yml docker-compose.yaml docker/docker-compose.yml compose.yml compose.yaml; do
  [ -f "$f" ] && { COMPOSE_EXISTS=true; break; }
done

# ─── Build JSON ──────────────────────────────────────────────────────────────
cat <<ENDJSON
{
  "meta": {
    "project": "$(json_escape "$PROJECT_NAME")",
    "timestamp": "$TIMESTAMP",
    "date": "$DATE_SLUG",
    "version": "2.0.0"
  },
  "git": {
    "totalCommits": $GIT_TOTAL_COMMITS,
    "commitsToday": $GIT_COMMITS_TODAY,
    "commitsThisWeek": $GIT_COMMITS_WEEK,
    "commitsThisMonth": $GIT_COMMITS_MONTH,
    "contributors": $GIT_CONTRIBUTORS,
    "branches": $GIT_BRANCHES,
    "tags": $GIT_TAGS,
    "dirtyFiles": $GIT_DIRTY,
    "unpushedCommits": $GIT_UNPUSHED,
    "firstCommit": "$(json_escape "$GIT_FIRST_COMMIT")",
    "lastCommit": "$(json_escape "$GIT_LAST_COMMIT")",
    "weeklyVelocity": {
      "linesAdded": $WEEK_ADDED,
      "linesRemoved": $WEEK_REMOVED,
      "netLines": $((WEEK_ADDED - WEEK_REMOVED))
    },
    "commitTypes": {
      "feat": $FEAT_COUNT,
      "fix": $FIX_COUNT,
      "chore": $CHORE_COUNT,
      "refactor": $REFACTOR_COUNT,
      "test": $TEST_COMMIT_COUNT,
      "docs": $DOCS_COUNT
    },
    "aiCollabCommits": $AI_COMMITS
  },
  "codebase": {
    "totalSourceFiles": $TOTAL_SOURCE_FILES,
    "totalSourceLOC": $TOTAL_SOURCE_LOC,
    "languages": {
      "typescript": { "files": $((TS_FILES + TSX_FILES)), "loc": $((TS_LOC + TSX_LOC)), "breakdown": { "ts": $TS_FILES, "tsx": $TSX_FILES } },
      "javascript": { "files": $((JS_FILES + JSX_FILES)), "loc": $((JS_LOC + JSX_LOC)), "breakdown": { "js": $JS_FILES, "jsx": $JSX_FILES } },
      "python": { "files": $PY_FILES, "loc": $PY_LOC },
      "go": { "files": $GO_FILES, "loc": $GO_LOC },
      "rust": { "files": $RS_FILES, "loc": $RS_LOC },
      "css": { "files": $((CSS_FILES + SCSS_FILES)), "loc": $CSS_LOC },
      "php": { "files": $PHP_FILES, "loc": $PHP_LOC },
      "java": { "files": $JAVA_FILES },
      "swift": { "files": $SWIFT_FILES },
      "kotlin": { "files": $KOTLIN_FILES }
    },
    "other": {
      "json": $JSON_FILES,
      "yaml": $((YAML_FILES + YAML2_FILES)),
      "markdown": $MD_FILES,
      "shell": $SH_FILES,
      "sql": $SQL_FILES,
      "html": $HTML_FILES
    }
  },
  "testing": {
    "unitTestFiles": $TOTAL_TEST_FILES,
    "e2eTestFiles": $E2E_FILES,
    "specFiles": $TEST_FILES_SPEC,
    "testFiles": $TEST_FILES_TEST,
    "pythonTestFiles": $TEST_FILES_PY
  },
  "dependencies": {
    "npm": { "production": $NPM_DEPS, "dev": $NPM_DEV_DEPS },
    "python": $PY_DEPS,
    "go": $GO_DEPS
  },
  "infrastructure": {
    "monorepo": $IS_MONOREPO,
    "monorepoTool": "$MONOREPO_TOOL",
    "workspaceCount": $WORKSPACE_COUNT,
    "apps": $APPS_COUNT,
    "packages": $PKGS_COUNT,
    "frameworks": [$FRAMEWORKS],
    "dockerfiles": $DOCKERFILE_COUNT,
    "dockerCompose": $COMPOSE_EXISTS
  },
  "quality": {
    "todos": $TODO_COUNT,
    "fixmes": $FIXME_COUNT
  },
  "i18n": {
    "keys": $I18N_KEYS,
    "locales": $I18N_LOCALES
  }
}
ENDJSON
