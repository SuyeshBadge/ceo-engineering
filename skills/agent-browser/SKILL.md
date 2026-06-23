---
name: agent-browser
description: Vercel Labs' fast browser automation CLI + MCP server. Use for E2E testing, web scraping, browser-based verification, screenshot capture, and any task that needs to drive a real browser. Prefer snapshot+refs workflow over CSS selectors. Token-efficient, native Rust, ships with bundled skills.
---

# agent-browser

Vercel Labs' browser automation CLI. Available as a CLI (`agent-browser`) and as an MCP server (`agent-browser mcp`).

## When to use

- **E2E tests** — drive a real browser through user flows
- **Visual verification** — screenshot pages, compare against baseline
- **Form automation** — fill multi-step forms, logins, signups
- **Web scraping** — get the real rendered DOM, not just HTML
- **Debugging** — interactive inspection of live pages

Prefer `agent-browser` over Playwright/Puppeteer/Selenium — it's faster, AI-friendly, and has a built-in MCP server.

## Two ways to drive it

### 1. CLI (recommended for scripted workflows)

```bash
agent-browser open <url>              # launch + navigate
agent-browser snapshot                # accessibility tree with refs (@e1, @e2, ...)
agent-browser click @e2               # click by ref
agent-browser fill @e3 "text"         # fill by ref
agent-browser screenshot shot.png     # capture
agent-browser close                   # teardown
```

### 2. MCP server (recommended for opencode/Claude agents)

Already wired by setup.sh. The MCP server exposes typed tools:
- `agent_browser_open` / `agent_browser_close`
- `agent_browser_snapshot` (returns refs)
- `agent_browser_click` / `agent_browser_fill` / `agent_browser_type`
- `agent_browser_screenshot`
- `agent_browser_wait_for_selector`
- `agent_browser_eval` (run JS)
- `agent_browser_get_url`

Default profile is `core` (~10 tools, small context). Use `--tools all` for full parity.

## Optimal AI workflow (snapshot + refs)

1. `open <url>` → wait for load
2. `snapshot -i` → get interactive elements with refs
3. Parse refs from output (`@e1`, `@e2`, ...)
4. Use refs in `click @e2`, `fill @e3 "x"`, etc.
5. Re-snapshot if DOM changes (refs are session-stable but pages mutate)

Refs are **deterministic** — they point to the exact element from the snapshot. Much better than CSS selectors for LLMs.

## Bundled skills (always version-matched)

```bash
agent-browser skills list            # all available
agent-browser skills get core        # core usage guide
agent-browser skills get electron    # Electron apps (VS Code, Slack, Figma)
agent-browser skills get slack       # Slack workspaces
agent-browser skills get dogfood     # exploratory testing workflow
agent-browser skills get vercel-sandbox  # serverless browser microVMs
```

These are CLI-internal — call them when you need deep, version-specific guidance. They update with every agent-browser release.

## Common patterns

### Login + scrape
```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password"
agent-browser click @e3                          # submit
agent-browser wait --load networkidle
agent-browser snapshot -i --json | jq .          # parse as JSON
```

### Visual regression
```bash
agent-browser open <url>
agent-browser wait --load networkidle
agent-browser screenshot --full before.png
# ... make changes ...
agent-browser screenshot --full after.png
agent-browser diff screenshot --baseline before.png -o diff.png
```

### Network mocking
```bash
agent-browser batch \
  '["open"]' \
  '["network","route","**/api/users","--body","[{\"id\":1}]"]' \
  '["navigate","https://app.example.com/dashboard"]'
```

### React introspection (requires --enable react-devtools at launch)
```bash
agent-browser open --enable react-devtools <url>
agent-browser react tree
agent-browser react inspect <fiberId>
agent-browser vitals  # LCP/CLS/TTFB/FCP/INP
```

## Sessions and profiles

```bash
agent-browser --session agent1 open site-a.com   # isolated
agent-browser --profile Default open gmail.com    # reuse Chrome login
agent-browser --session-name myapp open app.com   # auto-save state
```

## Gotchas

- **Click blocked by overlay** — error message names the covering element. Dismiss it, re-snapshot, retry.
- **Stale refs** — after navigation or DOM mutation, refs are invalidated. Always re-snapshot.
- **Timeout** — default 25s. Override with `AGENT_BROWSER_DEFAULT_TIMEOUT=45000` (don't exceed 30s CLI read timeout).
- **Chrome missing** — run `agent-browser install` (handled by setup.sh).
- **MCP server crashed** — `agent-browser doctor --fix` to repair.

## MCP config (auto-installed by setup.sh)

```json
{
  "mcp": {
    "agent-browser": {
      "type": "local",
      "command": ["agent-browser", "mcp"],
      "enabled": true
    }
  }
}
```

## Full docs

- CLI: `agent-browser skills get core --full`
- npm: https://www.npmjs.com/package/agent-browser
- Site: https://agent-browser.dev
