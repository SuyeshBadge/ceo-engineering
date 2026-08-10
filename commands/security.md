---
description: Route a security audit through mandatory trust-boundary gates.
agent: ceo
---

$ARGUMENTS

Tier: risky/irreversible — trust boundary touched. Get explicit user approval for any execution, then delegate only the named trust boundaries to `security`. `security` scopes its own audit using its own read-only git allowlist (`git status --porcelain`, `git diff --stat` covering staged, unstaged, and untracked files) — CEO does not run an inline diff command, and no agent performs an external write.
