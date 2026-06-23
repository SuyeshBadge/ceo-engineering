# Glossary

Terms used throughout the CEO Engineering System.

---

## A

**Agent** — A specialized LLM with its own system prompt, tools, and model selection. The CEO system has 9 agents, each with strict, non-overlapping scope.

**AGENTS.md** — The master instruction file. Loaded at session start. Contains the rules the agent follows. The CEO system's "constitution."

**Agent Skills standard** — The open format for skills (`SKILL.md`). Used by opencode, Claude Code, and other tools. See https://agentskills.io.

**Architect agent** — The design specialist. Produces decision documents, not code. Called once per task, output cached.

**Auto-memory** — Claude Code's auto-written memory files in `~/.claude/projects/<hash>/memory/`. The agent writes things it learns.

## B

**Builder agent** — The code-writer. The only agent (other than `doc-writer` and `devops`) that edits files.

**Background subagent** — A subagent that runs concurrently while the parent continues. Available in both opencode and Claude Code.

## C

**Cache hit** — When the model has the same content in its context from a previous request. Cached reads cost ~10-20% of fresh reads.

**Caveman MCP** — A markdown compressor that cuts token usage by 65%. Useful for doc-heavy projects.

**CEO agent** — The Chief of Staff. The primary agent. Plans, delegates, reports. Never writes code.

**CLAUDE.md** — Claude Code's master instruction file. Symlinked to `AGENTS.md` in the CEO system.

**Context window** — The maximum amount of text (input + output) the model can process. Capped per model. opencode-go models support 256K tokens in the cheap tier.

**CodeGraph** — A code-aware search tool that uses a graph index. 1-2 KB answers instead of 50 KB grep dumps.

**Cost cap** — A limit on how much money the system will spend on a task or session. The CEO system caps per-agent, per-feature, and per-month.

## D

**Devops agent** — The infrastructure specialist. Deploys, configures CI, manages env. Requires user confirmation for prod actions.

**Doc-writer agent** — The documentation specialist. Updates READMEs, JSDoc, inline comments. Has bash disabled.

## E

**Efficiency MCP** — MCPs that reduce token consumption (RTK, Octocode, Caveman, token-pilot, etc.).

## F

**Frontmatter** — The YAML metadata at the top of an agent or skill file. Required fields differ between opencode and Claude Code.

## G

**Grep.app** — A public GitHub code search MCP. Better than raw GitHub search for finding examples.

## H

**Hook** — A script that runs on a lifecycle event (PreToolUse, PostToolUse, SessionStart, etc.). Used for safety, formatting, auditing.

## I

**Inner loop** — L1 in the loop hierarchy. Builder ↔ Tester, max 4 iterations. Inside a single feature/bug/refactor.

**Instructions** — The `instructions` array in `opencode.json` — always-loaded rules.

## L

**L1, L2, L3, L4** — Loop levels. L1 = inner, L2 = verification, L3 = persistent (Ralph), L4 = hill-climbing (metrics + tuning).

**Loop** — A repeated execution pattern. The CEO system has inner loops (L1), verification loops (L2), persistent loops (L3, Ralph), and improvement loops (L4).

## M

**MaxTurns / steps** — A cap on how many agentic turns a subagent can take. Forces summarization when reached.

**MCP** — Model Context Protocol. The standard for extending AI tools with external capabilities. See https://modelcontextprotocol.io.

**MCP server** — A process that exposes tools via the MCP protocol. Examples: filesystem, github, codegraph, RTK proxies.

**minimax-m3** — The user's default opencode-go model. $0.30/$1.20 per 1M tokens. Good for code work.

## O

**Octocode** — A semantic code indexer with GraphRAG. Natural language search over codebases. 10-50× savings on search.

**opencode-go** — A low-cost subscription service. $5 first month, $10/month after. Provides access to optimized open models.

**Orchestrator** — The CEO agent. Delegates to workers. In some docs, "orchestrator" is used interchangeably with "CEO."

## P

**Permission glob** — A pattern like `"git status *"` used to allow/deny specific bash commands.

**PreToolUse hook** — Runs before a tool is called. Can block the tool.

**PostToolUse hook** — Runs after a tool succeeds. Used for formatting, typecheck, auditing.

**Persistent loop** — L3 in the loop hierarchy. Runs indefinitely until cost/time cap hit. See Ralph Wiggum pattern.

**Pipeline** — The end-to-end flow: scout → architect → builder → reviewer+tester → doc-writer → commit.

**Primary agent** — The default agent. In the CEO system, this is the `ceo` agent.

**Provider** — The backend for LLM inference. opencode supports 75+ providers (Anthropic, OpenAI, Google, Bedrock, etc.).

## R

**Ralph Wiggum pattern** — A persistent loop where the agent runs in a fresh context every iteration, reading state from the filesystem. See https://ghuntley.com/ralph/.

**Reviewer agent** — The code review specialist. Read-only. Reports findings with severity (Blocker/Major/Minor/Praise).

**RTK (Rust Token Killer)** — A CLI proxy that reduces bash output by 60-90%. Works via hook. https://github.com/rtk-ai/rtk.

## S

**Scout agent** — The read-only search specialist. Always spawned first. Returns 1-2 KB context.

**Security agent** — The audit specialist. Checks for OWASP top 10 and other vulnerabilities. Read-only.

**Skill** — A reusable workflow defined in `SKILL.md`. Portable across opencode and Claude Code.

**SKILL.md** — The skill definition file. YAML frontmatter + markdown body.

**Steps** — The cap on agentic turns in opencode. Forces summarization when reached.

**Strict scope** — Each agent has a defined set of capabilities and explicit "CANNOT do" rules. No overlap.

**Subagent** — An agent spawned by another agent. Has its own context, tools, and model.

**Subagent permission** — The allowlist of which subagents a parent can spawn. `permission.task: { "*": "deny", "scout": "allow" }`.

**Symlink** — A file that points to another. Used in the CEO system to share skills and AGENTS.md between opencode and Claude Code.

## T

**TDD loop** — A red-green-refactor loop. Write a failing test, make it pass, refactor. Repeat.

**Tester agent** — The test runner. Verifies builder's work by running tests, typecheck, lint.

**Token** — The unit of text the model processes. Roughly 0.75 words = 1 token. Cost is per million tokens.

**Token budget** — The maximum cost (in dollars) for a task. The CEO system has budgets per task type.

**TypeScript-style frontmatter** — Used in opencode agents. YAML at the top of the .md file.

## V

**Verification loop** — L2 in the loop hierarchy. Tests + typecheck + lint must all pass.

**Variant** — A specific configuration of a model (e.g., `qwen3.7-plus` has `low` and `high` variants for thinking effort).

## W

**Worktree** — A separate working directory for a git branch. Used for parallel agent work without conflicts.

---

## Concepts vs Implementations

| Concept | opencode | Claude Code |
|---|---|---|
| Master rules | `AGENTS.md` | `CLAUDE.md` (symlinked) |
| Subagent | `mode: subagent` in frontmatter | `tools: Agent(name)` in parent |
| Subagent model | `model: opencode-go/x` | `model: sonnet/opus/haiku` |
| Hook | TypeScript plugin | JSON + shell script |
| Loop | Bash script | Bash script or Routines |
| Skill | `SKILL.md` | `SKILL.md` (same format) |
| Plan mode | Tab key | `permissionMode: plan` |
| Memory | Manual (AGENTS.md) | Auto + manual |
| Schedule | External cron | Routines (built-in) |

---

## See also

- [architecture.md](architecture.md) — system design
- [opencode-guide.md](opencode-guide.md) — opencode usage
- [claude-code-guide.md](claude-code-guide.md) — Claude Code usage
- [efficiency-mcps.md](efficiency-mcps.md) — RTK, Octocode, Caveman
