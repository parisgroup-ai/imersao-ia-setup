---
name: maestro-run
description: Use when running Maestro mobile tests on iOS Simulator and you need project-aware flow selection.
---

# maestro-run - Smart Maestro Test Runner

Run Maestro E2E flows against iOS Simulator with automatic project discovery, category detection, and structured output. Works with any mobile project (Expo, React Native, native Swift/Kotlin, Flutter, etc.).

## Usage

```bash
/maestro-run                    # Run all flows
/maestro-run smoke              # Category by name
/maestro-run auth               # Another category
/maestro-run <flow-file>        # Specific flow file
/maestro-run studio             # Open Maestro Studio (interactive)
```

## Step 1: Project Discovery

Maestro doesn't enforce a single convention for where flows live. Scan the project to find the right paths — the goal is zero configuration from the user.

```bash
# Find .maestro directories (could be at root, in an app subdir, etc.)
find . -name ".maestro" -type d -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null

# If multiple .maestro dirs found, prefer the one closest to cwd
# If none found, check for maestro/ (without dot) or flows/ at root

# Find config file
# Look for: .maestro/config.yaml, .maestro/config.yml, maestro.yaml
```

Extract from the discovered structure:

| What | How | Fallback |
|------|-----|----------|
| **Flows dir** | `<maestro-dir>/flows/` or `<maestro-dir>/` if flows are at root level | Ask user |
| **App bundle ID** | Parse from config.yaml (`appId`), or `app.json`/`app.config.js` (Expo), or `*.xcodeproj` (native iOS) | Ask user |
| **Shared sub-flows** | `<maestro-dir>/shared/` or any `_shared/`/`common/` directory | None needed |
| **Categories** | Subdirectories inside flows dir (each subdir = one category) | Treat all flows as uncategorized |

**Important:** Do NOT hardcode category names. Discover them dynamically:

```bash
# List categories (subdirectories of flows dir)
ls -d <flows-dir>/*/ 2>/dev/null | xargs -I{} basename {}

# List all flow files
find <flows-dir> -name "*.yaml" -o -name "*.yml" | grep -v shared | grep -v _shared | grep -v common
```

## Step 2: Pre-flight Checks

```bash
# Check Maestro is installed
maestro --version || echo "ERROR: Maestro not installed. Run: brew install maestro"

# Check iOS Simulator is running
xcrun simctl list devices booted | grep -i iphone || echo "ERROR: No booted simulator"

# Check app is installed (use discovered bundle ID)
xcrun simctl get_app_container booted <BUNDLE_ID> 2>/dev/null || echo "ERROR: App not installed on simulator"

# Check Metro/dev server if applicable (Expo/RN projects)
# Only check if package.json suggests Expo or React Native
if grep -q "expo\|react-native" package.json 2>/dev/null; then
  curl -s http://localhost:8081/status 2>/dev/null | grep -q "packager-status:running" || \
    echo "WARNING: Metro bundler may not be running"
fi
```

## Step 3: Category Resolution

Given user input, resolve what to run:

1. **`studio`** — Open `maestro studio` for interactive debugging. Done.

2. **Exact category match** — Input matches a discovered subdirectory name
   ```bash
   maestro test <flows-dir>/<category>/
   ```

3. **File match** — Input ends in `.yaml`/`.yml` or matches a flow filename
   ```bash
   # Find the file
   find <flows-dir> -name "<input>*" -name "*.yaml" -o -name "<input>*" -name "*.yml"
   maestro test <matched-file>
   ```

4. **Keyword match** — Fuzzy match against flow filenames
   ```bash
   find <flows-dir> -name "*<keyword>*" \( -name "*.yaml" -o -name "*.yml" \) | grep -v shared
   ```
   If multiple matches, run them all. If zero matches, report available categories/flows.

5. **No args** — Run all flows
   ```bash
   maestro test <flows-dir>/
   ```

## Step 4: Execute

```bash
# Set working directory to where .maestro lives (Maestro resolves relative paths from cwd)
cd <project-dir-containing-maestro>

# Run with output capture
maestro test <target> 2>&1 | tee /tmp/maestro-run-output.txt
```

If the project has environment variables in config.yaml or `.env.maestro`, source them before running.

## Step 5: Structured Output

After execution, create a result file at `<maestro-dir>/maestro-run-result.yaml`:

```yaml
executed_at: <ISO8601>
project: <project-name from package.json or directory name>
category: <detected or "all">
target: <original-input>
platform: ios-simulator
app_id: <discovered bundle ID>
flows_dir: <discovered flows path>
duration_seconds: <time>
total: <count>
passed: <count>
failed: <count>
failures:
  - flow: "<relative-path-to-flow>"
    step: "<failing step description>"
    error_summary: "<first line of error>"
    screenshot: "<path to screenshot if available>"
    error_category: "<auto-detected from table below>"
```

### Failure Category Detection

| Error Pattern | Category | Description |
|---------------|----------|-------------|
| `Element not found` | missing-element | UI element not visible/accessible |
| `Timeout` | timeout | Flow step timed out |
| `App crashed` | app-crash | App crashed during test |
| `Network error` | network-error | API/network failure |
| `assertVisible failed` | assertion-failed | Expected element not on screen |
| `launchApp failed` | launch-failure | App failed to launch |
| `mockNetwork` | mock-error | Network mock setup failed |

## Step 6: Summary

Always end with a summary like this:

```
═══════════════════════════════════════════════════════════
  MAESTRO RUN COMPLETE
  Project: <project-name>
  Category: <category or "all">
  Platform: iOS Simulator (<device name>)
  Result: X passed, Y failed

  Failures by category:
    - missing-element: N
    - timeout: N

  Available categories: <list discovered categories>
  Next: /maestro-analyze for detailed failure diagnosis
═══════════════════════════════════════════════════════════
```

## Multi-Maestro Projects

Some monorepos have multiple apps with separate `.maestro/` directories. When multiple are found:

1. If user is inside an app directory (cwd is within one of the apps), use that app's `.maestro/`
2. If at repo root, list the options and ask which app to test
3. If user specifies an app name as prefix (e.g., `mobile smoke`), resolve accordingly

## Recommended Workflow

```bash
# 1. Quick validation
/maestro-run smoke

# 2. Test specific area (categories are auto-discovered)
/maestro-run <any-category-name>

# 3. All flows
/maestro-run

# 4. Analyze failures
/maestro-analyze

# 5. Auto-fix cycle
/maestro-fix-cycle

# 6. Interactive debugging
/maestro-run studio
```
