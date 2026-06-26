---
name: "testkit:run"
description: Phase 5 — run the suite, classify every failure (Bug | Selector | Timing | Data | Env | Doc-drift), self-heal genuine test issues, route real bugs to bugs.md.
category: Testing
tags: [testkit, run, self-heal]
---

Invoke the `run-and-heal` skill using the Skill tool. Pass through any arguments.

Runs Playwright (Staging) or pytest-qt (headless). Every failure is classified BEFORE any fix.
Two hard rules: never green-wash a real bug; fix data-drift flakiness with independent data, not timeouts.
