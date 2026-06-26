---
name: "testkit:cases"
description: Phase 2 — generate structured test cases + requirements traceability matrix (rtm.md). Gated by feature-map.md APPROVED.
category: Testing
tags: [testkit, test-cases, rtm]
---

Invoke the `generate-cases` skill using the Skill tool. Pass through any arguments.

Pre-flight: requires `feature-map.md` to contain `> Review: APPROVED` (hook-enforced on Claude Code;
self-check on Cursor). Produces `test-cases.md` + `rtm.md`, ending with `> Review: PENDING`.
