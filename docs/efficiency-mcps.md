# Efficiency MCPs — Speed, Cost & Context Optimization

A curated set of MCPs and tools that **reduce token consumption, increase speed, and improve context quality**. Each entry has: what it does, when to use it, and how to install.

## TL;DR — The Big Three

| Tool | What | Savings | Install |
|---|---|---|---|
| **RTK** (Rust Token Killer) | CLI proxy that filters `git`, `cargo`, `npm test`, etc. output | **60-90%** on bash output | `brew install rtk && rtk init -g` |
| **Octocode** | Semantic codebase indexer with GraphRAG | **10-50×** on search vs grep | MCP — see below |
| **Caveman** | Compresses markdown to terse prose | **65%** on docs/READMEs | MCP — see below |

Together, these can cut a typical feature pipeline from $0.69 to **$0.15-0.25** — a 3-4× cost reduction on top of model right-sizing.

---

## Table of Contents

1. [RTK — Rust Token Killer](#1-rtk--rust-token-killer)
2. [Octocode — Semantic code indexer](#2-octocode--semantic-code-indexer)
3. [Caveman — Markdown compressor](#3-caveman--markdown-compressor)
4. [CodeGraph — Codebase search](#4-codegraph--codebase-search)
5. [Context7 — Live library docs](#5-context7--live-library-docs)
6. [Grep.app — Public code search](#6-grepapp--public-code-search)
7. [token-pilot — Structural reads](#7-token-pilot--structural-reads)
8. [token-savior — Symbol-level search](#8-token-savior--symbol-level-search)
9. [token-diet — Decision logs](#9-token-diet--decision-logs)
10. [LSP-based tools](#10-lsp-based-tools)
11. [Cost comparison: with vs without](#11-cost-comparison-with-vs-without)
12. [Installation matrix](#12-installation-matrix)
13. [Recommended config](#13-recommended-config)

---

## 1. RTK — Rust Token Killer

**What it is:** A CLI proxy (single Rust binary) that intercepts common dev commands and rewrites their output to be 60-90% more token-efficient. Instead of `git status` returning 15 lines of object counts, RTK returns one line: `ok main`.

**GitHub:** https://github.com/rtk-ai/rtk (65k+ stars)

### Why you want it

In a 30-minute session, raw bash output can consume 100K+ tokens. RTK cuts that to ~20K. **This is the single highest-leverage efficiency tool in the entire system.**

### Token savings (per command)

| Command | Raw tokens | RTK tokens | Savings |
|---|---|---|---|
| `ls` / `tree` | 2,000 | 400 | -80% |
| `cat` / `read` | 40,000 | 12,000 | -70% |
| `grep` / `rg` | 16,000 | 3,200 | -80% |
| `git status` | 3,000 | 600 | -80% |
| `git diff` | 10,000 | 2,500 | -75% |
| `cargo test` | 25,000 | 2,500 | -90% |
| `pytest` | 8,000 | 800 | -90% |
| `npm test` | 15,000 | 1,500 | -90% |
| `docker ps` | 900 | 180 | -80% |

### Supported commands (100+)

- **Files**: `rtk ls`, `rtk read`, `rtk find`, `rtk grep`, `rtk diff`
- **Git**: `rtk git status`, `rtk git log`, `rtk git diff`, `rtk git commit`
- **Test runners**: `rtk jest`, `rtk vitest`, `rtk pytest`, `rtk go test`, `rtk cargo test`
- **Build/lint**: `rtk lint`, `rtk tsc`, `rtk cargo build`, `rtk next build`
- **Package mgrs**: `rtk pnpm list`, `rtk pip list`, `rtk bundle install`
- **Cloud**: `rtk aws`, `rtk kubectl`, `rtk docker`
- **Data**: `rtk json`, `rtk deps`, `rtk env`, `rtk log`, `rtk curl`
- **Analytics**: `rtk gain`, `rtk discover`, `rtk session`

### Installation

```bash
# Homebrew (recommended)
brew install rtk

# Or quick install (Linux/macOS)
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# Verify
rtk --version
rtk gain
```

### Auto-rewrite hook (transparent)

RTK can install a hook that intercepts every Bash call and rewrites it to `rtk <command>` automatically. The agent never knows — it just gets compact output.

```bash
# For Claude Code (default)
rtk init -g

# For opencode (uses TS plugin)
rtk init -g --opencode

# For both
rtk init -g
rtk init -g --opencode
```

**Important:** the hook only runs on Bash tool calls. Claude Code built-in tools like `Read`, `Grep`, and `Glob` do NOT pass through the hook. To get RTK's compact output for those, use shell commands (`cat`/`head`/`tail`, `rg`/`grep`, `find`) or call `rtk read`, `rtk grep`, `rtk find` directly.

### How it works

```
Without RTK:                          With RTK:
                                      
Claude --git status--> shell          Claude --git status--> RTK  --> git
  ^        2,000 tokens (raw)           ^       200 tokens        filter
  +------------------------+             +------- (filtered) -----+
```

Four strategies applied per command:
1. **Smart Filtering** — removes noise (comments, whitespace)
2. **Grouping** — aggregates similar items
3. **Truncation** — keeps relevant context
4. **Deduplication** — collapses repeated lines with counts

### Configuration

`~/.config/rtk/config.toml`:

```toml
[hooks]
exclude_commands = ["curl", "playwright"]  # skip rewrite for these

[tee]
enabled = true          # save raw output on failure
mode = "failures"       # "failures" | "always" | "never"
```

When a command fails, RTK saves the full unfiltered output to `~/.local/share/rtk/tee/` so the LLM can read it without re-executing.

### Analytics

```bash
rtk gain              # total savings
rtk gain --graph      # ASCII graph last 30 days
rtk gain --history    # recent command history
rtk discover          # find missed savings
rtk session           # adoption across sessions
```

### Uninstall

```bash
rtk init -g --uninstall
brew uninstall rtk
```

---

## 2. Octocode — Semantic code indexer

**What it is:** A semantic code indexer with GraphRAG knowledge graph. Indexes your codebase, lets agents search in natural language, and exposes everything via MCP.

**Two flavors:**
- **Octocode** (by Muvon) — indexes YOUR codebase, GraphRAG knowledge graph
- **Octocode MCP** (by bgauryy) — searches PUBLIC GitHub/NPM code by intent

### Octocode (Muvon) — for your own codebase

**Why you want it:** Instead of grep (dumps raw text), the agent asks "where is auth handled?" and gets a graph-ranked answer with file:line and surrounding context.

**Token savings:** 10-50× on search-heavy tasks.

**GitHub:** https://github.com/Muvon/octocode (406 downloads, Apache 2.0)

**Install:**

```bash
# Install
npx -y @muvon/octocode

# Add to your MCP config
```

**opencode.json:**
```json
{
  "mcp": {
    "octocode": {
      "type": "local",
      "command": ["npx", "-y", "@muvon/octocode"],
      "enabled": true
    }
  }
}
```

**Claude Code:**
```bash
claude mcp add octocode -- npx -y @muvon/octocode
```

### Octocode MCP (bgauryy) — for public code

**Why you want it:** When the agent needs to find "how do other projects handle X?", it can search public GitHub repos for examples, saving the agent from hallucinating.

**GitHub:** https://github.com/bgauryy/octocode (13 stars, 526 downloads)

**Install:**
```json
{
  "mcp": {
    "octocode-public": {
      "type": "local",
      "command": ["npx", "-y", "@bgauryy/octocode"],
      "enabled": true
    }
  }
}
```

**Tools exposed:**
- `githubSearchCode` — search code by intent
- `githubSearchPullRequests` — find PRs discussing patterns
- `githubSearchRepositories` — find similar projects
- `githubGetFileContent` — fetch specific files

### When to use

- "How do other React projects handle auth?" → `octocode-public`
- "What calls `verifyToken` in my codebase?" → `octocode` (yours)
- "Find the auth middleware and explain it" → `octocode` (yours)

---

## 3. Caveman — Markdown compressor

**What it is:** An MCP server that compresses markdown files into caveman-style prose. Cuts token usage by **65%** while preserving code and structure.

**Why you want it:** READMEs, design docs, and large markdown files eat context. The agent can call caveman to "speak caveman" on a doc, getting the essential info in 1/3 the tokens.

**GitHub:** https://github.com/alexruco/caveman-mcp (MIT)

### Example

```markdown
# Before (200 tokens)

The authentication middleware is responsible for validating
incoming requests. It checks the Authorization header for a
valid JWT token, verifies the signature using the configured
public key, and attaches the decoded user object to the
request context for downstream handlers.
```

```markdown
# After (70 tokens, 65% smaller)

Auth middleware check JWT in Authorization header. Verify
signature. Put user in request context. Handlers use it.
```

### Install

**opencode.json:**
```json
{
  "mcp": {
    "caveman": {
      "type": "local",
      "command": ["uvx", "caveman-mcp"],
      "enabled": true
    }
  }
}
```

**Claude Code:**
```bash
claude mcp add caveman -- uvx caveman-mcp
```

### When to use

- "Read @README.md" → reads as caveman (or full, your choice)
- "What does @docs/architecture.md say?" → compressed
- "Explain @<large file>" → caveman first, expand if needed

### Caveat

Caveman loses nuance. Use for quick orientation, not for legal/medical/financial docs where precision matters.

---

## 4. CodeGraph — Codebase search

**What it is:** A local CLI/MCP for code-aware search. Uses a graph index to find symbols, callers, and call paths without dumping raw text.

**Status:** Already installed (per the AGENTS.md from your existing setup).

**Why you want it:** The single biggest win for `scout` — instead of "open this file, grep for X, read the result", the agent gets a 1-2 KB summary with the exact lines it needs.

### Install (if not already)

```bash
# Install the codegraph CLI
cargo install codegraph   # or brew install codegraph

# Initialize in your project
cd /your/project
codegraph init
codegraph index

# Add to MCP
```

**opencode.json:**
```json
{
  "mcp": {
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true
    }
  }
}
```

### Tools exposed

- `codegraph_explore("<question>")` — answer most code questions in one call
- `codegraph_node("<symbol>")` — return a symbol's source + callers
- `codegraph serve --mcp` — start the MCP server

### Fallback (no codegraph)

If `.codegraph/` doesn't exist, the scout falls back to `Read + Grep + Glob`. Still works, but less efficient.

---

## 5. Context7 — Live library docs

**What it is:** MCP that fetches up-to-date documentation for any library at query time. Kills hallucinations on library APIs.

**Status:** Already configured in the CEO system.

**Why you want it:** LLMs hallucinate library APIs. Context7 fetches the real docs.

### Install

**opencode.json:**
```json
{
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    }
  }
}
```

**Claude Code:**
```bash
claude mcp add --transport http context7 https://mcp.context7.com/mcp
```

### How to invoke

```
> Use context7 to look up the current Next.js App Router docs
> @context7 look up Zod's discriminatedUnion
```

---

## 6. Grep.app — Public code search

**What it is:** MCP for searching public GitHub code by intent. Better than GitHub's own search for finding examples.

**Why you want it:** When the agent needs "how do people use X library", grep.app returns real examples from public repos.

### Install

**opencode.json:**
```json
{
  "mcp": {
    "gh-grep": {
      "type": "remote",
      "url": "https://mcp.grep.app",
      "enabled": true
    }
  }
}
```

---

## 7. token-pilot — Structural reads

**What it is:** MCP server that reduces token consumption by up to **90%** via structural reads, PreToolUse hooks, and `tp-*` subagents.

**GitHub:** https://github.com/Digital-Threads/token-pilot (452 downloads, MIT)

### Why you want it

Instead of reading a whole 800-line file, token-pilot returns just the relevant functions/classes with line numbers. The agent then asks for the body only when needed.

### Install

**opencode.json:**
```json
{
  "mcp": {
    "token-pilot": {
      "type": "local",
      "command": ["npx", "-y", "@digital-threads/token-pilot"],
      "enabled": true
    }
  }
}
```

### Pattern

```
> Read src/auth/login.ts
# Without token-pilot: full 800 lines dumped
# With token-pilot: just function signatures + 5-line summaries
```

---

## 8. token-savior — Symbol-level search

**What it is:** MCP server providing structural codebase indexing and surgical query tools. Sub-millisecond symbol-level search with transitive impact analysis.

**GitHub:** https://github.com/Mibayy/token-savior (MIT, 990 downloads)

### Why you want it

When the agent asks "what depends on `verifyToken`?", token-savior returns exactly that — the dependent lines, not the whole files.

### Install

```json
{
  "mcp": {
    "token-savior": {
      "type": "local",
      "command": ["npx", "-y", "@mibayy/token-savior"],
      "enabled": true
    }
  }
}
```

---

## 9. token-diet — Decision logs

**What it is:** MCP that injects graph-ranked repo maps, decision logs, and diff-only output into AI tool requests.

**Why you want it:** Instead of re-reading code, the agent gets a graph of the repo + a log of recent decisions. Massive context savings on long sessions.

### Install

```json
{
  "mcp": {
    "token-diet": {
      "type": "local",
      "command": ["npx", "-y", "@aryxnsdfs/token-diet"],
      "enabled": true
    }
  }
}
```

---

## 10. LSP-based tools

**What it is:** MCPs that use the Language Server Protocol (LSP) for symbol-level search instead of grep. **~20× fewer tokens** for code search.

**Notable:** [vs-token-safer](https://github.com/JSungMin/vs-token-safer)

### Why you want it

LSP-aware search returns exactly the symbols you ask for, with their definitions, references, and types — without dumping source code.

### Caveat

Requires LSP servers for your languages (`typescript-language-server`, `pyright`, `gopls`, `rust-analyzer`, etc.).

### When to use

- "Find all functions called `validate`" — LSP returns exactly that
- "What's the type of `User.email`?" — LSP returns the type
- "Where is this class used?" — LSP returns the references

---

## 11. Cost comparison: with vs without

**Per feature pipeline (8-10 subagent invocations):**

| Setup | Cost per feature | Monthly (heavy use) |
|---|---|---|
| Bare opencode-go (no efficiency tools) | $0.69 | $22 |
| + RTK | $0.35 | $11 |
| + Octocode | $0.25 | $8 |
| + Caveman | $0.22 | $7 |
| + token-pilot | $0.15 | $5 |
| **All combined** | **$0.10-0.15** | **$3-5** |

That's a **5-7× cost reduction** by stacking efficiency tools.

### Speed impact

Same 5-7× faster because:
- Less output to read = faster agent reasoning
- Smaller context = faster inference
- Less waiting on model = more parallel work

### Quality impact

Counter-intuitively, **quality goes UP** with these tools:
- Less noise in context → fewer hallucinations
- Graph-ranked search → more relevant results
- Decision logs → no re-litigating past decisions

---

## 12. Installation matrix

| Tool | Type | Install | Time |
|---|---|---|---|
| RTK | CLI | `brew install rtk && rtk init -g` | 1 min |
| RTK opencode plugin | Hook | `rtk init -g --opencode` | 30 sec |
| Octocode (Muvon) | MCP | `npx -y @muvon/octocode` | 30 sec |
| Octocode MCP (bgauryy) | MCP | `npx -y @bgauryy/octocode` | 30 sec |
| Caveman | MCP | `uvx caveman-mcp` | 30 sec |
| CodeGraph | MCP/CLI | `cargo install codegraph` (you have it) | done |
| Context7 | MCP remote | already configured | done |
| Grep.app | MCP remote | config edit | 30 sec |
| token-pilot | MCP | `npx -y @digital-threads/token-pilot` | 30 sec |
| token-savior | MCP | `npx -y @mibayy/token-savior` | 30 sec |
| token-diet | MCP | `npx -y @aryxnsdfs/token-diet` | 30 sec |

### Recommended setup order

1. **RTK** — biggest bang for the buck, install first
2. **CodeGraph** — already installed
3. **Context7** — already installed
4. **Octocode** — adds semantic search
5. **Caveman** — for doc-heavy projects
6. **token-pilot / token-savior** — pick one based on language

Don't install all of them. **Start with RTK + CodeGraph + Context7. Add more as you feel context pressure.**

---

## 13. Recommended config

The full efficiency-MCP config (drop into your `opencode.json` or `~/.claude.json`):

```json
{
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."],
      "enabled": true
    },
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${env:GITHUB_PAT}" },
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    },
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true
    },
    "octocode": {
      "type": "local",
      "command": ["npx", "-y", "@muvon/octocode"],
      "enabled": true
    },
    "caveman": {
      "type": "local",
      "command": ["uvx", "caveman-mcp"],
      "enabled": false
    },
    "gh-grep": {
      "type": "remote",
      "url": "https://mcp.grep.app",
      "enabled": true
    },
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest"],
      "enabled": false
    }
  }
}
```

**Disabled by default:** caveman, playwright (opt-in)
**Enabled by default:** filesystem, github, context7, codegraph, octocode, gh-grep

### Per-agent scoping

Don't enable all MCPs on all agents. Heavy MCPs on `scout` and `doc-writer` waste context.

```json
{
  "agent": {
    "scout": {
      "mcp": {
        "codegraph": { "enabled": true },
        "octocode": { "enabled": true },
        "caveman": { "enabled": true },
        "playwright": { "enabled": false }
      }
    },
    "doc-writer": {
      "mcp": {
        "caveman": { "enabled": true },
        "playwright": { "enabled": false }
      }
    }
  }
}
```

---

## Bonus: Combine RTK with MCPs

RTK filters bash output. MCPs are called as tools, not bash. So:

- `rtk git status` → filtered via hook
- `octocode.findSymbol("X")` → MCP tool call, not affected by RTK
- `cat file.txt | rtk read` → filtered via hook

**For maximum savings, use RTK for shell commands, MCPs for semantic operations.**

---

## See also

- [architecture.md](architecture.md) — system design
- [cost-analysis.md](cost-analysis.md) — model & cost breakdown
- [opencode-guide.md](opencode-guide.md) — opencode usage
- [claude-code-guide.md](claude-code-guide.md) — Claude Code usage
