---
name: e2e-testing
description: End-to-end testing workflow using agent-browser. Use when verifying user flows, smoke-testing a deployed app, validating bug fixes in a real browser, or generating test artifacts (screenshots, traces, HAR files). Pairs the agent-browser skill with project-specific test conventions.
---

# E2E Testing

End-to-end verification of web apps. The agent-browser skill is the engine; this skill is the workflow.

## When to use

- Smoke test a deploy before reporting "done"
- Verify a UI fix works in a real browser
- Generate regression artifacts (screenshots, HAR, traces)
- Validate signup/login/forms/checkout flows
- Cross-browser sanity check

## The 5-step E2E loop

1. **Setup** — start browser, navigate to URL, wait for load
2. **Snapshot** — get interactive elements with refs
3. **Act** — click/fill/type using refs (not CSS selectors)
4. **Assert** — verify state via `get text`, `get url`, screenshot, or `eval`
5. **Cleanup** — close session, save artifacts to `e2e-output/`

## Stack-aware patterns

### Nuxt / Vue (Mirage stack)

```bash
# Test login flow
agent-browser open http://localhost:4488/login
agent-browser wait --load networkidle
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser screenshot e2e-output/login-success.png
```

### React / Next.js

```bash
agent-browser open --enable react-devtools http://localhost:3000
agent-browser react tree                    # inspect component hierarchy
agent-browser vitals                        # LCP/CLS/TTFB
```

### Supabase auth flows

```bash
agent-browser open http://localhost:3000/auth
# Fill email/password
agent-browser snapshot -i
agent-browser fill @e1 "$TEST_EMAIL"
agent-browser fill @e2 "$TEST_PASSWORD"
agent-browser click @e3
agent-browser wait --text "Welcome"
```

## Artifact collection

Save these to `e2e-output/<test-name>/<timestamp>/`:

| Artifact | Command | Use |
|---|---|---|
| Screenshot | `screenshot --full shot.png` | visual review |
| Annotated | `screenshot --annotate` | element ref label overlay |
| HAR | `network har start/stop` | network analysis |
| Trace | `trace start/stop` | DevTools trace |
| Snapshot | `snapshot -i --json > snap.json` | DOM diff over time |
| Console | `console --json` | JS errors |
| Vitals | `vitals --json` | perf metrics |

## Test isolation

Use sessions for parallel runs:

```bash
agent-browser --session test-A open site.com
agent-browser --session test-B open site.com
# Each has its own cookies, storage, tabs
```

## CI integration

```bash
# In CI: headless, deterministic, no interactive
export AGENT_BROWSER_HEADED=false
export AGENT_BROWSER_MAX_OUTPUT=10000
agent-browser install --with-deps  # Linux only
agent-browser open "$TEST_URL"
# ... test ...
agent-browser close --all
```

## Debugging failures

When a test breaks:

1. `agent-browser screenshot --full fail.png` — what did the user see?
2. `agent-browser console --json` — JS errors?
3. `agent-browser errors --json` — uncaught exceptions?
4. `agent-browser snapshot -i` — what state is the page in?
5. `agent-browser eval "JSON.stringify(window.__STATE__)"` — check app state

## Anti-patterns

❌ **CSS selectors** — `agent-browser click "#submit"` — brittle, slow, breaks on refactor
✅ **Refs** — `agent-browser click @e3` — deterministic, fast, snapshot-driven

❌ **`sleep 2`** between actions — flaky
✅ **`wait --text "Loaded"`** or **`wait --url "**/dash"`** — event-driven

❌ **Hard-coded URLs** — couples tests to environment
✅ **`$TEST_URL` env var** — portable across local/staging/prod

❌ **Screenshots in assertions** — pixel comparison is brittle
✅ **`get text` / `is visible` / `eval`** — semantic assertions

❌ **One mega-test** — hard to debug on failure
✅ **Small focused tests** — one flow per session

## Pair with the agent-browser skill

For deep CLI mechanics (refs, MCP tools, batch mode, sessions, profiles, security), load the `agent-browser` skill:

```bash
agent-browser skills get core --full
```

This skill is the **workflow**; `agent-browser` is the **tool**. Use both.
