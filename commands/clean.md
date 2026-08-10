---
description: Prepare cleanup of local Git state with a destructive-operation approval gate.
agent: ceo
---

$ARGUMENTS

Tier: risky/irreversible (destructive op). Delegate the dirty-state half of the dry run to `scout-quick` (one narrow check: `git status --porcelain` — read-only, in its allowlist). `git branch --merged` is deliberately not in any agent's allowlist (that pattern would also allow `git branch -D`), so ask the user to run it directly, or read pasted output. Combine both into a list of exactly what would be removed. Get explicit user approval naming every branch/ref before handing over the exact deletion command — never run it yourself, and never propose force-deletion when ownership or reversibility is unclear.
