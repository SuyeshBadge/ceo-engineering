---
description: Route merge-conflict resolution through the CEO controller.
agent: ceo
---

$ARGUMENTS

Delegate read-only conflict-state evidence (`git status`, `git diff`) to `scout-quick` (narrow git-state checks; escalate to `scout` if there are enough conflicted files that reconstructing both-side intent needs real investigation) to capture both-side intent, then serialize one `builder` pass to edit the conflicted files, preserving both-side intent explicitly, then `git add` the resolved files and `git commit` to complete the merge — both are plain `allow` for `builder`, so this runs straight to completion with no manual hand-off and no `tester`/`reviewer` pass. This does not initiate a merge (`git merge` itself stays hook-blocked, human-only) — it only finishes one already in progress from a conflict the user hit.
