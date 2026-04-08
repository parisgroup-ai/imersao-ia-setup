---
name: sync-skills
description: "Sync shared skills from parisgroup-ai/imersao-ia-setup to your local environment. Supports Claude Code and Codex. Use without args to sync all, or specify skill names to sync selectively."
version: 1.0.0
author: gustavo
tags: [meta, tooling]
---

# Sync Skills

You are executing the **sync-skills** meta-skill. Follow these steps exactly using bash commands.

## Step 1: Clone or update the skills cache

Run the following to ensure `~/.ai-skills-cache` is up to date:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
REPO_URL="https://github.com/parisgroup-ai/imersao-ia-setup.git"

if [ ! -d "$CACHE_DIR/.git" ]; then
  echo ">>> Cloning skills repo into $CACHE_DIR..."
  git clone "$REPO_URL" "$CACHE_DIR"
else
  # Check if cache is older than 24 hours
  LAST_FETCH="$CACHE_DIR/.git/FETCH_HEAD"
  if [ ! -f "$LAST_FETCH" ] || [ $(find "$LAST_FETCH" -mmin +1440 2>/dev/null | wc -l) -gt 0 ]; then
    echo ">>> Cache is stale (>24h). Pulling latest..."
    git -C "$CACHE_DIR" pull --ff-only
  else
    echo ">>> Cache is fresh (updated within 24h). Skipping pull."
  fi
fi
```

## Step 2: Detect installed tools

Determine which AI coding tools are installed by checking for their skills directories. Run:

```bash
TARGETS=()

if [ -d "$HOME/.claude" ]; then
  mkdir -p "$HOME/.claude/skills"
  TARGETS+=("claude:$HOME/.claude/skills")
  echo ">>> Detected: Claude Code (~/.claude/skills/)"
fi

if [ -d "$HOME/.agents" ]; then
  mkdir -p "$HOME/.agents/skills"
  TARGETS+=("codex:$HOME/.agents/skills")
  echo ">>> Detected: Codex (~/.agents/skills/)"
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "ERROR: No supported AI tools detected. Expected ~/.claude/ or ~/.agents/ to exist."
  echo "Create the directory for your tool first, then re-run."
  exit 1
fi
```

If no tools are detected, stop and report the error to the user.

## Step 3: Copy skills

### Determine which skills to sync

Check if the user provided specific skill names as arguments (e.g., `/sync-skills api-design clean-architecture`). If arguments were provided, only sync those. Otherwise sync all.

Run the full sync script below. **Replace `REQUESTED_SKILLS` with the space-separated list of skill names the user provided, or leave it empty to sync all.**

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
REQUESTED_SKILLS=""  # Set to "skill1 skill2" if user provided args, or leave empty for all

SYNCED_SKILLS=()
SYNCED_META=()
ERRORS=()

# --- Sync regular skills from skills/ ---
if [ -z "$REQUESTED_SKILLS" ]; then
  # Sync ALL skills
  for skill_dir in "$CACHE_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    [ "$skill_name" = ".gitkeep" ] && continue
    for target_entry in "${TARGETS[@]}"; do
      tool_name="${target_entry%%:*}"
      target_dir="${target_entry#*:}"
      cp -r "$skill_dir" "$target_dir/$skill_name"
    done
    SYNCED_SKILLS+=("$skill_name")
  done
else
  # Sync only requested skills
  for skill_name in $REQUESTED_SKILLS; do
    skill_dir="$CACHE_DIR/skills/$skill_name"
    if [ ! -d "$skill_dir" ]; then
      ERRORS+=("Skill not found: $skill_name")
      continue
    fi
    for target_entry in "${TARGETS[@]}"; do
      tool_name="${target_entry%%:*}"
      target_dir="${target_entry#*:}"
      cp -r "$skill_dir" "$target_dir/$skill_name"
    done
    SYNCED_SKILLS+=("$skill_name")
  done
fi

# --- Always sync meta skills (so sync-skills and share-skill self-update) ---
for meta_dir in "$CACHE_DIR"/meta/*/; do
  [ -d "$meta_dir" ] || continue
  meta_name=$(basename "$meta_dir")
  [ "$meta_name" = ".gitkeep" ] && continue
  for target_entry in "${TARGETS[@]}"; do
    tool_name="${target_entry%%:*}"
    target_dir="${target_entry#*:}"
    mkdir -p "$target_dir/$meta_name"
    cp -r "$meta_dir"* "$target_dir/$meta_name/"
  done
  SYNCED_META+=("$meta_name")
done

# --- Report ---
echo ""
echo "========== Sync Complete =========="
TOOL_NAMES=""
for target_entry in "${TARGETS[@]}"; do
  tool_name="${target_entry%%:*}"
  TOOL_NAMES="$TOOL_NAMES $tool_name"
done
echo "Tools:  $TOOL_NAMES"
echo "Skills: ${SYNCED_SKILLS[*]:-none}"
echo "Meta:   ${SYNCED_META[*]:-none}"
TOTAL=$(( ${#SYNCED_SKILLS[@]} + ${#SYNCED_META[@]} ))
echo "Total:  $TOTAL skill(s) synced"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Warnings:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
fi
echo "==================================="
```

## Step 4: Report to the user

After running the commands above, summarize:
- Which tools were detected (Claude Code, Codex, or both)
- How many skills were synced and their names
- Any errors (e.g., requested skill not found)
- Remind the user they can run `/sync-skills` again anytime, or `/sync-skills <name>` for selective sync
