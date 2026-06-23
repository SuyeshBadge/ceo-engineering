# CEO Engineering System

**Turn any engineer into the CEO of their product.** The user gives intent; the system handles the rest.

A platform-agnostic AI engineering setup for **opencode** and **Claude Code** that uses a small fleet of strict-scope subagents, a curated set of daily-work skills, and proven loop patterns to deliver complex engineering work at the lowest possible token cost.

## One-Command Setup

```bash
curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
```

The installer:
- Detects opencode and/or Claude Code
- Backs up your existing config
- Installs **9 subagents, 23 built-in skills, 5 hook scripts, 3 loop scripts**
- Wires up **efficiency MCPs** (CodeGraph, Octocode, Context7, Grep.app)
- Installs **~70+ curated skills from skills.sh** (process, frontend, backend, design, caveman)
- Optionally installs **RTK** (Rust Token Killer — 60-90% bash savings)
- Symlinks skills between editors
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

### 23 Built-in Daily-Work Skills

| Group | Commands |
|---|---|
| **Commit & ship** | `/commit` `/pr` `/pr-review` `/review` `/merge-conflict` |
| **Test & verify** | `/test` `/format` `/lint` `/typecheck` `/security` |
| **Branch & sync** | `/branch` `/sync` `/clean` |
| **Release & docs** | `/changelog` `/release` `/hotfix` `/doc` |
| **Understand & big work** | `/explain` `/feature` `/bug` `/refactor` `/mvp` `/metrics` |

### 70+ Curated Skills from skills.sh (auto-installed)

| Category | Source | What you get |
|---|---|---|
| **Process** | `obra/superpowers` | 14 skills (TDD, debugging, planning, subagent patterns, code review) |
| **TypeScript** | `mattpocock/skills` | 13+ skills (grill-me, tdd, architecture, prototype, handoff) |
| **Caveman** | `juliusbrussee/caveman` | 7 skills (terse prompting family) |
| **Frontend** | `vercel-labs/agent-skills`, `vercel-labs/next-skills`, `shadcn/ui`, `anthropics/skills` | React, Next.js, shadcn, design |
| **Backend** | `supabase/agent-skills`, `xixu-me/skills` | Postgres, Supabase, GitHub Actions |
| **Design** | `pbakaus/impeccable`, `leonxlnx/taste-skill`, `sleekdotdesign`, `ui-ux-pro-max`, `extract-design-system`, `coreyhaines31/marketingskills` | UI/UX polish, design taste, SEO |

See [docs/skills-from-skills-sh.md](docs/skills-from-skills-sh.md) for the full curated list.

### Loop Patterns

- **`/feature`** — full orchestrator pipeline
- **`/mvp`** — Ralph Wiggum persistent loop for greenfield (L3)
- **`loops/tdd-loop.sh`** — Red-green-refactor TDD loop (L1)

### Efficiency MCPs (cut cost 3-5×)

| Tool | Savings | What |
|---|---|---|
| **RTK** (Rust Token Killer) | 60-90% on bash | CLI proxy that filters noisy output |
| **CodeGraph** | 10-50× on search | Graph-indexed code search |
| **Octocode** | 10-50× on search | Semantic code indexer with GraphRAG |
| **Caveman** | 65% on markdown | Compresses docs to terse prose |
| **Context7** | n/a | Live library docs (kills hallucinations) |
| **Grep.app** | n/a | Public GitHub code search |

See [docs/efficiency-mcps.md](docs/efficiency-mcps.md) for the full guide.

## Cost (with opencode-go + RTK + Octocode + Caveman)

~$0.10-0.15 per feature pipeline (down from $0.69 bare). Heavy usage (8 features/week) ≈ $3-5/month.

## Documentation

### Getting started
- **[docs/opencode-guide.md](docs/opencode-guide.md)** — full opencode walkthrough
- **[docs/claude-code-guide.md](docs/claude-code-guide.md)** — full Claude Code walkthrough

### Reference
- **[docs/architecture.md](docs/architecture.md)** — the system design
- **[docs/agent-matrix.md](docs/agent-matrix.md)** — what each agent does
- **[docs/commands.md](docs/commands.md)** — all daily commands
- **[docs/cost-analysis.md](docs/cost-analysis.md)** — model & cost breakdown
- **[docs/efficiency-mcps.md](docs/efficiency-mcps.md)** — RTK, Octocode, Caveman, etc.
- **[docs/skills-from-skills-sh.md](docs/skills-from-skills-sh.md)** — curated skills from skills.sh
- **[docs/glossary.md](docs/glossary.md)** — terms defined

### Practical
- **[docs/workflows.md](docs/workflows.md)** — 15 end-to-end recipes
- **[docs/troubleshooting.md](docs/troubleshooting.md)** — when things go wrong

## License

MIT — fork, modify, share.
