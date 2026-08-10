---
description: Force fast-path (reversible/local) handling when the gate is met.
agent: ceo
---

Tier override requested: reversible/local.

$ARGUMENTS

Use the fast path only for a reversible, small, local change with no API/schema/dependency/security/migration/secret/destructive/external-write/infra/production effect. Send straight to `builder`, no scout/architect/reviewer round-trip. If scope turns out bigger, promote to standard tier before writing further.
