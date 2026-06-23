# CEO Engineering System

**Turn any engineer into the CEO of their product.** The user gives intent; the system handles the rest.

A platform-agnostic AI engineering setup for **opencode** and **Claude Code** that uses a small fleet of strict-scope subagents, a curated set of daily-work skills, and proven loop patterns to deliver complex engineering work at the lowest possible token cost.

## One-Command Setup

```bash
curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
```

That's it. The installer:
- Detects opencode and/or Claude Code
- Backs up your existing config
- Installs 9 subagents, 23 skills, 5 hook scripts, 3 loop scripts
- Wires everything together with symlinks (skills shared between editors)
- Preserves your existing MCP servers, design agents, and personal rules

**To uninstall:** `curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/uninstall.sh | bash`

## What You Get

### The CEO Agent (primary)
The Chief of Staff. You give it intent. It plans, delegates, and reports in CEO language. **It never writes code directly** — it spawns specialists.

### 8 Specialist Subagents (strict scope)

| Agent | Scope (ONLY does this) | Model (opencode-go) |
|---|---|---|
| `scout` | Read-only search: code, docs, web | `mimo-v2.5` ($0.14/$0.28) |
| `architect` | Design decisions and trade-off analysis | `qwen3.7-max` ($2.50/$7.50) |
| `builder` | Write code, apply edits | `minimax-m3` ($0.30/$1.20) |
| `reviewer` | Code review, read-only | `minimax-m3` ($0.30/$1.20) |
| `tester` | Run tests, interpret results | `kimi-k2.7-code` ($0.95/$4.00) |
| `security` | Security audit, read-only | `glm-5.2` ($1.40/$4.40) |
| `doc-writer` | Documentation, JSDoc, READMEs | `mimo-v2.5` ($0.14/$0.28) |
| `devops` | Deploy, CI, infra | `kimi-k2.7-code` ($0.95/$4.00) |

### 23 Daily-Work Skills

| Command | What it does |
|---|---|
| `/commit` | Conventional commit with pre-commit checks |
| `/pr` | Open a pull request |
| `/review` | Review uncommitted changes |
| `/pr-review <url>` | Review a PR by URL or number |
| `/merge-conflict` | Resolve merge conflicts intelligently |
| `/test` | Run targeted tests |
| `/format` | Format code |
| `/lint` | Run linter |
| `/typecheck` | Run typecheck |
| `/branch <name>` | Create properly-named branch |
| `/sync` | Sync with main, rebase |
| `/explain <target>` | Explain a file or function |
| `/doc` | Generate/update docs |
| `/changelog` | Update CHANGELOG.md |
| `/release` | Cut a release |
| `/hotfix` | Emergency fix branch |
| `/clean` | Clean up merged branches |
| `/feature <desc>` | Full feature pipeline |
| `/bug <desc>` | Bug fix with reproduction test |
| `/refactor <scope>` | Behavior-preserving refactor |
| `/security` | Security audit of changes |
| `/mvp <idea>` | Ralph loop — fire-and-forget build |
| `/metrics` | Show session cost & throughput |

### Loop Patterns

- **`/feature`** — orchestrator → scout → architect → builder → reviewer → tester → doc-writer → commit
- **`/mvp`** — Ralph Wiggum persistent loop for greenfield (L3)
- **`loops/tdd-loop.sh`** — Red-green-refactor TDD loop (L1)
- **`loops/ralph.sh`** — Run any prompt in a persistent loop

## Cost (with opencode-go subscription)

~$0.69 per feature pipeline (8-10 subagent invocations). Heavy usage (8 features/week) ≈ $22/month, well under the $60 cap.

## Documentation

- [docs/architecture.md](docs/architecture.md) — the system design
- [docs/agent-matrix.md](docs/agent-matrix.md) — what each agent does
- [docs/commands.md](docs/commands.md) — all daily commands
- [docs/cost-analysis.md](docs/cost-analysis.md) — model & cost breakdown

## License

MIT — fork, modify, share.
