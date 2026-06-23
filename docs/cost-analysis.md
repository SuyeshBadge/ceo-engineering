# Cost Analysis — opencode-go

## Your subscription

**OpenCode Go** — $5 first month, $10/month after.
- $12 / 5h limit
- $30 / week limit
- $60 / month limit
- Models hosted in US, EU, Singapore
- Zero-retention, no training

## Model Catalog & Pricing

| Model | Input $/1M | Output $/1M | Cached read $/1M | Req/5h |
|---|---|---|---|---|
| `mimo-v2.5` | $0.14 | $0.28 | — | **30,100** |
| `deepseek-v4-flash` | $0.14 | $0.28 | — | 31,650 |
| `minimax-m3` | $0.30 | $1.20 | $0.06 | 3,200 |
| `minimax-m2.7` | $0.30 | $1.20 | $0.06 | 3,400 |
| `qwen3.7-plus` (≤256K) | $0.40 | $1.60 | $0.04 | 4,300 |
| `qwen3.7-plus` (>256K) | $1.20 | $4.80 | $0.12 | — |
| `kimi-k2.7-code` | $0.95 | $4.00 | $0.19 | 1,350 |
| `kimi-k2.6` | $0.95 | $4.00 | $0.16 | 1,150 |
| `qwen3.6-plus` (≤256K) | $0.50 | $3.00 | $0.05 | 3,300 |
| `deepseek-v4-pro` | $1.74 | $3.48 | $0.0145 | 3,450 |
| `mimo-v2.5-pro` | $1.74 | $3.48 | $0.0145 | — |
| `glm-5.1` | $1.40 | $4.40 | $0.26 | 880 |
| `glm-5.2` | $1.40 | $4.40 | $0.26 | 880 |
| `qwen3.7-max` | $2.50 | $7.50 | $0.50 | 950 |

## Agent Model Assignment

| Agent | Model | Cost tier | Why |
|---|---|---|---|
| `ceo` | `qwen3.7-plus` | Mid | Smart enough for planning, cache-friendly |
| `scout` | `mimo-v2.5` | Ultra cheap | Pure search, 30K req/5h headroom |
| `architect` | `qwen3.7-max` | Premium | Called once/task, must be best |
| `builder` | `minimax-m3` | Cheap | Code workhorse, 3.2K req/5h |
| `reviewer` | `minimax-m3` | Cheap | Same as builder |
| `tester` | `kimi-k2.7-code` | Mid | Code-specialized, good at debug |
| `security` | `glm-5.2` | Premium | Strong reasoning, sparse use |
| `doc-writer` | `mimo-v2.5` | Ultra cheap | Simple docs |
| `devops` | `kimi-k2.7-code` | Mid | Code + ops, code-specialized |

## Per-Feature Cost Estimate

A typical `/feature` pipeline runs ~8-10 subagent invocations. Assuming ~50K input + 5K output tokens per invocation, with 70% cache hit rate:

| Invocation | Model | Cost |
|---|---|---|
| CEO × 1 | qwen3.7-plus | $0.05 |
| Scout × 1 | mimo-v2.5 | $0.01 |
| Architect × 1 (if needed) | qwen3.7-max | $0.30 |
| Builder × 3 (avg w/ loop) | minimax-m3 | $0.12 |
| Reviewer × 1 | minimax-m3 | $0.04 |
| Tester × 2 | kimi-k2.7-code | $0.16 |
| Doc-writer × 1 | mimo-v2.5 | $0.01 |
| **Total per feature** | | **~$0.69** |

## Usage Projections

| Usage level | Features/month | Cost | % of $60 cap |
|---|---|---|---|
| Light (1-2 features/week) | 6 | $4 | 7% |
| Medium (4-5 features/week) | 18 | $12 | 20% |
| Heavy (8+ features/week) | 32 | $22 | 37% |
| Power user (daily features) | 60 | $41 | 68% |

All comfortably under the monthly cap.

## Cost Comparison

| Plan | $/feature | Heavy use | Pro | Con |
|---|---|---|---|---|
| **opencode-go (this setup)** | **$0.69** | **$22/mo** | Open weights, $5 first month, generous limits | Smaller model pool than Zen |
| Claude Code (Max plan) | ~$2.50 | ~$80/mo | Frontier models (Opus 4.6) | $100-200/mo, lock-in |
| OpenCode Zen (BYOK) | ~$1.20 | ~$40/mo | Full model catalog (Opus, Fable, GPT-5) | Pay per use, no flat rate |
| Hybrid: Go + Zen fallback | $0.85 avg | ~$30/mo | Best of both | More config |

## Caching — The Hidden Multiplier

All opencode-go models support cached reads at ~10-20% the cost of fresh input. With prompt caching:

- Scout returns the same 50-line context for every task → ~80% cached after first call
- Architect decision is cached for the whole feature → ~95% cached
- Builder loads AGENTS.md + scout summary → ~60% cached

**Real-world factor: 5-8× cost reduction vs uncached pricing.**

So a "$0.69" feature is realistically **$0.10-0.15** with good cache hygiene.

## Cost Discipline Rules

1. **Cap builder↔tester loop at 4 iterations** — every extra iteration costs $0.10+
2. **Skip the orchestrator for trivial work** — typo fixes don't need scout+architect
3. **Use Haiku-tier (mimo-v2.5) for everything search-y** — it's 2× cheaper than cheap tier
4. **Don't repeat architect calls** — cache the design decision
5. **Monitor with `/metrics`** — if p95 cost per feature is climbing, the harness needs tuning
6. **Use the Ralph loop only for greenfield** — Huntley's $50k→$297 results were on a fresh project, not an existing one
