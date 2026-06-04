---
name: qa-mobile
description: Use when checking responsive behavior or mobile layout regressions across browser viewports.
---

# Mobile QA Skill

Systematic responsive QA using browser automation.

## Viewports

| Device | Width | Height |
|--------|-------|--------|
| iPhone SE | 375 | 667 |
| iPhone 14 Pro Max | 430 | 932 |
| iPad Mini | 768 | 1024 |
| iPad Pro | 1024 | 1366 |
| Desktop | 1440 | 900 |

## QA Checklist

For each viewport, check:

### Layout
- [ ] No horizontal overflow (no horizontal scrollbar)
- [ ] Content doesn't overflow containers
- [ ] Text is readable (min 12px on mobile)
- [ ] Touch targets are at least 44x44px
- [ ] No overlapping elements

### Navigation
- [ ] Mobile nav is functional (hamburger/tabs)
- [ ] Links are tappable
- [ ] Sticky headers don't cover content

### Components
- [ ] Cards display correctly
- [ ] Modals/dialogs fit viewport
- [ ] Forms are usable (inputs not too small)
- [ ] Carousels/sliders work with touch

### Design System
- [ ] Semantic tokens used (no hardcoded colors)
- [ ] Spacing is proportional to viewport
- [ ] Typography scales properly (sm/md/lg breakpoints)

## Browser Tool Selection

Use **Playwright MCP** as the primary browser tool. Fall back to `claude-in-chrome` only if Playwright MCP is unavailable.

For **visual tests** (screenshots, visual comparison, pixel-level checks), always use **Playwright MCP** — it provides headless screenshots with consistent rendering, which is essential for reliable visual validation.

### Chromium for Testing (REQUIRED)

Before starting browser interactions, ensure the **new Chromium headless mode** is active. This uses the real Chrome browser (not the legacy headless shell), providing more authentic rendering and behavior that matches what real users see.

1. **Install Chromium for Testing** (if not already installed):
   ```
   mcp__plugin_playwright_playwright__browser_install
   ```
   This ensures the Chromium for Testing binary is available.

2. The Playwright MCP uses `channel: 'chromium'` by default when configured — this opts into the new headless mode which is the real Chrome browser running headless, more reliable for visual QA than the legacy headless shell.

## Workflow (Playwright MCP — Primary)

0. **Install browser** (first run): `mcp__plugin_playwright_playwright__browser_install` to ensure Chromium for Testing is available
1. **Navigate to page**: `mcp__plugin_playwright_playwright__browser_navigate` with the target URL
2. **Resize viewport**: `mcp__plugin_playwright_playwright__browser_resize` for each viewport size
3. **Capture accessibility tree**: `mcp__plugin_playwright_playwright__browser_snapshot` to inspect layout structure
4. **Take screenshot** (visual tests): `mcp__plugin_playwright_playwright__browser_take_screenshot` to capture visual state at each viewport
5. **Check overflow**: `mcp__plugin_playwright_playwright__browser_evaluate` — run JS to detect horizontal scroll
6. **Check spacing**: `mcp__plugin_playwright_playwright__browser_evaluate` — inspect computed styles of key containers
7. **Report findings**: List issues with viewport, element, and fix suggestion

### Playwright MCP Tools Reference

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Go to URL |
| `browser_resize` | Set viewport width/height |
| `browser_snapshot` | Get accessibility tree (structural inspection) |
| `browser_take_screenshot` | Capture visual state (visual tests) |
| `browser_evaluate` | Run JavaScript on page (overflow, touch targets) |
| `browser_click` | Click element by ref |
| `browser_console_messages` | Check for JS errors |

### Example: Check iPhone SE Viewport

```
1. browser_navigate → url: "http://localhost:3000/marketing"
2. browser_resize → width: 375, height: 667
3. browser_snapshot → inspect layout structure
4. browser_take_screenshot → capture visual state
5. browser_evaluate → check overflow:
   document.documentElement.scrollWidth > document.documentElement.clientWidth
6. browser_evaluate → check touch targets:
   Array.from(document.querySelectorAll('a, button')).filter(el => {
     const rect = el.getBoundingClientRect();
     return rect.width < 44 || rect.height < 44;
   }).map(el => ({ tag: el.tagName, text: el.textContent?.trim(), w: el.getBoundingClientRect().width, h: el.getBoundingClientRect().height }))
```

## Project Memory

This skill reads and writes memory in the **project's** auto-memory directory to track QA results across sessions.

### On Start — Read Memory

Before running checks, read the project memory file if it exists:

```
<project-memory-dir>/qa-mobile.md
```

This file contains previous QA runs: pages checked, issues found, recurring problems, and known viewport-specific issues. Use this context to prioritize checks and compare against previous results.

### On Completion — Write Memory

After finishing QA checks, update `<project-memory-dir>/qa-mobile.md` with:

```markdown
# QA Mobile Memory

## Last Run
- **Date:** <ISO date>
- **Pages checked:** <list of URLs>
- **Viewports tested:** <list>

## Known Issues
- <page> @ <viewport>: <issue description> — <status: open|fixed>

## Recurring Patterns
- <pattern description and affected pages>
```

The memory directory is the project's auto-memory path (e.g., `~/.claude/projects/<project-path>/memory/`). Create the file if it doesn't exist; update it if it does.

---

## Quick JS Checks

Run via `mcp__plugin_playwright_playwright__browser_evaluate`:

```javascript
// Detect overflow
document.documentElement.scrollWidth > document.documentElement.clientWidth

// Check touch targets
document.querySelectorAll('a, button').forEach(el => {
  const rect = el.getBoundingClientRect();
  if (rect.width < 44 || rect.height < 44) console.warn('Small target:', el);
});

// Check min-height issues (nested .ui-theme)
document.querySelectorAll('.ui-theme .ui-theme').forEach(el => {
  const mh = getComputedStyle(el).minHeight;
  if (mh !== 'auto' && mh !== '0px') console.warn('Nested .ui-theme with min-height:', mh, el);
});
```
