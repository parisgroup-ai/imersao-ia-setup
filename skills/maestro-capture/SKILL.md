---
name: maestro-capture
description: Use when capturing iOS simulator screens via Maestro to compare the app against design references.
---

# Maestro Capture

Capture screenshots from the iOS Simulator after navigating via Maestro flows, then compare with design prototypes.

## Usage

```
/maestro-capture <section> [--compare]
```

- `section`: Screen name to capture (e.g., `settings`, `launch`, `inbox`)
- `--compare`: Also read the prototype PNG and show side-by-side analysis

## Steps

1. **Check simulator is booted**:
   ```bash
   xcrun simctl list devices booted
   ```
   If no device is booted, tell the user to start the simulator.

2. **Check if app is running**: Take a quick screenshot to see the current state.
   ```bash
   xcrun simctl io booted screenshot /tmp/maestro-capture-check.png
   ```
   Read the screenshot to determine if the app is on screen or if Expo Go home is showing.

3. **Navigate to the target screen**:
   - If on Expo Go home: create a temp Maestro YAML to tap "AsyncMe Mobile" and navigate
   - Write a temp YAML flow at `/tmp/maestro-capture-nav.yaml` that:
     - Launches `host.exp.Exponent`
     - Taps into the app if needed
     - Navigates to the target screen via bottom tab
   - Run: `maestro test /tmp/maestro-capture-nav.yaml`

4. **Capture screenshot**:
   ```bash
   xcrun simctl io booted screenshot <project-root>/compare-<section>.png
   ```

5. **Read and display** the captured screenshot using the Read tool.

6. **If `--compare` flag**:
   - Look for prototype at `design/sections/<section>/<section>-view-native.png`
   - Read both images
   - Provide a structured gap analysis:
     - Layout differences
     - Missing elements
     - Style mismatches
     - What's aligned

## Notes

- Always use `host.exp.Exponent` as the Maestro appId (Expo Go)
- Bottom tab labels are in English: Launch, Inbox, Processes, Projects, Settings
- Inner content uses the device locale (Portuguese on PT devices)
- Maestro `tapOn` works with visible text labels
- For scrolling to off-screen elements use `scrollUntilVisible`
- Clean up temp YAML files after use
