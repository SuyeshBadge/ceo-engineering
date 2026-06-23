# Agent Matrix — What Each Agent Does

The 9 subagents have **strict, non-overlapping scope**. Each does ONE thing well.

## Quick Reference

| Agent | Reads | Writes | Runs bash | Spawns | Model |
|---|---|---|---|---|---|
| `ceo` | ✅ | ❌ (denied) | only ls/cat/git status | ✅ all | qwen3.7-plus |
| `scout` | ✅ | ❌ (denied) | only git/rg/find | ❌ | mimo-v2.5 |
| `architect` | ✅ | ❌ (denied) | only ls/cat/rg | ❌ | qwen3.7-max |
| `builder` | ✅ | ✅ | allowed (asks) | scout only | minimax-m3 |
| `reviewer` | ✅ | ❌ (denied) | only git diff/rg | ❌ | minimax-m3 |
| `tester` | ✅ | ❌ (denied) | test/typecheck/lint | scout, builder | kimi-k2.7-code |
| `security` | ✅ | ❌ (denied) | only rg/git diff | ❌ | glm-5.2 |
| `doc-writer` | ✅ | ✅ | ❌ (denied) | ❌ | mimo-v2.5 |
| `devops` | ✅ | ✅ (asks) | all ops (asks) | scout | kimi-k2.7-code |

## Detailed Scope

### `ceo` — The Chief of Staff
**Mission:** Translate intent into delegated work, verify outcomes, report in CEO language.
**Input:** User's natural language request.
**Output:** Plan → delegation chain → final report with status, file:line, verification, cost, risk flags, next step.
**Lifecycle:** Primary. Runs for the whole session.
**Cannot:** Edit files. Run arbitrary commands. Bypass sub-agent allowlist.

### `scout` — The Mapper
**Mission:** Answer "what code is relevant and what files will be touched?" in 1-2 KB.
**Input:** A question or task.
**Output:** Structured report (files, symbols, call paths, patterns, risks).
**Lifecycle:** Subagent, ~15 steps max. Called once at start of each non-trivial task.
**Cannot:** Edit anything. Run package commands. Return > 2 KB.

### `architect` — The Designer
**Mission:** Produce a 1-page design decision document.
**Input:** A problem + scout's context.
**Output:** Decision, why, options table, files affected, risks, reversibility.
**Lifecycle:** Subagent, ~25 steps. Called once per task — cache the result.
**Cannot:** Edit files. Run code. Call itself twice for the same task.

### `builder` — The Coder
**Mission:** Turn plans into working code.
**Input:** Task + scout summary + (optional) architect plan.
**Output:** Diff summary, verification, self-review notes.
**Lifecycle:** Subagent, ~50 steps. Loops with `tester` on failures (max 4 iters).
**Cannot:** Spawn other agents except `scout`. Combine refactor + feature.

### `reviewer` — The Gate
**Mission:** Find what the builder missed. Adversarial but fair.
**Input:** A diff.
**Output:** Verdict + Blocker / Major / Minor / Praise findings, all with file:line.
**Lifecycle:** Subagent, ~25 steps. Spawned in parallel with `tester` after builder.
**Cannot:** Edit files. Approve without reading the diff.

### `tester` — The Verifier
**Mission:** Run tests, typecheck, lint. Report pass/fail. Loop with builder on failures.
**Input:** A diff or test command.
**Output:** Suite results, failure details with file:line, next-step recommendation.
**Lifecycle:** Subagent, ~30 steps. Foreground (blocks CEO).
**Cannot:** Modify source code. Modify tests to make them pass. Loop > 4 times.

### `security` — The Auditor
**Mission:** Find security vulnerabilities. Never approve without audit.
**Input:** A diff + (optional) scout context.
**Output:** Trust boundaries, Critical/High/Medium findings (with CWE refs), threats considered and rejected.
**Lifecycle:** Subagent, ~25 steps. Called when auth/payments/PII/uploads touched, or on `/security`.
**Cannot:** Edit files. Approve with "looks fine". Skip the "rejected threats" section.

### `doc-writer` — The Storyteller
**Mission:** Make code understandable via docs.
**Input:** A diff.
**Output:** Docs updated (file + 1-line change), docs left alone, recommendations.
**Lifecycle:** Subagent, ~15 steps. Cheap. Background. Spawned after tests pass.
**Cannot:** Run any command. Rewrite working docs. Add docs to internal helpers.

### `devops` — The Operator
**Mission:** Deploy, configure, manage infra.
**Input:** A deploy/config request.
**Output:** Action taken, verification, rollback plan, risk flags.
**Lifecycle:** Subagent, ~30 steps. Requires user confirmation for any prod action.
**Cannot:** Auto-deploy to prod. Edit production secrets. Mix deploy with feature work.

## When to Use Which

| You need... | Use |
|---|---|
| A new feature | `ceo` → scout → architect (if complex) → builder → reviewer+tester → doc-writer → commit |
| A bug fix | `ceo` → scout → builder (with failing test) → tester → commit |
| A refactor | `ceo` → scout → builder (incremental) → reviewer (no-behavior-change) → commit |
| A security review | `ceo` → scout → security → fix via builder if needed |
| A deploy | `ceo` → devops (with confirmation) |
| A quick question | Main agent reads directly, no sub-agent |
| Documentation | `ceo` → doc-writer (after tests pass) |
| An external library lookup | `ceo` → scout (with WebFetch) |
| An MVP from scratch | `ceo` → `/mvp` (Ralph loop) |
