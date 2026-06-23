# CEO Engineering Architecture

## The Vision

An engineer gives **intent** ("add MFA to login"). The system produces a **delivered, verified, cost-tracked, risk-flagged outcome**. The engineer becomes the **CEO of the product** — making decisions, not implementing them.

## The Pipeline (L1 — single task)

```
            YOU (CEO)
                │  intent
                ▼
        ┌───────────────┐
        │   CEO agent   │  Sonnet-tier · plans + delegates
        │  (primary)    │
        └───────┬───────┘
                │
   ┌────────────┼────────────┬────────────┐
   ▼            ▼            ▼            ▼
┌──────┐   ┌────────┐   ┌──────┐    ┌────────┐
│scout │ → │architct│ → │builder│ →  │reviewer│
│haiku │   │ premium│   │ code  │    │ code   │
│      │   │        │   │ tier  │    │ tier   │
└──────┘   └────────┘   └──────┘    └────────┘
                              │            │
                              └─────┬──────┘
                                    ▼
                              ┌──────────┐
                              │  tester  │  (loops with builder, max 4 iters)
                              │ code-spec │
                              └────┬─────┘
                                   │ green
                                   ▼
                            ┌──────────────┐
                            │  doc-writer  │  (background, haiku)
                            │  + commit    │
                            └──────┬───────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │ CEO reports  │  in CEO language
                            └──────────────┘
```

## The 4 Levels of Loops

| Level | Name | What | Where |
|---|---|---|---|
| L1 | Inner loop | Builder ↔ Tester, max 4 iters | Inside `/feature`, `/bug`, `/refactor` |
| L2 | Verification | Tests + typecheck + lint must all pass | After L1, before "done" |
| L3 | Persistent | `ralph.sh` — runs prompt in a loop with cost/time cap | `/mvp`, greenfield work |
| L4 | Hill-climbing | Track metrics, tune prompts, improve harness | `/metrics` + manual review |

## Strict Agent Scope (no overlap)

| Agent | CAN do | CANNOT do |
|---|---|---|
| `scout` | Read, grep, glob, fetch, search | Write, edit, run package commands |
| `architect` | Read, design docs | Edit, implement, run code |
| `builder` | Read, edit, write, run tests | Spawn other sub-agents (except scout) |
| `reviewer` | Read, comment, report | Edit, write, run code |
| `tester` | Run test/typecheck/lint commands | Edit source files |
| `security` | Read, scan, audit | Edit, run arbitrary code |
| `doc-writer` | Read, edit, write docs | Run any command (bash denied) |
| `devops` | All ops commands (after confirmation) | Auto-deploy without confirm |
| `ceo` | Spawn any agent, read | Edit, write, implement |

## Cost Model (opencode-go)

| Tier | Models | $/1M in/out | Used for |
|---|---|---|---|
| Ultra cheap | `mimo-v2.5`, `deepseek-v4-flash` | $0.14/$0.28 | scout, doc-writer |
| Cheap | `minimax-m3`, `minimax-m2.7` | $0.30/$1.20 | builder, reviewer |
| Mid | `qwen3.7-plus`, `kimi-k2.7-code` | $0.40-0.95 / $1.60-4.00 | tester, ceo, devops |
| Premium | `qwen3.7-max`, `glm-5.2` | $1.40-2.50 / $4.40-7.50 | architect, security |

**Per-feature cost: ~$0.69** (with caching: lower).
**Heavy use (8 features/week): ~$22/month** (under $60 cap).

## Portability

- **Rules** (`AGENTS.md` / `CLAUDE.md`): symlinked between opencode and Claude Code
- **Skills** (`SKILL.md`): symlinked (Agent Skills standard, both editors read both paths)
- **Agents**: separate files (different frontmatter schemas) but shared system-prompt bodies
- **Hooks**: separate implementations (TS plugins for opencode, shell + JSON for Claude Code)
- **Loops**: pure bash, work everywhere

## Safety Rails

| Layer | Mechanism | What it stops |
|---|---|---|
| Permissions | `permission: { ... }` in config | Sub-agents overstepping scope |
| PreToolUse hook | `block-destructive.sh` | `rm -rf`, force-push, pipe-to-shell |
| PreToolUse hook | `env-protection.sh` | Reading `.env` files |
| PostToolUse hook | `format-on-save.sh` | Unformatted commits |
| PostToolUse hook | `run-typecheck.sh` | Type errors sneaking in |
| Steps cap | `steps: 50` per agent | Runaway token spend |
| Cost cap | `--cost-cap` on ralph | Ralph loop overspending |
| Loop cap | Max 4 iters builder↔tester | Infinite loops |

## Extending the System

### Add a new skill
```bash
mkdir -p skills/my-skill
cat > skills/my-skill/SKILL.md <<'EOF'
---
name: my-skill
description: What it does + when to use
allowed-tools: ...
---
## Instructions
...
EOF
```
The setup script auto-installs it. Symlink to `~/.claude/skills/my-skill`.

### Add a new agent
1. Create `agents/my-agent.md` (opencode frontmatter)
2. Create `agents-cc/my-agent.md` (Claude Code frontmatter)
3. Add to `opencode.json` under `agent:` and `permission.task` allowlist on `ceo`
4. Rerun `setup.sh` (or just copy the new files)

### Add a new hook
1. Write `hooks/my-hook.sh`
2. Reference in `config/settings.json` under `hooks.<event>`
3. For opencode: write a TS plugin in `plugins/`
