# Design Language — The Output Format

The CEO Engineering System uses a **dual-mode output language** so the user gets beautiful, scannable output while agents get token-efficient structured data.

## The two modes

### USER mode (TTY, interactive)

Visual, scannable, with status icons, costs, and file:line refs. Designed for a human reading the terminal in 5 seconds.

### AGENT mode (piped, programmatic)

Compact JSON or key=value. ~70% fewer tokens than user mode. Designed for a subagent reading context to make a decision.

## The contract

| | USER mode | AGENT mode |
|---|---|---|
| **Format** | Box + colors + icons | JSON or compact KV |
| **Audience** | Human (you, the CEO) | Subagent (model) |
| **Goal** | "I understand in one glance" | "I have all the data I need" |
| **Tokens** | ~150-300 per report | ~50-100 per report |
| **Decisions enabled** | "Should I commit?" | "What to do next?" |

## The two modes, side by side

Same data, two presentations:

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Feature complete: Add MFA to login                       │
├─────────────────────────────────────────────────────────────┤
│  src/auth/login.ts:42-89    added MFA flow                 │
│  src/auth/mfa.ts:1-156      new module                      │
│                                                             │
│  ────────────────────────────────────────────────────────   │
│  Tests     12/12 ✓    Typecheck  clean ✓                    │
│  Cost      $0.42      Time       4.2s                       │
│  Cache     78% hit    Model      minimax-m3                 │
╰─────────────────────────────────────────────────────────────╯
```

```json
{"status":"ok","action":"feature_complete","target":"add_mfa","files":[{"path":"src/auth/login.ts","lines":"42-89"},{"path":"src/auth/mfa.ts","lines":"1-156"}],"tests":"12/12","typecheck":"clean","cost_usd":0.42,"time_sec":4.2,"cache_hit_rate":0.78,"model":"minimax-m3"}
```

## Conventions

### Status icons (USER mode only)

| Icon | Meaning | Use for |
|---|---|---|
| ✓ | Success | Done, passed, ok |
| ⚠ | Warning | Should fix, deprecated, soft fail |
| ✗ | Failure | Blocked, error, hard fail |
| ℹ | Info | Hint, tip, suggestion |
| → | Next | Suggested action |
| • | List item | Bullet, file, item |
| 🔥 | Streak | Daily use |
| 🎯 | Goal | Achievement |
| ⚡ | Speed | Fast path |

### Status codes (AGENT mode)

| Code | Meaning |
|---|---|
| `ok` | Success |
| `warn` | Warning |
| `fail` | Hard fail |
| `info` | Informational |

### File references

Always use `path:line` or `path:line-line` (range). Never just the filename. Example:
- ✓ `src/auth/login.ts:42-89`
- ✗ `login.ts` (no path)
- ✗ `src/auth/login.ts` (no line)

### Cost

Always in USD with the dollar sign, two decimals. Example: `$0.42`. Never:
- ✗ `0.42` (no symbol)
- ✗ `42 cents` (no decimals)
- ✗ `~$0.42` (no approximation)

### Time

In seconds for short, minutes for long. Example: `4.2s`, `2m 15s`.

### Model

Use the full model ID. Example: `minimax-m3`, not `haiku`.

## The `report` function

Every skill and agent uses a single `report` function that auto-detects mode.

```bash
# User invokes
source ~/.config/opencode/bin/format.sh
report status=ok action=feature_complete target="add_mfa" \
       files="src/auth/login.ts:42-89,src/auth/mfa.ts:1-156" \
       tests=12/12 typecheck=clean cost=0.42 time=4.2

# Same call, in user mode (TTY)
# → pretty box
# Same call, in agent mode (piped)
# → compact JSON
```

### Field reference

| Field | When to use | Example |
|---|---|---|
| `status` | Always | ok, warn, fail, info |
| `action` | What was done | feature_complete, commit, pr_opened |
| `target` | What it was done to | "add_mfa_to_login" |
| `files` | Comma-separated path:line | "src/foo.ts:42,src/bar.ts" |
| `tests` | Pass/total | 12/12, 47/48 |
| `typecheck` | Result | clean, 1 error, clean ✓ |
| `lint` | Result | clean, 2 warnings |
| `cost` | USD | 0.42, 1.20, 0.05 |
| `time` | Seconds | 4.2, 32.1 |
| `cache_hit` | Percentage | 78%, 45% |
| `model` | Model ID | minimax-m3, qwen3.7-plus |
| `risk` | Anything dangerous | "untested edge case" |
| `next` | Comma-separated commands | "/commit,/pr" |
| `detail` | One-line subtitle | "8 new tests" |
| `verdict` | For review | APPROVE, REQUEST CHANGES |

## When to use which mode

| Situation | Mode |
|---|---|
| Skill result printed to user's TUI | USER |
| Subagent reports back to CEO | AGENT |
| CEO reports back to user | USER |
| Hook blocks an action | USER (with reason) |
| Session log written to disk | AGENT (parseable) |
| `/metrics` output | USER (dashboard) |
| Cross-agent handoff | AGENT (compact) |

## Auto-detection

The `format.sh` library auto-detects mode:
- If stdout is a TTY → USER mode
- If stdout is piped → AGENT mode

You can override with:
```bash
CEO_MODE_OVERRIDE=user report ...
CEO_MODE_OVERRIDE=agent report ...
```

## The visual hierarchy

USER mode follows a strict visual hierarchy:

```
╭─ Title (bold) ─────────────────────────────────────╮
│ Subtitle (dim)                                     │
├─────────────────────────────────────────────────────┤
│ Section 1 (bold)                                   │
│   • Item 1                                         │
│   • Item 2                                         │
│                                                     │
│ Section 2 (bold)                                   │
│   Label (dim)     Value (bold)                     │
├─────────────────────────────────────────────────────┤
│ Warnings (yellow)                                  │
╰─────────────────────────────────────────────────────╯
  → Command 1  description
  → Command 2  description
```

## The token budget

| Mode | Tokens per report | Use for |
|---|---|---|
| USER | 150-300 | The CEO's final view |
| AGENT | 50-100 | Subagent-to-subagent |
| Minimal | 10-20 | Status checks |

If a report is over budget, the format library auto-compresses to the next tier.

## Examples

### /commit (USER)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Committed                                                 │
├─────────────────────────────────────────────────────────────┤
│  hash:  a1b2c3d                                             │
│  type:  feat(auth)                                          │
│  files: src/auth/login.ts, src/auth/mfa.ts                  │
│  +47 / -12                                                  │
╰─────────────────────────────────────────────────────────────╯
  → /pr   open a pull request
```

### /commit (AGENT)

```json
{"status":"ok","action":"commit","hash":"a1b2c3d","type":"feat","scope":"auth","files":["src/auth/login.ts","src/auth/mfa.ts"],"additions":47,"deletions":12,"next":["pr"]}
```

### /feature (USER)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Feature complete: Add MFA to login                       │
├─────────────────────────────────────────────────────────────┤
│  src/auth/login.ts:42-89    added MFA flow                 │
│  src/auth/mfa.ts:1-156      new MFA module                  │
│  tests/auth/mfa.test.ts     8 new tests                     │
│                                                             │
│  ────────────────────────────────────────────────────────   │
│  Tests       12/12 ✓      Typecheck     clean ✓            │
│  Cost        $0.42        Time          4.2s               │
│  Cache       78% hit      Model         minimax-m3          │
│  Agents      8 calls      Subagents     scout, builder...   │
╰─────────────────────────────────────────────────────────────╯
  → /commit   /pr   /review   /refactor   /security
```

### /feature (AGENT)

```json
{"status":"ok","action":"feature_complete","target":"add_mfa_to_login","files":[{"path":"src/auth/login.ts","lines":"42-89","action":"added_mfa_flow"},{"path":"src/auth/mfa.ts","lines":"1-156","action":"new_module"},{"path":"tests/auth/mfa.test.ts","action":"new_tests","count":8}],"verification":{"tests":"12/12","typecheck":"clean","lint":"clean"},"cost_usd":0.42,"time_sec":4.2,"cache_hit_rate":0.78,"model":"minimax-m3","agent_calls":8,"subagents":["scout","builder","reviewer","tester","doc-writer"],"next":["commit","pr","review","refactor","security"]}
```

### /review (USER)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Review: REQUEST CHANGES                                   │
├─────────────────────────────────────────────────────────────┤
│  3 files, 47 lines                                          │
│                                                             │
│  Blocker  (must fix before merge)                           │
│    (none)                                                   │
│                                                             │
│  Major    (should fix)                                      │
│    src/auth/login.ts:42   verifyToken missing null check   │
│                                                             │
│  Minor    (nit)                                             │
│    src/auth/mfa.ts:23     prefer `const` over `let`         │
│                                                             │
│  Praise                                                     │
│    tests/auth/mfa.test.ts comprehensive edge case coverage  │
╰─────────────────────────────────────────────────────────────╯
  → /bug "fix null check in verifyToken"   (recommended)
  → /commit                                  (if you disagree)
```

## Building blocks

The `bin/format.sh` library provides:

| Function | USER output | AGENT output |
|---|---|---|
| `report` | Pretty box with sections | JSON with fields |
| `user_box` / `agent_box` | Bordered box | JSON title+subtitle |
| `user_list` / `agent_list` | Bullet list | JSON array |
| `user_table` / `agent_table` | Aligned table | JSON rows |
| `user_metric` / `agent_metric` | Big number | JSON metric |
| `user_step` / `agent_step` | Numbered step | JSON step |
| `user_next` / `agent_next` | Suggested actions | JSON next |
| `user_hint` | Dim tip | (skipped — no fluff) |
| `user_header` | Section header | JSON section |

## Source the library

```bash
# From a skill
source ~/.config/opencode/bin/format.sh
report status=ok action=feature_complete target="add MFA" cost=0.42

# From a hook
source ~/.config/opencode/bin/format.sh
report status=warn action=blocked detail="destructive command" risk="rm -rf is dangerous"
```

## Force mode

```bash
# Force user mode (for handoffs to humans)
CEO_MODE_OVERRIDE=user report status=ok action=setup

# Force agent mode (for handoffs to subagents)
CEO_MODE_OVERRIDE=agent report status=ok action=setup
```

## Bin scripts

| Script | What |
|---|---|
| `bin/format.sh` | The output library |
| `bin/demo.sh` | First-run experience |
| `bin/status.sh` | Daily status dashboard |
| `bin/present.sh` | Mode-switching wrapper |

Run `bin/demo.sh` to see the design language in action.
