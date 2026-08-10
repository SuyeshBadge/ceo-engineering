---
description: Request non-mutating lint verification through the CEO controller.
agent: ceo
---

$ARGUMENTS

Tier: standard assurance. Delegate to `tester`. No auto-fix, no writing caches/generated artifacts into tracked scope, no mutation of the code under test; failures route back to `builder` for repair.
