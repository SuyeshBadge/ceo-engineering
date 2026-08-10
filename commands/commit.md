---
description: Stage relevant changes and create a Conventional Commit.
agent: builder
---

$ARGUMENTS

Tier: local write (commit only — push and PR creation are plain `allow` too, but that's a separate concern handled by `/create-pr`, not this command). Run `git status --porcelain` and `git diff --cached --stat` (and `git diff --stat` for unstaged changes) to see what's changed. If nothing is staged, stage the relevant changes with `git add`; use judgment — don't blindly `git add -A` if the working tree mixes in unrelated in-progress work, ask first in that case. Write a Conventional Commit message (`<type>: <description>`, optional body; types: feat/fix/refactor/docs/test/chore/perf/ci) and run `git commit -m "..."`. Report the actual commit hash and message. Never fabricate or report cost unless measured.
