---
name: "testkit:analyze"
description: Phase 1 — understand the system under test (read code / docs / explore live UI) and produce feature-map.md. Does not write tests.
category: Testing
tags: [testkit, analyze]
---

Invoke the `analyze-target` skill using the Skill tool. Pass through any arguments.

Produces `feature-map.md` (+ `open-questions.md` for from-docs, `missing-object-names.md` for desktop),
ending with `> Review: PENDING`. Remind the user to review and set `> Review: APPROVED` before `/testkit:cases`.
