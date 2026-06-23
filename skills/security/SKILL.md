---
name: security
description: Security audit of the recent changes. Use before merging auth/payments/PII code.
allowed-tools: Read, Grep, Glob, Bash(git diff:*)
---

## Recent diff
!`git diff HEAD~1 HEAD 2>/dev/dev/null || git diff`

## Instructions

Delegate to the **security** subagent with the diff above.

Output:
- **Trust boundaries**: <what crosses a trust boundary>
- **Critical findings**: <block merge, with CWE ref>
- **High findings**: <fix before merge>
- **Medium findings**: <fix in follow-up>
- **Threats considered and rejected**: <what was checked and dismissed>

Do not skip the "considered and rejected" section — that's the audit trail.
