# opencode Guide — The Complete Walkthrough

A comprehensive guide to using the CEO Engineering System with **opencode** — your terminal-native AI coding agent.

---

## Table of Contents

1. [Quick start](#1-quick-start)
2. [The CEO mindset in opencode](#2-the-ceo-mindset-in-opencode)
3. [Agents — when and how to use them](#3-agents--when-and-how-to-use-them)
4. [Skills — the daily commands](#4-skills--the-daily-commands)
5. [Plan mode and build mode](#5-plan-mode-and-build-mode)
6. [The @-mention system](#6-the--mention-system)
7. [Working with files and code](#7-working-with-files-and-code)
8. [Model selection and cost](#8-model-selection-and-cost)
9. [MCP servers](#9-mcp-servers)
10. [Loops and persistent tasks](#10-loops-and-persistent-tasks)
11. [Sharing and collaboration](#11-sharing-and-collaboration)
12. [Undoing and redoing](#12-undoing-and-redoing)
13. [Customization and extension](#13-customization-and-extension)
14. [Troubleshooting](#14-troubleshooting)
15. [Power-user tips](#15-power-user-tips)

---

## 1. Quick start

### Launch opencode

```bash
# In any project directory
cd ~/code/my-project
opencode
```

### Your first 60 seconds

1. **The CEO agent is the default** — you'll see "ceo" in the bottom status bar
2. **Type a request** in natural language: "add a logout button to the header"
3. **Watch it work** — the CEO will plan, spawn scout, then delegate to builder
4. **Review the diff** — the CEO reports when done with file:line, tests, cost
5. **Say "commit"** — runs the `/commit` skill

### Switching agents

```bash
# In the TUI, type:
/agent scout          # switch to scout (read-only search)
/agent builder        # switch to builder (code writer)
/agent ceo            # back to CEO
```

Or set the default in `~/.config/opencode/opencode.json`:
```json
{ "default_agent": "ceo" }
```

### The key principle

**The CEO never writes code.** If you find yourself typing code into the CEO, stop and use a builder. The CEO's job is to plan, delegate, verify, and report.

---

## 2. The CEO mindset in opencode

You are the CEO. The CEO gives **intent**, not **implementation**.

### ❌ Wrong (micro-managing)
```
> Open src/auth/login.ts, read the verifyToken function, then check if the JWT_EXPIRY constant is set to 24 hours, and if not, change it to 1 hour.
```

### ✅ Right (CEO mode)
```
> Users are reporting they're logged out too quickly. Investigate and fix.
```

The CEO doesn't say *how*. The CEO says *what outcome is wanted*. The system figures out *how*.

### When to be specific

| Be specific | Be vague |
|---|---|
| "Add a `/logout` endpoint that clears the session cookie" | "Make auth better" |
| "Rename `foo` to `bar` everywhere" | "Clean up the code" |
| "Add an index on `users.email`" | "Speed up queries" |
| "Fix the bug where Stripe webhooks 500 on retry" | "The payment thing is broken" |

**Rule of thumb:** if the request would be 1 sentence to a smart senior engineer, it's a good CEO request. If it needs a paragraph of context, you're micro-managing.

---

## 3. Agents — when and how to use them

The 9 agents have **strict, non-overlapping scope**. See [agent-matrix.md](agent-matrix.md) for the full reference. Here's the practical guide.

### How to invoke an agent

**Method 1: Switch to it (the agent becomes the main loop)**
```
/agent scout
> Where is the auth middleware?
```

**Method 2: @-mention it (sends a message, then returns to current agent)**
```
> @scout where is the auth middleware?
```

**Method 3: Let the CEO delegate (the recommended way)**
```
> Add MFA to login.
# CEO delegates: scout → architect → builder → reviewer → tester
```

### The 9 agents in practice

| Agent | When YOU use it directly | When the CEO spawns it |
|---|---|---|
| `ceo` | **Default.** Give intent, get reports. | — |
| `scout` | Quick "where is X?" questions | Before any non-trivial builder call |
| `architect` | "How should we design X?" | For non-trivial features |
| `builder` | "Implement this specific change" | After scout, for any code work |
| `reviewer` | "Review this diff" | After builder, before tester |
| `tester` | "Run the tests" | After reviewer |
| `security` | "Audit this for security issues" | When auth/payments/PII touched |
| `doc-writer` | "Update the docs" | After tests pass |
| `devops` | "Deploy this" | For deploys/releases/CI |

### The flow you should aim for

```
you → ceo (plan + delegate) → scout (background)
                              → architect (if complex)
                              → builder → reviewer+tester
                              → doc-writer
you ← ceo (report)
```

You interact with **the CEO**. The CEO handles everything else.

---

## 4. Skills — the daily commands

Skills are repeatable workflows. Invoke with `/skill-name` in the TUI.

### The 23 skills, in 5 groups

**Commit & ship (5)**
- `/commit` — conventional commit
- `/pr` — open a pull request
- `/pr-review <url>` — review a PR
- `/review` — review uncommitted changes
- `/merge-conflict` — resolve conflicts

**Test & verify (5)**
- `/test` — run targeted tests
- `/lint` — run linter
- `/typecheck` — run type checker
- `/format` — format code
- `/security` — security audit

**Branch & sync (3)**
- `/branch <name>` — create branch
- `/sync` — sync with main
- `/clean` — delete merged branches

**Release & docs (4)**
- `/changelog` — update changelog
- `/release` — cut a release
- `/hotfix` — emergency fix branch
- `/doc` — generate/update docs

**Understand & big work (6)**
- `/explain <target>` — explain code
- `/feature <desc>` — full feature pipeline
- `/bug <desc>` — bug fix with repro test
- `/refactor <scope>` — behavior-preserving refactor
- `/mvp <idea>` — Ralph loop
- `/metrics` — show cost dashboard

### Example session

```bash
# Morning standup
> /metrics
# Shows: this week, $4.20 spent, 12 tasks done, 87% success rate

# Start a feature
> /feature "add a /logout endpoint that clears the session cookie"
# CEO: planning...
# CEO: spawning scout... (background)
# CEO: spawning builder...
# CEO: spawning reviewer + tester (parallel)...
# CEO: ✓ Done. src/api/auth.ts:89-102. 4/4 tests pass. $0.12 spent. Ready to commit.

# Commit
> /commit
# Conventionally committed as: feat(auth): add /logout endpoint

# Open PR
> /pr
# PR opened: https://github.com/org/repo/pull/123

# Review a teammate's PR
> /pr-review https://github.com/org/repo/pull/124
# Verdict: REQUEST CHANGES — 2 majors, 1 minor
```

### Customizing skills

Skills are markdown files. Edit them in `~/.config/opencode/skills/<name>/SKILL.md` to change behavior. The system will pick up changes on next session.

---

## 5. Plan mode and build mode

opencode has two modes. Press **Tab** to toggle.

### Plan mode (Tab once)
- The agent **plans but does not edit**
- Shows you what it would do, asks for approval
- Use when: you're not sure, the change is big, you want to review the approach first

### Build mode (Tab again)
- The agent **edits files**
- Use when: you approved the plan, or the task is simple enough to just do

### In CEO mode
The CEO agent is **always in plan-then-build** mode:
1. It plans (mental, not in plan mode)
2. It delegates to builder (which writes code)
3. It reports back

You don't need to toggle Tab for the CEO. The CEO manages this for you.

### Manual override
If you want to see the plan before builder runs:
- Use the `ceo` agent and ask "plan first" or "show me the approach"
- Or switch to a custom agent with `mode: primary` and use Tab manually

---

## 6. The @-mention system

The `@` key is the most powerful shortcut in opencode.

### What you can @-mention

| @-mention | What it does |
|---|---|
| `@<file>` | Includes the file in the prompt |
| `@<directory>` | Includes all files in the directory |
| `@<symbol>` | Fuzzy-search for a function/class |
| `@<agent>` | Sends a message to that agent (returns to current) |
| `@<skill>` | Triggers that skill |
| `@<mcp>` | Uses a specific MCP server |

### Examples

```bash
# Reference files
> How does authentication work? @src/auth/login.ts @src/middleware/session.ts

# Reference a symbol
> @verifyToken what does this function do?

# Send to another agent
> @scout find all usages of the deprecated verifyToken

# Trigger a skill
> @commit commit my changes

# Use an MCP
> @github list my open PRs
```

### Combining with the CEO

When you're in CEO mode, @-mentions work the same way but the CEO will incorporate them into its delegation plan. Most of the time you don't need @-mention — just describe what you want in natural language.

---

## 7. Working with files and code

### Reading files

The agent reads files automatically when needed. To force a read, mention the file with `@`.

You don't need to pre-load files. The CEO will:
1. Spawn `scout` to identify relevant files
2. Have `scout` read only the relevant ones
3. Pass summaries to the next agent

This keeps context lean.

### Editing files

The `builder` agent is the only one that edits by default. The CEO delegates editing.

To edit directly (use sparingly):
- Switch to `/agent builder`
- Describe the change
- The builder will edit

### Creating new files

Same as editing — let the builder do it. Specify the path and the content intent.

### File patterns

opencode respects `.gitignore` and `.opencodeignore` (if you create one). Add `.opencodeignore` to exclude generated files, lock files, large data:

```
# .opencodeignore
package-lock.json
yarn.lock
*.min.js
dist/
build/
.next/
node_modules/
.env
.env.*
```

This prevents the agent from reading files that pollute context.

---

## 8. Model selection and cost

### Default model

The CEO uses `opencode-go/qwen3.7-plus` by default. To change:

```bash
# In TUI
/models
# Pick a model from the list
```

Or in `~/.config/opencode/opencode.json`:
```json
{ "model": "opencode-go/minimax-m3" }
```

### Per-agent models

Each agent has its own model. See `opencode.json` → `agent.<name>.model`. To override temporarily:

```bash
# In TUI, while a specific agent is active
# Use /variant to switch model variants
```

### Cost tracking

```bash
# Per-session cost
> /metrics

# Or in the TUI
/metrics
```

Output:
```
This session
  Tokens in:    42,310
  Tokens out:   8,940
  Cached reads: 156,420 (78% cache hit)
  Cost:         $0.31

By agent
  ceo          1 call    12K in   1.2K out    $0.05
  scout        1 call     2K in     200 out    $0.01
  builder      3 calls   28K in   5.4K out    $0.18
  reviewer     1 call     8K in   1.2K out    $0.04
  tester       1 call     4K in     400 out    $0.03
```

### Cost discipline

1. **Don't spawn architect unless needed** — it's the most expensive call
2. **Cache warmup** — repeating similar tasks gets cheaper (cache hits)
3. **Skip the orchestrator for trivial work** — typo fixes don't need scout
4. **Use the loop scripts** — Ralph is cheaper than running ad-hoc
5. **Watch p95 cost per feature** — if it's climbing, the harness needs tuning

See [cost-analysis.md](cost-analysis.md) for the full breakdown.

---

## 9. MCP servers

MCP (Model Context Protocol) servers extend what the agent can do. Configured in `opencode.json` under `mcp`.

### What's already configured

After `setup.sh`, you have:
- `filesystem` — bounded file access
- `github` — issues, PRs, code search
- `context7` — live library docs (kills hallucinations)

### Adding more MCP servers

Edit `~/.config/opencode/opencode.json`:
```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest"],
      "enabled": true
    }
  }
}
```

Restart opencode to pick up new MCPs.

### Per-agent MCP scoping

Disable MCPs on specific agents to keep their context lean:

```json
{
  "agent": {
    "scout": {
      "mcp": {
        "playwright": { "enabled": false }
      }
    }
  }
}
```

This is useful for `scout` and `doc-writer` which rarely need browser automation.

### Recommended MCPs for engineers

| MCP | Why |
|---|---|
| `filesystem` | Bounded file access (safer than default) |
| `github` | Issues, PRs, code search |
| `context7` | Live docs — no hallucinated library APIs |
| `playwright` | Browser automation for E2E |
| `postgres` | Read-only DB queries |
| `sentry` | Error monitoring |
| `linear` | Issue tracking |
| `figma` | Design tokens (if you do design work) |

Don't add all of these. **Start with 3-4, add as needed.** Each MCP adds context overhead.

---

## 10. Loops and persistent tasks

The CEO system has two loop patterns.

### Ralph Wiggum loop (L3 — persistent)

For greenfield projects where you want fire-and-forget.

```bash
# Set up the loop
> /mvp "build a SaaS landing page with email capture, pricing, and Stripe checkout"

# This creates:
#   AGENT.md      — how to build/test (auto-updated)
#   fix_plan.md   — TODO list (auto-updated)
#   PROMPT.md     — the prompt fed into the loop
#   specs/        — one .md per module

# Then runs the loop in the background
# Stops when:
#   - All items in fix_plan.md are done
#   - Cost cap hit (default $10)
#   - Time cap hit (default 120 min)
#   - You remove .ralph-stop
```

To monitor:
```bash
tail -f ~/.config/opencode/logs/ralph-$(date +%Y%m%d).log
```

To stop:
```bash
cd /your/project
rm .ralph-stop
```

### TDD loop (L1 — single feature)

For implementing a specific behavior with strict test-first discipline.

```bash
~/.config/opencode/loops/tdd-loop.sh "users can reset their password via email"
```

The loop:
1. Writes a failing test
2. Implements minimum code to pass
3. Refactors
4. Commits
5. Repeats for next behavior

### Custom loops

Write your own bash script in `~/.config/opencode/loops/`. Pattern:

```bash
#!/usr/bin/env bash
PROMPT="$1"
cat <<EOF | opencode run --non-interactive
Your task: $PROMPT
...
EOF
```

---

## 11. Sharing and collaboration

### Share a session

```bash
# In TUI
/share
```

Creates a link to the current conversation. Useful for:
- Sharing a debugging session with a teammate
- Posting to your team channel
- Bookmarking a complex solution

### Export a session

```bash
# Get the session ID
ls -lt ~/.config/opencode/sessions/

# Export to markdown
opencode session export <id> --format markdown > session.md
```

### Working with a team

Commit your `AGENTS.md` to the repo. Other engineers on the team will pick it up automatically when they open the project in opencode.

Commit skills to `.opencode/skills/` in the repo (not `~/.config/opencode/skills/`) for project-specific skills.

---

## 12. Undoing and redoing

The CEO sometimes makes changes you don't want. Undo is one keystroke.

```bash
# In TUI
/undo    # undo the last change
/redo    # redo it
```

This reverts the file system changes and re-shows your original prompt. You can then tweak the prompt and try again.

### For deeper undo

```bash
# Undo multiple times
/undo
/undo
/undo
```

### When undo isn't enough

If the agent made changes you can't easily revert:
1. `git diff` to see what changed
2. `git checkout -- <file>` to revert specific files
3. `git stash` to save the agent's work for later

### Session-level undo

opencode keeps a session history. To go back further:
- `/rewind <step>` — go back N steps in the session
- Start a new session — clean slate

---

## 13. Customization and extension

### Add a custom skill

```bash
mkdir -p ~/.config/opencode/skills/my-skill
cat > ~/.config/opencode/skills/my-skill/SKILL.md <<'EOF'
---
name: my-skill
description: What it does and when to use it (include "use proactively" to encourage invocation)
allowed-tools: Bash(git:*), Read
---

## Instructions
1. Step one
2. Step two

## Output
...
EOF
```

Restart opencode (or just reload the session). The skill is now available as `/my-skill`.

### Add a custom agent

Edit `~/.config/opencode/opencode.json`:
```json
{
  "agent": {
    "my-agent": {
      "mode": "subagent",
      "model": "opencode-go/mimo-v2.5",
      "description": "What this agent does",
      "prompt": "{file:./prompts/my-agent.txt}",
      "tools": ["Read", "Grep", "Glob"]
    }
  }
}
```

And add it to the CEO's `permission.task` allowlist:
```json
{
  "agent": {
    "ceo": {
      "permission": {
        "task": { "my-agent": "allow" }
      }
    }
  }
}
```

### Add a custom command

```bash
cat > ~/.config/opencode/commands/deploy.md <<'EOF'
---
description: Deploy to production (asks for confirmation)
agent: devops
model: opencode-go/kimi-k2.7-code
---

## Target
$ARGUMENTS

## Pre-flight
- Current branch is main? (warn if not)
- All tests pass?
- CHANGELOG updated?

## Deploy
1. Confirm with user
2. Tag release
3. Push to deploy
4. Smoke test
EOF
```

Now `/deploy` works in the TUI.

### Add a hook (TypeScript plugin)

For opencode, hooks are TS plugins:

```typescript
// ~/.config/opencode/plugins/my-plugin.ts
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool === "bash" && /dangerous/.test(output.args.command)) {
      throw new Error("Blocked: dangerous command")
    }
  }
})
```

Restart opencode. Hooks are loaded automatically.

---

## 14. Troubleshooting

### "Agent isn't following my instructions"

- Check that the description in the agent's frontmatter is clear
- The agent uses `description` to decide when to delegate — be specific
- Add "use proactively" to the description to encourage invocation

### "The CEO is writing code instead of delegating"

- This is a bug — the CEO should never edit
- Check `~/.config/opencode/agents/ceo.md` has `permission.edit: deny` (or equivalent)
- Check that `default_agent: "ceo"` is set in opencode.json

### "Tests are failing and the loop won't stop"

- Builder↔tester loop is capped at 4 iterations
- If it hits the cap, the CEO should escalate to you
- If it doesn't, file a bug — the cap is enforced in the skill, not the agent

### "I'm burning through tokens too fast"

- Run `/metrics` to see which agent is expensive
- Common culprits: too many architect calls, full-codebase reads, no caching
- See [cost-analysis.md](cost-analysis.md) for optimization

### "MCP server won't connect"

- Check the command/path is correct
- Try running the command manually outside opencode
- Check `~/.config/opencode/logs/` for error output

### "Skill not found"

- Skills must be in `~/.config/opencode/skills/<name>/SKILL.md`
- Restart opencode to pick up new skills
- Check the frontmatter is valid YAML

### "Loop ran away / never stopped"

- Ralph loop: `rm .ralph-stop` in the project directory
- TDD loop: Ctrl+C in the terminal
- For runaway sessions: kill the opencode process

---

## 15. Power-user tips

### Tip 1: Batch similar work

Group similar tasks into one session. Context and caches are warm.

```
> Refactor these 5 functions to use the new error type:
> 1. parseUser
> 2. parseOrg
> 3. parseWorkspace
> 4. parseProject
> 5. parseTeam
```

One CEO delegation, one review pass, one commit per function. Cheap.

### Tip 2: Pre-warm with scout

If you know a feature is coming, run scout ahead of time:
```
> /agent scout
> Map the auth system in detail. I'll need this in 10 minutes.
```

When you start the feature, scout's context is cached.

### Tip 3: Use the architect sparingly, but well

Architect is expensive ($0.30 per call). Use it for:
- New system components
- Breaking API changes
- "How should we..." questions

Don't use it for:
- Bug fixes
- Small refactors
- Code review

### Tip 4: Trust the L2 verifier

If tests pass and typecheck is clean, the change is good. Don't re-review manually unless something feels off.

### Tip 5: Iterate on AGENTS.md

The constitution (`AGENTS.md`) is the highest-leverage file. When you correct the agent for the second time on the same thing, update AGENTS.md so it doesn't happen again.

### Tip 6: Use the cost dashboard weekly

```bash
# Every Monday morning
~/.config/opencode/loops/cost-report.sh week
```

If your p95 cost per feature is creeping up, tune the prompts. If the success rate is dropping, your agents are drifting.

### Tip 7: Symlink your favorite MCPs

```bash
# If you use a custom MCP server across projects
ln -s ~/.config/opencode/mcp/global.json ~/.config/opencode/opencode.json
```

Or use the `mcpServers` array with global paths.

### Tip 8: Use `.opencodeignore` aggressively

Anything that pollutes context goes in `.opencodeignore`:
- Lock files
- Build output
- Generated code
- Large data files
- The `.git/` directory (usually)

### Tip 9: Profile before optimizing

Before adding more agents or skills, run `/metrics` to see what's actually expensive. Most of the time it's one agent doing too much.

### Tip 10: When in doubt, simplify

The best CEO system is the one you actually use. If you find yourself avoiding a skill because it's too complex, simplify it. If an agent's prompt is too long, trim it. Iteration > perfection.

---

## Next steps

- Read [commands.md](commands.md) for the full skill reference
- Read [workflows.md](workflows.md) for end-to-end recipes
- Read [architecture.md](architecture.md) to understand the system design
- Read [troubleshooting.md](troubleshooting.md) when things go wrong
