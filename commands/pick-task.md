---
description: Request ClickUp task selection and optional branch preparation through CEO.
agent: ceo
---

$ARGUMENTS

Delegate the ClickUp read to `research-quick` and repository context (current branch, status) to `scout-quick` — both single narrow lookups, both read-only. If branch creation is requested, preview the exact task/base/branch and hand the user the exact `git branch`/`git checkout -b` command to run — no agent creates the branch (`scout`'s allowlist deliberately excludes `git branch*`). Do not update ClickUp.
