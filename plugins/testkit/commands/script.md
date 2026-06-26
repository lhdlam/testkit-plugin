---
name: "testkit:script"
description: Phase 4 — turn scenarios into runnable test code (Playwright POM / pytest-qt Screen Object) with auth state, traceability, tags. Gated by scenarios.md APPROVED.
category: Testing
tags: [testkit, script, playwright, pytest-qt]
---

Invoke the `generate-script` skill using the Skill tool. Pass through any arguments.

Pre-flight: requires `scenarios.md` `> Review: APPROVED` (strongest hook-enforced gate — blocks code
generation before scenarios are signed off). Produces Page/Screen Objects + spec/test files + auth setup,
then runs one smoke flow to verify. Never weaken assertions to match a buggy product → log `bugs.md`.
