---
description: Prepare branch synchronization for explicit user approval.
agent: ceo
---

$ARGUMENTS

Tier: risky/irreversible (rebase/merge effects) — out of scope for any agent to execute. `git push` itself is plain `allow` for `builder`, but reconciling diverged branches needs `git merge`/`git rebase`, which `block-destructive.sh` hard-blocks for every agent, no exceptions — that's what actually keeps this human-run, not the push. Delegate the read-only preview (`git status --porcelain`, current branch/remote/base) to `scout-quick` (narrow, independent git-state checks), then assemble the exact commands, conflict strategy, and rollback plan; get explicit user approval, then hand over the exact operations for the user to run. Never propose a force-push.
