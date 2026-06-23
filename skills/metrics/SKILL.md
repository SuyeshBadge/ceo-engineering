---
name: metrics
description: Show session cost, throughput, and loop health metrics.
disable-model-invocation: true
allowed-tools: Bash
---

## This session
!`cat ~/.config/opencode/sessions/current.json 2>/dev/null || echo "no current session"`

## Recent sessions
!`ls -lt ~/.config/opencode/sessions/ 2>/dev/null | head -10 || echo "no sessions"`

## This week
!`~/.config/opencode/loops/cost-report.sh week 2>/dev/null || echo "no cost report"`

## Output

Display a dashboard with:
- **Tokens used (this session)**: input / output / cached
- **Cost (this session)**: $X.XX
- **By agent** (table):
  | Agent | Calls | Tokens | Cost |
  | --- | --- | --- | --- |
  | scout | 5 | 12K | $0.02 |
  | builder | 3 | 45K | $0.08 |
  | ... |
- **This week**:
  - Total cost
  - Total tasks completed
  - Avg cost per task
  - Most expensive task
  - Success rate
- **Loop health** (if applicable):
  - Iterations to success (p50, p95)
  - Stuck-loop rate
  - Replan rate
