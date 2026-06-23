---
description: Review a pull request by URL or number. Use when reviewing someone else's code.
agent: reviewer
---

## Target PR
$ARGUMENTS

## Instructions

1. Parse the target: if number, prefix with current repo; if URL, extract owner/repo/number
2. Fetch the PR: `gh pr view $ARGUMENTS --json title,body,files,additions,deletions,baseRefName,headRefName,author`
3. Fetch the diff: `gh pr diff $ARGUMENTS`
4. Read the linked issue if referenced
5. Delegate to the **reviewer** subagent with the full diff and PR description
6. Output:
   - **Summary**: <1-paragraph summary of what the PR does>
   - **Verdict**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
   - **Findings**: Blocker / Major / Minor / Praise
   - **Test plan check**: <are tests added? adequate?>
   - **Documentation check**: <docs updated?>
7. Optionally post a comment: `gh pr review $ARGUMENTS --comment --body "..."` (ask user first)
