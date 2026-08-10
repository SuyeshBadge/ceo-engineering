---
description: Force risky/irreversible-tier handling through the CEO controller.
agent: ceo
---

Tier override: risky/irreversible.

$ARGUMENTS

Get explicit consolidated user approval before executing. Run the full chain — `scout` → `architect` (if there's a real design trade-off) → `builder` → `tester` → `reviewer` — and add `security` whenever a trust boundary is touched. This tier is never demoted mid-flight.
