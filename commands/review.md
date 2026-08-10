---
description: Route a read-only review of the current diff/PR through CEO.
agent: ceo
---

$ARGUMENTS

Tier floor: standard, add `reviewer` explicitly. Delegate PR/diff evidence gathering to `scout` (it holds both `gh pr view`/`gh pr diff`/`gh pr list` for PR metadata and `git diff`/`git diff --stat` for local diffs), then hand that evidence to `reviewer` for the actual review. Do not run tests as reviewer. Reviewer stays read-only; it does not post comments — that's `builder`'s job via `/fix-pr` if the review calls for a reply.
