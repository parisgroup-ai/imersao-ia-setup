---
name: e2e-chrome-devtools
version: 1.0.0
description: >
  Visual smoke test using Chrome DevTools MCP against a running web app (local or production).
  Navigates key pages, captures screenshots, inspects console errors, network failures,
  runs Lighthouse audits, tests mobile/dark-mode emulation, and traces performance.
  Use this skill whenever the user says "smoke test", "visual test with chrome",
  "chrome devtools test", "visual QA", "devtools smoke", "visual e2e",
  "test with real browser", "test no chrome", "teste visual", "smoke visual",
  or wants to audit a running app through the real Chrome browser (not Playwright).
  Also use when the user asks to check console errors, network failures, or
  Lighthouse scores on a live page via Chrome DevTools MCP.
---

# Chrome DevTools Smoke Test

Run a structured visual smoke test against a running web application using the
Chrome DevTools MCP server. This connects to the user's **real Chrome browser**
(with sessions, cookies, extensions) — unlike Playwright which opens a headless
browser.

## When to use this vs Playwright MCP

| Scenario | Tool |
|---|---|
| Debug app with logged-in session | **Chrome DevTools MCP** |
| Inspect console/network in real time | **Chrome DevTools MCP** |
| Lighthouse audit, perf trace, heap snapshot | **Chrome DevTools MCP** |
| Automated E2E test suite (CI) | Playwright MCP |
| Headless screenshot comparison | Playwright MCP |

## Prerequisites

The `chrome-devtools` MCP server must be configured in `.mcp.json`:

```json
{
  "chrome-devtools": {
    "command": "npx",
    "args": ["chrome-devtools-mcp@latest", "--autoConnect"]
  }
}
```

Chrome must be running with DevTools Protocol enabled. The `--autoConnect` flag
handles this automatically.

## Workflow

### Phase 1: Discovery

Understand what's available before testing.

1. **Load tools** — Call `ToolSearch` for all `mcp__chrome-devtools__*` tools
2. **List pages** — `list_pages` to see what's already open in Chrome
3. **Detect app** — Check if the app is running locally (try common ports: 3000, 3700, 4000, 5173, 8080) or use a production URL already open in a tab
4. **Plan routes** — Identify key pages to test based on the project structure (glob for `**/page.tsx` or similar)

### Phase 2: Page-by-Page Smoke

For each target page, execute this sequence:

```
navigate_page(url)
  → take_screenshot(filePath, fullPage: true)
  → take_snapshot()                           # a11y tree with UIDs
  → list_console_messages(types: ["error", "warn"])
  → list_network_requests(resourceTypes: ["fetch", "xhr"])
```

Save screenshots to `/tmp/smoke-NN-description.png`.

**Key pages to test (adapt to the project):**
- Landing / home page
- Login page
- Main dashboard (if logged in)
- A detail/form page
- A list/table page

**For authenticated pages:** If the user is already logged in on a production tab,
use `select_page(pageId)` to switch to it instead of re-authenticating.

### Phase 3: Interaction Test (Optional)

If login is needed and credentials are available:

```
fill_form(elements: [{uid, value}, ...])
click(uid)                                    # submit
wait_for(text: ["Dashboard", "Expected text"])
```

If login fails, continue with public pages — don't block the test.

### Phase 4: Lighthouse Audit

Run on the most important page (usually the landing page):

```
lighthouse_audit(device: "mobile", mode: "navigation")
```

This returns scores for Accessibility, Best Practices, and SEO. Save the report
to a known directory. Extract failed audits from the JSON report:

```python
# Parse failed audits from report.json
for category in ['accessibility', 'seo', 'best-practices']:
    for audit in category.auditRefs:
        if audit.score < 1:
            report_failure(audit)
```

### Phase 5: Mobile & Dark Mode

Test responsive behavior and theme support:

```
# Mobile viewport (iPhone 14 Pro)
emulate(
  viewport: "393x852x3,mobile,touch",
  userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 ...)"
)
navigate_page(type: "reload")
take_screenshot(filePath: "/tmp/smoke-mobile.png")
list_console_messages(types: ["error"])

# Dark mode
emulate(colorScheme: "dark")
take_screenshot(filePath: "/tmp/smoke-mobile-dark.png")

# Reset
emulate(viewport: "1440x900x2", colorScheme: "auto", userAgent: "")
```

### Phase 6: Performance Trace

Trace Core Web Vitals on the most important page:

```
navigate_page(url: "target-page")
performance_start_trace(reload: true, autoStop: true, filePath: "/tmp/perf-trace.json.gz")
```

Then analyze key insights:

```
performance_analyze_insight(insightSetId: "NAVIGATION_0", insightName: "LCPBreakdown")
performance_analyze_insight(insightSetId: "NAVIGATION_0", insightName: "RenderBlocking")
performance_analyze_insight(insightSetId: "NAVIGATION_0", insightName: "ThirdParties")
```

### Phase 7: Cleanup & Report

1. Close any tabs opened during the test: `close_page(pageId)`
2. Compile findings into a structured report

## Report Format

Always end with a structured report using this template:

```markdown
# Visual Smoke Test Report

## Summary Table
| Dimension | Score/Status | Verdict |
|---|---|---|

## Findings (by severity)

### CRITICAL
- [description, where, impact, suggested fix]

### MEDIUM
- [description]

### LOW
- [description]

## Performance
| Metric | Value | Rating |
|---|---|---|

## Screenshots Captured
| # | File | Description |
|---|---|---|

## Tools Used
[list of chrome-devtools tools exercised]
```

### Severity Classification

| Severity | Criteria |
|---|---|
| **CRITICAL** | Breaks functionality, data loss, security issue, or 4xx/5xx on critical path |
| **MEDIUM** | Degraded UX, SEO impact, a11y WCAG violation, missing features |
| **LOW** | Cosmetic warnings, unused preloads, image optimization, minor config issues |

## Available Tools Reference

| Category | Tools |
|---|---|
| Navigation | `navigate_page`, `new_page`, `list_pages`, `select_page`, `close_page`, `resize_page` |
| Inspection | `take_snapshot`, `take_screenshot` |
| Interaction | `click`, `hover`, `fill`, `fill_form`, `type_text`, `press_key`, `drag`, `upload_file`, `handle_dialog`, `wait_for` |
| Debugging | `list_console_messages`, `get_console_message`, `list_network_requests`, `get_network_request` |
| Quality | `lighthouse_audit`, `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`, `take_memory_snapshot` |
| Emulation | `emulate` (viewport, colorScheme, networkConditions, cpuThrottlingRate, geolocation, userAgent) |

## Tips

- **Prefer `take_snapshot` over `take_screenshot`** for interaction — snapshots give UIDs needed by click/fill/hover
- **Use `evaluate_script`** for custom checks (e.g., verify a JS variable, check localStorage)
- **Filter network by type** — `resourceTypes: ["fetch", "xhr"]` isolates API calls
- **Filter console by severity** — `types: ["error"]` for critical issues only
- **`includePreservedMessages: true`** captures console messages across the last 3 navigations
- **Production testing** — use `select_page` to switch to already-logged-in production tabs
- **Slow network** — use `emulate(networkConditions: "Slow 3G")` to test degraded conditions
