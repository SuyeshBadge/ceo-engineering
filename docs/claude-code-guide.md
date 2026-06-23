# Claude Code Guide — The Complete Walkthrough

A comprehensive guide to using the CEO Engineering System with **Claude Code** — Anthropic's agentic CLI.

---

## Table of Contents

1. [Quick start](#1-quick-start)
2. [The CEO mindset in Claude Code](#2-the-ceo-mindset-in-claude-code)
3. [Agents — when and how to use them](#3-agents--when-and-how-to-use-them)
4. [Skills — the daily commands](#4-skills--the-daily-commands)
5. [CLAUDE.md and memory](#5-claudemd-and-memory)
6. [Plan mode and accept-edits mode](#6-plan-mode-and-accept-edits-mode)
7. [Working with files and code](#7-working-with-files-and-code)
8. [Model selection and cost](#8-model-selection-and-cost)
9. [MCP servers](#9-mcp-servers)
10. [Hooks — the lifecycle system](#10-hooks--the-lifecycle-system)
11. [Agent Teams and parallelism](#11-agent-teams-and-parallelism)
12. [Routines — scheduled tasks](#12-routines--scheduled-tasks)
13. [Loops and persistent tasks](#13-loops-and-persistent-tasks)
14. [Undoing and rewinding](#14-undoing-and-rewinding)
15. [Customization and extension](#15-customization-and-extension)
16. [Troubleshooting](#16-troubleshooting)
17. [Power-user tips](#17-power-user-tips)

---

## 1. Quick start

### Launch Claude Code

```bash
# In any project directory
cd ~/code/my-project
claude
```

### Your first 60 seconds

1. **The CEO agent loads automatically** (after `setup.sh`)
2. **Type a request** in natural language: "add a logout button"
3. **Watch the agent work** — it'll plan, spawn sub-agents, edit, test
4. **Read the report** — file:line changes, test results, cost
5. **Say "commit"** — runs the `/commit` skill

### Switching agents

```
/agents           # opens the agent picker
```

Or invoke a specific agent explicitly:
```
> Use the scout agent to find all usages of deprecatedAuth
```

### The key principle

**Claude Code + the CEO system = you give intent, the system delivers.** The CEO agent delegates; sub-agents execute. You stay in the loop for decisions, not implementation.

---

## 2. The CEO mindset in Claude Code

You're the CEO. Give intent, not implementation.

### ❌ Micro-managing
```
> Open src/auth.ts, find line 42, change verifyToken to verifyTokenV2, and make sure the tests still pass.
```

### ✅ CEO mode
```
> The deprecation warning in verifyToken is noisy. Migrate to V2.
```

The CEO delegates to scout (find usages), architect (if complex), builder (make changes), reviewer (check), tester (verify). You just see the result.

### When to be specific

| Be specific | Be vague |
|---|---|
| "Add a `/logout` endpoint that clears the session cookie" | "Make auth better" |
| "Add an index on `users.email`" | "Speed up queries" |
| "Fix the bug where Stripe webhooks 500 on retry" | "Payments are broken" |

**Rule of thumb:** if it's 1 sentence to a smart senior, it's a good CEO request.

---

## 3. Agents — when and how to use them

### The 9 agents (strict scope)

After `setup.sh`, your `~/.claude/agents/` has:
- `ceo.md` — Chief of Staff (primary)
- `scout.md` — read-only search
- `architect.md` — design decisions
- `builder.md` — code writing
- `reviewer.md` — code review
- `tester.md` — runs tests
- `security.md` — security audit
- `doc-writer.md` — documentation
- `devops.md` — deploys / infra

### How to invoke

**Automatic delegation (recommended):**
The CEO automatically spawns sub-agents based on the task. You don't need to invoke them directly for most work.

**Manual invocation:**
```
> Use the scout agent to find all auth middleware files
> Use the security agent to audit the recent payment changes
```

**Background subagents (parallel work):**
```
> Use scout in the background to map the codebase while I plan the feature
```

### When to use which agent directly

| You want to... | Switch to / invoke |
|---|---|
| Plan a feature | `ceo` (it plans for you) or `architect` (for design questions) |
| Find code | `scout` |
| Write code | `ceo` (it delegates to builder) or `builder` (if you know exactly what) |
| Review changes | `reviewer` or run `/review` skill |
| Run tests | `tester` or run `/test` skill |
| Audit security | `security` or run `/security` skill |
| Update docs | `doc-writer` or run `/doc` skill |
| Deploy | `devops` (with confirmation) |

### Sub-agents can spawn sub-agents

Claude Code supports **nested sub-agents** (v2.1.172+). The CEO can spawn a reviewer that spawns a security-auditor, for example. Use sparingly — each level adds latency.

---

## 4. Skills — the daily commands

Skills are markdown files in `~/.claude/skills/<name>/SKILL.md`. Invoke with `/skill-name`.

### The 23 skills (same as opencode)

**Commit & ship**: `/commit` `/pr` `/pr-review` `/review` `/merge-conflict`
**Test & verify**: `/test` `/lint` `/typecheck` `/format` `/security`
**Branch & sync**: `/branch` `/sync` `/clean`
**Release & docs**: `/changelog` `/release` `/hotfix` `/doc`
**Understand & big work**: `/explain` `/feature` `/bug` `/refactor` `/mvp` `/metrics`

### How skills work in Claude Code

```
> /commit
# Loads the commit skill, runs it, asks for confirmation
```

Skills can use `!command` to inject dynamic context:

```markdown
!`git diff --stat`
```

This runs at skill-load time and includes the output.

### Argument interpolation

```
> /branch feat/add-logout
# $ARGUMENTS = "feat/add-logout"
```

Skills can use `$ARGUMENTS` to take input.

### Example session

```bash
# Morning
> /metrics
# Dashboard: this week, $4.20, 12 tasks, 87% success

# Fix a bug
> /bug "users report being logged out after 5 minutes"
# CEO: writing repro test... 
# CEO: scout mapping session code...
# CEO: builder fixing...
# CEO: tester verifying... 4/4 pass.
# CEO: ✓ Root cause: SESSION_TIMEOUT=300, should be 86400. Fix in src/config/auth.ts:12. 4/4 tests pass. $0.18. Ready to commit.

> /commit
> /pr
# PR opened: https://github.com/org/repo/pull/123
```

---

## 5. CLAUDE.md and memory

Claude Code has **richer memory** than opencode. Three types:

### 1. CLAUDE.md (project rules)

The constitution. Loaded at session start. Path: `~/.claude/CLAUDE.md` (symlinks to your opencode AGENTS.md).

### 2. Per-directory rules

For project-specific guidance, put rules in `.claude/rules/` in the repo:

```
your-project/
├── .claude/
│   └── rules/
│       ├── api.md       # applies to src/api/**
│       ├── frontend.md  # applies to src/components/**
│       └── testing.md   # applies to tests/**
```

Each file has frontmatter:
```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API rules
- All procedures must validate input with Zod
- Use protectedProcedure unless public
- ...
```

### 3. Auto-memory (Claude Code unique)

Claude Code automatically writes project memory:
```
~/.claude/projects/<project-hash>/memory/
├── MEMORY.md          # main memory file
├── build-commands.md  # what it learned about your build
├── gotchas.md         # things that surprised it
└── preferences.md     # your style preferences
```

To enable:
```bash
# In settings.json
{
  "memory": {
    "enabled": true
  }
}
```

The agent writes to these files when it learns something useful. They auto-load at session start.

### 4. Subagent memory

Sub-agents can have persistent memory:
```yaml
---
name: code-reviewer
memory: project    # writes to ~/.claude/agent-memory/code-reviewer/
---
```

The reviewer remembers patterns it learned across sessions.

### When to use which

| Use CLAUDE.md for | Use auto-memory for | Use subagent memory for |
|---|---|---|
| Team-wide rules | Build commands, gotchas | Subagent-specific learning |
| Style conventions | Environment quirks | "The team prefers X pattern" |
| Architecture decisions | Tool quirks | |
| Permissions | | |

---

## 6. Plan mode and accept-edits mode

Claude Code has **3 permission modes**:

### `default` (interactive)
- Asks before each edit/bash command
- Safest
- Use for: new projects, sensitive work

### `acceptEdits` (auto-accept edits)
- Accepts file edits automatically
- Still asks for bash commands
- Use for: trusted work, fast iteration

### `plan` (read-only)
- The agent plans but doesn't edit
- Use for: reviewing approach before code is written

### `bypassPermissions` (auto-accept everything)
- Accepts all actions
- **Dangerous** — only for sandboxed/throwaway work

### `dontAsk` (auto-deny, manual run)
- Auto-denies everything
- You run commands manually
- Use for: sensitive environments

### For the CEO system

The CEO agent runs in `plan` mode by default — it never edits. Sub-agents (builder, doc-writer) run in `acceptEdits` mode. Tester in `default` (interactive).

### Switching modes mid-session

In the TUI:
- `Shift+Tab` to cycle through modes
- Or set in `settings.json`

---

## 7. Working with files and code

### Reading files

The agent reads files automatically. To force-include a file:
```
> Look at @src/auth/login.ts and explain verifyToken
```

### Editing files

The `builder` and `doc-writer` agents edit. The CEO never does.

### `.claudeignore` (recommended)

Create a `.claudeignore` in your project root:
```
# .claudeignore
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

### File references in prompts

```
> How does @src/auth/login.ts work? Compare to @src/middleware/session.ts
```

The `@` symbol triggers file inclusion. Use freely.

---

## 8. Model selection and cost

### Model options

Claude Code uses Anthropic models:
- **Sonnet 4.6** — default, balanced
- **Opus 4.6** — most capable, expensive
- **Haiku 4.5** — fast, cheap

### Per-agent models

Each agent's frontmatter specifies the model:
```yaml
---
model: sonnet   # or opus, haiku, or full ID
---
```

The CEO uses `sonnet` (default). Scout uses `haiku` (cheap). Architect uses `opus` (rare).

### Override globally

```bash
# In settings.json
{
  "model": "sonnet"   # default for all agents
}
```

Or per-env:
```bash
export CLAUDE_CODE_SUBAGENT_MODEL=haiku
# All subagents without an explicit model use haiku
```

### Cost tracking

Claude Code doesn't have built-in cost tracking, but the hooks capture everything:
- `~/.claude/logs/audit.log` — all hook invocations
- `~/.claude/sessions/` — full session JSON

To get a cost report:
```
> /metrics
```

The metrics skill parses the session logs and shows tokens, cost, agent breakdown.

### Cost discipline

1. Use **haiku for scout, doc-writer** (10× cheaper than sonnet)
2. Use **sonnet for builder, reviewer, tester** (default)
3. Use **opus only for architect, security** (called once per task)
4. **Cap subagent turns** with `maxTurns` in frontmatter
5. **Skip the orchestrator** for trivial work
6. **Monitor weekly** with `/metrics`

---

## 9. MCP servers

MCP servers in Claude Code are configured in `~/.claude.json` (user) or `.mcp.json` (project).

### After setup.sh

You have:
- `filesystem` — bounded file access
- `github` — issues, PRs
- `context7` — live library docs

### Adding MCP servers

```bash
# Quick add
claude mcp add --transport http context7 https://mcp.context7.com/mcp

# Or edit ~/.claude.json directly
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

### Per-agent MCP scoping

Sub-agents can have specific MCP allowlists via `mcpServers` in their frontmatter (Claude Code 2.1+).

### Recommended MCPs for engineers

| MCP | Why |
|---|---|
| `filesystem` | Bounded file access (safer) |
| `github` | Issues, PRs, code search |
| `context7` | Live docs — no hallucinations |
| `playwright` | Browser automation |
| `postgres` | Read-only DB queries |
| `sentry` | Error monitoring |
| `linear` | Issue tracking |
| `figma` | Design tokens |

Start with 3-4. Each MCP adds context.

---

## 10. Hooks — the lifecycle system

Claude Code has the **richest hook system** of any agent. 25+ events, 5 handler types.

### Hook events

| Event | When it fires |
|---|---|
| `PreToolUse` | Before any tool call (can block) |
| `PostToolUse` | After a successful tool call |
| `PostToolUseFailure` | After a failed tool call |
| `PermissionRequest` | When agent asks for permission |
| `PermissionDenied` | When permission is denied |
| `Notification` | Agent sends a notification |
| `SubagentStart` | A subagent starts |
| `SubagentStop` | A subagent stops |
| `TaskCreated` | A task is created |
| `TaskCompleted` | A task is completed |
| `TeammateIdle` | In Agent Teams mode, when teammate goes idle |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction |
| `SessionStart` | Session begins |
| `SessionEnd` | Session ends |
| `Setup` | Initial setup |
| `CwdChanged` | Working directory changed |
| `FileChanged` | A watched file changed |
| `WorktreeCreate` | A git worktree was created |
| `WorktreeRemove` | A git worktree was removed |
| `Elicitation` | Agent asks the user a question |
| `ElicitationResult` | User answered the question |
| `ConfigChange` | Settings changed |
| `InstructionsLoaded` | CLAUDE.md or rules loaded |
| `StopFailure` | Agent stopped with error |

### Handler types

1. **`command`** — runs a shell command (most common)
2. **`http`** — calls a webhook
3. **`mcp`** — calls an MCP tool
4. **`prompt`** — uses an LLM as a judge
5. **`agent`** — uses a subagent as a judge

### Already installed hooks

After `setup.sh`, you have:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "~/.claude/hooks/block-destructive.sh" }] },
      { "matcher": "Read|Write|Edit", "hooks": [{ "type": "command", "command": "~/.claude/hooks/env-protection.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [
        { "type": "command", "command": "~/.claude/hooks/format-on-save.sh" },
        { "type": "command", "command": "~/.claude/hooks/run-typecheck.sh" }
      ]}
    ],
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/audit.sh session-start" }] }],
    "SessionEnd": [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/audit.sh session-end" }] }]
  }
}
```

### Adding a custom hook

Example: send a Slack notification on `SessionEnd`:

```json
{
  "hooks": {
    "SessionEnd": [
      { "hooks": [
        { "type": "http", "url": "https://hooks.slack.com/services/XXX/YYY/ZZZ", "method": "POST" }
      ]}
    ]
  }
}
```

Example: block a specific file from being edited:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [
        { "type": "command", "command": "if echo \"$CLAUDE_TOOL_INPUT\" | jq -e '.file_path | test(\"package-lock.json\")' > /dev/null; then echo 'BLOCKED: edit package-lock.json manually' >&2; exit 2; fi" }
      ]}
    ]
  }
}
```

### Testing hooks

```bash
# Run with debug
claude --debug

# Check hook output
cat ~/.claude/logs/audit.log
```

---

## 11. Agent Teams and parallelism

Claude Code has **Agent Teams** (May 2026) — multiple agents working in parallel on independent sessions.

### When to use Agent Teams

- Refactoring 10+ files where each file is independent
- Building multiple features in parallel
- Triaging issues (one agent per issue)
- Research tasks that can be split

### When NOT to use

- Tasks with dependencies between subtasks
- Anything where you'd be confused by interleaved output
- Cost-sensitive work (Teams use more tokens)

### How to use

```
> Use 3 sub-agents in parallel to refactor:
> 1. /workspace/api/* — migrate to Zod
> 2. /workspace/db/* — add indexes
> 3. /workspace/ui/* — convert to Server Components
```

Or invoke explicitly:
```
> Spawn 5 scout agents in parallel to map different parts of the codebase
```

### Background subagents

For non-blocking work:
```
> Run tester in the background while I review the diff
```

### Dynamic workflows

For 10s-100s of parallel sub-agents (uses the "agent teams" feature):
- Limited to Opus 4.6+ plans
- Useful for large migrations
- See Claude Code docs for the `Agent(agent_type)` syntax

---

## 12. Routines — scheduled tasks

Claude Code has **Routines** (April 2026) — cron-like scheduled triggers.

### Use cases

- "Every morning, run the test suite and report failures"
- "Every Monday, run `/metrics` and post to Slack"
- "Every hour, check for new Sentry errors"

### Setup

```bash
# In settings.json or via CLI
claude routine add "every weekday at 9am" "Run /metrics and report"
```

Or in `settings.json`:
```json
{
  "routines": [
    {
      "schedule": "0 9 * * 1-5",
      "prompt": "Run /metrics for this week and summarize in 3 bullets"
    }
  ]
}
```

### Output

Routines write to `~/.claude/routines/`. You can:
- Read the output
- Pipe to email/Slack via hooks
- Use as input to other routines

### Cost warning

Routines burn tokens continuously. Set tight `maxTurns` and use Haiku for routine work.

---

## 13. Loops and persistent tasks

### Ralph Wiggum loop (L3 — greenfield)

For fire-and-forget greenfield builds.

```bash
# Set up
> /mvp "build a SaaS landing page"

# Runs in background with cost/time cap
# Stops when:
#   - All items in fix_plan.md done
#   - Cost cap hit
#   - Time cap hit
#   - You cancel
```

### TDD loop (L1 — single feature)

```bash
~/.config/opencode/loops/tdd-loop.sh "users can reset their password"
```

(Yes, this is in `~/.config/opencode/loops/` but works in both editors since it's just bash.)

### Manual persistent loop

```bash
while :; do
  cat PROMPT.md | claude -p --permission-mode auto
  sleep 5
done
```

Or with cost cap:
```bash
~/.config/opencode/loops/ralph.sh --cost-cap 5 --time-cap 60
```

---

## 14. Undoing and rewinding

### Quick undo

```
/undo
```

Undoes the last change. Multiple times for multiple changes.

### Deep rewind

```
/rewind <step>
```

Rewinds the session N steps. Restores the prompt, the agent state, and the files.

### Per-file undo

If you want to revert a specific file:
```
> Revert src/auth.ts to the last commit, but keep my other changes
```

### When undo isn't enough

```bash
git diff                    # see all changes
git checkout -- <file>      # revert one file
git stash                   # save agent's work
```

---

## 15. Customization and extension

### Add a custom skill

```bash
mkdir -p ~/.claude/skills/my-skill
cat > ~/.claude/skills/my-skill/SKILL.md <<'EOF'
---
name: my-skill
description: What it does and when to use it
allowed-tools: Bash(git:*), Read
---

## Instructions
...
EOF
```

### Add a custom agent

```bash
cat > ~/.claude/agents/my-agent.md <<'EOF'
---
name: my-agent
description: What this agent does
tools: Read, Grep, Glob
model: haiku
---

Your system prompt here.
EOF
```

Add to the CEO's `tools` allowlist:
```yaml
---
name: ceo
tools: Agent(scout), Agent(architect), Agent(builder), ..., Agent(my-agent)
---
```

### Add a custom command (slash)

```bash
mkdir -p ~/.claude/commands
cat > ~/.claude/commands/deploy.md <<'EOF'
---
description: Deploy to production (asks confirmation)
---

Deploy the current branch to production. Confirm before proceeding.
EOF
```

Now `/deploy` works.

### Add a custom hook

Edit `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit", "hooks": [
        { "type": "command", "command": "~/.claude/hooks/my-hook.sh" }
      ]}
    ]
  }
}
```

### Add a custom MCP

```bash
claude mcp add --transport stdio my-mcp -- npx -y @example/mcp-server
```

Or in `~/.claude.json`:
```json
{
  "mcpServers": {
    "my-mcp": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

---

## 16. Troubleshooting

### "Agent isn't following instructions"

- Check the frontmatter `description` — that's what the model uses to decide when to invoke
- Add "use proactively" to encourage invocation
- Make the system prompt more specific

### "The CEO is editing files"

- The CEO should have `disallowedTools: Write, Edit, NotebookEdit` in frontmatter
- Check `~/.claude/agents/ceo.md` for these
- The CEO delegates — it doesn't write

### "Loop won't stop"

- Builder↔tester loop is capped at 4 (in the skill, not the agent)
- If exceeding, the CEO should escalate
- For runaway sessions: Ctrl+C

### "MCP not connecting"

```bash
# Test the command manually
npx -y @playwright/mcp@latest

# Check Claude Code's MCP logs
ls ~/.claude/logs/
```

### "Hook isn't firing"

```bash
# Test the hook script
~/.claude/hooks/block-destructive.sh < test-input.json

# Or run Claude Code with debug
claude --debug
```

### "Token usage too high"

- Run `/metrics` to see breakdown
- Common causes: too many Opus calls, no caching, full-codebase reads
- See [cost-analysis.md](cost-analysis.md)

### "Skill not found"

- Skills must be in `~/.claude/skills/<name>/SKILL.md`
- Restart Claude Code to pick up new skills
- Frontmatter must be valid YAML

### "Agent Teams not working"

- Requires Claude Code Max plan or higher
- Use the `Agent(agent_type)` syntax
- Check Claude Code version: `claude --version` (need 2.1+)

---

## 17. Power-user tips

### Tip 1: Use auto-memory aggressively

Let Claude Code learn your project's quirks. The auto-memory feature writes to `~/.claude/projects/<hash>/memory/`. After a few sessions, the agent "knows" your build commands, test patterns, and gotchas.

### Tip 2: Combine background + foreground

```
> Spawn 3 scout agents in the background to map auth, db, and ui
> While they work, I'll plan the migration
> [you write the plan]
> OK, now consolidate their findings and proceed
```

This is 3-5× faster than sequential exploration.

### Tip 3: Use Agent Teams for refactors

```
> Use 5 agents to refactor these modules in parallel:
> - /api/users
> - /api/orgs
> - /api/workspaces
> - /api/projects
> - /api/tasks
```

Each gets a fresh context, doesn't pollute the others, and the work happens in parallel.

### Tip 4: Trust the L2 verifier

If tests pass and typecheck is clean, the change is good. Don't re-review unless something feels off.

### Tip 5: Set up Routines for monitoring

```bash
claude routine add "every weekday at 9am" "Check for new Sentry errors and summarize"
claude routine add "every Monday at 10am" "Run /metrics and post to #engineering"
```

### Tip 6: Use `.claudeignore` aggressively

```
# .claudeignore
node_modules/
dist/
.next/
package-lock.json
.env
.env.*
*.min.js
coverage/
```

This saves tokens and prevents context pollution.

### Tip 7: Profile before optimizing

Before adding more agents or skills, run `/metrics` to see what's actually expensive.

### Tip 8: Use the prompt-judge hook for quality gates

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [
        { "type": "prompt", "prompt": "Did the agent complete the user's request? Reply with 'yes' or 'no: <reason>'" }
      ]}
    ]
  }
}
```

This uses an LLM to judge whether the agent should stop.

### Tip 9: Customize per-directory rules

Create `.claude/rules/` in your project:
```
.claude/rules/
├── api.md          # paths: src/api/**
├── db.md           # paths: src/db/**
├── testing.md      # paths: tests/**
└── frontend.md     # paths: src/components/**
```

Each loads only when the agent touches relevant files. Massive context savings.

### Tip 10: When in doubt, simplify

The best system is the one you use. If a skill is too complex, simplify it. If an agent is doing too much, split it.

---

## Next steps

- Read [commands.md](commands.md) for the full skill reference
- Read [workflows.md](workflows.md) for end-to-end recipes
- Read [architecture.md](architecture.md) for the system design
- Read [troubleshooting.md](troubleshooting.md) for common issues
- Read [glossary.md](glossary.md) for terms
