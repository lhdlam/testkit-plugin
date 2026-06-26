---
name: "testkit:init"
description: Phase 0 — scaffold a test-automation project, pick the target profile, and write CLAUDE.md / Cursor rules + runner config.
category: Testing
tags: [testkit, setup, scaffold]
---

Invoke the `setup` skill using the Skill tool. Pass through any arguments the user provided.

The skill will: detect/ask the target (web-playwright | web-from-docs | web-blackbox | desktop-pyside6),
**ask the output/chat language (en | vi, default vi)**, read `profiles/<target>.md`, scaffold the project
layout + runner config, write `CLAUDE.md` with a language directive (and mirror `.cursor/rules/` for Cursor),
and record the target + language in `${TESTKIT_ROOT:-e2e-tests/docs}/.testkit-target` and `.testkit-lang`.

Next: `/testkit:analyze`.
