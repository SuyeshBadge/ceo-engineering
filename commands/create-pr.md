---
description: Prepare, push, and open a GitHub pull request.
agent: ceo
---

$ARGUMENTS

Tier: risky/irreversible (remote write), the explicit fully-automated exception documented in AGENTS.md — no approval prompt exists in this config (the CEO always runs `--auto`, which makes `ask` behave like `allow`, so this config only ever uses `allow`/`deny`). Delegate the read-only PR-prep context (`git log`, `git diff`/`--stat`, current branch via `git rev-parse --abbrev-ref HEAD`, existing-PR check via the `github` MCP server's `list_pull_requests`/`pull_request_read`) to `scout`. Use the `create-pr` skill plus scout's output to draft the title/body, run `security` if the diff touches a trust boundary, preview the exact branch/base/title/body, then hand off to `builder` to run `git push` (CLI) and `create_pull_request` (the `github` MCP tool) directly — both are plain `allow`, so they execute immediately with no manual hand-off. No force-push, no touching other branches, and this flow doesn't merge the PR it just created — merging is available to `builder` in general now (`merge_pull_request`, see AGENTS.md) but isn't part of this command. The MCP server's repo/content-mutation tools (`create_repository`, `fork_repository`, `create_branch`, `create_or_update_file`, `delete_file`, `push_files`) are not granted to any agent.
