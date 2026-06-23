---
name: metrics
description: Show session cost, throughput, loop health. Addictive — shows your productivity dashboard.
disable-model-invocation: true
allowed-tools: Bash
---

## Period
$ARGUMENTS

## Instructions

Delegate to the `bin/status.sh` script for the dashboard view. Or read session logs for raw data.

## Output (USER mode)

```
━━━ CEO Status: today ━━━

  Spent     $0.42  today

  Numbers
  ────────────────────────────────────
  Tokens in    12,400    this session
  Tokens out   3,200     this session
  Calls        8         agent invocations
  Cache        78% hit   5-8× cost savings

  Goals
  ────────────────────────────────────
  Monthly budget    $60
  Used              $0.42  (1%)
  Remaining         $59.58

  ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  1%

  🔥 Streak    active  (3 days)

  Suggestions
  ────────────────────────────────────
  ℹ Try /refactor on a hot module
  ℹ Run /feature for a new feature
```

## Output (AGENT mode)

```json
{"period":"today","cost_usd":0.42,"tokens_in":12400,"tokens_out":3200,"cache_hit_rate":0.78,"agent_calls":8,"monthly_budget":60,"monthly_used":0.42,"monthly_remaining":59.58,"streak_days":3,"next":["refactor","feature"]}
```

## Report

The metrics skill auto-detects the period and runs the appropriate aggregation. Output is in the chosen mode.
