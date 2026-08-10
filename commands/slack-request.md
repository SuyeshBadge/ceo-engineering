---
description: Draft a Slack-ready review message through CEO without posting it.
agent: ceo
---

$ARGUMENTS

Delegate PR evidence to `scout-quick` (`gh pr view`/`gh pr diff`; escalate to `scout` if the diff is large enough to need real investigation) and ClickUp evidence to `research-quick` (both narrow, read-only lookups), then use the `slack-request` skill to draft plain text from that evidence. Do not send to Slack — posting or clipboard mutation is a manual step for the user.
