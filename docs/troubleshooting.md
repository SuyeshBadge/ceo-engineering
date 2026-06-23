# Troubleshooting Guide

When things go wrong, this is the first place to look.

---

## Table of Contents

1. [Setup issues](#1-setup-issues)
2. [Agent issues](#2-agent-issues)
3. [Skill issues](#3-skill-issues)
4. [MCP issues](#4-mcp-issues)
5. [Hook issues](#5-hook-issues)
6. [Loop issues](#6-loop-issues)
7. [Performance issues](#7-performance-issues)
8. [Cost issues](#8-cost-issues)
9. [Platform-specific issues](#9-platform-specific-issues)
10. [Common error messages](#10-common-error-messages)

---

## 1. Setup issues

### "setup.sh: command not found"

```bash
chmod +x setup.sh
./setup.sh
```

Or pipe directly from GitHub:
```bash
curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
```

### "jq: command not found"

`jq` is required for JSON merging. Install it:
```bash
brew install jq          # macOS
sudo apt install jq      # Ubuntu/Debian
```

### "opencode: command not found"

```bash
# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Or via Homebrew
brew install anomalyco/tap/opencode
```

### "claude: command not found"

Install Claude Code from https://claude.com/product/claude-code.

### Setup ran but nothing changed

The installer merges with your existing config, doesn't overwrite. To verify:
```bash
ls -la ~/.config/opencode/agents/
# Should show 9 .md files: ceo, scout, architect, builder, reviewer, tester, security, doc-writer, devops
```

If empty, run setup again with `bash -x` for debug:
```bash
bash -x setup.sh
```

### "Permission denied" on hooks

```bash
chmod +x ~/.config/opencode/hooks/*.sh
chmod +x ~/.config/opencode/loops/*.sh
```

---

## 2. Agent issues

### "The CEO is writing code instead of delegating"

The CEO should never edit. Check:
```bash
cat ~/.config/opencode/agents/ceo.md | head -15
```

Should have `mode: primary` and `permission.edit: deny` (or `disallowedTools: Write, Edit, NotebookEdit` in Claude Code).

If missing, the agent file was overwritten. Re-run setup.

### "Agent isn't following my instructions"

- Check the agent's `description` field — that's what the model uses to decide when to invoke
- Add "use proactively" to encourage invocation
- Make the system prompt more specific
- Try: `> /agent <name>` to force-spawn

### "Agent is using wrong model"

Check `~/.config/opencode/opencode.json`:
```json
{
  "agent": {
    "<name>": {
      "model": "opencode-go/qwen3.7-plus"  // should be here
    }
  }
}
```

Override globally:
```bash
export CLAUDE_CODE_SUBAGENT_MODEL=haiku  # for Claude Code
```

### "Agent can't invoke another agent"

Check the `permission.task` allowlist on the parent:
```json
{
  "agent": {
    "ceo": {
      "permission": {
        "task": {
          "*": "deny",
          "scout": "allow",
          "builder": "allow"
        }
      }
    }
  }
}
```

### "Subagent fails with permission denied"

The subagent is trying to use a tool not in its allowlist. Either:
1. Add the tool to the subagent's `tools` list
2. Loosen the permission: `permission.bash: { "*": "allow" }` (less safe)

---

## 3. Skill issues

### "Skill not found"

Verify the path:
```bash
ls ~/.config/opencode/skills/<name>/SKILL.md
```

If missing, re-run setup. If present but not loading, check the frontmatter:
```markdown
---
name: my-skill       # required
description: ...     # required
---
```

Restart opencode / Claude Code to pick up new skills.

### "Skill runs but doesn't do what I expect"

Read the skill's SKILL.md to understand its behavior:
```bash
cat ~/.config/opencode/skills/commit/SKILL.md
```

Edit it to change behavior. The system picks up changes on next session.

### "Skill hangs"

Skills can hang if they're waiting on input. Check the prompt:
- Does it have `!`command`` injection that's failing?
- Does it have `$ARGUMENTS` that's being interpreted wrong?

Test the dynamic context:
```bash
git diff --stat  # what the commit skill's !`git diff --stat` runs
```

### "Skill invents files / paths"

The model is hallucinating. Make the skill more specific:
- Use absolute paths
- Reference actual config files
- Add "if $ARGUMENTS is empty, ask the user" check

---

## 4. MCP issues

### "MCP server won't connect"

Test the command manually:
```bash
npx -y @playwright/mcp@latest
```

If that fails, the MCP package has an issue. Check:
- Internet connection
- npm registry access
- Node.js version (need 18+)

### "MCP server connected but tools not appearing"

Restart opencode / Claude Code. The MCP tool list is loaded at session start.

### "MCP requires auth"

For remote MCPs (context7, github, etc.), you may need to authenticate:
```bash
# Context7 — no auth needed
# GitHub — needs GITHUB_PAT
gh auth login
export GITHUB_PAT=$(gh auth token)
```

### "CodeGraph MCP not responding"

CodeGraph requires the `codegraph` CLI and a project index:
```bash
# Check codegraph is installed
which codegraph

# Initialize in your project
cd /your/project
codegraph init
codegraph index

# Test
codegraph explore "main function"
```

### "Octocode is slow on first run"

Octocode indexes your codebase on first use. For a large repo, this can take 30-60 seconds. Subsequent calls are fast.

---

## 5. Hook issues

### "Hook isn't firing"

Test the hook script directly:
```bash
echo '{"tool_input":{"command":"rm -rf /"}}' | ~/.claude/hooks/block-destructive.sh
```

Should output JSON with `permissionDecision: "deny"`.

If empty, check:
- The script is executable: `chmod +x`
- The path in `settings.json` is correct
- The `matcher` pattern matches the tool name

### "Hook blocks everything"

Your hook is too aggressive. Check the patterns:
```bash
# Good — specific patterns
grep -qE 'rm\s+-rf\s+/|:(){ :|:& };:'

# Bad — too broad
grep -qE 'rm'
```

### "Hook fires but doesn't block"

Check exit code:
- `exit 0` + JSON `permissionDecision: "deny"` = block
- `exit 2` = block (without JSON)
- `exit 0` + no JSON = allow

### "PostToolUse hook runs formatter but nothing changes"

The file might not need formatting. Or the formatter isn't installed:
```bash
which prettier
which black
which gofmt
```

Install missing formatters, or the hook will silently skip.

---

## 6. Loop issues

### "Ralph loop never stops"

```bash
# In the project directory
rm .ralph-stop
```

Or kill the process:
```bash
pkill -f "opencode run"
```

### "Ralph loop stops too early"

Check the cost cap. Logs show why:
```bash
tail -50 ~/.config/opencode/logs/ralph-$(date +%Y%m%d).log
```

### "TDD loop runs but doesn't commit"

Check that the project is a git repo:
```bash
git status
```

If not:
```bash
git init
git add -A
git commit -m "initial"
```

### "Loop hits the iteration cap and stops"

The builder↔tester loop is capped at 4 iterations. After 4, the CEO should escalate to you. If it doesn't, file a bug.

---

## 7. Performance issues

### "Agent is slow"

Causes:
1. **Large context** — too much in history. Run `/clear` to reset.
2. **Big reads** — agent read a huge file. Add `.opencodeignore`.
3. **Slow model** — check you're using the right model. Haiku for search, Sonnet for code.
4. **No caching** — first run of the session is always slow. Subsequent are faster.

### "Many sub-agents spawning in parallel"

This is normal for complex work. To slow it down:
- Lower the `task` allowlist
- Use a smaller model for the orchestrator
- Break the work into smaller tasks

### "Agent keeps re-reading the same file"

The agent doesn't have persistent memory by default. Either:
- Add the info to AGENTS.md
- Use Claude Code's auto-memory
- Reduce the `steps` cap so the agent has to wrap up

---

## 8. Cost issues

### "I'm burning through tokens too fast"

Run `/metrics` to see which agent is expensive.

Common culprits:
- **Architect called too often** — cache its output
- **Scout reading entire files** — use codegraph first
- **No RTK** — install RTK for 60-90% savings on bash
- **Big context** — start sessions fresh
- **Repeating work** — re-using cached results

### "Specific feature is expensive"

Check the agent breakdown in `/metrics`. The expensive one is usually:
- The model is too premium for the task
- The agent has no scope (writing everything inline)
- The prompt is too verbose

### "Hitting subscription limits"

For opencode-go:
- 5h limit: $12
- Weekly: $30
- Monthly: $60

If hitting limits:
- Switch to cheaper models for scout/doc-writer
- Cache more aggressively
- Defer non-urgent work to next period
- Upgrade plan

---

## 9. Platform-specific issues

### opencode: "TUI not rendering"

```bash
# Update opencode
brew upgrade opencode

# Or try a different terminal
# Recommended: Ghostty, WezTerm, Alacritty, Kitty
```

### opencode: "/agents command not found"

In opencode, use `/agent <name>` (singular) to switch. `/agents` (plural) is Claude Code.

### opencode: "model not found"

List available models:
```bash
opencode models
```

The model you specified doesn't exist. Either:
- Use a different model
- Check your provider is configured
- Verify spelling

### Claude Code: "session limit reached"

You're on a free/Pro plan. Either:
- Wait for the limit to reset
- Upgrade to Max
- Use opencode instead

### Claude Code: "MCP tool not available"

Run `/mcp` in the TUI to see all available MCP tools. If your tool isn't listed:
```bash
claude mcp list
```

If not in the list, add it:
```bash
claude mcp add my-mcp -- npx -y @example/mcp-server
```

---

## 10. Common error messages

### "ENOSPC: no space left on device"

Your disk is full. Clean up:
```bash
# Opencode cache
rm -rf ~/.cache/opencode/

# Session logs
rm -rf ~/.config/opencode/logs/*.log

# Old Claude Code sessions
rm -rf ~/.claude/sessions/old/
```

### "ECONNREFUSED 127.0.0.1:port"

An MCP server tried to connect to a local port that's not open. Either:
- The MCP server isn't running (try the command manually)
- Wrong port in config
- Firewall blocking

### "Tool result missing due to internal error"

Temporary issue. Retry the operation. If persistent:
```bash
# Restart opencode
# Or clear session: /clear (Claude Code) or /new (opencode)
```

### "Maximum context length exceeded"

The agent's context is full. Either:
- Start a new session
- Use `/compact` (Claude Code) to summarize
- Reduce the diff size
- Use a more aggressive `.opencodeignore`

### "Rate limit exceeded"

You're hitting the model's rate limit. Either:
- Wait
- Use a different model
- Upgrade plan

### "API key invalid"

```bash
# opencode
opencode auth logout
opencode auth login

# Claude Code
claude auth logout
claude auth login
```

---

## Getting more help

1. Check the [docs/](.) — start with the relevant guide
2. Run with debug: `opencode --debug` or `claude --debug`
3. Check logs: `~/.config/opencode/logs/`, `~/.claude/logs/`
4. Search the opencode / Claude Code docs
5. File an issue: https://github.com/SuyeshBadge/ceo-engineering/issues

---

## See also

- [opencode-guide.md](opencode-guide.md) — opencode usage
- [claude-code-guide.md](claude-code-guide.md) — Claude Code usage
- [efficiency-mcps.md](efficiency-mcps.md) — RTK, Octocode, Caveman
- [architecture.md](architecture.md) — system design
