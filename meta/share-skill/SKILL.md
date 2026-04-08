---
name: share-skill
description: "Share a local skill to the parisgroup-ai/imersao-ia-setup repo. Push direct to main by default, or use --pr flag to create a pull request for review."
version: 1.1.0
author: gustavo
tags: [meta, tooling]
---

# Share Skill

You are executing the **share-skill** meta-skill. Follow these steps exactly using bash commands.

## Step 1: Parse arguments

The user must provide a skill name as the first argument (e.g., `/share-skill api-design`).
An optional `--pr` flag means you should create a pull request instead of pushing directly to main.

Parse the invocation:
- **Skill name**: required. If missing, stop and tell the user: `Usage: /share-skill <skill-name> [--pr]`
- **--pr flag**: optional. If present, you will use the PR flow (Step 8b). If absent, use the direct push flow (Step 8a).

Set these variables for later steps. **Replace `SKILL_NAME` with the actual name the user provided, and set `USE_PR` to `true` or `false`.**

```bash
SKILL_NAME=""   # e.g. "api-design"
USE_PR=false    # set to true if --pr flag was provided
```

## Step 2: Locate the skill

Search for the skill SKILL.md in local tool directories. Run:

```bash
SKILL_NAME=""  # replace with actual skill name

SKILL_SOURCE=""

if [ -f "$HOME/.claude/skills/$SKILL_NAME/SKILL.md" ]; then
  SKILL_SOURCE="$HOME/.claude/skills/$SKILL_NAME"
  echo ">>> Found skill in Claude Code: $SKILL_SOURCE"
elif [ -f "$HOME/.agents/skills/$SKILL_NAME/SKILL.md" ]; then
  SKILL_SOURCE="$HOME/.agents/skills/$SKILL_NAME"
  echo ">>> Found skill in Codex: $SKILL_SOURCE"
else
  echo "ERROR: Skill '$SKILL_NAME' not found."
  echo "Searched:"
  echo "  - ~/.claude/skills/$SKILL_NAME/SKILL.md"
  echo "  - ~/.agents/skills/$SKILL_NAME/SKILL.md"
  echo ""
  echo "Make sure the skill exists locally before sharing."
fi
```

If the skill was not found, stop and report the error to the user. Do not continue.

## Step 3: Validate frontmatter

Read the SKILL.md file and check that it contains valid YAML frontmatter with the required fields: `name`, `description`, and `version`. Run:

```bash
SKILL_FILE="$SKILL_SOURCE/SKILL.md"

# Check for frontmatter delimiters
if ! head -1 "$SKILL_FILE" | grep -q '^---$'; then
  echo "ERROR: SKILL.md is missing YAML frontmatter (no opening ---)."
  echo "Please add frontmatter with name, description, and version fields."
  exit 1
fi

# Extract frontmatter (between first and second ---)
FRONTMATTER=$(sed -n '2,/^---$/p' "$SKILL_FILE" | head -n -1)

MISSING=()
echo "$FRONTMATTER" | grep -q '^name:' || MISSING+=("name")
echo "$FRONTMATTER" | grep -q '^description:' || MISSING+=("description")
echo "$FRONTMATTER" | grep -q '^version:' || MISSING+=("version")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: SKILL.md frontmatter is missing required fields: ${MISSING[*]}"
  echo "Please add them before sharing."
  exit 1
fi

echo ">>> Frontmatter validated: name, description, version all present."
```

If validation fails, stop and ask the user to fix the frontmatter before re-running.

## Step 3b: Validate skill is org-appropriate

**BEFORE continuing, you MUST evaluate whether this skill is appropriate for the shared org repo.**

Read the full SKILL.md content and evaluate against these criteria:

**REJECT the skill if it is:**
- Tied to a specific project, product, or domain (e.g., dental, a specific client app, a specific database schema)
- References project-specific files, paths, or configurations that only make sense in one repo
- Only useful to one person or one team working on a specific product
- A wrapper around a very specific internal tool that others wouldn't use

**ACCEPT the skill if it is:**
- Applicable to any software project (e.g., API design, testing, Docker, security)
- Applicable to any Paris Group project using shared tools (e.g., PageShell, design system)
- About general development practices (e.g., code quality, i18n, logging)
- About tooling and workflow (e.g., git, CI/CD, documentation)

**If the skill is rejected:**
- Stop immediately
- Explain to the user WHY the skill is too specific
- Suggest they keep it as a local/project-level skill instead
- Do NOT continue to Step 4

**If the skill is accepted**, continue normally.

## Step 3c: Check for author conflict on existing skills

This step only applies if the skill already exists in the repo. Run:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
SKILL_NAME=""  # replace with actual skill name

EXISTING_SKILL="$CACHE_DIR/skills/$SKILL_NAME/SKILL.md"

if [ -f "$EXISTING_SKILL" ]; then
  EXISTING_AUTHOR=$(sed -n '/^---$/,/^---$/p' "$EXISTING_SKILL" | grep '^author:' | sed 's/^author:\s*//' | tr -d '"' | tr -d "'" | xargs)
  LOCAL_AUTHOR=$(sed -n '/^---$/,/^---$/p' "$SKILL_SOURCE/SKILL.md" | grep '^author:' | sed 's/^author:\s*//' | tr -d '"' | tr -d "'" | xargs)

  if [ -n "$EXISTING_AUTHOR" ] && [ -n "$LOCAL_AUTHOR" ] && [ "$EXISTING_AUTHOR" != "$LOCAL_AUTHOR" ]; then
    echo "WARNING: Skill '$SKILL_NAME' already exists in the repo and was created by '$EXISTING_AUTHOR'."
    echo "You ($LOCAL_AUTHOR) are about to overwrite it."
  fi
fi
```

**If the authors are different**, you MUST ask the user for confirmation before continuing:
- Tell them who the original author is
- Ask if they want to proceed and overwrite, or cancel
- Only continue if the user explicitly confirms

If the skill does not exist yet, or the authors match, continue normally.

## Step 4: Ensure the skills cache is fresh

Run the following to clone or update `~/.ai-skills-cache`:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
REPO_URL="https://github.com/parisgroup-ai/imersao-ia-setup.git"

if [ ! -d "$CACHE_DIR/.git" ]; then
  echo ">>> Cloning skills repo into $CACHE_DIR..."
  git clone "$REPO_URL" "$CACHE_DIR"
else
  echo ">>> Pulling latest from skills repo..."
  git -C "$CACHE_DIR" checkout main
  git -C "$CACHE_DIR" pull --ff-only
fi
```

## Step 5: Copy skill to cache

Copy the local skill folder into the cache repo's `skills/` directory:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
SKILL_NAME=""  # replace with actual skill name

mkdir -p "$CACHE_DIR/skills/$SKILL_NAME"
cp -r "$SKILL_SOURCE"/* "$CACHE_DIR/skills/$SKILL_NAME/"

echo ">>> Copied skill to $CACHE_DIR/skills/$SKILL_NAME/"
```

## Step 6: Detect add vs update

Check whether this skill already existed in the repo to choose the right commit message verb:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
SKILL_NAME=""  # replace with actual skill name

# Check if the skill existed before our copy (i.e., was already tracked by git)
if git -C "$CACHE_DIR" ls-files --error-unmatch "skills/$SKILL_NAME/SKILL.md" >/dev/null 2>&1; then
  ACTION="update"
  echo ">>> Skill '$SKILL_NAME' already exists in repo. This is an update."
else
  ACTION="add"
  echo ">>> Skill '$SKILL_NAME' is new. This is an addition."
fi
```

## Step 7: Commit the skill

Now stage the skill files. The commit and push approach depends on whether `--pr` was used.

### Step 8a: Default flow (push to main)

If `--pr` was NOT provided, push directly to main:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
SKILL_NAME=""  # replace with actual skill name
ACTION=""       # "add" or "update" from Step 6

cd "$CACHE_DIR"
git checkout main
git add "skills/$SKILL_NAME/"
git commit -m "feat: $ACTION $SKILL_NAME skill"
git push origin main

echo ""
echo "========== Share Complete =========="
echo "Skill:  $SKILL_NAME"
echo "Action: ${ACTION}d"
echo "Branch: main (direct push)"
echo "==================================="
```

### Step 8b: PR flow (with --pr flag)

If `--pr` was provided, create a branch and open a pull request:

```bash
CACHE_DIR="$HOME/.ai-skills-cache"
SKILL_NAME=""  # replace with actual skill name
ACTION=""       # "add" or "update" from Step 6

cd "$CACHE_DIR"
git checkout main
git checkout -b "skill/$SKILL_NAME"
git add "skills/$SKILL_NAME/"
git commit -m "feat: $ACTION $SKILL_NAME skill"
git push origin "skill/$SKILL_NAME"

PR_URL=$(gh pr create \
  --repo parisgroup-ai/imersao-ia-setup \
  --title "feat: $ACTION $SKILL_NAME skill" \
  --body "This PR ${ACTION}s the **$SKILL_NAME** skill.

Shared via the \`/share-skill\` meta-skill." \
  --base main \
  --head "skill/$SKILL_NAME" 2>&1)

echo ""
echo "========== Share Complete =========="
echo "Skill:  $SKILL_NAME"
echo "Action: ${ACTION}d"
echo "Branch: skill/$SKILL_NAME"
echo "PR:     $PR_URL"
echo "==================================="
```

**Only run Step 8a OR Step 8b**, depending on whether the `--pr` flag was provided.

## Step 9: Report to the user

After running the commands above, summarize:
- The skill name that was shared
- Whether it was an add or update
- Whether it was pushed to main or a PR was created (include the PR URL if applicable)
- Remind the user that teammates can run `/sync-skills` to pull the shared skill
